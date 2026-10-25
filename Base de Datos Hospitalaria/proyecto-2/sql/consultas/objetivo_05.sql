-- Objetivo 5: los 3 cirujanos mas eficientes
-- primero los que tienen mas agendamientos aprobados y, entre ellos, los que pidieron
-- menos insumos, instrumentos y equipos (cada uno por separado)
-- lapso: enero a octubre de 2026

select m.nombres, m.apellidos,
       count(*) as agendamientos_aprobados,
       sum(coalesce(ri.cantidad, 0)) as insumos,
       sum(coalesce(rn.cantidad, 0)) as instrumentos,
       sum(coalesce(re.cantidad, 0)) as equipos
from agendamiento_quirurgico a
inner join medico m on m.id_medico = a.id_medico_cirujano
left join (select id_agendamiento, sum(cantidad) as cantidad
           from requerimiento_insumo group by id_agendamiento) ri on ri.id_agendamiento = a.id_agendamiento
left join (select id_agendamiento, sum(cantidad) as cantidad
           from requerimiento_instrumento group by id_agendamiento) rn on rn.id_agendamiento = a.id_agendamiento
left join (select id_agendamiento, sum(cantidad) as cantidad
           from requerimiento_equipo group by id_agendamiento) re on re.id_agendamiento = a.id_agendamiento
where a.estado_solicitud = 'aprobada'
  and a.fecha_hora_solicitud between '2026-01-01' and '2026-10-31 23:59:59'
group by m.id_medico, m.nombres, m.apellidos
order by agendamientos_aprobados desc, insumos, instrumentos, equipos
limit 3;
