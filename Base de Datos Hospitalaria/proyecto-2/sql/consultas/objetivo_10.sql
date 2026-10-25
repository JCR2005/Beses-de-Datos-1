-- Objetivo 10: por hospital, la fecha con mas decesos (egresos con codigo "muerto")
-- y la unidad medica donde se han registrado mas.
-- Se resuelve con dos consultas. En cada una se cuentan los decesos por grupo y el
-- HAVING se queda con el grupo que tiene el maximo de su hospital (si hay empate,
-- salen todos los empatados). No lleva lapso: el objetivo pide la fecha historica.

-- fecha con mas decesos de cada hospital
select h.nombre as hospital,
       e.fecha_hora_egreso::date as fecha,
       count(*) as decesos
from egreso e
inner join ingreso i on i.id_ingreso = e.id_ingreso
inner join unidad_medica u on u.id_unidad = i.id_unidad
inner join hospital h on h.id_hospital = u.id_hospital
where e.codigo_egreso = 'muerto'
group by h.id_hospital, h.nombre, e.fecha_hora_egreso::date
having count(*) = (select max(total)
                   from (select count(*) as total
                         from egreso e2
                         inner join ingreso i2 on i2.id_ingreso = e2.id_ingreso
                         inner join unidad_medica u2 on u2.id_unidad = i2.id_unidad
                         where e2.codigo_egreso = 'muerto'
                           and u2.id_hospital = h.id_hospital
                         group by e2.fecha_hora_egreso::date) por_fecha)
order by decesos desc, hospital, fecha;

-- unidad medica con mas decesos de cada hospital
select h.nombre as hospital,
       u.tipo_unidad as unidad,
       count(*) as decesos
from egreso e
inner join ingreso i on i.id_ingreso = e.id_ingreso
inner join unidad_medica u on u.id_unidad = i.id_unidad
inner join hospital h on h.id_hospital = u.id_hospital
where e.codigo_egreso = 'muerto'
group by h.id_hospital, h.nombre, u.tipo_unidad
having count(*) = (select max(total)
                   from (select count(*) as total
                         from egreso e2
                         inner join ingreso i2 on i2.id_ingreso = e2.id_ingreso
                         inner join unidad_medica u2 on u2.id_unidad = i2.id_unidad
                         where e2.codigo_egreso = 'muerto'
                           and u2.id_hospital = h.id_hospital
                         group by u2.tipo_unidad) por_unidad)
order by decesos desc, hospital, unidad;
