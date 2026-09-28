-- Proyecto 1 - BD Hospitales de Occidente
-- 01_catalogo_geo.sql : catalogo de departamentos y municipios de Guatemala

create table departamento (
    id_departamento serial primary key,
    nombre varchar(80) not null unique
);

-- los municipios dependen del departamento al que pertenecen
create table municipio (
    id_municipio serial primary key,
    departamento_id integer not null references departamento(id_departamento),
    nombre varchar(80) not null,
    unique (departamento_id, nombre)
);

insert into departamento (nombre) values
('Alta Verapaz'),('Baja Verapaz'),('Chimaltenango'),('Chiquimula'),
('El Progreso'),('Escuintla'),('Guatemala'),('Huehuetenango'),('Izabal'),
('Jalapa'),('Jutiapa'),('Petén'),('Quetzaltenango'),('Quiché'),
('Retalhuleu'),('Sacatepéquez'),('San Marcos'),('Santa Rosa'),('Sololá'),
('Suchitepéquez'),('Totonicapán'),('Zacapa');

-- municipios que se usan en los datos ficticios del hospital
insert into municipio (departamento_id, nombre)
select id_departamento, 'Quetzaltenango' from departamento where nombre='Quetzaltenango';
insert into municipio (departamento_id, nombre)
select id_departamento, 'Coatepeque' from departamento where nombre='Quetzaltenango';
insert into municipio (departamento_id, nombre)
select id_departamento, 'Olintepeque' from departamento where nombre='Quetzaltenango';
insert into municipio (departamento_id, nombre)
select id_departamento, 'Zunil' from departamento where nombre='Quetzaltenango';
insert into municipio (departamento_id, nombre)
select id_departamento, 'Cantel' from departamento where nombre='Quetzaltenango';
insert into municipio (departamento_id, nombre)
select id_departamento, 'San Marcos' from departamento where nombre='San Marcos';
insert into municipio (departamento_id, nombre)
select id_departamento, 'Totonicapán' from departamento where nombre='Totonicapán';
