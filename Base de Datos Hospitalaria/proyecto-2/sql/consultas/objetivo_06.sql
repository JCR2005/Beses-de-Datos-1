-- Objetivo 6: los 3 tipos de cirugia con mas ingresos
-- solo cirugias "sin complicaciones" en las que todos los aspectos de la fase
-- intraoperatoria salieron en exito o aceptables (ninguna falla ni no aceptable)
-- lapso: enero a octubre de 2026

select tc.nombre as tipo_cirugia,
       e.nombre as especialidad,
       count(*) as cirugias,
       sum(f.total) as ingresos
from cirugia ci
inner join agendamiento_quirurgico a on a.id_agendamiento = ci.id_agendamiento
inner join tipo_cirugia tc on tc.id_tipo_cirugia = a.id_tipo_cirugia
inner join especialidad e on e.id_especialidad = tc.id_especialidad
inner join factura f on f.id_cirugia = ci.id_cirugia
where ci.condicion_evolucion = 'sin_complicaciones'
  and ci.fecha_hora_inicio between '2026-01-01' and '2026-10-31 23:59:59'
  and not exists (select 1
                  from registro_procedimiento rp
                  inner join aspecto_quirurgico aq on aq.id_aspecto = rp.id_aspecto
                  where rp.id_cirugia = ci.id_cirugia
                    and aq.etapa = 'intraoperatorio'
                    and rp.resultado not in ('exito', 'aceptable'))
group by tc.nombre, e.nombre
order by ingresos desc
limit 3;
