-- Objetivo 8: total pagado en efectivo, tarjeta de credito y tarjeta de debito
-- en cada hospital, sumando los pagos de cada una de sus unidades.
-- La unidad de cada factura sale de su origen: la clinica de la cita, la unidad
-- del ingreso o el quirofano de la cirugia (cada factura tiene solo uno).
-- lapso: enero a octubre de 2026

select h.nombre as hospital,
       u.tipo_unidad as unidad,
       sum(case when mp.nombre = 'Efectivo' then p.monto else 0 end) as efectivo,
       sum(case when mp.nombre = 'Tarjeta de crédito' then p.monto else 0 end) as tarjeta_credito,
       sum(case when mp.nombre = 'Tarjeta de débito' then p.monto else 0 end) as tarjeta_debito
from pago p
inner join metodo_pago mp on mp.id_metodo_pago = p.id_metodo_pago
inner join factura f on f.id_factura = p.id_factura
left join cita c on c.id_cita = f.id_cita
left join clinica cl on cl.id_clinica = c.id_clinica
left join ingreso i on i.id_ingreso = f.id_ingreso
left join cirugia ci on ci.id_cirugia = f.id_cirugia
left join quirofano q on q.id_quirofano = ci.id_quirofano
inner join unidad_medica u on u.id_unidad in (cl.id_unidad, i.id_unidad, q.id_unidad)
inner join hospital h on h.id_hospital = u.id_hospital
where p.fecha_pago between '2026-01-01' and '2026-10-31'
group by h.id_hospital, h.nombre, u.tipo_unidad
order by h.id_hospital, u.tipo_unidad;
