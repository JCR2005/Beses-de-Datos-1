-- Proyecto 1 - BD Hospitales de Occidente
-- 08_calificaciones.sql : calificaciones de la calidad del servicio (datos FICTICIOS)

set search_path to public;

insert into calificacion (id_calificacion, id_paciente, fecha, puntuacion, comentario, id_hospital, id_medico, id_enfermero, id_encargado, id_consulta) values
-- hospitales
(1, 1, '2026-08-10', 5, 'Atención puntual y ordenada.', 1, null, null, null, null),
(2, 3, '2026-08-12', 4, 'Buena atención en emergencias, espera corta.', 1, null, null, null, null),
(3, 2, '2026-08-18', 3, 'Habitación cómoda, pero demoras en los trámites.', 1, null, null, null, null),
-- medicos, ligados a la consulta cuando la atencion fue en consulta externa
(4, 1, '2026-08-10', 5, 'Explicó claramente el tratamiento.', null, 1002, null, null, 1),
(5, 5, '2026-08-11', 4, 'Detectó a tiempo la apendicitis.', null, 1005, null, null, 2),
(6, 5, '2026-08-14', 5, 'Cirugía sin complicaciones y buen seguimiento.', null, 1006, null, null, null),
(7, 3, '2026-08-12', 4, 'Atención rápida en emergencias.', null, 1001, null, null, null),
-- enfermeros
(8, 5, '2026-08-14', 5, 'Muy atento durante la recuperación.', null, null, 2003, null, null),
(9, 5, '2026-08-12', 4, null, null, null, 2001, null, null),
-- encargados
(10, 4, '2026-08-21', 4, 'Estuvo pendiente de todos los trámites de la paciente.', null, null, null, 301, null);
