
-- ##################################################
-- SECCION 1: PRUEBAS DE VISTAS
-- ##################################################

-- Vista 1: v_resumen_temporada
-- Verifica: total quintales por semana, tipo de cafe y categoria productor
SELECT * FROM v_resumen_temporada;

-- Vista 2: v_saldo_bodegas
-- Verifica: saldo actual por bodega, tipo y clasificacion
SELECT * FROM v_saldo_bodegas ORDER BY bodega, clasificacion;

-- Vista 3: v_socios_activos_terrenos
-- Verifica: socios activos con numero de terrenos y area total
SELECT * FROM v_socios_activos_terrenos;

-- Vista 4: v_pagos_pendientes
-- Verifica: facturas con saldo pendiente > 0
SELECT * FROM v_pagos_pendientes;

-- Vista 5: v_contratos_avance
-- Verifica: contratos vigentes con progreso de exportacion
SELECT * FROM v_contratos_avance;

-- Vista 6: v_trazabilidad_lote
-- Verifica: historial completo de lotes
SELECT * FROM v_trazabilidad_lote LIMIT 20;

-- Vista 7: v_rendimiento_terrenos
-- Verifica: rendimiento por terreno incluyendo especialidad
SELECT * FROM v_rendimiento_terrenos;

-- ##################################################
-- SECCION 2: PRUEBAS DE FUNCIONES ESCALARES
-- ##################################################

-- fn_precio_compra
-- Caso 1: productor socio activo (debe retornar precio_base * 1.10)
SELECT fn_precio_compra(1, 'cereza'::tipo_cafe_enum, '2026-03-01') AS precio_socio;
-- Caso 2: productor externo (debe retornar precio_base sin incremento)
SELECT fn_precio_compra(16, 'cereza'::tipo_cafe_enum, '2026-03-01') AS precio_externo;
-- Caso 3: pergamino_seco para socio
SELECT fn_precio_compra(6, 'pergamino_seco'::tipo_cafe_enum, '2026-01-15') AS precio_seco_socio;
-- Verificacion: diferencia entre socio y externo debe ser 10%
SELECT
    fn_precio_compra(1,  'cereza'::tipo_cafe_enum, '2026-01-01') AS precio_socio,
    fn_precio_compra(16, 'cereza'::tipo_cafe_enum, '2026-01-01') AS precio_externo,
    ROUND((fn_precio_compra(1,'cereza'::tipo_cafe_enum,'2026-01-01')
           / fn_precio_compra(16,'cereza'::tipo_cafe_enum,'2026-01-01') - 1) * 100, 2)
    AS diferencia_porcentual;

-- fn_area_terreno
-- Caso 1: calcular area del terreno 1 (debe actualizar area_calculada_cuerdas)
SELECT fn_area_terreno(1) AS area_terreno_1;
-- Caso 2: calcular area del terreno con mayor cantidad de esquineros
SELECT fn_area_terreno(6) AS area_terreno_6;
-- Verificacion: el campo area_calculada_cuerdas debe actualizarse
SELECT id, codigo, area_estimada_cuerdas, area_calculada_cuerdas
FROM   terrenos WHERE id IN (1, 6);

-- fn_saldo_contrato
-- Caso 1: contrato 1 deberia estar en 0 (100 qq pactados, 100 exportados)
SELECT fn_saldo_contrato(1) AS saldo_contrato_1;
-- Caso 2: contrato 2 deberia estar en 0 (200 pactados, 200 exportados en 2 parciales)
SELECT fn_saldo_contrato(2) AS saldo_contrato_2;
-- Caso 3: contrato 3 deberia tener saldo pendiente (300 pactados, solo 50 exportados)
SELECT fn_saldo_contrato(3) AS saldo_contrato_3;

-- fn_clasificar_socio
-- Tipo A: puntuacion >= 80
SELECT fn_clasificar_socio(1) AS tipo_ev1;   -- puntuacion 88 → A
-- Tipo B: puntuacion entre 60 y 79
SELECT fn_clasificar_socio(2) AS tipo_ev2;   -- puntuacion 74 → B
-- Tipo C: puntuacion < 60
SELECT fn_clasificar_socio(4) AS tipo_ev4;   -- puntuacion 55 → C
-- Tabla resumen de clasificaciones
SELECT id, terreno_id, puntuacion_tecnica,
       fn_clasificar_socio(id) AS tipo_calculado
FROM   evaluaciones_tecnicas
WHERE  estado = 'aprobada'
ORDER  BY puntuacion_tecnica DESC;

-- ##################################################
-- SECCION 3: PRUEBAS DE PROCEDIMIENTOS ALMACENADOS
-- ##################################################

-- sp_registrar_recibo
-- Caso 1: registro nuevo recibo socio activo
CALL sp_registrar_recibo(
    'REC-PRUEBA-001',   -- numero
    1,                  -- bodega_id (La Union)
    1,                  -- productor_id (socio activo → precio +10%)
    9,                  -- bodeguero_id
    2,                  -- supervisor_id
    'cereza'::tipo_cafe_enum,
    25.00,              -- peso_bruto_qq
    24.50,              -- peso_neto_qq
    '2026-04-20',       -- fecha_recibo
    '08:30:00'::TIME,   -- hora_recibo
    7,                  -- contador_id
    'efectivo'::forma_pago_enum
);
-- Verificar que se creo el recibo y la factura
SELECT r.numero, r.fecha_recibo, r.peso_neto_qq,
       f.numero AS factura, f.precio_unitario, f.monto_total
FROM   recibos r JOIN facturas_compra f ON f.recibo_id = r.id
WHERE  r.numero = 'REC-PRUEBA-001';

-- Caso 2: registro con anticipo y pago en cheque
CALL sp_registrar_recibo(
    'REC-PRUEBA-002',
    2,
    6,
    10,
    3,
    'pergamino_seco'::tipo_cafe_enum,
    30.00,
    29.50,
    '2026-04-21',
    '09:00:00'::TIME,
    8,
    'cheque'::forma_pago_enum,
    2000.00,            -- anticipo
    'Banrural',         -- banco
    'CH-PRUEBA-001',    -- num_cheque
    '2026-04-21'        -- fecha_cheque
);
-- Verificar saldo descuenta el anticipo
SELECT f.numero, f.monto_total, f.anticipo, f.saldo_pagar
FROM   facturas_compra f
JOIN   recibos r ON r.id = f.recibo_id
WHERE  r.numero = 'REC-PRUEBA-002';

-- sp_trasladar_cafe
-- Caso 1: traslado valido de bodega 1 a bodega central
CALL sp_trasladar_cafe(
    'TRS-PRUEBA-001',   -- numero
    1,                  -- bodega_origen (La Union)
    4,                  -- bodega_destino (Central)
    2,                  -- clasificacion_id (Superior)
    4,                  -- tipo_cafe_id (cafe_oro)
    20.00,              -- cantidad_qq
    13,                 -- transportista_id
    1,                  -- vehiculo_id (activo)
    9                   -- bodeguero_despacha
);
-- Verificar que se descontó en origen y se acreditó en destino
SELECT b.nombre AS bodega, tc.nombre AS tipo, cc.nombre AS clasificacion, ic.cantidad_qq
FROM   inventario_cafe ic
JOIN   bodegas b ON b.id = ic.bodega_id
JOIN   tipos_cafe tc ON tc.id = ic.tipo_cafe_id
LEFT JOIN clasificaciones_cafe cc ON cc.id = ic.clasificacion_id
WHERE  ic.bodega_id IN (1, 4) AND ic.clasificacion_id = 2
ORDER  BY b.nombre;

-- Caso 2: traslado con saldo insuficiente (debe lanzar excepcion)
DO $$
BEGIN
    CALL sp_trasladar_cafe(
        'TRS-PRUEBA-ERR',
        1,
        4,
        1,
        4,
        99999.00,  -- cantidad mayor al stock
        13, 1, 9
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ERROR ESPERADO: %', SQLERRM;
END $$;

-- sp_registrar_exportacion
-- Caso 1: exportacion valida contra contrato 3 (tiene saldo disponible)
CALL sp_registrar_exportacion(
    'EXP-PRUEBA-001',   -- numero
    3,                  -- contrato_id
    4,                  -- bodega_origen (central)
    13,                 -- transportista
    1,                  -- vehiculo
    1,                  -- autorizador
    '2026-04-25',       -- fecha_despacho
    50.00,              -- quintales_exportados
    4,                  -- tipo_cafe_id
    1,                  -- clasificacion_id (Extra)
    'PRUEBA-CONT-001',  -- num_contenedor
    'Puerto Quetzal'    -- puerto_salida
);
-- Verificar nuevo saldo del contrato 3
SELECT fn_saldo_contrato(3) AS saldo_restante_contrato_3;

-- Caso 2: exportacion que excede saldo (debe fallar)
DO $$
BEGIN
    CALL sp_registrar_exportacion(
        'EXP-PRUEBA-ERR',
        1,    -- contrato_id 1 (ya cumplido, saldo = 0)
        4, 13, 1, 1,
        '2026-04-26',
        500.00,  -- mas de lo disponible
        4, 1
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ERROR ESPERADO: %', SQLERRM;
END $$;

-- sp_agendar_visita
-- Caso 1: agendar visita valida
CALL sp_agendar_visita(
    1,                                                      -- gerente_id
    5,                                                      -- tecnico_id
    '2026-05-10',                                           -- fecha_programada
    ARRAY[1, 2],                                            -- terrenos a visitar
    ARRAY['fertilizacion','control_plagas']::tipo_aplicacion_enum[],
    ARRAY['Urea 46%', 'Clorpirifós 480'],                   -- productos
    ARRAY['2 qq/cuerda', '1 lt/200 lts agua'],              -- dosis
    ARRAY['Aplicar al pie', 'Horas frescas']                -- instrucciones
);
-- Verificar que se creo la visita y sus terrenos
SELECT vt.id AS visita, vt.fecha_programada, vt.estado,
       e.nombre || ' ' || e.apellido AS tecnico,
       vtr.terreno_id, t.nombre AS terreno, vtr.tipo_aplicacion
FROM   visitas_tecnicas vt
JOIN   empleados e ON e.id = vt.tecnico_id
JOIN   visita_terrenos vtr ON vtr.visita_id = vt.id
JOIN   terrenos t ON t.id = vtr.terreno_id
WHERE  vt.fecha_programada = '2026-05-10';

-- Caso 2: mismo tecnico misma fecha (debe lanzar excepcion)
DO $$
BEGIN
    CALL sp_agendar_visita(
        1, 5, '2026-05-10',  -- tecnico 5 ya tiene visita ese dia
        ARRAY[3],
        ARRAY['riego']::tipo_aplicacion_enum[]
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ERROR ESPERADO: %', SQLERRM;
END $$;

-- sp_aprobar_evaluacion
-- Caso 1: aprobar evaluacion pendiente (id=16)
CALL sp_aprobar_evaluacion(
    16,           -- evaluacion_id (estado pendiente)
    2,            -- supervisor_id
    'aprobada'::estado_evaluacion_enum,
    'Terreno con buen potencial, aprobado como Tipo B según puntuación'
);
-- Verificar que se actualizo el estado y el tipo del socio
SELECT et.id, et.estado, et.puntuacion_tecnica,
       et.comentario_supervisor, et.fecha_decision,
       s.tipo_asociacion
FROM   evaluaciones_tecnicas et
JOIN   terrenos t ON t.id = et.terreno_id
LEFT JOIN socios s ON s.productor_id = t.productor_id
WHERE  et.id = 16;

-- Caso 2: rechazar con comentario
-- Primero insertamos una evaluacion de prueba en estado pendiente
INSERT INTO evaluaciones_tecnicas (terreno_id, tecnico_id, fecha_evaluacion,
    plantas_por_cuerda, edad_cafetal_anios, variedad_id, puntuacion_tecnica, estado)
VALUES (4, 5, '2026-04-01', 350, 3, 5, 42.00, 'pendiente');

CALL sp_aprobar_evaluacion(
    (SELECT MAX(id) FROM evaluaciones_tecnicas),
    2,
    'rechazada'::estado_evaluacion_enum,
    'Puntuación insuficiente, pendiente de mejoras estructurales en el terreno'
);
-- Verificar rechazo
SELECT id, terreno_id, estado, comentario_supervisor, fecha_decision
FROM   evaluaciones_tecnicas
ORDER  BY id DESC LIMIT 1;

-- Caso 3: rechazar sin comentario (debe lanzar excepcion)
DO $$
BEGIN
    CALL sp_aprobar_evaluacion(1, 2, 'rechazada'::estado_evaluacion_enum, '');
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ERROR ESPERADO: %', SQLERRM;
END $$;

-- ##################################################
-- SECCION 4: PRUEBAS DE TRIGGERS
-- ##################################################

-- TRIGGER 1: trg_auditoria_empleados (AFTER UPDATE)
-- Modificar salario y nombre → debe crear registros en auditoria_empleados
UPDATE empleados SET salario_base = 9800.00 WHERE id = 5;
UPDATE empleados SET nombre = 'Juan Carlos' WHERE id = 5;
-- Verificar registros de auditoria
SELECT empleado_id, campo_modificado, valor_anterior, valor_nuevo, fecha_cambio
FROM   auditoria_empleados
WHERE  empleado_id = 5
ORDER  BY fecha_cambio DESC;

-- TRIGGER 2: trg_historial_rol (BEFORE UPDATE)
-- Cambiar rol del empleado 16 de Cargador a Bodeguero
UPDATE empleados SET rol_id = 5 WHERE id = 16;  -- 5 = Bodeguero
-- Verificar que se cerro el registro anterior y se creo uno nuevo
SELECT empleado_id, rol_id, fecha_inicio, fecha_fin
FROM   historial_roles
WHERE  empleado_id = 16
ORDER  BY fecha_inicio;

-- TRIGGER 3: trg_validar_contrato (BEFORE INSERT en exportaciones)
-- Intentar exportar mas de lo disponible en contrato 1 (saldo = 0)
DO $$
BEGIN
    INSERT INTO exportaciones (numero, contrato_id, bodega_origen_id,
        transportista_id, vehiculo_id, autorizador_id,
        fecha_despacho, quintales_exportados, num_contenedor, puerto_salida)
    VALUES ('TRG-TEST-001', 1, 4, 13, 1, 1, '2026-04-30', 999.00, 'TEST', 'Puerto Quetzal');
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'trg_validar_contrato OK: %', SQLERRM;
END $$;

-- TRIGGER 4: trg_actualizar_inventario_recibo (AFTER INSERT en recibos)
-- El inventario ya se actualizó con los inserts. Verificamos un recibo especifico.
-- Insertar recibo de prueba y verificar que se creo en inventario_cafe
INSERT INTO recibos (numero, bodega_id, productor_id, bodeguero_id, supervisor_id,
    tipo_cafe_id, peso_bruto_qq, peso_neto_qq, fecha_recibo, hora_recibo)
VALUES ('REC-TRG-004', 1, 2, 9, 2, 2, 10.00, 9.80, '2026-04-26', '08:00:00');

-- Verificar que el inventario se incremento automaticamente
SELECT b.nombre AS bodega, tc.nombre AS tipo_cafe,
       ic.clasificacion_id, ic.cantidad_qq
FROM   inventario_cafe ic
JOIN   bodegas b ON b.id = ic.bodega_id
JOIN   tipos_cafe tc ON tc.id = ic.tipo_cafe_id
WHERE  ic.bodega_id = 1 AND ic.tipo_cafe_id = 2;

-- Verificar movimiento registrado automaticamente
SELECT tipo_movimiento, cantidad_qq, fecha
FROM   movimientos_inventario
WHERE  referencia_id = (SELECT id FROM recibos WHERE numero = 'REC-TRG-004');

-- TRIGGER 5: trg_bono_especialidad (AFTER INSERT en control_calidad)
-- Insertar control calidad con puntaje >= 80 → debe generar bono automaticamente
-- Primero creamos un recibo de prueba
INSERT INTO recibos (numero, bodega_id, productor_id, bodeguero_id, supervisor_id,
    tipo_cafe_id, peso_bruto_qq, peso_neto_qq, fecha_recibo, hora_recibo)
VALUES ('REC-TRG-005', 1, 6, 9, 2, 3, 20.00, 19.50, '2026-04-26', '09:00:00');

-- Insertar control de calidad con especialidad
INSERT INTO control_calidad (recibo_id, responsable_id, porcentaje_humedad,
    rendimiento_estimado, defectos, puntaje_taza, es_especialidad, fecha_evaluacion)
VALUES (
    (SELECT id FROM recibos WHERE numero = 'REC-TRG-005'),
    5, 11.50, 83.00, 'Sin defectos', 85.00, FALSE, '2026-04-26'
);
-- Verificar bono creado automaticamente
SELECT b.recibo_id, b.quintales, b.bono_por_quintal, b.monto_total_bono, b.pagado
FROM   bonos_especialidad b
JOIN   recibos r ON r.id = b.recibo_id
WHERE  r.numero = 'REC-TRG-005';

-- Verificar que es_especialidad se actualizo a TRUE
SELECT recibo_id, puntaje_taza, es_especialidad
FROM   control_calidad
WHERE  recibo_id = (SELECT id FROM recibos WHERE numero = 'REC-TRG-005');

-- TRIGGER 6: trg_prevent_delete_socio_activo (BEFORE DELETE en socios)
-- Intentar eliminar socio con recibos en temporada activa
DO $$
BEGIN
    DELETE FROM socios WHERE id = 1;  -- tiene recibos activos
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'trg_prevent_delete_socio_activo OK: %', SQLERRM;
END $$;

-- Verificar que el socio sigue existiendo
SELECT id, productor_id, estado_membresia
FROM   socios WHERE id = 1;

-- TRIGGER 7: trg_log_precios (AFTER INSERT OR UPDATE en precios_cafe)
-- Verificar que los cambios de precio quedaron registrados
SELECT lp.id, tc.nombre AS tipo_cafe,
       lp.precio_anterior, lp.precio_nuevo,
       lp.variacion_abs, lp.variacion_pct,
       lp.fecha_cambio
FROM   log_precios lp
JOIN   tipos_cafe tc ON tc.id = lp.tipo_cafe_id
ORDER  BY lp.fecha_cambio;

-- Insertar nuevo precio y verificar que se registra en log
INSERT INTO precios_cafe (tipo_cafe_id, precio_quintal, fecha_vigencia)
VALUES (1, 225.00, '2026-05-01');
-- Verificar nuevo registro en log
SELECT lp.precio_anterior, lp.precio_nuevo, lp.variacion_abs, lp.variacion_pct
FROM   log_precios lp
WHERE  lp.tipo_cafe_id = 1
ORDER  BY lp.fecha_cambio DESC LIMIT 3;

-- ##################################################
-- SECCION 5: CONSULTAS SQL DE ANALISIS
-- ##################################################

-- CONSULTA 1
-- Ranking de socios por rentabilidad compuesta en temporada activa
-- Usa: RANK() con PARTITION, JOINs multiples, SUM, CASE
WITH temporada AS (
    SELECT MIN(fecha_recibo) AS inicio, MAX(fecha_recibo) AS fin
    FROM   recibos
)
SELECT
    p.nombre || ' ' || p.apellido                              AS productor,
    s.tipo_asociacion,
    COALESCE(SUM(r.peso_neto_qq), 0)                           AS total_quintales,
    COALESCE(SUM(f.monto_total - COALESCE(f.anticipo,0)), 0)   AS monto_bruto_pagado,
    COALESCE(SUM(bo.monto_total_bono), 0)                      AS monto_bonos_especialidad,
    COALESCE(SUM(f.monto_total - COALESCE(f.anticipo,0)), 0)
        + COALESCE(SUM(bo.monto_total_bono), 0)                AS monto_total_acumulado,
    RANK() OVER (
        PARTITION BY s.tipo_asociacion
        ORDER BY COALESCE(SUM(f.monto_total - COALESCE(f.anticipo,0)), 0)
               + COALESCE(SUM(bo.monto_total_bono), 0) DESC
    )                                                          AS ranking_por_tipo
FROM   socios s
JOIN   productores       p  ON p.id = s.productor_id
LEFT JOIN recibos        r  ON r.productor_id = p.id
    AND r.fecha_recibo BETWEEN (SELECT inicio FROM temporada) AND (SELECT fin FROM temporada)
LEFT JOIN facturas_compra f ON f.recibo_id = r.id
LEFT JOIN bonos_especialidad bo ON bo.recibo_id = r.id
WHERE  s.estado_membresia = 'activo'
GROUP  BY p.nombre, p.apellido, s.id, s.tipo_asociacion
ORDER  BY s.tipo_asociacion, ranking_por_tipo;


-- CONSULTA 2
-- Terrenos improductivos con evaluacion vigente (aprobada ultimos 2 años,
-- con visita completada, pero sin recibos en temporada activa)
-- Usa: JOINs multiples, subconsulta correlacionada, HAVING
WITH temporada_activa AS (
    SELECT MIN(fecha_recibo) AS inicio, MAX(fecha_recibo) AS fin
    FROM   recibos
)
SELECT
    t.nombre                                                   AS terreno,
    m.nombre                                                   AS municipio,
    s.tipo_asociacion,
    MAX(vt.fecha_programada)                                   AS ultima_visita_completada,
    e.nombre || ' ' || e.apellido                              AS tecnico
FROM   terrenos t
JOIN   municipios m ON m.id = t.municipio_id
JOIN   productores pr ON pr.id = t.productor_id
LEFT JOIN socios s ON s.productor_id = pr.id
JOIN   evaluaciones_tecnicas et ON et.terreno_id = t.id
    AND et.estado = 'aprobada'
    AND et.fecha_evaluacion >= CURRENT_DATE - INTERVAL '2 years'
JOIN   visita_terrenos vtr ON vtr.terreno_id = t.id
JOIN   visitas_tecnicas vt ON vt.id = vtr.visita_id
    AND vt.estado = 'completada'
JOIN   empleados e ON e.id = vt.tecnico_id
WHERE  NOT EXISTS (
    SELECT 1 FROM recibos r
    JOIN   temporada_activa ta ON r.fecha_recibo BETWEEN ta.inicio AND ta.fin
    WHERE  r.productor_id = pr.id
)
GROUP  BY t.nombre, m.nombre, s.tipo_asociacion, e.nombre, e.apellido
ORDER  BY ultima_visita_completada DESC;


-- CONSULTA 3
-- Eficiencia del beneficiado por cooperativa y mes
-- Usa: JOINs, DATE_TRUNC, AVG, SUM, CASE, ORDER BY
SELECT
    c.nombre                                                   AS cooperativa,
    TO_CHAR(DATE_TRUNC('month', bs.fecha), 'YYYY-MM')          AS mes,
    ROUND(AVG(bs.porcentaje_rendimiento), 2)                   AS prom_rendimiento_pct,
    SUM(bs.qq_pergamino_entrada)                               AS total_qq_procesados,
    COALESCE(SUM(bh.merma_kg), 0)                              AS merma_total_kg,
    CASE
        WHEN AVG(bs.porcentaje_rendimiento) >= 80 THEN 'Alto'
        WHEN AVG(bs.porcentaje_rendimiento) >= 70 THEN 'Medio'
        ELSE 'Bajo'
    END                                                        AS nivel_rendimiento
FROM   beneficiado_seco bs
JOIN   lotes_procesamiento lp ON lp.id = bs.lote_id
JOIN   recibos r ON r.id = lp.recibo_id
JOIN   bodegas bo ON bo.id = r.bodega_id
JOIN   cooperativas c ON c.id = bo.cooperativa_id
LEFT JOIN beneficiado_humedo bh ON bh.lote_id = lp.id
GROUP  BY c.nombre, DATE_TRUNC('month', bs.fecha)
ORDER  BY c.nombre, mes;


-- CONSULTA 4
-- Contratos en riesgo con proyeccion de deficit
-- Usa: JOINs, SUM, CASE, HAVING con condicion compuesta
SELECT
    c.numero                                                   AS contrato,
    e.nombre                                                   AS empresa,
    e.pais,
    c.qq_totales_pactados                                      AS quintales_pactados,
    COALESCE(SUM(exp.quintales_exportados), 0)                 AS quintales_exportados,
    c.qq_totales_pactados - COALESCE(SUM(exp.quintales_exportados), 0) AS quintales_pendientes,
    ROUND(
        COALESCE(SUM(exp.quintales_exportados), 0)
        / NULLIF(c.qq_totales_pactados, 0) * 100, 2
    )                                                          AS pct_cumplimiento,
    c.fecha_entrega_est - CURRENT_DATE                         AS dias_restantes
FROM   contratos_exportacion c
JOIN   empresas_extranjeras e ON e.id = c.empresa_id
LEFT JOIN exportaciones exp ON exp.contrato_id = c.id
WHERE  c.estado = 'vigente'
  AND  c.fecha_entrega_est <= CURRENT_DATE + INTERVAL '30 days'
GROUP  BY c.numero, e.nombre, e.pais,
          c.qq_totales_pactados, c.fecha_entrega_est
HAVING
    COALESCE(SUM(exp.quintales_exportados), 0)
    / NULLIF(c.qq_totales_pactados, 0) < 0.60
    AND
    c.qq_totales_pactados - COALESCE(SUM(exp.quintales_exportados), 0) > 50
ORDER  BY dias_restantes;


-- CONSULTA 5
-- Comparativa de productividad socios vs externos por tipo de cafe
-- Usa: CTEs, JOIN sobre CTE, funciones de agregacion, diferencia porcentual
WITH productividad_socios AS (
    SELECT
        tc.nombre                                              AS tipo_cafe,
        'socio'                                                AS categoria,
        ROUND(AVG(r.peso_neto_qq), 2)                          AS prom_qq_recibo,
        ROUND(AVG(f.precio_unitario), 2)                       AS precio_promedio,
        ROUND(AVG(cq.puntaje_taza), 2)                         AS puntaje_taza_prom
    FROM   recibos r
    JOIN   tipos_cafe tc ON tc.id = r.tipo_cafe_id
    JOIN   productores pr ON pr.id = r.productor_id
    JOIN   socios s ON s.productor_id = pr.id AND s.estado_membresia = 'activo'
    LEFT JOIN facturas_compra f ON f.recibo_id = r.id
    LEFT JOIN control_calidad cq ON cq.recibo_id = r.id
    GROUP  BY tc.nombre
),
productividad_externos AS (
    SELECT
        tc.nombre                                              AS tipo_cafe,
        'externo'                                              AS categoria,
        ROUND(AVG(r.peso_neto_qq), 2)                          AS prom_qq_recibo,
        ROUND(AVG(f.precio_unitario), 2)                       AS precio_promedio,
        ROUND(AVG(cq.puntaje_taza), 2)                         AS puntaje_taza_prom
    FROM   recibos r
    JOIN   tipos_cafe tc ON tc.id = r.tipo_cafe_id
    JOIN   productores pr ON pr.id = r.productor_id
    LEFT JOIN socios s ON s.productor_id = pr.id
    LEFT JOIN facturas_compra f ON f.recibo_id = r.id
    LEFT JOIN control_calidad cq ON cq.recibo_id = r.id
    WHERE  s.id IS NULL   -- solo externos
    GROUP  BY tc.nombre
)
SELECT
    ps.tipo_cafe,
    ps.prom_qq_recibo                                          AS qq_prom_socio,
    pe.prom_qq_recibo                                          AS qq_prom_externo,
    ps.precio_promedio                                         AS precio_prom_socio,
    pe.precio_promedio                                         AS precio_prom_externo,
    ROUND((ps.precio_promedio - pe.precio_promedio)
          / NULLIF(pe.precio_promedio, 0) * 100, 2)            AS diferencia_pct_precio,
    ps.puntaje_taza_prom                                       AS puntaje_prom_socio,
    pe.puntaje_taza_prom                                       AS puntaje_prom_externo
FROM   productividad_socios ps
JOIN   productividad_externos pe ON pe.tipo_cafe = ps.tipo_cafe
ORDER  BY ps.tipo_cafe;


-- CONSULTA 6
-- Trazabilidad financiera de lotes de especialidad
-- Usa: JOINs multiples, LEFT JOIN para exportaciones (NULL si no exportado)
WITH temporada AS (
    SELECT MIN(fecha_recibo) AS inicio, MAX(fecha_recibo) AS fin
    FROM   recibos
)
SELECT
    r.numero                                                   AS numero_recibo,
    p.nombre || ' ' || p.apellido                              AS productor,
    t.nombre                                                   AS terreno_origen,
    m.nombre                                                   AS municipio,
    r.fecha_recibo,
    cq.puntaje_taza,
    f.monto_total                                              AS monto_compra_base,
    bo.monto_total_bono                                        AS monto_bono,
    cc.nombre                                                  AS clasificacion_final,
    exp.numero                                                 AS numero_exportacion,
    emp.nombre                                                 AS empresa_destino,
    emp.pais
FROM   control_calidad cq
JOIN   recibos r ON r.id = cq.recibo_id
JOIN   temporada ta ON r.fecha_recibo BETWEEN ta.inicio AND ta.fin
JOIN   productores p ON p.id = r.productor_id
LEFT JOIN facturas_compra f ON f.recibo_id = r.id
LEFT JOIN bonos_especialidad bo ON bo.recibo_id = r.id
LEFT JOIN lotes_procesamiento lp ON lp.recibo_id = r.id
LEFT JOIN beneficiado_seco bs ON bs.lote_id = lp.id
LEFT JOIN clasificaciones_lote cl ON cl.lote_id = lp.id
LEFT JOIN clasificaciones_cafe cc ON cc.id = cl.clasificacion_id
LEFT JOIN terrenos t ON t.productor_id = p.id
LEFT JOIN municipios m ON m.id = t.municipio_id
LEFT JOIN exportaciones exp ON exp.contrato_id IN (
    SELECT cd.contrato_id FROM contrato_detalle cd
    WHERE  cd.clasificacion_id = cl.clasificacion_id
)
LEFT JOIN contratos_exportacion ce ON ce.id = exp.contrato_id
LEFT JOIN empresas_extranjeras emp ON emp.id = ce.empresa_id
WHERE  cq.puntaje_taza >= 80
ORDER  BY r.fecha_recibo, cc.nombre;


-- CONSULTA 7
-- Carga laboral de cargadores por bodega
-- Usa: JOINs, COUNT, SUM, AVG, EXTRACT, subconsulta para bodega frecuente, HAVING
SELECT
    e.nombre || ' ' || e.apellido                              AS cargador,
    COUNT(td.id)                                               AS numero_turnos,
    SUM(td.sacos_descargados)                                  AS total_sacos,
    ROUND(AVG(td.sacos_descargados), 2)                        AS prom_sacos_por_turno,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (td.hora_fin::INTERVAL - td.hora_inicio::INTERVAL)) / 3600
    ), 2)                                                      AS prom_horas_por_turno,
    (
        SELECT b.nombre
        FROM   turnos_descarga td2
        JOIN   recibos r2 ON r2.id = td2.recibo_id
        JOIN   bodegas b ON b.id = r2.bodega_id
        WHERE  td2.cargador_id = e.id
        GROUP  BY b.nombre
        ORDER  BY COUNT(*) DESC
        LIMIT  1
    )                                                          AS bodega_mas_frecuente
FROM   turnos_descarga td
JOIN   empleados e ON e.id = td.cargador_id
JOIN   recibos r ON r.id = td.recibo_id
GROUP  BY e.id, e.nombre, e.apellido
HAVING COUNT(td.id) > 5
ORDER  BY total_sacos DESC;


-- CONSULTA 8
-- Impacto de variaciones de precio en pagos realizados
-- Usa: log_precios, CTEs, JOINs, SUM, HAVING con condicion compuesta
WITH cambios_precio AS (
    SELECT
        lp.tipo_cafe_id,
        tc.nombre                                              AS tipo_cafe,
        lp.precio_anterior,
        lp.precio_nuevo,
        lp.variacion_abs,
        lp.variacion_pct,
        lp.fecha_cambio,
        LEAD(lp.fecha_cambio) OVER (
            PARTITION BY lp.tipo_cafe_id
            ORDER BY lp.fecha_cambio
        )                                                      AS proxima_vigencia,
        COUNT(*) OVER (PARTITION BY lp.tipo_cafe_id)           AS total_cambios
    FROM   log_precios lp
    JOIN   tipos_cafe tc ON tc.id = lp.tipo_cafe_id
    WHERE  lp.precio_anterior IS NOT NULL   -- solo cambios, no inserciones iniciales
)
SELECT
    cp.tipo_cafe,
    cp.precio_anterior,
    cp.precio_nuevo,
    cp.variacion_abs,
    cp.variacion_pct,
    COUNT(r.id)                                                AS recibos_bajo_tarifa,
    COALESCE(SUM(r.peso_neto_qq), 0)                           AS quintales_comprados,
    COALESCE(SUM(f.monto_total), 0)                            AS monto_total_pagado
FROM   cambios_precio cp
LEFT JOIN recibos r ON r.tipo_cafe_id = cp.tipo_cafe_id
    AND r.fecha_recibo >= cp.fecha_cambio::DATE
    AND r.fecha_recibo <  COALESCE(cp.proxima_vigencia::DATE, '9999-12-31')
LEFT JOIN facturas_compra f ON f.recibo_id = r.id
WHERE  cp.total_cambios >= 2
GROUP  BY cp.tipo_cafe, cp.precio_anterior, cp.precio_nuevo,
          cp.variacion_abs, cp.variacion_pct, cp.fecha_cambio
ORDER  BY cp.tipo_cafe, cp.fecha_cambio;


-- CONSULTA 9
-- Desempeño tecnico de agronomos con impacto en produccion
-- Usa: JOINs multiples, COUNT, SUM, ROUND, subconsulta correlacionada
SELECT
    e.nombre || ' ' || e.apellido                              AS agronomo,
    e.num_colegiado,
    COUNT(DISTINCT et.id)                                      AS total_evaluaciones,
    COUNT(DISTINCT CASE WHEN et.estado = 'aprobada' THEN et.id END)
                                                               AS evaluaciones_aprobadas,
    ROUND(
        COUNT(DISTINCT CASE WHEN et.estado = 'aprobada' THEN et.id END)::DECIMAL
        / NULLIF(COUNT(DISTINCT et.id), 0) * 100, 2
    )                                                          AS tasa_aprobacion_pct,
    COUNT(DISTINCT CASE WHEN vt.estado = 'completada' THEN vt.id END)
                                                               AS visitas_completadas,
    COUNT(DISTINCT vtr.terreno_id)                             AS terrenos_visitados,
    COALESCE(SUM(r.peso_neto_qq), 0)                           AS total_qq_terrenos_evaluados,
    COALESCE(SUM(CASE WHEN cq.es_especialidad = TRUE THEN r.peso_neto_qq ELSE 0 END), 0)
                                                               AS qq_especialidad
FROM   empleados e
JOIN   evaluaciones_tecnicas et ON et.tecnico_id = e.id
LEFT JOIN visitas_tecnicas vt ON vt.tecnico_id = e.id
LEFT JOIN visita_terrenos vtr ON vtr.visita_id = vt.id
LEFT JOIN terrenos t ON t.id = et.terreno_id AND et.estado = 'aprobada'
LEFT JOIN recibos r ON r.productor_id = t.productor_id
LEFT JOIN control_calidad cq ON cq.recibo_id = r.id
WHERE  e.estado = 'activo'
  AND  e.rol_id = (SELECT id FROM roles WHERE nombre = 'Técnico Agrónomo')
GROUP  BY e.id, e.nombre, e.apellido, e.num_colegiado
ORDER  BY total_qq_terrenos_evaluados DESC;


-- CONSULTA 10
-- Reporte consolidado mensual de la bodega central
-- Usa: CTEs multiples, JOINs, SUM, HAVING, subconsulta para max transportista
WITH bodega_central AS (
    SELECT id FROM bodegas WHERE es_central = TRUE LIMIT 1
),
entradas_mes AS (
    SELECT
        DATE_TRUNC('month', tr.fecha_llegada)::DATE            AS mes,
        cc.nombre                                              AS clasificacion,
        SUM(tr.cantidad_qq)                                    AS qq_recibidos
    FROM   traslados tr
    JOIN   clasificaciones_cafe cc ON cc.id = tr.clasificacion_id
    WHERE  tr.bodega_destino_id = (SELECT id FROM bodega_central)
      AND  tr.estado = 'recibido'
    GROUP  BY DATE_TRUNC('month', tr.fecha_llegada), cc.nombre
),
salidas_mes AS (
    SELECT
        DATE_TRUNC('month', exp.fecha_despacho)::DATE          AS mes,
        emp.nombre                                             AS empresa_destino,
        SUM(exp.quintales_exportados)                          AS qq_exportados
    FROM   exportaciones exp
    JOIN   contratos_exportacion ce ON ce.id = exp.contrato_id
    JOIN   empresas_extranjeras emp ON emp.id = ce.empresa_id
    WHERE  exp.bodega_origen_id = (SELECT id FROM bodega_central)
    GROUP  BY DATE_TRUNC('month', exp.fecha_despacho), emp.nombre
),
transportista_mes AS (
    SELECT
        DATE_TRUNC('month', tr.fecha_salida)::DATE             AS mes,
        e.nombre || ' ' || e.apellido                          AS transportista,
        SUM(tr.cantidad_qq)                                    AS vol_traslado,
        RANK() OVER (
            PARTITION BY DATE_TRUNC('month', tr.fecha_salida)
            ORDER BY SUM(tr.cantidad_qq) DESC
        )                                                      AS rk
    FROM   traslados tr
    JOIN   empleados e ON e.id = tr.transportista_id
    WHERE  tr.bodega_destino_id = (SELECT id FROM bodega_central)
    GROUP  BY DATE_TRUNC('month', tr.fecha_salida), e.nombre, e.apellido
)
SELECT
    COALESCE(en.mes, sa.mes)                                   AS mes,
    COALESCE(SUM(en.qq_recibidos), 0)                          AS qq_recibidos_traslado,
    COALESCE(SUM(sa.qq_exportados), 0)                         AS qq_exportados,
    COALESCE(SUM(en.qq_recibidos), 0)
        - COALESCE(SUM(sa.qq_exportados), 0)                   AS saldo_teorico_cierre,
    MAX(tm.transportista)                                       AS transportista_mayor_volumen
FROM   entradas_mes en
FULL OUTER JOIN salidas_mes sa ON sa.mes = en.mes
LEFT JOIN (SELECT * FROM transportista_mes WHERE rk = 1) tm ON tm.mes = COALESCE(en.mes, sa.mes)
GROUP  BY COALESCE(en.mes, sa.mes)
HAVING COALESCE(SUM(en.qq_recibidos), 0) + COALESCE(SUM(sa.qq_exportados), 0) > 100
ORDER  BY mes;

-- ##################################################
-- FIN DE PRUEBAS
-- ##################################################
