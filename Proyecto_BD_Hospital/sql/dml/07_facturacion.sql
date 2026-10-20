-- Proyecto 1 - BD Hospitales de Occidente
-- 07_facturacion.sql : insumos de hospitalizacion, facturas y pagos (datos FICTICIOS)

set search_path to public;

-- insumos usados durante los internamientos (suman al costo de hospitalizacion)
insert into hospitalizacion_insumo (id_ingreso, id_insumo, cantidad, costo_unitario) values
(3, 1, 8, 30.00),
(3, 8, 10, 15.00),
(5, 1, 6, 30.00),
(5, 8, 6, 15.00);

-- una factura por proceso terminado: consulta, emergencia, hospitalizacion o cirugia
insert into factura (id_factura, id_cita, id_ingreso, id_cirugia, fecha_emision, descripcion, total, numero_cuotas) values
(1, 1, null, null, '2026-08-10 11:30-06', 'Consulta de cardiología; reconsulta (75%).', 165.00, 1),
(2, null, 1, null, '2026-08-12 10:30-06', 'Atención de emergencia por politraumatismo.', 1800.00, 3),
(3, null, 3, null, '2026-08-18 09:45-06', 'Hospitalización 4 días: medicina interna + insumos médicos.', 4390.00, 4),
(4, null, null, 1, '2026-08-12 08:00-06', 'Cirugía: apendicectomía (cirugía general) + insumos utilizados.', 9235.00, 6),
(5, null, 5, null, '2026-08-14 12:00-06', 'Hospitalización postoperatoria: 3 días en cuidados intermedios + insumos.', 3870.00, 3);

-- cuotas pagadas hasta la fecha
insert into pago (id_pago, id_factura, numero_cuota, monto, fecha_pago, id_metodo_pago) values
(1, 1, 1, 165.00, '2026-08-10', 1),
(2, 2, 1, 600.00, '2026-08-12', 2),
(3, 2, 2, 600.00, '2026-09-12', 2),
(4, 3, 1, 1097.50, '2026-08-18', 3),
(5, 3, 2, 1097.50, '2026-09-18', 1),
(6, 4, 1, 1539.17, '2026-08-12', 2),
(7, 4, 2, 1539.17, '2026-09-12', 2),
(8, 5, 1, 1290.00, '2026-08-14', 3);
