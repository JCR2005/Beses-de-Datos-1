-- Proyecto 1 - BD Hospitales de Occidente
-- 05_fichas.sql : ingresos, egresos y traslados (datos FICTICIOS)

set search_path to public;

-- ingresos a emergencias (con turno y triage), cirugia (con quirofano) y hospitalizacion (con camilla)
insert into ingreso (id_ingreso, id_paciente, id_unidad, id_servicio, id_medico_encargado, id_camilla, id_quirofano, id_turno, fecha_hora_ingreso, motivo_ingreso, diagnostico_presuntivo, prioridad_triage, turnos_espera) values
(1, 3, 12, 3, 1001, 25, null, 1, '2026-08-09 22:10-06', 'Politraumatismo por accidente de tránsito.', 'Traumatismo craneoencefálico leve; fractura de brazo derecho.', 2, 0),
(2, 4, 12, 5, 1005, 26, null, 2, '2026-08-20 14:05-06', 'Fiebre alta persistente y deshidratación.', 'Cuadro febril viral en observación.', 3, 1),
(3, 2, 14, 9, 1005, 3, null, null, '2026-08-14 11:00-06', 'Hipertensión arterial descompensada.', 'Crisis hipertensiva en estudio.', null, null),
(4, 5, 13, 17, 1006, null, 2, null, '2026-08-11 18:35-06', 'Ingreso a quirófano para apendicectomía de urgencia.', 'Apendicitis aguda.', null, null),
(5, 5, 14, 15, 1006, 4, null, null, '2026-08-11 21:00-06', 'Sala de recuperación postquirúrgica tras apendicectomía.', 'Postoperatorio de apendicectomía.', null, null);

-- egresos de los ingresos que ya terminaron
insert into egreso (id_egreso, id_ingreso, id_medico, id_diagnostico_principal, fecha_hora_egreso, motivo_egreso, codigo_egreso) values
(1, 1, 1001, 3, '2026-08-12 10:00-06', 'Mejoría clínica.', 'vivo'),
(2, 3, 1005, 1, '2026-08-18 09:30-06', 'Estabilización y mejoría.', 'vivo'),
(3, 5, 1006, 2, '2026-08-14 11:30-06', 'Recuperación satisfactoria sin complicaciones.', 'vivo');

-- diagnosticos secundarios del politraumatismo: conmocion cerebral y fractura de humero
insert into egreso_diagnostico (id_egreso, id_diagnostico) values
(1, 5),
(1, 4);

-- consulta externa -> cirugia; cirugia -> hospitalizacion; emergencias H1 -> emergencias H2
insert into traslado (id_traslado, fecha_hora, id_medico_indica, id_consulta, id_ingreso, id_unidad_origen, tipo_traslado, id_unidad_destino, id_institucion_destino) values
(1, '2026-08-11 10:00-06', 1005, 2, null, 11, 'interno', 13, null),
(2, '2026-08-11 21:30-06', 1006, null, 4, 13, 'interno', 14, null),
(3, '2026-08-21 08:00-06', 1005, null, 2, 12, 'interno', 22, null);
