-- Proyecto 2 - BD Hospitales de Occidente
-- 05_cirugia.sql : agendamientos, preoperatorio, cirugias y su registro de enero a octubre de 2026 (datos FICTICIOS)
--
-- Rangos de id: agendamientos 101-145; la cirugia usa el mismo id que su
-- agendamiento; su ingreso y traslado, 3000 + n.

begin;
set role admin;
set search_path to public;

-- procedimientos de las especialidades quirurgicas que no tenian ninguno
insert into tipo_cirugia (id_tipo_cirugia, nombre, id_especialidad) values
(11, 'Reparación de tendones flexores de la mano', 319),
(12, 'Craneotomía para drenaje de hematoma', 322),
(13, 'Amigdalectomía', 325),
(14, 'Herniorrafia umbilical pediátrica', 326),
(15, 'Rinoplastia reconstructiva', 327),
(16, 'Lobectomía pulmonar', 328),
(17, 'Prostatectomía', 329);

-- ============================================================
-- agendamientos: 45 solicitudes; 1 de cada 6 se rechaza y algunas quedan pendientes
-- ============================================================
-- algunos cirujanos aparecen varias veces en la lista para que tengan mas solicitudes

insert into agendamiento_quirurgico (id_agendamiento, id_paciente, id_medico_cirujano, id_tipo_cirugia, id_tipo_anestesia,
                                     caracter, resumen_clinico, tiempo_estimado_min, fecha_hora_solicitud,
                                     estado_solicitud, motivo_rechazo, id_quirofano_solicitado, fecha_hora_agendada)
select 100 + g.n, 1 + (g.n * 17) % 67, g.cirujano,
       (select id_tipo_cirugia from tipo_cirugia t where t.id_especialidad = m.id_especialidad order by id_tipo_cirugia
         offset g.n % (select count(*) from tipo_cirugia x where x.id_especialidad = m.id_especialidad) limit 1),
       (array[1, 1, 1, 2, 3, 4, 5])[1 + g.n % 7],
       case when g.n % 4 = 0 then 'urgente' else 'programado' end,
       'Paciente valorado en consulta; se indica tratamiento quirúrgico.',
       60 + (g.n * 13) % 150,
       g.solicitud,
       g.estado,
       case when g.estado = 'rechazada' then 'El comité solicita estudios complementarios antes de programar la intervención.' end,
       4 * (m.id_hospital - 1) + 1 + g.n % 4,
       case when g.estado = 'aprobada' then g.solicitud + (1 + g.n % 4) * interval '1 day' + interval '7 hours' end
  from (select n,
               (array[1006, 1006, 1045, 1009, 1050, 1035, 1045, 1020, 1007, 1009, 1023, 1050, 1006, 1026, 1021,
                      1029, 1022, 1040, 1024, 1025, 1027, 1028, 1030, 1045, 1006])[1 + (n * 7) % 25] as cirujano,
               ((date '2026-01-12' + (n * 6) % 270) + time '08:00') at time zone 'America/Guatemala' as solicitud,
               case when n % 6 = 0 then 'rechazada' when n % 9 = 0 then 'pendiente' else 'aprobada' end as estado
          from generate_series(1, 45) n) g
  join medico m on m.id_medico = g.cirujano;

-- recursos solicitados: cada cirujano tiene su propia costumbre (factor 1 a 4)
insert into requerimiento_insumo (id_agendamiento, id_insumo, cantidad)
select a.id_agendamiento, r.id_insumo, r.cantidad
  from agendamiento_quirurgico a
 cross join lateral (values (1 + a.id_agendamiento % 10, (1 + a.id_medico_cirujano % 4) * 2 + a.id_agendamiento % 3),
                            (1 + (a.id_agendamiento + 5) % 10, 1 + a.id_medico_cirujano % 4)) r(id_insumo, cantidad)
 where a.id_agendamiento > 100;

insert into requerimiento_instrumento (id_agendamiento, id_instrumento, cantidad)
select a.id_agendamiento, r.id_instrumento, r.cantidad
  from agendamiento_quirurgico a
 cross join lateral (values (1 + a.id_agendamiento % 9, 1 + a.id_medico_cirujano % 4),
                            (1 + (a.id_agendamiento + 3) % 9, 1 + a.id_agendamiento % 2)) r(id_instrumento, cantidad)
 where a.id_agendamiento > 100;

insert into requerimiento_equipo (id_agendamiento, id_equipo, cantidad)
select a.id_agendamiento, 1 + a.id_agendamiento % 8, case when a.id_medico_cirujano % 4 > 1 then 2 else 1 end
  from agendamiento_quirurgico a
 where a.id_agendamiento > 100;

-- ============================================================
-- preoperatorio
-- ============================================================

insert into historia_clinica (id_historia_clinica, id_agendamiento, id_medico, fecha, fuente_interrogatorio,
                              antecedentes_heredofamiliares, antecedentes_personales_no_patologicos,
                              antecedentes_patologicos, padecimiento_actual, signos_vitales, exploracion_general)
select a.id_agendamiento, a.id_agendamiento, a.id_medico_cirujano, a.fecha_hora_solicitud::date,
       case when a.id_agendamiento % 5 = 0 then 'indirecto' else 'directo' end,
       'Sin antecedentes heredofamiliares de importancia.', 'No fuma; alimentación balanceada.',
       case when a.id_agendamiento % 3 = 0 then 'Hipertensión arterial controlada.' else 'Ninguno conocido.' end,
       'Padecimiento que motiva la cirugía, según valoración del cirujano.',
       'TA 120/80, FC 78, T° 36.8.', 'Paciente consciente y orientado.'
  from agendamiento_quirurgico a
 where a.id_agendamiento > 100;

insert into consentimiento_informado (id_consentimiento, id_agendamiento, id_medico, procedimiento_nombre, procedimiento_objetivo,
                                      procedimiento_caracteristicas, procedimiento_riesgos, medico_firmo,
                                      firmante_nombre, firmante_relacion, firmante_firmo, fecha_obtencion)
select a.id_agendamiento, a.id_agendamiento, a.id_medico_cirujano, t.nombre,
       'Tratar quirúrgicamente el padecimiento del paciente.', 'Procedimiento bajo la anestesia indicada en el agendamiento.',
       'Sangrado, infección y complicaciones anestésicas.', true,
       p.nombres || ' ' || p.apellidos,
       case when fn_edad(p.fecha_nacimiento) < 18 then 'tutor' else 'paciente' end,
       true, a.fecha_hora_solicitud::date
  from agendamiento_quirurgico a
  join tipo_cirugia t on t.id_tipo_cirugia = a.id_tipo_cirugia
  join paciente p on p.id_paciente = a.id_paciente
 where a.id_agendamiento > 100 and a.estado_solicitud = 'aprobada';

-- el anestesista es el anestesiologo del hospital cuando lo hay; si no, el mismo cirujano
insert into chequeo_preanestesico (id_chequeo, id_agendamiento, clasificacion_asa, id_medico_clasifica, plan_anestesia, id_medico_anestesista)
select a.id_agendamiento, a.id_agendamiento, (array['I','II','II','III'])[1 + a.id_agendamiento % 4],
       a.id_medico_cirujano, 'Plan anestésico acorde al tipo de anestesia solicitado.',
       coalesce((select an.id_medico from medico an where an.id_especialidad = 318 and an.id_hospital = m.id_hospital limit 1),
                a.id_medico_cirujano)
  from agendamiento_quirurgico a
  join medico m on m.id_medico = a.id_medico_cirujano
 where a.id_agendamiento > 100 and a.estado_solicitud = 'aprobada';

-- ============================================================
-- cirugias realizadas: las aprobadas con fecha antes del 18 de octubre
-- ============================================================

-- ingreso del paciente al quirofano (ficha de ingreso de la unidad de cirugia)
insert into ingreso (id_ingreso, id_paciente, id_unidad, id_servicio, id_medico_encargado, id_quirofano,
                     fecha_hora_ingreso, motivo_ingreso, diagnostico_presuntivo)
select 3000 + (a.id_agendamiento - 100), a.id_paciente, 10 * m.id_hospital + 3,
       (m.id_hospital - 1) * 100 + case e.id_especialidad when 316 then 18 when 317 then 19 else 17 end,
       a.id_medico_cirujano, a.id_quirofano_solicitado,
       a.fecha_hora_agendada - interval '20 minutes',
       'Ingreso a quirófano: ' || t.nombre || '.', 'Indicación quirúrgica.'
  from agendamiento_quirurgico a
  join medico m on m.id_medico = a.id_medico_cirujano
  join tipo_cirugia t on t.id_tipo_cirugia = a.id_tipo_cirugia
  join especialidad e on e.id_especialidad = t.id_especialidad
 where a.id_agendamiento > 100 and a.estado_solicitud = 'aprobada'
   and a.fecha_hora_agendada < timestamptz '2026-10-18 00:00-06';

insert into cirugia (id_cirugia, id_agendamiento, id_quirofano, id_ingreso, fecha_hora_inicio, fecha_hora_fin, estado, condicion_evolucion)
select a.id_agendamiento, a.id_agendamiento, a.id_quirofano_solicitado, i.id_ingreso,
       a.fecha_hora_agendada,
       a.fecha_hora_agendada + (a.tiempo_estimado_min + (a.id_agendamiento % 5) * 10 - 20) * interval '1 minute',
       'finalizada',
       case when a.id_agendamiento % 11 = 0 then 'complicaciones_graves'
            when a.id_agendamiento % 7 = 0 then 'complicaciones'
            else 'sin_complicaciones' end
  from agendamiento_quirurgico a
  join ingreso i on i.id_ingreso = 3000 + (a.id_agendamiento - 100);

-- equipo quirurgico: el cirujano y, si el hospital tiene, el anestesiologo
insert into cirugia_personal (id_cirugia, id_medico, id_enfermero, id_rol)
select c.id_cirugia, a.id_medico_cirujano, null::integer, 1
  from cirugia c join agendamiento_quirurgico a using (id_agendamiento) where c.id_cirugia > 100
union all
select c.id_cirugia, ch.id_medico_anestesista, null, 3
  from cirugia c join chequeo_preanestesico ch using (id_agendamiento)
 where c.id_cirugia > 100 and ch.id_medico_anestesista <> ch.id_medico_clasifica;

-- y dos enfermeros (instrumentista y circulante), rotando entre los de su hospital
insert into cirugia_personal (id_cirugia, id_medico, id_enfermero, id_rol)
select c.id_cirugia, null, x.id_enfermero, x.rol
  from cirugia c
  join quirofano q on q.id_quirofano = c.id_quirofano
  join unidad_medica u on u.id_unidad = q.id_unidad
 cross join lateral (
        select id_enfermero, 4 + row_number() over (order by id_enfermero) - 1 as rol
          from (select id_enfermero from enfermero where id_hospital = u.id_hospital order by id_enfermero
                offset c.id_cirugia % (select count(*) - 1 from enfermero where id_hospital = u.id_hospital) limit 2) e2) x
 where c.id_cirugia > 100;

-- resultado de los 38 aspectos de cada cirugia; algunas fallas y resultados no aceptables
insert into registro_procedimiento (id_cirugia, id_aspecto, resultado, descripcion, fecha_hora_registro, id_enfermero)
select c.id_cirugia, ap.id_aspecto,
       case when ap.tipo_evaluacion = 'exito_falla'
            then case when (c.id_cirugia * ap.id_aspecto) % 29 = 0 then 'falla' else 'exito' end
            else case (c.id_cirugia + ap.id_aspecto) % 10 when 0 then 'no_aceptable'
                                                         when 1 then 'medianamente_aceptable'
                                                         when 2 then 'medianamente_aceptable'
                                                         else 'aceptable' end end,
       null,
       case ap.etapa when 'preoperatorio' then c.fecha_hora_inicio - interval '40 minutes'
                     when 'intraoperatorio' then c.fecha_hora_inicio
                     else c.fecha_hora_fin end + ap.id_aspecto * interval '1 minute',
       (select min(id_enfermero) from cirugia_personal cp where cp.id_cirugia = c.id_cirugia)
  from cirugia c
 cross join aspecto_quirurgico ap
 where c.id_cirugia > 100;

insert into documentacion_etapa (id_cirugia, etapa, id_enfermero, fecha_envio)
select c.id_cirugia, et.etapa, (select min(id_enfermero) from cirugia_personal cp where cp.id_cirugia = c.id_cirugia),
       c.fecha_hora_fin::date + 1
  from cirugia c
 cross join (values ('preoperatorio'), ('intraoperatorio'), ('postoperatorio')) et(etapa)
 where c.id_cirugia > 100;

-- insumos usados realmente en la cirugia, al costo vigente
insert into cirugia_insumo (id_cirugia, id_insumo, cantidad, costo_unitario)
select c.id_cirugia, s.id_insumo, s.cantidad, ins.costo_unitario
  from cirugia c
 cross join lateral (values (1 + c.id_cirugia % 10, 2 + c.id_cirugia % 6),
                            (1 + (c.id_cirugia + 2) % 10, 1 + c.id_cirugia % 3),
                            (1 + (c.id_cirugia + 6) % 10, 3)) s(id_insumo, cantidad)
  join insumo ins on ins.id_insumo = s.id_insumo
 where c.id_cirugia > 100;

-- egreso de la unidad de cirugia y traslado a hospitalizacion para la recuperacion
insert into egreso (id_egreso, id_ingreso, id_medico, id_diagnostico_principal, fecha_hora_egreso, motivo_egreso, codigo_egreso)
select c.id_ingreso, c.id_ingreso, a.id_medico_cirujano, 2,
       c.fecha_hora_fin + interval '30 minutes',
       case when c.condicion_evolucion = 'complicaciones_graves' and c.id_cirugia % 2 = 0 then 'Fallecimiento en sala de operaciones.'
            else 'Traslado a sala de recuperación.' end,
       case when c.condicion_evolucion = 'complicaciones_graves' and c.id_cirugia % 2 = 0 then 'muerto' else 'vivo' end
  from cirugia c join agendamiento_quirurgico a using (id_agendamiento)
 where c.id_cirugia > 100;

insert into traslado (id_traslado, fecha_hora, id_medico_indica, id_ingreso, id_unidad_origen, tipo_traslado, id_unidad_destino)
select e.id_egreso, e.fecha_hora_egreso - interval '10 minutes', e.id_medico, e.id_ingreso, i.id_unidad, 'interno', i.id_unidad + 1
  from egreso e join ingreso i using (id_ingreso)
 where e.id_egreso > 3000 and e.codigo_egreso = 'vivo';

reset role;
commit;
