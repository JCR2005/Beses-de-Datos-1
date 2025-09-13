#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Diccionario de Datos - Hospitales de Occidente."""
import os, subprocess, sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import cm
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table,
                                TableStyle, Image as RLImage, PageBreak, KeepTogether)
from reportlab.lib.utils import ImageReader

BASE = os.path.dirname(os.path.abspath(__file__))
PROY = os.path.abspath(os.path.join(BASE, '..'))
OUT  = os.path.join(BASE, 'Diccionario_Datos_Hospital.pdf')
IMG  = os.path.join(PROY, 'modelo', 'modelo_barker.png')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
try:
    from justificaciones import DELETE_UPDATE_JUST
except:
    DELETE_UPDATE_JUST = {}

def psql(sql):
    r = subprocess.run(['psql', '-h', 'localhost', '-p', '5433', '-U', 'hospital',
                        '-d', 'hospital', '-Atq', '-F', '|', '-c', sql],
                       capture_output=True, text=True, env=dict(os.environ, PGPASSWORD='bd_hospital'))
    if r.returncode != 0:
        raise SystemExit('psql: ' + r.stderr[:400])
    return r.stdout

QCOLS = """
SELECT c.relname, a.attname,
       format_type(a.atttypid, a.atttypmod),
       a.attnotnull::int,
       (EXISTS(SELECT 1 FROM pg_index i WHERE i.indrelid=c.oid AND i.indisprimary
                AND a.attnum=ANY(i.indkey)))::int,
       coalesce(pg_catalog.col_description(c.oid, a.attnum),''),
       coalesce(pg_catalog.obj_description(c.oid,'pg_class'),'')
  FROM pg_attribute a
  JOIN pg_class c ON c.oid=a.attrelid
  JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='public' AND c.relkind IN ('r','p')
   AND a.attnum>0 AND NOT a.attisdropped
 ORDER BY c.relname, a.attnum;
"""
QFK = """
SELECT tc.table_name, kcu.column_name, ccu.table_name AS foranea_col,
       tc.constraint_name,
       rc.delete_rule, rc.update_rule,
       pg_catalog.obj_description(c.oid,'pg_constraint')
  FROM information_schema.table_constraints tc
  JOIN information_schema.key_column_usage kcu
       ON tc.constraint_name=kcu.constraint_name AND tc.table_name=kcu.table_name
  JOIN information_schema.constraint_column_usage ccu
       ON ccu.constraint_name=tc.constraint_name
  JOIN information_schema.referential_constraints rc
       ON rc.constraint_name=tc.constraint_name
  JOIN pg_constraint c ON c.conname=tc.constraint_name
 WHERE tc.constraint_type='FOREIGN KEY' AND tc.table_schema='public'
 ORDER BY tc.table_name, kcu.ordinal_position;
"""
QCHK = """
SELECT conrelid::regclass::text, conname, pg_get_constraintdef(oid),
       pg_catalog.obj_description(oid,'pg_constraint')
  FROM pg_constraint
 WHERE contype='c' AND connamespace='public'::regnamespace
 ORDER BY 1,2;
"""

try:
    coldata = psql(QCOLS)
    fkdata  = psql(QFK)
    chkdata = psql(QCHK)
except Exception:
    coldata = fkdata = chkdata = ''

cols = {}
for line in coldata.splitlines():
    p = line.split('|')
    if len(p) >= 7:
        cols.setdefault(p[0], []).append((p[1], p[2], int(p[3]), int(p[4]), p[5], p[6]))

fks = {}
for line in fkdata.splitlines():
    p = line.split('|')
    if len(p) >= 7:
        just = DELETE_UPDATE_JUST.get(p[3], '') or (p[6] or '')
        fks.setdefault(p[0], []).append({'col': p[1], 'foranea': p[2], 'del': p[4],
                                         'upd': p[5], 'just': just})

chks = {}
for line in chkdata.splitlines():
    p = line.split('|')
    if len(p) >= 3:
        chks.setdefault(p[0], []).append((p[1], p[2], p[3] if len(p)>3 else ''))
sw = getSampleStyleSheet()
st_h1  = ParagraphStyle('h1', parent=sw['Heading1'], fontSize=14, spaceAfter=6)
st_h2  = ParagraphStyle('h2', parent=sw['Heading2'], fontSize=11, spaceAfter=4)
st_body= ParagraphStyle('body', parent=sw['BodyText'], fontSize=9, leading=12.4, alignment=TA_JUSTIFY)
st_cen = ParagraphStyle('cen', parent=st_body, alignment=TA_CENTER)
st_cel = ParagraphStyle('cel', parent=st_body, fontSize=7.4, leading=9.2)
st_title = ParagraphStyle('t', parent=st_body, fontSize=20, leading=24, alignment=TA_CENTER)

SW = letter[0] - 3.0*cm

def portada(S):
    S.append(Spacer(1, 10))
    S.append(Paragraph('UNIVERSIDAD DE SAN CARLOS DE GUATEMALA', st_title))
    S.append(Spacer(1, 14))
    S.append(Paragraph('Centro Universitario de Occidente', st_cen))
    S.append(Paragraph('División de Ciencias de la Ingeniería', st_cen))
    S.append(Paragraph('Sistemas de Bases de Datos 1', st_cen))
    S.append(Spacer(1, 36))
    S.append(Paragraph('PROYECTO 1', ParagraphStyle('p1', parent=st_title, fontSize=18)))
    S.append(Spacer(1, 8))
    S.append(Paragraph('SISTEMA DE INFORMACIÓN PARA HOSPITALES DE OCCIDENTE', ParagraphStyle('p2', parent=st_cen, fontSize=12)))
    S.append(Spacer(1, 18))
    S.append(Paragraph('Modelado (notación Barker), diccionario de datos y bases de datos relacionales', st_cen))
    S.append(Spacer(1, 80))
    tab = Table([[Paragraph('Estudiante', st_cen), Paragraph('Juan Carlos Rodríguez López', st_cen)],
                 [Paragraph('Carné', st_cen), Paragraph('202231970', st_cen)],
                 [Paragraph('Fecha', st_cen), Paragraph('27 de septiembre de 2026', st_cen)]],
                colWidths=[4*cm, 6*cm], hAlign='CENTER')
    tab.setStyle(TableStyle([('GRID',(0,0),(-1,-1),0.3,colors.black), ('VALIGN',(0,0),(-1,-1),'MIDDLE'),
                             ('TOPPADDING',(0,0),(-1,-1),4),('BOTTOMPADDING',(0,0),(-1,-1),4)]))
    S.append(tab)
    S.append(PageBreak())
def objetivos(S):
    S.append(Paragraph('1. Objetivos', st_h1))
    S.append(Paragraph('Objetivo general', st_h2))
    S.append(Paragraph('Aplicar los conceptos de bases de datos relacionales adquiridos en el curso: '
                       'análisis de requerimientos, diseño conceptual y lógico, implementación física '
                       '(DDL), carga de datos (DML), administración de privilegios (DCL) y respaldo '
                       'de la información, para construir el sistema de datos de la cadena '
                       'Hospitales de Occidente.', st_body))
    S.append(Paragraph('Objetivos específicos', st_h2))
    for o in ['Elaborar el modelo entidad-relación de la cadena hospitalaria en notación Barker (34 entidades).',
              'Transformar el modelo a un esquema relacional físico en PostgreSQL 18 con restricciones de dominio mediante CHECK.',
              'Definir llaves primarias y foráneas con acciones referenciales justificadas para preservar la integridad.',
              'Cargar datos ficticios coherentes (catálogos, pacientes, citas, consultas, cirugías, facturación).',
              'Aplicar DCL para crear roles de solo lectura (auditoría) y administrativo.',
              'Generar el respaldo de la base y documentar la entrega en PDF y README.']:
        S.append(Paragraph('• ' + o, st_body))

def modelo(S):
    S.append(PageBreak())
    S.append(Paragraph('2. Modelo entidad-relación (notación Barker)', st_h1))
    S.append(Paragraph('El modelo conceptual se elaboró en notación Barker (patas de gallo), '
                       'documentado en el archivo editable modelo/modelo_barker.drawio y su imagen '
                       'de exportación modelo_barker.png.', st_body))
    if os.path.exists(IMG):
        try:
            ir = ImageReader(IMG)
            w, h = ir.getSize()
            ratio = h / w
            w = min(17.0*cm, SW)
            h = w * ratio
            if h > 16*cm:
                h = 16*cm; w = h / ratio
            S.append(RLImage(IMG, width=w, height=h, hAlign='CENTER'))
        except Exception:
            S.append(Paragraph('No fue posible incluir la imagen del modelo.', st_body))
    else:
        S.append(Paragraph('Imagen del modelo no disponible: ' + IMG, st_body))

def diccionario(S):
    S.append(PageBreak())
    S.append(Paragraph('3. Diccionario de datos', st_h1))
    S.append(Paragraph('Diccionario de datos del esquema de la base de datos. Cada fila '
                       'refleja los atributos, tipos, llaves, nulidad y justificaciones '
                       'correspondientes al esquema aplicado. PK = llave primaria, FK = llave '
                       'foránea (con su acción referencial y justificación de negocio).', st_body))
    S.append(Spacer(1, 6))
    for tname in sorted(cols):
        header = Paragraph('Tabla: %s' % tname, st_h2)
        rows = [[Paragraph('<b>Atributo</b>', st_cel), Paragraph('<b>Tipo</b>', st_cel),
                 Paragraph('<b>Llave</b>', st_cel), Paragraph('<b>Nulo</b>', st_cel),
                 Paragraph('<b>Descripción / justificación</b>', st_cel)]]
        for (col, tipo, notnull, pk, desc, tdesc) in cols[tname]:
            llave = 'PK' if pk else ''
            desc = desc or ''
            for f in fks.get(tname, []):
                if f['col'] == col:
                    llave = 'FK'
                    desc = ('FK → %s DEL=%s UPD=%s<br/>' % (f['foranea'], f['del'], f['upd'])) + (f.get('just') or '')
            rows.append([Paragraph('<b>%s</b>' % col, st_cel), Paragraph(tipo, st_cel),
                         Paragraph(llave, st_cel), Paragraph('NO' if notnull else 'SÍ', st_cel),
                         Paragraph(desc, st_cel)])
        for (cname, cdef, cjust) in chks.get(tname, []):
            rows.append([Paragraph(cname, st_cel), Paragraph('CHECK', st_cel), Paragraph('', st_cel),
                         Paragraph('', st_cel),
                         Paragraph('<i>%s</i>%s' % (cdef, (' — ' + cjust) if cjust else ''), st_cel)])
        t = Table(rows, colWidths=[3.4*cm, 3.2*cm, 1.1*cm, 1.1*cm, SW-8.8*cm], repeatRows=1)
        t.setStyle(TableStyle([('GRID',(0,0),(-1,-1),0.3,colors.black), ('VALIGN',(0,0),(-1,-1),'TOP'),
                               ('TOPPADDING',(0,0),(-1,-1),2),('BOTTOMPADDING',(0,0),(-1,-1),2),
                               ('LEFTPADDING',(0,0),(-1,-1),3),('RIGHTPADDING',(0,0),(-1,-1),3)]))
        S.append(KeepTogether([header, t]))
        S.append(Spacer(1, 7))
def sentencias(S):
    S.append(PageBreak())
    S.append(Paragraph('4. Sentencias y administración', st_h1))
    S.append(Paragraph('DDL', st_h2))
    S.append(Paragraph('sql/ddl/: 7 módulos con CREATE/DROP (+ extensión y secuencias) que '
                       'definen 35 tablas, llaves primarias, 66 llaves foráneas con acciones '
                       'referenciales y 32 restricciones CHECK de dominio.', st_body))
    S.append(Paragraph('DML', st_h2))
    S.append(Paragraph('sql/dml/: datos ficticios de catálogos y operación: pacientes, personal '
                       'médico, citas, consultas, ingresos/egresos/traslados, agendamientos de '
                       'cirugía, quiófanos, camillas, insumos, facturas y pagos en cuotas.', st_body))
    S.append(Paragraph('DCL', st_h2))
    S.append(Paragraph('sql/dcl/: roles admin (lectura/escritura) y visor (solo lectura).', st_body))
    S.append(Paragraph('Respaldo', st_h2))
    S.append(Paragraph('backup/hospital_ok.bk — pg_dump en formato custom; backup/roles_ok.sql — roles usuarios.', st_body))

def build():
    S = []
    portada(S)
    objetivos(S)
    modelo(S)
    diccionario(S)
    sentencias(S)
    doc = SimpleDocTemplate(OUT, pagesize=letter, leftMargin=1.5*cm, rightMargin=1.5*cm,
                            topMargin=1.5*cm, bottomMargin=1.5*cm,
                            title='Diccionario de Datos - Proyecto 1 Hospital')
    doc.build(S)
    return OUT

if __name__ == '__main__':
    print('PDF: ' + build())
