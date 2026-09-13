-- ============================================================
-- 03_consulta_externa.sql : citas, consultas y recetas
-- ============================================================

-- Tabla CITA: ficha de cita programada en consulta externa, con estado y costo segun reglas de negocio.
CREATE TABLE cita (
    id_cita               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    paciente_id           INTEGER       NOT NULL REFERENCES paciente(id_paciente)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    medico_id             INTEGER       NOT NULL REFERENCES medico(id_medico)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    fecha_hora            TIMESTAMPTZ   NOT NULL,
    num_clinica           VARCHAR(20)   NOT NULL,
    medio_asignacion      VARCHAR(20),
    estado                VARCHAR(20)   NOT NULL DEFAULT 'programada',
    es_reconsulta         BOOLEAN       NOT NULL DEFAULT FALSE,
    es_referido           BOOLEAN       NOT NULL DEFAULT FALSE,
    costo_base            NUMERIC(10,2),
    costo_aplicado        NUMERIC(10,2),
    cancelada_sin_aviso   BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_cita_medio CHECK (medio_asignacion IN ('telefonico','correo_institucional','recepcion_general','recepcion_medico')),
    CONSTRAINT chk_cita_estado CHECK (estado IN ('programada','realizada','reprogramada','cancelada')),
    CONSTRAINT chk_cita_costos CHECK (costo_base IS NULL OR costo_base >= 0),
    CONSTRAINT chk_cita_costo_aplicado CHECK (costo_aplicado IS NULL OR costo_aplicado >= 0)
);
COMMENT ON CONSTRAINT chk_cita_medio ON cita IS 'Valida medio de asignacion de la cita (telefonico, correo, recepciones).';
COMMENT ON CONSTRAINT chk_cita_estado ON cita IS 'Valida estado de la cita (programada, realizada, reprogramada, cancelada).';
COMMENT ON CONSTRAINT chk_cita_costos ON cita IS 'Valida que el costo base de la cita sea mayor o igual a cero.';
COMMENT ON CONSTRAINT chk_cita_costo_aplicado ON cita IS 'Valida que el costo aplicado (con descuentos/sobrecargos) sea mayor o igual a cero.';

-- Tabla CONSULTA: ficha de consulta realizada del paciente (diagnostico, notas y observaciones).
CREATE TABLE consulta (
    id_consulta           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cita_id               INTEGER       NOT NULL UNIQUE REFERENCES cita(id_cita)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    paciente_id           INTEGER       NOT NULL REFERENCES paciente(id_paciente)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    medico_id             INTEGER       NOT NULL REFERENCES medico(id_medico)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    fecha                 DATE          NOT NULL,
    diagnostico           TEXT          NOT NULL,
    otros_datos           TEXT,
    notas_observaciones   TEXT
);

-- Tabla RECETA: receta medica emitida en la consulta; incluye la proxima cita de seguimiento.
CREATE TABLE receta (
    id_receta             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    consulta_id           INTEGER       NOT NULL UNIQUE REFERENCES consulta(id_consulta)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    fecha                 DATE          NOT NULL,
    proxima_cita          DATE
);

-- Tabla RECETA_MEDICAMENTO: medicamentos prescritos en la receta (detalle con dosis y duracion).
CREATE TABLE receta_medicamento (
    id_receta_medicamento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    receta_id             INTEGER       NOT NULL REFERENCES receta(id_receta)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    medicamento_nombre    VARCHAR(120)  NOT NULL,
    dosis                 VARCHAR(60)   NOT NULL,
    duracion              VARCHAR(60)
);