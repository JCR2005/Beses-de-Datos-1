-- Objetivo 12: edad promedio y cantidad por sexo de los ingresos a emergencias
-- de cada hospital, agrupados por turno (jornada diurna o nocturna).
-- La edad es la que tenia el paciente el dia que ingreso
-- lapso: enero a octubre de 2026

select h.nombre as hospital,
       t.jornada,
       count(*) as ingresos,
       round(avg(extract(year from age(i.fecha_hora_ingreso::date, p.fecha_nacimiento))), 1) as edad_promedio,
       count(case when p.sexo = 'Masculino' then 1 end) as masculino,
       count(case when p.sexo = 'Femenino' then 1 end) as femenino
from ingreso i
inner join turno_emergencia t on t.id_turno = i.id_turno
inner join unidad_medica u on u.id_unidad = i.id_unidad
inner join hospital h on h.id_hospital = u.id_hospital
inner join paciente p on p.id_paciente = i.id_paciente
where i.fecha_hora_ingreso between '2026-01-01' and '2026-10-31 23:59:59'
group by h.id_hospital, h.nombre, t.jornada
order by h.id_hospital, t.jornada;
