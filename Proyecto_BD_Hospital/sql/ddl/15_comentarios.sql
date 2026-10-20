-- Proyecto 1 - BD Hospitales de Occidente
-- 15_comentarios.sql : descripcion de tablas y columnas guardada en el catalogo
--
-- El diccionario de datos (documentacion/generar_diccionario.py) lee estas
-- descripciones. Las PK y FK no se comentan aqui: el generador las describe
-- a partir de la tabla a la que apuntan.

set search_path to public;

-- ============================================================
-- tablas
-- ============================================================
comment on table departamento is 'Departamentos de Guatemala.';
comment on table municipio is 'Municipios de cada departamento.';
comment on table hospital is 'Hospitales de la cadena Hospitales de Occidente.';
comment on table unidad_medica is 'Unidades de atención de cada hospital: Consulta Externa, Emergencias, Cirugía y Hospitalización.';
comment on table servicio_atencion is 'Tipo de atención médica que ofrece cada unidad, con su costo.';
comment on table camilla is 'Camillas de las unidades de Emergencias y Hospitalización.';
comment on table quirofano is 'Quirófanos de la unidad de Cirugía.';
comment on table especialidad is 'Especialidades médicas clínicas y quirúrgicas.';
comment on table medico is 'Médicos de la cadena; los externos solo llegan a operar.';
comment on table enfermero is 'Enfermeros registrados y practicantes de enfermería.';
comment on table turno_emergencia is 'Turnos de 12 horas de la unidad de Emergencias.';
comment on table turno_medico is 'Médicos asignados a cada turno de emergencia.';
comment on table insumo is 'Insumos médicos y quirúrgicos con su inventario.';
comment on table instrumento is 'Instrumental médico y quirúrgico.';
comment on table equipo is 'Equipos médicos y quirúrgicos.';
comment on table medicamento is 'Medicamentos que se pueden recetar.';
comment on table diagnostico is 'Diagnósticos de la Clasificación Internacional de Enfermedades (CIE-10).';
comment on table estado_civil is 'Catálogo de estados civiles.';
comment on table parentesco is 'Catálogo de parentescos entre paciente y encargado.';
comment on table paciente is 'Pacientes atendidos en la red.';
comment on table encargado is 'Personas responsables de un paciente.';
comment on table paciente_encargado is 'Encargados de cada paciente y su parentesco.';
comment on table cita is 'Citas programadas de consulta externa.';
comment on table consulta is 'Consulta realizada en una cita.';
comment on table receta is 'Receta entregada al final de la consulta.';
comment on table receta_medicamento is 'Medicamentos prescritos en cada receta.';
comment on table ingreso is 'Ficha de ingreso a Emergencias, Cirugía u Hospitalización.';
comment on table egreso is 'Ficha de egreso que cierra un ingreso.';
comment on table egreso_diagnostico is 'Diagnósticos secundarios de cada egreso.';
comment on table institucion_externa is 'Hospitales y establecimientos fuera de la cadena que reciben traslados.';
comment on table traslado is 'Ficha de traslado de un paciente entre unidades o hacia fuera de la red.';
comment on table tipo_anestesia is 'Catálogo de tipos de anestesia.';
comment on table tipo_cirugia is 'Procedimientos quirúrgicos que ofrece la red.';
comment on table aspecto_quirurgico is 'Aspectos que el enfermero verifica en cada etapa de la cirugía.';
comment on table rol_quirurgico is 'Rol que cumple cada persona del equipo quirúrgico.';
comment on table agendamiento_quirurgico is 'Solicitud de cirugía que el cirujano envía al comité médico.';
comment on table requerimiento_insumo is 'Insumos que solicita el cirujano en el agendamiento.';
comment on table requerimiento_instrumento is 'Instrumental que solicita el cirujano en el agendamiento.';
comment on table requerimiento_equipo is 'Equipos que solicita el cirujano en el agendamiento.';
comment on table historia_clinica is 'Interrogatorio y exploración física del paciente antes de la cirugía.';
comment on table consentimiento_informado is 'Consentimiento informado firmado para la cirugía.';
comment on table chequeo_preanestesico is 'Evaluación del riesgo anestésico (ASA) y plan de anestesia.';
comment on table cirugia is 'Cirugía realizada a partir de un agendamiento aprobado.';
comment on table cirugia_personal is 'Médicos y enfermeros que participan en la cirugía.';
comment on table registro_procedimiento is 'Resultado de cada aspecto verificado durante la cirugía.';
comment on table documentacion_etapa is 'Documentación de cada etapa de la cirugía enviada a secretaría.';
comment on table cirugia_insumo is 'Insumos usados en la cirugía.';
comment on table hospitalizacion_insumo is 'Insumos usados durante un internamiento.';
comment on table metodo_pago is 'Métodos de pago aceptados.';
comment on table factura is 'Factura emitida al terminar una consulta, emergencia, hospitalización o cirugía.';
comment on table pago is 'Pago de una cuota de la factura.';
comment on table calificacion is 'Calificación de la calidad del servicio de un hospital, médico, enfermero o encargado.';

-- ============================================================
-- columnas (excepto PK y FK)
-- ============================================================

-- geografia y hospital
comment on column departamento.nombre is 'Nombre del departamento.';
comment on column municipio.nombre is 'Nombre del municipio.';
comment on column hospital.nombre is 'Nombre del hospital.';
comment on column hospital.informacion_especifica is 'Información específica del hospital (nivel, capacidad, especialización).';
comment on column hospital.direccion is 'Dirección del hospital.';
comment on column unidad_medica.tipo_unidad is 'Tipo de unidad: Consulta Externa, Emergencias, Cirugía u Hospitalización.';
comment on column unidad_medica.costo_dia_hospitalizacion is 'Costo por día internado; solo aplica a Hospitalización.';
comment on column servicio_atencion.nombre is 'Nombre del servicio de atención.';
comment on column servicio_atencion.costo is 'Costo del servicio en quetzales.';
comment on column camilla.numero is 'Número de la camilla dentro de su unidad.';
comment on column camilla.disponible is 'Indica si la camilla está libre.';
comment on column quirofano.numero is 'Número del quirófano dentro de la unidad de cirugía.';
comment on column quirofano.estado is 'Estado: disponible, ocupado o en_mantenimiento.';

-- personal
comment on column especialidad.nombre is 'Nombre de la especialidad.';
comment on column especialidad.tipo is 'clinica (consulta) o quirurgica (cirugía).';
comment on column medico.nombres is 'Nombres del médico.';
comment on column medico.apellidos is 'Apellidos del médico.';
comment on column medico.dpi is 'Documento Personal de Identificación (CUI de 13 dígitos).';
comment on column medico.telefono is 'Teléfono de contacto.';
comment on column medico.area is 'Área de residencia: Urbana o Rural.';
comment on column medico.tipo_medico is 'Modalidad: general, especialista, residente, interno o externo.';
comment on column medico.costo_primera_consulta is 'Costo de la primera consulta; base para reconsultas y referidos.';
comment on column medico.horario_inicio is 'Inicio del horario de consulta externa (turno matutino).';
comment on column medico.horario_fin is 'Fin del horario de consulta externa.';
comment on column enfermero.nombres is 'Nombres del enfermero.';
comment on column enfermero.apellidos is 'Apellidos del enfermero.';
comment on column enfermero.dpi is 'Documento Personal de Identificación (CUI de 13 dígitos).';
comment on column enfermero.telefono is 'Teléfono de contacto.';
comment on column enfermero.tipo is 'registrado o practicante.';
comment on column turno_emergencia.fecha is 'Fecha en que inicia el turno.';
comment on column turno_emergencia.jornada is 'diurno (07:00-19:00) o nocturno (19:00-07:00).';

-- recursos
comment on column insumo.nombre is 'Nombre del insumo.';
comment on column insumo.descripcion is 'Descripción del insumo.';
comment on column insumo.material is 'Material del que está hecho.';
comment on column insumo.tipo is 'medico, quirurgico u otro.';
comment on column insumo.unidad_medida is 'Unidad en que se despacha (caja, unidad, bolsa...).';
comment on column insumo.costo_unitario is 'Costo actual por unidad.';
comment on column insumo.stock_minimo is 'Existencia mínima antes de reabastecer.';
comment on column insumo.stock_actual is 'Existencia actual en inventario.';
comment on column instrumento.nombre is 'Nombre del instrumento.';
comment on column instrumento.descripcion is 'Descripción del instrumento.';
comment on column instrumento.tipo is 'medico, quirurgico u otro.';
comment on column instrumento.funcion is 'corte, contencion, hemostatica, retractor, accesorio, implante u otro.';
comment on column instrumento.estado is 'disponible, en_uso o en_mantenimiento.';
comment on column equipo.nombre is 'Nombre del equipo.';
comment on column equipo.descripcion is 'Descripción del equipo.';
comment on column equipo.tipo is 'medico, quirurgico u otro.';
comment on column equipo.funcion is 'exploracion, diagnostico, tratamiento, rehabilitacion u otro.';
comment on column equipo.estado is 'disponible, en_uso o en_mantenimiento.';
comment on column medicamento.nombre_generico is 'Nombre genérico (principio activo).';
comment on column medicamento.concentracion is 'Concentración por unidad (ej. 50 mg).';
comment on column medicamento.forma_farmaceutica is 'Presentación: tableta, cápsula, jarabe, inyectable...';
comment on column diagnostico.codigo_cie10 is 'Código CIE-10 del diagnóstico.';
comment on column diagnostico.descripcion is 'Descripción oficial del diagnóstico.';

-- pacientes
comment on column estado_civil.nombre is 'Estado civil.';
comment on column parentesco.nombre is 'Parentesco o relación con el paciente.';
comment on column paciente.numero_expediente is 'Número de expediente clínico del paciente.';
comment on column paciente.nombres is 'Nombres del paciente.';
comment on column paciente.apellidos is 'Apellidos del paciente.';
comment on column paciente.fecha_nacimiento is 'Fecha de nacimiento; la edad se calcula con fn_edad.';
comment on column paciente.sexo is 'Masculino o Femenino.';
comment on column paciente.dpi is 'CUI de 13 dígitos; opcional para menores de edad.';
comment on column paciente.telefono is 'Teléfono de contacto.';
comment on column paciente.area is 'Área de residencia: Urbana o Rural.';
comment on column paciente.numero_seguro_social is 'Número de afiliación al seguro social, si tiene.';
comment on column encargado.nombres is 'Nombres del encargado.';
comment on column encargado.apellidos is 'Apellidos del encargado.';
comment on column encargado.dpi is 'CUI de 13 dígitos.';
comment on column encargado.telefono is 'Teléfono de contacto.';
comment on column encargado.area is 'Área de residencia: Urbana o Rural.';

-- consulta externa
comment on column cita.fecha_hora is 'Fecha y hora de la cita.';
comment on column cita.numero_clinica is 'Clínica o consultorio donde se atiende.';
comment on column cita.medio_asignacion is 'Medio por el que se asignó: teléfono, correo, recepción general o del médico.';
comment on column cita.estado is 'programada, realizada, reprogramada o cancelada.';
comment on column cita.es_reconsulta is 'Indica si es reconsulta (cuesta 75% de la primera consulta).';
comment on column cita.es_referido is 'Indica si el paciente fue referido por una institución (cuesta 80%).';
comment on column cita.cancelada_sin_aviso is 'Indica si se canceló sin avisar (sobrecargo de 10% en la siguiente cita).';
comment on column cita.costo_base is 'Costo de primera consulta del médico al momento de agendar.';
comment on column cita.costo_final is 'Costo cobrado después de aplicar las reglas de descuento o sobrecargo.';
comment on column consulta.otros_datos is 'Otros datos de interés clínico.';
comment on column consulta.notas_observaciones is 'Notas u observaciones del médico.';
comment on column receta.fecha_proxima_cita is 'Fecha sugerida para la próxima cita de seguimiento.';
comment on column receta_medicamento.dosis is 'Dosis indicada.';
comment on column receta_medicamento.duracion is 'Duración del tratamiento.';

-- fichas
comment on column ingreso.fecha_hora_ingreso is 'Fecha y hora del ingreso.';
comment on column ingreso.motivo_ingreso is 'Motivo por el que ingresa el paciente.';
comment on column ingreso.diagnostico_presuntivo is 'Diagnóstico presuntivo de ingreso.';
comment on column ingreso.prioridad_triage is 'Prioridad de atención en emergencias: 1 la más urgente, 5 la menos.';
comment on column ingreso.turnos_espera is 'Turnos que esperó por falta de camilla libre (solo emergencias).';
comment on column egreso.fecha_hora_egreso is 'Fecha y hora del egreso.';
comment on column egreso.motivo_egreso is 'Motivo del egreso.';
comment on column egreso.codigo_egreso is 'Condición de salida: vivo, muerto, embarazo o parto.';
comment on column egreso.sin_consentimiento is 'Indica si el paciente salió sin consentimiento médico.';
comment on column egreso.motivo_sin_consentimiento is 'Motivo del egreso sin consentimiento.';
comment on column egreso.codigo_traslado is 'Código de traslado, si el egreso fue por traslado.';
comment on column egreso.referido_otro_hospital is 'Indica si fue referido a otro hospital o establecimiento.';
comment on column institucion_externa.nombre is 'Nombre de la institución.';
comment on column institucion_externa.direccion is 'Dirección de la institución.';
comment on column traslado.fecha_hora is 'Fecha y hora del traslado.';
comment on column traslado.tipo_traslado is 'interno (dentro de la red) o externo (fuera de la red).';

-- cirugia
comment on column tipo_anestesia.nombre is 'Tipo de anestesia.';
comment on column tipo_cirugia.nombre is 'Nombre del procedimiento quirúrgico.';
comment on column aspecto_quirurgico.etapa is 'preoperatorio, intraoperatorio o postoperatorio.';
comment on column aspecto_quirurgico.seccion is 'Sección de la etapa (Planificación, Entrada, Pausa quirúrgica...).';
comment on column aspecto_quirurgico.nombre is 'Aspecto que se verifica.';
comment on column aspecto_quirurgico.tipo_evaluacion is 'exito_falla o aceptabilidad.';
comment on column rol_quirurgico.nombre is 'Nombre del rol.';
comment on column rol_quirurgico.tipo_personal is 'Quién cumple el rol: medico o enfermero.';
comment on column agendamiento_quirurgico.caracter is 'urgente o programado.';
comment on column agendamiento_quirurgico.resumen_clinico is 'Resumen de la historia clínica que justifica la cirugía.';
comment on column agendamiento_quirurgico.tiempo_estimado_min is 'Tiempo estimado de la intervención en minutos.';
comment on column agendamiento_quirurgico.fecha_hora_solicitud is 'Fecha y hora en que se envió la solicitud.';
comment on column agendamiento_quirurgico.estado_solicitud is 'Decisión del comité: pendiente, aprobada o rechazada.';
comment on column agendamiento_quirurgico.motivo_rechazo is 'Razones del rechazo (base de cirugías rechazadas).';
comment on column agendamiento_quirurgico.fecha_hora_agendada is 'Fecha y hora asignadas al aprobarse.';
comment on column requerimiento_insumo.cantidad is 'Cantidad solicitada.';
comment on column requerimiento_instrumento.cantidad is 'Cantidad solicitada.';
comment on column requerimiento_equipo.cantidad is 'Cantidad solicitada.';
comment on column historia_clinica.fecha is 'Fecha de elaboración.';
comment on column historia_clinica.fuente_interrogatorio is 'directo (del paciente) o indirecto (de un familiar o amigo).';
comment on column historia_clinica.religion is 'Religión del paciente.';
comment on column historia_clinica.ocupacion is 'Ocupación del paciente.';
comment on column historia_clinica.lugar_nacimiento is 'Lugar de nacimiento.';
comment on column historia_clinica.lugar_residencia is 'Lugar de residencia.';
comment on column historia_clinica.antecedentes_heredofamiliares is 'Antecedentes heredofamiliares.';
comment on column historia_clinica.antecedentes_personales_no_patologicos is 'Antecedentes personales no patológicos.';
comment on column historia_clinica.antecedentes_patologicos is 'Antecedentes patológicos.';
comment on column historia_clinica.padecimiento_actual is 'Padecimiento actual.';
comment on column historia_clinica.interrogatorio_aparatos_sistemas is 'Interrogatorio por aparatos y sistemas.';
comment on column historia_clinica.sintomas_generales_terapeutica is 'Síntomas generales y terapéutica empleada.';
comment on column historia_clinica.estudios_previos is 'Estudios previos.';
comment on column historia_clinica.signos_vitales is 'Signos vitales.';
comment on column historia_clinica.exploracion_general is 'Exploración general.';
comment on column historia_clinica.exploracion_sistematizada is 'Exploración de cabeza, cuello, tórax, abdomen, extremidades, columna y cavidades.';
comment on column consentimiento_informado.procedimiento_nombre is 'Nombre específico del procedimiento.';
comment on column consentimiento_informado.procedimiento_objetivo is 'Objetivo del procedimiento.';
comment on column consentimiento_informado.procedimiento_caracteristicas is 'Características del procedimiento.';
comment on column consentimiento_informado.procedimiento_riesgos is 'Posibles riesgos del procedimiento.';
comment on column consentimiento_informado.medico_firmo is 'Indica si el médico firmó.';
comment on column consentimiento_informado.firmante_nombre is 'Nombre de quien firma por el paciente.';
comment on column consentimiento_informado.firmante_relacion is 'paciente, familiar, tutor o representante_legal.';
comment on column consentimiento_informado.firmante_firmo is 'Indica si el paciente o su representante firmó.';
comment on column consentimiento_informado.fecha_obtencion is 'Fecha en que se obtuvo el consentimiento.';
comment on column chequeo_preanestesico.clasificacion_asa is 'Clasificación ASA del riesgo anestésico (I a VI).';
comment on column chequeo_preanestesico.plan_anestesia is 'Plan de anestesia.';
comment on column cirugia.fecha_hora_inicio is 'Inicio de la cirugía.';
comment on column cirugia.fecha_hora_fin is 'Fin de la cirugía.';
comment on column cirugia.estado is 'preoperatorio, intraoperatorio, postoperatorio o finalizada.';
comment on column cirugia.condicion_evolucion is 'sin_complicaciones, complicaciones o complicaciones_graves.';
comment on column registro_procedimiento.resultado is 'exito/falla, o aceptable/medianamente_aceptable/no_aceptable.';
comment on column registro_procedimiento.descripcion is 'Descripción de lo observado.';
comment on column registro_procedimiento.fecha_hora_registro is 'Hora en que se registró.';
comment on column documentacion_etapa.etapa is 'Etapa documentada.';
comment on column documentacion_etapa.fecha_envio is 'Fecha de envío a secretaría.';
comment on column cirugia_insumo.cantidad is 'Cantidad usada.';
comment on column cirugia_insumo.costo_unitario is 'Costo por unidad al momento de usarlo.';

-- hospitalizacion, facturacion y calificaciones
comment on column hospitalizacion_insumo.cantidad is 'Cantidad usada durante el internamiento.';
comment on column hospitalizacion_insumo.costo_unitario is 'Costo por unidad al momento de usarlo.';
comment on column metodo_pago.nombre is 'Método de pago.';
comment on column factura.fecha_emision is 'Fecha y hora de emisión.';
comment on column factura.descripcion is 'Descripción breve de los servicios facturados.';
comment on column factura.total is 'Monto total en quetzales.';
comment on column factura.numero_cuotas is 'Número de cuotas mensuales del plan de pago (1 a 12).';
comment on column pago.numero_cuota is 'Número de cuota que se paga.';
comment on column pago.monto is 'Monto pagado.';
comment on column pago.fecha_pago is 'Fecha del pago.';
comment on column calificacion.fecha is 'Fecha de la calificación.';
comment on column calificacion.puntuacion is 'Puntuación de 1 (peor) a 5 (mejor).';
comment on column calificacion.comentario is 'Comentario opcional.';
