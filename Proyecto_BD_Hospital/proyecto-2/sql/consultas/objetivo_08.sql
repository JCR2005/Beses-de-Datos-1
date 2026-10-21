-- Proyecto 2 - Objetivo 8
-- Total pagado en efectivo, tarjeta de credito y tarjeta de debito en cada
-- hospital, como la suma de los pagos de cada una de sus unidades.
--
-- La unidad de cada pago es la de la factura que paga (v_factura la obtiene
-- de la cita, el ingreso o la cirugia que la origino).

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_08(p_desde date, p_hasta date)
returns table (hospital varchar, unidad varchar, efectivo numeric, tarjeta_credito numeric, tarjeta_debito numeric)
language sql stable
as $$
    select h.nombre, vf.tipo_unidad,
           coalesce(sum(p.monto) filter (where mp.nombre = 'Efectivo'), 0),
           coalesce(sum(p.monto) filter (where mp.nombre = 'Tarjeta de crédito'), 0),
           coalesce(sum(p.monto) filter (where mp.nombre = 'Tarjeta de débito'), 0)
      from pago p
      join metodo_pago mp on mp.id_metodo_pago = p.id_metodo_pago
      join v_factura vf on vf.id_factura = p.id_factura
      join hospital h on h.id_hospital = vf.id_hospital
     where p.fecha_pago between p_desde and p_hasta
     group by h.id_hospital, h.nombre, vf.tipo_unidad
     order by h.id_hospital, vf.tipo_unidad;
$$;

comment on function fn_objetivo_08(date, date) is 'Objetivo 8: pagos por método (efectivo, crédito, débito) por hospital y unidad.';

reset role;
commit;

set role visor;
select * from fn_objetivo_08('2026-01-01', '2026-10-31');
reset role;
