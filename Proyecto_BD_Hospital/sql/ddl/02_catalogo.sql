-- Proyecto 1 - BD Hospitales de Occidente
-- 01_catalogo.sql : tablas de catalogo y datos generales

create table hospital (
    id_hospital serial primary key,
    nombre varchar(120) not null,
    informacion_especifica text,
    direccion varchar(250) not null
);

-- cada hospital tiene sus unidades de atencion
create table unidad_medica (
    id_unidad serial primary key,
    hospital_id integer not null references hospital(id_hospital) on delete cascade,
    nombre varchar(40) not null,
    costo_dia_hospitalizacion numeric(10,2),
    unique (hospital_id, nombre),
    check (nombre in ('Consulta Externa','Emergencias','Cirugia','Hospitalizacion','Otro'))
);

-- tipo de servicio que se atiende en cada unidad
create table servicio_atencion (
    id_servicio serial primary key,
    unidad_id integer not null references unidad_medica(id_unidad) on delete cascade,
    nombre varchar(80) not null,
    costo numeric(10,2),
    unique (unidad_id, nombre)
);

-- catalogo de especialidades medicas
create table especialidad (
    id_especialidad serial primary key,
    nombre varchar(80) not null unique
);

create table camilla (
    id_camilla serial primary key,
    hospital_id integer not null references hospital(id_hospital) on delete cascade,
    unidad_id integer not null references unidad_medica(id_unidad) on delete cascade,
    numero varchar(10) not null,
    disponible boolean not null default true,
    unique (hospital_id, numero)
);

-- quirofanos disponibles en el hospital
create table quirofano (
    id_quirofano serial primary key,
    hospital_id integer not null references hospital(id_hospital) on delete cascade,
    numero varchar(10) not null,
    estado varchar(20) not null default 'disponible',
    unique (hospital_id, numero),
    check (estado in ('disponible','ocupado','en_mantenimiento'))
);

-- personal medico del hospital
create table medico (
    id_medico serial primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    dpi varchar(20) not null unique,
    telefono varchar(20),
    municipio_id integer references municipio(id_municipio),
    area varchar(10),
    especialidad_id integer references especialidad(id_especialidad),
    tipo_medico varchar(20) not null,
    costo_primera_consulta numeric(10,2),
    horario_inicio time,
    horario_fin time,
    check (area in ('Urbana','Rural')),
    check (tipo_medico in ('residente','interno','externo','general','especialista'))
);

create table enfermero (
    id_enfermero serial primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    dpi varchar(20) not null unique,
    telefono varchar(20),
    tipo varchar(30) not null,
    check (tipo in ('registrado','practicante_de_enfermeria'))
);

-- insumos medicos y quirurgicos
create table insumo (
    id_insumo serial primary key,
    nombre varchar(120) not null,
    descripcion text,
    material varchar(80),
    tipo varchar(20) not null,
    check (tipo in ('medico','quirurgico','otro'))
);

create table instrumento (
    id_instrumento serial primary key,
    nombre varchar(120) not null,
    descripcion text,
    tipo varchar(20) not null,
    funcion varchar(30) not null,
    check (tipo in ('medico','quirurgico','otro')),
    check (funcion in ('corte','contencion','hemostatica','retractor','accesorio','implante','otro'))
);

create table equipo (
    id_equipo serial primary key,
    nombre varchar(120) not null,
    descripcion text,
    tipo varchar(20) not null,
    funcion varchar(30) not null,
    check (tipo in ('medico','quirurgico','otro')),
    check (funcion in ('exploracion','diagnostico','tratamiento','rehabilitacion','otro'))
);
