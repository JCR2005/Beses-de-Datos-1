-- Objetivo 14: promedio del numero de cuotas de pago por unidad medica en cada hospital
-- (segun el plan de cuotas de cada factura emitida)
-- La unidad de cada factura sale de su origen: la clinica de la cita, la unidad
-- del ingreso o el quirofano de la cirugia (cada factura tiene solo uno).
-- lapso: enero a octubre de 2026

select h.nombre as hospital,
       u.tipo_unidad as unidad,
       count(*) as facturas,
       round(avg(f.numero_cuotas), 2) as promedio_cuotas,
       min(f.numero_cuotas) as minimo_cuotas,
       max(f.numero_cuotas) as maximo_cuotas
from factura f
left join cita c on c.id_cita = f.id_cita
left join clinica cl on cl.id_clinica = c.id_clinica
left join ingreso i on i.id_ingreso = f.id_ingreso
left join cirugia ci on ci.id_cirugia = f.id_cirugia
left join quirofano q on q.id_quirofano = ci.id_quirofano
inner join unidad_medica u on u.id_unidad in (cl.id_unidad, i.id_unidad, q.id_unidad)
inner join hospital h on h.id_hospital = u.id_hospital
where f.fecha_emision between '2026-01-01' and '2026-10-31 23:59:59'
group by h.id_hospital, h.nombre, u.tipo_unidad
order by h.id_hospital, u.tipo_unidad;
