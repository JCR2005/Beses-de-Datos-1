-- Proyecto 1 - BD Hospitales de Occidente
-- 03_pacientes.sql : pacientes y sus encargados

-- el paciente es el centro del modelo: todo lo demas cuelga de el
create table paciente (
    id_paciente serial primary key,
    codigo_expediente varchar(20) not null unique,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    fecha_nacimiento date not null,
    edad_años smallint not null,
    sexo varchar(10) not null,
    dpi varchar(20) unique,
    telefono varchar(20),
    municipio_id integer not null references municipio(id_municipio)
        on delete no action on update cascade,
    area varchar(10) not null,
    estado_civil varchar(30),
    no_seguro_social varchar(30),
    -- valida que la edad sea humana (0 a 120 años)
    check (edad_años between 0 and 120),
    -- valida el sexo registrado en la ficha del paciente
    check (sexo in ('Masculino','Femenino')),
    -- valida si el paciente vive en zona urbana o rural
    check (area in ('Urbana','Rural'))
);

-- el encargado es la persona responsable del paciente, no es un paciente
create table encargado (
    id_encargado serial primary key,
    nombre varchar(150) not null,
    dpi varchar(20) unique,
    telefono varchar(20),
    municipio_id integer not null references municipio(id_municipio)
        on delete no action on update cascade,
    area varchar(10) not null,
    -- valida si el encargado vive en zona urbana o rural
    check (area in ('Urbana','Rural'))
);

-- un paciente puede tener varios encargados y un encargado puede llevar
-- varios pacientes, por eso es tabla intermedia (asociativa M:N)
create table paciente_encargado (
    id_paciente_encargado serial primary key,
    paciente_id integer not null references paciente(id_paciente)
        on delete cascade on update cascade,
    encargado_id integer not null references encargado(id_encargado)
        on delete cascade on update cascade,
    parentesco varchar(40) not null,
    -- impide registrar dos veces al mismo encargado para el mismo paciente
    unique (paciente_id, encargado_id)
);