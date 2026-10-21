-- Proyecto 2 - Objetivo 2
-- Los 5 medicos de consulta externa con menor calificacion promedio por servicio.
--
-- Calificacion por servicio = la que el paciente da al medico ligada a la
-- consulta en que lo atendio (escala de 1 a 5). Se muestra el promedio, cuantas
-- calificaciones lo forman y el numero de consultas del medico en el lapso.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_02(p_desde date, p_hasta date)
returns table (posicion bigint, medico text, especialidad varchar, hospital varchar,
               calificacion_promedio numeric, calificaciones bigint, consultas bigint)
language sql stable
as $$
    with consulta_lapso as (
        select co.id_consulta, ci.id_medico
          from consulta co
          join cita ci on ci.id_cita = co.id_cita
         where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
    ), por_medico as (
        select cl.id_medico,
               avg(ca.puntuacion) as promedio,
               count(ca.id_calificacion) as calificaciones,
               count(distinct cl.id_consulta) as consultas
          from consulta_lapso cl
          left join calificacion ca on ca.id_consulta = cl.id_consulta
         group by cl.id_medico
        having count(ca.id_calificacion) > 0
    )
    select rank() over (order by pm.promedio, pm.consultas desc),
           me.nombres || ' ' || me.apellidos, es.nombre, h.nombre,
           round(pm.promedio, 2), pm.calificaciones, pm.consultas
      from por_medico pm
      join medico me on me.id_medico = pm.id_medico
      join especialidad es on es.id_especialidad = me.id_especialidad
      join hospital h on h.id_hospital = me.id_hospital
     order by pm.promedio, pm.consultas desc
     limit 5;
$$;

comment on function fn_objetivo_02(date, date) is 'Objetivo 2: 5 médicos de consulta externa con menor calificación promedio.';

reset role;
commit;

set role visor;
select * from fn_objetivo_02('2026-01-01', '2026-10-31');
reset role;
