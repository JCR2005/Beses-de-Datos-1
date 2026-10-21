-- Proyecto 2 - Objetivo 7
-- Los 3 hospitales con mayores ingresos en hospitalizacion en un lapso de tiempo,
-- con el menor numero de camillas asignadas y el menor costo de servicio.
--
-- Se combinan los tres criterios en el ingreso por camilla: lo facturado en
-- hospitalizacion dividido entre las camillas que se asignaron. Tambien se
-- muestran el total facturado, las camillas y el costo promedio del servicio.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_07(p_desde date, p_hasta date)
returns table (hospital varchar, ingresos numeric, camillas_asignadas bigint,
               costo_promedio_servicio numeric, ingreso_por_camilla numeric)
language sql stable
as $$
    select h.nombre,
           sum(f.total),
           count(distinct i.id_camilla),
           round(avg(s.costo), 2),
           round(sum(f.total) / count(distinct i.id_camilla), 2)
      from factura f
      join ingreso i on i.id_ingreso = f.id_ingreso
      join unidad_medica u on u.id_unidad = i.id_unidad
      join hospital h on h.id_hospital = u.id_hospital
      join servicio_atencion s on s.id_servicio = i.id_servicio
     where u.tipo_unidad = 'Hospitalización'
       and f.fecha_emision >= p_desde and f.fecha_emision < p_hasta + 1
     group by h.id_hospital, h.nombre
     order by 5 desc
     limit 3;
$$;

comment on function fn_objetivo_07(date, date) is 'Objetivo 7: 3 hospitales con mayor ingreso por camilla en hospitalización.';

reset role;
commit;

set role visor;
select * from fn_objetivo_07('2026-01-01', '2026-10-31');
reset role;
