-- ============================================================
-- 04_fichas.sql : ingresos, egresos y traslados
-- ============================================================

SET search_path TO public;

-- Ingresos a unidades (emergencias, cirugía y hospitalización)
INSERT INTO ingreso (id_ingreso, paciente_id, unidad_id, servicio_id, camilla_id, motivo_ingreso, fecha_hora_ingreso, medico_encargado_id, diagnostico_presuntivo) VALUES
(1, 3, 12, 3, 111, 'Politraumatismo por accidente de tránsito.', '2026-08-09 22:10:00-06', 1001, 'Traumatismo craneoencefálico leve; fractura de brazo derecho.'),
(2, 4, 12, 5, 112, 'Fiebre alta persistente y deshidratación.', '2026-08-20 14:05:00-06', 1005, 'Cuadro febril viral en observación.'),
(3, 2, 14, 9, 121, 'Hipertensión arterial descompensada.', '2026-08-14 11:00:00-06', 1005, 'Crisis hipertensiva en estudio.'),
(4, 5, 13, 17, NULL, 'Ingreso a quirófano para apendicectomía de urgencia.', '2026-08-11 18:35:00-06', 1006, 'Apendicitis aguda.'),
(5, 5, 14, 15, 123, 'Sala de recuperación postquirúrgica tras apendicectomía.', '2026-08-11 21:00:00-06', 1006, 'Postoperatorio de apendicectomía.');

-- Egresos (uno por ingreso completado)
INSERT INTO egreso (id_egreso, ingreso_id, diagnostico_principal, diagnosticos_secundarios, motivo_egreso, unidad_id, servicio_id, fecha_hora_egreso, medico_id, camilla_id, codigo_egreso, egreso_sin_consentimiento, motivo_egreso_sin_consentimiento, dias_hospitalizado, codigo_traslado, referido_otro_hospital) VALUES
(1, 1, 'Politraumatismo; fractura de brazo derecho.', 'Traumatismo craneoencefálico leve.', 'Mejoría clínica.', 12, 3, '2026-08-12 10:00:00-06', 1001, 111, 'vivo', FALSE, NULL, 3, NULL, FALSE),
(2, 3, 'Hipertensión arterial descompensada controlada.', NULL, 'Estabilización y mejoría.', 14, 9, '2026-08-18 09:30:00-06', 1005, 121, 'vivo', FALSE, NULL, 4, NULL, FALSE),
(3, 5, 'Postoperatorio de apendicectomía sin complicaciones.', NULL, 'Recuperación satisfactoria.', 14, 15, '2026-08-14 11:30:00-06', 1006, 123, 'vivo', FALSE, NULL, 3, NULL, FALSE);

-- Traslados (consulta externa -> cirugía; cirugía -> hospitalización; externo a otra institución)
INSERT INTO traslado (id_traslado, fecha_hora, paciente_id, medico_indica_id, unidad_origen_id, unidad_destino_id, interno_externo, hospital_externo_nombre, hospital_externo_direccion, ingreso_id, consulta_id) VALUES
(1, '2026-08-11 10:00:00-06', 5, 1005, 11, 13, 'interno', NULL, NULL, NULL, 2),
(2, '2026-08-11 21:30:00-06', 5, 1006, 13, 14, 'interno', NULL, NULL, 4, NULL),
(3, '2026-08-21 08:00:00-06', 4, 1005, 12, 25, 'externo', 'Hospital Regional de San Marcos', '7a. calle 4-10, zona 2, San Marcos', 2, NULL);