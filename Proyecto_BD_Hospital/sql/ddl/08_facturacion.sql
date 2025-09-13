-- Proyecto 1 - BD Hospitales de Occidente
-- 08_facturacion.sql : factura y pagos en cuotas

-- al terminar el proceso se emite la factura del servicio brindado
create table factura (
    id_factura serial primary key,
    paciente_id integer not null references paciente(id_paciente)
        on delete no action on update cascade,
    fecha_emision timestamptz not null,
    descripcion text not null,
    total numeric(10,2) not null,
    cita_id integer references cita(id_cita)
        on delete no action on update cascade,
    ingreso_id integer references ingreso(id_ingreso)
        on delete no action on update cascade,
    cirugia_id integer references cirugia(id_cirugia)
        on delete no action on update cascade,
    -- valida que el monto facturado no sea negativo
    check (total >= 0),
    -- valida que la factura tenga exactamente un origen (cita, cirugia o ingreso)
    check (
        ((cita_id IS NOT NULL)::int +
         (cirugia_id IS NOT NULL)::int +
         (ingreso_id IS NOT NULL)::int) = 1
    )
);

-- la factura se puede pagar en cuotas mensuales (asociativa 1:N)
create table pago (
    id_pago serial primary key,
    factura_id integer not null references factura(id_factura)
        on delete cascade on update cascade,
    numero_cuota smallint not null,
    total_cuotas smallint not null,
    monto numeric(10,2) not null,
    fecha_pago date not null,
    -- impide pagar dos veces la misma cuota de la misma factura
    unique (factura_id, numero_cuota),
    -- valida que la cuota sea una de las 12 mensualidades del ano
    check (numero_cuota between 1 and 12),
    -- valida que el plan no tenga mas de 12 cuotas
    check (total_cuotas between 1 and 12),
    -- valida que el monto pagado sea mayor que cero
    check (monto > 0)
);