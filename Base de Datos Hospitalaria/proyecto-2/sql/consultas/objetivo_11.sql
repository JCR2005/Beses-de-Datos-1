-- Objetivo 11: ingresos monetarios totales de cada hospital
-- lo facturado (servicios prestados), lo cobrado (cuotas pagadas) y lo pendiente.
-- El hospital de cada factura sale de su origen: la clinica de la cita, la unidad
-- del ingreso o el quirofano de la cirugia (cada factura tiene solo uno).
-- lapso: enero a octubre de 2026

select hospital, facturas, total_facturado, total_cobrado,
       total_facturado - total_cobrado as pendiente_de_cobro
from (select h.nombre as hospital,
             (select count(*)
              from factura f
              left join cita c on c.id_cita = f.id_cita
              left join clinica cl on cl.id_clinica = c.id_clinica
              left join ingreso i on i.id_ingreso = f.id_ingreso
              left join cirugia ci on ci.id_cirugia = f.id_cirugia
              left join quirofano q on q.id_quirofano = ci.id_quirofano
              inner join unidad_medica u on u.id_unidad in (cl.id_unidad, i.id_unidad, q.id_unidad)
              where u.id_hospital = h.id_hospital
                and f.fecha_emision between '2026-01-01' and '2026-10-31 23:59:59') as facturas,
             (select coalesce(sum(f.total), 0)
              from factura f
              left join cita c on c.id_cita = f.id_cita
              left join clinica cl on cl.id_clinica = c.id_clinica
              left join ingreso i on i.id_ingreso = f.id_ingreso
              left join cirugia ci on ci.id_cirugia = f.id_cirugia
              left join quirofano q on q.id_quirofano = ci.id_quirofano
              inner join unidad_medica u on u.id_unidad in (cl.id_unidad, i.id_unidad, q.id_unidad)
              where u.id_hospital = h.id_hospital
                and f.fecha_emision between '2026-01-01' and '2026-10-31 23:59:59') as total_facturado,
             (select coalesce(sum(p.monto), 0)
              from pago p
              inner join factura f on f.id_factura = p.id_factura
              left join cita c on c.id_cita = f.id_cita
              left join clinica cl on cl.id_clinica = c.id_clinica
              left join ingreso i on i.id_ingreso = f.id_ingreso
              left join cirugia ci on ci.id_cirugia = f.id_cirugia
              left join quirofano q on q.id_quirofano = ci.id_quirofano
              inner join unidad_medica u on u.id_unidad in (cl.id_unidad, i.id_unidad, q.id_unidad)
              where u.id_hospital = h.id_hospital
                and p.fecha_pago between '2026-01-01' and '2026-10-31') as total_cobrado
      from hospital h) datos
order by total_facturado desc;
