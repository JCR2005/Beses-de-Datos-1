-- Proyecto 2 - BD Hospitales de Occidente
-- 06_facturacion.sql : facturas y pagos en cuotas de la actividad de enero a octubre de 2026 (datos FICTICIOS)
--
-- Se emite una factura por cada proceso terminado, con el costo que fija el
-- enunciado para cada unidad, y se pagan las cuotas vencidas al 20 de octubre.

begin;
set role admin;
set search_path to public;

-- consulta externa: el costo de la cita, en un solo pago en la recepcion del medico
insert into factura (id_cita, fecha_emision, descripcion, total, numero_cuotas)
select ci.id_cita, ci.fecha_hora + interval '1 hour', 'Consulta externa de ' || lower(es.nombre) || '.', ci.costo_final, 1
  from consulta co
  join cita ci on ci.id_cita = co.id_cita
  join medico me on me.id_medico = ci.id_medico
  join especialidad es on es.id_especialidad = me.id_especialidad
 where ci.id_cita > 100;

-- emergencias: el costo del servicio brindado, de 1 a 4 cuotas
insert into factura (id_ingreso, fecha_emision, descripcion, total, numero_cuotas)
select i.id_ingreso, e.fecha_hora_egreso + interval '30 minutes', 'Atención de emergencia: ' || lower(s.nombre) || '.',
       s.costo, 1 + i.id_ingreso % 4
  from ingreso i
  join egreso e on e.id_ingreso = i.id_ingreso
  join servicio_atencion s on s.id_servicio = i.id_servicio
 where i.id_ingreso between 1001 and 1155;

-- hospitalizacion: dias internado x costo por dia + servicio + insumos usados, de 1 a 12 cuotas
insert into factura (id_ingreso, fecha_emision, descripcion, total, numero_cuotas)
select i.id_ingreso, e.fecha_hora_egreso + interval '1 hour',
       format('Hospitalización %s días: %s + insumos.', greatest(1, e.fecha_hora_egreso::date - i.fecha_hora_ingreso::date), lower(s.nombre)),
       greatest(1, e.fecha_hora_egreso::date - i.fecha_hora_ingreso::date) * u.costo_dia_hospitalizacion + s.costo
         + coalesce((select sum(hi.cantidad * hi.costo_unitario) from hospitalizacion_insumo hi where hi.id_ingreso = i.id_ingreso), 0),
       1 + i.id_ingreso % 12
  from ingreso i
  join egreso e on e.id_ingreso = i.id_ingreso
  join unidad_medica u on u.id_unidad = i.id_unidad
  join servicio_atencion s on s.id_servicio = i.id_servicio
 where i.id_ingreso between 2001 and 2060;

-- cirugia: costo segun el tipo de cirugia + insumos usados, de 1 a 12 cuotas
insert into factura (id_cirugia, fecha_emision, descripcion, total, numero_cuotas)
select c.id_cirugia, c.fecha_hora_fin + interval '2 hours', 'Cirugía: ' || lower(t.nombre) || ' + insumos utilizados.',
       s.costo + coalesce((select sum(ci.cantidad * ci.costo_unitario) from cirugia_insumo ci where ci.id_cirugia = c.id_cirugia), 0),
       1 + c.id_cirugia % 12
  from cirugia c
  join agendamiento_quirurgico a on a.id_agendamiento = c.id_agendamiento
  join tipo_cirugia t on t.id_tipo_cirugia = a.id_tipo_cirugia
  join ingreso i on i.id_ingreso = c.id_ingreso
  join servicio_atencion s on s.id_servicio = i.id_servicio
 where c.id_cirugia > 100;

-- ============================================================
-- pagos: la primera cuota al emitir la factura y una por cada mes transcurrido
-- ============================================================
-- la ultima cuota ajusta los centavos para que la suma sea exactamente el total

insert into pago (id_factura, numero_cuota, monto, fecha_pago, id_metodo_pago)
select f.id_factura, k.cuota,
       case when k.cuota = f.numero_cuotas
            then f.total - round(f.total / f.numero_cuotas, 2) * (f.numero_cuotas - 1)
            else round(f.total / f.numero_cuotas, 2) end,
       (f.fecha_emision::date + (k.cuota - 1) * interval '1 month')::date,
       case when (f.id_factura * k.cuota) % 11 = 0 then 4 else 1 + (f.id_factura + k.cuota) % 3 end
  from factura f
 cross join lateral generate_series(1, least(f.numero_cuotas,
        1 + (extract(year from age(date '2026-10-20', f.fecha_emision::date)) * 12
             + extract(month from age(date '2026-10-20', f.fecha_emision::date)))::int)) as k(cuota)
 where f.id_factura > 5;

reset role;
commit;
