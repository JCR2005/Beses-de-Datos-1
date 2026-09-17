
-- PASO 1: CREAR TABLAS
CREATE TABLE IF NOT EXISTS "24_202231970_categoria" (
    id_categoria  INTEGER       PRIMARY KEY AUTOINCREMENT,
    nombre        VARCHAR(50)   NOT NULL,
    descripcion   VARCHAR(150),
    activo        INTEGER       NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS "24_202231970_producto" (
    id_producto   INTEGER        PRIMARY KEY AUTOINCREMENT,
    id_categoria  INTEGER        NOT NULL,
    nombre        VARCHAR(100)   NOT NULL,
    precio        DECIMAL(10,2)  NOT NULL,
    stock         INTEGER        NOT NULL DEFAULT 0,
    fecha_ingreso TEXT           NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES "24_202231970_categoria"(id_categoria)
);

-- PASO 2: INSERTAR REGISTROS 
INSERT INTO "24_202231970_categoria" (nombre, descripcion, activo) VALUES
    ('Electrónica', 'Dispositivos y accesorios electrónicos', 1),
    ('Hogar',       'Artículos para el hogar y cocina',       1),
    ('Deportes',    'Equipos y ropa deportiva',               1);

INSERT INTO "24_202231970_producto" (id_categoria, nombre, precio, stock, fecha_ingreso) VALUES
    (1, 'Audífonos Bluetooth', 349.99, 15, '2025-01-10'),
    (1, 'Teclado Mecánico',    599.00,  8, '2025-02-05'),
    (1, 'Mouse Inalámbrico',   189.50, 20, '2025-02-20'),
    (2, 'Licuadora 600W',      250.00, 12, '2025-01-15'),
    (2, 'Set de Ollas',        480.00,  5, '2025-03-01'),
    (3, 'Pelota de Fútbol',    120.00, 30, '2025-01-28');

-- PASO 3: SELECT INICIAL 
SELECT p.id_producto, c.nombre AS categoria,
       p.nombre AS producto, p.precio, p.stock
FROM "24_202231970_producto" p
JOIN "24_202231970_categoria" c ON p.id_categoria = c.id_categoria;

-- PASO 4: UPDATE — 10% descuento a productos de Electrónica
UPDATE "24_202231970_producto"
SET precio = ROUND(precio * 0.90, 2)
WHERE id_categoria = (
    SELECT id_categoria FROM "24_202231970_categoria"
    WHERE nombre = 'Electrónica'
);

-- PASO 5: SELECT DE VERIFICACIÓN (después del UPDATE)
SELECT p.id_producto, c.nombre AS categoria,
       p.nombre AS producto,
       p.precio AS precio_con_descuento, p.stock
FROM "24_202231970_producto" p
JOIN "24_202231970_categoria" c ON p.id_categoria = c.id_categoria;


UPDATE "24_202231970_producto" SET stock = stock + 100;
SELECT id_producto, nombre, stock AS stock_sin_where FROM "24_202231970_producto";
UPDATE "24_202231970_producto" SET stock = stock - 100;  -- revertir

SELECT type, name FROM sqlite_master
WHERE type IN ('table','index') ORDER BY type, name;
