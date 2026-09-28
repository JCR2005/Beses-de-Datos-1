-- Proyecto 1 - BD Hospitales de Occidente
-- 08_facturacion.sql : factura y pagos en cuotas

create table factura (
    id_factura serial primary key,
    paciente_id integer not null references paciente(id_paciente),
    fecha_emision timestamptz not null,
    descripcion text not null,
    total numeric(10,2) not null,
    cita_id integer references cita(id_cita),
    ingreso_id integer references ingreso(id_ingreso),
    cirugia_id integer references cirugia(id_cirugia),
    check (total >= 0)
);

-- la factura se puede pagar en cuotas mensuales
create table pago (
    id_pago serial primary key,
    factura_id integer not null references factura(id_factura) on delete cascade,
    numero_cuota smallint not null,
    total_cuotas smallint not null,
    monto numeric(10,2) not null,
    fecha_pago date not null,
    unique (factura_id, numero_cuota),
    check (numero_cuota between 1 and 12),
    check (total_cuotas between 1 and 12),
    check (monto > 0)
);
