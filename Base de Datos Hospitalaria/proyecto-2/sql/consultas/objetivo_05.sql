-- Proyecto 2 - Objetivo 5
-- Los 3 cirujanos mas eficientes en un lapso de tiempo.
--
-- Por cirujano y sobre sus agendamientos aprobados: cantidad total de insumos,
-- de instrumentos y de equipos solicitados (cada campo por separado) y numero
-- de agendamientos aprobados. Primero los que tienen mas aprobados; entre
-- ellos, los que piden menos recursos por cirugia.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_05(p_desde date, p_hasta date)
returns table (cirujano text, especialidad varchar, agendamientos_aprobados bigint,
               insumos bigint, instrumentos bigint, equipos bigint, recursos_por_cirugia numeric)
language sql stable
as $$
    with aprobado as (
        select a.id_agendamiento, a.id_medico_cirujano
          from agendamiento_quirurgico a
         where a.estado_solicitud = 'aprobada'
           and a.fecha_hora_solicitud >= p_desde and a.fecha_hora_solicitud < p_hasta + 1
    ), recursos as (
        select ap.id_medico_cirujano,
               count(*) as aprobados,
               sum((select coalesce(sum(cantidad), 0) from requerimiento_insumo r where r.id_agendamiento = ap.id_agendamiento)) as insumos,
               sum((select coalesce(sum(cantidad), 0) from requerimiento_instrumento r where r.id_agendamiento = ap.id_agendamiento)) as instrumentos,
               sum((select coalesce(sum(cantidad), 0) from requerimiento_equipo r where r.id_agendamiento = ap.id_agendamiento)) as equipos
          from aprobado ap
         group by ap.id_medico_cirujano
    )
    select me.nombres || ' ' || me.apellidos, es.nombre, r.aprobados,
           r.insumos::bigint, r.instrumentos::bigint, r.equipos::bigint,
           round((r.insumos + r.instrumentos + r.equipos) / r.aprobados, 2)
      from recursos r
      join medico me on me.id_medico = r.id_medico_cirujano
      join especialidad es on es.id_especialidad = me.id_especialidad
     order by r.aprobados desc, 7
     limit 3;
$$;

comment on function fn_objetivo_05(date, date) is 'Objetivo 5: 3 cirujanos más eficientes (más aprobados, menos recursos).';

reset role;
commit;

set role visor;
select * from fn_objetivo_05('2026-01-01', '2026-10-31');
reset role;
