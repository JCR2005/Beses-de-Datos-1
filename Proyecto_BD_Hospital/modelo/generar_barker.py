#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera modelo_barker.drawio en notacion Barker a partir del esquema real de la BD.

Notacion Barker (James Barker):
  - Entidad  = rectangulo con cabecera + lista de atributos
  - Identificador (PK) = subrayado
  - Atributo opcional = nombre en gris discontinuo
  - Cardinalidad = patas de gallo (0..1, 1..*, etc.)
  - M:N = lineas doble hacia la entidad asociativa
"""
import subprocess, os, html, re

BASE = os.path.dirname(os.path.abspath(__file__))
PROY = os.path.abspath(os.path.join(BASE, '..'))
OUT = os.path.join(BASE, 'modelo_barker.drawio')

Q = """
SELECT c.relname, a.attname, a.attnotnull::int,
       (EXISTS(SELECT 1 FROM pg_index i WHERE i.indrelid=c.oid AND i.indisprimary
                 AND a.attnum=ANY(i.indkey)))::int,
       (EXISTS(SELECT 1 FROM pg_constraint k WHERE k.conrelid=c.oid
                 AND k.contype='f' AND a.attnum=ANY(k.conkey)))::int
  FROM pg_attribute a
  JOIN pg_class c ON c.oid=a.attrelid
  JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='public' AND c.relkind='r' AND a.attnum>0 AND NOT a.attisdropped
 ORDER BY c.relname, a.attnum;
"""

def psql(sql):
    r = subprocess.run(['psql', '-h', 'localhost', '-p', '5433', '-U', 'hospital',
                        '-d', 'hospital', '-tAF', '|', '-c', sql],
                       capture_output=True, text=True,
                       env=dict(os.environ, PGPASSWORD='bd_hospital'))
    if r.returncode != 0:
        raise SystemExit('psql: ' + r.stderr[:300])
    return r.stdout

# --- leer esquema: tabla -> [(attr, notnull, pk, fk)] ---
ents = {}
order = []
for line in psql(Q).splitlines():
    p = line.split('|')
    if len(p) == 5:
        t = p[0]
        if t not in ents:
            ents[t] = []
            order.append(t)
        ents[t].append((p[1], int(p[2]), int(p[3]), int(p[4])))

# --- relaciones FK: hijo -> (padre, columna) ---
QFK = """
SELECT child.relname, parent.relname
  FROM pg_constraint k
  JOIN pg_class child  ON child.oid = k.conrelid
  JOIN pg_class parent ON parent.oid = k.confrelid
  JOIN pg_namespace n  ON n.oid = child.relnamespace
 WHERE k.contype='f' AND n.nspname='public';
"""
fks = []
for line in psql(QFK).splitlines():
    p = line.split('|')
    if len(p) == 2:
        fks.append((p[0], p[1]))

# entidades asociativas: tablas con >=2 FK y que son "puente" (curva alta -> M:N)
# Heuristica por nombre + estructura: tablas cuyo nombre sigue patron puente o tienen 2+ FK a padres distintos
puente_pat = re.compile(r'^(paciente_encargado|receta_medicamento|cirugia_insumo|cirugia_personal|'
                        r'cirugia_quirofano|paciente_insumo|pago|.*_personal|ingreso_insumo|'
                        r'procedimiento_personal|equipo_insumo|instrumento_insumo)$')
asociativas = set(t for t in ents if puente_pat.match(t))

# --- layout en rejilla ---
COLS = 5
CW, CH = 250, 150
GAPX, GAPY = 40, 60
pos = {}
for i, t in enumerate(order):
    r, c = divmod(i, COLS)
    pos[t] = (40 + c * (CW + GAPX), 60 + r * (CH + GAPY))

STYLE_ENT = ('rounded=0;whiteSpace=wrap;html=1;verticalAlign=top;align=left;'
             'fillColor=#ffffff;strokeColor=#000000;strokeWidth=2;spacing=4;spacingTop=2;'
             'fontSize=10;')
STYLE_ASOC = ('rounded=0;whiteSpace=wrap;html=1;verticalAlign=top;align=left;'
              'fillColor=#f5f5f5;strokeColor=#000000;strokeWidth=2;dashed=1;spacing=4;'
              'fontSize=10;')

def attr_html(a, notnull, pk, fk):
    style = ''
    name = a
    if pk:
        name = '<u>%s</u>' % html.escape(a)
    else:
        name = html.escape(a)
    if fk:
        name += ' <i>FK</i>'
    # opcional = notnull==0 -> gris (usa <font> con comillas simples: seguro en XML)
    if notnull == 0:
        return ("<font color='#777777'>%s</font>" % name).replace(' ', '&nbsp;')
    return name

def attr_label(a, notnull, pk, fk):
    """Texto plano del atributo con marcadores Barker inequivocos (sin HTML embebido):
       PK -> envolver en parentesis angulares, FK -> asterisco, opcional -> parentesis redondos."""
    name = a
    if pk:
        name = '«%s»' % name          # «» = identificador unico (subrayado en la impresion)
    if fk:
        name = name + '*'             # * = llave foranea
    if notnull == 0:
        name = '(%s)' % name           # ( ) = atributo opcional
    return name

def build_entity(t):
    attrs = ents[t]
    is_asoc = t in asociativas
    x, y = pos[t]
    label = t.upper() + '\n' + '\n'.join(attr_label(a, nn, pk, fk) for (a, nn, pk, fk) in attrs)
    ent_id = 'e_' + t
    return (
        f'<mxCell id="{ent_id}" value="{html.escape(label, quote=True)}" '
        f'style="{STYLE_ASOC if is_asoc else STYLE_ENT}" '
        f'vertex="1" parent="1"><mxGeometry x="{x}" y="{y}" width="{CW}" height="{CH}" '
        f'as="geometry"/></mxCell>'
    )

def build_edge(child, parent):
    """Relacion FK: cardinalidad 1:N (un padre -> muchos hijos).
    Pata de gallo (crow's foot) en el lado MANY (hijo), barra en el lado UNO (padre).
    Esto es notacion Barker para la cardinalidad."""
    style = (
        'edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;strokeColor=#000000;strokeWidth=1;'
        # lado UNO (padre): barra simple
        'endArrow=none;endFill=0;'
        # lado MUCHOS (hijo): pata de gallo
        'startArrow=ERone;startFill=0;startSize=12;'
    )
    return (f'<mxCell id="r_{child}_{parent}" style="{style}" '
            f'edge="1" parent="1" source="{child}" target="{parent}">'
            f'<mxGeometry relative="1" as="geometry"/></mxCell>')

# --- construir XML ---
cells = ['<mxCell id="0"/>', '<mxCell id="1" parent="0"/>']

# titulo
cells.append('<mxCell id="titulo" value="MODELO DE DATOS - HOSPITALES DE OCCIDENTE - Notaci&#243;n Barker" '
             'style="text;html=1;fontStyle=1;fontSize=16;align=left;verticalAlign=middle;" '
             'vertex="1" parent="1"><mxGeometry x="40" y="10" width="900" height="30" '
             'as="geometry"/></mxCell>')
cells.append('<mxCell id="leyenda" '
             'value="Leyenda Barker:  &#171;atributo&#187; = identificador unico (PK)   |   '
             'atributo* = llave foranea (FK)   |   (atributo) = opcional   |   '
             'recuadro punteado = entidad asociativa que resuelve la relacion M:N   |   '
             'pata de gallo = lado muchos" '
             'style="text;html=1;fontSize=11;align=left;verticalAlign=middle;" '
             'vertex="1" parent="1"><mxGeometry x="40" y="34" width="1100" height="20" '
             'as="geometry"/></mxCell>')

for t in order:
    cells.append(build_entity(t))

for (child, parent) in fks:
    if child in pos and parent in pos:
        cells.append(build_edge(child, parent))

xml = ("<?xml version='1.0' encoding='utf-8'?>\n"
       '<mxGraphModel dx="1400" dy="900" grid="1" gridSize="10" guides="1" tooltips="1" '
       'connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1600" pageHeight="1200" '
       'background="#ffffff" math="0" shadow="0">\n'
       '<root>' + ''.join(cells) + '</root>\n'
       '</mxGraphModel>')

with open(OUT, 'w', encoding='utf-8') as fh:
    fh.write(xml)
print('drawio generado:', OUT)

# ------------------------------------------------------------
# Segunda salida: PNG del modelo (Graphviz 'dot') para el enunciado
# (se pide archivo nativo .drawio + imagen del resultado).
# Mismo esquema, misma notacion: PK en negrita, FK con flecha,
# opcional en gris, entidad asociativa punteada, cardinalidad
# 1:N con pata de gallo (arrowhead=vee en el lado muchos).
# ------------------------------------------------------------
PNG = os.path.join(BASE, 'modelo_barker.png')

def dot_label(t):
    rows = ['<TR><TD BORDER="0"><FONT POINT-SIZE="13"><B>%s</B></FONT></TD></TR>' %
            html.escape(t.upper())]
    for (a, nn, pk, fk) in ents[t]:
        if pk:
            cell = '<B><U>%s</U></B>' % html.escape(a)
        elif nn == 0:
            cell = '<FONT COLOR="gray">(%s)</FONT>' % html.escape(a)
        else:
            cell = html.escape(a)
        if fk:
            cell += ' *'
        rows.append('<TR><TD BORDER="0" ALIGN="LEFT"><FONT POINT-SIZE="9">%s</FONT></TD></TR>' % cell)
    return ('<<TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" CELLPADDING="2">%s</TABLE>>'
            % ''.join(rows))

L = ['digraph hospital {',
     'rankdir=LR;',
     'graph [fontname="Helvetica", splines=ortho, nodesep=0.3, ranksep=0.9];',
     'node [shape=plaintext];',
     'edge [dir=back, arrowhead=vee, arrowtail=none, arrowsize=0.7, style=solid];']
for t in order:
    style = 'style="rounded,dashed,filled" fillcolor="#f5f5f5"' if t in asociativas else 'style="rounded,filled" fillcolor="white"'
    L.append('  "%s" [label=%s %s];' % (t, dot_label(t), style))
for (child, parent) in fks:
    if child in ents and parent in ents:
        # direccion: many(child) -> one(parent): la flecha va hacia el padre (dir=back)
        L.append('  "%s" -> "%s";' % (child, parent))
L.append('}')
dot_src = os.path.join(BASE, 'modelo_barker.dot')
with open(dot_src, 'w', encoding='utf-8') as fh:
    fh.write('\n'.join(L))
r = subprocess.run(['dot', '-Tpng', '-Gdpi=110', dot_src, '-o', PNG],
                   capture_output=True, text=True)
if r.returncode == 0:
    print('PNG generado:', PNG)
else:
    print('dot fallo:', r.stderr[:300])
print('entidades:', len(order), '| FKs:', len(fks), '| asociativas:', sorted(asociativas))
