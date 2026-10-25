-- Objetivo 4: los 3 hospitales mas eficientes en emergencias
-- eficiente = tiene camilla libre cuando llega el paciente: mayor porcentaje de
-- ingresos atendidos sin esperar turno y menor promedio de turnos de espera
-- lapso: enero a octubre de 2026

select h.nombre as hospital,
       count(*) as ingresos,
       count(e.id_egreso) as egresos,
       count(case when i.turnos_espera = 0 then 1 end) as atendidos_sin_espera,
       round(100.0 * count(case when i.turnos_espera = 0 then 1 end) / count(*), 1) as porcentaje_sin_espera,
       round(avg(i.turnos_espera), 2) as promedio_turnos_espera
from ingreso i
inner join unidad_medica u on u.id_unidad = i.id_unidad
inner join hospital h on h.id_hospital = u.id_hospital
left join egreso e on e.id_ingreso = i.id_ingreso
where u.tipo_unidad = 'Emergencias'
  and i.fecha_hora_ingreso between '2026-01-01' and '2026-10-31 23:59:59'
group by h.nombre
order by porcentaje_sin_espera desc, promedio_turnos_espera, ingresos desc
limit 3;
