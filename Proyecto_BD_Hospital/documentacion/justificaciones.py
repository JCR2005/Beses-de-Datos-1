# -*- coding: utf-8 -*-
"""Justificacion de negocio de las acciones referenciales de cada llave foranea.

El enunciado pide que esta justificacion quede solo en el PDF y no en el DDL.
Clave: (tabla, columna). Todas las FK usan ON UPDATE CASCADE porque las PK son
identity y nunca se modifican; si llegara a pasar, el hijo debe seguir al padre.
"""

# textos que se repiten
_CAT = 'RESTRICT: no se borra un valor de catálogo que está en uso; primero se reasignan las filas que lo usan.'
_HIST = 'RESTRICT: es historia clínica; borrar el {p} dejaría {h} sin referencia, por eso se impide.'
_DET = 'CASCADE: {h} es un detalle que no existe sin su {p}; al borrar el {p} se borran sus detalles.'
_FIN = 'RESTRICT: es información financiera que se debe conservar para auditoría.'

JUSTIFICACIONES = {
    # geografia e infraestructura
    ('municipio', 'id_departamento'): _CAT,
    ('hospital', 'id_municipio'): _CAT,
    ('unidad_medica', 'id_hospital'): _DET.format(h='la unidad', p='hospital') + ' Si ya tiene fichas, esas FK bloquean el borrado.',
    ('servicio_atencion', 'id_unidad'): _DET.format(h='el servicio', p='unidad'),
    ('camilla', 'id_unidad'): _DET.format(h='la camilla', p='unidad'),
    ('quirofano', 'id_unidad'): _DET.format(h='el quirófano', p='unidad'),
    # personal
    ('medico', 'id_especialidad'): _CAT,
    ('medico', 'id_hospital'): 'RESTRICT: un hospital con médicos asignados no se elimina; primero se reasigna su personal.',
    ('medico', 'id_municipio'): _CAT,
    ('enfermero', 'id_hospital'): 'RESTRICT: un hospital con enfermeros asignados no se elimina; primero se reasigna su personal.',
    ('turno_emergencia', 'id_unidad'): 'RESTRICT: los turnos son el historial de cobertura de emergencias y los usan los ingresos.',
    ('turno_medico', 'id_medico'): 'RESTRICT: no se borra un médico que aparece en el historial de turnos.',
    ('turno_medico', 'id_turno'): _DET.format(h='la asignación de médicos', p='turno'),
    # pacientes
    ('paciente', 'id_estado_civil'): _CAT,
    ('paciente', 'id_municipio'): _CAT,
    ('encargado', 'id_municipio'): _CAT,
    ('paciente_encargado', 'id_encargado'): 'CASCADE: la relación no tiene sentido sin el encargado; al borrarlo solo se quita el vínculo.',
    ('paciente_encargado', 'id_paciente'): 'CASCADE: la relación no tiene sentido sin el paciente; al borrarlo se quitan sus vínculos.',
    ('paciente_encargado', 'id_parentesco'): _CAT,
    # consulta externa
    ('cita', 'id_medico'): _HIST.format(p='médico', h='la cita'),
    ('cita', 'id_paciente'): _HIST.format(p='paciente', h='la cita'),
    ('consulta', 'id_cita'): _HIST.format(p='cita', h='la consulta'),
    ('consulta', 'id_diagnostico'): _CAT,
    ('receta', 'id_consulta'): _HIST.format(p='consulta', h='la receta'),
    ('receta_medicamento', 'id_medicamento'): _CAT,
    ('receta_medicamento', 'id_receta'): _DET.format(h='cada medicamento recetado', p='receta'),
    # fichas
    ('ingreso', 'id_camilla'): 'RESTRICT: no se borra una camilla que aparece en ingresos; se marca como no disponible.',
    ('ingreso', 'id_medico_encargado'): _HIST.format(p='médico encargado', h='el ingreso'),
    ('ingreso', 'id_paciente'): _HIST.format(p='paciente', h='el ingreso'),
    ('ingreso', 'id_quirofano'): 'RESTRICT: no se borra un quirófano que aparece en ingresos; se marca en mantenimiento.',
    ('ingreso', 'id_servicio'): _CAT,
    ('ingreso', 'id_turno'): 'RESTRICT: el turno es parte del registro de cómo se atendió el ingreso.',
    ('ingreso', 'id_unidad'): _HIST.format(p='unidad', h='el ingreso'),
    ('egreso', 'id_diagnostico_principal'): _CAT,
    ('egreso', 'id_ingreso'): _HIST.format(p='ingreso', h='el egreso'),
    ('egreso', 'id_medico'): _HIST.format(p='médico', h='el egreso'),
    ('egreso_diagnostico', 'id_diagnostico'): _CAT,
    ('egreso_diagnostico', 'id_egreso'): _DET.format(h='el diagnóstico secundario', p='egreso'),
    ('institucion_externa', 'id_municipio'): _CAT,
    ('traslado', 'id_consulta'): _HIST.format(p='consulta', h='el traslado'),
    ('traslado', 'id_ingreso'): _HIST.format(p='ingreso', h='el traslado'),
    ('traslado', 'id_institucion_destino'): 'RESTRICT: no se borra una institución que recibió traslados.',
    ('traslado', 'id_medico_indica'): _HIST.format(p='médico', h='el traslado'),
    ('traslado', 'id_unidad_destino'): _HIST.format(p='unidad', h='el traslado'),
    ('traslado', 'id_unidad_origen'): _HIST.format(p='unidad', h='el traslado'),
    # cirugia
    ('tipo_cirugia', 'id_especialidad'): _CAT,
    ('agendamiento_quirurgico', 'id_medico_cirujano'): _HIST.format(p='cirujano', h='la solicitud'),
    ('agendamiento_quirurgico', 'id_paciente'): _HIST.format(p='paciente', h='la solicitud'),
    ('agendamiento_quirurgico', 'id_quirofano_solicitado'): 'RESTRICT: no se borra un quirófano con solicitudes; se marca en mantenimiento.',
    ('agendamiento_quirurgico', 'id_tipo_anestesia'): _CAT,
    ('agendamiento_quirurgico', 'id_tipo_cirugia'): _CAT,
    ('requerimiento_insumo', 'id_agendamiento'): _DET.format(h='el requerimiento', p='agendamiento'),
    ('requerimiento_insumo', 'id_insumo'): _CAT,
    ('requerimiento_instrumento', 'id_agendamiento'): _DET.format(h='el requerimiento', p='agendamiento'),
    ('requerimiento_instrumento', 'id_instrumento'): _CAT,
    ('requerimiento_equipo', 'id_agendamiento'): _DET.format(h='el requerimiento', p='agendamiento'),
    ('requerimiento_equipo', 'id_equipo'): _CAT,
    ('historia_clinica', 'id_agendamiento'): _HIST.format(p='agendamiento', h='la historia clínica'),
    ('historia_clinica', 'id_medico'): _HIST.format(p='médico', h='la historia clínica'),
    ('consentimiento_informado', 'id_agendamiento'): 'RESTRICT: el consentimiento firmado es un documento legal que se debe conservar.',
    ('consentimiento_informado', 'id_medico'): 'RESTRICT: el consentimiento firmado es un documento legal; no se borra al médico que lo firmó.',
    ('chequeo_preanestesico', 'id_agendamiento'): _HIST.format(p='agendamiento', h='el chequeo preanestésico'),
    ('chequeo_preanestesico', 'id_medico_anestesista'): _HIST.format(p='anestesista', h='el chequeo'),
    ('chequeo_preanestesico', 'id_medico_clasifica'): _HIST.format(p='médico', h='el chequeo'),
    ('cirugia', 'id_agendamiento'): _HIST.format(p='agendamiento', h='la cirugía'),
    ('cirugia', 'id_ingreso'): _HIST.format(p='ingreso', h='la cirugía'),
    ('cirugia', 'id_quirofano'): 'RESTRICT: no se borra un quirófano donde se operó; se marca en mantenimiento.',
    ('cirugia_personal', 'id_cirugia'): _DET.format(h='la participación del personal', p='cirugía'),
    ('cirugia_personal', 'id_enfermero'): 'RESTRICT: no se borra a un enfermero que participó en cirugías.',
    ('cirugia_personal', 'id_medico'): 'RESTRICT: no se borra a un médico que participó en cirugías.',
    ('cirugia_personal', 'id_rol'): _CAT,
    ('registro_procedimiento', 'id_aspecto'): _CAT,
    ('registro_procedimiento', 'id_cirugia'): _DET.format(h='el registro de cada aspecto', p='cirugía'),
    ('registro_procedimiento', 'id_enfermero'): 'RESTRICT: se debe conservar quién registró cada aspecto de la cirugía.',
    ('documentacion_etapa', 'id_cirugia'): _DET.format(h='la documentación de la etapa', p='cirugía'),
    ('documentacion_etapa', 'id_enfermero'): 'RESTRICT: se debe conservar qué enfermero envió la documentación.',
    ('cirugia_insumo', 'id_cirugia'): _DET.format(h='el consumo de insumos', p='cirugía'),
    ('cirugia_insumo', 'id_insumo'): _CAT,
    # hospitalizacion y facturacion
    ('hospitalizacion_insumo', 'id_ingreso'): _DET.format(h='el consumo de insumos', p='ingreso'),
    ('hospitalizacion_insumo', 'id_insumo'): _CAT,
    ('factura', 'id_cirugia'): _FIN,
    ('factura', 'id_cita'): _FIN,
    ('factura', 'id_ingreso'): _FIN,
    ('pago', 'id_factura'): _FIN + ' Una factura con pagos no se puede borrar.',
    ('pago', 'id_metodo_pago'): _CAT,
    # calificaciones
    ('calificacion', 'id_consulta'): 'RESTRICT: la calificación forma parte del historial de calidad del servicio.',
    ('calificacion', 'id_encargado'): 'RESTRICT: la calificación forma parte del historial de calidad del servicio.',
    ('calificacion', 'id_enfermero'): 'RESTRICT: la calificación forma parte del historial de calidad del servicio.',
    ('calificacion', 'id_hospital'): 'RESTRICT: la calificación forma parte del historial de calidad del servicio.',
    ('calificacion', 'id_medico'): 'RESTRICT: la calificación forma parte del historial de calidad del servicio.',
    ('calificacion', 'id_paciente'): 'RESTRICT: se conserva quién emitió cada calificación.',
}
