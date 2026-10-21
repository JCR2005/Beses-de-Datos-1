-- Proyecto 2 - Objetivo 3
-- Los 5 mejores medicos de emergencias en un lapso de tiempo.
--
-- Por medico: turnos de 12 horas cubiertos, horas laboradas (turnos x 12) y
-- egresos de emergencias que firmo con codigo "vivo" y con consentimiento
-- medico (el paciente no se fue sin el alta). Se ordena por egresos, luego
-- por horas laboradas.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_03(p_desde date, p_hasta date)
returns table (posicion bigint, medico text, hospital varchar, turnos bigint, horas_laboradas bigint, egresos_vivos bigint)
language sql stable
as $$
    with turnos as (
        select tm.id_medico, count(*) as turnos
          from turno_medico tm
          join turno_emergencia t on t.id_turno = tm.id_turno
         where t.fecha between p_desde and p_hasta
         group by tm.id_medico
    ), egresos as (
        select e.id_medico, count(*) as egresos
          from egreso e
          join ingreso i on i.id_ingreso = e.id_ingreso
          join unidad_medica u on u.id_unidad = i.id_unidad
         where u.tipo_unidad = 'Emergencias'
           and e.codigo_egreso = 'vivo' and not e.sin_consentimiento
           and e.fecha_hora_egreso >= p_desde and e.fecha_hora_egreso < p_hasta + 1
         group by e.id_medico
    )
    select rank() over (order by coalesce(eg.egresos, 0) desc, t.turnos desc),
           me.nombres || ' ' || me.apellidos, h.nombre,
           t.turnos, t.turnos * 12, coalesce(eg.egresos, 0)
      from turnos t
      join medico me on me.id_medico = t.id_medico
      join hospital h on h.id_hospital = me.id_hospital
      left join egresos eg on eg.id_medico = t.id_medico
     order by 1
     limit 5;
$$;

comment on function fn_objetivo_03(date, date) is 'Objetivo 3: 5 mejores médicos de emergencias.';

reset role;
commit;

set role visor;
select * from fn_objetivo_03('2026-01-01', '2026-10-31');
reset role;
