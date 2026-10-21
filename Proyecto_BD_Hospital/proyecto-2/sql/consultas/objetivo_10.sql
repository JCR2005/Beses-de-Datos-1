-- Proyecto 2 - Objetivo 10
-- Fecha con mayor cantidad de decesos por hospital (egresos con codigo "muerto")
-- y la unidad medica donde se ha registrado la mayoria.
--
-- Si dos fechas empatan, se muestra la mas reciente. No tiene parametros de
-- fecha porque el objetivo pide la fecha historica, no un lapso.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_10()
returns table (hospital varchar, fecha_mas_decesos date, decesos_en_fecha bigint,
               unidad_con_mas_decesos varchar, decesos_en_unidad bigint, decesos_totales bigint)
language sql stable
as $$
    with deceso as (
        select u.id_hospital, u.tipo_unidad, e.fecha_hora_egreso::date as fecha
          from egreso e
          join ingreso i on i.id_ingreso = e.id_ingreso
          join unidad_medica u on u.id_unidad = i.id_unidad
         where e.codigo_egreso = 'muerto'
    ), por_fecha as (
        select id_hospital, fecha, count(*) as n,
               row_number() over (partition by id_hospital order by count(*) desc, fecha desc) as orden
          from deceso group by id_hospital, fecha
    ), por_unidad as (
        select id_hospital, tipo_unidad, count(*) as n,
               row_number() over (partition by id_hospital order by count(*) desc, tipo_unidad) as orden,
               sum(count(*)) over (partition by id_hospital) as total
          from deceso group by id_hospital, tipo_unidad
    )
    select h.nombre, pf.fecha, pf.n, pu.tipo_unidad, pu.n, pu.total::bigint
      from por_fecha pf
      join por_unidad pu on pu.id_hospital = pf.id_hospital and pu.orden = 1
      join hospital h on h.id_hospital = pf.id_hospital
     where pf.orden = 1
     order by pf.n desc, pu.total desc, h.nombre;
$$;

comment on function fn_objetivo_10() is 'Objetivo 10: fecha con más decesos y unidad con más decesos por hospital.';

reset role;
commit;

set role visor;
select * from fn_objetivo_10();
reset role;
