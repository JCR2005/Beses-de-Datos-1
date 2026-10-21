-- Proyecto 2 - Objetivo 1
-- Los 3 hospitales con mayor demanda en consulta externa en un lapso de tiempo.
--
-- Demanda = reservaciones (citas no canceladas) + consultas realizadas +
-- proximas consultas registradas en las recetas. Se muestra cada componente
-- por separado y su suma.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_01(p_desde date, p_hasta date)
returns table (hospital varchar, reservaciones bigint, consultas bigint, proximas_consultas bigint, demanda_total bigint)
language sql stable
as $$
    with cita_lapso as (
        select ci.id_cita, ci.estado, me.id_hospital
          from cita ci
          join medico me on me.id_medico = ci.id_medico
         where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
    ), conteo as (
        select cl.id_hospital,
               count(*) filter (where cl.estado <> 'cancelada') as reservaciones,
               count(co.id_consulta) as consultas,
               count(re.fecha_proxima_cita) as proximas_consultas
          from cita_lapso cl
          left join consulta co on co.id_cita = cl.id_cita
          left join receta re on re.id_consulta = co.id_consulta
         group by cl.id_hospital
    )
    select h.nombre, c.reservaciones, c.consultas, c.proximas_consultas,
           c.reservaciones + c.consultas + c.proximas_consultas
      from conteo c
      join hospital h on h.id_hospital = c.id_hospital
     order by 5 desc, h.nombre
     limit 3;
$$;

comment on function fn_objetivo_01(date, date) is 'Objetivo 1: 3 hospitales con mayor demanda en consulta externa.';

reset role;
commit;

-- resultado de enero a octubre de 2026, consultado con el rol de solo lectura
set role visor;
select * from fn_objetivo_01('2026-01-01', '2026-10-31');
reset role;
