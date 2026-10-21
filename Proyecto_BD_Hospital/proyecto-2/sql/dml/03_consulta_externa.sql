-- Proyecto 2 - BD Hospitales de Occidente
-- 03_consulta_externa.sql : citas, consultas, recetas y calificaciones de enero a octubre de 2026 (datos FICTICIOS)
--
-- Las filas se generan con formulas fijas sobre generate_series, asi que la
-- carga siempre produce los mismos datos. Rangos de id: citas 101-320; la
-- consulta y la receta usan el mismo id que su cita.

begin;
set role admin;
set search_path to public;

-- diagnosticos frecuentes en consulta externa (CIE-10)
insert into diagnostico (id_diagnostico, codigo_cie10, descripcion) values
(12, 'J06.9', 'Infección aguda de las vías respiratorias superiores, no especificada'),
(13, 'K29.7', 'Gastritis, no especificada'),
(14, 'M54.5', 'Lumbago no especificado'),
(15, 'L20.9', 'Dermatitis atópica, no especificada'),
(16, 'H10.9', 'Conjuntivitis, no especificada'),
(17, 'F41.1', 'Trastorno de ansiedad generalizada'),
(18, 'Z00.0', 'Examen médico general'),
(19, 'N39.0', 'Infección de vías urinarias, sitio no especificado');

-- ============================================================
-- citas: 220 repartidas entre los medicos con horario de consulta externa
-- ============================================================
-- estado: las futuras quedan programadas; de las pasadas 1 de cada 10 se
-- cancela y 1 de cada 10 se reprograma. Costo: reconsulta 75%, referido 80%.

insert into cita (id_cita, id_paciente, id_medico, fecha_hora, numero_clinica, medio_asignacion, estado,
                  es_reconsulta, es_referido, cancelada_sin_aviso, costo_base, costo_final)
select 100 + g.n,
       1 + (g.n * 7) % 67,
       m.id_medico,
       f.fecha_hora,
       'C-' || (100 + m.id_medico % 100),
       (array['telefonico','correo_institucional','recepcion_general','recepcion_medico'])[1 + g.n % 4],
       e.estado,
       g.n % 3 = 0,
       g.n % 3 <> 0 and g.n % 7 = 0,
       e.estado = 'cancelada' and g.n % 4 = 0,
       m.costo_primera_consulta,
       round(m.costo_primera_consulta * case when g.n % 3 = 0 then 0.75 when g.n % 7 = 0 then 0.80 else 1 end, 2)
  from generate_series(1, 220) g(n)
 cross join lateral (
        select id_medico, costo_primera_consulta, horario_inicio
          from medico
         where horario_inicio is not null
         order by id_medico
        offset (g.n * 5) % (select count(*) from medico where horario_inicio is not null)
         limit 1) m
 cross join lateral (
        select ((date '2026-01-05' + (g.n * 13) % 290) + m.horario_inicio + (g.n % 5) * interval '30 minutes')
               at time zone 'America/Guatemala' as fecha_hora) f
 cross join lateral (
        select case when f.fecha_hora > timestamptz '2026-10-20 23:59-06' then 'programada'
                    when g.n % 10 = 0 then 'cancelada'
                    when g.n % 10 = 5 then 'reprogramada'
                    else 'realizada' end as estado) e;

-- ============================================================
-- consultas, recetas y medicamentos de las citas realizadas
-- ============================================================

insert into consulta (id_consulta, id_cita, id_diagnostico, otros_datos, notas_observaciones)
select c.id_cita, c.id_cita, 1 + c.id_cita % 19,
       case when c.es_referido then 'Paciente referido por centro de salud.' end,
       case when c.es_reconsulta then 'Reconsulta de seguimiento; evolución favorable.'
            else 'Primera consulta; se indica tratamiento y control.' end
  from cita c
 where c.id_cita > 100 and c.estado = 'realizada';

-- 6 de cada 7 consultas terminan con receta; la mitad agenda proxima cita a 30 dias
insert into receta (id_receta, id_consulta, fecha_proxima_cita)
select co.id_consulta, co.id_consulta,
       case when co.id_consulta % 2 = 0 then ci.fecha_hora::date + 30 end
  from consulta co
  join cita ci on ci.id_cita = co.id_cita
 where co.id_consulta > 100 and co.id_consulta % 7 <> 0;

insert into receta_medicamento (id_receta, id_medicamento, dosis, duracion)
select r.id_receta, 1 + r.id_receta % 10, '1 cada 12 horas', (7 * (1 + r.id_receta % 4)) || ' días'
  from receta r where r.id_receta > 100
union all
select r.id_receta, 1 + (r.id_receta + 3) % 10, '1 cada 8 horas si hay dolor', '5 días'
  from receta r where r.id_receta > 100 and r.id_receta % 3 = 0;

-- ============================================================
-- calificaciones
-- ============================================================

-- 7 de cada 10 pacientes califican al medico que los atendio. Cada medico
-- tiene un nivel base distinto (1 a 5) para que el ranking tenga diferencias.
insert into calificacion (id_paciente, fecha, puntuacion, comentario, id_medico, id_consulta)
select ci.id_paciente, ci.fecha_hora::date,
       least(5, greatest(1, 1 + ci.id_medico % 5 + (co.id_consulta % 3) - 1)),
       case co.id_consulta % 4 when 0 then 'Muy buena explicación del tratamiento.'
                               when 1 then 'Tuve que esperar bastante.' end,
       ci.id_medico, co.id_consulta
  from consulta co
  join cita ci on ci.id_cita = co.id_cita
 where co.id_consulta > 100 and co.id_consulta % 10 < 7;

-- calificaciones a los hospitales, enfermeros y encargados
insert into calificacion (id_paciente, fecha, puntuacion, comentario, id_hospital)
select 1 + (n * 3) % 67, date '2026-01-10' + (n * 7) % 280,
       least(5, greatest(1, 2 + (n * 7 + n / 5) % 4)), null, 1 + n % 5
  from generate_series(1, 40) n;

insert into calificacion (id_paciente, fecha, puntuacion, comentario, id_enfermero)
select 1 + (n * 5) % 67, date '2026-02-01' + (n * 11) % 250,
       2 + n % 4, case when n % 3 = 0 then 'Atención amable y oportuna.' end,
       (select id_enfermero from enfermero order by id_enfermero offset n % 20 limit 1)
  from generate_series(1, 20) n;

insert into calificacion (id_paciente, fecha, puntuacion, comentario, id_encargado)
select pe.id_paciente, date '2026-03-01' + pe.id_encargado % 200, 3 + pe.id_encargado % 3,
       'Acompañó al paciente en todos los trámites.', pe.id_encargado
  from paciente_encargado pe
 where pe.id_paciente between 8 and 30 and pe.id_parentesco in (1, 2);

reset role;
commit;
