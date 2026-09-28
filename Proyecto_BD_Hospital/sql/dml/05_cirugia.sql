-- ============================================================
-- 05_cirugia.sql : agendamiento, pre/intra/postoperatorio y recursos
-- ============================================================

SET search_path TO public;

-- Agendamientos quirúrgicos (solicitudes al comité)
INSERT INTO agendamiento_quirurgico (id_agendamiento, paciente_id, medico_cirujano_id, caracter, historia_clinica, tipo_procedimiento, tiempo_estimado_min, tipo_anestesia, fecha_hora_solicitud, estado_solicitud, motivo_rechazo, quirofano_solicitado_id, fecha_hora_agendada) VALUES
(1, 5, 1006, 'urgente', 'Apendicitis aguda confirmada por ecografía.', 'Apendicectomía abierta', 90, 'General', '2026-08-11 11:00:00-06', 'aprobada', NULL, 2, '2026-08-11 18:30:00-06'),
(2, 7, 1009, 'programado', 'Carcinoma colorrectal en estudio.', 'Resección oncológica de colon', 160, 'General', '2026-08-13 09:00:00-06', 'rechazada', 'El comité recomienda completar estudios de imagen y control nutricional previo a la intervención.', 3, NULL),
(3, 6, 1007, 'programado', 'Enfermedad valvular aórtica con estenosis severa.', 'Revascularización miocárdica', 180, 'General', '2026-09-08 10:00:00-06', 'pendiente', NULL, NULL, NULL);

-- Historia clínica del agendamiento aprobado (interrogatorio + exploración física)
INSERT INTO historia_clinica (id_historia_clinica, agendamiento_id, medico_id, fecha, fuente_interrogatorio, religion, ocupacion, lugar_nacimiento, lugar_residencia, antecedentes_heredofamiliares, antecedentes_personales_no_patologicos, antecedentes_patologicos, padecimiento_actual, interrogatorio_aparatos_sistemas, sintomas_generales_terapeutica, estudios_previos, signos_vitales, exploracion_general, exploracion_sistematizada) VALUES
(1, 1, 1006, '2026-08-11', 'directo', 'Católica', 'Comerciante', 'Olintepeque, Quetzaltenango', 'Olintepeque, Quetzaltenango',
 'Cardiopatía isquémica en padre; hipertensión en madre.',
 'No fumador; consumo de alcohol ocasional; alimentación sin restricciones.',
 'Ninguno conocido.',
 'Dolor abdominal en fosa ilíaca derecha desde hace 8 horas, con náuseas.',
 'Dolor intenso localizado, sin irradiación.',
 'Paciente no había iniciado antibióticos previo a consulta.',
 'Ecografía abdominal: líquido libre y engrosamiento apendicular.',
 'TA 120/80, FC 92, T° 37.8.',
 'Abdomen blando, doloroso a palpación en fosa ilíaca derecha.',
 'Cabeza y cuello sin alteraciones; tórax y abdomen según lo referido; extremidades sin déficit motor.');

-- Consentimiento informado del agendamiento aprobado
INSERT INTO consentimiento_informado (id_consentimiento, agendamiento_id, procedimiento_nombre, procedimiento_objetivo, procedimiento_caracteristicas, procedimiento_riesgos, medico_nombre, medico_firmado, paciente_firma_nombre, paciente_firmado, fecha_obtencion) VALUES
(1, 1, 'Apendicectomía abierta',
 'Resección del apéndice inflamado para evitar perforación y peritonitis.',
 'Incisión en fosa ilíaca derecha, ligadura y extirpación del apéndice, cierre por planos, bajo anestesia general.',
 'Sangrado, infección de herida, lesión de estructuras vecinas, complicaciones anestésicas.',
 'Alejandro Ramírez Lemus', TRUE, 'Carlos De León Ortiz', TRUE, '2026-08-11');

-- Chequeo preanestésico (clasificación ASA y plan)
INSERT INTO chequeo_preanestesico (id_chequeo_preanestesico, agendamiento_id, clasificacion_asa, medico_asa_nombre, plan_anestesia, anestesista_nombre) VALUES
(1, 1, 'II', 'Alejandro Ramírez Lemus', 'Inducción con propofol, mantenimiento con sevoflurano, analgesia con morfina.',
 'Daniel Morales Peña');

-- Cirugía ejecutada del agendamiento aprobado
INSERT INTO cirugia (id_cirugia, agendamiento_id, quirofano_id, paciente_id, cirujano_id, ingreso_id, fecha_hora_inicio, fecha_hora_fin, condicion_evolucion, estado) VALUES
(1, 1, 2, 5, 1006, 4, '2026-08-11 18:40:00-06', '2026-08-11 20:10:00-06', 'sin_complicaciones', 'finalizada');

-- Registros de procedimiento realizados por el enfermero encargado (éxito/falla y hora de registro)
INSERT INTO registro_procedimiento (id_registro_procedimiento, cirugia_id, etapa, aspecto, exito, descripcion, hora_registro, enfermero_id, fecha_documentacion) VALUES
(1, 1, 'preoperatorio', 'planificacion', TRUE, 'Tabla quirúrgica disponible, equipos y quirófano preparados.', '2026-08-11 18:15:00-06', 2001, '2026-08-12'),
(2, 1, 'preoperatorio', 'entrada', TRUE, 'Paciente identificado con brazalete; ficha clínica y consentimiento firmado verificados.', '2026-08-11 18:38:00-06', 2001, '2026-08-12'),
(3, 1, 'intraoperatorio', 'chequeo_quirofano', TRUE, 'Equipo quirúrgico completo; traslado y posicionamiento correctos.', '2026-08-11 18:45:00-06', 2002, '2026-08-12'),
(4, 1, 'intraoperatorio', 'pausa_quirurgica', TRUE, 'Paciente y procedimiento confirmados; condiciones de esterilidad adecuadas.', '2026-08-11 18:50:00-06', 2002, '2026-08-12'),
(5, 1, 'intraoperatorio', 'balance_hidrico', TRUE, 'Balance hídrico registrado sin alteraciones.', '2026-08-11 19:10:00-06', 2002, '2026-08-12'),
(6, 1, 'intraoperatorio', 'salida_quirurgica', TRUE, 'Conteo de instrumental satisfactorio; cierre de incisión.', '2026-08-11 20:05:00-06', 2002, '2026-08-12'),
(7, 1, 'postoperatorio', 'ingreso_sala_recuperacion', TRUE, 'Ingreso a sala de recuperación con evolución sin complicaciones.', '2026-08-11 20:25:00-06', 2003, '2026-08-12'),
(8, 1, 'postoperatorio', 'traslado_seguro', TRUE, 'Signos vitales normales; zona operatoria limpia; documentación completa.', '2026-08-11 21:15:00-06', 2003, '2026-08-12');

-- Requerimientos del agendamiento (insumos, instrumentos y equipos solicitados)
INSERT INTO requerimiento_quirurgico (id_requerimiento, agendamiento_id, tipo_recurso, insumo_id, instrumento_id, equipo_id, cantidad) VALUES
(1, 1, 'instrumento', NULL, 1, NULL, 1),
(2, 1, 'insumo', 6, NULL, NULL, 2),
(3, 1, 'equipo', NULL, NULL, 1, 1),
(4, 2, 'equipo', NULL, NULL, 3, 1),
(5, 2, 'instrumento', NULL, 3, NULL, 4);

-- Personal que intervino en la cirugía (médicos, enfermeros y practicantes)
INSERT INTO cirugia_personal (id_cirugia_personal, cirugia_id, medico_id, enfermero_id, rol) VALUES
(1, 1, 1006, NULL, 'Cirujano'),
(2, 1, 1008, NULL, 'Anestesiólogo'),
(3, 1, NULL, 2001, 'Enfermero instrumentista'),
(4, 1, NULL, 2003, 'Enfermero circulante');

-- Insumos efectivamente utilizados durante la operación (contribuyen al costo de la cirugía)
INSERT INTO cirugia_insumo (id_cirugia_insumo, cirugia_id, insumo_id, cantidad, costo_unitario) VALUES
(1, 1, 1, 2, 30.00),
(2, 1, 2, 1, 25.00),
(3, 1, 4, 10, 8.00),
(4, 1, 5, 8, 15.00),
(5, 1, 6, 2, 120.00),
(6, 1, 7, 3, 70.00);