-- Objetivo 13: reporte de citas de consulta externa de cada hospital,
-- ordenado por fecha y agrupado por sexo del paciente y especialidad del medico.
-- lapso: enero a octubre de 2026

select h.nombre as hospital,
       c.fecha_hora::date as fecha,
       e.nombre as especialidad,
       p.sexo,
       count(*) as citas
from cita c
inner join paciente p on p.id_paciente = c.id_paciente
inner join medico m on m.id_medico = c.id_medico
inner join especialidad e on e.id_especialidad = m.id_especialidad
inner join hospital h on h.id_hospital = m.id_hospital
where c.fecha_hora between '2026-01-01' and '2026-10-31 23:59:59'
group by h.id_hospital, h.nombre, c.fecha_hora::date, e.nombre, p.sexo
order by h.id_hospital, fecha, especialidad, p.sexo;
