-- ============================================================
-- 02_pacientes.sql : pacientes y encargados
-- ============================================================

-- Tabla PACIENTE: datos de los pacientes (expediente, identidad, direccion habitual, seguro social cuando aplica).
CREATE TABLE paciente (
    id_paciente           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_expediente     VARCHAR(20)   NOT NULL UNIQUE,
    nombres               VARCHAR(100)  NOT NULL,
    apellidos             VARCHAR(100)  NOT NULL,
    fecha_nacimiento      DATE          NOT NULL,
    edad_años             SMALLINT      NOT NULL,
    sexo                  VARCHAR(10)   NOT NULL,
    dpi                   VARCHAR(20)   UNIQUE,
    telefono              VARCHAR(20),
    municipio             VARCHAR(80),
    departamento          VARCHAR(80),
    area                  VARCHAR(10),
    estado_civil          VARCHAR(30),
    no_seguro_social      VARCHAR(30),
    CONSTRAINT chk_paciente_edad CHECK (edad_años BETWEEN 0 AND 120),
    CONSTRAINT chk_paciente_sexo CHECK (sexo IN ('Masculino','Femenino')),
    CONSTRAINT chk_paciente_area CHECK (area IN ('Urbana','Rural'))
);
COMMENT ON CONSTRAINT chk_paciente_edad ON paciente IS 'Valida rango de edad plausible (0 a 120 años).';
COMMENT ON CONSTRAINT chk_paciente_sexo ON paciente IS 'Valida sexo (Masculino/Femenino).';
COMMENT ON CONSTRAINT chk_paciente_area ON paciente IS 'Valida area de residencia (Urbana/Rural).';

-- Tabla ENCARGADO: responsable/encargado del paciente (humano, no es paciente necesariamente).
CREATE TABLE encargado (
    id_encargado          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre                VARCHAR(150)  NOT NULL,
    dpi                   VARCHAR(20)   UNIQUE,
    telefono              VARCHAR(20),
    municipio             VARCHAR(80),
    departamento          VARCHAR(80),
    area                  VARCHAR(10),
    CONSTRAINT chk_encargado_area CHECK (area IN ('Urbana','Rural'))
);
COMMENT ON CONSTRAINT chk_encargado_area ON encargado IS 'Valida area de residencia del encargado (Urbana/Rural).';

-- Tabla paciente_encargado: relacion M:N resuelta entre pacientes y encargados, con el parentesco.
CREATE TABLE paciente_encargado (
    id_paciente_encargado INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    paciente_id           INTEGER       NOT NULL REFERENCES paciente(id_paciente)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    encargado_id          INTEGER       NOT NULL REFERENCES encargado(id_encargado)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    parentesco            VARCHAR(40)   NOT NULL,
    CONSTRAINT uq_paciente_encargado UNIQUE (paciente_id, encargado_id)
);