-- Proyecto 2 - Objetivo 4
-- Los 3 hospitales mas eficientes en emergencias en un lapso de tiempo.
--
-- Eficiencia = tener camilla disponible cuando el paciente llega: porcentaje de
-- ingresos atendidos sin esperar turno y menor promedio de turnos de espera.
-- Tambien se muestran los ingresos y egresos de la unidad.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_04(p_desde date, p_hasta date)
returns table (hospital varchar, ingresos bigint, egresos bigint, atendidos_sin_espera bigint,
               porcentaje_sin_espera numeric, promedio_turnos_espera numeric)
language sql stable
as $$
    select h.nombre,
           count(*),
           count(e.id_egreso),
           count(*) filter (where i.turnos_espera = 0),
           round(100.0 * count(*) filter (where i.turnos_espera = 0) / count(*), 1),
           round(avg(i.turnos_espera), 2)
      from ingreso i
      join unidad_medica u on u.id_unidad = i.id_unidad
      join hospital h on h.id_hospital = u.id_hospital
      left join egreso e on e.id_ingreso = i.id_ingreso
     where u.tipo_unidad = 'Emergencias'
       and i.fecha_hora_ingreso >= p_desde and i.fecha_hora_ingreso < p_hasta + 1
     group by h.id_hospital, h.nombre
     order by 5 desc, 6, 2 desc
     limit 3;
$$;

comment on function fn_objetivo_04(date, date) is 'Objetivo 4: 3 hospitales con mayor disponibilidad de camillas en emergencias.';

reset role;
commit;

set role visor;
select * from fn_objetivo_04('2026-01-01', '2026-10-31');
reset role;
