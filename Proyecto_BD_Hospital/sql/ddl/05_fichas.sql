-- Proyecto 1 - BD Hospitales de Occidente
-- 05_fichas.sql : fichas de ingreso, egreso y traslado

-- el paciente ingresa a una unidad medica por un motivo clinico
create table ingreso (
    id_ingreso serial primary key,
    paciente_id integer not null references paciente(id_paciente)
        on delete no action on update cascade,
    unidad_id integer not null references unidad_medica(id_unidad)
        on delete no action on update cascade,
    servicio_id integer references servicio_atencion(id_servicio)
        on delete no action on update cascade,
    camilla_id integer references camilla(id_camilla)
        on delete no action on update cascade,
    motivo_ingreso text not null,
    fecha_hora_ingreso timestamptz not null,
    medico_encargado_id integer not null references medico(id_medico)
        on delete no action on update cascade,
    diagnostico_presuntivo text
);

-- cada ingreso tiene un solo egreso
create table egreso (
    id_egreso serial primary key,
    ingreso_id integer not null unique references ingreso(id_ingreso)
        on delete no action on update cascade,
    diagnostico_principal text not null,
    diagnosticos_secundarios text,
    motivo_egreso text not null,
    unidad_id integer not null references unidad_medica(id_unidad)
        on delete no action on update cascade,
    servicio_id integer references servicio_atencion(id_servicio)
        on delete no action on update cascade,
    fecha_hora_egreso timestamptz not null,
    medico_id integer not null references medico(id_medico)
        on delete no action on update cascade,
    camilla_id integer references camilla(id_camilla)
        on delete no action on update cascade,
    codigo_egreso varchar(15) not null,
    egreso_sin_consentimiento boolean not null default false,
    motivo_egreso_sin_consentimiento text,
    dias_hospitalizado smallint,
    codigo_traslado varchar(20),
    referido_otro_hospital boolean not null default false,
    -- valida la condicion en que el paciente sale del hospital
    check (codigo_egreso in ('vivo','muerto','embarazo','parto'))
);

-- traslado de un paciente entre unidades, interno o a otro hospital
create table traslado (
    id_traslado serial primary key,
    fecha_hora timestamptz not null,
    paciente_id integer not null references paciente(id_paciente)
        on delete no action on update cascade,
    medico_indica_id integer not null references medico(id_medico)
        on delete no action on update cascade,
    unidad_origen_id integer not null references unidad_medica(id_unidad)
        on delete no action on update cascade,
    unidad_destino_id integer not null references unidad_medica(id_unidad)
        on delete no action on update cascade,
    interno_externo varchar(10) not null,
    hospital_externo_nombre varchar(120),
    hospital_externo_direccion varchar(250),
    ingreso_id integer references ingreso(id_ingreso)
        on delete no action on update cascade,
    consulta_id integer references consulta(id_consulta)
        on delete no action on update cascade,
    -- valida si el traslado es dentro del hospital o hacia otro hospital
    check (interno_externo in ('interno','externo')),
    -- valida que el traslado provenga de una consulta o de un ingreso, pero no ambos
    check (
        ((consulta_id IS NOT NULL)::int + (ingreso_id IS NOT NULL)::int) = 1
    )
);