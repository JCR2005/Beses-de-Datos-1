-- Objetivo 9: los 3 hospitales con mas ingreso por visita
-- visita = ficha de ingreso (emergencias, cirugia, hospitalizacion) o cita no cancelada.
-- Las consultas se muestran pero no se suman porque ya estan contadas en su cita.
-- El hospital de cada factura sale de su origen: la clinica de la cita, la unidad
-- del ingreso o el quirofano de la cirugia (cada factura tiene solo uno).
-- lapso: enero a octubre de 2026

select hospital, ingresos_fichas, citas, consultas,
       ingresos_fichas + citas as visitas,
       monto_facturado,
       round(monto_facturado / (ingresos_fichas + citas), 2) as ingreso_por_visita
from (select h.nombre as hospital,
             (select count(*)
              from ingreso i
              inner join unidad_medica u on u.id_unidad = i.id_unidad
              where u.id_hospital = h.id_hospital
                and i.fecha_hora_ingreso between '2026-01-01' and '2026-10-31 23:59:59') as ingresos_fichas,
             (select count(*)
              from cita c
              inner join medico m on m.id_medico = c.id_medico
              where m.id_hospital = h.id_hospital
                and c.estado <> 'cancelada'
                and c.fecha_hora between '2026-01-01' and '2026-10-31 23:59:59') as citas,
             (select count(*)
              from consulta co
              inner join cita c on c.id_cita = co.id_cita
              inner join medico m on m.id_medico = c.id_medico
              where m.id_hospital = h.id_hospital
                and c.fecha_hora between '2026-01-01' and '2026-10-31 23:59:59') as consultas,
             (select coalesce(sum(f.total), 0)
              from factura f
              left join cita c on c.id_cita = f.id_cita
              left join clinica cl on cl.id_clinica = c.id_clinica
              left join ingreso i on i.id_ingreso = f.id_ingreso
              left join cirugia ci on ci.id_cirugia = f.id_cirugia
              left join quirofano q on q.id_quirofano = ci.id_quirofano
              inner join unidad_medica u on u.id_unidad in (cl.id_unidad, i.id_unidad, q.id_unidad)
              where u.id_hospital = h.id_hospital
                and f.fecha_emision between '2026-01-01' and '2026-10-31 23:59:59') as monto_facturado
      from hospital h) datos
order by ingreso_por_visita desc
limit 3;
