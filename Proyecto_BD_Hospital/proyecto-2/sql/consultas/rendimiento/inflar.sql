-- Proyecto 2 - Objetivo 17, medicion de rendimiento
-- inflar.sql : agrega medicos, citas, consultas y calificaciones de prueba a
-- una COPIA de la base (nunca a la base entregada).
--
-- Variables de psql: :medicos y :calificaciones (una por consulta).
-- Los datos pasan por los mismos disparadores y restricciones que los reales.

begin;
set search_path to public;

insert into personal (id_personal, tipo_personal, nombres, apellidos, dpi, direccion, id_municipio, area,
                      id_hospital, fecha_contratacion, salario, nivel_acceso)
select 100000 + k, 'medico', 'Médico', 'Prueba ' || k, '9' || lpad(k::text, 12, '0'), 'Dirección de prueba', 1, 'Urbana',
       1 + k % 5, date '2020-01-01', 10000.00, 'operativo'
  from generate_series(1, :medicos) k;

insert into medico (id_medico, id_especialidad, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin)
select 100000 + k, 307, 'general', 150.00, '08:00', '12:00'
  from generate_series(1, :medicos) k;

insert into cita (id_cita, id_paciente, id_medico, fecha_hora, numero_clinica, medio_asignacion, estado, costo_base, costo_final)
select 1000000 + k, 1 + k % 67, 100001 + k % :medicos,
       timestamptz '2026-02-01 09:00-06' + (k % 240) * interval '1 day',
       'P-1', 'telefonico', 'realizada', 150.00, 150.00
  from generate_series(1, :calificaciones) k;

insert into consulta (id_consulta, id_cita, id_diagnostico)
select id_cita, id_cita, 18 from cita where id_cita > 1000000;

insert into calificacion (id_paciente, fecha, puntuacion, id_medico, id_consulta)
select ci.id_paciente, ci.fecha_hora::date, 1 + (ci.id_cita * 7 + ci.id_medico) % 5, ci.id_medico, ci.id_cita
  from cita ci where ci.id_cita > 1000000;

commit;
analyze;
