-- Proyecto 2 - Objetivo 6
-- Los 3 tipos de cirugia con mayores ingresos monetarios en un lapso de tiempo.
--
-- Solo cuentan las cirugias cuya evolucion fue "sin complicaciones" y en las
-- que todos los aspectos de la fase intraoperatoria resultaron en exito o
-- aceptables (ninguna falla, ni medianamente o no aceptable).

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_06(p_desde date, p_hasta date)
returns table (tipo_cirugia varchar, especialidad varchar, cirugias bigint, ingresos numeric)
language sql stable
as $$
    with cirugia_exitosa as (
        select c.id_cirugia, a.id_tipo_cirugia
          from cirugia c
          join agendamiento_quirurgico a on a.id_agendamiento = c.id_agendamiento
         where c.condicion_evolucion = 'sin_complicaciones'
           and c.fecha_hora_inicio >= p_desde and c.fecha_hora_inicio < p_hasta + 1
           and not exists (
                select 1
                  from registro_procedimiento rp
                  join aspecto_quirurgico ap on ap.id_aspecto = rp.id_aspecto
                 where rp.id_cirugia = c.id_cirugia
                   and ap.etapa = 'intraoperatorio'
                   and rp.resultado not in ('exito', 'aceptable'))
    )
    select t.nombre, es.nombre, count(*), sum(f.total)
      from cirugia_exitosa ce
      join factura f on f.id_cirugia = ce.id_cirugia
      join tipo_cirugia t on t.id_tipo_cirugia = ce.id_tipo_cirugia
      join especialidad es on es.id_especialidad = t.id_especialidad
     group by t.id_tipo_cirugia, t.nombre, es.nombre
     order by 4 desc
     limit 3;
$$;

comment on function fn_objetivo_06(date, date) is 'Objetivo 6: 3 tipos de cirugía con mayores ingresos sin complicaciones.';

reset role;
commit;

set role visor;
select * from fn_objetivo_06('2026-01-01', '2026-10-31');
reset role;
