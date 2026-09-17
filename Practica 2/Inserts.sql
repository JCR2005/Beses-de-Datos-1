
BEGIN;
-- ##################################################
-- 1. MUNICIPIOS (Huehuetenango)
-- ##################################################
INSERT INTO municipios (nombre) VALUES
('San Pedro Necta'),
('La Democracia'),
('Jacaltenango'),
('Todos Santos Cuchumatán'),
('Chiantla'),
('Huehuetenango');

-- ##################################################
-- 2. ROLES
-- ##################################################
INSERT INTO roles (nombre, descripcion) VALUES
('Gerente General',  'Máxima autoridad de la cooperativa'),
('Supervisor',       'Supervisa operaciones de recepción y campo'),
('Técnico Agrónomo', 'Realiza evaluaciones técnicas y visitas de campo'),
('Contador',         'Emite facturas y lleva contabilidad'),
('Bodeguero',        'Administra y controla el inventario en bodega'),
('Transportista',    'Conduce vehículos para traslados y exportaciones'),
('Cargador',         'Apoya en la descarga de café'),
('Administrador',    'Gestiona recursos administrativos');

-- ##################################################
-- 3. TIPOS CAFE
-- ##################################################
INSERT INTO tipos_cafe (nombre, descripcion) VALUES
('cereza',           'Café con pulpa recién cortado en campo'),
('pergamino_humedo', 'Café despulpado sin secar'),
('pergamino_seco',   'Café pergamino listo para beneficiado'),
('cafe_oro',         'Café verde resultado del beneficiado seco');

-- ##################################################
-- 4. CLASIFICACIONES CAFE
-- ##################################################
INSERT INTO clasificaciones_cafe (nombre, descripcion) VALUES
('Extra',    'Grano más grande y uniforme, mayor calidad'),
('Superior', 'Segundo nivel de calidad en tamaño y peso'),
('Segunda',  'Tercer nivel, menor uniformidad de grano'),
('Tercera',  'Granos más pequeños o irregulares'),
('Caracol',  'Grano redondo natural Peaberry guatemalteco'),
('Peaberry', 'Single bean inside cherry, alta cotización'),
('Descarte', 'Granos defectuosos o quebrados');

-- ##################################################
-- 5. TIPOS INSUMO
-- ##################################################
INSERT INTO tipos_insumo (nombre, descripcion) VALUES
('insecticida',    'Control de plagas e insectos del cafeto'),
('fungicida',      'Control de hongos y enfermedades foliares'),
('abono_organico', 'Fertilización orgánica del suelo'),
('almacigo',       'Planta de café en crecimiento para siembra');

-- ##################################################
-- 6. VARIEDADES CAFE
-- ##################################################
INSERT INTO variedades_cafe (nombre) VALUES
('Bourbon'),
('Caturra'),
('Catuai'),
('Geisha'),
('Typica');

-- ##################################################
-- 7. EMPRESAS EXTRANJERAS
-- ##################################################
INSERT INTO empresas_extranjeras (nombre, pais, ciudad, contacto, correo, telefono, activa) VALUES
('Nordic Coffee Co.',    'Noruega', 'Oslo',          'Erik Larsen',    'erik@nordiccoffee.no',  '+47-22-334455', TRUE),
('Blue Bottle Trading',  'USA',     'San Francisco',  'Sarah Thompson', 'sarah@bluebottle.com',  '+1-415-5552030', TRUE),
('Stumptown Import LLC', 'USA',     'Portland',       'Mike Johnson',   'mike@stumptown.com',    '+1-503-5551987', TRUE);

-- ##################################################
-- 8. BONOS ESPECIALIDAD CONFIG (temporada dic-mayo)
-- ##################################################
INSERT INTO bonos_especialidad_config (puntaje_min, puntaje_max, bono_quintal, temporada_inicio, temporada_fin) VALUES
(80.00, 100.00, 75.00, '2025-12-01', '2026-05-31');

-- ##################################################
-- 9. COOPERATIVAS
-- ##################################################
INSERT INTO cooperativas (nombre, municipio_id, direccion, telefono, correo, activa) VALUES
('Cooperativa La Unión R.L.',         1, '3a Calle 2-15 San Pedro Necta',  '7764-1001', 'launion@ofi.com.gt',      TRUE),
('Cooperativa El Progreso R.L.',      2, '1a Avenida 5-32 La Democracia',  '7764-2002', 'elprogreso@ofi.com.gt',   TRUE),
('Cooperativa Los Cuchumatanes R.L.', 3, 'Calle Principal Jacaltenango',   '7764-3003', 'cuchumatanes@ofi.com.gt', TRUE);

-- ##################################################
-- 10. EMPLEADOS
-- NOTA: id=1 es referenciado por trg_log_precios (usuario_bd hardcoded=1)
--       Insertar ANTES que precios_cafe
-- ##################################################
INSERT INTO empleados (codigo, nombre, apellido, dpi, nit, telefono, direccion,
    fecha_ingreso, salario_base, rol_id, cooperativa_id, num_colegiado,
    tipo_licencia, num_licencia, estado) VALUES
-- id=1  Gerente General (único activo, regla de negocio)
('EMP001','Carlos',   'López Méndez',      '1234567890101','1234567-8','5501-0001','Zona 1 Huehuetenango',     '2018-01-15',18000.00,1,1, NULL, NULL,  NULL,              'activo'),
-- id=2,3,4  Supervisores (uno por cooperativa)
('EMP002','María',    'González Ramos',    '2234567890101','2234567-8','5502-0002','San Pedro Necta Casco',    '2019-03-01', 9500.00,2,1, NULL, NULL,  NULL,              'activo'),
('EMP003','Pedro',    'Martínez Pérez',    '3234567890101','3234567-8','5503-0003','La Democracia Centro',     '2019-06-15', 9500.00,2,2, NULL, NULL,  NULL,              'activo'),
('EMP004','Ana',      'Pérez Domingo',     '4234567890101','4234567-8','5504-0004','Jacaltenango Centro',      '2020-01-10', 9500.00,2,3, NULL, NULL,  NULL,              'activo'),
-- id=5,6  Técnicos Agrónomos con colegiado
('EMP005','Juan',     'Hernández Cux',     '5234567890101','5234567-8','5505-0005','Aldea La Trinidad',        '2019-08-20', 8500.00,3,1, 'COL-AG-0412', NULL, NULL,      'activo'),
('EMP006','Luis',     'Ramos Alvarado',    '6234567890101','6234567-8','5506-0006','Aldea La Victoria',        '2020-02-05', 8500.00,3,2, 'COL-AG-0587', NULL, NULL,      'activo'),
-- id=7,8  Contadores
('EMP007','Rosa',     'Méndez García',     '7234567890101','7234567-8','5507-0007','San Pedro Necta',          '2018-05-01', 8000.00,4,1, NULL, NULL,  NULL,              'activo'),
('EMP008','Roberto',  'Ajtzalam Pop',      '8234567890101','8234567-8','5508-0008','La Democracia',            '2021-01-10', 8000.00,4,2, NULL, NULL,  NULL,              'activo'),
-- id=9,10,11,12  Bodegueros (coop 1,2,3 + central)
('EMP009','Diego',    'Velásquez Boch',    '9234567890101','9234567-8','5509-0009','San Pedro Necta',          '2019-09-15', 6500.00,5,1, NULL, NULL,  NULL,              'activo'),
('EMP010','Elena',    'Cifuentes Tzul',    '0234567890101','0234567-8','5510-0010','La Democracia',            '2020-03-20', 6500.00,5,2, NULL, NULL,  NULL,              'activo'),
('EMP011','Marco',    'Ajú Domingo',       '1134567890101','1134567-8','5511-0011','Jacaltenango',             '2020-07-01', 6500.00,5,3, NULL, NULL,  NULL,              'activo'),
('EMP012','Miriam',   'Cux López',         '1234567890201','1234568-8','5512-0012','Huehuetenango Zona 2',     '2021-03-15', 6500.00,5,1, NULL, NULL,  NULL,              'activo'),
-- id=13,14  Transportistas con licencia
('EMP013','Felipe',   'Tzunun Batz',       '1234567890301','1234569-8','5513-0013','Aldea San Marcos',         '2019-11-01', 7000.00,6,1, NULL, 'C',   'LIC-GT-2021-001', 'activo'),
('EMP014','Sergio',   'Pop Ixchop',        '1234567890401','1234560-8','5514-0014','La Democracia',            '2020-04-10', 7000.00,6,2, NULL, 'C',   'LIC-GT-2020-045', 'activo'),
-- id=15,16  Cargadores
('EMP015','Mateo',    'Domingo Coc',       '1234567890501','1234501-8','5515-0015','San Pedro Necta',          '2021-06-01', 4500.00,7,1, NULL, NULL,  NULL,              'activo'),
('EMP016','Andrés',   'Coy Hernández',     '1234567890601','1234502-8','5516-0016','San Pedro Necta',          '2021-06-01', 4500.00,7,1, NULL, NULL,  NULL,              'activo'),
-- id=17  Administrador
('EMP017','Catalina', 'Tax Méndez',        '1234567890701','1234503-8','5517-0017','Huehuetenango Zona 1',     '2020-09-01', 7500.00,8,1, NULL, NULL,  NULL,              'activo');

-- ##################################################
-- 11. HISTORIAL ROLES (registro inicial por empleado)
-- ##################################################
INSERT INTO historial_roles (empleado_id, rol_id, fecha_inicio) VALUES
(1,1,'2018-01-15'),(2,2,'2019-03-01'),(3,2,'2019-06-15'),(4,2,'2020-01-10'),
(5,3,'2019-08-20'),(6,3,'2020-02-05'),(7,4,'2018-05-01'),(8,4,'2021-01-10'),
(9,5,'2019-09-15'),(10,5,'2020-03-20'),(11,5,'2020-07-01'),(12,5,'2021-03-15'),
(13,6,'2019-11-01'),(14,6,'2020-04-10'),(15,7,'2021-06-01'),(16,7,'2021-06-01'),
(17,8,'2020-09-01');

-- ##################################################
-- 12. PRODUCTORES (15 socios + 5 externos)
-- ##################################################
INSERT INTO productores (nombre, apellido, dpi, nit, telefono, municipio_id, aldea, fecha_registro, es_socio) VALUES
-- id 1-15: socios (es_socio = TRUE)
('Domingo',   'Pérez Hernández',   '2001001001001','2001001-0','5801-0001',1,'Aldea El Palmar',    '2019-01-10', TRUE),
('Santos',    'López Méndez',      '2002002002002','2002002-0','5802-0002',1,'Aldea San Marcos',   '2019-02-15', TRUE),
('Francisco', 'García Ramos',      '2003003003003','2003003-0','5803-0003',2,'Aldea La Unión',     '2019-03-20', TRUE),
('Miguel',    'Hernández Tzul',    '2004004004004','2004004-0','5804-0004',2,'Aldea El Rancho',    '2019-04-05', TRUE),
('Josefina',  'Méndez Boch',       '2005005005005','2005005-0','5805-0005',1,'Aldea Las Flores',   '2019-05-12', TRUE),
('Juan',      'Alvarado Cux',      '2006006006006','2006006-0','5806-0006',3,'Aldea La Esperanza', '2019-06-18', TRUE),
('Rosa',      'Domingo Batz',      '2007007007007','2007007-0','5807-0007',3,'Aldea Los Cuchos',   '2019-07-22', TRUE),
('Pedro',     'Ixchop González',   '2008008008008','2008008-0','5808-0008',2,'Aldea El Progreso',  '2019-08-30', TRUE),
('Elena',     'Coc Hernández',     '2009009009009','2009009-0','5809-0009',1,'Aldea La Trinidad',  '2019-09-14', TRUE),
('Carlos',    'Pop Tzul',          '2010010010010','2010010-0','5810-0010',4,'Aldea San Rafael',   '2020-01-08', TRUE),
('María',     'Ajú Méndez',        '2011011011011','2011011-0','5811-0011',1,'Aldea El Retiro',    '2020-02-20', TRUE),
('Luis',      'Cuy López',         '2012012012012','2012012-0','5812-0012',2,'Aldea Las Palmas',   '2020-03-15', TRUE),
('Ana',       'Velásquez Pérez',   '2013013013013','2013013-0','5813-0013',3,'Aldea La Victoria',  '2020-04-10', TRUE),
('Mateo',     'Hernández García',  '2014014014014','2014014-0','5814-0014',1,'Aldea San Juan',     '2020-05-05', TRUE),
('Carmen',    'Tzunun Ramos',      '2015015015015','2015015-0','5815-0015',2,'Aldea El Carmen',    '2020-06-01', TRUE),
-- id 16-20: externos (es_socio = FALSE)
('Roberto',   'Coy Domingo',       '2016016016016','2016016-0','5816-0016',4,'Aldea San Pedro',    '2023-11-05', FALSE),
('Cristina',  'Tax García',        '2017017017017','2017017-0','5817-0017',5,'Aldea Las Minas',    '2024-01-20', FALSE),
('Ernesto',   'Ajtzalam López',    '2018018018018','2018018-0','5818-0018',4,'Aldea El Quetzal',   '2024-02-14', FALSE),
('Patricia',  'Méndez Cux',        '2019019019019','2019019-0','5819-0019',5,'Aldea Los Pinos',    '2024-03-10', FALSE),
('Jorge',     'Ramos Domingo',     '2020020020020','2020020-0','5820-0020',6,'Zona 3 Huehue',      '2024-04-05', FALSE);

-- ##################################################
-- 13. SOCIOS (uno por productor 1-15)
-- ##################################################
-- Coops: prod 1-5 → coop1, prod 6-10 → coop2, prod 11-15 → coop3
-- tipo_asociacion se actualiza via sp_aprobar_evaluacion; precargamos algunos
INSERT INTO socios (productor_id, cooperativa_id, fecha_ingreso_socio, tipo_asociacion, estado_membresia) VALUES
(1,  1, '2019-01-20', 'A', 'activo'),
(2,  1, '2019-02-28', 'B', 'activo'),
(3,  1, '2019-04-05', 'A', 'activo'),
(4,  1, '2019-05-15', 'C', 'activo'),
(5,  1, '2019-06-20', 'B', 'activo'),
(6,  2, '2019-07-10', 'A', 'activo'),
(7,  2, '2019-08-05', 'B', 'activo'),
(8,  2, '2019-09-18', 'A', 'activo'),
(9,  2, '2019-10-01', 'C', 'activo'),
(10, 2, '2020-02-15', 'B', 'activo'),
(11, 3, '2020-03-10', 'A', 'activo'),
(12, 3, '2020-04-20', 'B', 'activo'),
(13, 3, '2020-05-15', 'C', 'suspendido'),
(14, 3, '2020-06-01', 'A', 'activo'),
(15, 3, '2020-07-10', 'B', 'activo');

-- ##################################################
-- 14. TERRENOS (18 terrenos, algunos socios tienen más de uno)
-- ##################################################
INSERT INTO terrenos (codigo, nombre, productor_id, municipio_id, aldea, altitud_msnm, area_estimada_cuerdas) VALUES
('TRR-001','Finca El Palmar',     1, 1,'Aldea El Palmar',    1680.00, 12.50),
('TRR-002','Finca San Marcos',    2, 1,'Aldea San Marcos',   1720.00,  8.00),
('TRR-003','Finca La Unión',      3, 2,'Aldea La Unión',     1650.00, 15.00),
('TRR-004','Finca El Rancho',     4, 2,'Aldea El Rancho',    1590.00,  9.50),
('TRR-005','Finca Las Flores',    5, 1,'Aldea Las Flores',   1700.00, 11.00),
('TRR-006','Finca La Esperanza',  6, 3,'Aldea La Esperanza', 1800.00, 20.00),
('TRR-007','Finca Los Cuchos',    7, 3,'Aldea Los Cuchos',   1750.00, 14.50),
('TRR-008','Finca El Progreso',   8, 2,'Aldea El Progreso',  1640.00, 10.00),
('TRR-009','Finca La Trinidad',   9, 1,'Aldea La Trinidad',  1690.00, 13.00),
('TRR-010','Finca San Rafael',   10, 4,'Aldea San Rafael',   1820.00, 18.00),
('TRR-011','Finca El Retiro',    11, 1,'Aldea El Retiro',    1670.00,  9.00),
('TRR-012','Finca Las Palmas',   12, 2,'Aldea Las Palmas',   1600.00, 11.50),
('TRR-013','Finca La Victoria',  13, 3,'Aldea La Victoria',  1780.00, 16.00),
('TRR-014','Finca San Juan',     14, 1,'Aldea San Juan',     1710.00, 12.00),
('TRR-015','Finca El Carmen',    15, 2,'Aldea El Carmen',    1660.00,  8.50),
-- Terrenos adicionales (socios con más de un terreno)
('TRR-016','Parcela Norte Palmar', 1, 1,'Aldea El Palmar',   1685.00,  6.00),
('TRR-017','Parcela Alta Unión',   3, 2,'Aldea La Unión',    1680.00,  7.50),
('TRR-018','Parcela Esperanza 2',  6, 3,'Aldea La Esperanza',1810.00,  9.00);

-- ##################################################
-- 15. ESQUINEROS TERRENO (4 por terreno = 72 filas)
-- Coordenadas aproximadas en UTM zona 15N, Huehuetenango
-- ##################################################
INSERT INTO esquineros_terreno (terreno_id, numero_orden, coord_x, coord_y) VALUES
-- TRR-001
(1,1,493500.00,1712000.00),(1,2,493650.00,1712000.00),(1,3,493650.00,1711850.00),(1,4,493500.00,1711850.00),
-- TRR-002
(2,1,493700.00,1712200.00),(2,2,493820.00,1712200.00),(2,3,493820.00,1712080.00),(2,4,493700.00,1712080.00),
-- TRR-003
(3,1,499200.00,1706500.00),(3,2,499380.00,1706500.00),(3,3,499380.00,1706330.00),(3,4,499200.00,1706330.00),
-- TRR-004
(4,1,499400.00,1706300.00),(4,2,499540.00,1706300.00),(4,3,499540.00,1706160.00),(4,4,499400.00,1706160.00),
-- TRR-005
(5,1,493800.00,1711900.00),(5,2,493940.00,1711900.00),(5,3,493940.00,1711760.00),(5,4,493800.00,1711760.00),
-- TRR-006
(6,1,503100.00,1720100.00),(6,2,503350.00,1720100.00),(6,3,503350.00,1719850.00),(6,4,503100.00,1719850.00),
-- TRR-007
(7,1,503200.00,1719700.00),(7,2,503400.00,1719700.00),(7,3,503400.00,1719520.00),(7,4,503200.00,1719520.00),
-- TRR-008
(8,1,499500.00,1706600.00),(8,2,499640.00,1706600.00),(8,3,499640.00,1706460.00),(8,4,499500.00,1706460.00),
-- TRR-009
(9,1,493900.00,1712100.00),(9,2,494060.00,1712100.00),(9,3,494060.00,1711940.00),(9,4,493900.00,1711940.00),
-- TRR-010
(10,1,510200.00,1722000.00),(10,2,510450.00,1722000.00),(10,3,510450.00,1721760.00),(10,4,510200.00,1721760.00),
-- TRR-011
(11,1,494100.00,1711800.00),(11,2,494240.00,1711800.00),(11,3,494240.00,1711660.00),(11,4,494100.00,1711660.00),
-- TRR-012
(12,1,499600.00,1706700.00),(12,2,499750.00,1706700.00),(12,3,499750.00,1706560.00),(12,4,499600.00,1706560.00),
-- TRR-013
(13,1,503500.00,1720300.00),(13,2,503700.00,1720300.00),(13,3,503700.00,1720100.00),(13,4,503500.00,1720100.00),
-- TRR-014
(14,1,494200.00,1712300.00),(14,2,494370.00,1712300.00),(14,3,494370.00,1712130.00),(14,4,494200.00,1712130.00),
-- TRR-015
(15,1,499700.00,1706400.00),(15,2,499820.00,1706400.00),(15,3,499820.00,1706280.00),(15,4,499700.00,1706280.00),
-- TRR-016
(16,1,493520.00,1711820.00),(16,2,493620.00,1711820.00),(16,3,493620.00,1711720.00),(16,4,493520.00,1711720.00),
-- TRR-017
(17,1,499220.00,1706320.00),(17,2,499360.00,1706320.00),(17,3,499360.00,1706200.00),(17,4,499220.00,1706200.00),
-- TRR-018
(18,1,503120.00,1719820.00),(18,2,503270.00,1719820.00),(18,3,503270.00,1719680.00),(18,4,503120.00,1719680.00);

-- Calcular areas con Gauss-Shoelace para cada terreno
SELECT fn_area_terreno(id) FROM terrenos;

-- ##################################################
-- 16. EVALUACIONES TECNICAS (mezcla de estados)
-- ##################################################
INSERT INTO evaluaciones_tecnicas (terreno_id, tecnico_id, supervisor_id, fecha_evaluacion,
    plantas_por_cuerda, edad_cafetal_anios, variedad_id, observaciones_suelo,
    porcentaje_pendiente, puntuacion_tecnica, estado, comentario_supervisor, fecha_decision, foto_url) VALUES
-- Aprobadas (usadas para socios activos)
(1,  5, 2, '2023-02-10', 400, 8, 1, 'Suelo franco-arcilloso, pH 6.2, buena retención hídrica', 35.00, 88.00, 'aprobada', 'Excelente potencial productivo',        '2023-02-15', 'https://ofi-fotos.s3.amazonaws.com/ev001.jpg'),
(2,  5, 2, '2023-03-05', 380, 6, 2, 'Suelo franco, buen drenaje, pendiente moderada',           30.00, 74.00, 'aprobada', 'Buen terreno, clasificado tipo B',       '2023-03-10', 'https://ofi-fotos.s3.amazonaws.com/ev002.jpg'),
(3,  6, 3, '2023-04-12', 420, 9, 1, 'Franco-arenoso, alta materia orgánica',                   25.00, 85.00, 'aprobada', 'Altamente recomendado para Tipo A',     '2023-04-18', 'https://ofi-fotos.s3.amazonaws.com/ev003.jpg'),
(4,  6, 3, '2023-05-08', 360, 5, 3, 'Suelo arcilloso pesado, requiere manejo de humedad',       45.00, 55.00, 'aprobada', 'Aprobado con observaciones, Tipo C',    '2023-05-14', 'https://ofi-fotos.s3.amazonaws.com/ev004.jpg'),
(5,  5, 2, '2023-06-20', 390, 7, 2, 'Suelo franco, buena estructura y profundidad',             28.00, 72.00, 'aprobada', 'Clasificado como Tipo B sin objeciones','2023-06-25', 'https://ofi-fotos.s3.amazonaws.com/ev005.jpg'),
(6,  5, 2, '2023-07-15', 450, 10, 4, 'Volcánico, alta fertilidad, excelente altitud',           20.00, 92.00, 'aprobada', 'Potencial de especialidad certificado', '2023-07-20', 'https://ofi-fotos.s3.amazonaws.com/ev006.jpg'),
(7,  6, 3, '2023-08-22', 410, 8, 1, 'Franco con buena aireación y drenaje lateral',             32.00, 78.00, 'aprobada', 'Aprobado Tipo B, seguimiento recomend.','2023-08-28', 'https://ofi-fotos.s3.amazonaws.com/ev007.jpg'),
(8,  6, 3, '2023-09-10', 430, 9, 2, 'Suelo rico en materia orgánica, pH óptimo',               22.00, 86.00, 'aprobada', 'Terreno de alta calidad, Tipo A',       '2023-09-16', 'https://ofi-fotos.s3.amazonaws.com/ev008.jpg'),
(9,  5, 2, '2023-10-05', 370, 6, 3, 'Pendiente alta, riesgo de erosión moderado',               48.00, 52.00, 'aprobada', 'Aprobado condicionado, manejo erosión', '2023-10-11', 'https://ofi-fotos.s3.amazonaws.com/ev009.jpg'),
(10, 6, 3, '2023-11-14', 460, 11, 4, 'Suelo volcánico premium, alta altitud óptima',            18.00, 91.00, 'aprobada', 'Terreno excepcional para especialidad', '2023-11-20', 'https://ofi-fotos.s3.amazonaws.com/ev010.jpg'),
(11, 5, 2, '2024-01-08', 395, 7, 1, 'Franco-arcilloso, profundidad media aceptable',             33.00, 84.00, 'aprobada', 'Aprobado Tipo A, excelente manejo',     '2024-01-14', 'https://ofi-fotos.s3.amazonaws.com/ev011.jpg'),
(12, 6, 3, '2024-02-20', 385, 6, 2, 'Franco, pH 6.0, buen contenido de fósforo',               27.00, 71.00, 'aprobada', 'Clasificado Tipo B, continuar monit.',  '2024-02-26', 'https://ofi-fotos.s3.amazonaws.com/ev012.jpg'),
-- Rechazada
(13, 5, 2, '2024-03-15', 340, 4, 5, 'Suelo muy arcilloso, mal drenaje, presencia de roca',     60.00, 44.00, 'rechazada','Terreno no apto por drenaje deficiente','2024-03-21', 'https://ofi-fotos.s3.amazonaws.com/ev013.jpg'),
-- Aprobadas restantes
(14, 6, 3, '2024-04-10', 415, 8, 1, 'Suelo franco óptimo, microclima favorable',               24.00, 89.00, 'aprobada', 'Recomendado ampliamente Tipo A',        '2024-04-16', 'https://ofi-fotos.s3.amazonaws.com/ev014.jpg'),
(15, 5, 2, '2024-05-05', 375, 7, 3, 'Suelo franco, buen potencial de producción',               29.00, 73.00, 'aprobada', 'Aprobado Tipo B sin observaciones',     '2024-05-11', 'https://ofi-fotos.s3.amazonaws.com/ev015.jpg'),
-- Pendiente (evaluación reciente sin decisión)
(16, 5, NULL, '2025-11-20', 405, 7, 2, 'Pendiente revisión supervisor - suelo franco', 31.00, 77.00, 'pendiente', NULL, NULL, 'https://ofi-fotos.s3.amazonaws.com/ev016.jpg'),
-- Terrenos adicionales aprobados
(17, 6, 3, '2024-06-12', 425, 8, 4, 'Excelente altitud, suelo volcánico',                      21.00, 87.00, 'aprobada', 'Aprobado Tipo A, microclima excelente', '2024-06-18', 'https://ofi-fotos.s3.amazonaws.com/ev017.jpg'),
(18, 5, 2, '2024-07-08', 400, 9, 1, 'Franco-volcánico, alta materia orgánica',                  23.00, 82.00, 'aprobada', 'Aprobado Tipo A, alto potencial',       '2024-07-14', 'https://ofi-fotos.s3.amazonaws.com/ev018.jpg');

-- ##################################################
-- 17. VISITAS TECNICAS (para consultas 2 y 9)
-- ##################################################
INSERT INTO visitas_tecnicas (gerente_id, tecnico_id, fecha_programada, fecha_real_ejecucion, estado, observaciones_generales) VALUES
(1, 5, '2025-09-10', '2025-09-10', 'completada', 'Visita de seguimiento temporada anterior'),
(1, 6, '2025-09-15', '2025-09-16', 'completada', 'Monitoreo de plagas previo a temporada'),
(1, 5, '2025-10-05', '2025-10-05', 'completada', 'Preparación de terrenos para cosecha'),
(1, 6, '2025-10-20', '2025-10-21', 'completada', 'Verificación de madurez de café'),
(1, 5, '2026-01-15', '2026-01-15', 'completada', 'Visita de monitoreo durante temporada'),
(1, 6, '2026-02-10', '2026-02-10', 'completada', 'Control de calidad en campo'),
(1, 5, '2026-04-05', '2026-04-05', 'completada', 'Visita final de temporada terrenos norte'),
(1, 6, '2026-04-20', NULL,          'programada', 'Visita programada para cierre de temporada');

-- ##################################################
-- 18. VISITA TERRENOS
-- ##################################################
INSERT INTO visita_terrenos (visita_id, terreno_id, tipo_aplicacion, producto, dosis_recomendada, instrucciones, hallazgos, actividades_realizadas) VALUES
(1,1,'fertilizacion','Urea 46%','2 qq/cuerda','Aplicar al pie de planta','Cafetos con buen desarrollo vegetativo','Fertilización foliar completada'),
(1,2,'control_plagas','Clorpirifós 480','1 lt/200 lts agua','Aplicar en horas frescas','Presencia leve de broca','Aplicación preventiva de insecticida'),
(2,3,'fertilizacion','15-15-15','2.5 qq/cuerda','Incorporar al suelo','Suelo con déficit de potasio detectado','Fertilización edáfica realizada'),
(2,6,'poda','N/A','Poda de formación','Eliminar chupones y ramas bajas','Cafetos con exceso de ramas secundarias','Poda sanitaria ejecutada'),
(3,5,'riego','N/A','Sistema aspersión','Riegar 2 veces por semana','Suelo con baja humedad','Revisión sistema de riego'),
(3,9,'muestreo_suelo','N/A','Muestra 0-30 cm','Tomar 10 submuestras','Suelo con pH bajo (5.8)','Muestreo y envío a laboratorio'),
(4,7,'fertilizacion','Abono orgánico','3 qq/cuerda','Incorporar con azadón','Materia orgánica baja en parcela sur','Aplicación abono orgánico completada'),
(4,10,'control_plagas','Trichoderma','200 g/lt agua','Aplicar al suelo','Sin plagas activas, aplicación preventiva','Biocontrol aplicado'),
(5,11,'fertilizacion','Sulfato de amonio','1.5 qq/cuerda','Aplicar fraccionado','Buen estado general de los cafetos','Fertilización completada'),
(5,14,'poda','N/A','Poda de producción','Dejar 3-4 ramas productoras','Cafetos con alta carga de fruto','Poda de aclareo realizada'),
(6,3,'muestreo_suelo','N/A','Muestra compuesta','10 puntos por cuerda','pH 6.2 adecuado para café','Muestreo de seguimiento completado'),
(6,8,'fertilizacion','Nitrato de calcio','1 qq/cuerda','Disolver en agua','Buen estado del follaje','Fertilización foliar aplicada'),
(7,1,'riego','N/A','Goteo','2 horas diarias','Humedad óptima en suelo','Sistema de riego revisado y ajustado'),
(7,16,'control_plagas','Aceite de neem','3 ml/lt agua','Cubrir envés de hojas','Sin presencia de plagas','Aplicación preventiva realizada'),
-- Visita 8 (programada, sin hallazgos aún)
(8,6,'fertilizacion','Compost orgánico','4 qq/cuerda','Plan de aplicación por definir',NULL,NULL),
(8,17,'muestreo_suelo','N/A','Análisis completo','Tomar muestra representativa',NULL,NULL);

-- ##################################################
-- 19. ENTREGAS INSUMOS (beneficios para socios, época invierno)
-- ##################################################
INSERT INTO entregas_insumos (socio_id, terreno_id, tipo_insumo_id, cantidad, unidad_medida, fecha_entrega, responsable_id, observaciones) VALUES
(1, 1,  3, 3.00, 'qq',     '2025-07-15', 5, 'Abono para temporada invierno'),
(1, 16, 3, 1.50, 'qq',     '2025-07-15', 5, 'Parcela norte'),
(2, 2,  3, 2.00, 'qq',     '2025-07-20', 5, 'Fertilización orgánica'),
(3, 3,  1, 2.00, 'litros', '2025-08-05', 6, 'Control de broca preventivo'),
(4, 4,  2, 1.50, 'litros', '2025-08-10', 6, 'Control ojo de gallo'),
(5, 5,  3, 2.50, 'qq',     '2025-08-15', 5, 'Abono orgánico primera aplicación'),
(6, 6,  4, 200.00,'plantas','2025-09-01', 6, 'Almácigo Geisha para renovación'),
(7, 7,  3, 3.50, 'qq',     '2025-09-05', 5, 'Fertilización pre-cosecha'),
(8, 8,  1, 1.00, 'litros', '2025-09-10', 6, 'Insecticida sistémico'),
(9, 9,  2, 1.00, 'litros', '2025-09-15', 5, 'Fungicida cúprico'),
(10,10, 3, 4.00, 'qq',     '2025-09-20', 6, 'Abono completo alto rendimiento'),
(11,11, 4, 150.00,'plantas','2025-10-01', 5, 'Almácigo Bourbon para renovación');

-- ##################################################
-- 20. PRECIOS CAFE
-- NOTA: trg_log_precios se dispara en cada INSERT → requiere emp id=1 ya creado
-- ##################################################
INSERT INTO precios_cafe (tipo_cafe_id, precio_quintal, fecha_vigencia, fecha_fin) VALUES
(1, 200.00, '2025-12-01', NULL),  -- cereza inicial
(2, 350.00, '2025-12-01', NULL),  -- pergamino_humedo inicial
(3, 500.00, '2025-12-01', NULL),  -- pergamino_seco inicial
(4, 900.00, '2025-12-01', NULL);  -- cafe_oro inicial

-- Cambio de precios (genera entradas en log_precios con variacion)
-- Cereza sube en enero
UPDATE precios_cafe SET precio_quintal = 210.00, updated_at = NOW()
WHERE tipo_cafe_id = 1 AND fecha_vigencia = '2025-12-01';
-- Cereza sube de nuevo en marzo
UPDATE precios_cafe SET precio_quintal = 215.00, updated_at = NOW()
WHERE tipo_cafe_id = 1 AND fecha_vigencia = '2025-12-01';
-- Pergamino húmedo sube en febrero
UPDATE precios_cafe SET precio_quintal = 365.00, updated_at = NOW()
WHERE tipo_cafe_id = 2 AND fecha_vigencia = '2025-12-01';
-- Pergamino húmedo sube de nuevo en abril
UPDATE precios_cafe SET precio_quintal = 372.00, updated_at = NOW()
WHERE tipo_cafe_id = 2 AND fecha_vigencia = '2025-12-01';

-- ##################################################
-- 21. BODEGAS
-- ##################################################
INSERT INTO bodegas (codigo, nombre, cooperativa_id, es_central, capacidad_qq, bodeguero_id) VALUES
('BOD-001', 'Bodega La Unión',         1, FALSE, 500.00,  9),
('BOD-002', 'Bodega El Progreso',      2, FALSE, 500.00, 10),
('BOD-003', 'Bodega Los Cuchumatanes', 3, FALSE, 400.00, 11),
('BOD-CEN', 'Bodega Central OFI',      1, TRUE,  2000.00, 12);

-- ##################################################
-- 22. ACTIVOS (vehículos para traslados y exportaciones)
-- ##################################################
INSERT INTO activos (codigo, descripcion, categoria, fecha_adquisicion, valor_compra, estado, cooperativa_id, responsable_id, observaciones) VALUES
('ACT-VEH-001','Camión Ford F-650 Placa P-001-ABC', 'vehiculo', '2020-06-15', 320000.00, 'en_uso', 1, 13, 'Capacidad 5 toneladas'),
('ACT-VEH-002','Camión Toyota Dyna Placa P-002-XYZ', 'vehiculo', '2021-03-10', 280000.00, 'en_uso', 2, 14, 'Capacidad 4 toneladas'),
('ACT-VEH-003','Camioneta Mitsubishi Placa P-003-DEF', 'vehiculo', '2022-01-20', 180000.00, 'en_uso', 3, 13, 'Capacidad 2 toneladas'),
('ACT-MAQ-001','Despulpadora Penagos 3000',          'maquinaria','2019-08-01', 95000.00,  'en_uso', 1,  9, 'Capacidad 500 qq/día'),
('ACT-MAQ-002','Secadora IMISA Modular',              'maquinaria','2020-11-15', 150000.00, 'en_uso', 1,  9, 'Capacidad 200 qq por ciclo'),
('ACT-MAQ-003','Trilladora Pinhalense',               'maquinaria','2021-05-20', 220000.00, 'en_uso', 1,  9, 'Capacidad 100 qq/hora'),
('ACT-MOB-001','Escritorio gerencia',                 'mobiliario', '2018-02-10', 4500.00,  'en_uso', 1,  1, NULL),
('ACT-HER-001','Costaleras y costales',               'herramienta','2023-01-05', 12000.00, 'en_uso', 1,  9, '500 unidades');

-- ##################################################
-- 23. RECIBOS (35 total: ~25 socios, ~10 externos)
-- trg_actualizar_inventario_recibo se dispara en cada INSERT
-- Bodeguero coop1=9, coop2=10, coop3=11 | Supervisor coop1=2, coop2=3, coop3=4
-- ##################################################
INSERT INTO recibos (numero, bodega_id, productor_id, bodeguero_id, supervisor_id,
    tipo_cafe_id, peso_bruto_qq, peso_neto_qq, fecha_recibo, hora_recibo) VALUES
-- Recibos socios coop 1 (bodega 1)
('REC-2025-001', 1,  1, 9, 2, 1, 20.50, 20.00, '2025-12-05', '08:30:00'),
('REC-2025-002', 1,  2, 9, 2, 1, 15.00, 14.60, '2025-12-08', '09:15:00'),
('REC-2025-003', 1,  3, 9, 2, 2, 25.00, 24.50, '2025-12-10', '07:45:00'),
('REC-2025-004', 1,  5, 9, 2, 1, 18.00, 17.50, '2025-12-15', '10:00:00'),
('REC-2025-005', 1,  1, 9, 2, 2, 22.00, 21.50, '2025-12-20', '08:00:00'),
-- Recibos socios coop 2 (bodega 2)
('REC-2025-006', 2,  6, 10, 3, 3, 30.00, 29.50, '2025-12-12', '09:30:00'),
('REC-2025-007', 2,  7, 10, 3, 2, 28.00, 27.50, '2025-12-18', '08:45:00'),
('REC-2025-008', 2,  8, 10, 3, 3, 35.00, 34.50, '2025-12-22', '07:30:00'),
('REC-2025-009', 2,  9, 10, 3, 1, 16.00, 15.60, '2025-12-28', '10:15:00'),
('REC-2025-010', 2, 10, 10, 3, 2, 24.00, 23.50, '2025-12-30', '09:00:00'),
-- Recibos socios coop 3 (bodega 3)
('REC-2026-001', 3, 11, 11, 4, 3, 20.00, 19.60, '2026-01-05', '08:00:00'),
('REC-2026-002', 3, 12, 11, 4, 2, 18.50, 18.10, '2026-01-08', '09:45:00'),
('REC-2026-003', 3, 14, 11, 4, 3, 32.00, 31.50, '2026-01-12', '07:30:00'),
('REC-2026-004', 3, 15, 11, 4, 1, 14.00, 13.70, '2026-01-15', '10:30:00'),
-- Recibos socios mes de enero-febrero (coop 1 y 2)
('REC-2026-005', 1,  2, 9,  2, 2, 26.00, 25.50, '2026-01-20', '08:15:00'),
('REC-2026-006', 2,  6, 10, 3, 3, 40.00, 39.20, '2026-01-25', '07:00:00'),
('REC-2026-007', 1,  3, 9,  2, 1, 19.00, 18.60, '2026-02-03', '09:00:00'),
('REC-2026-008', 2,  8, 10, 3, 3, 45.00, 44.20, '2026-02-10', '08:30:00'),
('REC-2026-009', 3, 11, 11, 4, 2, 22.50, 22.00, '2026-02-15', '09:15:00'),
('REC-2026-010', 1,  1, 9,  2, 1, 23.00, 22.50, '2026-02-20', '07:45:00'),
-- Recibos socios marzo-abril
('REC-2026-011', 2,  6, 10, 3, 3, 50.00, 49.00, '2026-03-05', '08:00:00'),
('REC-2026-012', 1,  5, 9,  2, 2, 28.00, 27.40, '2026-03-10', '09:30:00'),
('REC-2026-013', 3, 14, 11, 4, 3, 35.00, 34.30, '2026-03-15', '07:15:00'),
('REC-2026-014', 2, 10, 10, 3, 1, 21.00, 20.60, '2026-03-20', '10:00:00'),
('REC-2026-015', 1,  3, 9,  2, 2, 30.00, 29.40, '2026-04-02', '08:45:00'),
-- Recibos productores externos (5 distintos, bodega 1 y 2)
('REC-EXT-001',  1, 16, 9,  2, 1, 12.00, 11.70, '2026-01-10', '11:00:00'),
('REC-EXT-002',  2, 17, 10, 3, 2, 10.00,  9.80, '2026-01-18', '10:45:00'),
('REC-EXT-003',  1, 18, 9,  2, 1, 15.00, 14.60, '2026-02-05', '09:30:00'),
('REC-EXT-004',  2, 19, 10, 3, 3, 18.00, 17.60, '2026-02-22', '08:15:00'),
('REC-EXT-005',  1, 20, 9,  2, 2, 13.00, 12.70, '2026-03-08', '10:00:00'),
('REC-EXT-006',  2, 16, 10, 3, 1, 20.00, 19.50, '2026-03-18', '09:00:00'),
('REC-EXT-007',  1, 17, 9,  2, 2, 16.00, 15.60, '2026-04-01', '08:30:00'),
('REC-EXT-008',  2, 18, 10, 3, 3, 22.00, 21.50, '2026-04-08', '07:45:00'),
('REC-EXT-009',  1, 19, 9,  2, 1, 14.00, 13.70, '2026-04-12', '10:15:00'),
('REC-EXT-010',  2, 20, 10, 3, 2, 17.00, 16.60, '2026-04-18', '09:30:00');

-- ##################################################
-- 24. TURNOS DESCARGA (supervisores asignan cargadores)
-- ##################################################
INSERT INTO turnos_descarga (recibo_id, cargador_id, sacos_descargados, hora_inicio, hora_fin) VALUES
(1,  15, 41, '08:30', '10:00'),
(1,  16, 40, '08:30', '10:00'),
(2,  15, 29, '09:15', '10:15'),
(3,  15, 49, '07:45', '09:30'),
(3,  16, 49, '07:45', '09:30'),
(4,  16, 35, '10:00', '11:15'),
(5,  15, 43, '08:00', '09:45'),
(6,  15, 59, '09:30', '11:30'),
(7,  16, 55, '08:45', '10:30'),
(8,  15, 69, '07:30', '09:45'),
(8,  16, 69, '07:30', '09:45'),
(9,  15, 31, '10:15', '11:15'),
(10, 16, 47, '09:00', '10:30'),
(11, 15, 39, '08:00', '09:30'),
(12, 16, 36, '09:45', '11:00'),
(13, 15, 63, '07:30', '09:30'),
(14, 16, 27, '10:30', '11:30'),
(15, 15, 51, '08:15', '10:00'),
(16, 15, 78, '07:00', '09:30'),
(17, 16, 37, '09:00', '10:30'),
(18, 15, 88, '08:30', '11:00'),
(19, 16, 44, '09:15', '10:45'),
(20, 15, 45, '07:45', '09:30'),
(26, 15, 23, '11:00', '12:00'),
(27, 16, 31, '10:45', '12:00'),
(28, 15, 29, '09:30', '10:45'),
(29, 16, 35, '08:15', '09:30'),
(30, 15, 25, '10:00', '11:15'),
(31, 16, 39, '09:00', '10:15'),
(32, 15, 31, '08:30', '09:45'),
(33, 16, 43, '07:45', '09:15'),
(34, 15, 27, '10:15', '11:15'),
(35, 16, 33, '09:30', '10:45');

-- ##################################################
-- 25. FACTURAS COMPRA
-- Precios calculados manualmente:
--   cereza socio:      Q215 * 1.10 = Q236.50 (precio vigente temporada)
--   cereza externo:    Q215.00
--   perg_hum socio:    Q372 * 1.10 = Q409.20
--   perg_hum externo:  Q372.00
--   perg_seco socio:   Q500 * 1.10 = Q550.00
--   perg_seco externo: Q500.00
-- ##################################################
INSERT INTO facturas_compra (numero, recibo_id, contador_id, fecha_factura,
    quintales_netos, precio_unitario, monto_total, anticipo, saldo_pagar,
    forma_pago, banco, num_cheque, fecha_cheque, estado) VALUES
-- Socios cereza (tipo 1)
('F-000001', 1,  7, '2025-12-05', 20.00, 236.50,  4730.00,    0.00,  4730.00, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-000002', 2,  7, '2025-12-08', 14.60, 236.50,  3452.90,  500.00,  2952.90, 'efectivo', NULL, NULL, NULL, 'pendiente'),
('F-000004', 4,  7, '2025-12-15', 17.50, 236.50,  4138.75,    0.00,  4138.75, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-000010', 14, 7, '2026-01-15', 13.70, 236.50,  3240.05,    0.00,  3240.05, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-000017', 20, 7, '2026-02-20', 22.50, 236.50,  5321.25, 1000.00,  4321.25, 'cheque',  'Banrural', 'CH-001', '2026-02-20', 'pendiente'),
-- Socios pergamino húmedo (tipo 2)
('F-000003', 3,  7, '2025-12-10', 24.50, 409.20, 10025.40,    0.00, 10025.40, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-000007', 7,  8, '2025-12-18', 27.50, 409.20, 11253.00, 2000.00,  9253.00, 'efectivo', NULL, NULL, NULL, 'pendiente'),
('F-000009', 10, 8, '2025-12-30', 23.50, 409.20,  9616.20,    0.00,  9616.20, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-000012', 15, 7, '2026-01-20', 25.50, 409.20, 10434.60,    0.00, 10434.60, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-000018', 22, 7, '2026-03-10', 27.40, 409.20, 11212.08,    0.00, 11212.08, 'cheque',  'G&T Continental', 'CH-002', '2026-03-10', 'pendiente'),
-- Socios pergamino seco (tipo 3)
('F-000006', 6,  8, '2025-12-12', 29.50, 550.00, 16225.00, 3000.00, 13225.00, 'cheque',  'Banrural', 'CH-003', '2025-12-12', 'pendiente'),
('F-000008', 8,  8, '2025-12-22', 34.50, 550.00, 18975.00,    0.00, 18975.00, 'cheque',  'G&T Continental', 'CH-004', '2025-12-22', 'pagada'),
('F-000011', 13, 8, '2026-01-12', 31.50, 550.00, 17325.00, 2000.00, 15325.00, 'cheque',  'Banrural', 'CH-005', '2026-01-12', 'pendiente'),
('F-000013', 16, 8, '2026-01-25', 39.20, 550.00, 21560.00,    0.00, 21560.00, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-000016', 19, 8, '2026-02-15', 22.00, 550.00, 12100.00, 1500.00, 10600.00, 'efectivo', NULL, NULL, NULL, 'pendiente'),
('F-000021', 21, 8, '2026-03-05', 49.00, 550.00, 26950.00, 5000.00, 21950.00, 'cheque',  'Banrural', 'CH-006', '2026-03-05', 'pendiente'),
('F-000023', 23, 8, '2026-03-15', 34.30, 550.00, 18865.00,    0.00, 18865.00, 'efectivo', NULL, NULL, NULL, 'pagada'),
-- Externos cereza
('F-EXT-001', 26, 7, '2026-01-10', 11.70, 215.00,  2515.50,    0.00,  2515.50, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-EXT-003', 28, 7, '2026-02-05', 14.60, 215.00,  3139.00,    0.00,  3139.00, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-EXT-006', 31, 7, '2026-03-18', 19.50, 215.00,  4192.50,    0.00,  4192.50, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-EXT-009', 34, 7, '2026-04-12', 13.70, 215.00,  2945.50,    0.00,  2945.50, 'efectivo', NULL, NULL, NULL, 'pendiente'),
-- Externos pergamino húmedo
('F-EXT-002', 27, 8, '2026-01-18',  9.80, 372.00,  3645.60,    0.00,  3645.60, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-EXT-005', 30, 7, '2026-03-08', 12.70, 372.00,  4724.40,    0.00,  4724.40, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-EXT-007', 32, 7, '2026-04-01', 15.60, 372.00,  5803.20,    0.00,  5803.20, 'efectivo', NULL, NULL, NULL, 'pendiente'),
('F-EXT-010', 35, 8, '2026-04-18', 16.60, 372.00,  6175.20,    0.00,  6175.20, 'efectivo', NULL, NULL, NULL, 'pendiente'),
-- Externos pergamino seco
('F-EXT-004', 29, 8, '2026-02-22', 17.60, 500.00,  8800.00,    0.00,  8800.00, 'efectivo', NULL, NULL, NULL, 'pagada'),
('F-EXT-008', 33, 8, '2026-04-08', 21.50, 500.00, 10750.00,    0.00, 10750.00, 'efectivo', NULL, NULL, NULL, 'pendiente');

-- ##################################################
-- 26. CONTROL CALIDAD
-- trg_bono_especialidad se dispara cuando puntaje_taza >= 80
-- Recibos 3,6,8,11,13,21 → especialidad (puntaje >= 80)
-- ##################################################
INSERT INTO control_calidad (recibo_id, responsable_id, porcentaje_humedad,
    rendimiento_estimado, defectos, puntaje_taza, es_especialidad, fecha_evaluacion) VALUES
-- Socios
( 1,  5, 12.50, 75.00, 'Ninguno detectado',                 78.50, FALSE, '2025-12-05'),
( 2,  5, 13.00, 73.00, 'Broca leve 2%',                     72.00, FALSE, '2025-12-08'),
( 3,  6, 11.80, 80.50, 'Sin defectos significativos',        87.50, FALSE, '2025-12-10'),  -- ESPECIALIDAD
( 4,  5, 12.80, 74.00, 'Daño por clima 3%',                  71.00, FALSE, '2025-12-15'),
( 5,  6, 12.20, 77.00, 'Ninguno detectado',                  76.00, FALSE, '2025-12-20'),
( 6,  5, 11.50, 82.00, 'Excelente muestra, homogénea',       92.00, FALSE, '2025-12-12'),  -- ESPECIALIDAD
( 7,  6, 12.60, 79.00, 'Broca 1%',                          74.50, FALSE, '2025-12-18'),
( 8,  5, 11.20, 84.00, 'Sin defectos, muestra premium',      85.00, FALSE, '2025-12-22'),  -- ESPECIALIDAD
( 9,  6, 13.50, 72.00, 'Exceso humedad, manchado 4%',       68.00, FALSE, '2025-12-28'),
(10,  5, 12.00, 78.00, 'Ninguno detectado',                  75.50, FALSE, '2025-12-30'),
(11,  6, 11.60, 83.00, 'Muestra muy limpia',                 82.00, FALSE, '2026-01-05'),  -- ESPECIALIDAD
(12,  5, 12.30, 76.50, 'Broca leve 1.5%',                   73.00, FALSE, '2026-01-08'),
(13,  6, 11.30, 85.00, 'Premium, aroma muy agradable',       91.00, FALSE, '2026-01-12'),  -- ESPECIALIDAD
(14,  5, 12.70, 74.50, 'Daño leve por lluvia',               70.50, FALSE, '2026-01-15'),
(15,  6, 12.10, 78.50, 'Ninguno detectado',                  77.00, FALSE, '2026-01-20'),
(16,  5, 11.40, 83.50, 'Excelente uniformidad Geisha',       88.50, FALSE, '2026-01-25'),  -- ESPECIALIDAD
(17,  6, 12.50, 75.00, 'Broca 2%',                          73.50, FALSE, '2026-02-03'),
(18,  5, 11.10, 86.00, 'Muestra excepcional',                89.50, FALSE, '2026-02-10'),  -- ESPECIALIDAD (7o)
(19,  6, 12.20, 77.50, 'Ninguno detectado',                  76.50, FALSE, '2026-02-15'),
(20,  5, 12.80, 73.00, 'Broca leve 1%',                     72.50, FALSE, '2026-02-20'),
(21,  6, 11.00, 87.00, 'Lote premium Geisha',                94.00, FALSE, '2026-03-05'),  -- ESPECIALIDAD (8o)
(22,  5, 12.40, 78.00, 'Ninguno detectado',                  77.50, FALSE, '2026-03-10'),
(23,  6, 11.50, 82.50, 'Excelente estructura',               83.00, FALSE, '2026-03-15'),  -- ESPECIALIDAD (9o)
(24,  5, 12.90, 74.00, 'Daño mínimo cosecha',                71.50, FALSE, '2026-03-20'),
(25,  6, 12.00, 79.00, 'Ninguno detectado',                  78.00, FALSE, '2026-04-02'),
-- Externos
(26,  9, 13.00, 71.00, 'Humedad alta, grano irregular',      67.00, FALSE, '2026-01-10'),
(27,  10,12.50, 76.00, 'Broca 3%',                          71.50, FALSE, '2026-01-18'),
(28,  9, 13.20, 70.00, 'Manchado por lluvia 5%',             66.00, FALSE, '2026-02-05'),
(29,  10,12.80, 77.50, 'Ninguno relevante',                  74.00, FALSE, '2026-02-22'),
(30,  9, 12.60, 75.50, 'Broca leve 2%',                     72.00, FALSE, '2026-03-08'),
(31,  10,13.10, 72.00, 'Manchado 4%',                       68.50, FALSE, '2026-03-18'),
(32,  9, 12.30, 76.50, 'Ninguno detectado',                  75.00, FALSE, '2026-04-01'),
(33,  10,12.00, 78.00, 'Aceptable',                          74.50, FALSE, '2026-04-08'),
(34,  9, 13.50, 70.50, 'Humedad elevada',                    67.50, FALSE, '2026-04-12'),
(35,  10,12.40, 77.00, 'Broca 1.5%',                        73.00, FALSE, '2026-04-18');

-- ##################################################
-- 27. LOTES DE PROCESAMIENTO (12 lotes de los mejores recibos)
-- ##################################################
INSERT INTO lotes_procesamiento (codigo, recibo_id) VALUES
('LOTE-2025-001',  1),
('LOTE-2025-002',  3),
('LOTE-2025-003',  6),
('LOTE-2025-004',  8),
('LOTE-2026-001', 11),
('LOTE-2026-002', 13),
('LOTE-2026-003', 16),
('LOTE-2026-004', 18),
('LOTE-2026-005', 21),
('LOTE-2026-006', 22),
('LOTE-2026-007', 23),
('LOTE-2026-008', 25);

-- ##################################################
-- 28. BENEFICIADO HUMEDO (lotes de cereza y pergamino húmedo)
-- Solo aplica a recibos de cereza (tipo 1) y pergamino húmedo (tipo 2)
-- ##################################################
INSERT INTO beneficiado_humedo (lote_id, operador_id, fecha, volumen_entrada_qq, merma_kg, observaciones) VALUES
(1,  9, '2025-12-06', 20.00,  85.00, 'Despulpado sin inconvenientes'),
(2,  9, '2025-12-11', 24.50, 100.50, 'Fermentación controlada 18 horas'),
(3,  10,'2025-12-13', 29.50, 125.00, 'Excelente lote, fermentación óptima'),
(5,  11,'2026-01-06', 19.60,  82.00, 'Proceso estándar, sin observaciones'),
(6,  10,'2026-01-13', 31.50, 130.00, 'Lote premium, despulpado preciso'),
(7,  9, '2026-01-26', 39.20, 162.00, 'Volumen alto, proceso en dos tandas'),
(8,  9, '2026-02-11', 44.20, 185.00, 'Muestra excepcional, fermentación 20h'),
(9,  10,'2026-03-06', 49.00, 205.00, 'Lote Geisha, proceso especial 24h');

-- ##################################################
-- 29. SECADO
-- ##################################################
INSERT INTO secado (lote_id, operador_id, metodo, temperatura_c, dias_empleados, humedad_final_pct, fecha_inicio, fecha_fin) VALUES
(1,  9,  'patio',   NULL,  14, 11.50, '2025-12-07', '2025-12-21'),
(2,  9,  'patio',   NULL,  12, 11.80, '2025-12-12', '2025-12-24'),
(3,  10, 'maquina', 42.00,  5, 11.20, '2025-12-14', '2025-12-19'),
(4,  9,  'patio',   NULL,  13, 11.60, '2025-12-23', '2026-01-05'),
(5,  11, 'patio',   NULL,  14, 11.40, '2026-01-07', '2026-01-21'),
(6,  10, 'maquina', 40.00,  5, 11.10, '2026-01-14', '2026-01-19'),
(7,  9,  'maquina', 41.00,  6, 11.30, '2026-01-27', '2026-02-02'),
(8,  9,  'maquina', 40.00,  5, 11.00, '2026-02-12', '2026-02-17'),
(9,  10, 'maquina', 38.00,  4, 10.80, '2026-03-07', '2026-03-11'),
(10, 9,  'patio',   NULL,  15, 11.70, '2026-03-11', '2026-03-26'),
(11, 9,  'patio',   NULL,  13, 11.50, '2026-03-16', '2026-03-29'),
(12, 10, 'patio',   NULL,  14, 11.60, '2026-04-03', '2026-04-17');

-- ##################################################
-- 30. BENEFICIADO SECO (trilla para obtener café oro)
-- ##################################################
INSERT INTO beneficiado_seco (lote_id, operador_id, fecha, qq_pergamino_entrada, qq_oro_resultado, porcentaje_rendimiento, observaciones) VALUES
( 1,  9, '2025-12-22', 20.00, 16.20, 81.00, 'Rendimiento estándar'),
( 2,  9, '2025-12-25', 24.50, 20.09, 82.00, 'Buen rendimiento, lote limpio'),
( 3, 10, '2025-12-20', 29.50, 24.60, 83.39, 'Rendimiento alto, producto premium'),
( 4,  9, '2026-01-06', 34.50, 27.26, 79.01, 'Rendimiento normal pergamino seco'),
( 5, 11, '2026-01-22', 19.60, 16.07, 82.00, 'Sin observaciones'),
( 6, 10, '2026-01-20', 31.50, 26.35, 83.65, 'Excelente calidad oro'),
( 7,  9, '2026-02-03', 39.20, 30.77, 78.50, 'Volumen procesado correctamente'),
( 8,  9, '2026-02-18', 44.20, 37.14, 84.00, 'Lote excepcional café de especialidad'),
( 9, 10, '2026-03-12', 49.00, 41.65, 85.00, 'Lote Geisha rendimiento premium'),
(10,  9, '2026-03-27', 23.50, 18.80, 80.00, 'Rendimiento adecuado'),
(11,  9, '2026-03-30', 27.40, 22.41, 81.79, 'Buen resultado de trilla'),
(12, 10, '2026-04-18', 29.00, 23.20, 80.00, 'Procesamiento final de temporada');

-- ##################################################
-- 31. CLASIFICACIONES LOTE
-- ##################################################
INSERT INTO clasificaciones_lote (lote_id, clasificacion_id, cantidad_qq, fecha_clasificacion) VALUES
-- Lote 1
(1,  1, 10.50, '2025-12-22'),  -- Extra
(1,  2,  4.70, '2025-12-22'),  -- Superior
(1,  7,  1.00, '2025-12-22'),  -- Descarte
-- Lote 2
(2,  1, 13.00, '2025-12-25'),  -- Extra
(2,  2,  6.00, '2025-12-25'),  -- Superior
(2,  7,  1.09, '2025-12-25'),  -- Descarte
-- Lote 3 (especialidad)
(3,  1, 17.00, '2025-12-20'),  -- Extra
(3,  2,  6.60, '2025-12-20'),  -- Superior
(3,  7,  1.00, '2025-12-20'),  -- Descarte
-- Lote 4
(4,  1, 15.00, '2026-01-06'),  -- Extra
(4,  2,  9.26, '2026-01-06'),  -- Superior
(4,  7,  3.00, '2026-01-06'),  -- Descarte
-- Lote 5
(5,  1,  9.00, '2026-01-22'),  -- Extra
(5,  2,  6.07, '2026-01-22'),  -- Superior
(5,  7,  1.00, '2026-01-22'),  -- Descarte
-- Lote 6 (especialidad)
(6,  1, 18.00, '2026-01-20'),  -- Extra
(6,  2,  7.35, '2026-01-20'),  -- Superior
(6,  7,  1.00, '2026-01-20'),  -- Descarte
-- Lote 7
(7,  1, 18.00, '2026-02-03'),  -- Extra
(7,  2, 10.77, '2026-02-03'),  -- Superior
(7,  7,  2.00, '2026-02-03'),  -- Descarte
-- Lote 8 (especialidad)
(8,  1, 25.00, '2026-02-18'),  -- Extra
(8,  2, 10.14, '2026-02-18'),  -- Superior
(8,  6,  1.00, '2026-02-18'),  -- Peaberry
(8,  7,  1.00, '2026-02-18'),  -- Descarte
-- Lote 9 (especialidad Geisha)
(9,  1, 28.00, '2026-03-12'),  -- Extra
(9,  2, 10.65, '2026-03-12'),  -- Superior
(9,  6,  2.00, '2026-03-12'),  -- Peaberry
(9,  7,  1.00, '2026-03-12'),  -- Descarte
-- Lote 10
(10, 2, 12.00, '2026-03-27'),  -- Superior
(10, 3,  5.80, '2026-03-27'),  -- Segunda
(10, 7,  1.00, '2026-03-27'),  -- Descarte
-- Lote 11
(11, 1, 14.00, '2026-03-30'),  -- Extra
(11, 2,  7.41, '2026-03-30'),  -- Superior
(11, 7,  1.00, '2026-03-30'),  -- Descarte
-- Lote 12
(12, 2, 15.00, '2026-04-18'),  -- Superior
(12, 3,  7.20, '2026-04-18'),  -- Segunda
(12, 7,  1.00, '2026-04-18');  -- Descarte

-- ##################################################
-- 32. INVENTARIO CAFE - Insertar saldos clasificados en bodegas de cooperativas
-- (representan el café procesado listo para traslado)
-- Los triggers ya insertaron café sin clasificar en el inventario.
-- Ahora insertamos el café clasificado resultante del beneficiado.
-- ##################################################
-- Bodega 1 (La Unión): lotes 1,2,5,7,8,11 = Extra + Superior disponible
INSERT INTO inventario_cafe (bodega_id, tipo_cafe_id, clasificacion_id, cantidad_qq, ultima_actualizacion) VALUES
(1, 4, 1, 104.50, NOW()),  -- Extra en bodega 1
(1, 4, 2,  48.09, NOW()),  -- Superior en bodega 1
(1, 4, 6,   2.00, NOW()),  -- Peaberry en bodega 1
-- Bodega 2 (El Progreso): lotes 3,4,6,9,10,12 = Extra + Superior
(2, 4, 1, 100.00, NOW()),  -- Extra en bodega 2
(2, 4, 2,  41.86, NOW()),  -- Superior en bodega 2
(2, 4, 3,  13.00, NOW()),  -- Segunda en bodega 2
(2, 4, 6,   2.00, NOW());  -- Peaberry en bodega 2

-- ##################################################
-- 33. TRASLADOS (3 traslados de bodegas cooperativas a bodega central)
-- Hacemos los movimientos de inventario manualmente
-- ##################################################
INSERT INTO traslados (numero, bodega_origen_id, bodega_destino_id, clasificacion_id,
    cantidad_qq, transportista_id, vehiculo_id,
    bodeguero_despacha_id, bodeguero_recibe_id,
    fecha_salida, fecha_llegada, nota_contable, estado) VALUES
('TRS-2026-001', 1, 4, 1, 50.00, 13, 1, 9, 12, '2026-04-05 06:00:00', '2026-04-05 09:30:00', 'NC-TRS-001 Traslado Extra bodega La Unión a Central', 'recibido'),
('TRS-2026-002', 2, 4, 1, 60.00, 14, 2, 10, 12, '2026-04-08 06:30:00', '2026-04-08 10:00:00', 'NC-TRS-002 Traslado Extra bodega El Progreso a Central', 'recibido'),
('TRS-2026-003', 2, 4, 2, 30.00, 14, 2, 10, 12, '2026-04-10 07:00:00', '2026-04-10 10:30:00', 'NC-TRS-003 Traslado Superior El Progreso a Central', 'recibido');

-- Actualizar inventario de bodegas origen (descontar)
UPDATE inventario_cafe SET cantidad_qq = cantidad_qq - 50.00, ultima_actualizacion = NOW()
WHERE bodega_id = 1 AND clasificacion_id = 1;

UPDATE inventario_cafe SET cantidad_qq = cantidad_qq - 60.00, ultima_actualizacion = NOW()
WHERE bodega_id = 2 AND clasificacion_id = 1;

UPDATE inventario_cafe SET cantidad_qq = cantidad_qq - 30.00, ultima_actualizacion = NOW()
WHERE bodega_id = 2 AND clasificacion_id = 2;

-- Insertar en bodega central (acreditar)
INSERT INTO inventario_cafe (bodega_id, tipo_cafe_id, clasificacion_id, cantidad_qq, ultima_actualizacion) VALUES
(4, 4, 1, 110.00, NOW()),  -- Extra en bodega central (50+60)
(4, 4, 2,  30.00, NOW());  -- Superior en bodega central

-- Registrar movimientos de inventario para traslados
INSERT INTO movimientos_inventario (bodega_id, tipo_cafe_id, clasificacion_id, tipo_movimiento, cantidad_qq, referencia_id, responsable_id, fecha) VALUES
(1, 4, 1, 'salida_traslado',   50.00, 1, 9,  '2026-04-05 06:00:00'),
(4, 4, 1, 'entrada_traslado',  50.00, 1, 12, '2026-04-05 09:30:00'),
(2, 4, 1, 'salida_traslado',   60.00, 2, 10, '2026-04-08 06:30:00'),
(4, 4, 1, 'entrada_traslado',  60.00, 2, 12, '2026-04-08 10:00:00'),
(2, 4, 2, 'salida_traslado',   30.00, 3, 10, '2026-04-10 07:00:00'),
(4, 4, 2, 'entrada_traslado',  30.00, 3, 12, '2026-04-10 10:30:00');

-- ##################################################
-- 34. CONTRATOS DE EXPORTACION
-- ##################################################
INSERT INTO contratos_exportacion (numero, empresa_id, fecha_firma, fecha_entrega_est,
    qq_totales_pactados, precio_usd_quintal, estado, observaciones) VALUES
-- Contrato 1: cumplir en 1 exportación (100 qq Extra)
('CONT-2026-001', 1, '2026-03-15', '2026-04-30', 100.00, 280.00, 'vigente', 'Café de especialidad Extra, Geisha y Bourbon'),
-- Contrato 2: cumplir en 2 exportaciones parciales (200 qq Extra)
('CONT-2026-002', 2, '2026-03-20', '2026-05-20', 200.00, 265.00, 'vigente', 'Café Extra para tostado especial Blue Bottle'),
-- Contrato 3: en riesgo (fecha próxima, poco exportado - para consulta 4)
('CONT-2026-003', 3, '2026-04-01', '2026-05-10', 300.00, 270.00, 'vigente', 'Urgente - Stumptown temporada alta');

-- ##################################################
-- 35. CONTRATO DETALLE
-- ##################################################
INSERT INTO contrato_detalle (contrato_id, tipo_cafe_id, clasificacion_id, cantidad_qq) VALUES
(1, 4, 1, 100.00),  -- CONT-001: 100 qq Extra cafe_oro
(2, 4, 1, 200.00),  -- CONT-002: 200 qq Extra cafe_oro
(3, 4, 1, 200.00),  -- CONT-003: 200 qq Extra cafe_oro
(3, 4, 2, 100.00);  -- CONT-003: 100 qq Superior cafe_oro

-- ##################################################
-- 36. EXPORTACIONES
-- trg_validar_contrato se dispara en cada INSERT
-- ##################################################
INSERT INTO exportaciones (numero, contrato_id, bodega_origen_id, transportista_id,
    vehiculo_id, autorizador_id, fecha_despacho, quintales_exportados,
    num_contenedor, puerto_salida) VALUES
-- Exportación 1: cumple contrato 1 en una sola operación (100 qq)
('EXP-2026-001', 1, 4, 13, 1, 1, '2026-04-22', 100.00, 'CONT-GT-001-2026', 'Puerto Quetzal, Guatemala'),
-- Exportaciones 2 y 3: cumplen contrato 2 en dos parciales
('EXP-2026-002', 2, 4, 14, 2, 1, '2026-04-25', 100.00, 'CONT-GT-002-2026', 'Puerto Quetzal, Guatemala'),
('EXP-2026-003', 2, 4, 13, 1, 1, '2026-04-28', 100.00, 'CONT-GT-003-2026', 'Puerto Quetzal, Guatemala'),
-- Exportación parcial de contrato 3 (solo 50/300 qq = 16.7%, contrato "en riesgo")
('EXP-2026-004', 3, 4, 14, 2, 1, '2026-04-20',  50.00, 'CONT-GT-004-2026', 'Puerto Quetzal, Guatemala');

-- Descontar inventario bodega central por exportaciones
UPDATE inventario_cafe SET cantidad_qq = cantidad_qq - 110.00, ultima_actualizacion = NOW()
WHERE bodega_id = 4 AND clasificacion_id = 1;

-- Registrar movimientos de exportación
INSERT INTO movimientos_inventario (bodega_id, tipo_cafe_id, clasificacion_id, tipo_movimiento, cantidad_qq, referencia_id, responsable_id, fecha) VALUES
(4, 4, 1, 'salida_exportacion', 100.00, 1, 1, '2026-04-22 10:00:00'),
(4, 4, 1, 'salida_exportacion', 100.00, 2, 1, '2026-04-25 10:00:00'),
(4, 4, 1, 'salida_exportacion', 100.00, 3, 1, '2026-04-28 10:00:00'),
(4, 4, 1, 'salida_exportacion',  50.00, 4, 1, '2026-04-20 10:00:00');

-- ##################################################
-- FIN DE DATOS SEMILLA
-- Total aproximado:
--   6 municipios, 8 roles, 4 tipos café, 7 clasificaciones
--   4 tipos insumo, 5 variedades, 3 empresas extranjeras
--   1 config bono, 3 cooperativas, 17 empleados
--   20 productores, 15 socios, 18 terrenos, 72 esquineros
--   18 evaluaciones, 8 visitas, 16 visita_terrenos
--   12 entregas insumos, 4 precios (+ 4 updates → 8 log entries)
--   4 bodegas, 8 activos, 35 recibos
--   33 turnos descarga, 28 facturas, 35 control calidad
--   12 lotes, 8 beneficiado_humedo, 12 secado
--   12 beneficiado_seco, 37 clasificaciones_lote
--   9 inventario_cafe (+ trigger auto), 3 traslados
--   3 contratos, 4 contrato_detalle, 4 exportaciones
-- ##################################################
COMMIT;