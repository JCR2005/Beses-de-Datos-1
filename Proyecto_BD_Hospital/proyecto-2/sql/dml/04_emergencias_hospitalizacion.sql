-- Proyecto 2 - BD Hospitales de Occidente
-- 04_emergencias_hospitalizacion.sql : turnos, ingresos, egresos y traslados de enero a octubre de 2026 (datos FICTICIOS)
--
-- Rangos de id: turnos 1000-1949; ingresos a emergencias 1001-1155 y a
-- hospitalizacion 2001-2060; el egreso usa el mismo id que su ingreso.

begin;
set role admin;
set search_path to public;

-- ============================================================
-- turnos de emergencia: cada 3 dias, jornada diurna y nocturna, en los 5 hospitales
-- ============================================================
-- id = 1000 + dia*10 + (hospital-1)*2 + (0 diurno | 1 nocturno)

insert into turno_emergencia (id_turno, id_unidad, fecha, jornada)
select 1000 + d * 10 + (h - 1) * 2 + j, 10 * h + 2, date '2026-01-05' + 3 * d,
       case j when 0 then 'diurno' else 'nocturno' end
  from generate_series(0, 94) d, generate_series(1, 5) h, generate_series(0, 1) j
 -- se omiten los turnos que ya existian desde el Proyecto 1
 where not exists (select 1 from turno_emergencia x
                    where x.id_unidad = 10 * h + 2 and x.fecha = date '2026-01-05' + 3 * d
                      and x.jornada = case j when 0 then 'diurno' else 'nocturno' end);

-- medicos de emergencia de cada hospital; donde hay 3, cada turno lo cubren 2
-- y la rotacion hace que unos acumulen mas turnos que otros
with candidato(id_hospital, posicion, id_medico) as (
    values (1, 0, 1001), (1, 1, 1005), (1, 2, 1006),
           (2, 0, 1031), (2, 1, 1032), (2, 2, 1035),
           (3, 0, 1036), (3, 1, 1037),
           (4, 0, 1041), (4, 1, 1042), (4, 2, 1046),
           (5, 0, 1047), (5, 1, 1048)
), turno as (
    select t.id_turno, u.id_hospital, (t.id_turno - 1000) / 10 + (t.id_turno % 2) as rotacion
      from turno_emergencia t join unidad_medica u on u.id_unidad = t.id_unidad
     where t.id_turno >= 1000
)
insert into turno_medico (id_turno, id_medico)
select t.id_turno, c.id_medico
  from turno t
  join candidato c on c.id_hospital = t.id_hospital
 where (select count(*) from candidato x where x.id_hospital = t.id_hospital) = 2
    or c.posicion <> case when t.rotacion % 6 = 0 then 0 when t.rotacion % 6 in (1, 2) then 1 else 2 end;

-- ============================================================
-- ingresos a emergencias (150), dentro de un turno de su hospital
-- ============================================================
-- la espera por falta de camilla depende de cada hospital: unos casi siempre
-- tienen camilla libre al llegar el paciente y otros no

insert into ingreso (id_ingreso, id_paciente, id_unidad, id_servicio, id_medico_encargado, id_camilla, id_turno,
                     fecha_hora_ingreso, motivo_ingreso, diagnostico_presuntivo, prioridad_triage, turnos_espera)
select 1000 + g.n, 1 + (g.n * 11) % 67, 10 * g.h + 2, (g.h - 1) * 100 + 1 + g.n % 7,
       (select id_medico from turno_medico tm where tm.id_turno = g.id_turno order by id_medico
         offset g.n % (select count(*) from turno_medico x where x.id_turno = g.id_turno) limit 1),
       (array[25, 113, 211, 315, 411])[g.h] + g.n % (array[6, 4, 4, 5, 4])[g.h],
       g.id_turno,
       ((t.fecha + case t.jornada when 'diurno' then time '07:00' else time '19:00' end)
         at time zone 'America/Guatemala') + ((g.n * 37) % 700) * interval '1 minute',
       (array['Dolor torácico.', 'Fiebre alta y deshidratación.', 'Traumatismo por caída.', 'Dificultad respiratoria.',
              'Dolor abdominal agudo.', 'Herida cortante en extremidad.', 'Crisis hipertensiva.'])[1 + g.n % 7],
       (array['Síndrome coronario en estudio.', 'Cuadro viral.', 'Contusión.', 'Crisis asmática.',
              'Abdomen agudo en estudio.', 'Herida superficial.', 'Hipertensión descompensada.'])[1 + g.n % 7],
       1 + (g.n * 3) % 5,
       case when ((g.n / 5) * 7) % 10 < (array[8, 5, 7, 4, 6])[g.h] then 0 else 1 + (g.n / 5) % 3 end
  from (select n, 1 + n % 5 as h, 1000 + ((n * 7) % 95) * 10 + (n % 5) * 2 + n % 2 as id_turno
          from generate_series(1, 150) n) g
  join turno_emergencia t on t.id_turno = g.id_turno;

-- egresos de 6 de cada 7 ingresos; algunos fallecen y otros salen sin consentimiento medico
insert into egreso (id_egreso, id_ingreso, id_medico, id_diagnostico_principal, fecha_hora_egreso, motivo_egreso,
                    codigo_egreso, sin_consentimiento, motivo_sin_consentimiento)
select i.id_ingreso, i.id_ingreso, i.id_medico_encargado, 1 + (n * 5) % 19,
       i.fecha_hora_ingreso + (4 + n % 40) * interval '1 hour',
       case when n % 23 = 0 then 'Fallecimiento.' when n % 9 = 0 then 'Traslado a hospitalización.'
            else 'Mejoría clínica.' end,
       case when n % 23 = 0 then 'muerto' else 'vivo' end,
       n % 13 = 0 and n % 23 <> 0,
       case when n % 13 = 0 and n % 23 <> 0 then 'El paciente decidió retirarse antes del alta.' end
  from ingreso i
 cross join lateral (select i.id_ingreso - 1000 as n) x
 where i.id_ingreso between 1001 and 1150 and n % 7 <> 0;

-- los egresos por traslado a hospitalizacion tienen su ficha de traslado
insert into traslado (id_traslado, fecha_hora, id_medico_indica, id_ingreso, id_unidad_origen, tipo_traslado, id_unidad_destino)
select e.id_egreso, e.fecha_hora_egreso - interval '15 minutes', e.id_medico, e.id_ingreso,
       i.id_unidad, 'interno', i.id_unidad + 2
  from egreso e join ingreso i on i.id_ingreso = e.id_ingreso
 where e.id_egreso between 1001 and 1150 and e.motivo_egreso = 'Traslado a hospitalización.';

-- ============================================================
-- casos escritos a mano: accidentes con varias victimas el mismo dia
-- ============================================================

-- hospital 1, turno nocturno del 13 de junio: accidente de bus, 2 fallecen el 14
insert into ingreso (id_ingreso, id_paciente, id_unidad, id_servicio, id_medico_encargado, id_camilla, id_turno,
                     fecha_hora_ingreso, motivo_ingreso, diagnostico_presuntivo, prioridad_triage, turnos_espera) values
(1151, 20, 12, 3, 1001, 25, 1531, '2026-06-13 21:30-06', 'Politraumatismo por accidente de bus.', 'Trauma craneoencefálico severo.', 1, 0),
(1152, 33, 12, 3, 1005, 26, 1531, '2026-06-13 21:40-06', 'Politraumatismo por accidente de bus.', 'Trauma torácico severo.', 1, 0),
(1153, 46, 12, 3, 1001, 27, 1531, '2026-06-13 21:50-06', 'Politraumatismo por accidente de bus.', 'Fractura de fémur.', 2, 0);
-- hospital 2, turno diurno del 21 de marzo: intoxicacion, 2 fallecen ese dia
insert into ingreso (id_ingreso, id_paciente, id_unidad, id_servicio, id_medico_encargado, id_camilla, id_turno,
                     fecha_hora_ingreso, motivo_ingreso, diagnostico_presuntivo, prioridad_triage, turnos_espera) values
(1154, 41, 22, 104, (select min(id_medico) from turno_medico where id_turno = 1252), 113, 1252, '2026-03-21 09:15-06', 'Intoxicación por plaguicida.', 'Intoxicación por organofosforados.', 1, 0),
(1155, 54, 22, 104, (select min(id_medico) from turno_medico where id_turno = 1252), 114, 1252, '2026-03-21 09:20-06', 'Intoxicación por plaguicida.', 'Intoxicación por organofosforados.', 1, 1);

insert into egreso (id_egreso, id_ingreso, id_medico, id_diagnostico_principal, fecha_hora_egreso, motivo_egreso, codigo_egreso)
select id_ingreso, id_ingreso, id_medico_encargado, 3,
       case id_ingreso when 1151 then timestamptz '2026-06-14 02:10-06' when 1152 then timestamptz '2026-06-14 05:45-06'
                       when 1153 then timestamptz '2026-06-15 10:00-06' when 1154 then timestamptz '2026-03-21 14:30-06'
                       else timestamptz '2026-03-21 18:05-06' end,
       case when id_ingreso = 1153 then 'Mejoría clínica.' else 'Fallecimiento.' end,
       case when id_ingreso = 1153 then 'vivo' else 'muerto' end
  from ingreso where id_ingreso between 1151 and 1155;

-- ============================================================
-- hospitalizacion (60 internamientos)
-- ============================================================

insert into ingreso (id_ingreso, id_paciente, id_unidad, id_servicio, id_medico_encargado, id_camilla,
                     fecha_hora_ingreso, motivo_ingreso, diagnostico_presuntivo)
select 2000 + g.n, 1 + (g.n * 13 + 5) % 67, 10 * g.h + 4, (g.h - 1) * 100 + 8 + g.n % 9,
       (select id_medico from medico where id_hospital = g.h and tipo_medico <> 'externo' order by id_medico
         offset g.n % (select count(*) from medico where id_hospital = g.h and tipo_medico <> 'externo') limit 1),
       (g.h - 1) * 100 + 1 + g.n % (array[24, 12, 10, 14, 10])[g.h],
       ((date '2026-01-08' + (g.n * 5) % 280) + time '10:00' + (g.n % 8) * interval '1 hour') at time zone 'America/Guatemala',
       (array['Neumonía que requiere oxígeno.', 'Control de diabetes descompensada.', 'Recuperación postquirúrgica.',
              'Observación por trauma craneal.', 'Tratamiento de infección urinaria complicada.'])[1 + g.n % 5],
       (array['Neumonía.', 'Diabetes descompensada.', 'Postoperatorio.', 'Trauma craneal leve.', 'Pielonefritis.'])[1 + g.n % 5]
  from (select n, 1 + (n * 3) % 5 as h from generate_series(1, 60) n) g;

insert into egreso (id_egreso, id_ingreso, id_medico, id_diagnostico_principal, fecha_hora_egreso, motivo_egreso, codigo_egreso)
select i.id_ingreso, i.id_ingreso, i.id_medico_encargado,
       (array[10, 11, 2, 5, 19])[1 + (i.id_ingreso - 2000) % 5],
       i.fecha_hora_ingreso + (1 + (i.id_ingreso - 2000) % 9) * interval '1 day' + interval '2 hours',
       case when (i.id_ingreso - 2000) % 19 = 0 then 'Fallecimiento.' else 'Alta médica.' end,
       case when (i.id_ingreso - 2000) % 19 = 0 then 'muerto' else 'vivo' end
  from ingreso i
 where i.id_ingreso between 2001 and 2060 and (i.id_ingreso - 2000) % 8 <> 0;

-- insumos usados en cada internamiento, al costo vigente
insert into hospitalizacion_insumo (id_ingreso, id_insumo, cantidad, costo_unitario)
select i.id_ingreso, s.id_insumo, s.cantidad, ins.costo_unitario
  from ingreso i
 cross join lateral (values (1 + i.id_ingreso % 10, 2 + i.id_ingreso % 8),
                            (1 + (i.id_ingreso + 4) % 10, 1 + i.id_ingreso % 5)) as s(id_insumo, cantidad)
  join insumo ins on ins.id_insumo = s.id_insumo
 where i.id_ingreso between 2001 and 2060;

-- diagnosticos secundarios en 1 de cada 5 egresos de emergencias y hospitalizacion
insert into egreso_diagnostico (id_egreso, id_diagnostico)
select e.id_egreso, 1 + (e.id_egreso * 3) % 19
  from egreso e
 where e.id_egreso between 1001 and 2060 and e.id_egreso % 5 = 0
   and 1 + (e.id_egreso * 3) % 19 <> e.id_diagnostico_principal;

reset role;
commit;
