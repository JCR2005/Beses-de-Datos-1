-- Proyecto 1 - BD Hospitales de Occidente
-- 04_consulta_externa.sql : citas, consultas y recetas (datos FICTICIOS)

set search_path to public;

-- reglas de costo: reconsulta 75%, referido 80%, sobrecargo de 10% por cancelar sin aviso
insert into cita (id_cita, id_paciente, id_medico, fecha_hora, numero_clinica, medio_asignacion, estado, es_reconsulta, es_referido, cancelada_sin_aviso, costo_base, costo_final) values
(1, 1, 1002, '2026-08-10 09:00-06', 'A-101', 'telefonico', 'realizada', true, false, false, 220.00, 165.00),
(2, 2, 1003, '2026-08-12 10:30-06', 'A-205', 'recepcion_general', 'reprogramada', false, false, false, 160.00, 160.00),
(3, 4, 1004, '2026-08-15 08:30-06', 'B-110', 'telefonico', 'cancelada', false, false, true, 180.00, 198.00),
(4, 6, 1002, '2026-09-20 09:30-06', 'A-101', 'correo_institucional', 'programada', false, true, false, 220.00, 176.00),
(5, 5, 1005, '2026-08-11 09:15-06', 'A-108', 'recepcion_medico', 'realizada', false, false, false, 180.00, 180.00);

-- consultas de las citas realizadas
insert into consulta (id_consulta, id_cita, id_diagnostico, otros_datos, notas_observaciones) values
(1, 1, 1, 'Seguimiento a estudio cardiológico de 2025.', 'Paciente estable; continuar tratamiento y control en 30 días.'),
(2, 5, 2, 'Dolor abdominal en fosa ilíaca derecha de más de 6 horas.', 'Se solicita valoración quirúrgica de urgencia; requiere hospitalización.');

insert into receta (id_receta, id_consulta, fecha_proxima_cita) values
(1, 1, '2026-09-10'),
(2, 2, null);

insert into receta_medicamento (id_receta, id_medicamento, dosis, duracion) values
(1, 1, '1 tableta cada 12 horas', '30 días'),
(1, 2, '1 tableta en la mañana', '30 días'),
(2, 3, '1 tableta hasta cada 8 horas según dolor', '5 días');
