-- Proyecto 2 - Objetivo 11
-- Ingresos monetarios totales de cada hospital en un lapso de tiempo.
--
-- Se muestra lo facturado (servicios prestados) y lo efectivamente cobrado
-- (cuotas pagadas) en el lapso, y la diferencia pendiente de cobro.

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_11(p_desde date, p_hasta date)
returns table (hospital varchar, facturas bigint, total_facturado numeric, total_cobrado numeric, pendiente_de_cobro numeric)
language sql stable
as $$
    with facturado as (
        select id_hospital, count(*) as facturas, sum(total) as total
          from v_factura
         where fecha_emision >= p_desde and fecha_emision < p_hasta + 1
         group by id_hospital
    ), cobrado as (
        select vf.id_hospital, sum(p.monto) as total
          from pago p join v_factura vf on vf.id_factura = p.id_factura
         where p.fecha_pago between p_desde and p_hasta
         group by vf.id_hospital
    )
    select h.nombre, coalesce(f.facturas, 0), coalesce(f.total, 0), coalesce(c.total, 0),
           coalesce(f.total, 0) - coalesce(c.total, 0)
      from hospital h
      left join facturado f on f.id_hospital = h.id_hospital
      left join cobrado c on c.id_hospital = h.id_hospital
     order by 3 desc;
$$;

comment on function fn_objetivo_11(date, date) is 'Objetivo 11: ingresos totales (facturado y cobrado) por hospital.';

reset role;
commit;

set role visor;
select * from fn_objetivo_11('2026-01-01', '2026-10-31');
reset role;
