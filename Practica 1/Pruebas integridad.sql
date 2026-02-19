PRAGMA foreign_keys = ON;



--Buscar ciudadano por nombre 
SELECT Identificacion_ciudadano, NOMBRE, APELLIDOS, TELEFONO, CORREO
FROM CIUDADANO
WHERE NOMBRE LIKE 'Juan';

--Datos básicos de todos los ciudadanos
SELECT Identificacion_ciudadano, NOMBRE, APELLIDOS, NIT
FROM CIUDADANO
ORDER BY APELLIDOS, NOMBRE;

-- 3) Predios con su titular
SELECT p.CODIGO_CATASTRAL,
       p.UBICACION,
       p.AREA_PREDIO,
       c.NOMBRE || ' ' || c.APELLIDOS AS titular
FROM PREDIO_CATASTRAL p
JOIN CIUDADANO c ON c.Identificacion_ciudadano = p.Identificacion_ciudadano_titular
ORDER BY p.CODIGO_CATASTRAL;

--Predios con avalúo
SELECT p.CODIGO_CATASTRAL,
       p.UBICACION,
       a.FECHA_AVALUO,
       a.VALOR_TOTAL
FROM PREDIO_CATASTRAL p
LEFT JOIN AVALUO a ON a.ID_PREDIO_CATASTRAL = p.CODIGO_CATASTRAL
ORDER BY a.VALOR_TOTAL DESC;

--Multas con categoría
SELECT m.Id_multa,
       tm.categoria,
       m.monto,
       m.fecha,
       m.ubicacion
FROM MULTA m
JOIN TIPO_MULTA tm ON tm.Id_tipo_multa = m.id_tipo_multa
ORDER BY m.fecha DESC;

--Multas por ciudadano
SELECT c.Identificacion_ciudadano,
       c.NOMBRE || ' ' || c.APELLIDOS AS ciudadano,
       m.Id_multa,
       m.monto,
       m.fecha
FROM MULTA_CIUDADANO mc
JOIN CIUDADANO c ON c.Identificacion_ciudadano = mc.id_ciudadano
JOIN MULTA m ON m.Id_multa = mc.id_multa
ORDER BY ciudadano;

--Facturas por ciudadano
SELECT c.NOMBRE || ' ' || c.APELLIDOS AS ciudadano,
       f.id_factura,
       f.fecha_emision,
       f.monto,
       f.mora
FROM FACTURA f
JOIN CIUDADANO c ON c.Identificacion_ciudadano = f.id_ciudadano
ORDER BY f.id_factura;

--Facturas pendientes o morosas
SELECT f.id_factura,
       c.NOMBRE || ' ' || c.APELLIDOS AS ciudadano,
       ef.estado,
       f.monto,
       f.mora
FROM FACTURA f
JOIN CIUDADANO c ON c.Identificacion_ciudadano = f.id_ciudadano
JOIN ESTADO_FACTURA ef ON ef.id_estado_factura = f.id_estado_factura
WHERE ef.estado IN ('PENDIENTE','MOROSA')
ORDER BY f.id_factura;

--Pagos realizados
SELECT p.id_pago,
       p.fecha_pago,
       p.monto_pago,
       p.id_factura,
       mp.metodo_pago
FROM PAGO p
JOIN METODO_PAGO mp ON mp.id_metodo_pago = p.id_metodo_pago
ORDER BY p.fecha_pago DESC;

--Inventario general
SELECT id_producto, nombre_producto, stock_actual, stock_minimo, costo_unitario
FROM INVENTARIO
ORDER BY nombre_producto;

--Productos con poco stock (stock <= 20)
SELECT id_producto, nombre_producto, stock_actual
FROM INVENTARIO
WHERE stock_actual <= 20
ORDER BY stock_actual ASC;

--Servicios municipales con estado
SELECT s.id_servicio,
       s.nombre_servicio,
       s.costo,
       es.estado,
       s.fecha_inicio
FROM SERVICIO_MUNICIPAL s
JOIN ESTADO_SERVICIO es ON es.id_estado = s.id_estado_servicio
ORDER BY s.id_servicio;

--VALIDACIONES BÁSICAS DE CANTIDAD 

SELECT 'CIUDADANO' AS tabla, COUNT(*) AS total FROM CIUDADANO
UNION ALL
SELECT 'PREDIO_CATASTRAL', COUNT(*) FROM PREDIO_CATASTRAL
UNION ALL
SELECT 'TRAMITE_CIUDADANO', COUNT(*) FROM TRAMITE_CIUDADANO
UNION ALL
SELECT 'SERVICIO_MUNICIPAL', COUNT(*) FROM SERVICIO_MUNICIPAL
UNION ALL
SELECT 'FACTURA', COUNT(*) FROM FACTURA
UNION ALL
SELECT 'PAGO', COUNT(*) FROM PAGO
UNION ALL
SELECT 'MULTA', COUNT(*) FROM MULTA
UNION ALL
SELECT 'INVENTARIO', COUNT(*) FROM INVENTARIO;


--PRUEBAS DE INTEGRIDAD REFERENCIAL

--Trámites con ciudadano inexistente
SELECT tc.*
FROM TRAMITE_CIUDADANO tc
LEFT JOIN CIUDADANO c ON c.Identificacion_ciudadano = tc.Id_ciudadano
WHERE c.Identificacion_ciudadano IS NULL;

-- Predios con titular inexistente
SELECT p.*
FROM PREDIO_CATASTRAL p
LEFT JOIN CIUDADANO c ON c.Identificacion_ciudadano = p.Identificacion_ciudadano_titular
WHERE c.Identificacion_ciudadano IS NULL;

--Servicios con predio inexistente
SELECT s.*
FROM SERVICIO_MUNICIPAL s
LEFT JOIN PREDIO_CATASTRAL p ON p.CODIGO_CATASTRAL = s.codigo_catastral
WHERE p.CODIGO_CATASTRAL IS NULL;

--Pagos con factura inexistente
SELECT p.*
FROM PAGO p
LEFT JOIN FACTURA f ON f.id_factura = p.id_factura
WHERE f.id_factura IS NULL;

--Detalle de factura huérfano
SELECT d.*
FROM DETALLE_FACTURA d
LEFT JOIN FACTURA f ON f.id_factura = d.id_factura
WHERE f.id_factura IS NULL;


--PRUEBAS DE REGLAS DE NEGOCIO 

--Facturas con pagos que exceden monto + mora (debe ser 0 filas)
SELECT f.id_factura,
       f.monto,
       f.mora,
       COALESCE(SUM(p.monto_pago),0) AS total_pagado,
       (f.monto + f.mora) AS maximo_permitido
FROM FACTURA f
LEFT JOIN PAGO p ON p.id_factura = f.id_factura
GROUP BY f.id_factura, f.monto, f.mora
HAVING COALESCE(SUM(p.monto_pago),0) > (f.monto + f.mora);

--Inventario en estado crítico 
SELECT id_producto, nombre_producto, stock_actual, stock_minimo
FROM INVENTARIO
WHERE stock_actual <= stock_minimo
ORDER BY stock_actual ASC;

--Encuestas fuera de rango (debe ser 0 filas por trigger)
SELECT *
FROM ENCUESTA_SATISFACCION
WHERE calificacion < 1 OR calificacion > 5;


--BÚSQUEDAS BÁSICAS


--Ciudadanos con sus trámites y estado
SELECT c.Identificacion_ciudadano,
       c.NOMBRE || ' ' || c.APELLIDOS AS ciudadano,
       t.Nombre_tramite,
       et.Nombre_estado,
       tc.Fecha_inicio,
       tc.Fecha_fin
FROM TRAMITE_CIUDADANO tc
JOIN CIUDADANO c ON c.Identificacion_ciudadano = tc.Id_ciudadano
JOIN TRAMITE t ON t.Id_tramite = tc.Id_tramite
JOIN ESTADO_TRAMITE et ON et.id_estado = tc.Id_estado
ORDER BY tc.Id_tramite_ciudadano DESC;

--Predios con titular y uso de suelo
SELECT p.CODIGO_CATASTRAL,
       p.MUNICIPIO,
       p.UBICACION,
       us.USO_SUELO,
       c.NOMBRE || ' ' || c.APELLIDOS AS titular
FROM PREDIO_CATASTRAL p
JOIN USO_SUELO_PREDIO us ON us.ID_USO = p.ID_USO
JOIN CIUDADANO c ON c.Identificacion_ciudadano = p.Identificacion_ciudadano_titular
ORDER BY p.CODIGO_CATASTRAL;


--BÚSQUEDAS COMPLEJAS

-- Estado de cuenta por ciudadano (version simple)

SELECT 
    c.Identificacion_ciudadano,
    c.NOMBRE || ' ' || c.APELLIDOS AS nombre_completo,
    SUM(f.monto + f.mora) AS total_facturado,
    SUM(p.monto_pago) AS total_pagado,
    SUM(f.monto + f.mora) - SUM(p.monto_pago) AS saldo
FROM CIUDADANO c
LEFT JOIN FACTURA f 
    ON c.Identificacion_ciudadano = f.id_ciudadano
LEFT JOIN PAGO p 
    ON f.id_factura = p.id_factura
GROUP BY c.Identificacion_ciudadano, c.NOMBRE, c.APELLIDOS
ORDER BY saldo DESC;
-- Ranking de servicios por dinero generado

SELECT 
    s.nombre_servicio,
    COUNT(f.id_factura) AS total_facturas,
    SUM(df.valor * df.cantidad) AS total_generado
FROM SERVICIO_MUNICIPAL s
LEFT JOIN TRAMITE_CIUDADANO tc
    ON s.id_tramite_ciudadano = tc.Id_tramite_ciudadano
LEFT JOIN FACTURA f
    ON f.id_ciudadano = tc.Id_ciudadano
LEFT JOIN DETALLE_FACTURA df
    ON df.id_factura = f.id_factura
GROUP BY s.nombre_servicio
ORDER BY total_generado DESC;

--AUDITORÍA (BITÁCORA)

-- Últimos movimientos en bitácora
SELECT id_bitacora, tabla_afectada, id_registro, accion, usuario, fecha
FROM BITACORA
ORDER BY id_bitacora DESC
LIMIT 30;