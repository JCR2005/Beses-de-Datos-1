-- Objetivo 2: los 5 medicos de consulta externa con menor calificacion
-- se usa la calificacion (1 a 5) que el paciente le dio al medico en cada consulta
-- lapso: enero a octubre de 2026

select m.nombres, m.apellidos,
       e.nombre as especialidad,
       h.nombre as hospital,
       round(avg(ca.puntuacion), 2) as calificacion_promedio,
       count(co.id_consulta) as consultas
from consulta co
inner join cita c on c.id_cita = co.id_cita
inner join medico m on m.id_medico = c.id_medico
inner join especialidad e on e.id_especialidad = m.id_especialidad
inner join hospital h on h.id_hospital = m.id_hospital
left join calificacion ca on ca.id_consulta = co.id_consulta
where c.fecha_hora between '2026-01-01' and '2026-10-31 23:59:59'
group by m.id_medico, m.nombres, m.apellidos, e.nombre, h.nombre
having count(ca.id_calificacion) > 0   --aqui solo se consideran los medicos que tengan al menos una calificacion
order by calificacion_promedio, consultas desc, m.apellidos
limit 5;
