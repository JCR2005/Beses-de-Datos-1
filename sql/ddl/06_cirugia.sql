-- ============================================================
-- 06_cirugia.sql : agendamiento, pre/intra/postoperatorio y recursos quirurgicos
-- ============================================================

-- Tabla AGENDAMIENTO_QUIRURGICO: solicitud enviada al comite medico; aprobada, rechazada (con motivo) o pendiente.
CREATE TABLE agendamiento_quirurgico (
    id_agendamiento       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    paciente_id           INTEGER       NOT NULL REFERENCES paciente(id_paciente)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    medico_cirujano_id    INTEGER       NOT NULL REFERENCES medico(id_medico)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    caracter              VARCHAR(15)   NOT NULL,
    historia_clinica      TEXT,
    tipo_procedimiento    TEXT          NOT NULL,
    tiempo_estimado_min   SMALLINT      NOT NULL,
    tipo_anestesia        VARCHAR(80)   NOT NULL,
    fecha_hora_solicitud  TIMESTAMPTZ   NOT NULL,
    estado_solicitud      VARCHAR(15)   NOT NULL,
    motivo_rechazo        TEXT,
    quirofano_solicitado_id INTEGER     REFERENCES quirofano(id_quirofano)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    fecha_hora_agendada   TIMESTAMPTZ,
    CONSTRAINT chk_agendamiento_caracter CHECK (caracter IN ('urgente','programado')),
    CONSTRAINT chk_agendamiento_estado CHECK (estado_solicitud IN ('pendiente','aprobada','rechazada')),
    CONSTRAINT chk_agendamiento_tiempo CHECK (tiempo_estimado_min > 0),
    CONSTRAINT chk_agendamiento_rechazo CHECK (estado_solicitud <> 'rechazada' OR motivo_rechazo IS NOT NULL)
);
COMMENT ON CONSTRAINT chk_agendamiento_caracter ON agendamiento_quirurgico IS 'Valida caracter de la cirugia: urgente o programado.';
COMMENT ON CONSTRAINT chk_agendamiento_estado ON agendamiento_quirurgico IS 'Valida estado de la solicitud (pendiente, aprobada, rechazada).';
COMMENT ON CONSTRAINT chk_agendamiento_tiempo ON agendamiento_quirurgico IS 'Valida que el tiempo estimado de la intervencion sea positivo.';
COMMENT ON CONSTRAINT chk_agendamiento_rechazo ON agendamiento_quirurgico IS 'Valida que una solicitud rechazada indique las razones.';

-- Tabla HISTORIA_CLINICA: interrogatorio y exploracion fisica del paciente para la intervencion.
CREATE TABLE historia_clinica (
    id_historia_clinica   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agendamiento_id       INTEGER       NOT NULL UNIQUE REFERENCES agendamiento_quirurgico(id_agendamiento)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    medico_id             INTEGER       NOT NULL REFERENCES medico(id_medico)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    fecha                 DATE          NOT NULL,
    fuente_interrogatorio VARCHAR(10)   NOT NULL,
    religion              VARCHAR(40),
    ocupacion             VARCHAR(60),
    lugar_nacimiento      VARCHAR(80),
    lugar_residencia      VARCHAR(80),
    antecedentes_heredofamiliares TEXT NOT NULL,
    antecedentes_personales_no_patologicos TEXT NOT NULL,
    antecedentes_patologicos TEXT NOT NULL,
    padecimiento_actual   TEXT          NOT NULL,
    interrogatorio_aparatos_sistemas TEXT,
    sintomas_generales_terapeutica TEXT,
    estudios_previos      TEXT,
    signos_vitales        TEXT,
    exploracion_general   TEXT,
    exploracion_sistematizada TEXT,
    CONSTRAINT chk_historia_fuente CHECK (fuente_interrogatorio IN ('directo','indirecto'))
);
COMMENT ON CONSTRAINT chk_historia_fuente ON historia_clinica IS 'Valida fuente del interrogatorio: directo (paciente) o indirecto (familiar/amigo).';

-- Tabla CONSENTIMIENTO_INFORMADO: nombre y firma de medico y paciente/encargado, objetivos, caracteristicas y riesgos.
CREATE TABLE consentimiento_informado (
    id_consentimiento     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agendamiento_id       INTEGER       NOT NULL REFERENCES agendamiento_quirurgico(id_agendamiento)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    procedimiento_nombre  TEXT          NOT NULL,
    procedimiento_objetivo TEXT         NOT NULL,
    procedimiento_caracteristicas TEXT  NOT NULL,
    procedimiento_riesgos TEXT         NOT NULL,
    medico_nombre         VARCHAR(150)  NOT NULL,
    medico_firmado        BOOLEAN       NOT NULL DEFAULT FALSE,
    paciente_firma_nombre VARCHAR(150)  NOT NULL,
    paciente_firmado      BOOLEAN       NOT NULL DEFAULT FALSE,
    fecha_obtencion       DATE          NOT NULL
);

-- Tabla CHEQUEO_PREANESTESICO: evaluacion del riesgo anestesico (ASA) y plan de anestesia.
CREATE TABLE chequeo_preanestesico (
    id_chequeo_preanestesico INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agendamiento_id       INTEGER       NOT NULL UNIQUE REFERENCES agendamiento_quirurgico(id_agendamiento)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    clasificacion_asa     VARCHAR(5)    NOT NULL,
    medico_asa_nombre     VARCHAR(150)  NOT NULL,
    plan_anestesia        TEXT          NOT NULL,
    anestesista_nombre    VARCHAR(150)  NOT NULL,
    CONSTRAINT chk_preanestesico_asa CHECK (clasificacion_asa IN ('I','II','III','IV','V','VI'))
);
COMMENT ON CONSTRAINT chk_preanestesico_asa ON chequeo_preanestesico IS 'Valida clasificacion ASA del riesgo anestesico (I a VI).';

-- Tabla CIRUGIA: intervencion quirurgica de un agendamiento aprobado (quirofano, cirujano, tiempos y condicion).
CREATE TABLE cirugia (
    id_cirugia            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agendamiento_id       INTEGER       NOT NULL UNIQUE REFERENCES agendamiento_quirurgico(id_agendamiento)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    quirofano_id          INTEGER       NOT NULL REFERENCES quirofano(id_quirofano)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    paciente_id           INTEGER       NOT NULL REFERENCES paciente(id_paciente)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    cirujano_id           INTEGER       NOT NULL REFERENCES medico(id_medico)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    ingreso_id            INTEGER       REFERENCES ingreso(id_ingreso)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    fecha_hora_inicio     TIMESTAMPTZ   NOT NULL,
    fecha_hora_fin        TIMESTAMPTZ,
    condicion_evolucion   VARCHAR(25),
    estado                VARCHAR(20)   NOT NULL,
    CONSTRAINT chk_cirugia_condicion CHECK (condicion_evolucion IN ('sin_complicaciones','complicaciones','complicaciones_graves')),
    CONSTRAINT chk_cirugia_estado CHECK (estado IN ('preoperatorio','intraoperatorio','postoperatorio','finalizada'))
);
COMMENT ON CONSTRAINT chk_cirugia_condicion ON cirugia IS 'Valida condicion de evolucion durante la cirugia (sin complicaciones, complicaciones, complicaciones graves).';
COMMENT ON CONSTRAINT chk_cirugia_estado ON cirugia IS 'Valida etapa de la cirugia (preoperatorio, intraoperatorio, postoperatorio, finalizada).';

-- Tabla REGISTRO_PROCEDIMIENTO: registro del enfermero encargado de cada proceso (descripcion, hora, exito o falla).
CREATE TABLE registro_procedimiento (
    id_registro_procedimiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cirugia_id            INTEGER       NOT NULL REFERENCES cirugia(id_cirugia)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    etapa                 VARCHAR(20)   NOT NULL,
    aspecto               VARCHAR(60)   NOT NULL,
    exito                 BOOLEAN       NOT NULL,
    descripcion           TEXT,
    hora_registro         TIMESTAMPTZ   NOT NULL,
    enfermero_id          INTEGER       NOT NULL REFERENCES enfermero(id_enfermero)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    fecha_documentacion   DATE,
    CONSTRAINT chk_registro_etapa CHECK (etapa IN ('preoperatorio','intraoperatorio','postoperatorio'))
);
COMMENT ON CONSTRAINT chk_registro_etapa ON registro_procedimiento IS 'Valida etapa del proceso registrado (preoperatorio, intraoperatorio, postoperatorio).';

-- Tabla REQUERIMIENTO_QUIRURGICO: entidad asociativa entre el agendamiento y los recursos requeridos (insumo/instrumento/equipo).
CREATE TABLE requerimiento_quirurgico (
    id_requerimiento      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agendamiento_id       INTEGER       NOT NULL REFERENCES agendamiento_quirurgico(id_agendamiento)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    tipo_recurso          VARCHAR(20)   NOT NULL,
    insumo_id             INTEGER       REFERENCES insumo(id_insumo)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    instrumento_id        INTEGER       REFERENCES instrumento(id_instrumento)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    equipo_id             INTEGER       REFERENCES equipo(id_equipo)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    cantidad              SMALLINT      NOT NULL,
    CONSTRAINT chk_requerimiento_tipo CHECK (tipo_recurso IN ('insumo','instrumento','equipo')),
    CONSTRAINT chk_requerimiento_un_recurso CHECK (
        (insumo_id IS NOT NULL)::int + (instrumento_id IS NOT NULL)::int + (equipo_id IS NOT NULL)::int = 1
    ),
    CONSTRAINT chk_requerimiento_cantidad CHECK (cantidad > 0)
);
COMMENT ON CONSTRAINT chk_requerimiento_tipo ON requerimiento_quirurgico IS 'Valida tipo de recurso requerido (insumo, instrumento o equipo).';
COMMENT ON CONSTRAINT chk_requerimiento_un_recurso ON requerimiento_quirurgico IS 'Valida que el requerimiento referencia exactamente un recurso real.';
COMMENT ON CONSTRAINT chk_requerimiento_cantidad ON requerimiento_quirurgico IS 'Valida cantidad requerida mayor que cero.';

-- Tabla CIRUGIA_PERSONAL: entidad asociativa entre la cirugia y el personal (medicos, enfermeros, practicantes) que interviene.
CREATE TABLE cirugia_personal (
    id_cirugia_personal   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cirugia_id            INTEGER       NOT NULL REFERENCES cirugia(id_cirugia)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    medico_id             INTEGER       REFERENCES medico(id_medico)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    enfermero_id          INTEGER       REFERENCES enfermero(id_enfermero)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    rol                   VARCHAR(60)   NOT NULL,
    CONSTRAINT chk_personal_un_tipo CHECK (
        (medico_id IS NOT NULL)::int + (enfermero_id IS NOT NULL)::int = 1
    )
);
COMMENT ON CONSTRAINT chk_personal_un_tipo ON cirugia_personal IS 'Valida que la participacion corresponda a un medico o a un enfermero, no a ambos.';

-- Tabla CIRUGIA_INSUMO: insumos utilizados durante la operacion (contribuyen al costo total de la cirugia).
CREATE TABLE cirugia_insumo (
    id_cirugia_insumo     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cirugia_id            INTEGER       NOT NULL REFERENCES cirugia(id_cirugia)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    insumo_id             INTEGER       NOT NULL REFERENCES insumo(id_insumo)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    cantidad              SMALLINT      NOT NULL,
    costo_unitario        NUMERIC(10,2) NOT NULL,
    CONSTRAINT chk_cirugia_insumo_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_cirugia_insumo_costo CHECK (costo_unitario >= 0)
);
COMMENT ON CONSTRAINT chk_cirugia_insumo_cantidad ON cirugia_insumo IS 'Valida cantidad de insumo utilizada mayor que cero.';
COMMENT ON CONSTRAINT chk_cirugia_insumo_costo ON cirugia_insumo IS 'Valida costo unitario del insumo no negativo.';