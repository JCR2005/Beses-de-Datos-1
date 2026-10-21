-- Proyecto 2 - Objetivo 13
-- Reporte de citas de consulta externa de cada hospital, ordenado por fecha y
-- agrupado por sexo del paciente y especialidad del medico.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_13(p_desde date, p_hasta date)
returns table (hospital varchar, fecha date, especialidad varchar, sexo varchar, citas bigint)
language sql stable
as $$
    select h.nombre, ci.fecha_hora::date, es.nombre, p.sexo, count(*)
      from cita ci
      join paciente p on p.id_paciente = ci.id_paciente
      join medico me on me.id_medico = ci.id_medico
      join especialidad es on es.id_especialidad = me.id_especialidad
      join hospital h on h.id_hospital = me.id_hospital
     where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
     group by h.id_hospital, h.nombre, ci.fecha_hora::date, es.nombre, p.sexo
     order by h.id_hospital, 2, 3, 4;
$$;

comment on function fn_objetivo_13(date, date) is 'Objetivo 13: citas por hospital, fecha, especialidad y sexo.';

reset role;
commit;

-- el reporte completo es largo; como ejemplo se consulta el primer trimestre
set role visor;
select * from fn_objetivo_13('2026-01-01', '2026-03-31');
reset role;
