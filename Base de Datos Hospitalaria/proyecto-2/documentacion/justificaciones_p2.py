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
}
