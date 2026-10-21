#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera el documento PDF del Proyecto 2.

Contenido: modelo extendido, diccionario de datos de las tablas nuevas o
modificadas (y el completo como anexo), los 20 objetivos con su sentencia y su
captura, el ORM, la normalizacion del Bloque E, la auditoria, la comparacion de
rendimiento del objetivo 17 y todas las sentencias SQL del Proyecto 2.

El diccionario se arma leyendo el catalogo de la base con el rol visor; las
explicaciones de cada CHECK y de cada disparador se toman de los comentarios
"-- valida ..." que acompañan a cada uno en los scripts SQL.

Uso: HOSPITAL_DB_PASSWORD=... python3 generar_documento.py
"""
import glob
import os
import re
import subprocess
import sys
from datetime import date
from html import escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
from reportlab.lib.pagesizes import landscape, letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.lib.utils import ImageReader
from reportlab.platypus import (BaseDocTemplate, CondPageBreak, Frame, Image, KeepTogether, NextPageTemplate,
                                PageBreak, PageTemplate, Paragraph, Preformatted, Spacer, Table, TableStyle)
from reportlab.platypus.tableofcontents import TableOfContents

BASE = os.path.dirname(os.path.abspath(__file__))
P2 = os.path.abspath(os.path.join(BASE, '..'))
P1 = os.path.abspath(os.path.join(P2, '..', '..', 'Proyecto_BD_Hospital'))
SALIDA = os.path.join(BASE, 'Proyecto2_Hospitales_de_Occidente.pdf')
IMG_MODELO = os.path.join(P2, 'modelo', 'modelo_barker_p2.png')
CAPTURAS = os.path.join(BASE, 'capturas')

sys.path.insert(0, BASE)
sys.path.insert(0, os.path.join(P1, 'documentacion'))
from justificaciones import JUSTIFICACIONES  # noqa: E402  (Proyecto 1)
from justificaciones_p2 import JUSTIFICACIONES_P2  # noqa: E402

JUSTIFICACION = {**JUSTIFICACIONES, **JUSTIFICACIONES_P2}
NUEVAS = ['personal', 'auditoria_personal']
MODIFICADAS = ['medico', 'enfermero']
ACCION = {'a': 'NO ACTION', 'r': 'RESTRICT', 'c': 'CASCADE', 'n': 'SET NULL', 'd': 'SET DEFAULT'}


# ---------------------------------------------------------------- base de datos
def psql(sql):
    env = dict(os.environ)
    if not env.get('HOSPITAL_DB_PASSWORD'):
        raise SystemExit('Defina HOSPITAL_DB_PASSWORD con la clave del rol visor')
    env['PGPASSWORD'] = env['HOSPITAL_DB_PASSWORD']
    r = subprocess.run(['psql', '-h', 'localhost', '-p', '5433', '-U', 'visor', '-d', 'hospital', '-X', '-Atq',
                        '-F', '\x1f', '-c', sql], capture_output=True, text=True, env=env)
    if r.returncode != 0:
        raise SystemExit('psql: ' + r.stderr[:500])
    return [l.split('\x1f') for l in r.stdout.splitlines()]


def leer_catalogo():
    cat = {'tablas': {}, 'cols': {}, 'fk': {}, 'uk': set(), 'uk_compuestos': {}, 'checks': {}, 'triggers': {}, 'indices': {}}
    for t, d in psql("""select relname, coalesce(obj_description(oid, 'pg_class'), '') from pg_class
                         where relnamespace = 'public'::regnamespace and relkind = 'r' order by relname"""):
        cat['tablas'][t] = d
    for t, c, tipo, nn, pk, defecto, d in psql("""
        select c.relname, a.attname, format_type(a.atttypid, a.atttypmod), a.attnotnull::int,
               exists(select 1 from pg_index i where i.indrelid = c.oid and i.indisprimary and a.attnum = any(i.indkey))::int,
               coalesce(case when a.attidentity in ('a', 'd') then 'identity' end, pg_get_expr(ad.adbin, ad.adrelid), ''),
               coalesce(col_description(c.oid, a.attnum), '')
          from pg_class c join pg_attribute a on a.attrelid = c.oid
          left join pg_attrdef ad on ad.adrelid = c.oid and ad.adnum = a.attnum
         where c.relnamespace = 'public'::regnamespace and c.relkind = 'r' and a.attnum > 0 and not a.attisdropped
         order by c.relname, a.attnum"""):
        cat['cols'].setdefault(t, []).append(dict(col=c, tipo=tipo, nn=nn == '1', pk=pk == '1', defecto=defecto, desc=d))
    for t, c, padre, borrar, actualizar in psql("""
        select f.conrelid::regclass::text, a.attname, f.confrelid::regclass::text, f.confdeltype, f.confupdtype
          from pg_constraint f join pg_attribute a on a.attrelid = f.conrelid and a.attnum = any(f.conkey)
         where f.contype = 'f' and f.connamespace = 'public'::regnamespace"""):
        cat['fk'][(t, c)] = (padre, ACCION[borrar], ACCION[actualizar])
    for t, n, cols_uk in psql("""select x.conrelid::regclass::text, x.conname,
                                     string_agg(a.attname, ', ' order by k.ord)
                                from pg_constraint x
                                cross join lateral unnest(x.conkey) with ordinality k(attnum, ord)
                                join pg_attribute a on a.attrelid = x.conrelid and a.attnum = k.attnum
                               where x.contype = 'u' and x.connamespace = 'public'::regnamespace
                               group by x.conrelid, x.conname"""):
        if ', ' in cols_uk:
            cat['uk_compuestos'].setdefault(t, []).append((n, cols_uk))
        else:
            cat['uk'].add((t, cols_uk))
    for t, n, d in psql("""select conrelid::regclass::text, conname, pg_get_constraintdef(oid) from pg_constraint
                            where contype = 'c' and connamespace = 'public'::regnamespace order by 1, 2"""):
        cat['checks'].setdefault(t, []).append((n, d))
    for t, n, d, f in psql("""select tgrelid::regclass::text, tgname, pg_get_triggerdef(oid), tgfoid::regproc::text
                               from pg_trigger where not tgisinternal and tgrelid::regclass::text not like '%.%'
                              order by 1, 2"""):
        m = re.match(r'CREATE (?:CONSTRAINT )?TRIGGER \S+ (.*?) ON ', d)
        cat['triggers'].setdefault(t, []).append((n, m.group(1) if m else '', f))
    for t, n, d in psql("""select tablename, indexname, indexdef from pg_indexes where schemaname = 'public'
                            order by 1, 2"""):
        cat['indices'].setdefault(t, []).append((n, re.sub(r'^.* USING btree ', '', d)))
    return cat


def comentarios_sql():
    """Explicacion de cada CHECK y de cada funcion, tomada del comentario que la precede en los scripts."""
    checks, funciones = {}, {}
    rutas = glob.glob(os.path.join(P1, 'sql', 'ddl', '*.sql')) + glob.glob(os.path.join(P2, 'sql', '**', '*.sql'), recursive=True)
    for ruta in rutas:
        texto = open(ruta, encoding='utf-8').read()
        for m in re.finditer(r'--\s*(.+)\n\s*(?:add\s+)?constraint\s+(\w+)', texto):
            checks[m.group(2)] = m.group(1).strip()[:1].upper() + m.group(1).strip()[1:]
        for m in re.finditer(r'--\s*(.+)\n(?:--.*\n)*\s*create (?:or replace )?function (\w+)', texto):
            funciones.setdefault(m.group(2), m.group(1).strip()[:1].upper() + m.group(1).strip()[1:])
    return checks, funciones


# ---------------------------------------------------------------- estilos
ss = getSampleStyleSheet()
H1 = ParagraphStyle('h1', parent=ss['Heading1'], fontSize=16, spaceBefore=4, spaceAfter=8, textColor=colors.HexColor('#0D47A1'))
H2 = ParagraphStyle('h2', parent=ss['Heading2'], fontSize=12, spaceBefore=8, spaceAfter=4, textColor=colors.HexColor('#1565C0'))
H3 = ParagraphStyle('h3', parent=ss['Heading3'], fontSize=10, spaceBefore=6, spaceAfter=3)
CUERPO = ParagraphStyle('cuerpo', parent=ss['BodyText'], fontSize=9.5, leading=13, alignment=TA_JUSTIFY)
CENTRO = ParagraphStyle('centro', parent=CUERPO, alignment=TA_CENTER)
TITULO = ParagraphStyle('titulo', parent=CUERPO, fontSize=20, leading=26, alignment=TA_CENTER)
CELDA = ParagraphStyle('celda', parent=CUERPO, fontSize=7.4, leading=9, alignment=0)
CELDA_B = ParagraphStyle('celda_b', parent=CELDA, fontName='Helvetica-Bold')
CODIGO = ParagraphStyle('codigo', fontName='Courier', fontSize=6.9, leading=8.2, textColor=colors.HexColor('#263238'),
                        backColor=colors.HexColor('#F5F6F8'), borderPadding=4)
GRILLA = [('GRID', (0, 0), (-1, -1), 0.3, colors.HexColor('#B0BEC5')),
          ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#E3F2FD')),
          ('VALIGN', (0, 0), (-1, -1), 'TOP'),
          ('TOPPADDING', (0, 0), (-1, -1), 2), ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
          ('LEFTPADDING', (0, 0), (-1, -1), 3), ('RIGHTPADDING', (0, 0), (-1, -1), 3)]


def p(texto, estilo=CELDA):
    return Paragraph(texto, estilo)


def tabla(filas, anchos, encabezado=True, extra=()):
    t = Table(filas, colWidths=anchos, repeatRows=1 if encabezado else 0)
    t.setStyle(TableStyle(GRILLA + list(extra)))
    return t


def codigo(texto, ancho_linea=130):
    return Preformatted(texto.rstrip(), CODIGO, maxLineLength=ancho_linea, newLineChars='')


def imagen(ruta, ancho_max, alto_max):
    w, h = ImageReader(ruta).getSize()
    escala = min(ancho_max / w, alto_max / h, 1.0 if w < ancho_max * 0.6 else 99)
    return Image(ruta, width=w * escala, height=h * escala)


# ---------------------------------------------------------------- documento con indice
class Documento(BaseDocTemplate):
    def __init__(self, ruta):
        super().__init__(ruta, pagesize=letter, title='Proyecto 2 - Hospitales de Occidente',
                         author='Juan Carlos Rodríguez López')
        m = 1.5 * cm
        v, hz = letter, landscape(letter)
        pie = self.pie
        self.addPageTemplates([
            PageTemplate('vertical', [Frame(m, m, v[0] - 2 * m, v[1] - 2 * m)], pagesize=v, onPage=pie),
            PageTemplate('horizontal', [Frame(1 * cm, 1.2 * cm, hz[0] - 2 * cm, hz[1] - 2.2 * cm)], pagesize=hz, onPage=pie),
        ])

    @staticmethod
    def pie(canvas, doc):
        canvas.saveState()
        canvas.setFont('Helvetica', 7.5)
        canvas.setFillColor(colors.grey)
        canvas.drawString(1.2 * cm, 0.7 * cm, 'Proyecto 2 — Hospitales de Occidente — Sistemas de Bases de Datos 1')
        canvas.drawRightString(doc.pagesize[0] - 1.2 * cm, 0.7 * cm, 'Página %d' % doc.page)
        canvas.restoreState()

    def afterFlowable(self, f):
        if isinstance(f, Paragraph) and f.style.name in ('h1', 'h2'):
            nivel = 0 if f.style.name == 'h1' else 1
            texto = f.getPlainText()
            clave = 'h%d' % id(f)
            self.canv.bookmarkPage(clave)
            self.notify('TOCEntry', (nivel, texto, self.page, clave))


ANCHO_V = letter[0] - 3 * cm
ANCHO_H = landscape(letter)[0] - 2 * cm


# ---------------------------------------------------------------- secciones
def portada(S):
    S.append(Spacer(1, 30))
    for linea in ['Universidad de San Carlos de Guatemala', 'Centro Universitario de Occidente',
                  'División de Ciencias de la Ingeniería', 'Ingeniería en Ciencias y Sistemas',
                  'Sistemas de Bases de Datos 1']:
        S.append(p(linea, CENTRO))
    S.append(Spacer(1, 70))
    S.append(p('<b>Proyecto 2</b>', TITULO))
    S.append(p('Base de Datos Hospitalaria: Consultas Avanzadas, Lógica del Negocio y Seguridad', TITULO))
    S.append(Spacer(1, 90))
    t = Table([[p('Estudiante', CENTRO), p('Juan Carlos Rodríguez López', CENTRO)],
               [p('Carné', CENTRO), p('202231970', CENTRO)],
               [p('Fecha', CENTRO), p(date.today().strftime('%d/%m/%Y'), CENTRO)]],
              colWidths=[4 * cm, 7 * cm], hAlign='CENTER')
    t.setStyle(TableStyle([('GRID', (0, 0), (-1, -1), 0.4, colors.black), ('VALIGN', (0, 0), (-1, -1), 'MIDDLE')]))
    S.append(t)
    S.append(PageBreak())
    S.append(p('Contenido', H1.clone('indice')))
    toc = TableOfContents()
    toc.levelStyles = [ParagraphStyle('t0', fontSize=10, leading=14, leftIndent=0, fontName='Helvetica-Bold'),
                       ParagraphStyle('t1', fontSize=9, leading=12, leftIndent=14)]
    S.append(toc)
    S.append(PageBreak())


def introduccion(S, cat):
    S.append(p('1. Descripción general', H1))
    S.append(p('El Proyecto 2 extiende la misma base de datos del Proyecto 1 (mismo esquema y datos, ampliados). '
               'Se resolvieron los 20 objetivos del enunciado organizados en seis bloques: consultas de inteligencia '
               'de negocio (A), extensión del modelo (B), reportes del personal médico (C), programa de fidelidad (D), '
               'revisión del reporte de cirugías (E) y trazabilidad de cambios sensibles (F).', CUERPO))
    S.append(p('Resumen del esquema final', H2))
    filas = [[p('<b>Elemento</b>'), p('<b>Cantidad</b>')],
             [p('Tablas'), p(str(len(cat['tablas'])))],
             [p('Tablas nuevas del Proyecto 2'), p(', '.join(NUEVAS))],
             [p('Tablas modificadas por el Proyecto 2'), p(', '.join(MODIFICADAS))],
             [p('Llaves foráneas'), p(str(len({k for k in cat['fk']})))],
             [p('Restricciones CHECK'), p(str(sum(len(v) for v in cat['checks'].values())))],
             [p('Disparadores'), p(str(sum(len(v) for v in cat['triggers'].values())))],
             [p('Funciones de consulta (una por objetivo)'), p('fn_objetivo_01 … fn_objetivo_18, fn_cadena_mando, fn_objetivo_17_*')]]
    S.append(tabla(filas, [8 * cm, ANCHO_V - 8 * cm]))
    S.append(p('Decisiones principales', H2))
    for d in [
        'El rol administrativo (<b>admin</b>) pasa a ser dueño del esquema (script 00_propietario.sql), porque en '
        'PostgreSQL solo el dueño de una tabla puede alterarla; así la extensión del Bloque B y la auditoría del '
        'Bloque F las ejecuta admin, como pide el enunciado. Las consultas se ejecutan con el rol de solo lectura <b>visor</b>.',
        'Cada objetivo es una función <i>fn_objetivo_XX(desde, hasta)</i>: el lapso de tiempo es un parámetro y '
        'visor puede ejecutarla sin permisos de escritura.',
        'La extensión es una migración no destructiva: no se borra ninguna columna ni tabla del Proyecto 1.',
        'Se agregaron dos hospitales y datos de enero a octubre de 2026 generados de forma reproducible '
        '(siempre producen los mismos valores), con 15 o más registros en cada tabla relevante.',
        'Para los objetivos con criterios ambiguos se fijó una métrica explícita, descrita junto a cada objetivo.']:
        S.append(p('• ' + d, CUERPO))


def modelo(S):
    S.append(NextPageTemplate('horizontal'))
    S.append(PageBreak())
    S.append(p('2. Modelo de datos extendido (notación Barker)', H1))
    S.append(p('Archivo editable: modelo/modelo_barker_p2.drawio (draw.io). El recuadro <b>PERSONAL</b> es el '
               'supertipo y contiene a sus subtipos <b>MEDICO</b> y <b>ENFERMERO</b>; la línea naranja «superior '
               'directo» es la relación recursiva de MEDICO; [P2] marca los atributos agregados en este proyecto.', CUERPO))
    S.append(imagen(IMG_MODELO, ANCHO_H, landscape(letter)[1] - 5 * cm))
    # el modelo completo queda pequeño en una hoja: se agrega ampliado por cuadrantes
    from PIL import Image as PILImage
    import tempfile
    completo = PILImage.open(IMG_MODELO)
    w, h = completo.size
    carpeta = tempfile.mkdtemp(prefix='modelo_p2_')
    nombres = ['superior izquierdo', 'superior derecho', 'inferior izquierdo', 'inferior derecho']
    for i, (x0, y0) in enumerate([(0, 0), (w // 2, 0), (0, h // 2), (w // 2, h // 2)]):
        ruta = os.path.join(carpeta, 'cuadrante_%d.png' % i)
        completo.crop((max(0, x0 - 60), max(0, y0 - 60), min(w, x0 + w // 2 + 60), min(h, y0 + h // 2 + 60))).save(ruta)
        S.append(PageBreak())
        S.append(p('Modelo extendido — cuadrante %s' % nombres[i], H3))
        S.append(imagen(ruta, ANCHO_H, landscape(letter)[1] - 4 * cm))
    S.append(NextPageTemplate('vertical'))
    S.append(PageBreak())
    S.append(p('2.1 Estrategia de mapeo del supertipo y relación recursiva', H2))
    for d in [
        '<b>Tabla por supertipo y por subtipo (class table inheritance).</b> PERSONAL guarda los datos que comparte '
        'todo el personal (nombres, DPI, teléfono, dirección, municipio, área, hospital, fecha de contratación, '
        'salario y nivel de acceso) y el discriminador <i>tipo_personal</i>, restringido con CHECK a medico o enfermero.',
        '<b>Llave compartida.</b> id_medico e id_enfermero son el mismo valor que id_personal. Cada subtipo referencia '
        'a PERSONAL con una FK compuesta (id, tipo_personal) contra el UNIQUE (id_personal, tipo_personal): así un '
        'médico solo puede apuntar a personal de tipo médico. La jerarquía es <b>exclusiva</b> (una persona es de un '
        'solo subtipo) y <b>completa</b> (un disparador diferido exige que toda persona tenga su subtipo al confirmar).',
        '<b>Por qué esta estrategia.</b> Una sola tabla con todas las columnas dejaría muchas nulas (los enfermeros no '
        'tienen especialidad ni horario de consulta); una tabla por subtipo sin supertipo repetiría los datos comunes '
        'y no permitiría auditar o consultar al personal como un todo. Con supertipo y subtipos cada dato vive una vez '
        'y las FK del Proyecto 1 hacia medico y enfermero siguen funcionando sin cambios.',
        '<b>Migración no destructiva.</b> Como el enunciado no permite modificar de forma destructiva las tablas '
        'existentes, medico y enfermero conservan sus columnas del Proyecto 1. PERSONAL es la fuente de esos datos y '
        'un disparador los copia al subtipo en cada inserción o actualización, de modo que nunca pueden diferir.',
        '<b>Relación recursiva.</b> medico.id_medico_superior referencia a medico (ON DELETE SET NULL). El cargo '
        '(director_medico, jefe_servicio, medico) se valida con CHECK; un índice único parcial permite un solo director '
        'por hospital y un disparador impide ciclos y superiores de otro hospital.']:
        S.append(p('• ' + d, CUERPO))


def fila_diccionario(cat, tabla_, c, anexo=False):
    fk = cat['fk'].get((tabla_, c['col']))
    llave = []
    if c['pk']:
        llave.append('PK')
    if fk:
        llave.append('FK')
    if (tabla_, c['col']) in cat['uk'] and not c['pk']:
        llave.append('UK')
    fila = [p('<b>%s</b>' % c['col'] if c['pk'] else c['col']), p(escape(c['tipo'])), p('/'.join(llave) or '—'),
            p('No' if c['nn'] else 'Sí')]
    if not anexo:
        fila.append(p(escape(re.sub(r'::[a-z ]+', '', c['defecto'])[:40])))
    desc = c['desc'] or ('Referencia a %s.' % fk[0] if fk else '')
    fila.append(p(escape(desc)))
    if fk:
        fila += [p(fk[1]), p(fk[2]), p(escape(JUSTIFICACION.get((tabla_, c['col']), '')))]
    else:
        fila += [p(''), p(''), p('')]
    return fila


def diccionario_detallado(S, cat, checks_txt, funciones_txt):
    S.append(NextPageTemplate('horizontal'))
    S.append(PageBreak())
    S.append(p('3. Diccionario de datos de las tablas nuevas y modificadas', H1))
    S.append(p('Una tabla por entidad nueva (PERSONAL, AUDITORIA_PERSONAL) o modificada por el Bloque B (MEDICO, '
               'ENFERMERO). En las filas de llave foránea se indica la acción referencial ante DELETE y UPDATE y su '
               'justificación de negocio. Debajo se detallan sus restricciones CHECK, disparadores e índices.', CUERPO))
    cab = ['Atributo', 'Tipo de dato', 'Llave', 'Nulos', 'Por defecto', 'Descripción', 'DELETE', 'UPDATE', 'Justificación']
    anchos = [3.4 * cm, 2.5 * cm, 1.3 * cm, 1.0 * cm, 2.3 * cm, 6.6 * cm, 1.75 * cm, 1.75 * cm, ANCHO_H - 20.6 * cm]
    for t in NUEVAS + MODIFICADAS:
        S.append(CondPageBreak(6 * cm))
        estado = 'nueva' if t in NUEVAS else 'modificada'
        S.append(p('Tabla %s (%s)' % (t, estado), H2))
        S.append(p(escape(cat['tablas'][t]), CUERPO))
        filas = [[p('<b>%s</b>' % c, CELDA_B) for c in cab]]
        resaltar = []
        for i, c in enumerate(cat['cols'][t], 1):
            filas.append(fila_diccionario(cat, t, c))
            if t in MODIFICADAS and c['col'] in ('tipo_personal', 'cargo', 'id_medico_superior'):
                resaltar.append(('BACKGROUND', (0, i), (-1, i), colors.HexColor('#E0F2F1')))
        S.append(tabla(filas, anchos, extra=resaltar))
        if t in MODIFICADAS:
            S.append(p('<font color="#00695C">Las filas resaltadas son las columnas agregadas en el Proyecto 2.</font>', CELDA))
        if cat['uk_compuestos'].get(t):
            S.append(p('Restricciones UNIQUE compuestas', H3))
            S.append(tabla([[p('<b>Restricción</b>'), p('<b>Columnas</b>'), p('<b>Para qué sirve</b>')]] +
                           [[p(n), p(cs), p(escape(checks_txt.get(n, '')))] for n, cs in cat['uk_compuestos'][t]],
                           [5 * cm, 6 * cm, ANCHO_H - 11 * cm]))
        if cat['checks'].get(t):
            S.append(p('Restricciones CHECK', H3))
            S.append(tabla([[p('<b>Restricción</b>'), p('<b>Expresión</b>'), p('<b>Qué valida</b>')]] +
                           [[p(n), p('<font face="Courier">%s</font>' % escape(re.sub(r'::(character varying|text|numeric|date|integer)(\[\])?', '', d))),
                             p(escape(checks_txt.get(n, '')))]
                            for n, d in cat['checks'][t]],
                           [5 * cm, 12 * cm, ANCHO_H - 17 * cm]))
        if cat['triggers'].get(t):
            S.append(p('Disparadores', H3))
            S.append(tabla([[p('<b>Disparador</b>'), p('<b>Cuándo se ejecuta</b>'), p('<b>Función</b>'), p('<b>Propósito</b>')]] +
                           [[p(n), p(escape(m)), p(f), p(escape(funciones_txt.get(f, '')))] for n, m, f in cat['triggers'][t]],
                           [5 * cm, 6 * cm, 5 * cm, ANCHO_H - 16 * cm]))
        if cat['indices'].get(t):
            S.append(p('Índices', H3))
            S.append(tabla([[p('<b>Índice</b>'), p('<b>Columnas</b>')]] +
                           [[p(n), p('<font face="Courier">%s</font>' % escape(d))] for n, d in cat['indices'][t]],
                           [8 * cm, ANCHO_H - 8 * cm]))
    S.append(NextPageTemplate('vertical'))


def encabezado_sql(ruta):
    """Comentario inicial del archivo de una consulta (descripcion y metrica)."""
    lineas = []
    for l in open(ruta, encoding='utf-8'):
        if not l.startswith('--'):
            break
        lineas.append(l[2:].strip())
    titulo = lineas[0] if lineas else ''
    cuerpo = ' '.join(x for x in lineas[1:] if x)
    return titulo, cuerpo


def codigo_funcion(ruta):
    texto = open(ruta, encoding='utf-8').read()
    ini = texto.find('create or replace function')
    fin = texto.rfind('$$;') + 3
    return texto[ini:fin] if ini >= 0 else texto


OBJETIVOS_TITULO = {
    1: 'Hospitales con mayor demanda en consulta externa', 2: 'Médicos con menor calificación',
    3: 'Mejores médicos de emergencias', 4: 'Hospitales más eficientes en emergencias', 5: 'Cirujanos más eficientes',
    6: 'Tipos de cirugía con mayores ingresos', 7: 'Hospitales con mayores ingresos en hospitalización',
    8: 'Pagos por método de pago', 9: 'Hospitales con mayor ingreso por visita', 10: 'Fecha con más decesos',
    11: 'Ingresos totales por hospital', 12: 'Edad y sexo en emergencias por turno', 13: 'Reporte de citas',
    14: 'Promedio de cuotas por unidad', 15: 'Extensión del modelo', 16: 'Cadena de supervisión',
    17: 'Ranking por hospital y global', 18: 'Pacientes del programa de fidelidad',
    19: 'Revisión del reporte de cirugías', 20: 'Trazabilidad de cambios sensibles'}
BLOQUE = {1: 'A', 15: 'B', 16: 'C', 18: 'D', 19: 'E', 20: 'F'}
NOMBRE_BLOQUE = {'A': 'Consultas de inteligencia de negocio', 'B': 'Extensión del modelo',
                 'C': 'Reportes sobre el personal médico', 'D': 'Programa de fidelidad',
                 'E': 'Revisión del reporte de cirugías', 'F': 'Trazabilidad de cambios sensibles'}


def objetivos(S):
    S.append(PageBreak())
    S.append(p('4. Objetivos', H1))
    S.append(p('Para cada objetivo se muestra el criterio usado, la sentencia (archivo sql/consultas/objetivo_XX.sql) '
               'y la captura de su resultado, ejecutado con el rol de solo lectura visor sobre enero a octubre de 2026.', CUERPO))
    for n in range(1, 21):
        if n in BLOQUE:
            b = BLOQUE[n]
            S.append(CondPageBreak(10 * cm))
            S.append(p('Bloque %s — %s' % (b, NOMBRE_BLOQUE[b]), H2))
        S.append(CondPageBreak(8 * cm))
        S.append(p('Objetivo %d. %s' % (n, OBJETIVOS_TITULO[n]), H3))
        ruta = os.path.join(P2, 'sql', 'consultas', 'objetivo_%02d.sql' % n)
        if os.path.exists(ruta):
            _, cuerpo = encabezado_sql(ruta)
            S.append(p(escape(cuerpo), CUERPO))
            if n == 19:
                texto = open(ruta, encoding='utf-8').read()
                ini, fin = texto.find('-- propuesta normalizada'), texto.find('-- migracion de los datos')
                S.append(p('Sentencias CREATE TABLE de la propuesta en 3FN (esquema propuesta_bloque_e):', CUERPO))
                S.append(codigo(texto[ini:fin]))
            else:
                S.append(codigo(codigo_funcion(ruta)))
        elif n == 15:
            S.append(p('La extensión se entrega como migración en sql/ddl/01_personal.sql (supertipo PERSONAL y '
                       'subtipos) y sql/ddl/02_jerarquia.sql (cadena de mando); el modelo y la estrategia están en la '
                       'sección 2 y el diccionario en la sección 3. La captura muestra que cada persona tiene su '
                       'subtipo y la cadena de mando del hospital 1.', CUERPO))
        elif n == 20:
            S.append(p('Mecanismo en sql/auditoria/01_auditoria.sql: disparadores AFTER UPDATE sobre personal '
                       '(salario, nivel_acceso) y medico (id_especialidad) registran una fila por campo modificado con '
                       'el rol de base de datos, el usuario de sesión, el usuario de la aplicación (app.usuario), el '
                       'valor anterior, el valor nuevo y clock_timestamp(). La bitácora pertenece a un rol sin login: '
                       'admin y visor solo pueden leerla y la función que escribe en ella solo acepta llamadas desde un '
                       'disparador. La demostración (sql/auditoria/02_prueba.sql) hace 3 cambios: un aumento de '
                       'salario, un cambio de especialidad y un cambio de salario y nivel de acceso en la misma '
                       'sentencia; además, un UPDATE que deja el mismo valor no genera registro y los intentos de '
                       'borrar o falsificar la bitácora fallan con «permission denied». Limitación: como admin es '
                       'dueño de personal y medico, podría desactivar los disparadores; evitarlo requeriría quitarle la '
                       'propiedad que necesita para el Bloque B.', CUERPO))
        captura = os.path.join(CAPTURAS, 'objetivo_%02d.png' % n)
        S.append(Spacer(1, 4))
        S.append(imagen(captura, ANCHO_V, 19 * cm))
        if n == 17:
            md = open(os.path.join(BASE, 'rendimiento_objetivo_17.md'), encoding='utf-8').read()
            filas = [l.strip('|').split('|') for l in md.splitlines() if l.startswith('| ') and '---' not in l]
            S.append(p('Comparación de rendimiento (sql/consultas/rendimiento/medir_objetivo_17.sh)', H3))
            S.append(tabla([[p('<b>%s</b>' % c.strip()) for c in filas[0]]] + [[p(c.strip()) for c in f] for f in filas[1:]],
                           [3.5 * cm, 3.2 * cm, 3.6 * cm, 4.2 * cm, ANCHO_V - 14.5 * cm]))
            concl = md.split('## Conclusión')[1].split('##')[0].strip().replace('\n', ' ')
            S.append(p(escape(concl).replace('`', ''), CUERPO))


def orm(S):
    S.append(PageBreak())
    S.append(p('5. ORM: objetivos 8, 11 y 18 con JPA', H1))
    S.append(p('Se implementaron con Java 21, JPA (Hibernate 6.6) y el driver JDBC de PostgreSQL, en el proyecto '
               'Maven orm/. Las entidades son de solo lectura (@Immutable) y mapean solo las columnas usadas; '
               'Factura se mapea a la vista v_factura, que ya calcula el hospital y la unidad de cada factura. La '
               'conexión usa el rol visor y la contraseña se lee de la variable de entorno HOSPITAL_DB_PASSWORD. '
               'Todas las consultas JPQL usan parámetros con nombre (:desde, :hasta, :efectivo…): Hibernate los envía '
               'en sentencias preparadas, nunca concatenados al texto, por lo que no hay riesgo de inyección SQL.', CUERPO))
    S.append(p('Igualdad de resultados', H2))
    S.append(p('La clase Comparar ejecuta cada objetivo con JPA y con su función SQL (también con parámetros '
               'enlazados ?1, ?2) y compara fila por fila:', CUERPO))
    S.append(codigo(open(os.path.join(BASE, 'orm_comparacion.txt'), encoding='utf-8').read()))
    S.append(p('Consultas JPQL (ConsultasOrm.java)', H2))
    S.append(codigo(open(os.path.join(P2, 'orm', 'src', 'main', 'java', 'gt', 'cunoc', 'hospital', 'orm',
                                      'ConsultasOrm.java'), encoding='utf-8').read(), 125))
    S.append(p('Sentencia preparada enviada por Hibernate (objetivo 8)', H2))
    S.append(p('Extracto de la salida con hibernate.show_sql: los valores aparecen como «?».', CUERPO))
    salida = open(os.path.join(BASE, 'orm_salida.txt'), encoding='utf-8').read()
    ini = salida.find('Hibernate:')
    S.append(codigo(salida[ini:salida.find('Hibernate:', ini + 10)]))


def anexo_diccionario(S, cat):
    S.append(NextPageTemplate('horizontal'))
    S.append(PageBreak())
    S.append(p('Anexo A. Diccionario de datos completo', H1))
    S.append(p('Todas las tablas del esquema final (Proyecto 1 extendido por el Proyecto 2), en orden alfabético.', CUERPO))
    cab = ['Atributo', 'Tipo de dato', 'Llave', 'Nulos', 'Descripción', 'DELETE', 'UPDATE', 'Justificación']
    anchos = [3.6 * cm, 2.7 * cm, 1.3 * cm, 1.0 * cm, 7.6 * cm, 1.75 * cm, 1.75 * cm, ANCHO_H - 19.7 * cm]
    for t in sorted(cat['tablas']):
        filas = [[p('<b>%s</b>' % c, CELDA_B) for c in cab]] + [fila_diccionario(cat, t, c, anexo=True) for c in cat['cols'][t]]
        bloque = [p('Tabla %s' % t, H3), p(escape(cat['tablas'][t]), CELDA), Spacer(1, 2), tabla(filas, anchos), Spacer(1, 6)]
        S.append(KeepTogether(bloque) if len(filas) < 20 else bloque[0])
        if len(filas) >= 20:
            S.extend(bloque[1:])
    S.append(NextPageTemplate('vertical'))


def anexo_sql(S):
    S.append(PageBreak())
    S.append(p('Anexo B. Sentencias SQL del Proyecto 2', H1))
    S.append(p('Contenido completo de los scripts, en el orden en que se ejecutan: sql/ddl, sql/dml, '
               'sql/auditoria y sql/consultas.', CUERPO))
    for carpeta in ['ddl', 'dml', 'auditoria', 'consultas', os.path.join('consultas', 'rendimiento')]:
        for ruta in sorted(glob.glob(os.path.join(P2, 'sql', carpeta, '*.sql'))):
            S.append(p('sql/%s/%s' % (carpeta, os.path.basename(ruta)), H3))
            S.append(codigo(open(ruta, encoding='utf-8').read()))


def main():
    cat = leer_catalogo()
    checks_txt, funciones_txt = comentarios_sql()
    S = []
    portada(S)
    introduccion(S, cat)
    modelo(S)
    diccionario_detallado(S, cat, checks_txt, funciones_txt)
    objetivos(S)
    orm(S)
    anexo_diccionario(S, cat)
    anexo_sql(S)
    doc = Documento(SALIDA)
    doc.multiBuild(S)
    print('PDF:', SALIDA)


if __name__ == '__main__':
    main()
