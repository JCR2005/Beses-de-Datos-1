-- Proyecto 1 - BD Hospitales de Occidente
-- 04_consulta_externa.sql : citas, consultas medicas y recetas

-- se agenda la cita del paciente con un medico en una clinica
create table cita (
    id_cita serial primary key,
    paciente_id integer not null references paciente(id_paciente)
        on delete no action on update cascade,
    medico_id integer not null references medico(id_medico)
        on delete no action on update cascade,
    fecha_hora timestamptz not null,
    num_clinica varchar(20) not null,
    medio_asignacion varchar(20),
    estado varchar(20) not null default 'programada',
    es_reconsulta boolean not null default false,
    es_referido boolean not null default false,
    costo_base numeric(10,2),
    costo_aplicado numeric(10,2),
    cancelada_sin_aviso boolean not null default false,
    -- valida por que medio se le aviso al paciente su cita
    check (medio_asignacion in ('telefonico','correo_institucional','recepcion_general','recepcion_medico')),
    -- valida en que situacion se encuentra la cita
    check (estado in ('programada','realizada','reprogramada','cancelada'))
);

-- se hace una consulta por cada cita realizada
create table consulta (
    id_consulta serial primary key,
    cita_id integer not null unique references cita(id_cita)
        on delete no action on update cascade,
    paciente_id integer not null references paciente(id_paciente)
        on delete no action on update cascade,
    medico_id integer not null references medico(id_medico)
        on delete no action on update cascade,
    fecha date not null,
    diagnostico text not null,
    otros_datos text,
    notas_observaciones text
);

create table receta (
    id_receta serial primary key,
    consulta_id integer not null unique references consulta(id_consulta)
        on delete no action on update cascade,
    fecha date not null,
    proxima_cita date
);

-- una receta lleva varios medicamentos, por eso es tabla aparte (asociativa M:N)
create table receta_medicamento (
    id_receta_medicamento serial primary key,
    receta_id integer not null references receta(id_receta)
        on delete cascade on update cascade,
    medicamento_nombre varchar(120) not null,
    dosis varchar(60) not null,
    duracion varchar(60)
);