#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera el modelo extendido del Proyecto 2 en notacion Barker a partir del esquema.

Extiende el modelo del Proyecto 1 con lo que agrega el Bloque B y el Bloque F:
  * PERSONAL como supertipo, con MEDICO y ENFERMERO dibujados dentro de el
    (asi representa Barker los subtipos). La estrategia de mapeo es una tabla
    por supertipo y una por subtipo que comparten la llave primaria.
  * La relacion recursiva de MEDICO consigo mismo (superior directo).
  * AUDITORIA_PERSONAL, la bitacora de cambios sensibles.
Las entidades nuevas o modificadas se resaltan en naranja.

Salidas (en esta carpeta):
  modelo_barker_p2.dot / .png / .drawio y modelo_barker_p2_parteN.png

Notacion Barker usada:
  # identificador unico, * atributo obligatorio, o atributo opcional.
  Las llaves foraneas se dibujan como relaciones, no como atributos.
  Cada relacion tiene dos mitades: continua si esa entidad DEBE participar,
  punteada si PUEDE participar. Pata de gallo en el lado "muchos"; barra en el
  hijo cuando la relacion forma parte de su identificador.
  Los subtipos solo muestran sus atributos propios; los comunes estan en PERSONAL.

Conexion: variables PGHOST, PGPORT, PGUSER, PGDATABASE y PGPASSWORD (o ~/.pgpass).
"""
import json
import os
import subprocess
from html import escape

BASE = os.path.dirname(os.path.abspath(__file__))
DOT = os.path.join(BASE, 'modelo_barker_p2.dot')
PNG = os.path.join(BASE, 'modelo_barker_p2.png')
DRAWIO = os.path.join(BASE, 'modelo_barker_p2.drawio')

SUPERTIPO = 'personal'
SUBTIPOS = ['medico', 'enfermero']
NUEVAS = {'personal', 'auditoria_personal'}
MODIFICADAS = {'medico', 'enfermero'}
RESALTE = '#E65100'

# areas del modelo; cada una se dibuja agrupada y con su color
AREAS = [
    ('Geografía', '#eef3fb', ['departamento', 'municipio']),
    ('Hospital', '#eef8f0', ['hospital', 'unidad_medica', 'servicio_atencion', 'camilla', 'quirofano']),
    ('Personal', '#fdf5e6', ['especialidad', 'personal', 'turno_emergencia', 'turno_medico', 'auditoria_personal']),
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
        # la FK del subtipo al supertipo no se dibuja como linea: el subtipo va dentro del supertipo
        if hijo in SUBTIPOS and padre == SUPERTIPO:
            continue
        # los datos comunes que el subtipo copia de PERSONAL se representan con la relacion de PERSONAL
        if hijo in SUBTIPOS and col in ('id_hospital', 'id_municipio'):
            continue
        relaciones.append({'hijo': hijo, 'padre': padre, 'col': col, 'obligatoria': nn == '1',
                           'uno_a_uno': unico == '1', 'en_uid': en_pk == '1'})
    return columnas, relaciones


def atributos(tabla, columnas):
    """Lineas de atributos en notacion Barker (sin llaves foraneas ni datos heredados)."""
    comunes = {c for c, _, pk, _ in columnas[SUPERTIPO] if not pk}
    lineas = []
    for nombre, nn, pk, fk in columnas[tabla]:
        if fk or (tabla in SUBTIPOS and nombre in comunes):
            continue
        marca = '#*' if pk else ('*' if nn else 'o')
        lineas.append('%s %s' % (marca, nombre))
    return lineas


def etiqueta_entidad(tabla, columnas):
    """Tabla HTML de Graphviz para una entidad."""
    borde = RESALTE if tabla in NUEVAS | MODIFICADAS else '#333333'
    fondo = '#FFF3E0' if tabla in NUEVAS else 'white'
    filas = ''.join('<TR><TD ALIGN="LEFT"><FONT POINT-SIZE="10">%s</FONT></TD></TR>' % escape(a)
                    for a in atributos(tabla, columnas))
    return ('<<TABLE BORDER="%d" COLOR="%s" CELLBORDER="0" CELLSPACING="0" CELLPADDING="3" STYLE="ROUNDED" '
            'BGCOLOR="%s"><TR><TD><B>%s</B></TD></TR>%s</TABLE>>'
            % (2 if borde == RESALTE else 1, borde, fondo, tabla.upper(), filas))


def generar_dot(columnas, relaciones):
    out = ['digraph modelo {',
           '  graph [rankdir=TB, compound=true, fontname="Helvetica", splines=true, overlap=false, nodesep=0.35, '
           'ranksep=1.1, label="Hospitales de Occidente - Modelo extendido del Proyecto 2 (notación Barker)", '
           'labelloc=t, fontsize=26];',
           '  node [shape=plaintext, fontname="Helvetica"];',
           '  edge [color="#444444", penwidth=1.1];',
           '  "leyenda" [label=<<TABLE BORDER="1" CELLBORDER="0" CELLPADDING="4" BGCOLOR="white">'
           '<TR><TD ALIGN="LEFT"><B>Leyenda</B></TD></TR>'
           '<TR><TD ALIGN="LEFT"><FONT COLOR="%s"><B>Borde naranja, fondo naranja: entidad nueva del Proyecto 2</B></FONT></TD></TR>'
           '<TR><TD ALIGN="LEFT"><FONT COLOR="%s"><B>Borde naranja, fondo blanco: entidad modificada</B></FONT></TD></TR>'
           '<TR><TD ALIGN="LEFT">Subtipos MEDICO y ENFERMERO dentro del supertipo PERSONAL</TD></TR>'
           '<TR><TD ALIGN="LEFT">(una tabla por supertipo y por subtipo, con llave compartida)</TD></TR>'
           '<TR><TD ALIGN="LEFT">#  identificador   *  obligatorio   o  opcional</TD></TR>'
           '</TABLE>>];' % (RESALTE, RESALTE)]
    for i, (area, color, tablas) in enumerate(AREAS):
        out.append('  subgraph cluster_%d { label="%s"; style="rounded,filled"; fillcolor="%s"; color="#999999"; '
                   'fontsize=18;' % (i, area, color))
        for t in tablas:
            if t == SUPERTIPO:
                # el supertipo es un recuadro que contiene a sus subtipos
                filas = ''.join('<TR><TD ALIGN="LEFT"><FONT POINT-SIZE="10">%s</FONT></TD></TR>' % escape(a)
                                for a in atributos(t, columnas))
                out.append('    subgraph cluster_personal { label=<<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2">'
                           '<TR><TD><B>PERSONAL</B></TD></TR>%s</TABLE>>; style="rounded,filled,bold"; '
                           'fillcolor="#FFF3E0"; color="%s"; penwidth=2.5;' % (filas, RESALTE))
                for s in SUBTIPOS:
                    out.append('      "%s" [label=%s];' % (s, etiqueta_entidad(s, columnas)))
                out.append('    }')
            else:
                out.append('    "%s" [label=%s];' % (t, etiqueta_entidad(t, columnas)))
        out.append('  }')
    for i, r in enumerate(relaciones):
        m = 'rel%d' % i
        out.append('  "%s" [shape=point, width=0.02, label=""];' % m)
        cola = ('tee' if r['en_uid'] else '') + ('none' if r['uno_a_uno'] else 'crow')
        hijo, padre = r['hijo'], r['padre']
        extra_hijo = extra_padre = ''
        if hijo == padre:
            color = ', color="%s"' % RESALTE
            extra_hijo = ', label="superior directo", fontsize=11, fontcolor="%s"%s' % (RESALTE, color)
            extra_padre = color
        # las lineas del supertipo salen del borde del recuadro PERSONAL
        if hijo == SUPERTIPO:
            hijo, extra_hijo = SUBTIPOS[0], extra_hijo + ', ltail=cluster_personal'
        if padre == SUPERTIPO:
            padre, extra_padre = SUBTIPOS[0], extra_padre + ', lhead=cluster_personal'
        # mitad del hijo: continua si el hijo debe tener padre (FK not null)
        out.append('  "%s" -> "%s" [dir=back, arrowtail=%s, style=%s%s];'
                   % (hijo, m, cola, 'solid' if r['obligatoria'] else 'dashed', extra_hijo))
        # mitad del padre: el padre puede existir sin hijos
        out.append('  "%s" -> "%s" [dir=none, style=dashed%s];' % (m, padre, extra_padre))
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

    def texto_entidad(tabla):
        return '<b>%s</b><hr>%s' % (tabla.upper(), '<br>'.join(escape(a) for a in atributos(tabla, columnas)))

    celdas, ids = [], {}
    clusters = [o for o in layout.get('objects', []) if 'nodes' in o and 'bb' in o]
    # primero las areas y al final el supertipo, para que quede encima de su area
    clusters.sort(key=lambda o: o['name'] == 'cluster_personal')
    for obj in clusters:
        x0, y0, x1, y1 = (float(v) for v in obj['bb'].split(','))
        geo = '<mxGeometry x="%.0f" y="%.0f" width="%.0f" height="%.0f" as="geometry"/>' % (
            x0 * pt, (alto - y1) * pt, (x1 - x0) * pt, (y1 - y0) * pt)
        if obj['name'] == 'cluster_personal':
            ids[SUPERTIPO] = 'supertipo_personal'
            celdas.append('<mxCell id="supertipo_personal" value="%s" style="rounded=1;arcSize=4;whiteSpace=wrap;'
                          'html=1;align=left;verticalAlign=top;spacingLeft=8;fillColor=#FFF3E0;strokeColor=%s;'
                          'strokeWidth=2.5;fontSize=11;" vertex="1" parent="1">%s</mxCell>'
                          % (escape(texto_entidad(SUPERTIPO)), RESALTE, geo))
        else:
            celdas.append('<mxCell id="area%s" value="%s" style="rounded=1;arcSize=3;whiteSpace=wrap;html=1;'
                          'fillColor=%s;strokeColor=#999999;verticalAlign=top;fontSize=18;fontStyle=1;" '
                          'vertex="1" parent="1">%s</mxCell>'
                          % (obj['_gvid'], escape(obj['label']), obj.get('fillcolor', '#ffffff'), geo))
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
            continue
        if nombre == 'leyenda':
            texto = ('<b>Leyenda</b><br><font color="%s"><b>Fondo naranja: entidad nueva del Proyecto 2</b><br>'
                     '<b>Borde naranja: entidad modificada</b></font><br>Subtipos MEDICO y ENFERMERO dentro del '
                     'supertipo PERSONAL<br>(una tabla por supertipo y por subtipo, con llave compartida)<br>'
                     '# identificador &nbsp; * obligatorio &nbsp; o opcional' % RESALTE)
            estilo = 'fillColor=#ffffff;strokeColor=#333333;'
        else:
            texto = texto_entidad(nombre)
            if nombre in NUEVAS:
                estilo = 'fillColor=#FFF3E0;strokeColor=%s;strokeWidth=2.5;' % RESALTE
            elif nombre in MODIFICADAS:
                estilo = 'fillColor=#ffffff;strokeColor=%s;strokeWidth=2.5;' % RESALTE
            else:
                estilo = 'fillColor=#ffffff;strokeColor=#333333;'
        celdas.append('<mxCell id="%s" value="%s" style="rounded=1;arcSize=8;whiteSpace=wrap;html=1;align=left;'
                      'verticalAlign=top;spacingLeft=6;fontSize=11;%s" vertex="1" parent="1">'
                      '<mxGeometry x="%.0f" y="%.0f" width="%.0f" height="%.0f" as="geometry"/></mxCell>'
                      % (ids[nombre], escape(texto), estilo, x, y, w, h))
    for i, r in enumerate(relaciones):
        m = ids['rel%d' % i]
        if r['uno_a_uno']:
            fin = 'ERone' if r['en_uid'] else 'none'
        else:
            fin = 'ERoneToMany' if r['en_uid'] else 'ERmany'
        recursiva = r['hijo'] == r['padre']
        color = RESALTE if recursiva else '#444444'
        valor = 'superior directo' if recursiva else ''
        celdas.append('<mxCell id="e%da" value="%s" style="endArrow=none;startArrow=%s;startFill=0;dashed=%d;html=1;'
                      'strokeColor=%s;fontColor=%s;" edge="1" parent="1" source="%s" target="%s">'
                      '<mxGeometry relative="1" as="geometry"/></mxCell>'
                      % (i, valor, fin, 0 if r['obligatoria'] else 1, color, color, ids[r['hijo']], m))
        celdas.append('<mxCell id="e%db" style="endArrow=none;dashed=1;html=1;strokeColor=%s;" edge="1" '
                      'parent="1" source="%s" target="%s"><mxGeometry relative="1" as="geometry"/></mxCell>'
                      % (i, color, m, ids[r['padre']]))
    xml = ('<mxfile host="app.diagrams.net"><diagram id="modelo-barker-p2" name="Modelo extendido P2">'
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
        imagen.crop((x0, 0, x1, alto)).save(os.path.join(BASE, 'modelo_barker_p2_parte%d.png' % (i + 1)))


def main():
    columnas, relaciones = leer_esquema()
    faltan = set(columnas) - {t for _, _, ts in AREAS for t in ts} - set(SUBTIPOS)
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
