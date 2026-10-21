-- Proyecto 2 - Objetivo 12
-- Promedio de edad y distribucion por sexo de los ingresos a emergencias de
-- cada hospital, agrupados por turno (jornada diurna o nocturna).
--
-- La edad es la que tenia el paciente el dia del ingreso, no la actual.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_12(p_desde date, p_hasta date)
returns table (hospital varchar, jornada varchar, ingresos bigint, edad_promedio numeric,
               masculino bigint, femenino bigint)
language sql stable
as $$
    select h.nombre, t.jornada, count(*),
           round(avg(fn_edad(p.fecha_nacimiento, i.fecha_hora_ingreso::date)), 1),
           count(*) filter (where p.sexo = 'Masculino'),
           count(*) filter (where p.sexo = 'Femenino')
      from ingreso i
      join turno_emergencia t on t.id_turno = i.id_turno
      join unidad_medica u on u.id_unidad = i.id_unidad
      join hospital h on h.id_hospital = u.id_hospital
      join paciente p on p.id_paciente = i.id_paciente
     where i.fecha_hora_ingreso >= p_desde and i.fecha_hora_ingreso < p_hasta + 1
     group by h.id_hospital, h.nombre, t.jornada
     order by h.id_hospital, t.jornada;
$$;

comment on function fn_objetivo_12(date, date) is 'Objetivo 12: edad promedio y sexo en emergencias por hospital y turno.';

reset role;
commit;

set role visor;
select * from fn_objetivo_12('2026-01-01', '2026-10-31');
reset role;
