PRAGMA foreign_keys = ON;


CREATE TABLE FINCA_MATRIZ (
    ID_FINCA INTEGER PRIMARY KEY AUTOINCREMENT,
    FINCA TEXT NOT NULL,
    FOLIO TEXT NOT NULL,
    LIBRO TEXT NOT NULL
);

CREATE TABLE TIPO_PREDIO (
    ID_TIPO_PREDIO INTEGER PRIMARY KEY AUTOINCREMENT,
    TIPO TEXT CHECK(TIPO IN ('Rural','Urbana'))
);

CREATE TABLE METODO_MEDICION_CASTRAL (
    ID_METODO INTEGER PRIMARY KEY AUTOINCREMENT,
    METODO TEXT CHECK(METODO IN ('Estación total','GPS','Ortofoto'))
);

CREATE TABLE CLASE_PREDIO (
    ID_CLASE_PREDIO INTEGER PRIMARY KEY AUTOINCREMENT,
    CLASE TEXT CHECK(CLASE IN ('PRIVADO','COMUNAL','MUNICIPAL','ESTATAL'))
);

CREATE TABLE DOCUMENTO_AMPARO_TITULARIDAD_CATASTRAL (
    ID_DOCUMENTO INTEGER PRIMARY KEY AUTOINCREMENT,
    EMISOR TEXT,
    TIPO_DOCUMENTO TEXT CHECK(TIPO_DOCUMENTO IN ('No tiene','Escritura pública inscrita','Escritura pública no inscrita','Documento privado','Certificación del Registro general de la propiedad','Acta Municipal','Resolución Judicial inscrita','Resolución Judicial no inscrita','Acuerdo Gubernativo','Otro'))
);

CREATE TABLE CAUSA_TITULARIDAD (
    ID_CAUSA INTEGER PRIMARY KEY AUTOINCREMENT,
    CAUSA TEXT CHECK(CAUSA IN ('compraventa','herencia','adjudicación','donación','permuta','titulación','supletoria','otro'))
);

CREATE TABLE USO_SUELO_PREDIO (
    ID_USO INTEGER PRIMARY KEY AUTOINCREMENT,
    USO_SUELO TEXT CHECK(USO_SUELO IN ('Vivienda','Recreación','Industrial','Área protegida','Agrícola','Pecuario','Forestal','Área de reserva','Agropecuario','Agro-forestal','Otro'))
);

CREATE TABLE ESTADO_AVALUO (
    ID_ESTADO INTEGER PRIMARY KEY AUTOINCREMENT,
    ESTADO TEXT CHECK(ESTADO IN ('ACTIVO','HISTÓRICO'))
);

CREATE TABLE TIPO_LICENCIA (
    id_tipo INTEGER PRIMARY KEY AUTOINCREMENT,
    genero TEXT,
    descripcion_ocupacion_area TEXT,
    unidad_medida TEXT,
    costo_por_obra_m2 REAL,
    costo_licencia_m2_iva REAL,
    fecha_fin TEXT,
    numero_de_supervisiones INTEGER,
    fecha_inicio TEXT
);

CREATE TABLE TRAMITE (
    Id_tramite INTEGER PRIMARY KEY AUTOINCREMENT,
    Nombre_tramite TEXT,
    Descripcion TEXT,
    Tiempo_atencion_promedio TEXT
);

CREATE TABLE REQUISITO (
    id_requisito INTEGER PRIMARY KEY AUTOINCREMENT,
    Nombre_requisito TEXT,
    Descripcion TEXT
);

CREATE TABLE ESTADO_TRAMITE (
    id_estado INTEGER PRIMARY KEY AUTOINCREMENT,
    Nombre_estado TEXT CHECK(Nombre_estado IN ('EN PROCESO','APROBADO','RECHAZADO')),
    Descripcion TEXT
);

CREATE TABLE TIPO_COBRO_SERVICIO (
    id_tipo_cobro INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo_cobro TEXT CHECK(tipo_cobro IN ('fijo','por consumo')),
    descripcion TEXT
);

CREATE TABLE ESTADO_SERVICIO (
    id_estado INTEGER PRIMARY KEY AUTOINCREMENT,
    estado TEXT CHECK(estado IN ('ACTIVO','INACTIVO','EN INSTALACIÓN')),
    descripcion TEXT
);

CREATE TABLE ESTADO_FACTURA (
    id_estado_factura INTEGER PRIMARY KEY AUTOINCREMENT,
    estado TEXT CHECK(estado IN ('PENDIENTE','PAGADA','MOROSA')),
    descripcion TEXT
);

CREATE TABLE METODO_PAGO (
    id_metodo_pago INTEGER PRIMARY KEY AUTOINCREMENT,
    metodo_pago TEXT,
    descripcion TEXT
);

CREATE TABLE TIPO_MULTA (
    Id_tipo_multa INTEGER PRIMARY KEY AUTOINCREMENT,
    categoria TEXT,
    descripcion TEXT,
    monto_base REAL
);

CREATE TABLE TIPO_LICENCIA_CONDUCIR (
    id_tipo_licencia INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo_licencia TEXT,
    descripcion TEXT
);


CREATE TABLE CIUDADANO (
    Identificacion_ciudadano INTEGER PRIMARY KEY AUTOINCREMENT,
    NUMERO_DOCUMENTO_identificacion TEXT NOT NULL UNIQUE,
    TIPO_DOCUMENTO_identificacion TEXT NOT NULL,
    NOMBRE TEXT NOT NULL,
    APELLIDOS TEXT NOT NULL,
    FECHA_NACIMIENTO TEXT,
    DIRECCION TEXT,
    NIT TEXT,
    TELEFONO TEXT,
    SEXO TEXT,
    NACIONALIDAD TEXT,
    PROFESION_OFICIO TEXT,
    ESTADO_CIVIL TEXT,
    CORREO TEXT,
    Identificacion_ciudadano_conyuge INTEGER,
    FOREIGN KEY (Identificacion_ciudadano_conyuge) REFERENCES CIUDADANO(Identificacion_ciudadano)
);

CREATE TABLE EMPRESA (
    ID_EMPRESA INTEGER PRIMARY KEY AUTOINCREMENT,
    NOMBRE TEXT NOT NULL,
    DIRECCION TEXT,
    Identificacion_ciudadano INTEGER,
    FOREIGN KEY (Identificacion_ciudadano) REFERENCES CIUDADANO(Identificacion_ciudadano)
);


CREATE TABLE TRAMITE_REQUISITO (
    id_tramite_requisito INTEGER PRIMARY KEY AUTOINCREMENT,
    Id_tramite INTEGER,
    id_requisito INTEGER,
    FOREIGN KEY (Id_tramite) REFERENCES TRAMITE(Id_tramite),
    FOREIGN KEY (id_requisito) REFERENCES REQUISITO(id_requisito)
);

CREATE TABLE TRAMITE_CIUDADANO (
    Id_tramite_ciudadano INTEGER PRIMARY KEY AUTOINCREMENT,
    Id_tramite INTEGER,
    Id_ciudadano INTEGER,
    Fecha_inicio TEXT,
    Fecha_fin TEXT,
    Id_estado INTEGER,
    FOREIGN KEY (Id_tramite) REFERENCES TRAMITE(Id_tramite),
    FOREIGN KEY (Id_ciudadano) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (Id_estado) REFERENCES ESTADO_TRAMITE(id_estado)
);

CREATE TABLE DOCUMENTO_TRAMITE_CIUDADANO (
    id_doc_tramite_ciudadano INTEGER PRIMARY KEY AUTOINCREMENT,
    id_tramite_ciudadano INTEGER,
    Tipo_documento TEXT,
    Documento BLOB,
    FOREIGN KEY (id_tramite_ciudadano) REFERENCES TRAMITE_CIUDADANO(Id_tramite_ciudadano)
);

CREATE TABLE REQUISITO_TRAMITE_CIUDADANO (
    Id_requisito_tramite_ciudadano INTEGER PRIMARY KEY AUTOINCREMENT,
    Id_requisito_tramite INTEGER,
    id_tramite_ciudadano INTEGER,
    FOREIGN KEY (Id_requisito_tramite) REFERENCES TRAMITE_REQUISITO(id_tramite_requisito),
    FOREIGN KEY (id_tramite_ciudadano) REFERENCES TRAMITE_CIUDADANO(Id_tramite_ciudadano)
);


CREATE TABLE PREDIO_CATASTRAL (
    CODIGO_CATASTRAL TEXT PRIMARY KEY,
    DEPARTAMENTO TEXT,
    MUNICIPIO TEXT,
    UBICACION TEXT,
    AREA_PREDIO REAL,
    FECHA_ADQUISICION_PREDIO TEXT,
    RELACION_TITULAR_INFORMANTE TEXT,
    ID_TIPO_PREDIO INTEGER,
    ID_CLASE_PREDIO INTEGER,
    ID_FINCA_MATRIZ INTEGER,
    ID_DOCUMENTO_AMPARO_TITULARIDAD_CATASTRAL INTEGER,
    ID_CAUSA_TITULARIDAD INTEGER,
    ID_USO INTEGER,
    Identificacion_ciudadano_titular INTEGER,
    Identificacion_ciudadano_titular_anterior INTEGER,
    Identificacion_ciudadano_titular_informante INTEGER,
    FOREIGN KEY (ID_TIPO_PREDIO) REFERENCES TIPO_PREDIO(ID_TIPO_PREDIO),
    FOREIGN KEY (ID_CLASE_PREDIO) REFERENCES CLASE_PREDIO(ID_CLASE_PREDIO),
    FOREIGN KEY (ID_FINCA_MATRIZ) REFERENCES FINCA_MATRIZ(ID_FINCA),
    FOREIGN KEY (ID_DOCUMENTO_AMPARO_TITULARIDAD_CATASTRAL) REFERENCES DOCUMENTO_AMPARO_TITULARIDAD_CATASTRAL(ID_DOCUMENTO),
    FOREIGN KEY (ID_CAUSA_TITULARIDAD) REFERENCES CAUSA_TITULARIDAD(ID_CAUSA),
    FOREIGN KEY (ID_USO) REFERENCES USO_SUELO_PREDIO(ID_USO),
    FOREIGN KEY (Identificacion_ciudadano_titular) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (Identificacion_ciudadano_titular_anterior) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (Identificacion_ciudadano_titular_informante) REFERENCES CIUDADANO(Identificacion_ciudadano)
);

CREATE TABLE CITA_INVESTIGACION_CATASTRAL (
    ID_CITA INTEGER PRIMARY KEY AUTOINCREMENT,
    IDENTIFICACION_UNICA_TITULAR INTEGER,
    id_tramite_ciudadano INTEGER,
    FECHA_HORA_INICIO TEXT,
    IDENTIFICACION_UNICA_TECNICO_CASTRAL INTEGER,
    IDENTIFICACION_UNICA_TECNICO_SUPERVISOR INTEGER,
    FECHA_HORA_FIN TEXT,
    EQUIPO_MEDICION TEXT,
    UBICACION TEXT,
    ID_METODO_MEDICION INTEGER,
    FOREIGN KEY (IDENTIFICACION_UNICA_TITULAR) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (IDENTIFICACION_UNICA_TECNICO_CASTRAL) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (IDENTIFICACION_UNICA_TECNICO_SUPERVISOR) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (ID_METODO_MEDICION) REFERENCES METODO_MEDICION_CASTRAL(ID_METODO),
    FOREIGN KEY (id_tramite_ciudadano) REFERENCES TRAMITE_CIUDADANO(Id_tramite_ciudadano)
);

CREATE TABLE OBSERVACION_CATASTRAL (
    ID_OBSERVACION INTEGER PRIMARY KEY AUTOINCREMENT,
    OBSERVACION TEXT,
    ID_PREDIO_CATASTRAL TEXT,
    FOREIGN KEY (ID_PREDIO_CATASTRAL) REFERENCES PREDIO_CATASTRAL(CODIGO_CATASTRAL)
);

CREATE TABLE DESACUERDO_PERIMETRAL (
    ID_DESACUERDO INTEGER PRIMARY KEY AUTOINCREMENT,
    TIPO_DESACUERDO TEXT CHECK(TIPO_DESACUERDO IN ('LINDEROS','MOJONES','ESQUINEROS')),
    ID_PREDIO_CATASTRAL TEXT,
    FOREIGN KEY (ID_PREDIO_CATASTRAL) REFERENCES PREDIO_CATASTRAL(CODIGO_CATASTRAL)
);

CREATE TABLE COLINDANCIA_PREDIO (
    ID_COLINDANCIA INTEGER PRIMARY KEY AUTOINCREMENT,
    DETALLE TEXT,
    ID_PREDIO_CATASTRAL TEXT NOT NULL,
    ID_PREDIO_CATASTRAL_COLINDANTE TEXT,
    FOREIGN KEY (ID_PREDIO_CATASTRAL) REFERENCES PREDIO_CATASTRAL(CODIGO_CATASTRAL),
    FOREIGN KEY (ID_PREDIO_CATASTRAL_COLINDANTE) REFERENCES PREDIO_CATASTRAL(CODIGO_CATASTRAL)
);

CREATE TABLE SERVIDUMBRE_PREDIO (
    ID_SERVIDUMBRE INTEGER PRIMARY KEY AUTOINCREMENT,
    ANCHO_SERVIDUMBRE REAL,
    LARGO_SERVIDUMBRE REAL,
    TIPO_SERVIDUMBRE TEXT CHECK(TIPO_SERVIDUMBRE IN ('acueducto','desagüe','Energía eléctrica','paso','Telefónica','saca de agua','Otro')),
    ID_PREDIO_CATASTRAL TEXT,
    FOREIGN KEY (ID_PREDIO_CATASTRAL) REFERENCES PREDIO_CATASTRAL(CODIGO_CATASTRAL)
);

CREATE TABLE AVALUO (
    ID_AVALUO INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_PREDIO_CATASTRAL TEXT,
    FECHA_AVALUO TEXT,
    IDENTIFICACION_UNICA_EVALUADOR INTEGER,
    AREA_AVALUO REAL,
    ID_ESTADO INTEGER,
    VALOR_PREDIO REAL,
    VALOR_CONSTRUCCION REAL,
    VALOR_TOTAL REAL,
    FOREIGN KEY (ID_PREDIO_CATASTRAL) REFERENCES PREDIO_CATASTRAL(CODIGO_CATASTRAL),
    FOREIGN KEY (IDENTIFICACION_UNICA_EVALUADOR) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO_AVALUO(ID_ESTADO)
);


CREATE TABLE LICENCIA_OBRAS (
    ID_LICENCIA INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_TRAMITE_CIUDADANO INTEGER,
    IDENTIFICACION_UNICA_TITULAR INTEGER,
    ID_PREDIO_CATASTRAL TEXT,
    ID_TIPO_LICENCIA INTEGER,
    FOREIGN KEY (ID_TRAMITE_CIUDADANO) REFERENCES TRAMITE_CIUDADANO(Id_tramite_ciudadano),
    FOREIGN KEY (IDENTIFICACION_UNICA_TITULAR) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (ID_PREDIO_CATASTRAL) REFERENCES PREDIO_CATASTRAL(CODIGO_CATASTRAL),
    FOREIGN KEY (ID_TIPO_LICENCIA) REFERENCES TIPO_LICENCIA(id_tipo)
);

CREATE TABLE SERVICIO_MUNICIPAL (
    id_servicio INTEGER PRIMARY KEY AUTOINCREMENT,
    id_tramite_ciudadano INTEGER,
    nombre_servicio TEXT,
    costo REAL,
    id_tipo_cobro INTEGER,
    fecha_inicio TEXT,
    codigo_catastral TEXT,
    id_estado_servicio INTEGER,
    FOREIGN KEY (id_tramite_ciudadano) REFERENCES TRAMITE_CIUDADANO(Id_tramite_ciudadano),
    FOREIGN KEY (id_tipo_cobro) REFERENCES TIPO_COBRO_SERVICIO(id_tipo_cobro),
    FOREIGN KEY (codigo_catastral) REFERENCES PREDIO_CATASTRAL(CODIGO_CATASTRAL),
    FOREIGN KEY (id_estado_servicio) REFERENCES ESTADO_SERVICIO(id_estado)
);


CREATE TABLE FACTURA (
    id_factura INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha_emision TEXT,
    id_ciudadano INTEGER,
    monto REAL,
    mora REAL,
    id_estado_factura INTEGER,
    FOREIGN KEY (id_ciudadano) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (id_estado_factura) REFERENCES ESTADO_FACTURA(id_estado_factura)
);

CREATE TABLE DETALLE_FACTURA (
    id_detalle_factura INTEGER PRIMARY KEY AUTOINCREMENT,
    id_factura INTEGER,
    Descripcion TEXT,
    valor REAL,
    cantidad INTEGER,
    FOREIGN KEY (id_factura) REFERENCES FACTURA(id_factura)
);

CREATE TABLE CONVENIO_PAGO (
    id_convenio_pago INTEGER PRIMARY KEY AUTOINCREMENT,
    id_metodo_pago INTEGER,
    representante_convenio INTEGER,
    monto_acordado REAL,
    FOREIGN KEY (id_metodo_pago) REFERENCES METODO_PAGO(id_metodo_pago),
    FOREIGN KEY (representante_convenio) REFERENCES CIUDADANO(Identificacion_ciudadano)
);

ALTER TABLE CONVENIO_PAGO
ADD COLUMN fecha_convenio TEXT;
ALTER TABLE CONVENIO_PAGO
ADD COLUMN cuotas INTEGER;


CREATE TABLE FACTURA_CONVENIO (
    id_factura_convenio INTEGER PRIMARY KEY AUTOINCREMENT,
    id_factura INTEGER,
    id_convenio_pago INTEGER,
    FOREIGN KEY (id_factura) REFERENCES FACTURA(id_factura),
    FOREIGN KEY (id_convenio_pago) REFERENCES CONVENIO_PAGO(id_convenio_pago)
);

CREATE TABLE PAGO (
    id_pago INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha_pago TEXT,
    monto_pago REAL,
    id_factura INTEGER,
    id_metodo_pago INTEGER,
    FOREIGN KEY (id_factura) REFERENCES FACTURA(id_factura),
    FOREIGN KEY (id_metodo_pago) REFERENCES METODO_PAGO(id_metodo_pago)
);

CREATE TABLE MULTA (
    Id_multa INTEGER PRIMARY KEY AUTOINCREMENT,
    id_tipo_multa INTEGER,
    monto REAL,
    fecha TEXT,
    ubicacion TEXT,
    FOREIGN KEY (id_tipo_multa) REFERENCES TIPO_MULTA(Id_tipo_multa)
);

CREATE TABLE MULTA_TRANSITO (
    Id_multa INTEGER PRIMARY KEY,
    Numero_placa TEXT,
    tipo_vehiculo TEXT,
    Marca TEXT,
    Color TEXT,
    id_unico_ciudadano_infractor INTEGER,
    id_tipo_licencia INTEGER,
    hora_infraccion TEXT,
    codigo_agente TEXT,
    FOREIGN KEY (Id_multa) REFERENCES MULTA(Id_multa),
    FOREIGN KEY (id_unico_ciudadano_infractor) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (id_tipo_licencia) REFERENCES TIPO_LICENCIA_CONDUCIR(id_tipo_licencia)
);

CREATE TABLE ARTICULO_INFRINGIDO_MULTA (
    id_articulo_infringido_multa INTEGER PRIMARY KEY AUTOINCREMENT,
    id_multa INTEGER,
    articulo TEXT,
    descripcion TEXT,
    base_legal TEXT,
    FOREIGN KEY (id_multa) REFERENCES MULTA(Id_multa)
);

CREATE TABLE MULTA_CIUDADANO (
    id_multa INTEGER,
    id_ciudadano INTEGER,
    PRIMARY KEY (id_multa, id_ciudadano),
    FOREIGN KEY (id_multa) REFERENCES MULTA(Id_multa),
    FOREIGN KEY (id_ciudadano) REFERENCES CIUDADANO(Identificacion_ciudadano)
);

CREATE TABLE MULTA_EMPRESA (
    id_multa INTEGER,
    id_empresa INTEGER,
    PRIMARY KEY (id_multa, id_empresa),
    FOREIGN KEY (id_multa) REFERENCES MULTA(Id_multa),
    FOREIGN KEY (id_empresa) REFERENCES EMPRESA(ID_EMPRESA)
);

CREATE TABLE MULTA_PREDIO (
    id_multa INTEGER,
    codigo_catastral TEXT,
    PRIMARY KEY (id_multa, codigo_catastral),
    FOREIGN KEY (id_multa) REFERENCES MULTA(Id_multa),
    FOREIGN KEY (codigo_catastral) REFERENCES PREDIO_CATASTRAL(CODIGO_CATASTRAL)
);


CREATE TABLE APELACION_MULTA (
    id_apelacion INTEGER PRIMARY KEY AUTOINCREMENT,
    id_multa INTEGER,
    fecha_apelacion TEXT,
    argumento_ciudadano TEXT,
    estado_tramite INTEGER,
    FOREIGN KEY (id_multa) REFERENCES MULTA(Id_multa),
    FOREIGN KEY (estado_tramite) REFERENCES ESTADO_TRAMITE(id_estado)
);

CREATE TABLE RESOLUCION_APELACION (
    id_resolucion INTEGER PRIMARY KEY AUTOINCREMENT,
    id_apelacion INTEGER,
    fecha_resolucion TEXT,
    veredicto TEXT,
    monto_total REAL,
    descuento_aplicado REAL,
    id_factura INTEGER,
    FOREIGN KEY (id_apelacion) REFERENCES APELACION_MULTA(id_apelacion),
    FOREIGN KEY (id_factura) REFERENCES FACTURA(id_factura)
);

CREATE TABLE QUEJA (
    id_queja INTEGER PRIMARY KEY AUTOINCREMENT,
    queja TEXT,
    id_unico_ciudadano INTEGER,
    estado_queja INTEGER,
    id_tramite_ciudadano INTEGER,
    FOREIGN KEY (id_unico_ciudadano) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (estado_queja) REFERENCES ESTADO_TRAMITE(id_estado),
    FOREIGN KEY (id_tramite_ciudadano) REFERENCES TRAMITE_CIUDADANO(Id_tramite_ciudadano)
);

CREATE TABLE SOLICITUD (
    id_solicitud INTEGER PRIMARY KEY AUTOINCREMENT,
    id_tramite_ciudadano INTEGER,
    descripcion_solicitud TEXT,
    id_unico_ciudadano_solicitud INTEGER,
    prioridad TEXT CHECK(prioridad IN ('BAJA','MEDIA','ALTA','URGENTE')),
    FOREIGN KEY (id_tramite_ciudadano) REFERENCES TRAMITE_CIUDADANO(Id_tramite_ciudadano),
    FOREIGN KEY (id_unico_ciudadano_solicitud) REFERENCES CIUDADANO(Identificacion_ciudadano)
);

CREATE TABLE ENCUESTA_SATISFACCION (
    id_encuesta INTEGER PRIMARY KEY AUTOINCREMENT,
    id_unico_ciudadano INTEGER,
    id_tramite_ciudadano INTEGER,
    fecha_realizacion TEXT,
    calificacion INTEGER,
    FOREIGN KEY (id_unico_ciudadano) REFERENCES CIUDADANO(Identificacion_ciudadano),
    FOREIGN KEY (id_tramite_ciudadano) REFERENCES TRAMITE_CIUDADANO(Id_tramite_ciudadano)
);

CREATE TABLE OBSERVACION_ENCUESTA (
    id_observacion_encuesta INTEGER PRIMARY KEY AUTOINCREMENT,
    id_encuesta INTEGER,
    observacion TEXT,
    FOREIGN KEY (id_encuesta) REFERENCES ENCUESTA_SATISFACCION(id_encuesta)
);



CREATE TABLE PROVEEDOR (
    id_proveedor INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    nit TEXT UNIQUE,
    direccion TEXT,
    telefono TEXT,
    correo TEXT
);


CREATE TABLE ORDEN_COMPRA (
    id_orden INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha TEXT,
    id_proveedor INTEGER,
    total REAL,
    estado TEXT CHECK(estado IN ('PENDIENTE','RECIBIDA','CANCELADA')),
    FOREIGN KEY (id_proveedor) REFERENCES PROVEEDOR(id_proveedor)
);

CREATE TABLE DETALLE_COMPRA (
    id_detalle INTEGER PRIMARY KEY AUTOINCREMENT,
    id_orden INTEGER,
    descripcion TEXT,
    cantidad INTEGER,
    precio_unitario REAL,
    subtotal REAL,
    FOREIGN KEY (id_orden) REFERENCES ORDEN_COMPRA(id_orden)
);

CREATE TABLE INVENTARIO (
    id_producto INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre_producto TEXT,
    descripcion TEXT,
    stock_actual INTEGER,
    stock_minimo INTEGER,
    costo_unitario REAL
);
CREATE TABLE ACTIVO_MUNICIPAL (
    id_activo INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre_activo TEXT,
    descripcion TEXT,
    fecha_adquisicion TEXT,
    valor REAL,
    estado TEXT CHECK(estado IN ('ACTIVO','DE BAJA','EN MANTENIMIENTO'))
);
CREATE TABLE MOVIMIENTO_INVENTARIO (
    id_movimiento INTEGER PRIMARY KEY AUTOINCREMENT,
    id_producto INTEGER,
    tipo_movimiento TEXT CHECK(tipo_movimiento IN ('ENTRADA','SALIDA')),
    cantidad INTEGER,
    fecha TEXT,
    FOREIGN KEY (id_producto) REFERENCES INVENTARIO(id_producto)
);

CREATE TABLE BITACORA (
    id_bitacora INTEGER PRIMARY KEY AUTOINCREMENT,
    tabla_afectada TEXT,
    id_registro INTEGER,
    accion TEXT,
    usuario TEXT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE current_user (username TEXT);
INSERT INTO current_user (username) VALUES ('secre 1');



------------------------------------------------------------------------------------------- --Llenado de catalogos---------------------------------------------------------------------------------------------

INSERT INTO TIPO_PREDIO (TIPO) VALUES
('Rural'),
('Urbana');


INSERT INTO METODO_MEDICION_CASTRAL (METODO) VALUES
('Estación total'),
('GPS'),
('Ortofoto');


INSERT INTO CLASE_PREDIO (CLASE) VALUES
('PRIVADO'),
('COMUNAL'),
('MUNICIPAL'),
('ESTATAL');


INSERT INTO CAUSA_TITULARIDAD (CAUSA) VALUES
('compraventa'),
('herencia'),
('adjudicación'),
('donación'),
('permuta'),
('titulación'),
('supletoria'),
('otro');


INSERT INTO USO_SUELO_PREDIO (USO_SUELO) VALUES
('Vivienda'),
('Recreación'),
('Industrial'),
('Área protegida'),
('Agrícola'),
('Pecuario'),
('Forestal'),
('Área de reserva'),
('Agropecuario'),
('Agro-forestal'),
('Otro');



INSERT INTO ESTADO_AVALUO (ESTADO) VALUES
('ACTIVO'),
('HISTÓRICO');



INSERT INTO ESTADO_TRAMITE (Nombre_estado, Descripcion) VALUES
('EN PROCESO','Trámite en revisión'),
('APROBADO','Trámite aprobado'),
('RECHAZADO','Trámite rechazado');


INSERT INTO TIPO_COBRO_SERVICIO (tipo_cobro, descripcion) VALUES
('fijo','Cobro mensual fijo'),
('por consumo','Cobro según consumo medido');


INSERT INTO ESTADO_SERVICIO (estado, descripcion) VALUES
('ACTIVO','Servicio funcionando'),
('INACTIVO','Servicio suspendido'),
('EN INSTALACIÓN','En proceso de instalación');


INSERT INTO ESTADO_FACTURA (estado, descripcion) VALUES
('PENDIENTE','Factura pendiente de pago'),
('PAGADA','Factura pagada completamente'),
('MOROSA','Factura vencida con mora');


INSERT INTO TIPO_MULTA (categoria, descripcion, monto_base) VALUES
('Transito','Infracciones de tránsito',500),
('Ambiental','Faltas ambientales',1000),
('Construcción','Construcción sin licencia',2000);


INSERT INTO TIPO_LICENCIA_CONDUCIR (tipo_licencia, descripcion) VALUES
('A','Transporte pesado'),
('B','Vehículos particulares'),
('C','Motocicletas'),
('M','Motocicletas menores');


INSERT INTO METODO_PAGO (metodo_pago, descripcion) VALUES
('Efectivo','Pago en ventanilla'),
('Tarjeta','Pago con tarjeta de débito o crédito'),
('Transferencia','Transferencia bancaria'),
('Convenio','Pago por convenio autorizado');


INSERT INTO DOCUMENTO_AMPARO_TITULARIDAD_CATASTRAL (EMISOR, TIPO_DOCUMENTO) VALUES
('Registro General de la Propiedad','Escritura pública inscrita'),
('Municipalidad','Acta Municipal'),
('Juzgado Civil','Resolución Judicial inscrita'),
('N/A','No tiene');


INSERT INTO FINCA_MATRIZ (FINCA, FOLIO, LIBRO) VALUES
('123','45','67'),
('456','78','90'),
('789','12','34');



INSERT INTO TRAMITE (Nombre_tramite, Descripcion, Tiempo_atencion_promedio) VALUES
('Licencia de construcción','Permiso para construir o remodelar','15 días'),
('Cambio de propietario','Actualización de titular del predio','10 días'),
('Solicitud de servicio de agua','Instalación de agua potable','7 días');



INSERT INTO REQUISITO (Nombre_requisito, Descripcion) VALUES
('DPI','Documento personal de identificación'),
('Escritura','Escritura del inmueble'),
('Plano catastral','Plano autorizado'),
('Recibo de pago','Comprobante de pago municipal');


INSERT INTO TRAMITE_REQUISITO (id_tramite, id_requisito) VALUES (1, 1);
INSERT INTO TRAMITE_REQUISITO (id_tramite, id_requisito) VALUES (1, 2);
INSERT INTO TRAMITE_REQUISITO (id_tramite, id_requisito) VALUES (1, 3);


INSERT INTO TRAMITE_REQUISITO (id_tramite, id_requisito) VALUES (2, 1);
INSERT INTO TRAMITE_REQUISITO (id_tramite, id_requisito) VALUES (2, 2);


INSERT INTO TRAMITE_REQUISITO (id_tramite, id_requisito) VALUES (3, 1);
INSERT INTO TRAMITE_REQUISITO (id_tramite, id_requisito) VALUES (3, 4);



-------------------------------------------------------------------------------------------------Triggers-------------------------------------------------------------------------------------------------------
--Trigger para bitacora de proveedor 
CREATE TRIGGER trg_proveedor_insert
AFTER INSERT ON PROVEEDOR
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('PROVEEDOR', NEW.id_proveedor, 'INSERT','sistema');
END;


--TRIGGER Para no permitir stock negativo
CREATE TRIGGER trg_validar_stock
BEFORE INSERT ON MOVIMIENTO_INVENTARIO
WHEN NEW.tipo_movimiento = 'SALIDA'
BEGIN
SELECT CASE
WHEN (SELECT stock_actual FROM INVENTARIO WHERE id_producto = NEW.id_producto) < NEW.cantidad
THEN RAISE(ABORT, 'Stock insuficiente')
END;
END;


-- Trigger insert para DETALLE_COMPRA
CREATE TRIGGER IF NOT EXISTS trg_detalle_compra_insert
AFTER INSERT ON DETALLE_COMPRA
BEGIN
    INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
    VALUES ('DETALLE_COMPRA', NEW.id_detalle, 'INSERT', COALESCE((SELECT username FROM current_user LIMIT 1),'sistema'));
END;

-- Trigger insert/update para INVENTARIO
CREATE TRIGGER IF NOT EXISTS trg_inventario_insert
AFTER INSERT ON INVENTARIO
BEGIN
    INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
    VALUES ('INVENTARIO', NEW.id_producto, 'INSERT', COALESCE((SELECT username FROM current_user LIMIT 1),'sistema'));
END;

CREATE TRIGGER IF NOT EXISTS trg_inventario_update
AFTER UPDATE ON INVENTARIO
BEGIN
    INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
    VALUES ('INVENTARIO', NEW.id_producto, 'UPDATE', COALESCE((SELECT username FROM current_user LIMIT 1),'sistema'));
END;

-- Trigger insert/update para ACTIVO_MUNICIPAL
CREATE TRIGGER IF NOT EXISTS trg_activo_insert
AFTER INSERT ON ACTIVO_MUNICIPAL
BEGIN
    INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
    VALUES ('ACTIVO_MUNICIPAL', NEW.id_activo, 'INSERT', COALESCE((SELECT username FROM current_user LIMIT 1),'sistema'));
END;

CREATE TRIGGER IF NOT EXISTS trg_activo_update
AFTER UPDATE ON ACTIVO_MUNICIPAL
BEGIN
    INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
    VALUES ('ACTIVO_MUNICIPAL', NEW.id_activo, 'UPDATE', COALESCE((SELECT username FROM current_user LIMIT 1),'sistema'));
END;

-- Trigger insert/update para MOVIMIENTO_INVENTARIO
CREATE TRIGGER IF NOT EXISTS trg_movimiento_insert
AFTER INSERT ON MOVIMIENTO_INVENTARIO
BEGIN
    INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
    VALUES ('MOVIMIENTO_INVENTARIO', NEW.id_movimiento, 'INSERT', COALESCE((SELECT username FROM current_user LIMIT 1),'sistema'));
END;

CREATE TRIGGER IF NOT EXISTS trg_movimiento_update
AFTER UPDATE ON MOVIMIENTO_INVENTARIO
BEGIN
    INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
    VALUES ('MOVIMIENTO_INVENTARIO', NEW.id_movimiento, 'UPDATE', COALESCE((SELECT username FROM current_user LIMIT 1),'sistema'));
END;


--Trigge para evitar compra sin proveedor y detalle con cantida < 0,
CREATE TRIGGER trg_validar_detalle_compra
BEFORE INSERT ON DETALLE_COMPRA
FOR EACH ROW
BEGIN
  SELECT CASE
    WHEN NEW.cantidad <= 0 THEN RAISE(ABORT, 'Cantidad debe ser > 0')
    WHEN NEW.precio_unitario < 0 THEN RAISE(ABORT, 'Precio unitario invalido')
  END;
END;




--trigger ciudadano

CREATE TRIGGER trg_ciudadano_insert
AFTER INSERT ON CIUDADANO
BEGIN
    INSERT INTO BITACORA (
        tabla_afectada,
        id_registro,
        accion,
        usuario
    )
    VALUES (
        'CIUDADANO',
        NEW.Identificacion_ciudadano,
        'INSERT',
        'sistema'
    );
END;

CREATE TRIGGER trg_ciudadano_update
AFTER UPDATE ON CIUDADANO
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'CIUDADANO',
NEW.Identificacion_ciudadano,
'UPDATE',
'sistema'
);
END;

--trigger EmpresA
CREATE TRIGGER trg_empresa_insert
AFTER INSERT ON EMPRESA
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'EMPRESA',
NEW.ID_EMPRESA,
'INSERT',
'sistema'
);
END;

CREATE TRIGGER trg_empresa_update
AFTER UPDATE ON EMPRESA
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'EMPRESA',
NEW.ID_EMPRESA,
'UPDATE',
'sistema'
);
END;




--Trigger predio catasttal
CREATE TRIGGER trg_predio_update
AFTER UPDATE ON PREDIO_CATASTRAL
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'PREDIO_CATASTRAL',
NEW.CODIGO_CATASTRAL,
'UPDATE',
'sistema'
);
END;

CREATE TRIGGER trg_predio_insert
AFTER INSERT ON PREDIO_CATASTRAL
BEGIN
    INSERT INTO BITACORA (
        tabla_afectada,
        id_registro,
        accion,
        usuario
    )
    VALUES (
        'PREDIO_CATASTRAL',
        NEW.CODIGO_CATASTRAL,
        'INSERT',
        'sistema'
    );
END;

CREATE TRIGGER trg_predio_delete
AFTER DELETE ON PREDIO_CATASTRAL
BEGIN
    INSERT INTO BITACORA (
        tabla_afectada,
        id_registro,
        accion,
        usuario
    )
    VALUES (
        'PREDIO_CATASTRAL',
        OLD.CODIGO_CATASTRAL,
        'DELETE',
        'sistema'
    );
END;


--trigger avaluos

CREATE TRIGGER trg_avaluo_insert
AFTER INSERT ON AVALUO
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'AVALUO',
NEW.ID_AVALUO,
'INSERT',
'sistema'
);
END;


CREATE TRIGGER trg_avaluo_update
AFTER UPDATE ON AVALUO
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'AVALUO',
NEW.ID_AVALUO,
'UPDATE',
'sistema'
);
END;

--trigger licencia obra
CREATE TRIGGER trg_licencia_insert
AFTER INSERT ON LICENCIA_OBRAS
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'LICENCIA_OBRAS',
NEW.ID_LICENCIA,
'INSERT',
'sistema'
);
END;

--trigger tramite_ciudadano
CREATE TRIGGER trg_tramite_ciudadano_insert
AFTER INSERT ON TRAMITE_CIUDADANO
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'TRAMITE_CIUDADANO',
NEW.Id_tramite_ciudadano,
'INSERT',
'sistema'
);
END;

CREATE TRIGGER trg_tramite_ciudadano_update
AFTER UPDATE ON TRAMITE_CIUDADANO
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'TRAMITE_CIUDADANO',
NEW.Id_tramite_ciudadano,
'UPDATE',
'sistema'
);
END;




--validacioñ para que un canvio de dueño de un predio no sea el mismo
CREATE TRIGGER trg_validar_cambio_titular
BEFORE UPDATE ON PREDIO_CATASTRAL
WHEN NEW.Identificacion_ciudadano_titular = OLD.Identificacion_ciudadano_titular
BEGIN
SELECT RAISE(ABORT, 'El nuevo titular no puede ser igual al titular actual');
END;



--tigeer servicio muni

CREATE TRIGGER trg_servicio_insert
AFTER INSERT ON SERVICIO_MUNICIPAL
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'SERVICIO_MUNICIPAL',
NEW.id_servicio,
'INSERT',
'sistema'
);
END;

CREATE TRIGGER trg_servicio_update
AFTER UPDATE ON SERVICIO_MUNICIPAL
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'SERVICIO_MUNICIPAL',
NEW.id_servicio,
'UPDATE',
'sistema'
);
END;



--tirger factura
CREATE TRIGGER trg_factura_insert
AFTER INSERT ON FACTURA
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'FACTURA',
NEW.id_factura,
'INSERT',
'sistema'
);
END;

CREATE TRIGGER trg_factura_update
AFTER UPDATE ON FACTURA
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'FACTURA',
NEW.id_factura,
'UPDATE',
'sistema'
);
END;


--rendimientos modulo 4

CREATE INDEX idx_servicio_predio
ON SERVICIO_MUNICIPAL(codigo_catastral);

CREATE INDEX idx_factura_ciudadano
ON FACTURA(id_ciudadano);

CREATE INDEX idx_pago_factura
ON PAGO(id_factura);

CREATE INDEX idx_pago_fecha
ON PAGO(fecha_pago);


--TRIGGER para validar que el pago no se mayor al indicado en la factura

CREATE TRIGGER trg_validar_pago
BEFORE INSERT ON PAGO
FOR EACH ROW
BEGIN
SELECT CASE
    WHEN NEW.monto_pago >
        (SELECT monto + mora
         FROM FACTURA
         WHERE id_factura = NEW.id_factura)
    THEN RAISE(ABORT, 'El pago excede el saldo pendiente')
END;
END;


--Contorl para poner mora automatica
UPDATE FACTURA
SET mora = monto * 0.10,
    id_estado_factura = 3
WHERE id_estado_factura = 1
AND julianday('now') - julianday(fecha_emision) > 30;


--TRIGGER para pagos

CREATE TRIGGER trg_pago_insert_bitacora
AFTER INSERT ON PAGO
BEGIN
INSERT INTO BITACORA (
tabla_afectada,
id_registro,
accion,
usuario
)
VALUES (
'PAGO',
NEW.id_pago,
'INSERT',
'sistema'
);
END;


--TRIGGER valida que no haya pagos negativos

CREATE TRIGGER trg_validar_pago_negativo
BEFORE INSERT ON PAGO
FOR EACH ROW
BEGIN
SELECT CASE
    WHEN NEW.monto_pago <= 0
    THEN RAISE(ABORT, 'El pago debe ser mayor a cero')
END;
END;



--TRIGGER para no permitir un convenio con moto cero
CREATE TRIGGER trg_validar_convenio
BEFORE INSERT ON CONVENIO_PAGO
FOR EACH ROW
BEGIN
SELECT CASE
    WHEN NEW.monto_acordado <= 0
    THEN RAISE(ABORT, 'Monto de convenio invalido')
END;
END;



--TRIGGER MULTA
CREATE TRIGGER trg_multa_insert
AFTER INSERT ON MULTA
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('MULTA', NEW.Id_multa, 'INSERT','sistema');
END;

CREATE TRIGGER trg_multa_update
AFTER UPDATE ON MULTA
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('MULTA', NEW.Id_multa, 'UPDATE','sistema');
END;

--TRIGGER APELACION MULTA
CREATE TRIGGER trg_apelacion_insert
AFTER INSERT ON APELACION_MULTA
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('APELACION_MULTA', NEW.id_apelacion, 'INSERT','sistema');
END;

CREATE TRIGGER trg_apelacion_update
AFTER UPDATE ON APELACION_MULTA
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('APELACION_MULTA', NEW.id_apelacion, 'UPDATE','sistema');
END;

--TRIGGER RESOLCION APELACION
CREATE TRIGGER trg_resolucion_insert
AFTER INSERT ON RESOLUCION_APELACION
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('RESOLUCION_APELACION', NEW.id_resolucion, 'INSERT','sistema');
END;

CREATE TRIGGER trg_resolucion_update
AFTER UPDATE ON RESOLUCION_APELACION
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('RESOLUCION_APELACION', NEW.id_resolucion, 'UPDATE','sistema');
END;

--TRIGGER MULTA CIUDADANO
CREATE TRIGGER trg_multa_ciudadano_insert
AFTER INSERT ON MULTA_CIUDADANO
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('MULTA_CIUDADANO', NEW.id_multa, 'INSERT','sistema');
END;


--TRIGGER VERIFICA QUE NO HAYA DOBLE APELACION A UN A MULTA

CREATE TRIGGER trg_validar_apelacion_unica
BEFORE INSERT ON APELACION_MULTA
FOR EACH ROW
BEGIN
SELECT CASE
WHEN EXISTS (
    SELECT 1 FROM APELACION_MULTA
    WHERE id_multa = NEW.id_multa
)
THEN RAISE(ABORT, 'La multa ya tiene una apelación registrada')
END;
END;


--TRIGGER PARA QUE EL MONTO DE DESCUENTO NO SEA MAYOR A LA MULTA
CREATE TRIGGER trg_validar_descuento
BEFORE INSERT ON RESOLUCION_APELACION
FOR EACH ROW
BEGIN
SELECT CASE
WHEN NEW.descuento_aplicado > NEW.monto_total
THEN RAISE(ABORT, 'El descuento no puede ser mayor al monto total')
END;
END;



--TRIGGER QUEJA
CREATE TRIGGER trg_queja_insert
AFTER INSERT ON QUEJA
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('QUEJA', NEW.id_queja, 'INSERT','sistema');
END;

CREATE TRIGGER trg_queja_update
AFTER UPDATE ON QUEJA
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('QUEJA', NEW.id_queja, 'UPDATE','sistema');
END;


--TRIGGER SOLICITUD

CREATE TRIGGER trg_solicitud_insert
AFTER INSERT ON SOLICITUD
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('SOLICITUD', NEW.id_solicitud, 'INSERT','sistema');
END;

CREATE TRIGGER trg_solicitud_update
AFTER UPDATE ON SOLICITUD
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('SOLICITUD', NEW.id_solicitud, 'UPDATE','sistema');
END;


--TRIGGER ENCUESTA
CREATE TRIGGER trg_encuesta_insert
AFTER INSERT ON ENCUESTA_SATISFACCION
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('ENCUESTA_SATISFACCION', NEW.id_encuesta, 'INSERT','sistema');
END;

--TRIGGER OBSERVACION_ENCUESTA

CREATE TRIGGER trg_observacion_encuesta_insert
AFTER INSERT ON OBSERVACION_ENCUESTA
BEGIN
INSERT INTO BITACORA (tabla_afectada,id_registro,accion,usuario)
VALUES ('OBSERVACION_ENCUESTA', NEW.id_observacion_encuesta, 'INSERT','sistema');
END;


--TRIGGER RANGO CALIFICACION
CREATE TRIGGER trg_validar_calificacion
BEFORE INSERT ON ENCUESTA_SATISFACCION
FOR EACH ROW
BEGIN
SELECT CASE
WHEN NEW.calificacion < 1 OR NEW.calificacion > 5
THEN RAISE(ABORT, 'La calificación debe estar entre 1 y 5')
END;
END;


--TRIGGER VALIDAR ENCUESTA POR TRAMITE DUPLICADA 
CREATE TRIGGER trg_encuesta_unica
BEFORE INSERT ON ENCUESTA_SATISFACCION
FOR EACH ROW
BEGIN
SELECT CASE
WHEN EXISTS (
SELECT 1 FROM ENCUESTA_SATISFACCION
WHERE id_unico_ciudadano = NEW.id_unico_ciudadano
AND id_tramite_ciudadano = NEW.id_tramite_ciudadano
)
THEN RAISE(ABORT, 'Ya existe una encuesta para este trámite')
END;
END;




