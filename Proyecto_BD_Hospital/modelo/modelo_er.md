# Modelo Entidad-Relación — Hospitales de Occidente

Convenciones: **M** = obligatorio, **O** = opcional. Las relaciones M:N quedan resueltas con
su entidad asociativa. Dominios con restricción CHECK listados al final.

## Catálogo general

**HOSPITAL**
- id_hospital (PK, M)
- nombre (M)
- informacion_especifica (O)
- direccion (M)

**UNIDAD_MEDICA** — una por hospital (las 4 unidades)
- id_unidad (PK, M)
- id_hospital (FK HOSPITAL, M)
- nombre (M) → CHECK ('Consulta Externa','Emergencias','Cirugia','Hospitalizacion','Otro')
- costo_dia_hospitalizacion (O, aplica a unidad Hospitalización)
- único: (id_hospital, nombre)

**SERVICIO_ATENCION** — "atención médica a recibir / tipo de servicio" por unidad
- id_servicio (PK, M)
- id_unidad (FK UNIDAD_MEDICA, M)
- nombre (M)
- costo (O) → costo definido por hospital según servicio brindado
- único: (id_unidad, nombre)

**ESPECIALIDAD**
- id_especialidad (PK, M)
- nombre (M, único)

**CAMILLA**
- id_camilla (PK, M)
- id_hospital (FK HOSPITAL, M)
- id_unidad (FK UNIDAD_MEDICA, M)
- numero (M)
- disponible (M, bool)
- único: (id_hospital, numero)

**QUIROFANO** — 4 por hospital
- id_quirofano (PK, M)
- id_hospital (FK HOSPITAL, M)
- numero (M)
- estado (O) → CHECK ('disponible','ocupado','en_mantenimiento')
- único: (id_hospital, numero)

**MEDICO**
- id_medico (PK, M)
- nombres (M)
- apellidos (M)
- dpi (M, único)
- telefono (O)
- municipio, departamento (O)
- area (O) → CHECK ('Urbana','Rural')
- id_especialidad (FK ESPECIALIDAD, O)
- tipo_medico (M) → CHECK ('residente','interno','externo','general','especialista')
- costo_primera_consulta (O) → para consulta externa, "el costo dependerá del médico"
- horario_inicio / horario_fin (O) → consulta externa solo turno matutino según horario

**ENFERMERO**
- id_enfermero (PK, M)
- nombres (M)
- apellidos (M)
- dpi (M, único)
- telefono (O)
- tipo (M) → CHECK ('registrado','practicante_de_enfermeria')

## Pacientes y acompañantes

**PACIENTE**
- id_paciente (PK, M)
- codigo_expediente (M, único)
- nombres (M)
- apellidos (M)
- fecha_nacimiento (M)
- edad_años (M) → CHECK (0–120)
- sexo (M) → CHECK ('Masculino','Femenino')
- dpi (O, único)
- telefono (O)
- municipio, departamento, area (O) — area CHECK ('Urbana','Rural')
- estado_civil (O) → egreso/traslado
- no_seguro_social (O) → ficha de consulta

**ENCARGADO**
- id_encargado (PK, M)
- nombre (M)
- dpi (O, único)
- telefono (O)
- municipio, departamento, area (O)

**PACIENTE_ENCARGADO** *(asociativa M:N — un paciente puede tener varios encargados y viceversa)*
- id_paciente_encargado (PK, M)
- id_paciente (FK PACIENTE, M)
- id_encargado (FK ENCARGADO, M)
- parentesco (M)
- único: (id_paciente, id_encargado)

## Consulta externa

**CITA** — ficha de cita programada
- id_cita (PK, M)
- id_paciente (FK PACIENTE, M)
- id_medico (FK MEDICO, M)
- fecha_hora (M)
- num_clinica (M) — "Clínica o consultorio"
- medio_asignacion (O) → CHECK ('telefonico','correo_institucional','recepcion_general','recepcion_medico')
- estado (M) → CHECK ('programada','realizada','reprogramada','cancelada')
- es_reconsulta (M, bool)
- es_referido (M, bool) → costo 80% si referido por institución
- costo_base (O) → costo del médico (base)
- costo_aplicado (O) → 75% reconsulta, 80% referido, +10% sobrecargo
- cancelada_sin_aviso (O, bool) → aplica sobrecargo del 10%

**CONSULTA** — ficha de consulta del paciente (1 consulta = 1 cita realizada)
- id_consulta (PK, M)
- id_cita (FK CITA, M, único)
- id_paciente (FK PACIENTE, M)
- id_medico (FK MEDICO, M)
- fecha (M)
- diagnostico (M)
- otros_datos (O)
- notas_observaciones (O)

**RECETA** — receta médica (0..1 por consulta)
- id_receta (PK, M)
- id_consulta (FK CONSULTA, M, único)
- fecha (M)
- proxima_cita (O) — día/mes/año de próxima cita de seguimiento

**RECETA_MEDICAMENTO** — prescripción (1:N RECETA)
- id_receta_medicamento (PK, M)
- id_receta (FK RECETA, M)
- medicamento_nombre (M)
- dosis (M)
- duracion (O)

## Fichas de Ingreso / Egreso / Traslado (Emergencias, Cirugía, Hospitalización)

**INGRESO** — ficha de ingreso (Consulta Externa NO la usa)
- id_ingreso (PK, M)
- id_paciente (FK PACIENTE, M)
- id_unidad (FK UNIDAD_MEDICA, M)
- id_servicio (FK SERVICIO_ATENCION, O) — atención médica a recibir
- id_camilla (FK CAMILLA, O) — camilla asignada
- motivo_ingreso (M)
- fecha_hora_ingreso (M)
- id_medico_encargado (FK MEDICO, M)
- diagnostico_presuntivo (O)

**EGRESO** — ficha de egreso (1:1 con INGRESO)
- id_egreso (PK, M)
- id_ingreso (FK INGRESO, M, único)
- diagnostico_principal (M)
- diagnosticos_secundarios (O)
- motivo_egreso (M)
- id_unidad (FK UNIDAD_MEDICA, M)
- id_servicio (FK SERVICIO_ATENCION, O)
- fecha_hora_egreso (M)
- id_medico (FK MEDICO, M)
- id_camilla (FK CAMILLA, O)
- codigo_egreso (M) → CHECK ('vivo','muerto','embarazo','parto')
- egreso_sin_consentimiento (M, bool) + motivo_egreso_sin_consentimiento (O)
- dias_hospitalizado (O) → CHECK (> 0)
- codigo_traslado (O)
- referido_otro_hospital (O, bool)

**TRASLADO** — ficha de traslado
- id_traslado (PK, M)
- fecha_hora (M)
- id_paciente (FK PACIENTE, M)
- id_medico_indica (FK MEDICO, M)
- id_unidad_origen (FK UNIDAD_MEDICA, M)
- id_unidad_destino (FK UNIDAD_MEDICA, M)
- interno_externo (M) → CHECK ('interno','externo')
- hospital_externo_nombre / hospital_externo_direccion (O, solo si externo)
- id_ingreso (FK INGRESO, O) — traslado desde una internación en curso
- id_consulta (FK CONSULTA, O) — traslado ordenado desde consulta externa

## Facturación

**FACTURA** — se emite al finalizar el proceso / cancelar el servicio
- id_factura (PK, M)
- id_paciente (FK PACIENTE, M)
- fecha_emision (M)
- descripcion (M) — breve y clara
- total (M) → CHECK (>= 0)
- id_cita (FK CITA, O) / id_ingreso (FK INGRESO, O) / id_cirugia (FK CIRUGIA, O) → origen del servicio
- CHECK: al menos un origen presente

**PAGO** — pago en cuotas (1..12) de una factura
- id_pago (PK, M)
- id_factura (FK FACTURA, M)
- numero_cuota (M) → CHECK (1–12)
- total_cuotas (M) → CHECK (1–12)
- monto (M) → CHECK (> 0)
- fecha_pago (M)
- único: (id_factura, numero_cuota)

## Cirugía

**AGENDAMIENTO_QUIRURGICO** — solicitud hacia el comité
- id_agendamiento (PK, M)
- id_paciente (FK PACIENTE, M)
- id_medico_cirujano (FK MEDICO, M)
- caracter (M) → CHECK ('urgente','programado')
- historia_clinica (O)
- tipo_procedimiento (M)
- tiempo_estimado (M)
- tipo_anestesia (M)
- fecha_hora_solicitud (M)
- estado_solicitud (M) → CHECK ('pendiente','aprobada','rechazada')
- motivo_rechazo (O) → se llena si rechazada (cirugías rechazadas)
- id_quirofano_solicitado (FK QUIROFANO, O)
- fecha_hora_agendada (O) — si aprobada, hora + pabellón

**HISTORIA_CLINICA** — interrogatorio + exploración física (preoperatorio)
- id_historia_clinica (PK, M)
- id_agendamiento (FK AGENDAMIENTO_QUIRURGICO, M, único)
- id_medico (FK MEDICO, M) — cirujano que elabora
- fecha (M)
- fuente_interrogatorio (M) → CHECK ('directo','indirecto')
- religion, ocupacion, lugar_nacimiento, lugar_residencia (O)
- antecedentes_heredofamiliares (M)
- antecedentes_personales_no_patologicos (M)
- antecedentes_patologicos (M)
- padecimiento_actual (M)
- interrogatorio_aparatos_sistemas (O)
- sintomas_generales_terapeutica (O)
- estudios_previos (O)
- signos_vitales (O)
- exploracion_general (O)
- exploracion_cabeza/cuello/torax/abdomen/extremidades/columna/cavidades (O)

**CONSENTIMIENTO_INFORMADO** — chequeo tras aprobación
- id_consentimiento (PK, M)
- id_agendamiento (FK AGENDAMIENTO_QUIRURGICO, M)
- procedimiento_nombre (M)
- procedimiento_objetivo (M)
- procedimiento_caracteristicas (M)
- procedimiento_riesgos (M)
- medico_firma (M) — nombre y firma del médico
- paciente_firma (M) — nombre y firma del paciente/familiar/tutor/legal
- fecha_obtencion (M)

**CHEQUEO_PREANESTESICO**
- id_chequeo_preanestesico (PK, M)
- id_agendamiento (FK AGENDAMIENTO_QUIRURGICO, M, único)
- clasificacion_asa (M) → CHECK ('I','II','III','IV','V','VI')
- medico_asa_nombre (M) — cirujano o médico tratante que clasifica
- plan_anestesia (M)
- anestesista_nombre (M)

**CIRUGIA** — intervención quirúrgica de un agendamiento aprobado
- id_cirugia (PK, M)
- id_agendamiento (FK AGENDAMIENTO_QUIRURGICO, M, único)
- id_quirofano (FK QUIROFANO, M)
- id_paciente (FK PACIENTE, M)
- id_cirujano (FK MEDICO, M)
- id_ingreso (FK INGRESO, O) — ficha de ingreso al llegar a quirófano
- fecha_hora_inicio (M)
- fecha_hora_fin (O)
- condicion_evolucion (O) → CHECK ('sin_complicaciones','complicaciones','complicaciones_graves')
- estado (M) → CHECK ('preoperatorio','intraoperatorio','postoperatorio','finalizada')

**REGISTRO_PROCEDIMIENTO** — registro del proceso (enfermero encargado)
- id_registro_procedimiento (PK, M)
- id_cirugia (FK CIRUGIA, M)
- etapa (M) → CHECK ('preoperatorio','intraoperatorio','postoperatorio')
- aspecto (M) — ej. planificacion, entrada, balance_hidrico, salida_quirurgica, traslado_seguro…
- exito (M, bool) — éxito/falla / aceptable-medianamente-no aceptable
- descripcion (O)
- hora_registro (M)
- id_enfermero (FK ENFERMERO, M)
- fecha_documentacion (O) — envío a secretaría (con nombre del enfermero y fecha)

**INSUMO** *(catálogo)*
- id_insumo (PK, M) · nombre (M) · descripcion (O) · material (O) · tipo (M) → CHECK ('medico','quirurgico','otro')

**INSTRUMENTO** *(catálogo)*
- id_instrumento (PK, M) · nombre (M) · descripcion (O) · tipo (M) → CHECK ('medico','quirurgico','otro') · funcion (M) → CHECK ('corte','contencion','hemostatica','retractor','accesorio','implante','otro')

**EQUIPO** *(catálogo)*
- id_equipo (PK, M) · nombre (M) · descripcion (O) · tipo (M) → CHECK ('medico','quirurgico','otro') · funcion (M) → CHECK ('exploracion','diagnostico','tratamiento','rehabilitacion','otro')

**REQUERIMIENTO_QUIRURGICO** *(asociativa M:N agendamiento ↔ recursos requeridos)*
- id_requerimiento (PK, M)
- id_agendamiento (FK AGENDAMIENTO_QUIRURGICO, M)
- tipo_recurso (M) → CHECK ('insumo','instrumento','equipo')
- id_insumo (FK INSUMO, O) / id_instrumento (FK INSTRUMENTO, O) / id_equipo (FK EQUIPO, O)
- cantidad (M) → CHECK (> 0)
- CHECK: exactamente un recurso no nulo

**CIRUGIA_PERSONAL** *(asociativa M:N cirugía ↔ personal sanitario que interviene)*
- id_cirugia_personal (PK, M)
- id_cirugia (FK CIRUGIA, M)
- id_medico (FK MEDICO, O) / id_enfermero (FK ENFERMERO, O)
- rol (M) — ej. cirujano, anestesiologo, ayudante, enfermero, practicante
- CHECK: exactamente un tipo de personal no nulo

**CIRUGIA_INSUMO** — insumos utilizados durante la operación (costo total de insumos)
- id_cirugia_insumo (PK, M)
- id_cirugia (FK CIRUGIA, M)
- id_insumo (FK INSUMO, M)
- cantidad (M) → CHECK (> 0)
- costo_unitario (M) → CHECK (>= 0)

## Hospitalización

**HOSPITALIZACION_INSUMO** — insumos médicos usados durante los días internados
- id_hospitalizacion_insumo (PK, M)
- id_ingreso (FK INGRESO, M) — ingreso a la unidad Hospitalización
- id_insumo (FK INSUMO, M)
- cantidad (M) → CHECK (> 0)
- costo_unitario (M) → CHECK (>= 0)

---

## Resumen de relaciones M:N resueltas (entidades asociativas)
1. **PACIENTE_ENCARGADO** (PACIENTE ↔ ENCARGADO) con parentesco.
2. **CIRUGIA_PERSONAL** (CIRUGIA ↔ MEDICO/ENFERMERO) con rol.
3. **REQUERIMIENTO_QUIRURGICO** (AGENDAMIENTO_QUIRURGICO ↔ INSUMO/INSTRUMENTO/EQUIPO) con cantidad.

## Dominios con CHECK (resumen)
Sexo (M/F), Área (Urbana/Rural), Unidad médica, tipo_medico, tipo_enfermero (registrado/practicante),
estado cita, medio asignación, codigo_egreso (vivo/muerto/embarazo/parto), interno_externo,
caracter (urgente/programado), estado_solicitud, ASA (I–VI), condicion_evolucion, etapa cirugía,
tipo/función de equipo-instrumento-insumo, tipo_recurso, cuotas (1–12), rangos de edad y totales >= 0.

## Reglas de negocio que definen acciones referenciales (a justificar en el diccionario)
- PACIENCIA/egreso: restringir pagos y egresos contra pacientes.
- CASCADA donde la tabla hija no tiene sentido sin el padre (RECETA_MEDICAMENTO→RECETA, PAGO→FACTURA…).
- SET NULL para referencias opcionales (id_camilla ante baja de camilla, id_servicio…).