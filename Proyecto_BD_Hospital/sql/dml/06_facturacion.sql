-- ============================================================
-- 06_facturacion.sql : facturas, pagos en cuotas e insumos de hospitalización
-- ============================================================

SET search_path TO public;

-- Insumos utilizados durante internamientos (costo del servicio de hospitalización)
INSERT INTO hospitalizacion_insumo (id_hospitalizacion_insumo, ingreso_id, insumo_id, cantidad, costo_unitario) OVERRIDING SYSTEM VALUE VALUES
(1, 3, 1, 8, 30.00),
(2, 3, 8, 10, 15.00),
(3, 5, 1, 6, 30.00),
(4, 5, 8, 6, 15.00);

-- Facturas emitidas al finalizar cada proceso (consulta, emergencia, hospitalización y cirugía)
INSERT INTO factura (id_factura, paciente_id, fecha_emision, descripcion, total, cita_id, ingreso_id, cirugia_id) OVERRIDING SYSTEM VALUE VALUES
(1, 1, '2026-08-10 11:30:00-06', 'Consulta de cardiología; reconsulta (75%).', 165.00, 1, NULL, NULL),
(2, 3, '2026-08-12 10:30:00-06', 'Atención de emergencia por politraumatismo; servicio de atención a pacientes politraumatizados.', 1800.00, NULL, 1, NULL),
(3, 2, '2026-08-18 09:45:00-06', 'Hospitalización 4 días: medicina interna + insumos médicos.', 4390.00, NULL, 3, NULL),
(4, 5, '2026-08-12 08:00:00-06', 'Cirugía: apendicectomía (cirugía general) + insumos utilizados.', 9235.00, NULL, NULL, 1),
(5, 5, '2026-08-14 12:00:00-06', 'Hospitalización postoperatoria: 3 días en cuidados intermedios + insumos.', 3870.00, NULL, 5, NULL);

-- Pagos en cuotas (de 1 a 12) por factura
INSERT INTO pago (id_pago, factura_id, numero_cuota, total_cuotas, monto, fecha_pago) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 1, 1, 165.00, '2026-08-10'),
(2, 2, 1, 3, 600.00, '2026-08-12'),
(3, 2, 2, 3, 600.00, '2026-09-12'),
(4, 3, 1, 4, 1097.50, '2026-08-18'),
(5, 3, 2, 4, 1097.50, '2026-09-18'),
(6, 4, 1, 6, 1539.17, '2026-08-12'),
(7, 4, 2, 6, 1539.17, '2026-09-12'),
(8, 5, 1, 3, 1290.00, '2026-08-14');