# -*- coding: utf-8 -*-
"""Descripcion de las tablas y columnas nuevas o modificadas por el Proyecto 2 (diccionario de datos del PDF).

Se combinan con las del Proyecto 1 (Proyecto_BD_Hospital/documentacion/descripciones.py); si una columna
aparece en las dos, vale la de aqui. Claves: TABLAS_P2[tabla] y COLUMNAS_P2[(tabla, columna)].
"""

TABLAS_P2 = {
    'personal': 'Supertipo con los datos comunes de todo el personal del hospital; sus subtipos son medico y enfermero.',
    'medico': 'Subtipo de personal: médicos de la cadena (los externos no están contratados, solo operan).',
    'enfermero': 'Subtipo de personal: enfermeros registrados y practicantes de enfermería.',
    'forma_farmaceutica': 'Catálogo de formas en que se entrega un medicamento.',
    'funcion_instrumento': 'Catálogo de funciones de un instrumento quirúrgico.',
    'funcion_equipo': 'Catálogo de funciones de un equipo médico.',
    'clasificacion_asa': 'Catálogo de la clasificación ASA del riesgo anestésico.',
    'tipo_medico': 'Catálogo de modalidades del médico dentro del hospital.',
    'medio_asignacion': 'Catálogo de medios por los que se asigna una cita.',
    'clinica': 'Clínicas (consultorios) de la unidad de Consulta Externa de cada hospital.',
    'examen_laboratorio': 'Catálogo de exámenes de laboratorio que se pueden ordenar.',
    'orden_laboratorio': 'Orden de laboratorio que el médico entrega en una consulta.',
    'orden_examen': 'Exámenes que se piden en cada orden de laboratorio.',
    'auditoria_personal': 'Bitácora automática de los cambios de salario, nivel de acceso y especialidad del personal.',
}

COLUMNAS_P2 = {
    ('personal', 'id_personal'): 'Identificador de la persona; es también la llave de su subtipo.',
    ('personal', 'tipo_personal'): 'Discriminador: indica si la persona es medico o enfermero.',
    ('personal', 'nombres'): 'Nombres de la persona.',
    ('personal', 'apellidos'): 'Apellidos de la persona.',
    ('personal', 'dpi'): 'Documento Personal de Identificación (CUI de 13 dígitos).',
    ('personal', 'telefono'): 'Teléfono de contacto.',
    ('personal', 'direccion'): 'Dirección de residencia.',
    ('personal', 'id_municipio'): 'Municipio de residencia.',
    ('personal', 'area'): 'Área de residencia: Urbana o Rural.',
    ('personal', 'id_hospital'): 'Hospital donde trabaja.',
    ('personal', 'fecha_contratacion'): 'Fecha de contratación; nula para los médicos externos, que no están contratados.',
    ('personal', 'salario'): 'Salario mensual en quetzales; nulo si no está contratado. Se audita cada cambio.',
    ('personal', 'nivel_acceso'): 'Nivel de acceso al sistema: consulta, operativo, supervisor o administrador. Se audita cada cambio.',

    ('medico', 'id_medico'): 'Identificador del médico; es el mismo id_personal de su supertipo.',
    ('medico', 'tipo_personal'): 'Discriminador fijo en medico; junto con id_medico forma la FK hacia personal.',
    ('medico', 'cargo'): 'Cargo en la cadena de mando: director_medico, jefe_servicio o medico.',
    ('medico', 'id_medico_superior'): 'Superior directo dentro del mismo hospital (relación recursiva); nulo para el director.',
    ('medico', 'id_especialidad'): 'Especialidad del médico. Se audita cada cambio.',
    ('medico', 'nombres'): 'Copia de personal.nombres (se guarda igual en las dos tablas).',
    ('medico', 'apellidos'): 'Copia de personal.apellidos.',
    ('medico', 'dpi'): 'Copia de personal.dpi.',
    ('medico', 'telefono'): 'Copia de personal.telefono.',
    ('medico', 'id_municipio'): 'Copia de personal.id_municipio.',
    ('medico', 'area'): 'Copia de personal.area.',
    ('medico', 'id_hospital'): 'Copia de personal.id_hospital.',

    ('enfermero', 'id_enfermero'): 'Identificador del enfermero; es el mismo id_personal de su supertipo.',
    ('enfermero', 'tipo_personal'): 'Discriminador fijo en enfermero; junto con id_enfermero forma la FK hacia personal.',
    ('enfermero', 'nombres'): 'Copia de personal.nombres (se guarda igual en las dos tablas).',
    ('enfermero', 'apellidos'): 'Copia de personal.apellidos.',
    ('enfermero', 'dpi'): 'Copia de personal.dpi.',
    ('enfermero', 'telefono'): 'Copia de personal.telefono.',
    ('enfermero', 'id_hospital'): 'Copia de personal.id_hospital.',

    ('forma_farmaceutica', 'codigo'): 'Código de la forma farmacéutica.',
    ('forma_farmaceutica', 'descripcion'): 'Descripción de la forma farmacéutica.',

    ('funcion_instrumento', 'codigo'): 'Código de la función.',
    ('funcion_instrumento', 'descripcion'): 'Descripción de la función.',

    ('funcion_equipo', 'codigo'): 'Código de la función.',
    ('funcion_equipo', 'descripcion'): 'Descripción de la función.',

    ('clasificacion_asa', 'codigo'): 'Clase ASA (I a VI).',
    ('clasificacion_asa', 'descripcion'): 'Significado de la clase.',

    ('tipo_medico', 'codigo'): 'Código de la modalidad.',
    ('tipo_medico', 'descripcion'): 'Descripción de la modalidad.',

    ('medio_asignacion', 'codigo'): 'Código del medio.',
    ('medio_asignacion', 'descripcion'): 'Descripción del medio.',

    ('clinica', 'id_clinica'): 'Identificador de la clínica.',
    ('clinica', 'numero'): 'Número o código de la clínica dentro de su unidad.',

    ('cita', 'id_clinica'): 'Clínica donde se atiende la cita.',
    ('cita', 'numero_clinica'): 'Número de clínica escrito en la cita (se conserva por compatibilidad; usar id_clinica).',

    ('examen_laboratorio', 'id_examen'): 'Identificador del examen.',
    ('examen_laboratorio', 'nombre'): 'Nombre del examen.',
    ('examen_laboratorio', 'descripcion'): 'Qué mide el examen.',
    ('examen_laboratorio', 'costo'): 'Costo del examen en quetzales.',

    ('orden_laboratorio', 'id_orden'): 'Identificador de la orden.',
    ('orden_laboratorio', 'fecha'): 'Fecha de la orden.',
    ('orden_laboratorio', 'indicaciones'): 'Indicaciones para el paciente.',

    ('auditoria_personal', 'id_auditoria'): 'Identificador del registro de la bitácora (lo genera la base).',
    ('auditoria_personal', 'fecha_hora'): 'Fecha y hora exacta del cambio (now()).',
    ('auditoria_personal', 'usuario'): 'Usuario de la base de datos que hizo el cambio (current_user).',
    ('auditoria_personal', 'tabla'): 'Tabla donde ocurrió el cambio: personal o medico.',
    ('auditoria_personal', 'id_registro'): 'Identificador de la persona cuyo dato cambió (id_personal = id_medico).',
    ('auditoria_personal', 'campo'): 'Campo que cambió: salario, nivel_acceso o id_especialidad.',
    ('auditoria_personal', 'valor_anterior'): 'Valor antes del cambio.',
    ('auditoria_personal', 'valor_nuevo'): 'Valor después del cambio.',
}
