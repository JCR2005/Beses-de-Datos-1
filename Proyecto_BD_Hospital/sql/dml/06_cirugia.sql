-- Proyecto 1 - BD Hospitales de Occidente
-- 06_cirugia.sql : agendamientos, preoperatorio, cirugia y su registro (datos FICTICIOS)

set search_path to public;

-- solicitudes al comite: una aprobada, una rechazada y una pendiente
insert into agendamiento_quirurgico (id_agendamiento, id_paciente, id_medico_cirujano, id_tipo_cirugia, id_tipo_anestesia, caracter, resumen_clinico, tiempo_estimado_min, fecha_hora_solicitud, estado_solicitud, motivo_rechazo, id_quirofano_solicitado, fecha_hora_agendada) values
(1, 5, 1006, 1, 1, 'urgente', 'Apendicitis aguda confirmada por ecografía.', 90, '2026-08-11 11:00-06', 'aprobada', null, 2, '2026-08-11 18:30-06'),
(2, 7, 1009, 4, 1, 'programado', 'Carcinoma colorrectal en estudio.', 160, '2026-08-13 09:00-06', 'rechazada',
 'El comité recomienda completar estudios de imagen y control nutricional previo a la intervención.', 11, null),
(3, 6, 1007, 7, 1, 'programado', 'Enfermedad valvular aórtica con estenosis severa.', 180, '2026-09-08 10:00-06', 'pendiente', null, null, null);

-- recursos que pidio el cirujano en cada solicitud
insert into requerimiento_insumo (id_agendamiento, id_insumo, cantidad) values
(1, 6, 2);

insert into requerimiento_instrumento (id_agendamiento, id_instrumento, cantidad) values
(1, 1, 1),
(2, 3, 4);

insert into requerimiento_equipo (id_agendamiento, id_equipo, cantidad) values
(1, 1, 1),
(2, 3, 1);

-- historia clinica de la solicitud aprobada (interrogatorio + exploracion fisica)
insert into historia_clinica (id_historia_clinica, id_agendamiento, id_medico, fecha, fuente_interrogatorio, religion, ocupacion, lugar_nacimiento, lugar_residencia, antecedentes_heredofamiliares, antecedentes_personales_no_patologicos, antecedentes_patologicos, padecimiento_actual, interrogatorio_aparatos_sistemas, sintomas_generales_terapeutica, estudios_previos, signos_vitales, exploracion_general, exploracion_sistematizada) values
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

insert into consentimiento_informado (id_consentimiento, id_agendamiento, id_medico, procedimiento_nombre, procedimiento_objetivo, procedimiento_caracteristicas, procedimiento_riesgos, medico_firmo, firmante_nombre, firmante_relacion, firmante_firmo, fecha_obtencion) values
(1, 1, 1006, 'Apendicectomía abierta',
 'Resección del apéndice inflamado para evitar perforación y peritonitis.',
 'Incisión en fosa ilíaca derecha, ligadura y extirpación del apéndice, cierre por planos, bajo anestesia general.',
 'Sangrado, infección de herida, lesión de estructuras vecinas, complicaciones anestésicas.',
 true, 'Carlos De León Ortiz', 'paciente', true, '2026-08-11');

insert into chequeo_preanestesico (id_chequeo, id_agendamiento, clasificacion_asa, id_medico_clasifica, plan_anestesia, id_medico_anestesista) values
(1, 1, 'II', 1006, 'Inducción con propofol, mantenimiento con sevoflurano, analgesia con morfina.', 1008);

-- cirugia realizada para la solicitud aprobada
insert into cirugia (id_cirugia, id_agendamiento, id_quirofano, id_ingreso, fecha_hora_inicio, fecha_hora_fin, estado, condicion_evolucion) values
(1, 1, 2, 4, '2026-08-11 18:40-06', '2026-08-11 20:10-06', 'finalizada', 'sin_complicaciones');

insert into cirugia_personal (id_cirugia_personal, id_cirugia, id_medico, id_enfermero, id_rol) values
(1, 1, 1006, null, 1),
(2, 1, 1008, null, 3),
(3, 1, null, 2001, 4),
(4, 1, null, 2003, 5);

-- aspectos verificados por los enfermeros en cada etapa
insert into registro_procedimiento (id_registro, id_cirugia, id_aspecto, resultado, descripcion, fecha_hora_registro, id_enfermero) values
(1, 1, 1,  'exito', 'Tabla quirúrgica disponible, equipos y quirófano preparados.', '2026-08-11 18:15-06', 2001),
(2, 1, 4,  'exito', 'Paciente identificado con brazalete; ficha clínica y consentimiento verificados.', '2026-08-11 18:38-06', 2001),
(3, 1, 8,  'exito', 'Equipo quirúrgico completo; traslado y posicionamiento correctos.', '2026-08-11 18:45-06', 2002),
(4, 1, 13, 'exito', 'Paciente y procedimiento confirmados; condiciones de esterilidad adecuadas.', '2026-08-11 18:50-06', 2002),
(5, 1, 19, 'aceptable', 'Balance hídrico registrado sin alteraciones.', '2026-08-11 19:10-06', 2002),
(6, 1, 24, 'exito', 'Conteo de instrumental satisfactorio; cierre de incisión.', '2026-08-11 20:05-06', 2002),
(7, 1, 26, 'exito', 'Ingreso a sala de recuperación con evolución sin complicaciones.', '2026-08-11 20:25-06', 2003),
(8, 1, 35, 'exito', 'Signos vitales normales; zona operatoria limpia; documentación completa.', '2026-08-11 21:15-06', 2003);

-- documentacion de cada etapa enviada a secretaria
insert into documentacion_etapa (id_cirugia, etapa, id_enfermero, fecha_envio) values
(1, 'preoperatorio', 2001, '2026-08-12'),
(1, 'intraoperatorio', 2002, '2026-08-12'),
(1, 'postoperatorio', 2003, '2026-08-12');

-- insumos usados en la operacion (suman al costo de la cirugia)
insert into cirugia_insumo (id_cirugia, id_insumo, cantidad, costo_unitario) values
(1, 1, 2, 30.00),
(1, 2, 1, 25.00),
(1, 4, 10, 8.00),
(1, 5, 8, 15.00),
(1, 6, 2, 120.00),
(1, 7, 3, 70.00);
