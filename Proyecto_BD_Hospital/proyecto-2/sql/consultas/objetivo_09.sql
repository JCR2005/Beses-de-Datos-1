-- Proyecto 2 - Objetivo 9
-- Los 3 hospitales con mayores ingresos monetarios por visita en un lapso de tiempo.
--
-- Ingreso por visita = monto facturado / visitas. Una visita es una ficha de
-- ingreso (emergencias, cirugia u hospitalizacion) o una cita de consulta
-- externa no cancelada. Las consultas se muestran aparte pero no se suman,
-- porque cada consulta ya se cuenta en su cita.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_09(p_desde date, p_hasta date)
returns table (hospital varchar, ingresos_fichas bigint, citas bigint, consultas bigint,
               visitas bigint, monto_facturado numeric, ingreso_por_visita numeric)
language sql stable
as $$
    with fichas as (
        select u.id_hospital, count(*) as n
          from ingreso i join unidad_medica u on u.id_unidad = i.id_unidad
         where i.fecha_hora_ingreso >= p_desde and i.fecha_hora_ingreso < p_hasta + 1
         group by u.id_hospital
    ), citas as (
        select me.id_hospital, count(*) filter (where ci.estado <> 'cancelada') as citas, count(co.id_consulta) as consultas
          from cita ci
          join medico me on me.id_medico = ci.id_medico
          left join consulta co on co.id_cita = ci.id_cita
         where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
         group by me.id_hospital
    ), facturado as (
        select id_hospital, sum(total) as monto
          from v_factura
         where fecha_emision >= p_desde and fecha_emision < p_hasta + 1
         group by id_hospital
    )
    select h.nombre, coalesce(fi.n, 0), coalesce(c.citas, 0), coalesce(c.consultas, 0),
           coalesce(fi.n, 0) + coalesce(c.citas, 0),
           coalesce(fa.monto, 0),
           round(coalesce(fa.monto, 0) / nullif(coalesce(fi.n, 0) + coalesce(c.citas, 0), 0), 2)
      from hospital h
      left join fichas fi on fi.id_hospital = h.id_hospital
      left join citas c on c.id_hospital = h.id_hospital
      left join facturado fa on fa.id_hospital = h.id_hospital
     order by 7 desc nulls last
     limit 3;
$$;

comment on function fn_objetivo_09(date, date) is 'Objetivo 9: 3 hospitales con mayor ingreso por visita.';

reset role;
commit;

set role visor;
select * from fn_objetivo_09('2026-01-01', '2026-10-31');
reset role;
