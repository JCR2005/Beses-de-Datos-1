-- ============================================================
-- 04_fichas.sql : fichas de ingreso, egreso y traslado
-- (emergencias, cirugia y hospitalizacion; consulta externa no usa ficha de ingreso)
-- ============================================================

-- Tabla INGRESO: ficha de ingreso del paciente a una unidad (camilla asignada, medico encargado, diagnostico presuntivo).
CREATE TABLE ingreso (
    id_ingreso            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    paciente_id           INTEGER       NOT NULL REFERENCES paciente(id_paciente)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    unidad_id             INTEGER       NOT NULL REFERENCES unidad_medica(id_unidad)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    servicio_id           INTEGER       REFERENCES servicio_atencion(id_servicio)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    camilla_id            INTEGER       REFERENCES camilla(id_camilla)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    motivo_ingreso        TEXT          NOT NULL,
    fecha_hora_ingreso    TIMESTAMPTZ   NOT NULL,
    medico_encargado_id   INTEGER       NOT NULL REFERENCES medico(id_medico)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    diagnostico_presuntivo TEXT
);

-- Tabla EGRESO: ficha de egreso, uno por ingreso; diagnostico, motivo, codigo de egreso y datos de consentimiento.
CREATE TABLE egreso (
    id_egreso             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ingreso_id            INTEGER       NOT NULL UNIQUE REFERENCES ingreso(id_ingreso)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    diagnostico_principal TEXT          NOT NULL,
    diagnosticos_secundarios TEXT,
    motivo_egreso         TEXT          NOT NULL,
    unidad_id             INTEGER       NOT NULL REFERENCES unidad_medica(id_unidad)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    servicio_id           INTEGER       REFERENCES servicio_atencion(id_servicio)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    fecha_hora_egreso     TIMESTAMPTZ   NOT NULL,
    medico_id             INTEGER       NOT NULL REFERENCES medico(id_medico)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    camilla_id            INTEGER       REFERENCES camilla(id_camilla)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    codigo_egreso         VARCHAR(15)   NOT NULL,
    egreso_sin_consentimiento BOOLEAN   NOT NULL DEFAULT FALSE,
    motivo_egreso_sin_consentimiento TEXT,
    dias_hospitalizado    SMALLINT,
    codigo_traslado       VARCHAR(20),
    referido_otro_hospital BOOLEAN      NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_egreso_codigo CHECK (codigo_egreso IN ('vivo','muerto','embarazo','parto')),
    CONSTRAINT chk_egreso_dias CHECK (dias_hospitalizado IS NULL OR dias_hospitalizado > 0),
    CONSTRAINT chk_egreso_consentimiento CHECK (NOT egreso_sin_consentimiento OR motivo_egreso_sin_consentimiento IS NOT NULL)
);
COMMENT ON CONSTRAINT chk_egreso_codigo ON egreso IS 'Valida codigo de egreso (vivo, muerto, embarazo, parto).';
COMMENT ON CONSTRAINT chk_egreso_dias ON egreso IS 'Valida que los dias hospitalizado sean positivos cuando se registran.';
COMMENT ON CONSTRAINT chk_egreso_consentimiento ON egreso IS 'Valida que el motivo sea obligatorio cuando hubo egreso sin consentimiento medico.';

-- Tabla TRASLADO: ficha de traslado entre unidades (interno o externo a la institucion) ordenado por un medico.
CREATE TABLE traslado (
    id_traslado           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_hora            TIMESTAMPTZ   NOT NULL,
    paciente_id           INTEGER       NOT NULL REFERENCES paciente(id_paciente)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    medico_indica_id      INTEGER       NOT NULL REFERENCES medico(id_medico)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    unidad_origen_id      INTEGER       NOT NULL REFERENCES unidad_medica(id_unidad)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    unidad_destino_id     INTEGER       NOT NULL REFERENCES unidad_medica(id_unidad)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    interno_externo       VARCHAR(10)   NOT NULL,
    hospital_externo_nombre VARCHAR(120),
    hospital_externo_direccion VARCHAR(250),
    ingreso_id            INTEGER       REFERENCES ingreso(id_ingreso)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    consulta_id           INTEGER       REFERENCES consulta(id_consulta)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    CONSTRAINT chk_traslado_tipo CHECK (interno_externo IN ('interno','externo')),
    CONSTRAINT chk_traslado_externo CHECK (interno_externo <> 'externo' OR (hospital_externo_nombre IS NOT NULL AND hospital_externo_direccion IS NOT NULL))
);
COMMENT ON CONSTRAINT chk_traslado_tipo ON traslado IS 'Valida tipo de traslado: interno o externo a la institucion.';
COMMENT ON CONSTRAINT chk_traslado_externo ON traslado IS 'Valida que un traslado externo indique nombre y direccion del hospital destino.';