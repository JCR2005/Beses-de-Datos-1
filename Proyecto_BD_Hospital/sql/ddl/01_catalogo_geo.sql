-- Proyecto 1 - BD Hospitales de Occidente
-- 01_catalogo_geo.sql : catalogo de departamentos y municipios de Guatemala

-- catalogo maestro: los 22 departamentos del pais
create table departamento (
    id_departamento serial primary key,
    nombre varchar(80) not null unique
);

-- los municipios dependen del departamento al que pertenecen
create table municipio (
    id_municipio serial primary key,
    departamento_id integer not null references departamento(id_departamento)
        on delete no action on update cascade,
    nombre varchar(80) not null,
    -- impide repetir un municipio dentro del mismo departamento
    unique (departamento_id, nombre)
);