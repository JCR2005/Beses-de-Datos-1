-- Objetivo 3: los 5 mejores medicos de emergencias (turnos de 12 horas)
-- lapso: enero a octubre de 2026

select m.nombres, m.apellidos,
       h.nombre as hospital,
       count(*) as turnos,
       count(*) * 12 as horas_laboradas, -- 12 horas por turno
       (select count(*)
        from egreso e
        inner join ingreso i on i.id_ingreso = e.id_ingreso
        where e.id_medico = m.id_medico
          and i.id_turno is not null      -- solo los ingresos de emergencias tienen turno
          and e.codigo_egreso = 'vivo'
          and e.sin_consentimiento = false
          and e.fecha_hora_egreso between '2026-01-01' and '2026-10-31 23:59:59') as egresos_vivos
from turno_medico tm
inner join turno_emergencia t on t.id_turno = tm.id_turno
inner join medico m on m.id_medico = tm.id_medico
inner join hospital h on h.id_hospital = m.id_hospital
where t.fecha between '2026-01-01' and '2026-10-31'
group by m.id_medico, m.nombres, m.apellidos, h.nombre
order by egresos_vivos desc, turnos desc
  limit 5;
