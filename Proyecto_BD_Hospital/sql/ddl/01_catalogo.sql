-- ============================================================
-- 01_catalogo.sql : catalogos y tablas maestras generales
-- ============================================================

-- Tabla HOSPITAL: almacena los hospitales de la cadena y sus datos generales.
CREATE TABLE hospital (
    id_hospital           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre                VARCHAR(120)  NOT NULL,
    informacion_especifica TEXT,
    direccion             VARCHAR(250)  NOT NULL
);

-- Tabla UNIDAD_MEDICA: las 4 unidades de atencion por hospital (consulta externa, emergencias, cirugia, hospitalizacion).
CREATE TABLE unidad_medica (
    id_unidad             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hospital_id           INTEGER       NOT NULL REFERENCES hospital(id_hospital)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    nombre                VARCHAR(40)   NOT NULL,
    costo_dia_hospitalizacion NUMERIC(10,2),
    CONSTRAINT uq_unidad_hospital_nombre UNIQUE (hospital_id, nombre),
    CONSTRAINT chk_unidad_nombre CHECK (nombre IN ('Consulta Externa','Emergencias','Cirugia','Hospitalizacion','Otro'))
);
COMMENT ON CONSTRAINT chk_unidad_nombre ON unidad_medica IS 'Valida que la unidad sea una de las 4 unidades medicas o "Otro" (traslados externos).';

-- Tabla SERVICIO_ATENCION: tipos de atencion/servicio ofrecidos por cada unidad (p. ej. servicios de hospitalizacion o emergencia).
CREATE TABLE servicio_atencion (
    id_servicio           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    unidad_id             INTEGER       NOT NULL REFERENCES unidad_medica(id_unidad)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    nombre                VARCHAR(80)   NOT NULL,
    costo                 NUMERIC(10,2),
    CONSTRAINT uq_servicio_unidad UNIQUE (unidad_id, nombre)
);

-- Tabla ESPECIALIDAD: catalogo de especialidades de los medicos.
CREATE TABLE especialidad (
    id_especialidad       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre                VARCHAR(80)   NOT NULL UNIQUE
);

-- Tabla CAMILLA: camillas de cada unidad de hospital del hospital (asignables a pacientes).
CREATE TABLE camilla (
    id_camilla            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hospital_id           INTEGER       NOT NULL REFERENCES hospital(id_hospital)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    unidad_id             INTEGER       NOT NULL REFERENCES unidad_medica(id_unidad)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    numero                VARCHAR(10)   NOT NULL,
    disponible            BOOLEAN       NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_camilla_hospital_numero UNIQUE (hospital_id, numero)
);

-- Tabla QUIROFANO: pabellones quirurgicos habilitados (4 por hospital).
CREATE TABLE quirofano (
    id_quirofano          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hospital_id           INTEGER       NOT NULL REFERENCES hospital(id_hospital)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    numero                VARCHAR(10)   NOT NULL,
    estado                VARCHAR(20)   NOT NULL DEFAULT 'disponible',
    CONSTRAINT uq_quirofano_hospital_numero UNIQUE (hospital_id, numero),
    CONSTRAINT chk_quirofano_estado CHECK (estado IN ('disponible','ocupado','en_mantenimiento'))
);
COMMENT ON CONSTRAINT chk_quirofano_estado ON quirofano IS 'Valida que el estado del quirofano sea disponible, ocupado o en mantenimiento.';

-- Tabla MEDICO: personal medico; tipo indica residencia/contratacion (externos no estan contratados).
CREATE TABLE medico (
    id_medico             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres               VARCHAR(100)  NOT NULL,
    apellidos             VARCHAR(100)  NOT NULL,
    dpi                   VARCHAR(20)   NOT NULL UNIQUE,
    telefono              VARCHAR(20),
    municipio             VARCHAR(80),
    departamento          VARCHAR(80),
    area                  VARCHAR(10),
    especialidad_id       INTEGER       REFERENCES especialidad(id_especialidad)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    tipo_medico           VARCHAR(20)   NOT NULL,
    costo_primera_consulta NUMERIC(10,2),
    horario_inicio        TIME,
    horario_fin           TIME,
    CONSTRAINT chk_medico_area CHECK (area IN ('Urbana','Rural')),
    CONSTRAINT chk_medico_tipo CHECK (tipo_medico IN ('residente','interno','externo','general','especialista'))
);
COMMENT ON CONSTRAINT chk_medico_area ON medico IS 'Valida area de residencia del medico (Urbana/Rural).';
COMMENT ON CONSTRAINT chk_medico_tipo ON medico IS 'Valida el tipo de contratacion del medico (residente, interno, externo, general, especialista).';

-- Tabla ENFERMERO: personal de enfermeria (registrado o practicante).
CREATE TABLE enfermero (
    id_enfermero          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres               VARCHAR(100)  NOT NULL,
    apellidos             VARCHAR(100)  NOT NULL,
    dpi                   VARCHAR(20)   NOT NULL UNIQUE,
    telefono              VARCHAR(20),
    tipo                  VARCHAR(30)   NOT NULL,
    CONSTRAINT chk_enfermero_tipo CHECK (tipo IN ('registrado','practicante_de_enfermeria'))
);
COMMENT ON CONSTRAINT chk_enfermero_tipo ON enfermero IS 'Valida tipo de enfermero: registrado o practicante de enfermeria.';

-- Tabla INSUMO: catalogo de insumos medicos/quirurgicos utilizados en cirugias e internamientos.
CREATE TABLE insumo (
    id_insumo             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre                VARCHAR(120)  NOT NULL,
    descripcion           TEXT,
    material              VARCHAR(80),
    tipo                  VARCHAR(20)   NOT NULL,
    CONSTRAINT chk_insumo_tipo CHECK (tipo IN ('medico','quirurgico','otro'))
);
COMMENT ON CONSTRAINT chk_insumo_tipo ON insumo IS 'Valida tipo de insumo: medico, quirurgico u otro.';

-- Tabla INSTRUMENTO: catalogo de instrumental quirurgico.
CREATE TABLE instrumento (
    id_instrumento        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre                VARCHAR(120)  NOT NULL,
    descripcion           TEXT,
    tipo                  VARCHAR(20)   NOT NULL,
    funcion               VARCHAR(30)   NOT NULL,
    CONSTRAINT chk_instrumento_tipo CHECK (tipo IN ('medico','quirurgico','otro')),
    CONSTRAINT chk_instrumento_funcion CHECK (funcion IN ('corte','contencion','hemostatica','retractor','accesorio','implante','otro'))
);
COMMENT ON CONSTRAINT chk_instrumento_tipo ON instrumento IS 'Valida tipo de instrumento: medico, quirurgico u otro.';
COMMENT ON CONSTRAINT chk_instrumento_funcion ON instrumento IS 'Valida funcion del instrumento (corte, contencion, hemostatica, retractor, accesorio, implante, otro).';

-- Tabla EQUIPO: catalogo de equipos medicos/quirurgicos.
CREATE TABLE equipo (
    id_equipo             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre                VARCHAR(120)  NOT NULL,
    descripcion           TEXT,
    tipo                  VARCHAR(20)   NOT NULL,
    funcion               VARCHAR(30)   NOT NULL,
    CONSTRAINT chk_equipo_tipo CHECK (tipo IN ('medico','quirurgico','otro')),
    CONSTRAINT chk_equipo_funcion CHECK (funcion IN ('exploracion','diagnostico','tratamiento','rehabilitacion','otro'))
);
COMMENT ON CONSTRAINT chk_equipo_tipo ON equipo IS 'Valida tipo de equipo: medico, quirurgico u otro.';
COMMENT ON CONSTRAINT chk_equipo_funcion ON equipo IS 'Valida funcion del equipo (exploracion, diagnostico, tratamiento, rehabilitacion, otro).';