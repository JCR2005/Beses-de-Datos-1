-- ============================================================
-- 05_facturacion.sql : factura y pagos en cuotas
-- ============================================================

-- Tabla FACTURA: comprobante emitido al cancelar el servicio, con descripcion breve y clara del servicio brindado.
CREATE TABLE factura (
    id_factura            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    paciente_id           INTEGER       NOT NULL REFERENCES paciente(id_paciente)
                                ON DELETE RESTRICT ON UPDATE RESTRICT,
    fecha_emision         TIMESTAMPTZ   NOT NULL,
    descripcion           TEXT          NOT NULL,
    total                 NUMERIC(10,2) NOT NULL,
    cita_id               INTEGER       REFERENCES cita(id_cita)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    ingreso_id            INTEGER       REFERENCES ingreso(id_ingreso)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    cirugia_id            INTEGER       REFERENCES cirugia(id_cirugia)
                                ON DELETE SET NULL ON UPDATE SET NULL,
    CONSTRAINT chk_factura_total CHECK (total >= 0),
    CONSTRAINT chk_factura_origen CHECK (
        (cita_id IS NOT NULL)::int + (ingreso_id IS NOT NULL)::int + (cirugia_id IS NOT NULL)::int >= 1
    )
);
COMMENT ON CONSTRAINT chk_factura_total ON factura IS 'Valida que el total de la factura no sea negativo.';
COMMENT ON CONSTRAINT chk_factura_origen ON factura IS 'Valida que la factura este asociada a al menos un servicio (cita, ingreso o cirugia).';

-- Tabla PAGO: pagos en cuotas de una factura (de 1 a 12 pagos mensuales).
CREATE TABLE pago (
    id_pago               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    factura_id            INTEGER       NOT NULL REFERENCES factura(id_factura)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    numero_cuota          SMALLINT      NOT NULL,
    total_cuotas          SMALLINT      NOT NULL,
    monto                 NUMERIC(10,2) NOT NULL,
    fecha_pago            DATE          NOT NULL,
    CONSTRAINT uq_pago_cuota UNIQUE (factura_id, numero_cuota),
    CONSTRAINT chk_pago_numero_cuota CHECK (numero_cuota BETWEEN 1 AND 12),
    CONSTRAINT chk_pago_total_cuotas CHECK (total_cuotas BETWEEN 1 AND 12),
    CONSTRAINT chk_pago_cuota_menor CHECK (numero_cuota <= total_cuotas),
    CONSTRAINT chk_pago_monto CHECK (monto > 0)
);
COMMENT ON CONSTRAINT chk_pago_numero_cuota ON pago IS 'Valida numero de cuota entre 1 y 12.';
COMMENT ON CONSTRAINT chk_pago_total_cuotas ON pago IS 'Valida total de cuotas entre 1 y 12 pagos.';
COMMENT ON CONSTRAINT chk_pago_cuota_menor ON pago IS 'Valida que el numero de cuota no supere el total de cuotas.';
COMMENT ON CONSTRAINT chk_pago_monto ON pago IS 'Valida que el monto del pago sea mayor que cero.';