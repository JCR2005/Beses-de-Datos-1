
.mode box -- Configura el modo de salida para mostrar los resultados en formato de tabla

.headers on -- Activa la visualización de los encabezados de las columnas

PRAGMA foreign_keys = ON; -- Habilita la verificación de claves foráneas

BEGIN TRANSACTION; -- Inicia una transacción para asegurar la integridad de los datos durante las inserciones


INSERT INTO CIUDADANO
(NUMERO_DOCUMENTO_identificacion, TIPO_DOCUMENTO_identificacion, NOMBRE, APELLIDOS, FECHA_NACIMIENTO, DIRECCION, NIT, TELEFONO, SEXO, NACIONALIDAD, PROFESION_OFICIO, ESTADO_CIVIL, CORREO, Identificacion_ciudadano_conyuge)
VALUES
('1001000010101','DPI','Juan Carlos','Pérez Gómez','1985-02-14','Zona 1, Huehuetenango','1234567-8','50250001111','M','Guatemalteca','Comerciante','Casado','juan.perez@correo.gt',2),
('1001000010102','DPI','María Elena','López Díaz','1987-10-03','Zona 1, Huehuetenango','2234567-1','50250002222','F','Guatemalteca','Docente','Casada','maria.lopez@correo.gt',1),
('1001000010103','DPI','Pedro José','Ramírez Soto','1979-05-22','Zona 5, Huehuetenango','3234567-2','50250003333','M','Guatemalteca','Agricultor','Soltero','pedro.ramirez@correo.gt',NULL),
('1001000010104','DPI','Ana Lucía','Morales Ruiz','1992-08-19','Zona 3, Huehuetenango','4234567-3','50250004444','F','Guatemalteca','Arquitecta','Soltera','ana.morales@correo.gt',NULL),
('1001000010105','DPI','Luis Fernando','Cano Méndez','1980-12-11','Zona 2, Huehuetenango','5234567-4','50250005555','M','Guatemalteca','Topógrafo','Casado','luis.cano@correo.gt',6),
('1001000010106','DPI','Patricia Isabel','Méndez Choc','1982-01-29','Zona 2, Huehuetenango','6234567-5','50250006666','F','Guatemalteca','Administradora','Casada','patricia.mendez@correo.gt',5),
('1001000010107','DPI','Diego Armando','Paz Cifuentes','1990-03-08','Zona 7, Huehuetenango','7234567-6','50250007777','M','Guatemalteca','Electricista','Soltero','diego.paz@correo.gt',NULL),
('1001000010108','DPI','Sofía Andrea','Tobar Caal','1995-07-15','Zona 4, Huehuetenango','8234567-7','50250008888','F','Guatemalteca','Ingeniera ambiental','Soltera','sofia.tobar@correo.gt',NULL),
('1001000010109','DPI','Carlos Alberto','Leiva Ordóñez','1988-09-10','Zona 6, Huehuetenango','9234567-8','50250009999','M','Guatemalteca','Contador','Casado','carlos.leiva@correo.gt',10),
('1001000010110','DPI','Karla Johana','Ordóñez Méndez','1991-11-27','Zona 6, Huehuetenango','1023456-9','50250001010','F','Guatemalteca','Abogada','Casada','karla.ordonez@correo.gt',9),
('1001000010111','DPI','Miguel Ángel','Cruz Ajanel','1984-06-06','Aldea Xinajoj, Huehuetenango','1123456-0','50250001112','M','Guatemalteca','Conductor','Unido','miguel.cruz@correo.gt',NULL),
('1001000010112','DPI','Rosa Amelia','Chaclán Ixtán','1976-04-21','Cantón El Calvario, Huehuetenango','1223456-1','50250001113','F','Guatemalteca','Comerciante','Viuda','rosa.chaclan@correo.gt',NULL);

INSERT INTO EMPRESA (NOMBRE, DIRECCION, Identificacion_ciudadano) VALUES
('Constructora Altos S.A.','Zona 9, Huehuetenango',4),
('Transportes del Norte S.A.','Zona 8, Huehuetenango',11),
('Materiales y Ferretería La Cumbre','Zona 3, Huehuetenango',1);

INSERT INTO TIPO_LICENCIA
(genero, descripcion_ocupacion_area, unidad_medida, costo_por_obra_m2, costo_licencia_m2_iva, fecha_fin, numero_de_supervisiones, fecha_inicio)
VALUES
('Residencial','Construcción vivienda unifamiliar','m2',180.00,201.60,'2027-12-31',3,'2024-01-01'),
('Comercial','Local comercial y oficina','m2',220.00,246.40,'2027-12-31',4,'2024-01-01'),
('Remodelación','Remodelación de inmueble existente','m2',120.00,134.40,'2027-12-31',2,'2024-01-01');


--CATASTRO

INSERT INTO PREDIO_CATASTRAL
(CODIGO_CATASTRAL, DEPARTAMENTO, MUNICIPIO, UBICACION, AREA_PREDIO, FECHA_ADQUISICION_PREDIO, RELACION_TITULAR_INFORMANTE,
 ID_TIPO_PREDIO, ID_CLASE_PREDIO, ID_FINCA_MATRIZ, ID_DOCUMENTO_AMPARO_TITULARIDAD_CATASTRAL, ID_CAUSA_TITULARIDAD, ID_USO,
 Identificacion_ciudadano_titular, Identificacion_ciudadano_titular_anterior, Identificacion_ciudadano_titular_informante)
VALUES
('13-01-001-0001-0001','Huehuetenango','Huehuetenango','Zona 1, Barrio Centro',250.50,'2019-02-15','Titular',
 2,1,1,1,1,1,1,3,1),
('13-01-001-0001-0002','Huehuetenango','Huehuetenango','Zona 2, Colonia Las Flores',180.00,'2020-08-10','Titular',
 2,1,2,1,1,1,2,1,2),
('13-01-001-0002-0001','Huehuetenango','Huehuetenango','Aldea Xinajoj',1500.00,'2015-06-20','Informante',
 1,1,3,2,2,5,3,NULL,5),
('13-01-001-0003-0001','Huehuetenango','Huehuetenango','Zona 7, Lote 12',320.75,'2021-11-05','Titular',
 2,3,1,2,4,8,6,4,6),
('13-01-001-0004-0001','Huehuetenango','Huehuetenango','Zona 4, Sector Norte',600.00,'2018-03-30','Titular',
 2,4,2,3,3,4,8,NULL,8);

INSERT INTO OBSERVACION_CATASTRAL (OBSERVACION, ID_PREDIO_CATASTRAL) VALUES
('Predio con construcción de dos niveles en buen estado.','13-01-001-0001-0001'),
('Predio con acceso a calle principal y servicios básicos completos.','13-01-001-0001-0002'),
('Terreno agrícola con pendiente moderada.','13-01-001-0002-0001');

INSERT INTO DESACUERDO_PERIMETRAL (TIPO_DESACUERDO, ID_PREDIO_CATASTRAL) VALUES
('LINDEROS','13-01-001-0002-0001'),
('MOJONES','13-01-001-0003-0001');

INSERT INTO COLINDANCIA_PREDIO (DETALLE, ID_PREDIO_CATASTRAL, ID_PREDIO_CATASTRAL_COLINDANTE) VALUES
('Colinda al norte con calle municipal','13-01-001-0001-0001',NULL),
('Colinda al sur con predio residencial vecino','13-01-001-0001-0001','13-01-001-0001-0002'),
('Colinda al oeste con área de reserva','13-01-001-0003-0001','13-01-001-0004-0001');

INSERT INTO SERVIDUMBRE_PREDIO (ANCHO_SERVIDUMBRE, LARGO_SERVIDUMBRE, TIPO_SERVIDUMBRE, ID_PREDIO_CATASTRAL) VALUES
(2.50,30.00,'paso','13-01-001-0002-0001'),
(1.20,45.00,'Energía eléctrica','13-01-001-0003-0001');

INSERT INTO AVALUO
(ID_PREDIO_CATASTRAL, FECHA_AVALUO, IDENTIFICACION_UNICA_EVALUADOR, AREA_AVALUO, ID_ESTADO, VALOR_PREDIO, VALOR_CONSTRUCCION, VALOR_TOTAL)
VALUES
('13-01-001-0001-0001','2025-01-10',9,250.50,1,175000.00,220000.00,395000.00),
('13-01-001-0001-0002','2025-01-12',9,180.00,1,120000.00,165000.00,285000.00),
('13-01-001-0002-0001','2024-12-01',9,1500.00,2,300000.00,0.00,300000.00),
('13-01-001-0003-0001','2025-02-02',9,320.75,1,210000.00,185000.00,395000.00);


--TRÁMITES Y RELACIONADOS


INSERT INTO TRAMITE_CIUDADANO (Id_tramite, Id_ciudadano, Fecha_inicio, Fecha_fin, Id_estado) VALUES
(1,4,'2025-01-15','2025-01-30',2),  -- Licencia construcción aprobada
(2,1,'2025-02-01','2025-02-20',2),  -- Cambio propietario aprobado
(3,2,'2025-02-05',NULL,1),          -- Servicio agua en proceso
(1,6,'2025-02-10',NULL,1),          -- Licencia en proceso
(3,3,'2025-01-20','2025-01-28',2);  -- Servicio aprobado

INSERT INTO REQUISITO_TRAMITE_CIUDADANO (Id_requisito_tramite, id_tramite_ciudadano) VALUES
(1,1),(2,1),(3,1), -- requisitos trámite 1
(4,2),(5,2),       -- requisitos trámite 2
(6,3),(7,3),       -- requisitos trámite 3
(1,4),             -- parcial
(6,5),(7,5);

INSERT INTO DOCUMENTO_TRAMITE_CIUDADANO (id_tramite_ciudadano, Tipo_documento, Documento) VALUES
(1,'Plano catastral',NULL),
(1,'DPI',NULL),
(2,'Escritura',NULL),
(3,'Solicitud de servicio',NULL),
(4,'Formulario licencia',NULL);

INSERT INTO CITA_INVESTIGACION_CATASTRAL
(IDENTIFICACION_UNICA_TITULAR, id_tramite_ciudadano, FECHA_HORA_INICIO, IDENTIFICACION_UNICA_TECNICO_CASTRAL, IDENTIFICACION_UNICA_TECNICO_SUPERVISOR, FECHA_HORA_FIN, EQUIPO_MEDICION, UBICACION, ID_METODO_MEDICION)
VALUES
(1,2,'2025-02-08 09:00:00',5,7,'2025-02-08 11:00:00','Estación Leica TS09','Zona 1, Barrio Centro',1),
(6,4,'2025-02-15 08:30:00',5,7,'2025-02-15 10:00:00','GPS Garmin GEO','Zona 7, Lote 12',2);

INSERT INTO LICENCIA_OBRAS (ID_TRAMITE_CIUDADANO, IDENTIFICACION_UNICA_TITULAR, ID_PREDIO_CATASTRAL, ID_TIPO_LICENCIA) VALUES
(1,4,'13-01-001-0003-0001',2);


--SERVICIOS, FACTURACIÓN Y PAGOS


INSERT INTO SERVICIO_MUNICIPAL
(id_tramite_ciudadano, nombre_servicio, costo, id_tipo_cobro, fecha_inicio, codigo_catastral, id_estado_servicio)
VALUES
(3,'Agua potable domiciliar',85.00,1,'2025-02-10','13-01-001-0001-0002',3),
(5,'Agua potable domiciliar',85.00,1,'2025-01-29','13-01-001-0002-0001',1),
(2,'Tren de aseo',45.00,1,'2025-02-22','13-01-001-0001-0001',1);

INSERT INTO FACTURA (fecha_emision, id_ciudadano, monto, mora, id_estado_factura) VALUES
('2025-02-01',2,130.00,0.00,1),
('2025-02-01',3,85.00,0.00,2),
('2025-02-01',1,45.00,0.00,1),
('2025-01-01',11,500.00,0.00,3);

INSERT INTO DETALLE_FACTURA (id_factura, Descripcion, valor, cantidad) VALUES
(1,'Servicio agua potable febrero',85.00,1),
(1,'Tren de aseo febrero',45.00,1),
(2,'Servicio agua potable febrero',85.00,1),
(3,'Tren de aseo febrero',45.00,1),
(4,'Multa de tránsito',500.00,1);

INSERT INTO CONVENIO_PAGO (id_metodo_pago, representante_convenio, monto_acordado, fecha_convenio, cuotas) VALUES
(4,11,500.00,'2025-02-12',5);

INSERT INTO FACTURA_CONVENIO (id_factura, id_convenio_pago) VALUES
(4,1);

INSERT INTO PAGO (fecha_pago, monto_pago, id_factura, id_metodo_pago) VALUES
('2025-02-03',130.00,1,1),
('2025-02-05',85.00,2,3),
('2025-02-18',45.00,3,2),
('2025-02-20',100.00,4,4);

-- MULTAS Y APELACIONES

INSERT INTO MULTA (id_tipo_multa, monto, fecha, ubicacion) VALUES
(1,500.00,'2025-01-05','Calzada Kaibil Balam, Huehuetenango'),
(2,1200.00,'2025-01-18','Río Seleguá, margen norte'),
(3,2200.00,'2025-02-02','Zona 7, Lote 12');

INSERT INTO MULTA_TRANSITO
(Id_multa, Numero_placa, tipo_vehiculo, Marca, Color, id_unico_ciudadano_infractor, id_tipo_licencia, hora_infraccion, codigo_agente)
VALUES
(1,'P123ABC','Sedán','Toyota','Gris',11,2,'08:45:00','AGT-045');

INSERT INTO ARTICULO_INFRINGIDO_MULTA (id_multa, articulo, descripcion, base_legal) VALUES
(1,'Art. 182','Conducir a velocidad mayor a la permitida','Reglamento de Tránsito'),
(2,'Art. 55','Vertido no autorizado en área protegida','Reglamento Ambiental Municipal'),
(3,'Art. 14','Construcción sin licencia vigente','Reglamento de Construcción Municipal');

INSERT INTO MULTA_CIUDADANO (id_multa, id_ciudadano) VALUES
(1,11),
(2,8);

INSERT INTO MULTA_EMPRESA (id_multa, id_empresa) VALUES
(2,2);

INSERT INTO MULTA_PREDIO (id_multa, codigo_catastral) VALUES
(3,'13-01-001-0003-0001');

INSERT INTO APELACION_MULTA (id_multa, fecha_apelacion, argumento_ciudadano, estado_tramite) VALUES
(1,'2025-01-10','Solicito revisión por señalización deficiente en el tramo.',1);

INSERT INTO RESOLUCION_APELACION
(id_apelacion, fecha_resolucion, veredicto, monto_total, descuento_aplicado, id_factura)
VALUES
(1,'2025-01-20','Procede descuento parcial por atenuantes',500.00,100.00,4);

--QUEJAS, SOLICITUDES, ENCUESTAS


INSERT INTO QUEJA (queja, id_unico_ciudadano, estado_queja, id_tramite_ciudadano) VALUES
('Demora en inspección de trámite de licencia.',6,1,4),
('Cobro duplicado en recibo de servicio municipal.',2,2,3);

INSERT INTO SOLICITUD (id_tramite_ciudadano, descripcion_solicitud, id_unico_ciudadano_solicitud, prioridad) VALUES
(3,'Solicito instalación de medidor nuevo en vivienda.',2,'ALTA'),
(5,'Solicitud de revisión por baja presión en red de agua.',3,'MEDIA'),
(2,'Actualización de datos del titular en sistema catastral.',1,'BAJA');

INSERT INTO ENCUESTA_SATISFACCION (id_unico_ciudadano, id_tramite_ciudadano, fecha_realizacion, calificacion) VALUES
(1,2,'2025-02-22',5),
(2,3,'2025-02-21',3),
(3,5,'2025-02-01',4),
(4,1,'2025-02-02',4);

INSERT INTO OBSERVACION_ENCUESTA (id_encuesta, observacion) VALUES
(1,'Atención rápida y amable.'),
(2,'El proceso fue claro, pero tardó más de lo esperado.'),
(3,'Buen servicio general.'),
(4,'Se cumplieron los tiempos prometidos.');


--PROVEEDORES, COMPRAS E INVENTARIO


INSERT INTO PROVEEDOR (nombre, nit, direccion, telefono, correo) VALUES
('Suministros Municipales del Norte','7788990-1','Zona 5, Huehuetenango','50241110001','ventas@sumnorte.gt'),
('Papelería y Equipos La Oficina','8899001-2','Zona 1, Huehuetenango','50241110002','contacto@laoficina.gt'),
('Tecnología Cívica S.A.','9900112-3','Zona 10, Guatemala','50241110003','licitaciones@tecnocivica.gt');

INSERT INTO ORDEN_COMPRA (fecha, id_proveedor, total, estado) VALUES
('2025-01-25',1,3500.00,'RECIBIDA'),
('2025-02-05',2,1250.00,'PENDIENTE'),
('2025-02-12',3,9800.00,'RECIBIDA');

INSERT INTO DETALLE_COMPRA (id_orden, descripcion, cantidad, precio_unitario, subtotal) VALUES
(1,'Tubería PVC para mantenimiento de red',50,40.00,2000.00),
(1,'Válvula de paso 3/4"',30,50.00,1500.00),
(2,'Resmas de papel carta',25,20.00,500.00),
(2,'Tóner impresora láser',5,150.00,750.00),
(3,'Computadoras de escritorio',4,2200.00,8800.00),
(3,'UPS 1200VA',2,500.00,1000.00);

INSERT INTO INVENTARIO (nombre_producto, descripcion, stock_actual, stock_minimo, costo_unitario) VALUES
('Tubería PVC 1/2"','Uso en mantenimiento de red de agua',120,30,40.00),
('Válvula de paso 3/4"','Accesorio para red hidráulica',60,20,50.00),
('Resma papel carta','Papelería oficinas municipales',200,80,20.00),
('Tóner láser negro','Consumible de impresión',25,10,150.00),
('Computadora escritorio','Equipo para atención al ciudadano',12,4,2200.00),
('UPS 1200VA','Respaldo eléctrico',10,3,500.00);

INSERT INTO MOVIMIENTO_INVENTARIO (id_producto, tipo_movimiento, cantidad, fecha) VALUES
(1,'ENTRADA',50,'2025-01-25'),
(1,'SALIDA',20,'2025-02-08'),
(2,'ENTRADA',30,'2025-01-25'),
(3,'ENTRADA',25,'2025-02-05'),
(4,'ENTRADA',5,'2025-02-05'),
(5,'ENTRADA',4,'2025-02-12'),
(6,'ENTRADA',2,'2025-02-12'),
(3,'SALIDA',10,'2025-02-18');

INSERT INTO ACTIVO_MUNICIPAL (nombre_activo, descripcion, fecha_adquisicion, valor, estado) VALUES
('Camioneta de supervisión','Vehículo para inspecciones de campo','2023-04-10',185000.00,'ACTIVO'),
('Servidor municipal','Servidor para sistema de gestión','2024-09-01',65000.00,'ACTIVO'),
('Retroexcavadora','Equipo para obras públicas','2018-06-15',420000.00,'EN MANTENIMIENTO');
