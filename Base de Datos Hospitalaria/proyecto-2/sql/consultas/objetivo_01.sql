-- Objetivo 1: los 3 hospitales con mas demanda en consulta externa
-- demanda = citas no canceladas (reservaciones) + consultas realizadas + proximas citas de las recetas
-- lapso: enero a octubre de 2026



select h.nombre as hospital,
       count(case when c.estado <> 'cancelada' then 1 end) as reservaciones,
       count(co.id_consulta) as consultas,
       count(r.fecha_proxima_cita) as proximas_consultas,
       count(case when c.estado <> 'cancelada' then 1 end) + count(co.id_consulta) + count(r.fecha_proxima_cita) as demanda_total
from cita c
inner join medico m on m.id_medico = c.id_medico   --a cada cita se busca su medico
inner join hospital h on h.id_hospital = m.id_hospital --a cada medico se busca su hospital
left join consulta co on co.id_cita = c.id_cita  --aqui  se busca a la cita su consulta, solo si la tuvo
left join receta r on r.id_consulta = co.id_consulta --a cada consulta se busca su receta, solo si la tuvo
where c.fecha_hora between '2026-01-01' and '2026-10-31 23:59:59' --aqui se filtra por el lapso de tiempo
group by h.nombre --aqui agurpo por nombre de hospital
order by demanda_total desc -- ordeno de manera descendente por demanda total
limit 3; --y solo muestro los 3 primeros hospitales con mas demanda
