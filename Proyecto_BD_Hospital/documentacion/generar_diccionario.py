#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera el documento PDF del Proyecto 1: modelo, diccionario de datos y sentencias SQL.

El diccionario se arma leyendo el catalogo de la base (tipos, nulos, llaves,
acciones referenciales y los COMMENT de sql/ddl/15_comentarios.sql). La
justificacion de cada llave foranea esta en justificaciones.py.

Conexion: variables PGHOST, PGPORT, PGUSER, PGDATABASE y PGPASSWORD (o ~/.pgpass).
"""
import glob
import os
import subprocess
import sys
from datetime import date
from html import escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.lib.utils import ImageReader
from reportlab.platypus import (BaseDocTemplate, Frame, Image, KeepTogether, NextPageTemplate,
                                PageBreak, PageTemplate, Paragraph, Preformatted, Spacer, Table,
                                TableStyle)

BASE = os.path.dirname(os.path.abspath(__file__))
PROY = os.path.abspath(os.path.join(BASE, '..'))
OUT = os.path.join(BASE, 'Diccionario_Datos_Hospital.pdf')
IMG = os.path.join(PROY, 'modelo', 'modelo_barker.png')
sys.path.insert(0, BASE)
from justificaciones import JUSTIFICACIONES  # noqa: E402

ACCION = {'a': 'NO ACTION', 'r': 'RESTRICT', 'c': 'CASCADE', 'n': 'SET NULL', 'd': 'SET DEFAULT'}


def psql(sql):
    env = dict(os.environ)
    env.setdefault('PGHOST', 'localhost')
    env.setdefault('PGPORT', '5433')
    env.setdefault('PGUSER', 'hospital')
    env.setdefault('PGDATABASE', 'hospital')
    r = subprocess.run(['psql', '-Atq', '-F', '\t', '-c', sql], capture_output=True, text=True, env=env)
    if r.returncode != 0:
        raise SystemExit('psql: ' + r.stderr[:400])
    return [line.split('\t') for line in r.stdout.splitlines()]


def leer_catalogo():
    tablas = {t: d for t, d in psql("""
        select relname, coalesce(obj_description(oid, 'pg_class'), '')
          from pg_class where relnamespace = 'public'::regnamespace and relkind = 'r'""")}
    columnas = {}
    for t, c, tipo, nn, pk, desc in psql("""
        select c.relname, a.attname, format_type(a.atttypid, a.atttypmod), a.attnotnull::int,
               exists(select 1 from pg_index i where i.indrelid = c.oid and i.indisprimary
                      and a.attnum = any(i.indkey))::int,
               coalesce(col_description(c.oid, a.attnum), '')
          from pg_class c join pg_attribute a on a.attrelid = c.oid
         where c.relnamespace = 'public'::regnamespace and c.relkind = 'r'
           and a.attnum > 0 and not a.attisdropped
         order by c.relname, a.attnum"""):
        columnas.setdefault(t, []).append({'col': c, 'tipo': tipo, 'nn': nn == '1', 'pk': pk == '1', 'desc': desc})
    fks = {}
    for t, c, padre, borrar, actualizar in psql("""
        select f.conrelid::regclass::text, a.attname, f.confrelid::regclass::text,
               f.confdeltype, f.confupdtype
          from pg_constraint f
          join pg_attribute a on a.attrelid = f.conrelid and a.attnum = f.conkey[1]
         where f.contype = 'f' and f.connamespace = 'public'::regnamespace"""):
        fks[(t, c)] = (padre, ACCION[borrar], ACCION[actualizar])
    checks = {}
    for t, nombre, definicion in psql("""
        select conrelid::regclass::text, conname, pg_get_constraintdef(oid)
          from pg_constraint
         where contype = 'c' and connamespace = 'public'::regnamespace
         order by 1, 2"""):
        checks.setdefault(t, []).append((nombre, definicion))
    return tablas, columnas, fks, checks


# ------------------------------------------------------------------ estilos
ss = getSampleStyleSheet()
H1 = ParagraphStyle('h1', parent=ss['Heading1'], fontSize=15, spaceAfter=8)
H2 = ParagraphStyle('h2', parent=ss['Heading2'], fontSize=11, spaceBefore=6, spaceAfter=3)
BODY = ParagraphStyle('body', parent=ss['BodyText'], fontSize=9.5, leading=13, alignment=TA_JUSTIFY)
CEN = ParagraphStyle('cen', parent=BODY, alignment=TA_CENTER)
TIT = ParagraphStyle('tit', parent=BODY, fontSize=18, leading=24, alignment=TA_CENTER)
CEL = ParagraphStyle('cel', parent=BODY, fontSize=7.3, leading=8.8, alignment=0)
CODE = ParagraphStyle('code', fontName='Courier', fontSize=6.6, leading=7.8)


def p(texto, estilo=CEL):
    return Paragraph(texto, estilo)


def portada(S):
    S.append(Spacer(1, 40))
    for linea in ['Universidad de San Carlos de Guatemala', 'Centro Universitario de Occidente',
                  'División de Ciencias de la Ingeniería', 'Sistemas de Bases de Datos 1']:
        S.append(p(linea, CEN))
    S.append(Spacer(1, 60))
    S.append(p('<b>Proyecto 1</b>', TIT))
    S.append(p('Modelado y Gestión de una Base de Datos Hospitalaria', TIT))
    S.append(Spacer(1, 10))
    S.append(p('Modelo de datos (notación Barker), diccionario de datos y sentencias SQL', CEN))
    S.append(Spacer(1, 80))
    t = Table([[p('Estudiante', CEN), p('Juan Carlos Rodríguez López', CEN)],
               [p('Carné', CEN), p('202231970', CEN)],
               [p('Fecha', CEN), p(date.today().strftime('%d/%m/%Y'), CEN)]],
              colWidths=[4 * cm, 7 * cm], hAlign='CENTER')
    t.setStyle(TableStyle([('GRID', (0, 0), (-1, -1), 0.4, colors.black),
                           ('VALIGN', (0, 0), (-1, -1), 'MIDDLE')]))
    S.append(t)
    S.append(PageBreak())


def introduccion(S, tablas, fks, checks):
    S.append(p('1. Descripción del modelo', H1))
    S.append(p('La base de datos registra la actividad diaria de la cadena Hospitales de Occidente en sus '
               'cuatro unidades (Consulta Externa, Emergencias, Cirugía y Hospitalización), el personal, '
               'los pacientes y sus encargados, la facturación en cuotas y el archivo de calificaciones '
               'de la calidad del servicio. Se implementó en PostgreSQL 18.', BODY))
    S.append(p('Resumen del esquema', H2))
    resumen = [['Tablas', str(len(tablas))], ['Llaves foráneas', str(len(fks))],
               ['Restricciones CHECK', str(sum(len(v) for v in checks.values()))],
               ['Vistas', 'v_paciente, v_consulta, v_estancia, v_cirugia, v_factura'],
               ['Reglas entre tablas', 'disparadores en sql/ddl/13_reglas_negocio.sql']]
    t = Table([[p('<b>%s</b>' % a, BODY), p(b, BODY)] for a, b in resumen], colWidths=[5 * cm, 11 * cm])
    t.setStyle(TableStyle([('GRID', (0, 0), (-1, -1), 0.3, colors.grey)]))
    S.append(t)
    S.append(p('Decisiones de diseño', H2))
    for d in [
        'Las llaves primarias son identity y se llaman <i>id_&lt;tabla&gt;</i>; la llave foránea usa el mismo '
        'nombre que la PK a la que apunta, o agrega el rol cuando una tabla apunta dos veces a la misma '
        '(id_medico_cirujano, id_unidad_origen).',
        'No se guardan datos derivables: la edad se calcula con fn_edad y los días hospitalizado, el hospital '
        'de cada factura y lo pagado se obtienen en vistas. Así no quedan datos desactualizados.',
        'Los valores que se repiten (estado civil, parentesco, medicamento, diagnóstico CIE-10, tipo de cirugía, '
        'tipo de anestesia, rol quirúrgico, método de pago) están en catálogos; los dominios cerrados y pequeños '
        '(sexo, área, código de egreso, carácter de la cirugía) se validan con CHECK.',
        'Las relaciones muchos a muchos se resuelven con entidades asociativas de PK compuesta '
        '(paciente_encargado, receta_medicamento, turno_medico, requerimiento_*, cirugia_insumo, '
        'hospitalizacion_insumo, egreso_diagnostico, documentacion_etapa).',
        'Arcos exclusivos: la factura proviene de exactamente una cita, ingreso o cirugía; el traslado sale de '
        'una consulta o de un ingreso; la calificación evalúa a exactamente un hospital, médico, enfermero o '
        'encargado. Se garantizan con CHECK usando num_nonnulls().',
        'Las reglas que dependen de otra tabla (la camilla pertenece a la unidad del ingreso, la cirugía requiere '
        'un agendamiento aprobado, la cuota no excede el plan de la factura, etc.) se validan con disparadores.']:
        S.append(p('• ' + d, BODY))


def modelo(S):
    S.append(NextPageTemplate('horizontal'))
    S.append(PageBreak())
    S.append(p('2. Modelo de datos (notación Barker)', H1))
    S.append(p('# identificador único, * obligatorio, o opcional. Las llaves foráneas se representan como '
               'relaciones: mitad continua = la entidad debe participar, mitad punteada = puede participar; '
               'pata de gallo en el lado "muchos"; barra cuando la relación forma parte del identificador. '
               'Archivo editable: modelo/modelo_barker.drawio.', BODY))
    ancho, alto = landscape(letter)[0] - 2 * cm, landscape(letter)[1] - 4.5 * cm

    def imagen(ruta):
        w, h = ImageReader(ruta).getSize()
        escala = min(ancho / w, alto / h)
        return Image(ruta, width=w * escala, height=h * escala)

    S.append(p('Vista general', H2))
    S.append(imagen(IMG))
    partes = sorted(glob.glob(os.path.join(PROY, 'modelo', 'modelo_barker_parte*.png')))
    for i, ruta in enumerate(partes, 1):
        S.append(PageBreak())
        S.append(p('Detalle %d de %d (de izquierda a derecha)' % (i, len(partes)), H2))
        S.append(imagen(ruta))
    S.append(NextPageTemplate('vertical'))


def diccionario(S, tablas, columnas, fks, checks):
    S.append(PageBreak())
    S.append(p('3. Diccionario de datos', H1))
    S.append(p('Una tabla por entidad. En las filas de llave foránea se indica la acción referencial ante '
               'DELETE y UPDATE y su justificación de negocio.', BODY))
    cab = ['Atributo', 'Tipo de dato', 'Llave', 'Nulos', 'Descripción', 'DELETE', 'UPDATE', 'Justificación']
    anchos = [2.9 * cm, 2.4 * cm, 1.0 * cm, 1.0 * cm, 3.6 * cm, 1.6 * cm, 1.5 * cm, 4.6 * cm]
    for t in sorted(tablas):
        filas = [[p('<b>%s</b>' % c) for c in cab]]
        for c in columnas[t]:
            fk = fks.get((t, c['col']))
            llave = 'PK/FK' if c['pk'] and fk else ('PK' if c['pk'] else ('FK' if fk else '—'))
            desc = c['desc']
            if not desc and c['pk'] and not fk:
                desc = 'Identificador único de %s.' % t
            elif not desc and fk:
                desc = 'Referencia a %s.' % fk[0]
            borrar = actualizar = just = ''
            if fk:
                borrar, actualizar = fk[1], fk[2]
                just = JUSTIFICACIONES.get((t, c['col']), '')
                if not just:
                    raise SystemExit('Falta justificación para %s.%s' % (t, c['col']))
            filas.append([p(c['col']), p(c['tipo']), p(llave), p('No' if c['nn'] else 'Sí'),
                          p(escape(desc)), p(borrar), p(actualizar), p(escape(just))])
        tabla = Table(filas, colWidths=anchos, repeatRows=1)
        tabla.setStyle(TableStyle([('GRID', (0, 0), (-1, -1), 0.3, colors.grey),
                                   ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#dde6f0')),
                                   ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                                   ('TOPPADDING', (0, 0), (-1, -1), 1.5), ('BOTTOMPADDING', (0, 0), (-1, -1), 1.5),
                                   ('LEFTPADDING', (0, 0), (-1, -1), 2), ('RIGHTPADDING', (0, 0), (-1, -1), 2)]))
        bloque = [p('Tabla: %s' % t, H2), p(escape(tablas[t]), BODY), Spacer(1, 2), tabla]
        if checks.get(t):
            bloque.append(p('<b>Restricciones CHECK:</b> ' + '; '.join(
                '%s: <font face="Courier" size="6.5">%s</font>' % (n, escape(d)) for n, d in checks[t]), CEL))
        S.append(KeepTogether(bloque) if len(filas) < 25 else bloque[0])
        if len(filas) >= 25:
            S.extend(bloque[1:])
        S.append(Spacer(1, 6))


def sentencias(S):
    S.append(PageBreak())
    S.append(p('4. Sentencias SQL', H1))
    S.append(p('Contenido completo de los scripts entregados en sql/, en el orden en que se ejecutan: '
               'DDL (sql/ddl), DML (sql/dml) y DCL (sql/dcl).', BODY))
    for carpeta, titulo in [('ddl', 'DDL'), ('dml', 'DML'), ('dcl', 'DCL')]:
        for ruta in sorted(glob.glob(os.path.join(PROY, 'sql', carpeta, '*.sql'))):
            S.append(p('%s — sql/%s/%s' % (titulo, carpeta, os.path.basename(ruta)), H2))
            with open(ruta, encoding='utf-8') as f:
                S.append(Preformatted(f.read(), CODE, maxLineLength=150, newLineChars=''))


def build():
    tablas, columnas, fks, checks = leer_catalogo()
    vertical = letter
    margen = 1.5 * cm
    doc = BaseDocTemplate(OUT, pagesize=vertical, title='Proyecto 1 - Hospitales de Occidente',
                          author='Juan Carlos Rodríguez López')
    doc.addPageTemplates([
        PageTemplate('vertical', [Frame(margen, margen, vertical[0] - 2 * margen, vertical[1] - 2 * margen)],
                     pagesize=vertical),
        PageTemplate('horizontal', [Frame(1 * cm, 1 * cm, landscape(letter)[0] - 2 * cm,
                                          landscape(letter)[1] - 2 * cm)], pagesize=landscape(letter)),
    ])
    S = []
    portada(S)
    introduccion(S, tablas, fks, checks)
    modelo(S)
    diccionario(S, tablas, columnas, fks, checks)
    sentencias(S)
    doc.build(S)
    return OUT


if __name__ == '__main__':
    print('PDF: ' + build())
