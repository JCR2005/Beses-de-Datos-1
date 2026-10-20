#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera el modelo en notacion Barker a partir del esquema de la base de datos.

Salidas (en esta carpeta):
  modelo_barker.dot    -> definicion para Graphviz
  modelo_barker.png    -> imagen del modelo
  modelo_barker.drawio -> archivo editable en draw.io / diagrams.net
  modelo_barker_parteN.png -> la imagen en 3 franjas, para imprimirla legible

Notacion Barker usada:
  # identificador unico, * atributo obligatorio, o atributo opcional.
  Las llaves foraneas no se listan como atributos: se dibujan como relaciones.
  Cada relacion tiene dos mitades: la mitad junto a una entidad es continua si
  esa entidad DEBE participar y punteada si PUEDE participar.
  Pata de gallo en el lado "muchos"; barra en el hijo cuando la relacion forma
  parte de su identificador (entidades asociativas con PK compuesta).

Conexion: variables PGHOST, PGPORT, PGUSER, PGDATABASE y PGPASSWORD (o ~/.pgpass).
"""
import json
import os
import subprocess
from html import escape

BASE = os.path.dirname(os.path.abspath(__file__))
DOT = os.path.join(BASE, 'modelo_barker.dot')
PNG = os.path.join(BASE, 'modelo_barker.png')
DRAWIO = os.path.join(BASE, 'modelo_barker.drawio')

# areas del modelo; cada una se dibuja agrupada y con su color
AREAS = [
    ('Geografía', '#eef3fb', ['departamento', 'municipio']),
    ('Hospital', '#eef8f0', ['hospital', 'unidad_medica', 'servicio_atencion', 'camilla', 'quirofano']),
    ('Personal', '#fdf5e6', ['especialidad', 'medico', 'enfermero', 'turno_emergencia', 'turno_medico']),
    ('Recursos', '#f4f0fa', ['insumo', 'instrumento', 'equipo', 'medicamento', 'diagnostico']),
    ('Pacientes', '#fbeff2', ['estado_civil', 'parentesco', 'paciente', 'encargado', 'paciente_encargado', 'calificacion']),
    ('Consulta externa', '#eef8f8', ['cita', 'consulta', 'receta', 'receta_medicamento']),
    ('Fichas', '#f7f7ea', ['ingreso', 'egreso', 'egreso_diagnostico', 'institucion_externa', 'traslado']),
    ('Cirugía', '#fdf0ea', ['tipo_anestesia', 'tipo_cirugia', 'aspecto_quirurgico', 'rol_quirurgico',
                            'agendamiento_quirurgico', 'requerimiento_insumo', 'requerimiento_instrumento',
                            'requerimiento_equipo', 'historia_clinica', 'consentimiento_informado',
                            'chequeo_preanestesico', 'cirugia', 'cirugia_personal', 'registro_procedimiento',
                            'documentacion_etapa', 'cirugia_insumo']),
    ('Hospitalización y facturación', '#eef3f3', ['hospitalizacion_insumo', 'metodo_pago', 'factura', 'pago']),
]


def psql(sql):
    env = dict(os.environ)
    env.setdefault('PGHOST', 'localhost')
    env.setdefault('PGPORT', '5433')
    env.setdefault('PGUSER', 'hospital')
    env.setdefault('PGDATABASE', 'hospital')
    r = subprocess.run(['psql', '-Atq', '-F', '|', '-c', sql], capture_output=True, text=True, env=env)
    if r.returncode != 0:
        raise SystemExit('psql: ' + r.stderr[:400])
    return [line.split('|') for line in r.stdout.splitlines()]


def leer_esquema():
    columnas = {}
    for t, c, nn, pk, fk in psql("""
        select c.relname, a.attname, a.attnotnull::int,
               exists(select 1 from pg_index i where i.indrelid = c.oid and i.indisprimary
                      and a.attnum = any(i.indkey))::int,
               exists(select 1 from pg_constraint f where f.conrelid = c.oid and f.contype = 'f'
                      and a.attnum = any(f.conkey))::int
          from pg_class c join pg_attribute a on a.attrelid = c.oid
         where c.relnamespace = 'public'::regnamespace and c.relkind = 'r'
           and a.attnum > 0 and not a.attisdropped
         order by c.relname, a.attnum"""):
        columnas.setdefault(t, []).append((c, nn == '1', pk == '1', fk == '1'))

    relaciones = []
    for hijo, padre, col, nn, unico, en_pk in psql("""
        select f.conrelid::regclass::text, f.confrelid::regclass::text, a.attname, a.attnotnull::int,
               exists(select 1 from pg_index i where i.indrelid = f.conrelid and i.indisunique
                      and i.indnatts = 1 and i.indkey[0] = f.conkey[1])::int,
               exists(select 1 from pg_index i where i.indrelid = f.conrelid and i.indisprimary
                      and f.conkey[1] = any(i.indkey) and i.indnatts > 1)::int
          from pg_constraint f
          join pg_attribute a on a.attrelid = f.conrelid and a.attnum = f.conkey[1]
         where f.contype = 'f' and f.connamespace = 'public'::regnamespace
         order by 1, 3"""):
        relaciones.append({'hijo': hijo, 'padre': padre, 'col': col, 'obligatoria': nn == '1',
                           'uno_a_uno': unico == '1', 'en_uid': en_pk == '1'})
    return columnas, relaciones


def atributos(cols):
    """Lineas de atributos en notacion Barker (sin llaves foraneas)."""
    lineas = []
    for nombre, nn, pk, fk in cols:
        if fk:
            continue
        marca = '#*' if pk else ('*' if nn else 'o')
        lineas.append('%s %s' % (marca, nombre))
    return lineas


def generar_dot(columnas, relaciones):
    out = ['digraph modelo {',
           '  graph [rankdir=TB, fontname="Helvetica", splines=true, overlap=false, nodesep=0.35, ranksep=1.1, '
           'label="Hospitales de Occidente - Modelo de datos (notación Barker)", labelloc=t, fontsize=26];',
           '  node [shape=plaintext, fontname="Helvetica"];',
           '  edge [color="#444444", penwidth=1.1];']
    for i, (area, color, tablas) in enumerate(AREAS):
        out.append('  subgraph cluster_%d { label="%s"; style="rounded,filled"; fillcolor="%s"; color="#999999"; '
                   'fontsize=18;' % (i, area, color))
        for t in tablas:
            filas = ''.join('<TR><TD ALIGN="LEFT"><FONT POINT-SIZE="10">%s</FONT></TD></TR>' % escape(a)
                            for a in atributos(columnas[t]))
            out.append('    "%s" [label=<<TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" CELLPADDING="3" '
                       'STYLE="ROUNDED" BGCOLOR="white"><TR><TD><B>%s</B></TD></TR>%s</TABLE>>];'
                       % (t, t.upper(), filas))
        out.append('  }')
    for i, r in enumerate(relaciones):
        m = 'rel%d' % i
        out.append('  "%s" [shape=point, width=0.02, label=""];' % m)
        cola = ('tee' if r['en_uid'] else '') + ('none' if r['uno_a_uno'] else 'crow')
        # mitad del hijo: continua si el hijo debe tener padre (FK not null)
        out.append('  "%s" -> "%s" [dir=back, arrowtail=%s, style=%s];'
                   % (r['hijo'], m, cola, 'solid' if r['obligatoria'] else 'dashed'))
        # mitad del padre: el padre puede existir sin hijos
        out.append('  "%s" -> "%s" [dir=none, style=dashed];' % (m, r['padre']))
    out.append('}')
    with open(DOT, 'w', encoding='utf-8') as f:
        f.write('\n'.join(out) + '\n')


def generar_drawio(columnas, relaciones):
    """Escribe el .drawio con las posiciones calculadas por Graphviz."""
    layout = json.loads(subprocess.run(['dot', '-Tjson', DOT], capture_output=True, text=True, check=True).stdout)
    alto = float(layout['bb'].split(',')[3])
    pt = 96 / 72  # graphviz trabaja en puntos; draw.io en pixeles

    def caja(obj):
        x, y = (float(v) for v in obj['pos'].split(','))
        w, h = float(obj['width']) * 96, float(obj['height']) * 96
        return x * pt - w / 2, (alto - y) * pt - h / 2, w, h

    celdas = []
    ids = {}
    for obj in layout.get('objects', []):
        if 'nodes' in obj and 'bb' in obj:   # cluster: rectangulo de fondo del area
            x0, y0, x1, y1 = (float(v) for v in obj['bb'].split(','))
            color = obj.get('fillcolor', '#ffffff')
            celdas.append('<mxCell id="area%s" value="%s" style="rounded=1;arcSize=3;whiteSpace=wrap;html=1;'
                          'fillColor=%s;strokeColor=#999999;verticalAlign=top;fontSize=18;fontStyle=1;" '
                          'vertex="1" parent="1"><mxGeometry x="%.0f" y="%.0f" width="%.0f" height="%.0f" '
                          'as="geometry"/></mxCell>'
                          % (obj['_gvid'], escape(obj['label']), color, x0 * pt, (alto - y1) * pt,
                             (x1 - x0) * pt, (y1 - y0) * pt))
    for obj in layout.get('objects', []):
        if 'nodes' in obj and 'bb' in obj:
            continue
        nombre = obj['name']
        x, y, w, h = caja(obj)
        ids[nombre] = 'n%s' % obj['_gvid']
        if nombre.startswith('rel'):
            celdas.append('<mxCell id="%s" value="" style="ellipse;fillColor=#444444;strokeColor=none;" vertex="1" '
                          'parent="1"><mxGeometry x="%.0f" y="%.0f" width="2" height="2" as="geometry"/></mxCell>'
                          % (ids[nombre], x + w / 2 - 1, y + h / 2 - 1))
        else:
            texto = '<b>%s</b><hr>%s' % (nombre.upper(), '<br>'.join(escape(a) for a in atributos(columnas[nombre])))
            celdas.append('<mxCell id="%s" value="%s" style="rounded=1;arcSize=8;whiteSpace=wrap;html=1;align=left;'
                          'verticalAlign=top;spacingLeft=6;fillColor=#ffffff;strokeColor=#333333;fontSize=11;" '
                          'vertex="1" parent="1"><mxGeometry x="%.0f" y="%.0f" width="%.0f" height="%.0f" '
                          'as="geometry"/></mxCell>' % (ids[nombre], escape(texto), x, y, w, h))
    for i, r in enumerate(relaciones):
        m = ids['rel%d' % i]
        if r['uno_a_uno']:
            fin = 'ERone' if r['en_uid'] else 'none'
        else:
            fin = 'ERoneToMany' if r['en_uid'] else 'ERmany'
        celdas.append('<mxCell id="e%da" style="endArrow=none;startArrow=%s;startFill=0;dashed=%d;html=1;'
                      'strokeColor=#444444;" edge="1" parent="1" source="%s" target="%s">'
                      '<mxGeometry relative="1" as="geometry"/></mxCell>'
                      % (i, fin, 0 if r['obligatoria'] else 1, ids[r['hijo']], m))
        celdas.append('<mxCell id="e%db" style="endArrow=none;dashed=1;html=1;strokeColor=#444444;" edge="1" '
                      'parent="1" source="%s" target="%s"><mxGeometry relative="1" as="geometry"/></mxCell>'
                      % (i, m, ids[r['padre']]))
    xml = ('<mxfile host="app.diagrams.net"><diagram id="modelo-barker" name="Modelo Barker">'
           '<mxGraphModel grid="1" gridSize="10" page="0"><root><mxCell id="0"/><mxCell id="1" parent="0"/>'
           + ''.join(celdas) + '</root></mxGraphModel></diagram></mxfile>')
    with open(DRAWIO, 'w', encoding='utf-8') as f:
        f.write(xml)


def dividir_png(n):
    """Corta la imagen en n franjas verticales (con traslape) para imprimirlas legibles."""
    from PIL import Image
    imagen = Image.open(PNG)
    ancho, alto = imagen.size
    traslape = ancho // 40
    for i in range(n):
        x0 = max(0, i * ancho // n - traslape)
        x1 = min(ancho, (i + 1) * ancho // n + traslape)
        imagen.crop((x0, 0, x1, alto)).save(os.path.join(BASE, 'modelo_barker_parte%d.png' % (i + 1)))


def main():
    columnas, relaciones = leer_esquema()
    faltan = set(columnas) - {t for _, _, ts in AREAS for t in ts}
    if faltan:
        raise SystemExit('Tablas sin area asignada: %s' % ', '.join(sorted(faltan)))
    generar_dot(columnas, relaciones)
    subprocess.run(['dot', '-Tpng', '-Gdpi=110', DOT, '-o', PNG], check=True)
    generar_drawio(columnas, relaciones)
    dividir_png(3)
    print('%d entidades, %d relaciones' % (len(columnas), len(relaciones)))
    print('Generados: %s, %s, %s y 3 partes del PNG' % (DOT, PNG, DRAWIO))


if __name__ == '__main__':
    main()
