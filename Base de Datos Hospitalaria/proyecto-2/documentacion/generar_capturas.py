#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera la captura (PNG) del resultado de cada uno de los 20 objetivos.

Cada consulta se ejecuta contra la base real con el rol de solo lectura (visor)
y su resultado se dibuja como lo mostraria un cliente SQL: la sentencia, la
tabla de resultados, el numero de filas y el tiempo de ejecucion.

Uso: HOSPITAL_DB_PASSWORD=... python3 generar_capturas.py
Salida: capturas/objetivo_XX.png
"""
import os
import subprocess
import time

from PIL import Image, ImageDraw, ImageFont

BASE = os.path.dirname(os.path.abspath(__file__))
SALIDA = os.path.join(BASE, 'capturas')
D, H = "'2026-01-01'", "'2026-10-31'"
LAPSO = '%s, %s' % (D, H)
MAX_FILAS = 25

OBJETIVOS = [
    (1, 'Los 3 hospitales con mayor demanda en consulta externa', ['select * from fn_objetivo_01(%s);' % LAPSO]),
    (2, 'Los 5 médicos de consulta externa con menor calificación', ['select * from fn_objetivo_02(%s);' % LAPSO]),
    (3, 'Los 5 mejores médicos de emergencias', ['select * from fn_objetivo_03(%s);' % LAPSO]),
    (4, 'Los 3 hospitales más eficientes en emergencias', ['select * from fn_objetivo_04(%s);' % LAPSO]),
    (5, 'Los 3 cirujanos más eficientes', ['select * from fn_objetivo_05(%s);' % LAPSO]),
    (6, 'Los 3 tipos de cirugía con mayores ingresos', ['select * from fn_objetivo_06(%s);' % LAPSO]),
    (7, 'Los 3 hospitales con mayores ingresos en hospitalización', ['select * from fn_objetivo_07(%s);' % LAPSO]),
    (8, 'Pagos en efectivo, crédito y débito por hospital y unidad', ['select * from fn_objetivo_08(%s);' % LAPSO]),
    (9, 'Los 3 hospitales con mayor ingreso por visita', ['select * from fn_objetivo_09(%s);' % LAPSO]),
    (10, 'Fecha con más decesos y unidad con más decesos por hospital', ['select * from fn_objetivo_10();']),
    (11, 'Ingresos monetarios totales de cada hospital', ['select * from fn_objetivo_11(%s);' % LAPSO]),
    (12, 'Edad promedio y sexo en emergencias por hospital y turno', ['select * from fn_objetivo_12(%s);' % LAPSO]),
    (13, 'Citas por hospital, fecha, especialidad y sexo (primer trimestre)',
     ["select * from fn_objetivo_13('2026-01-01', '2026-03-31');"]),
    (14, 'Promedio de cuotas de pago por unidad en cada hospital', ['select * from fn_objetivo_14(%s);' % LAPSO]),
    (15, 'Extensión del modelo: supertipo PERSONAL y cadena de mando', [
        """select p.tipo_personal, count(*) as personas, count(m.id_medico) as en_medico, count(e.id_enfermero) as en_enfermero
  from personal p
  left join medico m on m.id_medico = p.id_personal
  left join enfermero e on e.id_enfermero = p.id_personal
 group by p.tipo_personal;""",
        """select p.id_personal, p.nombres || ' ' || p.apellidos as medico, m.cargo,
       s.nombres || ' ' || s.apellidos as superior_directo
  from personal p
  join medico m on m.id_medico = p.id_personal
  left join medico s on s.id_medico = m.id_medico_superior
 where p.id_hospital = 1 and m.tipo_medico <> 'externo'
 order by m.cargo, p.id_personal;"""]),
    (16, 'Cadena de supervisión hasta el director médico (CTE recursiva)',
     ['select * from fn_cadena_mando(1018);', 'select * from fn_cadena_mando(1046);']),
    (17, 'Ranking por hospital y en toda la cadena (funciones de ventana)', [
        'select * from fn_objetivo_17_ventana(%s) limit 12;' % LAPSO,
        """select count(*) as filas_distintas_entre_las_dos_formas
  from ((select * from fn_objetivo_17_ventana(%s)
         except select * from fn_objetivo_17_correlacionada(%s))
        union all
        (select * from fn_objetivo_17_correlacionada(%s)
         except select * from fn_objetivo_17_ventana(%s))) d;""" % (LAPSO, LAPSO, LAPSO, LAPSO)]),
    (18, 'Pacientes atendidos en las 4 unidades (división relacional)', ['select * from fn_objetivo_18(%s);' % LAPSO]),
    (19, 'Reporte de cirugías: original y reconstruido desde la propuesta en 3FN', [
        'select * from propuesta_bloque_e.reporte_cirugia;',
        """select ci.id_cirugia, cj.nombres || ' ' || cj.apellidos as cirujano, es.nombre as especialidad,
       d.codigo_cie10, i.nombre as insumo, x.cantidad, ci.fecha
  from propuesta_bloque_e.cirugia ci
  join propuesta_bloque_e.cirujano cj on cj.id_cirujano = ci.id_cirujano
  join propuesta_bloque_e.especialidad es on es.id_especialidad = cj.id_especialidad
  join propuesta_bloque_e.diagnostico d on d.codigo_cie10 = ci.codigo_cie10
  join propuesta_bloque_e.cirugia_insumo x on x.id_cirugia = ci.id_cirugia
  join propuesta_bloque_e.insumo i on i.id_insumo = x.id_insumo
 order by ci.id_cirugia, i.nombre;"""]),
    (20, 'Bitácora automática de cambios sensibles del personal', [
        """select id_auditoria, fecha_hora, usuario_bd, usuario_aplicacion, tabla, id_registro,
       campo, valor_anterior, valor_nuevo
  from auditoria_personal
 order by id_auditoria;"""]),
]

# ---------------------------------------------------------------- consulta
SEP = '\x1f'


def ejecutar(sql):
    """Ejecuta la sentencia como visor y devuelve (columnas, filas, milisegundos)."""
    env = dict(os.environ)
    if not env.get('HOSPITAL_DB_PASSWORD'):
        raise SystemExit('Defina HOSPITAL_DB_PASSWORD con la clave del rol visor')
    env['PGPASSWORD'] = env['HOSPITAL_DB_PASSWORD']
    inicio = time.perf_counter()
    r = subprocess.run(['psql', '-h', 'localhost', '-p', '5433', '-U', 'visor', '-d', 'hospital', '-X', '-A', '-q',
                        '-F', SEP, '-P', 'footer=off', '-v', 'ON_ERROR_STOP=1', '-c', sql],
                       capture_output=True, text=True, env=env)
    ms = (time.perf_counter() - inicio) * 1000
    if r.returncode != 0:
        raise SystemExit('Error en la consulta:\n%s\n%s' % (sql, r.stderr))
    lineas = r.stdout.rstrip('\n').split('\n')
    return lineas[0].split(SEP), [l.split(SEP) for l in lineas[1:] if l != ''], ms


# ---------------------------------------------------------------- dibujo
FUENTE = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
FUENTE_B = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
MONO = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
F_TIT = ImageFont.truetype(FUENTE_B, 20)
F_SUB = ImageFont.truetype(FUENTE, 13)
F_SQL = ImageFont.truetype(MONO, 13)
F_CAB = ImageFont.truetype(FUENTE_B, 13)
F_CEL = ImageFont.truetype(FUENTE, 13)
AZUL, GRIS, LINEA = (30, 136, 229), (245, 246, 248), (210, 214, 220)


def es_numero(v):
    try:
        float(v)
        return True
    except ValueError:
        return False


def ancho(texto, fuente):
    return fuente.getlength(texto)


def bloque(sql, columnas, filas, ms):
    """Mide y devuelve una funcion que dibuja un bloque (sentencia + resultado)."""
    mostradas = filas[:MAX_FILAS]
    textos = [[(v[:45] + '…') if len(v) > 46 else v for v in f] for f in mostradas]
    anchos = [max([ancho(c, F_CAB)] + [ancho(f[i], F_CEL) for f in textos]) + 24 for i, c in enumerate(columnas)]
    lineas_sql = sql.split('\n')
    alto_sql = 16 + 18 * len(lineas_sql)
    alto_tabla = 30 * (len(textos) + 1)
    alto = alto_sql + 14 + alto_tabla + 34
    ancho_total = max(sum(anchos), max(ancho(l, F_SQL) for l in lineas_sql) + 24)

    def dibujar(d, x, y, ancho_lienzo):
        d.rectangle([x, y, x + ancho_lienzo, y + alto_sql], fill=GRIS, outline=LINEA)
        for i, l in enumerate(lineas_sql):
            d.text((x + 12, y + 8 + 18 * i), l, font=F_SQL, fill=(40, 40, 40))
        y += alto_sql + 14
        cx = x
        d.rectangle([x, y, x + sum(anchos), y + 30], fill=(227, 242, 253), outline=LINEA)
        for i, c in enumerate(columnas):
            d.text((cx + 12, y + 7), c, font=F_CAB, fill=(13, 71, 161))
            cx += anchos[i]
        for n, f in enumerate(textos):
            fy = y + 30 * (n + 1)
            d.rectangle([x, fy, x + sum(anchos), fy + 30], fill=(255, 255, 255) if n % 2 == 0 else (250, 251, 252),
                        outline=LINEA)
            cx = x
            for i, v in enumerate(f):
                tx = cx + anchos[i] - 12 - ancho(v, F_CEL) if es_numero(v) else cx + 12
                d.text((tx, fy + 7), v, font=F_CEL, fill=(33, 33, 33))
                cx += anchos[i]
        cx = x
        for a in anchos[:-1]:
            cx += a
            d.line([cx, y, cx, y + alto_tabla], fill=LINEA)
        pie = '%d fila%s  ·  %.0f ms' % (len(filas), '' if len(filas) == 1 else 's', ms)
        if len(filas) > MAX_FILAS:
            pie += '  ·  se muestran las primeras %d' % MAX_FILAS
        d.text((x, y + alto_tabla + 10), pie, font=F_SUB, fill=(100, 100, 100))

    return ancho_total, alto, dibujar


def captura(numero, titulo, sentencias):
    bloques = []
    for sql in sentencias:
        columnas, filas, ms = ejecutar(sql)
        bloques.append(bloque(sql, columnas, filas, ms))
    margen = 28
    ancho_lienzo = int(max(max(b[0] for b in bloques), 760))
    alto = 92 + sum(b[1] + 22 for b in bloques) + margen
    img = Image.new('RGB', (ancho_lienzo + 2 * margen, alto), 'white')
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, img.width, 6], fill=AZUL)
    d.text((margen, 22), 'Objetivo %d — %s' % (numero, titulo), font=F_TIT, fill=(33, 33, 33))
    d.text((margen, 54), 'PostgreSQL 18  ·  base hospital  ·  conectado con el rol de solo lectura: visor',
           font=F_SUB, fill=(110, 110, 110))
    y = 92
    for b in bloques:
        b[2](d, margen, y, ancho_lienzo)
        y += b[1] + 22
    ruta = os.path.join(SALIDA, 'objetivo_%02d.png' % numero)
    img.save(ruta)
    return ruta


def main():
    os.makedirs(SALIDA, exist_ok=True)
    for numero, titulo, sentencias in OBJETIVOS:
        print(captura(numero, titulo, sentencias))


if __name__ == '__main__':
    main()
