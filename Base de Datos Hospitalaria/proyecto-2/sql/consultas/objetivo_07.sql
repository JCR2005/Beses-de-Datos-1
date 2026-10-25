-- Objetivo 7: los 3 hospitales con mas ingresos en hospitalizacion
-- con menos camillas asignadas y menor costo de servicio. Se juntan los tres
-- criterios en el ingreso por camilla (lo facturado / camillas usadas)
-- lapso: enero a octubre de 2026

select h.nombre as hospital,
       sum(f.total) as ingresos,
       count(distinct i.id_camilla) as camillas_asignadas,
       round(avg(s.costo), 2) as costo_promedio_servicio,
       round(sum(f.total) / count(distinct i.id_camilla), 2) as ingreso_por_camilla
from factura f
inner join ingreso i on i.id_ingreso = f.id_ingreso
inner join unidad_medica u on u.id_unidad = i.id_unidad
inner join hospital h on h.id_hospital = u.id_hospital
inner join servicio_atencion s on s.id_servicio = i.id_servicio
where u.tipo_unidad = 'Hospitalización'
  and f.fecha_emision between '2026-01-01' and '2026-10-31 23:59:59'
group by h.nombre
order by ingreso_por_camilla desc, costo_promedio_servicio
limit 3;
