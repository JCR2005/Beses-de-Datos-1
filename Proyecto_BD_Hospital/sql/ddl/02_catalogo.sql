-- Proyecto 1 - BD Hospitales de Occidente
-- 02_catalogo.sql : tablas de catalogo y datos generales

-- Sobre las acciones referenciales:
--   on update cascade  -> todas las llaves primarias son serial y nunca se actualizan;
--                         si alguna vez se cambiara, los hijos deben seguirla.
--   on delete cascade  -> el hijo no existe sin su padre (ej. una unidad sin hospital).
--   on delete no action-> el borrado se bloquea para no perder historia clinica.

-- cada hospital tiene sus unidades de atencion
create table hospital (
    id_hospital serial primary key,
    nombre varchar(120) not null,
    informacion_especifica text,
    direccion varchar(250) not null
);

create table unidad_medica (
    id_unidad serial primary key,
    hospital_id integer not null references hospital(id_hospital)
        on delete cascade on update cascade,
    nombre varchar(40) not null,
    costo_dia_hospitalizacion numeric(10,2),
    unique (hospital_id, nombre),
    -- valida que la unidad sea una de las 4 unidades del hospital mas "Otro"
    check (nombre in ('Consulta Externa','Emergencias','Cirugia','Hospitalizacion','Otro'))
);

-- tipo de servicio que se atiende en cada unidad
create table servicio_atencion (
    id_servicio serial primary key,
    unidad_id integer not null references unidad_medica(id_unidad)
        on delete cascade on update cascade,
    nombre varchar(80) not null,
    costo numeric(10,2),
    unique (unidad_id, nombre)
);

-- catalogo de especialidades medicas
create table especialidad (
    id_especialidad serial primary key,
    nombre varchar(80) not null unique
);

-- las camillas pertenecen a una unidad de hospitalizacion
create table camilla (
    id_camilla serial primary key,
    hospital_id integer not null references hospital(id_hospital)
        on delete cascade on update cascade,
    unidad_id integer not null references unidad_medica(id_unidad)
        on delete cascade on update cascade,
    numero varchar(10) not null,
    disponible boolean not null default true,
    unique (hospital_id, numero)
);

-- quirofanos disponibles en el hospital
create table quirofano (
    id_quirofano serial primary key,
    hospital_id integer not null references hospital(id_hospital)
        on delete cascade on update cascade,
    numero varchar(10) not null,
    estado varchar(20) not null default 'disponible',
    unique (hospital_id, numero),
    -- valida si el quirofano esta libre, ocupado o en mantenimiento
    check (estado in ('disponible','ocupado','en_mantenimiento'))
);

-- personal medico del hospital
create table medico (
    id_medico serial primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    dpi varchar(20) not null unique,
    telefono varchar(20),
    hospital_id integer not null references hospital(id_hospital)
        on delete cascade on update cascade,
    municipio_id integer not null references municipio(id_municipio)
        on delete no action on update cascade,
    area varchar(10) not null,
    especialidad_id integer references especialidad(id_especialidad)
        on delete no action on update cascade,
    tipo_medico varchar(20) not null,
    costo_primera_consulta numeric(10,2),
    horario_inicio time,
    horario_fin time,
    -- valida si el medico vive en zona urbana o rural
    check (area in ('Urbana','Rural')),
    -- valida la modalidad del medico dentro del hospital
    check (tipo_medico in ('residente','interno','externo','general','especialista'))
);

create table enfermero (
    id_enfermero serial primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    dpi varchar(20) not null unique,
    telefono varchar(20),
    tipo varchar(30) not null,
    -- valida si el enfermero tiene titulo o es practicante
    check (tipo in ('registrado','practicante_de_enfermeria'))
);

-- insumos medicos y quirurgicos
create table insumo (
    id_insumo serial primary key,
    nombre varchar(120) not null,
    descripcion text,
    material varchar(80),
    tipo varchar(20),
    unidad_medida varchar(20),
    costo_unitario numeric(10,2),
    stock_minimo integer,
    stock_actual integer,
    -- valida si el insumo es medico, quirurgico u otro
    check (tipo in ('medico','quirurgico','otro'))
);

create table instrumento (
    id_instrumento serial primary key,
    nombre varchar(120) not null,
    tipo varchar(30) not null,
    estado varchar(20) not null default 'disponible',
    -- valida si el instrumento esta disponible, en uso o en mantenimiento
    check (estado in ('disponible','en_uso','en_mantenimiento'))
);

create table equipo (
    id_equipo serial primary key,
    nombre varchar(120) not null,
    descripcion text,
    estado varchar(20) not null default 'disponible',
    -- valida si el equipo esta disponible, en uso o en mantenimiento
    check (estado in ('disponible','en_uso','en_mantenimiento'))
);
