# -*- coding: utf-8 -*-
"""Justificacion de negocio de las acciones referenciales de las llaves foraneas nuevas del Proyecto 2.

El enunciado pide que esta justificacion quede solo en el documento PDF. Clave: (tabla, columna).
Las del Proyecto 1 estan en Proyecto_BD_Hospital/documentacion/justificaciones.py.
"""

JUSTIFICACIONES_P2 = {
    ('personal', 'id_municipio'):
        'DELETE RESTRICT: un municipio de catálogo no se borra mientras viva personal en él. '
        'UPDATE CASCADE: la llave es identity; si cambiara, la persona sigue a su municipio.',
    ('personal', 'id_hospital'):
        'DELETE RESTRICT: no se elimina un hospital que todavía tiene personal; primero se reasigna. '
        'UPDATE CASCADE: si cambiara la llave del hospital, su personal la sigue.',
    ('medico', 'id_medico'):
        'FK compuesta (id_medico, tipo_personal) hacia personal. DELETE CASCADE: el subtipo no existe sin su '
        'supertipo, al borrar la persona se borra su fila de médico (si tiene historia clínica, esas FK lo impiden). '
        'UPDATE CASCADE: el subtipo comparte la llave con el supertipo y debe seguirla; un cambio de tipo_personal '
        'en personal choca con el CHECK del subtipo, por lo que nadie puede cambiar de médico a enfermero.',
    ('medico', 'tipo_personal'):
        'Parte de la FK compuesta hacia personal (ver id_medico): obliga a que el médico apunte a personal de tipo médico.',
    ('enfermero', 'id_enfermero'):
        'FK compuesta (id_enfermero, tipo_personal) hacia personal. DELETE CASCADE: el subtipo no existe sin su '
        'supertipo. UPDATE CASCADE: el subtipo comparte la llave con el supertipo y debe seguirla.',
    ('enfermero', 'tipo_personal'):
        'Parte de la FK compuesta hacia personal (ver id_enfermero): obliga a que apunte a personal de tipo enfermero.',
    ('medico', 'id_medico_superior'):
        'Relación recursiva. DELETE SET NULL: si el jefe deja el hospital, sus subordinados quedan sin superior '
        'hasta que se les asigne otro, sin perder su historia ni bloquear la baja. UPDATE CASCADE: si cambiara la '
        'llave del jefe, sus subordinados lo siguen.',

    # catalogos de 03_catalogos.sql: no se borra un valor de catalogo que esta en uso
    ('medicamento', 'forma_farmaceutica'): 'DELETE RESTRICT: no se borra una forma farmacéutica que usa algún medicamento. UPDATE CASCADE: si cambia el código, los medicamentos lo siguen.',
    ('instrumento', 'funcion'): 'DELETE RESTRICT: no se borra una función que tiene instrumentos. UPDATE CASCADE: si cambia el código, los instrumentos lo siguen.',
    ('equipo', 'funcion'): 'DELETE RESTRICT: no se borra una función que tiene equipos. UPDATE CASCADE: si cambia el código, los equipos lo siguen.',
    ('chequeo_preanestesico', 'clasificacion_asa'): 'DELETE RESTRICT: la clase ASA es parte de la historia clínica del paciente. UPDATE CASCADE: si cambia el código, los chequeos lo siguen.',
    ('medico', 'tipo_medico'): 'DELETE RESTRICT: no se borra una modalidad que tienen médicos. UPDATE CASCADE: si cambia el código, los médicos lo siguen.',
    ('cita', 'medio_asignacion'): 'DELETE RESTRICT: no se borra un medio con el que se asignaron citas. UPDATE CASCADE: si cambia el código, las citas lo siguen.',
    # tablas de 04_laboratorio_y_clinicas.sql
    ('clinica', 'id_unidad'): 'DELETE RESTRICT: no se borra una unidad que tiene clínicas con citas. UPDATE CASCADE: la clínica sigue a su unidad.',
    ('cita', 'id_clinica'): 'DELETE RESTRICT: no se borra una clínica donde ya hubo citas, es parte de la historia. UPDATE CASCADE: la cita sigue a su clínica.',
    ('orden_laboratorio', 'id_consulta'): 'DELETE RESTRICT: la orden es parte de la historia clínica de la consulta. UPDATE CASCADE: la orden sigue a su consulta.',
    ('orden_examen', 'id_orden'): 'DELETE CASCADE: los exámenes pedidos no existen sin su orden. UPDATE CASCADE: siguen a su orden.',
    ('orden_examen', 'id_examen'): 'DELETE RESTRICT: no se borra un examen del catálogo que ya fue ordenado. UPDATE CASCADE: si cambia el id, las órdenes lo siguen.',
}
