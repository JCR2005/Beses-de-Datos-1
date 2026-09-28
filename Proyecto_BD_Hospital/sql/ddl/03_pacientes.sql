-- Proyecto 1 - BD Hospitales de Occidente
-- 03_pacientes.sql : pacientes y sus encargados

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
    municipio_id integer references municipio(id_municipio),
    area varchar(10),
    estado_civil varchar(30),
    no_seguro_social varchar(30),
    check (edad_años between 0 and 120),
    check (sexo in ('Masculino','Femenino')),
    check (area in ('Urbana','Rural'))
);

-- el encargado es la persona responsable del paciente, no es un paciente
create table encargado (
    id_encargado serial primary key,
    nombre varchar(150) not null,
    dpi varchar(20) unique,
    telefono varchar(20),
    municipio_id integer references municipio(id_municipio),
    area varchar(10),
    check (area in ('Urbana','Rural'))
);

-- un paciente puede tener varios encargados y un encargado puede llevar
-- varios pacientes, por eso es tabla intermedia
create table paciente_encargado (
    id_paciente_encargado serial primary key,
    paciente_id integer not null references paciente(id_paciente) on delete cascade,
    encargado_id integer not null references encargado(id_encargado) on delete cascade,
    parentesco varchar(40) not null,
    unique (paciente_id, encargado_id)
);
