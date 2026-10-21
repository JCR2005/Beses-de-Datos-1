-- Proyecto 2 - Objetivo 14
-- Promedio del numero de cuotas de pago por unidad medica en cada hospital, en
-- un lapso de tiempo (segun el plan de cuotas de cada factura emitida).

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_14(p_desde date, p_hasta date)
returns table (hospital varchar, unidad varchar, facturas bigint, promedio_cuotas numeric,
               minimo_cuotas smallint, maximo_cuotas smallint)
language sql stable
as $$
    select h.nombre, vf.tipo_unidad, count(*), round(avg(vf.numero_cuotas), 2),
           min(vf.numero_cuotas), max(vf.numero_cuotas)
      from v_factura vf
      join hospital h on h.id_hospital = vf.id_hospital
     where vf.fecha_emision >= p_desde and vf.fecha_emision < p_hasta + 1
     group by h.id_hospital, h.nombre, vf.tipo_unidad
     order by h.id_hospital, vf.tipo_unidad;
$$;

comment on function fn_objetivo_14(date, date) is 'Objetivo 14: promedio de cuotas por unidad y hospital.';

reset role;
commit;

set role visor;
select * from fn_objetivo_14('2026-01-01', '2026-10-31');
reset role;
