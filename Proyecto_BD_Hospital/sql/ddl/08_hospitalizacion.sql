-- ============================================================
-- 07_hospitalizacion.sql : costos de insumos durante la hospitalizacion
-- ============================================================

-- Tabla HOSPITALIZACION_INSUMO: insumos medicos utilizados durante el internamiento (costo parcial de la factura).
CREATE TABLE hospitalizacion_insumo (
    id_hospitalizacion_insumo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ingreso_id            INTEGER       NOT NULL REFERENCES ingreso(id_ingreso)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    insumo_id             INTEGER       NOT NULL REFERENCES insumo(id_insumo)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    cantidad              SMALLINT      NOT NULL,
    costo_unitario        NUMERIC(10,2) NOT NULL,
    CONSTRAINT chk_hospitalizacion_insumo_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_hospitalizacion_insumo_costo CHECK (costo_unitario >= 0)
);
COMMENT ON CONSTRAINT chk_hospitalizacion_insumo_cantidad ON hospitalizacion_insumo IS 'Valida cantidad de insumo usada mayor que cero.';
COMMENT ON CONSTRAINT chk_hospitalizacion_insumo_costo ON hospitalizacion_insumo IS 'Valida costo unitario del insumo no negativo.';