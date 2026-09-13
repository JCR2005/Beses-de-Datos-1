-- ============================================================
-- 03_consulta_externa.sql : citas, consultas y recetas
-- ============================================================

SET search_path TO public;

-- Citas programadas y su evolución (reglas: reconsulta 75%, referido 80%, sobrecargo 10% por cancelación sin aviso)
INSERT INTO cita (id_cita, paciente_id, medico_id, fecha_hora, num_clinica, medio_asignacion, estado, es_reconsulta, es_referido, costo_base, costo_aplicado, cancelada_sin_aviso) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 1002, '2026-08-10 09:00:00-06', 'A-101', 'telefonico', 'realizada', TRUE, FALSE, 220.00, 165.00, FALSE),
(2, 2, 1003, '2026-08-12 10:30:00-06', 'A-205', 'recepcion_general', 'reprogramada', FALSE, FALSE, 160.00, 160.00, FALSE),
(3, 4, 1004, '2026-08-15 08:30:00-06', 'B-110', 'telefonico', 'cancelada', FALSE, FALSE, 180.00, 198.00, TRUE),
(4, 6, 1002, '2026-09-20 09:30:00-06', 'A-101', 'correo_institucional', 'programada', FALSE, TRUE, 220.00, 176.00, FALSE),
(5, 5, 1005, '2026-08-11 09:15:00-06', 'A-108', 'recepcion_medico', 'realizada', FALSE, FALSE, 180.00, 180.00, FALSE);

-- Consultas realizadas (ficha de consulta del paciente)
INSERT INTO consulta (id_consulta, cita_id, paciente_id, medico_id, fecha, diagnostico, otros_datos, notas_observaciones) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 1, 1002, '2026-08-10', 'Hipertensión arterial controlada en tratamiento.', 'Seguimiento a estudio cardiológico de 2025.', 'Paciente estable; continuar tratamiento y control en 30 días.'),
(2, 5, 5, 1005, '2026-08-11', 'Sospecha de apendicitis aguda.', 'Dolor abdominal en fosa ilíaca derecha, mayor de 6 horas.', 'Se solicita valoración quirúrgica de urgencia; requiere hospitalización.');

-- Recetas y medicamentos prescritos
INSERT INTO receta (id_receta, consulta_id, fecha, proxima_cita) OVERRIDING SYSTEM VALUE VALUES
(1, 1, '2026-08-10', '2026-09-10'),
(2, 2, '2026-08-11', NULL);

INSERT INTO receta_medicamento (id_receta_medicamento, receta_id, medicamento_nombre, dosis, duracion) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 'Metoprolol 50 mg', '1 tableta cada 12 horas', '30 días'),
(2, 1, 'Losartán 50 mg', '1 tableta en la mañana', '30 días'),
(3, 2, 'Tramadol 50 mg (dolor)', '1 tableta hasta cada 8 horas según dolor', '5 días');