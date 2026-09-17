-- ============================================================
-- DDL COMPLETO - OFI COOPERATIVAS
-- Practica 2 - Sistemas de Bases de Datos 1
-- Universidad de San Carlos de Guatemala - CUNOC
-- Motor: PostgreSQL
-- Basado en el diagrama de tablas oficial
-- ============================================================

-- ============================================================
-- SECCION 1: TIPOS ENUM
-- ============================================================
CREATE TYPE tipo_cafe_enum          AS ENUM ('cereza','pergamino_humedo','pergamino_seco','cafe_oro');
CREATE TYPE clasificacion_cafe_enum AS ENUM ('Extra','Superior','Segunda','Tercera','Caracol','Peaberry','Descarte');
CREATE TYPE tipo_insumo_enum        AS ENUM ('insecticida','fungicida','abono_organico','almacigo');
CREATE TYPE estado_empleado_enum    AS ENUM ('activo','inactivo');
CREATE TYPE estado_membresia_enum   AS ENUM ('activo','suspendido','inactivo');
CREATE TYPE tipo_asociacion_enum    AS ENUM ('A','B','C');
CREATE TYPE estado_evaluacion_enum  AS ENUM ('pendiente','aprobada','rechazada');
CREATE TYPE estado_visita_enum      AS ENUM ('programada','en_curso','completada','cancelada');
CREATE TYPE tipo_aplicacion_enum    AS ENUM ('fertilizacion','control_plagas','poda','riego','muestreo_suelo');
CREATE TYPE forma_pago_enum         AS ENUM ('efectivo','cheque');
CREATE TYPE estado_factura_enum     AS ENUM ('pendiente','pagada');
CREATE TYPE tipo_movimiento_enum    AS ENUM ('entrada_recibo','salida_traslado','entrada_traslado','salida_exportacion');
CREATE TYPE estado_traslado_enum    AS ENUM ('en_transito','recibido','cancelado');
CREATE TYPE estado_contrato_enum    AS ENUM ('vigente','cumplido','cancelado');
CREATE TYPE categoria_activo_enum   AS ENUM ('vehiculo','maquinaria','mobiliario','herramienta','infraestructura');
CREATE TYPE estado_activo_enum      AS ENUM ('en_uso','en_reparacion','dado_de_baja');
CREATE TYPE metodo_secado_enum      AS ENUM ('patio','maquina');

-- ============================================================
-- SECCION 2: TABLAS BASE (sin dependencias)
-- ============================================================

CREATE TABLE municipios (
    id           SERIAL PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL DEFAULT 'Huehuetenango',
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE roles (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(60)  NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE tipos_cafe (
    id          SERIAL PRIMARY KEY,
    nombre      tipo_cafe_enum NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE clasificaciones_cafe (
    id          SERIAL PRIMARY KEY,
    nombre      clasificacion_cafe_enum NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE tipos_insumo (
    id          SERIAL PRIMARY KEY,
    nombre      tipo_insumo_enum NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE variedades_cafe (
    id         SERIAL PRIMARY KEY,
    nombre     VARCHAR(60) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE empresas_extranjeras (
    id       SERIAL PRIMARY KEY,
    nombre   VARCHAR(150) NOT NULL,
    pais     VARCHAR(100) NOT NULL,
    ciudad   VARCHAR(100),
    contacto VARCHAR(150),
    correo   VARCHAR(120),
    telefono VARCHAR(30),
    activa   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE vehiculos (
    id          SERIAL PRIMARY KEY,
    placa       VARCHAR(20)  NOT NULL UNIQUE,
    marca       VARCHAR(100),
    modelo      VARCHAR(100),
    descripcion VARCHAR(255),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE bonos_especialidad_config (
    id              SERIAL PRIMARY KEY,
    puntaje_min     DECIMAL(5,2)  NOT NULL CHECK (puntaje_min >= 0),
    puntaje_max     DECIMAL(5,2)  NOT NULL CHECK (puntaje_max <= 100),
    bono_quintal    DECIMAL(10,2) NOT NULL CHECK (bono_quintal > 0),
    temporada_inicio DATE NOT NULL,
    temporada_fin    DATE NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_bono_rango CHECK (puntaje_max >= puntaje_min),
    CONSTRAINT chk_bono_temporada CHECK (temporada_fin > temporada_inicio)
);

-- ============================================================
-- SECCION 3: COOPERATIVAS Y EMPLEADOS
-- ============================================================

CREATE TABLE cooperativas (
    id           SERIAL PRIMARY KEY,
    nombre       VARCHAR(150) NOT NULL,
    municipio_id INT          NOT NULL REFERENCES municipios(id),
    direccion    VARCHAR(255),
    telefono     VARCHAR(20),
    correo       VARCHAR(120),
    activa       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE empleados (
    id             SERIAL PRIMARY KEY,
    codigo         VARCHAR(20)  NOT NULL UNIQUE,
    nombre         VARCHAR(100) NOT NULL,
    apellido       VARCHAR(100) NOT NULL,
    dpi            VARCHAR(20)  NOT NULL UNIQUE,
    nit            VARCHAR(20)  NOT NULL UNIQUE,
    telefono       VARCHAR(20),
    direccion      VARCHAR(255),
    fecha_ingreso  DATE         NOT NULL,
    salario_base   DECIMAL(10,2) NOT NULL CHECK (salario_base > 0),
    rol_id         INT          NOT NULL REFERENCES roles(id),
    cooperativa_id INT          REFERENCES cooperativas(id),
    num_colegiado  VARCHAR(40),
    tipo_licencia  VARCHAR(10),
    num_licencia   VARCHAR(30),
    estado         estado_empleado_enum NOT NULL DEFAULT 'activo',
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Historial de cambios de rol
CREATE TABLE historial_roles (
    id           SERIAL PRIMARY KEY,
    empleado_id  INT  NOT NULL REFERENCES empleados(id),
    rol_id       INT  NOT NULL REFERENCES roles(id),
    fecha_inicio DATE NOT NULL,
    fecha_fin    DATE,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Auditoria de cambios en empleados
CREATE TABLE auditoria_empleados (
    id               SERIAL PRIMARY KEY,
    empleado_id      INT         NOT NULL REFERENCES empleados(id),
    campo_modificado VARCHAR(60) NOT NULL,
    valor_anterior   TEXT,
    valor_nuevo      TEXT,
    usuario_bd       INT         REFERENCES empleados(id),
    fecha_cambio     TIMESTAMP   NOT NULL DEFAULT NOW(),
    created_at       TIMESTAMP   NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP   NOT NULL DEFAULT NOW()
);

-- ============================================================
-- SECCION 4: PRODUCTORES, SOCIOS Y TERRENOS
-- ============================================================

CREATE TABLE productores (
    id             SERIAL PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL,
    apellido       VARCHAR(100) NOT NULL,
    dpi            VARCHAR(20)  NOT NULL UNIQUE,
    nit            VARCHAR(20),
    telefono       VARCHAR(20),
    municipio_id   INT REFERENCES municipios(id),
    aldea          VARCHAR(100),
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
    es_socio       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE socios (
    id                 SERIAL PRIMARY KEY,
    productor_id       INT NOT NULL UNIQUE REFERENCES productores(id),
    cooperativa_id     INT NOT NULL REFERENCES cooperativas(id),
    fecha_ingreso_socio DATE NOT NULL,
    tipo_asociacion    tipo_asociacion_enum,
    estado_membresia   estado_membresia_enum NOT NULL DEFAULT 'activo',
    created_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE terrenos (
    id                    SERIAL PRIMARY KEY,
    codigo                VARCHAR(30)  NOT NULL UNIQUE,
    nombre                VARCHAR(150) NOT NULL,
    productor_id          INT          NOT NULL REFERENCES productores(id),
    municipio_id          INT          NOT NULL REFERENCES municipios(id),
    aldea                 VARCHAR(100),
    altitud_msnm          DECIMAL(7,2),
    area_estimada_cuerdas DECIMAL(8,2),
    area_calculada_cuerdas DECIMAL(8,4),
    created_at            TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE esquineros_terreno (
    id           SERIAL PRIMARY KEY,
    terreno_id   INT            NOT NULL REFERENCES terrenos(id),
    numero_orden SMALLINT       NOT NULL CHECK (numero_orden >= 1),
    coord_x      DECIMAL(15,8)  NOT NULL,
    coord_y      DECIMAL(15,8)  NOT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (terreno_id, numero_orden)
);

CREATE TABLE evaluaciones_tecnicas (
    id                    SERIAL PRIMARY KEY,
    terreno_id            INT           NOT NULL REFERENCES terrenos(id),
    tecnico_id            INT           NOT NULL REFERENCES empleados(id),
    supervisor_id         INT           REFERENCES empleados(id),
    fecha_evaluacion      DATE          NOT NULL,
    plantas_por_cuerda    SMALLINT      CHECK (plantas_por_cuerda > 0),
    edad_cafetal_anios    SMALLINT      CHECK (edad_cafetal_anios >= 0),
    variedad_id           INT           REFERENCES variedades_cafe(id),
    observaciones_suelo   TEXT,
    porcentaje_pendiente  DECIMAL(5,2)  CHECK (porcentaje_pendiente BETWEEN 0 AND 100),
    puntuacion_tecnica    DECIMAL(5,2)  CHECK (puntuacion_tecnica BETWEEN 0 AND 100),
    estado                estado_evaluacion_enum NOT NULL DEFAULT 'pendiente',
    comentario_supervisor TEXT,
    fecha_decision        DATE,
    foto_url              VARCHAR(500),
    created_at            TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- SECCION 5: INSUMOS Y VISITAS TECNICAS
-- ============================================================

CREATE TABLE entregas_insumos (
    id             SERIAL PRIMARY KEY,
    socio_id       INT           NOT NULL REFERENCES socios(id),
    terreno_id     INT           NOT NULL REFERENCES terrenos(id),
    tipo_insumo_id INT           NOT NULL REFERENCES tipos_insumo(id),
    cantidad       DECIMAL(10,2) NOT NULL CHECK (cantidad > 0),
    unidad_medida  VARCHAR(30)   NOT NULL,
    fecha_entrega  DATE          NOT NULL,
    responsable_id INT           NOT NULL REFERENCES empleados(id),
    observaciones  TEXT,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE visitas_tecnicas (
    id                     SERIAL PRIMARY KEY,
    gerente_id             INT  NOT NULL REFERENCES empleados(id),
    tecnico_id             INT  NOT NULL REFERENCES empleados(id),
    fecha_programada       DATE NOT NULL,
    fecha_real_ejecucion   DATE,
    estado                 estado_visita_enum NOT NULL DEFAULT 'programada',
    observaciones_generales TEXT,
    created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE visita_terrenos (
    id                     SERIAL PRIMARY KEY,
    visita_id              INT  NOT NULL REFERENCES visitas_tecnicas(id),
    terreno_id             INT  NOT NULL REFERENCES terrenos(id),
    tipo_aplicacion        tipo_aplicacion_enum NOT NULL,
    producto               VARCHAR(100),
    dosis_recomendada      VARCHAR(100),
    instrucciones          TEXT,
    hallazgos              TEXT,
    actividades_realizadas TEXT,
    created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- SECCION 6: PRECIOS Y LOG
-- ============================================================

CREATE TABLE precios_cafe (
    id             SERIAL PRIMARY KEY,
    tipo_cafe_id   INT           NOT NULL REFERENCES tipos_cafe(id),
    precio_quintal DECIMAL(10,2) NOT NULL CHECK (precio_quintal > 0),
    fecha_vigencia DATE          NOT NULL,
    fecha_fin      DATE,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE log_precios (
    id              SERIAL PRIMARY KEY,
    precio_id       INT           REFERENCES precios_cafe(id),
    tipo_cafe_id    INT           NOT NULL REFERENCES tipos_cafe(id),
    precio_anterior DECIMAL(10,2),
    precio_nuevo    DECIMAL(10,2) NOT NULL,
    variacion_abs   DECIMAL(10,2),
    variacion_pct   DECIMAL(6,2),
    usuario_bd      INT           REFERENCES empleados(id),
    fecha_cambio    TIMESTAMP     NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- SECCION 7: BODEGAS E INVENTARIO
-- ============================================================

CREATE TABLE bodegas (
    id             SERIAL PRIMARY KEY,
    codigo         VARCHAR(20)   NOT NULL UNIQUE,
    nombre         VARCHAR(150)  NOT NULL,
    cooperativa_id INT           REFERENCES cooperativas(id),
    es_central     BOOLEAN       NOT NULL DEFAULT FALSE,
    capacidad_qq   DECIMAL(10,2) NOT NULL CHECK (capacidad_qq > 0),
    bodeguero_id   INT           REFERENCES empleados(id),
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE inventario_cafe (
    id                   SERIAL PRIMARY KEY,
    bodega_id            INT           NOT NULL REFERENCES bodegas(id),
    tipo_cafe_id         INT           NOT NULL REFERENCES tipos_cafe(id),
    clasificacion_id     INT           REFERENCES clasificaciones_cafe(id),
    cantidad_qq          DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (cantidad_qq >= 0),
    ultima_actualizacion TIMESTAMP     NOT NULL DEFAULT NOW(),
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (bodega_id, tipo_cafe_id, clasificacion_id)
);

CREATE TABLE movimientos_inventario (
    id               SERIAL PRIMARY KEY,
    bodega_id        INT                  NOT NULL REFERENCES bodegas(id),
    tipo_cafe_id     INT                  NOT NULL REFERENCES tipos_cafe(id),
    clasificacion_id INT                  REFERENCES clasificaciones_cafe(id),
    tipo_movimiento  tipo_movimiento_enum NOT NULL,
    cantidad_qq      DECIMAL(10,2)        NOT NULL CHECK (cantidad_qq > 0),
    referencia_id    INT,
    responsable_id   INT                  NOT NULL REFERENCES empleados(id),
    fecha            TIMESTAMP            NOT NULL DEFAULT NOW(),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- SECCION 8: RECEPCION Y COMPRA DE CAFE
-- ============================================================

CREATE TABLE recibos (
    id            SERIAL PRIMARY KEY,
    numero        VARCHAR(20)   NOT NULL UNIQUE,
    bodega_id     INT           NOT NULL REFERENCES bodegas(id),
    productor_id  INT           NOT NULL REFERENCES productores(id),
    bodeguero_id  INT           NOT NULL REFERENCES empleados(id),
    supervisor_id INT           NOT NULL REFERENCES empleados(id),
    tipo_cafe_id  INT           NOT NULL REFERENCES tipos_cafe(id),
    peso_bruto_qq DECIMAL(10,2) NOT NULL CHECK (peso_bruto_qq > 0),
    peso_neto_qq  DECIMAL(10,2) NOT NULL CHECK (peso_neto_qq > 0),
    fecha_recibo  DATE          NOT NULL,
    hora_recibo   TIME          NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE turnos_descarga (
    id                SERIAL   PRIMARY KEY,
    recibo_id         INT      NOT NULL REFERENCES recibos(id),
    cargador_id       INT      NOT NULL REFERENCES empleados(id),
    sacos_descargados SMALLINT NOT NULL CHECK (sacos_descargados > 0),
    hora_inicio       TIME     NOT NULL,
    hora_fin          TIME     NOT NULL,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_turno_horas CHECK (hora_fin > hora_inicio)
);

CREATE TABLE facturas_compra (
    id              SERIAL PRIMARY KEY,
    numero          VARCHAR(20)   NOT NULL UNIQUE,
    recibo_id       INT           NOT NULL UNIQUE REFERENCES recibos(id),
    contador_id     INT           NOT NULL REFERENCES empleados(id),
    fecha_factura   DATE          NOT NULL,
    quintales_netos DECIMAL(10,2) NOT NULL CHECK (quintales_netos > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario > 0),
    monto_total     DECIMAL(12,2) NOT NULL CHECK (monto_total > 0),
    anticipo        DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (anticipo >= 0),
    saldo_pagar     DECIMAL(12,2) NOT NULL CHECK (saldo_pagar >= 0),
    forma_pago      forma_pago_enum NOT NULL,
    banco           VARCHAR(100),
    num_cheque      VARCHAR(50),
    fecha_cheque    DATE,
    estado          estado_factura_enum NOT NULL DEFAULT 'pendiente',
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_cheque CHECK (
        forma_pago <> 'cheque' OR
        (banco IS NOT NULL AND num_cheque IS NOT NULL AND fecha_cheque IS NOT NULL)
    )
);

CREATE TABLE control_calidad (
    id                   SERIAL PRIMARY KEY,
    recibo_id            INT          NOT NULL UNIQUE REFERENCES recibos(id),
    responsable_id       INT          NOT NULL REFERENCES empleados(id),
    porcentaje_humedad   DECIMAL(5,2) CHECK (porcentaje_humedad BETWEEN 0 AND 100),
    rendimiento_estimado DECIMAL(5,2) CHECK (rendimiento_estimado BETWEEN 0 AND 100),
    defectos             TEXT,
    puntaje_taza         DECIMAL(5,2) CHECK (puntaje_taza BETWEEN 0 AND 100),
    es_especialidad      BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_evaluacion     DATE    NOT NULL DEFAULT CURRENT_DATE,
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE bonos_especialidad (
    id               SERIAL PRIMARY KEY,
    recibo_id        INT           NOT NULL UNIQUE REFERENCES recibos(id),
    config_bono_id   INT           NOT NULL REFERENCES bonos_especialidad_config(id),
    quintales        DECIMAL(10,2) NOT NULL CHECK (quintales > 0),
    bono_por_quintal DECIMAL(10,2) NOT NULL CHECK (bono_por_quintal > 0),
    monto_total_bono DECIMAL(12,2) NOT NULL CHECK (monto_total_bono > 0),
    pagado           BOOLEAN NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- SECCION 9: LOTES DE PROCESAMIENTO
-- ============================================================

CREATE TABLE lotes_procesamiento (
    id         SERIAL PRIMARY KEY,
    codigo     VARCHAR(30) NOT NULL UNIQUE,
    recibo_id  INT         NOT NULL UNIQUE REFERENCES recibos(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE beneficiado_humedo (
    id                SERIAL PRIMARY KEY,
    lote_id           INT           NOT NULL REFERENCES lotes_procesamiento(id),
    operador_id       INT           NOT NULL REFERENCES empleados(id),
    fecha             DATE          NOT NULL,
    volumen_entrada_qq DECIMAL(10,2) NOT NULL CHECK (volumen_entrada_qq > 0),
    merma_kg          DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (merma_kg >= 0),
    observaciones     TEXT,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE secado (
    id               SERIAL PRIMARY KEY,
    lote_id          INT           NOT NULL REFERENCES lotes_procesamiento(id),
    operador_id      INT           NOT NULL REFERENCES empleados(id),
    metodo           metodo_secado_enum NOT NULL,
    temperatura_c    DECIMAL(5,2),
    dias_empleados   SMALLINT      NOT NULL CHECK (dias_empleados > 0),
    humedad_final_pct DECIMAL(5,2) CHECK (humedad_final_pct BETWEEN 0 AND 100),
    fecha_inicio     DATE          NOT NULL,
    fecha_fin        DATE,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE beneficiado_seco (
    id                     SERIAL PRIMARY KEY,
    lote_id                INT           NOT NULL REFERENCES lotes_procesamiento(id),
    operador_id            INT           NOT NULL REFERENCES empleados(id),
    fecha                  DATE          NOT NULL,
    qq_pergamino_entrada   DECIMAL(10,2) NOT NULL CHECK (qq_pergamino_entrada > 0),
    qq_oro_resultado       DECIMAL(10,2) NOT NULL CHECK (qq_oro_resultado > 0),
    porcentaje_rendimiento DECIMAL(5,2)  NOT NULL DEFAULT 0 CHECK (porcentaje_rendimiento BETWEEN 0 AND 100),
    observaciones          TEXT,
    created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE clasificaciones_lote (
    id                 SERIAL PRIMARY KEY,
    lote_id            INT           NOT NULL REFERENCES lotes_procesamiento(id),
    clasificacion_id   INT           NOT NULL REFERENCES clasificaciones_cafe(id),
    cantidad_qq        DECIMAL(10,2) NOT NULL CHECK (cantidad_qq > 0),
    fecha_clasificacion DATE         NOT NULL DEFAULT CURRENT_DATE,
    created_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (lote_id, clasificacion_id)
);

-- ============================================================
-- SECCION 10: TRASLADOS
-- ============================================================

CREATE TABLE traslados (
    id                     SERIAL PRIMARY KEY,
    numero                 VARCHAR(20)          NOT NULL UNIQUE,
    bodega_origen_id       INT                  NOT NULL REFERENCES bodegas(id),
    bodega_destino_id      INT                  NOT NULL REFERENCES bodegas(id),
    clasificacion_id       INT                  NOT NULL REFERENCES clasificaciones_cafe(id),
    cantidad_qq            DECIMAL(10,2)        NOT NULL CHECK (cantidad_qq > 0),
    transportista_id       INT                  NOT NULL REFERENCES empleados(id),
    vehiculo_id            INT                  NOT NULL REFERENCES vehiculos(id),
    bodeguero_despacha_id  INT                  NOT NULL REFERENCES empleados(id),
    bodeguero_recibe_id    INT                  REFERENCES empleados(id),
    fecha_salida           TIMESTAMP,
    fecha_llegada          TIMESTAMP,
    nota_contable          VARCHAR(255),
    estado                 estado_traslado_enum NOT NULL DEFAULT 'en_transito',
    created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_bodegas_distintas CHECK (bodega_origen_id <> bodega_destino_id)
);

-- ============================================================
-- SECCION 11: ACTIVOS
-- ============================================================

CREATE TABLE activos (
    id                 SERIAL PRIMARY KEY,
    codigo             VARCHAR(30)          NOT NULL UNIQUE,
    descripcion        VARCHAR(255)         NOT NULL,
    categoria          categoria_activo_enum NOT NULL,
    fecha_adquisicion  DATE                 NOT NULL,
    valor_compra       DECIMAL(12,2)        NOT NULL CHECK (valor_compra > 0),
    estado             estado_activo_enum   NOT NULL DEFAULT 'en_uso',
    cooperativa_id     INT                  REFERENCES cooperativas(id),
    responsable_id     INT                  REFERENCES empleados(id),
    observaciones      TEXT,
    created_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- SECCION 12: CONTRATOS Y EXPORTACIONES
-- ============================================================

CREATE TABLE contratos_exportacion (
    id                   SERIAL PRIMARY KEY,
    numero               VARCHAR(30)          NOT NULL UNIQUE,
    empresa_id           INT                  NOT NULL REFERENCES empresas_extranjeras(id),
    fecha_firma          DATE                 NOT NULL,
    fecha_entrega_est    DATE                 NOT NULL,
    qq_totales_pactados  DECIMAL(10,2)        NOT NULL CHECK (qq_totales_pactados > 0),
    precio_usd_quintal   DECIMAL(10,2)        NOT NULL CHECK (precio_usd_quintal > 0),
    estado               estado_contrato_enum NOT NULL DEFAULT 'vigente',
    observaciones        TEXT,
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE contrato_detalle (
    id               SERIAL PRIMARY KEY,
    contrato_id      INT           NOT NULL REFERENCES contratos_exportacion(id),
    tipo_cafe_id     INT           NOT NULL REFERENCES tipos_cafe(id),
    clasificacion_id INT           NOT NULL REFERENCES clasificaciones_cafe(id),
    cantidad_qq      DECIMAL(10,2) NOT NULL CHECK (cantidad_qq > 0),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (contrato_id, tipo_cafe_id, clasificacion_id)
);

CREATE TABLE exportaciones (
    id                   SERIAL PRIMARY KEY,
    numero               VARCHAR(30)   NOT NULL UNIQUE,
    contrato_id          INT           NOT NULL REFERENCES contratos_exportacion(id),
    bodega_origen_id     INT           NOT NULL REFERENCES bodegas(id),
    transportista_id     INT           NOT NULL REFERENCES empleados(id),
    vehiculo_id          INT           NOT NULL REFERENCES vehiculos(id),
    autorizador_id       INT           NOT NULL REFERENCES empleados(id),
    fecha_despacho       DATE          NOT NULL,
    quintales_exportados DECIMAL(10,2) NOT NULL CHECK (quintales_exportados > 0),
    num_contenedor       VARCHAR(50),
    puerto_salida        VARCHAR(100),
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- SECCION 13: FUNCIONES ESCALARES
-- ============================================================

-- fn_precio_compra
-- Retorna el precio vigente para el tipo de cafe en la fecha dada.
-- Si el productor es socio activo, aplica incremento del 10%.
CREATE OR REPLACE FUNCTION fn_precio_compra(
    p_productor_id INT,             --id del productor
    p_tipo_cafe    tipo_cafe_enum,  --tipo de cafe (cereza, pergamino_humedo, pergamino_seco, cafe_oro)
    p_fecha        DATE             --fecha para determinar el precio vigente
)
RETURNS DECIMAL AS $$

DECLARE
    v_precio_base  DECIMAL(10,2);    --variable para almacenar el precio base encontrado
    v_tipo_cafe_id INT;              --variable para almacenar el id del tipo de cafe
    v_es_socio     BOOLEAN := FALSE; --variable para indicar si el productor es socio activo

BEGIN
    SELECT id INTO v_tipo_cafe_id                                    --obtener el id del tipo de cafe a partir del enum y lo asginar a la variable v_tipo_cafe_id
    FROM   tipos_cafe WHERE nombre = p_tipo_cafe;                    

    IF v_tipo_cafe_id IS NULL THEN                                   --si no se encuentra el tipo de cafe, lanzar excepcion
        RAISE EXCEPTION 'Tipo de cafe "%" no existe.', p_tipo_cafe;
    END IF;

    -- Precio vigente mas reciente en o antes de la fecha
    SELECT precio_quintal INTO v_precio_base                         --obtener el precio base vigente para el tipo de cafe y fecha dada y asignamos a la variable v_precio_base
    FROM   precios_cafe                                              --de la tabla precios_cafe
    WHERE  tipo_cafe_id   = v_tipo_cafe_id                           --donde el tipo_cafe_id coincida con el id obtenido para el tipo de cafe
      AND  fecha_vigencia <= p_fecha                                 --y la fecha de vigencia sea en o antes de la fecha dada
      AND  (fecha_fin IS NULL OR fecha_fin >= p_fecha)               --y la fecha_fin sea nula o en o después de la fecha dada
    ORDER BY fecha_vigencia DESC                                     --ordenar por fecha_vigencia descendente para obtener el mas reciente
    LIMIT 1;                                                         --como solo pidemos un precio, limitamos a 1 resultado

    IF v_precio_base IS NULL THEN                                                                    --si no se encuentra un precio vigente para el tipo de cafe y fecha dada, lanzar excepcion
        RAISE EXCEPTION 'No hay precio registrado para "%" en la fecha %.', p_tipo_cafe, p_fecha;
    END IF;

    -- Verificar si es socio activo
    SELECT EXISTS (
        SELECT 1 FROM socios s                               --de la tabla socios con alias s
        JOIN   productores pr ON pr.id = s.productor_id      --unir con productores para verificar el productor
        WHERE  pr.id = p_productor_id                        --donde el id del productor coincida con el id dado
          AND  s.estado_membresia = 'activo'                 --y el estado de membresia sea activo
    ) INTO v_es_socio;                                       --asignar el resultado a la variable v_es_socio

    IF v_es_socio THEN                                       --si es socio activo, aplicar incremento del 10% al precio base y retornar el resultado redondeado a 2 decimales
        RETURN ROUND(v_precio_base * 1.10, 2);
    ELSE
        RETURN v_precio_base;                                --si no es socio, retornar el precio base sin cambios
    END IF;
END;
$$ LANGUAGE plpgsql;                                         


-- fn_area_terreno
-- Calcula el area usando Gauss-Shoelace y actualiza area_calculada_cuerdas.
CREATE OR REPLACE FUNCTION fn_area_terreno(p_terreno_id INT)
RETURNS DECIMAL AS $$
DECLARE
    v_area DECIMAL(10,4);    --variable para almacenar el area calculada
BEGIN
    -- Gauss-Shoelace: A = |sum(x_i * y_{i+1} - x_{i+1} * y_i)| / 2
    --Esto  va diciendo o estableciendo el punto 1, punto 2, punto 3, etc. y luego el punto siguiente a cada uno
    WITH coords AS (                                                    --CTE para obtener las coordenadas ordenadas por numero_orden y asignar un numero de fila
        SELECT coord_x AS x,                                            --seleccionar coord_x como x
               coord_y AS y,                                            --seleccionar coord_y como y
               ROW_NUMBER() OVER (ORDER BY numero_orden) AS rn,         --asignar un numero de fila ordenado por numero_orden
               COUNT(*)     OVER ()                       AS total      --contar el total de esquineros para el terreno
        FROM   esquineros_terreno                                       --de la tabla esquineros_terreno
        WHERE  terreno_id = p_terreno_id                                --donde el terreno_id coincida con el id dado
    ),

    --aqui junta los pares de cordenadas para aplicar la formula de Gauss-Shoelace, tomando cada coordenada actual (xi, yi) y la siguiente (xi1, yi1)
    --rn cirve para identificar la coordenada actual y rn + 1 para identificar la siguiente coordenada, usando LEFT JOIN para unir con la siguiente fila
    pairs AS (                                                                   
        SELECT                                                                    --para cada fila de coords, obtener la coordenada actual (xi, yi) y                     
            c1.x                                                        AS xi,    -- la siguiente (xi1, yi1), usando LEFT JOIN para unir con la siguiente fila rn + 1
            c1.y                                                        AS yi,    --si no hay siguiente fila (es decir, para la ultima coordenada), usar la primera fila (rn = 1) para cerrar el poligono
            COALESCE(c2.x, (SELECT x FROM coords WHERE rn = 1))         AS xi1,    
            COALESCE(c2.y, (SELECT y FROM coords WHERE rn = 1))         AS yi1
        FROM  coords c1                                                           --c1 representa la coordenada actual
        LEFT  JOIN coords c2 ON c2.rn = c1.rn + 1                                 --c2 representa la siguiente coordenada, unida por el numero de fila rn + 1
    )
    SELECT ABS(SUM(xi * yi1 - xi1 * yi)) / 2.0 --aplicar la formula de Gauss-Shoelace para calcular el area del poligono formado por las coordenadas, tomando el valor absoluto y dividiendo entre 2
    INTO   v_area                              --asignar el resultado a la variable v_area
    FROM   pairs;                              --de la tabla pairs que contiene las coordenadas actuales y siguientes

    UPDATE terrenos                            --actualizar la tabla terrenos
    SET    area_calculada_cuerdas = v_area,    --establecer el area_calculada_cuerdas con el valor calculado
           updated_at             = NOW()      --actualizar el campo updated_at con la fecha y hora actual
    WHERE  id = p_terreno_id;                  --donde el id del terreno coincida con el id dado

    RETURN COALESCE(v_area, 0);                --retornar el area calculada, o 0 si es null (por ejemplo, si no hay esquineros para el terreno)
END;
$$ LANGUAGE plpgsql;


-- fn_saldo_contrato
-- Retorna los quintales pendientes de exportar en un contrato.
CREATE OR REPLACE FUNCTION fn_saldo_contrato(p_contrato_id INT)
RETURNS DECIMAL AS $$
DECLARE
    v_pactados  DECIMAL(10,2) := 0; --variable para almacenar los quintales pactados en el contrato
    v_exportado DECIMAL(10,2) := 0; --variable para almacenar los quintales ya exportados asociados al contrato
BEGIN
    SELECT COALESCE(qq_totales_pactados, 0)   --obtener los quintales totales pactados para el contrato dado y asignar a la variable v_pactados, usando COALESCE para retornar 0 si es null
    INTO   v_pactados                         --si hay pendientes lo almacena en la variable v_pactados
    FROM   contratos_exportacion              --toma los datos de la tabla contratos_exportacion
    WHERE  id = p_contrato_id;                --donde el id del contrato coincida con el id dado

    SELECT COALESCE(SUM(quintales_exportados), 0)   --obtener la suma de los quintales exportados asociados al contrato dado y asignar a la variable v_exportado, usando COALESCE para retornar 0 si no hay exportaciones
    INTO   v_exportado                              --si hay exportaciones lo almacena en la variable v_exportado
    FROM   exportaciones                            --toma los datos de la tabla exportaciones
    WHERE  contrato_id = p_contrato_id;             --donde el contrato_id coincida con el id del contrato dado

    RETURN v_pactados - v_exportado;                --retornar la diferencia entre los quintales pactados y los quintales exportados, lo que representa el saldo pendiente de exportar en el contrato
END;
$$ LANGUAGE plpgsql;


-- fn_clasificar_socio
-- Retorna el tipo A, B o C segun la puntuacion de la evaluacion.
CREATE OR REPLACE FUNCTION fn_clasificar_socio(p_evaluacion_id INT)
RETURNS tipo_asociacion_enum AS $$                                         --retorna un valor del tipo de dato enum tipo_asociacion_enum
DECLARE
    v_puntuacion DECIMAL(5,2);                                             --variable para guardar la puntuacion
BEGIN
    SELECT puntuacion_tecnica INTO v_puntuacion                            --obtener la puntuacion_tecnica de la evaluacion tecnica dada y asignar a la variable v_puntuacion
    FROM   evaluaciones_tecnicas                                           --de la tabla evaluaciones_tecnicas
    WHERE  id = p_evaluacion_id;                                           --donde el id de la evaluacion coincida con el id dado

    IF v_puntuacion IS NULL THEN                                           --si no se encuentra la evaluacion o la puntuacion es null, lanzar excepcion
        RAISE EXCEPTION 'Evaluacion % no encontrada.', p_evaluacion_id;
    END IF;

    IF    v_puntuacion >= 80 THEN RETURN 'A'::tipo_asociacion_enum;        --si la puntuacion es 80 o mas, retornar 'A' como tipo de asociacion
    ELSIF v_puntuacion >= 60 THEN RETURN 'B'::tipo_asociacion_enum;        --si la puntuacion es entre 60 y 79.99, retornar 'B' como tipo de asociacion
    ELSE                          RETURN 'C'::tipo_asociacion_enum;        --si la puntuacion es menor a 60, retornar 'C' como tipo de asociacion   
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- SECCION 14: VISTAS
-- ============================================================

-- v_resumen_temporada
-- Total de quintales por semana, tipo de cafe y categoria (socio/externo)
CREATE OR REPLACE VIEW v_resumen_temporada AS
SELECT                                                                                   --busca el resumen de la temporada actual
    DATE_TRUNC('week', r.fecha_recibo)::DATE             AS semana,                      --hace un truncamiento de la fecha del recibo a la semana, para agrupar por semana
    tc.nombre                                             AS tipo_cafe,                  --obtiene el nombre del tipo de cafe a partir de la tabla tipos_cafe
    CASE WHEN s.id IS NOT NULL THEN 'socio' ELSE 'externo' END AS categoria_productor,   --determina la categoria del productor (socio o externo) basado en si tiene un registro activo en la tabla socios
    COUNT(r.id)                                           AS total_recibos,              --cuenta el total de recibos para cada grupo
    COALESCE(SUM(r.peso_neto_qq), 0)                     AS total_quintales,             --suma el peso neto en quintales de los recibos para cada grupo, usando COALESCE para retornar 0 si no hay recibos
    COALESCE(SUM(f.monto_total), 0)                      AS monto_total_pagado           --suma el monto total pagado en las facturas asociadas a los recibos para cada grupo, usando COALESCE para retornar 0 si no hay facturas
FROM recibos r                                                                           --de la tabla recibos con alias r
JOIN tipos_cafe       tc ON tc.id = r.tipo_cafe_id                                       --unir con la tabla tipos_cafe para obtener el nombre del tipo de cafe, usando el tipo_cafe_id del recibo
JOIN productores      pr ON pr.id = r.productor_id                                       --unir con la tabla productores para obtener el productor asociado al recibo, usando el productor_id del recibo
LEFT JOIN socios       s ON s.productor_id = pr.id AND s.estado_membresia = 'activo'     --unir con la tabla socios para determinar si el productor es socio activo, usando el productor_id del productor y filtrando por estado de membresia activo, usando LEFT JOIN para incluir productores que no son socios
LEFT JOIN facturas_compra f ON f.recibo_id = r.id                                        --unir con la tabla facturas_compra para obtener las facturas asociadas a los recibos, usando el recibo_id de la factura, usando LEFT JOIN para incluir recibos que no tienen factura asociada
-- Temporada activa: diciembre-mayo del ciclo vigente
WHERE r.fecha_recibo BETWEEN (                                                           --aqui busca donde
        CASE WHEN EXTRACT(MONTH FROM CURRENT_DATE) >= 6                                  --si el mes actual es junio o despues
             THEN DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '11 months'                --entonces la temporada activa empieza en diciembre del año anterior
             ELSE DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 month'                  --si el mes actual es antes de junio, entonces la temporada activa empieza en diciembre del año anterior
        END
      )
      AND (                                                                                    --y
        CASE WHEN EXTRACT(MONTH FROM CURRENT_DATE) >= 6                                        --si el mes actual es junio o despues
             THEN DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '16 months' - INTERVAL '1 day'   --entonces la temporada activa termina el 30 de mayo del año siguiente
             ELSE DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '4 months' + INTERVAL '30 days'  --si el mes actual es antes de junio, entonces la temporada activa termina el 30 de mayo del mismo año
        END
      )
GROUP BY DATE_TRUNC('week', r.fecha_recibo), tc.nombre,                                        --agrupa por semana, tipo de cafe y categoria del productor
         CASE WHEN s.id IS NOT NULL THEN 'socio' ELSE 'externo' END                            --para asegurar que la categoria del productor se mantenga consistente en el GROUP BY
ORDER BY semana, tipo_cafe;                                                                    --ordenar por semana y tipo de cafe


-- v_saldo_bodegas
-- Saldo actual por bodega, tipo de cafe y clasificacion
CREATE OR REPLACE VIEW v_saldo_bodegas AS
SELECT                                                                               --seleccion de campos para mostrar el saldo actual en las bodegas
    b.codigo                                              AS codigo_bodega,          --codigo de la bodega
    b.nombre                                              AS bodega,                 --nombre de la bodega
    m.nombre                                              AS municipio,              --nombre del municipio donde se encuentra la bodega, obtenida a traves de la relacion con la tabla municipios
    b.es_central,                                                                    --indica si la bodega es central o no
    tc.nombre                                             AS tipo_cafe,              --nombre del tipo de cafe, obtenida a traves de la relacion con la tabla tipos_cafe
    cc.nombre                                             AS clasificacion,          --nombre de la clasificacion del cafe, obtenida a traves de la relacion con la tabla clasificaciones_cafe, puede ser null si no hay clasificacion
    ic.cantidad_qq                                        AS quintales_disponibles,  --quintales disponibles en la bodega para el tipo de cafe y clasificacion, obtenido de la tabla inventario_cafe
    b.capacidad_qq,                                                                  --capacidad total de la bodega en quintales, obtenida de la tabla bodegas
    ROUND(ic.cantidad_qq / NULLIF(b.capacidad_qq, 0) * 100, 2) AS pct_ocupacion      --porcentaje de ocupacion de la bodega para el tipo de cafe y clasificacion
                                                                                     -- calculado como la cantidad de quintales disponible dividido por la capacidad total de la bodega, 
                                                                                     -- multiplicado por 100 y redondeado a 2 decimales, usando NULLIF para evitar division por cero
FROM inventario_cafe ic                                                              --todo esto se obtiene de la tabla inventario_cafe con alias ic
JOIN bodegas          b  ON b.id  = ic.bodega_id                                     --que une con bodegas para obtener info de la bodega, usando el bodega_id del inventario
JOIN tipos_cafe       tc ON tc.id = ic.tipo_cafe_id                                  --que une con tipos_cafe para obtener el nombre del tipo de cafe, usando el tipo_cafe_id del inventario
LEFT JOIN clasificaciones_cafe cc ON cc.id = ic.clasificacion_id                     --que une con clasificaciones_cafe para obtener el nombre de la clasificacion, usando el clasificacion_id del inventario
JOIN  cooperativas          c  ON c.id  = b.cooperativa_id                                   --que une con municipios para saber el municipio donde esta la bodega
JOIN  municipios            m  ON m.id  = c.municipio_id
WHERE ic.cantidad_qq > 0                                                             --filtra para mostrar solo los registros donde hay cantidad disponible en la bodega
ORDER BY b.nombre, tc.nombre, cc.nombre;                                             --ordenar por nombre de bodega, tipo de cafe y clasificacion


-- v_socios_activos_terrenos
-- Socios activos con numero de terrenos aprobados y area total
CREATE OR REPLACE VIEW v_socios_activos_terrenos AS
SELECT                                                                                  --seleccion de campos para mostrar los socios activos con informacion de sus terrenos
    pr.nombre || ' ' || pr.apellido        AS productor,                                --nombre completo del productor, concatenando el nombre y apellido de la tabla productores
    s.id                                   AS socio_id,                                 --id del socio, obtenido de la tabla socios
    s.tipo_asociacion,                                                                  --tipo de asociacion del socio, obtenido de la tabla socios
    s.estado_membresia,                                                                 --estado de membresia del socio, obtenido de la tabla socios
    COUNT(DISTINCT t.id)                   AS numero_terrenos,                          --numero de terrenos asociados al productor que tienen una evaluacion tecnica aprobada, contando los id distintos de la tabla terrenos con alias t
    COALESCE(SUM(t.area_estimada_cuerdas), 0) AS area_total_estimada,                   --suma el area estimada de los terrenos asociados al productor, usando COALESCE para retornar 0 si no hay terrenos
    COALESCE(SUM(t.area_calculada_cuerdas), 0) AS area_total_calculada                  --suma el area calculada de los terrenos asociados al productor, usando COALESCE para retornar 0 si no hay terrenos
FROM socios s                                                                           --todo viene de la tabla socios con alias s
JOIN productores pr ON pr.id = s.productor_id                                           --que une con productores para obtener la informacion del productor asociado al socio, usando el productor_id del socio
LEFT JOIN terrenos t ON t.productor_id = pr.id                                          --que une con terrenos para obtener la informacion de los terrenos asociados al productor, usando el productor_id del terreno, usando LEFT JOIN para incluir socios que no tienen terrenos
LEFT JOIN evaluaciones_tecnicas et ON et.terreno_id = t.id AND et.estado = 'aprobada'   --que une con evaluaciones_tecnicas para filtrar solo los terrenos que tienen una evaluacion tecnica aprobada, usando el terreno_id del terreno y filtrando por estado de evaluacion aprobado, usando LEFT JOIN para incluir terrenos que no tienen evaluacion aprobada
WHERE s.estado_membresia = 'activo'                                                     --donde el estado de membresia del socio sea activo, para mostrar solo socios activos
GROUP BY pr.nombre, pr.apellido, s.id, s.tipo_asociacion, s.estado_membresia            --ordena por nombre y apellido del productor y agrupa por los campos del socio para obtener el conteo y sumas por cada socio
ORDER BY pr.apellido, pr.nombre;                                                        --ordenar por apellido y nombre del productor


-- v_pagos_pendientes
-- Facturas con saldo pendiente de liquidacion
CREATE OR REPLACE VIEW v_pagos_pendientes AS
SELECT                                                                               --seleccion de campos para mostrar las facturas de compra que tienen saldo pendiente de pago
    f.numero                                              AS factura,                --numero de la factura de compra, obtenido de la tabla facturas_compra con alias f
    f.fecha_factura,                                                                 --fecha de la factura, obtenido de la tabla facturas_compra
    pr.nombre || ' ' || pr.apellido                       AS productor,              --nombre completo del productor, concatenando el nombre y apellido de la tabla productores con alias pr
    CASE WHEN s.id IS NOT NULL THEN 'Socio' ELSE 'Externo' END AS categoria,         --donde la cat del produc se determina por si tiene un registro activo en la tabla socios
    f.quintales_netos,                                                               --quintales netos de la factura, obtenido de la tabla facturas_compra
    f.precio_unitario,                                                               --precio unitario de la factura, obtenido de la tabla facturas_compra
    f.monto_total,                                                                   --monto total de la factura, obtenido de la tabla facturas_compra
    COALESCE(f.anticipo, 0)                               AS anticipo_entregado,     --anticipo entregado para la factura, usando COALESCE para retornar 0 si no hay anticipo registrado en la factura
    f.saldo_pagar,                                                                   --saldo pendiente de pago para la factura, obtenido de la tabla facturas_compra
    f.forma_pago,                                                                    --forma de pago acordada en la factura, obtenido de la tabla facturas_compra
    f.estado                                                                         --estado de la factura, obtenido de la tabla facturas_compra
FROM facturas_compra f                                                               --toda sale de la tabla facturas_compra con alias f
JOIN recibos     r  ON r.id  = f.recibo_id                                           --que une con recibos para obtener la informacion del recibo asociado a la factura, usando el recibo_id de la factura
JOIN productores pr ON pr.id = r.productor_id                                        --tambien une con productores para obtener la informacion del productor asociado al recibo, usando el productor_id del recibo
LEFT JOIN socios s  ON s.productor_id = pr.id                                        --tambien une con socios para determinar la categoria del productor socio o externo, usando el productor_id del productor
WHERE f.estado = 'pendiente'                                                         --dondes estado es pendinte
  AND f.saldo_pagar > 0                                                              --y el saldo pendiente sea mayor a 0
ORDER BY f.fecha_factura;                                                            --ordenar por fecha de factura


-- v_contratos_avance
-- Por contrato vigente: pactado, exportado, pendiente y % cumplimiento
CREATE OR REPLACE VIEW v_contratos_avance AS
SELECT                                                                                         --seleccion de campos para mostrar el avance de los contratos de exportacion vigentes
    c.numero                                              AS contrato,                         --numero del contrato de exportacion, obtenido de la tabla contratos_exportacion con alias c
    e.nombre                                              AS empresa,                          --nombre de la empresa extranjera asociada al contrato, obtenido de la tabla empresas_extranjeras con alias e
    e.pais,                                                                                    --pais de la empresa extranjera, obtenido de la tabla empresas_extranjeras
    c.qq_totales_pactados                                 AS quintales_pactados,               --quintales totales pactados en el contrato, obtenido de la tabla contratos_exportacion
    COALESCE(SUM(exp.quintales_exportados), 0)            AS quintales_exportados,             --suma de los quintales exportados asociados al contrato, usando COALESCE para retornar 0 si no hay exportaciones
    c.qq_totales_pactados - COALESCE(SUM(exp.quintales_exportados), 0) AS quintales_pendientes,--calcula los quintales pendientes de exportar restando los quintales exportados de los quintales pactados
    ROUND(
        COALESCE(SUM(exp.quintales_exportados), 0)                                             --calcula el porcentaje de cumplimiento del contrato dividiendo los quintales exportados entre los quintales pactados, multiplicando por 100 y redondeando a 2 decimales, usando COALESCE para retornar 0 si no hay exportaciones y NULLIF para evitar division por cero
        / NULLIF(c.qq_totales_pactados, 0) * 100, 2
    )                                                     AS porcentaje_cumplimiento,          --porcentaje de cumplimiento del contrato
    c.fecha_entrega_est,                                                                       --decha estimada de entrega del contrato
    c.estado                                                                                   ---estado del contrato
FROM contratos_exportacion c                                                                   --obtenido de la tabla contratos_exportacion
JOIN empresas_extranjeras e   ON e.id = c.empresa_id                                           --que une con empresas_extranjeras para obtener la informacion de la empresa asociada al contrato, usando el empresa_id del contrato
LEFT JOIN exportaciones   exp ON exp.contrato_id = c.id                                        --que une con exportaciones para obtener la informacion de las exportaciones asociadas al contrato, usando el contrato_id del contrato
WHERE c.estado = 'vigente'                                                                     --dond estado es vigen te
GROUP BY c.numero, e.nombre, e.pais,                                                           --agrupa los resultados por los campos seleccionados
         c.qq_totales_pactados, c.fecha_entrega_est, c.estado                                  --para asegurar que los calculos de quintales exportados, pendientes y porcentaje de cumplimiento se hagan por cada contrato individualmente
ORDER BY c.numero;                                                                             --ordenar por numero de contrato


-- v_trazabilidad_lote
-- Historial completo: recibo -> procesamiento -> clasificacion -> exportacion
CREATE OR REPLACE VIEW v_trazabilidad_lote AS
SELECT                                                                              --selecion de campos para mostrar la trazabilidad completa de un lote desde el recibo hasta la exportacion
    r.numero                                              AS numero_recibo,         --numero del recibo, obtenido de la tabla recibos con alias r
    lp.codigo                                             AS codigo_lote,           --codigo del lote de procesamiento, obtenido de la tabla lotes_procesamiento con alias lp
    r.fecha_recibo,                                                                 --fecha del recibo, obtenido de la tabla recibos
    pr.nombre || ' ' || pr.apellido                       AS productor,             --nombre completo del productor, concatenando el nombre y apellido de la tabla productores con alias pr
    CASE WHEN s.id IS NOT NULL THEN 'Socio' ELSE 'Externo' END AS tipo_productor,   --tipo de productor (socio o externo) determinado por si tiene un registro activo en la tabla socios, usando el productor_id del productor para unir con socios
    tc.nombre                                             AS tipo_cafe,             --nombre del tipo de cafe, obtenido de la tabla tipos_cafe con alias tc
    r.peso_bruto_qq,                                                                --peso bruto en quintales del recibo, obtenido de la tabla recibos  
    r.peso_neto_qq,                                                                 --peso neto en quintales del recibo, obtenido de la tabla recibos
    f.monto_total,                                                                  --monto total pagado en la factura de compra asociada al recibo, obtenido de la tabla facturas_compra con alias f
    cq.puntaje_taza,                                                                --puntaje de la taza obtenido en el control de calidad asociado al recibo, obtenido de la tabla control_calidad con alias cq
    cq.es_especialidad,                                                             --indica si el cafe del recibo califico como especialidad en el control de calidad, obtenido de la tabla control_calidad
    bo.monto_total_bono                                   AS bono_especialidad,     --monto total del bono de especialidad asociado al recibo, obtenido de la tabla bonos_especialidad con alias bo
    bh.fecha                                              AS fecha_benef_humedo,    --fecha del beneficiado humedo asociado al lote, obtenido de la tabla beneficiado_humedo con alias bh
    bh.volumen_entrada_qq,                                                          --volumen de entrada en quintales al beneficiado humedo, obtenido de la tabla beneficiado_humedo
    bh.merma_kg,                                                                    --merma en kg del beneficiado humedo, obtenido de la tabla beneficiado_humedo
    sec.metodo                                            AS metodo_secado,         --metodo de secado utilizado en el secado asociado al lote, obtenido de la tabla secado con alias sec
    sec.dias_empleados,                                                             --dias empleados en el secado, obtenido de la tabla secado
    bs.fecha                                              AS fecha_benef_seco,      --fecha del beneficiado seco asociado al lote, obtenido de la tabla beneficiado_seco con alias bs                                                                   --merma en kg del beneficiado seco, obtenido de la tabla beneficiado_seco
    bs.qq_oro_resultado,                                                            --quintales de cafe oro resultado del beneficiado seco, obtenido de la tabla beneficiado_seco
    bs.porcentaje_rendimiento,                                                      --aqui esta el porcentaje de rendimiento del beneficiado seco calculado como los quintales de cafe oro resultado dividido por el volumen de entrada al beneficiado seco, multiplicado por 100 y redondeado a 2 decimales
    cc.nombre                                             AS clasificacion_final,   --nombre de la clasificacion final del lote, obtenido de la tabla clasificaciones_cafe con alias cc, puede ser null si el lote no tiene clasificacion
    cl.cantidad_qq                                        AS quintales_clasificados,--cantidad de quintales clasificados en la clasificacion del lote, obtenido de la tabla clasificaciones_lote con alias cl
    t_cod.codigo                                          AS terreno_origen,        --codigo de terreno de origen del cafe, obtenido de la tabla terrenos con alias t_cod, usando el productor_id del productor para unir con terrenos
    mu.nombre                                             AS municipio_origen,      --nombre del municipio de origen del cafe, obtenido de la tabla municipios con alias mu, usando el municipio_id del terreno para unir con municipios
    exp.numero                                            AS numero_exportacion,    --numero de exportaciones del lote
    emp.nombre                                            AS empresa_destino,       --nombre de la empresa extranjera detino del lote
    emp.pais                                              AS pais_destino           --empresa nacional
FROM recibos r                                                                      --de la tabla recibos con alias r
JOIN productores      pr  ON pr.id  = r.productor_id                --que une con productores para obtener la informacion del productor asociado al recibo, usando el productor_id del recibo
JOIN tipos_cafe       tc  ON tc.id  = r.tipo_cafe_id                --que une con tipos_cafe para obtener el nombre del tipo de cafe, usando el tipo_cafe_id del recibo
LEFT JOIN socios       s   ON s.productor_id = pr.id                --que une con socios para determinar la categoria del productor socio o externo, usando el productor_id del productor
LEFT JOIN facturas_compra f ON f.recibo_id = r.id                   --que une con facturas_compra para obtener la informacion de las facturas de compra asociadas al recibo
LEFT JOIN control_calidad cq ON cq.recibo_id = r.id                 --que une con control_calidad para obtener la informacion del control de calidad asociado al recibo
LEFT JOIN bonos_especialidad bo ON bo.recibo_id = r.id              --que une con bonos_especialidad para obtener la informacion del bono de especialidad asociado al recibo
LEFT JOIN lotes_procesamiento lp ON lp.recibo_id = r.id             --que une con lotes_procesamiento para obtener la informacion del lote de procesamiento asociado al recibo
LEFT JOIN beneficiado_humedo  bh  ON bh.lote_id = lp.id             --que une con beneficiado_humedo para obtener la informacion del beneficiado humedo asociado al lote
LEFT JOIN secado             sec  ON sec.lote_id = lp.id            --que une con secado para obtener la informacion del secado asociado al lote
LEFT JOIN beneficiado_seco    bs  ON bs.lote_id = lp.id             --que une con beneficiado_seco para obtener la informacion del beneficiado seco asociado al lote
LEFT JOIN clasificaciones_lote cl ON cl.lote_id = lp.id             --que une con clasificaciones_lote para obtener la informacion de la clasificacion del lote
LEFT JOIN clasificaciones_cafe cc ON cc.id = cl.clasificacion_id    --que une con clasificaciones_cafe para obtener el nombre de la clasificacion del cafe
LEFT JOIN terrenos t_cod ON t_cod.productor_id = pr.id              --que une con terrenos para obtener la informacion del terreno de origen del cafe
LEFT JOIN municipios  mu  ON mu.id = t_cod.municipio_id             --que une con municipios para obtener la informacion del municipio de origen del cafe
LEFT JOIN exportaciones exp ON exp.contrato_id IN (                 --que une con exportaciones para obtener la informacion de las exportaciones asociadas al lote
    SELECT cd.contrato_id FROM contrato_detalle cd                  --que une con contrato_detalle para obtener los contratos asociados a la clasificacion del lote
    WHERE cd.clasificacion_id = cl.clasificacion_id                 --y cd.cantidad_qq = cl.cantidad_qq            
)
LEFT JOIN contratos_exportacion ce ON ce.id = exp.contrato_id       --que une con contratos_exportacion para obtener la informacion del contrato asociado a la exportacion
LEFT JOIN empresas_extranjeras emp ON emp.id = ce.empresa_id        --que une con empresas_extranjeras para obtener la informacion de la empresa extranjera destino del lote
ORDER BY r.numero, cc.nombre;                                       --ordenar por numero de recibo y nombre de clasificacion


-- v_rendimiento_terrenos
-- Por terreno: total cafe entregado, clasificaciones y si genero especialidad

--Esto se logra mediante la siguiente consulta que une varias tablas para obtener la informacion de los terrenos, productores,
-- recibos, controles de calidad, clasificaciones y bonos de especialidad asociados a cada terreno, y luego agrupa por terreno 
--para calcular el total de cafe entregado, las clasificaciones obtenidas y si genero cafe de especialidad
CREATE OR REPLACE VIEW v_rendimiento_terrenos AS
SELECT                                                                                  --seleccion de campos para mostrar el rendimiento de los terrenos, incluyendo el total de cafe entregado, las clasificaciones obtenidas y si genero especialidad
    t.codigo                                              AS codigo_terreno,            --codigo del terreno, obtenido de la tabla terrenos con alias t
    t.nombre                                              AS terreno,                   --nombre del terreno, obtenido de la tabla terrenos
    m.nombre                                              AS municipio,                 --nombre del municipio donde se encuentra el terreno, obtenido de la tabla municipios con alias m
    pr.nombre || ' ' || pr.apellido                       AS productor,                 --nombre completo del productor, concatenando el nombre y apellido de la tabla productores con alias pr
    s.tipo_asociacion,                                                                  --tipo de asociacion del socio, obtenido de la tabla socios con alias s, puede ser null si el productor no es socio
    t.area_estimada_cuerdas,                                                            --area estimada del terreno en cuerdas, obtenido de la tabla terrenos
    COUNT(DISTINCT r.id)                                  AS total_recibos,             --conteo de los recibos asociados al terreno, contando los id distintos de la tabla recibos con alias r
    COALESCE(SUM(r.peso_neto_qq), 0)                      AS total_quintales,           --suma del peso neto en quintales de los recibos asociados al terreno, usando COALESCE para retornar 0 si no hay recibos
    STRING_AGG(DISTINCT cc.nombre::TEXT, ', ')            AS clasificaciones_obtenidas, --agrega en una cadena de texto separada por comas las clasificaciones obtenidas por los lotes asociados al terreno, usando STRING_AGG para concatenar los nombres de las clasificaciones distintas obtenidas de la tabla clasificaciones_cafe con alias cc, puede ser null si no hay clasificaciones
    COALESCE(BOOL_OR(cq.es_especialidad), FALSE)          AS genero_especialidad,       --determina si el terreno genero cafe de especialidad basado en si alguno de los controles de calidad asociados a los recibos del terreno califico como especialidad, usando BOOL_OR para retornar true si al menos uno es especialidad, y COALESCE para retornar false si no hay controles de calidad
    COALESCE(SUM(bo.monto_total_bono), 0)                 AS total_bonos                --suma del monto total de los bonos de especialidad asociados a los recibos del terreno, usando COALESCE para retornar 0 si no hay bonos
FROM terrenos t                                                        --de la tabla terrenos con alias t
JOIN municipios  m  ON m.id  = t.municipio_id                          --que une con municipios para obtener la informacion del municipio donde se encuentra el terreno, usando el municipio_id del terreno
JOIN productores pr ON pr.id = t.productor_id                          --que une con productores para obtener la informacion del productor asociado al terreno, usando el productor_id del terreno
LEFT JOIN socios  s  ON s.productor_id = pr.id                         --que une con socios para determinar la categoria del productor socio o externo, usando el productor_id del productor
LEFT JOIN recibos  r  ON r.productor_id = pr.id                        --que une con recibos para obtener la informacion de los recibos asociados al terreno, usando el productor_id del productor para unir con recibos
LEFT JOIN control_calidad cq ON cq.recibo_id = r.id                    --que une con control_calidad para obtener la informacion del control de calidad asociado a los recibos del terreno, usando el recibo_id del recibo para unir con control_calidad
LEFT JOIN bonos_especialidad bo ON bo.recibo_id = r.id                 --que une con bonos_especialidad para obtener la informacion de los bonos de especialidad asociados a los recibos del terreno, usando el recibo_id del recibo para unir con bonos_especialidad
LEFT JOIN lotes_procesamiento lp ON lp.recibo_id = r.id                --que une con lotes_procesamiento para obtener la informacion de los lotes de procesamiento asociados a los recibos del terreno, usando el recibo_id del recibo para unir con lotes_procesamiento
LEFT JOIN clasificaciones_lote cl ON cl.lote_id = lp.id                --que une con clasificaciones_lote para obtener la informacion de las clasificaciones asociadas a los lotes de procesamiento, usando el lote_id del lote para unir con clasificaciones_lote
LEFT JOIN clasificaciones_cafe cc ON cc.id = cl.clasificacion_id       --que une con clasificaciones_cafe para obtener la informacion de las clasificaciones de cafe, usando el id de la clasificacion para unir con clasificaciones_cafe
GROUP BY t.codigo, t.nombre, m.nombre, pr.nombre, pr.apellido,         --agrupa por los campos del terreno, municipio, productor y tipo de asociacion para obtener el conteo y sumas por cada terreno individualmente
         s.tipo_asociacion, t.area_estimada_cuerdas
ORDER BY total_quintales DESC;                                         --ordenar por total de quintales entregados en orden descendente



--TRIGGERS

-- TRIGGER 1: trg_auditoria_empleados
-- AFTER UPDATE: registra usuario, fecha, campo, valor anterior y nuevo
CREATE OR REPLACE FUNCTION fn_trg_auditoria_empleados()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.nombre IS DISTINCT FROM NEW.nombre THEN
        INSERT INTO auditoria_empleados(empleado_id,campo_modificado,valor_anterior,valor_nuevo,fecha_cambio)
        VALUES(NEW.id,'nombre',OLD.nombre,NEW.nombre,NOW());
    END IF;
    IF OLD.apellido IS DISTINCT FROM NEW.apellido THEN
        INSERT INTO auditoria_empleados(empleado_id,campo_modificado,valor_anterior,valor_nuevo,fecha_cambio)
        VALUES(NEW.id,'apellido',OLD.apellido,NEW.apellido,NOW());
    END IF;
    IF OLD.salario_base IS DISTINCT FROM NEW.salario_base THEN
        INSERT INTO auditoria_empleados(empleado_id,campo_modificado,valor_anterior,valor_nuevo,fecha_cambio)
        VALUES(NEW.id,'salario_base',OLD.salario_base::TEXT,NEW.salario_base::TEXT,NOW());
    END IF;
    IF OLD.estado IS DISTINCT FROM NEW.estado THEN
        INSERT INTO auditoria_empleados(empleado_id,campo_modificado,valor_anterior,valor_nuevo,fecha_cambio)
        VALUES(NEW.id,'estado',OLD.estado::TEXT,NEW.estado::TEXT,NOW());
    END IF;
    IF OLD.rol_id IS DISTINCT FROM NEW.rol_id THEN
        INSERT INTO auditoria_empleados(empleado_id,campo_modificado,valor_anterior,valor_nuevo,fecha_cambio)
        VALUES(NEW.id,'rol_id',OLD.rol_id::TEXT,NEW.rol_id::TEXT,NOW());
    END IF;
    IF OLD.direccion IS DISTINCT FROM NEW.direccion THEN
        INSERT INTO auditoria_empleados(empleado_id,campo_modificado,valor_anterior,valor_nuevo,fecha_cambio)
        VALUES(NEW.id,'direccion',OLD.direccion,NEW.direccion,NOW());
    END IF;
    IF OLD.telefono IS DISTINCT FROM NEW.telefono THEN
        INSERT INTO auditoria_empleados(empleado_id,campo_modificado,valor_anterior,valor_nuevo,fecha_cambio)
        VALUES(NEW.id,'telefono',OLD.telefono,NEW.telefono,NOW());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_empleados
AFTER UPDATE ON empleados
FOR EACH ROW EXECUTE FUNCTION fn_trg_auditoria_empleados();


-- TRIGGER 2: trg_historial_rol
-- BEFORE UPDATE: cierra el historial activo y abre uno nuevo al cambiar rol
CREATE OR REPLACE FUNCTION fn_trg_historial_rol()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.rol_id IS DISTINCT FROM NEW.rol_id THEN
        UPDATE historial_roles
        SET    fecha_fin  = CURRENT_DATE,
               updated_at = NOW()
        WHERE  empleado_id = OLD.id
          AND  fecha_fin   IS NULL;

        INSERT INTO historial_roles(empleado_id, rol_id, fecha_inicio)
        VALUES (NEW.id, NEW.rol_id, CURRENT_DATE);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_historial_rol
BEFORE UPDATE ON empleados
FOR EACH ROW EXECUTE FUNCTION fn_trg_historial_rol();


-- TRIGGER 3: trg_validar_contrato
-- BEFORE INSERT en exportaciones: verifica saldo disponible del contrato
CREATE OR REPLACE FUNCTION fn_trg_validar_contrato()
RETURNS TRIGGER AS $$
DECLARE
    v_saldo DECIMAL(10,2);
BEGIN
    v_saldo := fn_saldo_contrato(NEW.contrato_id);
    IF NEW.quintales_exportados > v_saldo THEN
        RAISE EXCEPTION
            'Saldo insuficiente en contrato ID %. Disponible: % qq, Solicitado: % qq',
            NEW.contrato_id, v_saldo, NEW.quintales_exportados;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_contrato
BEFORE INSERT ON exportaciones
FOR EACH ROW EXECUTE FUNCTION fn_trg_validar_contrato();


-- TRIGGER 4: trg_actualizar_inventario_recibo
-- AFTER INSERT en recibos: incrementa el inventario de la bodega receptora
CREATE OR REPLACE FUNCTION fn_trg_actualizar_inventario_recibo()
RETURNS TRIGGER AS $$
BEGIN
    -- Upsert en inventario_cafe (sin clasificacion aun, cafe sin procesar)
    INSERT INTO inventario_cafe(bodega_id, tipo_cafe_id, clasificacion_id, cantidad_qq, ultima_actualizacion)
    VALUES (NEW.bodega_id, NEW.tipo_cafe_id, NULL, NEW.peso_neto_qq, NOW())
    ON CONFLICT (bodega_id, tipo_cafe_id, clasificacion_id)
    DO UPDATE SET cantidad_qq          = inventario_cafe.cantidad_qq + NEW.peso_neto_qq,
                  ultima_actualizacion = NOW(),
                  updated_at           = NOW();

    -- Registrar movimiento
    INSERT INTO movimientos_inventario(
        bodega_id, tipo_cafe_id, clasificacion_id, tipo_movimiento,
        cantidad_qq, referencia_id, responsable_id, fecha
    )
    VALUES(
        NEW.bodega_id, NEW.tipo_cafe_id, NULL, 'entrada_recibo',
        NEW.peso_neto_qq, NEW.id, NEW.bodeguero_id, NOW()
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_inventario_recibo
AFTER INSERT ON recibos
FOR EACH ROW EXECUTE FUNCTION fn_trg_actualizar_inventario_recibo();


-- TRIGGER 5: trg_bono_especialidad
-- AFTER INSERT en control_calidad: si puntaje >= 80 genera el bono automaticamente
CREATE OR REPLACE FUNCTION fn_trg_bono_especialidad()
RETURNS TRIGGER AS $$
DECLARE
    v_config        bonos_especialidad_config%ROWTYPE;
    v_quintales     DECIMAL(10,2);
    v_fecha_recibo  DATE;
BEGIN
    IF NEW.puntaje_taza >= 80 THEN
        -- Marcar como especialidad
        UPDATE control_calidad
        SET    es_especialidad = TRUE, updated_at = NOW()
        WHERE  id = NEW.id;

        -- Obtener datos del recibo
        SELECT peso_neto_qq, fecha_recibo
        INTO   v_quintales, v_fecha_recibo
        FROM   recibos WHERE id = NEW.recibo_id;

        -- Obtener configuracion de bono vigente
        SELECT * INTO v_config
        FROM   bonos_especialidad_config
        WHERE  NEW.puntaje_taza BETWEEN puntaje_min AND puntaje_max
          AND  v_fecha_recibo BETWEEN temporada_inicio AND temporada_fin
        ORDER BY temporada_inicio DESC
        LIMIT 1;

        IF v_config.id IS NOT NULL AND v_quintales IS NOT NULL THEN
            INSERT INTO bonos_especialidad(
                recibo_id, config_bono_id, quintales,
                bono_por_quintal, monto_total_bono, pagado
            )
            VALUES(
                NEW.recibo_id,
                v_config.id,
                v_quintales,
                v_config.bono_quintal,
                ROUND(v_config.bono_quintal * v_quintales, 2),
                FALSE
            )
            ON CONFLICT (recibo_id) DO UPDATE
               SET monto_total_bono = ROUND(v_config.bono_quintal * v_quintales, 2),
                   updated_at       = NOW();
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bono_especialidad
AFTER INSERT ON control_calidad
FOR EACH ROW EXECUTE FUNCTION fn_trg_bono_especialidad();


-- TRIGGER 6: trg_prevent_delete_socio_activo
-- BEFORE DELETE en socios: impide eliminar socio con recibos en temporada activa
CREATE OR REPLACE FUNCTION fn_trg_prevent_delete_socio_activo()
RETURNS TRIGGER AS $$
DECLARE
    v_tiene_recibos BOOLEAN;
    v_temp_inicio   DATE;
    v_temp_fin      DATE;
BEGIN
    -- Determinar temporada activa segun bonos_especialidad_config
    SELECT temporada_inicio, temporada_fin
    INTO   v_temp_inicio, v_temp_fin
    FROM   bonos_especialidad_config
    WHERE  CURRENT_DATE BETWEEN temporada_inicio AND temporada_fin
    ORDER BY temporada_inicio DESC LIMIT 1;

    -- Si no hay config, usar logica de dic-mayo
    IF v_temp_inicio IS NULL THEN
        v_temp_inicio := (DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 month')::DATE;
        v_temp_fin    := (DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '4 months 30 days')::DATE;
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM recibos r
        WHERE  r.productor_id = OLD.productor_id
          AND  r.fecha_recibo BETWEEN v_temp_inicio AND v_temp_fin
    ) INTO v_tiene_recibos;

    IF v_tiene_recibos THEN
        RAISE EXCEPTION
            'No se puede eliminar el socio % porque tiene entregas en la temporada activa.',
            OLD.id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_delete_socio_activo
BEFORE DELETE ON socios
FOR EACH ROW EXECUTE FUNCTION fn_trg_prevent_delete_socio_activo();


-- TRIGGER 7: trg_log_precios
-- AFTER INSERT OR UPDATE en precios_cafe: registra historial de precios
CREATE OR REPLACE FUNCTION fn_trg_log_precios()
RETURNS TRIGGER AS $$
DECLARE
    v_abs DECIMAL(10,2);
    v_pct DECIMAL(6,2);
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO log_precios(
            precio_id, tipo_cafe_id,
            precio_anterior, precio_nuevo,
            variacion_abs, variacion_pct,
            usuario_bd,        -- <-- faltaba este
            fecha_cambio
        )
        VALUES (NEW.id, NEW.tipo_cafe_id, NULL, NEW.precio_quintal, NULL, NULL, 1, NOW());

    ELSIF TG_OP = 'UPDATE' AND OLD.precio_quintal IS DISTINCT FROM NEW.precio_quintal THEN
        v_abs := ROUND(NEW.precio_quintal - OLD.precio_quintal, 2);
        v_pct := ROUND((NEW.precio_quintal - OLD.precio_quintal)
                       / NULLIF(OLD.precio_quintal, 0) * 100, 2);

        INSERT INTO log_precios(
            precio_id, tipo_cafe_id,
            precio_anterior, precio_nuevo,
            variacion_abs, variacion_pct,
            usuario_bd,        -- <-- faltaba este
            fecha_cambio
        )
        VALUES (NEW.id, NEW.tipo_cafe_id,
                OLD.precio_quintal, NEW.precio_quintal,
                v_abs, v_pct, 1, NOW());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_precios
AFTER INSERT OR UPDATE ON precios_cafe
FOR EACH ROW EXECUTE FUNCTION fn_trg_log_precios();



--PROCEDIMIENTOS ALMACENADOS

-- sp_registrar_recibo
-- Registra entrega de cafe, genera factura y actualiza inventario
CREATE OR REPLACE PROCEDURE sp_registrar_recibo(
    p_numero          VARCHAR,
    p_bodega_id       INT,
    p_productor_id    INT,
    p_bodeguero_id    INT,
    p_supervisor_id   INT,
    p_tipo_cafe       tipo_cafe_enum,
    p_peso_bruto_qq   DECIMAL,
    p_peso_neto_qq    DECIMAL,
    p_fecha_recibo    DATE,
    p_hora_recibo     TIME,
    p_contador_id     INT,
    p_forma_pago      forma_pago_enum DEFAULT 'efectivo',
    p_anticipo        DECIMAL         DEFAULT 0,
    p_banco           VARCHAR         DEFAULT NULL,
    p_num_cheque      VARCHAR         DEFAULT NULL,
    p_fecha_cheque    DATE            DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_recibo_id    INT;
    v_precio       DECIMAL(10,2);
    v_monto_total  DECIMAL(12,2);
    v_saldo_pagar  DECIMAL(12,2);
    v_tipo_id      INT;
    v_num_factura  VARCHAR(20);
BEGIN
    -- Validar que el productor existe
    IF NOT EXISTS (SELECT 1 FROM productores WHERE id = p_productor_id) THEN
        RAISE EXCEPTION 'Productor % no existe.', p_productor_id;
    END IF;

    SELECT id INTO v_tipo_id FROM tipos_cafe WHERE nombre = p_tipo_cafe;

    -- Calcular precio con fn_precio_compra
    v_precio      := fn_precio_compra(p_productor_id, p_tipo_cafe, p_fecha_recibo);
    v_monto_total := ROUND(p_peso_neto_qq * v_precio, 2);
    v_saldo_pagar := v_monto_total - COALESCE(p_anticipo, 0);

    -- Insertar recibo (dispara trg_actualizar_inventario_recibo)
    INSERT INTO recibos(numero, bodega_id, productor_id, bodeguero_id, supervisor_id,
                        tipo_cafe_id, peso_bruto_qq, peso_neto_qq, fecha_recibo, hora_recibo)
    VALUES (p_numero, p_bodega_id, p_productor_id, p_bodeguero_id, p_supervisor_id,
            v_tipo_id, p_peso_bruto_qq, p_peso_neto_qq, p_fecha_recibo, p_hora_recibo)
    RETURNING id INTO v_recibo_id;

    v_num_factura := 'F-' || LPAD(v_recibo_id::TEXT, 6, '0');

    -- Generar factura
    INSERT INTO facturas_compra(
        numero, recibo_id, contador_id, fecha_factura,
        quintales_netos, precio_unitario, monto_total,
        anticipo, saldo_pagar, forma_pago,
        banco, num_cheque, fecha_cheque, estado
    )
    VALUES(
        v_num_factura, v_recibo_id, p_contador_id, p_fecha_recibo,
        p_peso_neto_qq, v_precio, v_monto_total,
        COALESCE(p_anticipo,0), v_saldo_pagar, p_forma_pago,
        p_banco, p_num_cheque, p_fecha_cheque, 'pendiente'
    );

    RAISE NOTICE 'Recibo % registrado. Factura % generada. Total: Q% / Saldo: Q%',
                 v_recibo_id, v_num_factura, v_monto_total, v_saldo_pagar;
END;
$$;


-- sp_trasladar_cafe
-- Valida disponibilidad, registra traslado y actualiza inventarios
CREATE OR REPLACE PROCEDURE sp_trasladar_cafe(
    p_numero                VARCHAR,
    p_bodega_origen_id      INT,
    p_bodega_destino_id     INT,
    p_clasificacion_id      INT,
    p_tipo_cafe_id          INT,
    p_cantidad_qq           DECIMAL,
    p_transportista_id      INT,
    p_vehiculo_id           INT,
    p_bodeguero_despacha_id INT,
    p_nota_contable         VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_saldo DECIMAL(10,2);
BEGIN
    -- Verificar saldo en bodega origen
    SELECT cantidad_qq INTO v_saldo
    FROM   inventario_cafe
    WHERE  bodega_id     = p_bodega_origen_id
      AND  tipo_cafe_id  = p_tipo_cafe_id
      AND  clasificacion_id IS NOT DISTINCT FROM p_clasificacion_id;

    IF COALESCE(v_saldo, 0) < p_cantidad_qq THEN
        RAISE EXCEPTION 'Saldo insuficiente en bodega origen. Disponible: % qq', COALESCE(v_saldo,0);
    END IF;

    -- Insertar traslado
    INSERT INTO traslados(
        numero, bodega_origen_id, bodega_destino_id, clasificacion_id,
        cantidad_qq, transportista_id, vehiculo_id,
        bodeguero_despacha_id, nota_contable,
        fecha_salida, estado
    )
    VALUES(
        p_numero, p_bodega_origen_id, p_bodega_destino_id, p_clasificacion_id,
        p_cantidad_qq, p_transportista_id, p_vehiculo_id,
        p_bodeguero_despacha_id, p_nota_contable,
        NOW(), 'en_transito'
    );

    -- Descontar de bodega origen
    UPDATE inventario_cafe
    SET    cantidad_qq          = cantidad_qq - p_cantidad_qq,
           ultima_actualizacion = NOW(),
           updated_at           = NOW()
    WHERE  bodega_id       = p_bodega_origen_id
      AND  tipo_cafe_id    = p_tipo_cafe_id
      AND  clasificacion_id IS NOT DISTINCT FROM p_clasificacion_id;

    -- Asiento contable salida
    INSERT INTO movimientos_inventario(
        bodega_id, tipo_cafe_id, clasificacion_id, tipo_movimiento,
        cantidad_qq, responsable_id, fecha
    )
    VALUES(
        p_bodega_origen_id, p_tipo_cafe_id, p_clasificacion_id, 'salida_traslado',
        p_cantidad_qq, p_bodeguero_despacha_id, NOW()
    );

    -- Acreditar en bodega destino
    INSERT INTO inventario_cafe(bodega_id, tipo_cafe_id, clasificacion_id, cantidad_qq, ultima_actualizacion)
    VALUES (p_bodega_destino_id, p_tipo_cafe_id, p_clasificacion_id, p_cantidad_qq, NOW())
    ON CONFLICT (bodega_id, tipo_cafe_id, clasificacion_id)
    DO UPDATE SET cantidad_qq          = inventario_cafe.cantidad_qq + p_cantidad_qq,
                  ultima_actualizacion = NOW(),
                  updated_at           = NOW();

    -- Asiento contable entrada
    INSERT INTO movimientos_inventario(
        bodega_id, tipo_cafe_id, clasificacion_id, tipo_movimiento,
        cantidad_qq, responsable_id, fecha
    )
    VALUES(
        p_bodega_destino_id, p_tipo_cafe_id, p_clasificacion_id, 'entrada_traslado',
        p_cantidad_qq, p_bodeguero_despacha_id, NOW()
    );

    RAISE NOTICE 'Traslado % registrado: % qq de bodega % a bodega %.', p_numero, p_cantidad_qq, p_bodega_origen_id, p_bodega_destino_id;
END;
$$;


-- sp_registrar_exportacion
-- Verifica saldo del contrato, registra exportacion y descuenta inventario
CREATE OR REPLACE PROCEDURE sp_registrar_exportacion(
    p_numero               VARCHAR,
    p_contrato_id          INT,
    p_bodega_origen_id     INT,
    p_transportista_id     INT,
    p_vehiculo_id          INT,
    p_autorizador_id       INT,
    p_fecha_despacho       DATE,
    p_quintales_exportados DECIMAL,
    p_num_contenedor       VARCHAR DEFAULT NULL,
    p_puerto_salida        VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_saldo DECIMAL(10,2);
BEGIN
    v_saldo := fn_saldo_contrato(p_contrato_id);

    IF p_quintales_exportados > v_saldo THEN
        RAISE EXCEPTION 'Exportacion (% qq) excede saldo del contrato (% qq disponibles).',
                        p_quintales_exportados, v_saldo;
    END IF;

    -- Insertar exportacion (trigger trg_validar_contrato corre antes)
    INSERT INTO exportaciones(
        numero, contrato_id, bodega_origen_id, transportista_id, vehiculo_id,
        autorizador_id, fecha_despacho, quintales_exportados,
        num_contenedor, puerto_salida
    )
    VALUES(
        p_numero, p_contrato_id, p_bodega_origen_id, p_transportista_id, p_vehiculo_id,
        p_autorizador_id, p_fecha_despacho, p_quintales_exportados,
        p_num_contenedor, p_puerto_salida
    );

    -- Movimiento de inventario salida exportacion
    INSERT INTO movimientos_inventario(
        bodega_id, tipo_cafe_id, clasificacion_id, tipo_movimiento,
        cantidad_qq, referencia_id, responsable_id, fecha
    )
    SELECT p_bodega_origen_id, cd.tipo_cafe_id, cd.clasificacion_id, 'salida_exportacion',
           p_quintales_exportados, p_contrato_id, p_autorizador_id, NOW()
    FROM   contrato_detalle cd WHERE cd.contrato_id = p_contrato_id LIMIT 1;

    -- Si saldo llega a cero marcar contrato como cumplido
    IF fn_saldo_contrato(p_contrato_id) <= 0 THEN
        UPDATE contratos_exportacion
        SET    estado = 'cumplido', updated_at = NOW()
        WHERE  id = p_contrato_id;
        RAISE NOTICE 'Contrato % marcado como CUMPLIDO.', p_contrato_id;
    END IF;

    RAISE NOTICE 'Exportacion % registrada: % qq despachados.', p_numero, p_quintales_exportados;
END;
$$;


-- sp_agendar_visita
-- Crea la visita y valida que el tecnico no tenga conflicto de fecha
CREATE OR REPLACE PROCEDURE sp_agendar_visita(
    p_gerente_id       INT,
    p_tecnico_id       INT,
    p_fecha_programada DATE,
    p_terrenos         INT[],
    p_tipos_aplicacion tipo_aplicacion_enum[],
    p_productos        TEXT[]  DEFAULT NULL,
    p_dosis            TEXT[]  DEFAULT NULL,
    p_instrucciones    TEXT[]  DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_visita_id INT;
    i           INT;
BEGIN
    -- Validar que el tecnico no tenga visita en esa fecha
    IF EXISTS (
        SELECT 1 FROM visitas_tecnicas
        WHERE  tecnico_id       = p_tecnico_id
          AND  fecha_programada = p_fecha_programada
          AND  estado NOT IN ('cancelada')
    ) THEN
        RAISE EXCEPTION 'El tecnico % ya tiene una visita programada para el %.', p_tecnico_id, p_fecha_programada;
    END IF;

    INSERT INTO visitas_tecnicas(gerente_id, tecnico_id, fecha_programada, estado)
    VALUES (p_gerente_id, p_tecnico_id, p_fecha_programada, 'programada')
    RETURNING id INTO v_visita_id;

    FOR i IN 1..ARRAY_LENGTH(p_terrenos, 1) LOOP
        INSERT INTO visita_terrenos(
            visita_id, terreno_id, tipo_aplicacion,
            producto, dosis_recomendada, instrucciones
        )
        VALUES(
            v_visita_id, p_terrenos[i], p_tipos_aplicacion[i],
            CASE WHEN p_productos    IS NOT NULL THEN p_productos[i]    END,
            CASE WHEN p_dosis        IS NOT NULL THEN p_dosis[i]        END,
            CASE WHEN p_instrucciones IS NOT NULL THEN p_instrucciones[i] END
        );
    END LOOP;

    RAISE NOTICE 'Visita % agendada para el % con % terrenos.',
                 v_visita_id, p_fecha_programada, ARRAY_LENGTH(p_terrenos,1);
END;
$$;


-- sp_aprobar_evaluacion
-- Registra decision del supervisor y actualiza tipo de socio si se aprueba
CREATE OR REPLACE PROCEDURE sp_aprobar_evaluacion(
    p_evaluacion_id INT,
    p_supervisor_id INT,
    p_decision      estado_evaluacion_enum,
    p_comentario    TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_terreno_id   INT;
    v_productor_id INT;
    v_socio_id     INT;
    v_tipo_asoc    tipo_asociacion_enum;
BEGIN
    IF p_decision NOT IN ('aprobada','rechazada') THEN
        RAISE EXCEPTION 'La decision debe ser aprobada o rechazada.';
    END IF;

    IF p_comentario IS NULL OR TRIM(p_comentario) = '' THEN
        RAISE EXCEPTION 'El comentario justificativo es obligatorio.';
    END IF;

    UPDATE evaluaciones_tecnicas
    SET    estado                = p_decision,
           supervisor_id         = p_supervisor_id,
           comentario_supervisor = p_comentario,
           fecha_decision        = CURRENT_DATE,
           updated_at            = NOW()
    WHERE  id = p_evaluacion_id;

    IF p_decision = 'aprobada' THEN
        -- Obtener terreno y productor
        SELECT et.terreno_id, t.productor_id
        INTO   v_terreno_id, v_productor_id
        FROM   evaluaciones_tecnicas et
        JOIN   terrenos t ON t.id = et.terreno_id
        WHERE  et.id = p_evaluacion_id;

        -- Buscar socio del productor
        SELECT id INTO v_socio_id
        FROM   socios WHERE productor_id = v_productor_id;

        IF v_socio_id IS NOT NULL THEN
            v_tipo_asoc := fn_clasificar_socio(p_evaluacion_id);
            UPDATE socios
            SET    tipo_asociacion = v_tipo_asoc, updated_at = NOW()
            WHERE  id = v_socio_id;
            RAISE NOTICE 'Socio % clasificado como Tipo %.', v_socio_id, v_tipo_asoc;
        END IF;
    END IF;

    RAISE NOTICE 'Evaluacion % marcada como %.', p_evaluacion_id, p_decision;
END;
$$;
