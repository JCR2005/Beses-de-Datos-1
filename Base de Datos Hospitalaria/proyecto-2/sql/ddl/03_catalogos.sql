-- Proyecto 2 - BD Hospitales de Occidente
-- 03_catalogos.sql : catalogos para los CHECK que tenian muchas opciones
--
-- Cada catalogo usa como llave el mismo codigo que ya se guardaba en la
-- columna, asi los datos existentes no cambian: solo se quita el CHECK y se
-- pone una llave foranea hacia el catalogo.

set role admin;

-- formas en que se entrega un medicamento
create table forma_farmaceutica (
    codigo varchar(12) primary key,
    descripcion varchar(100) not null
);

insert into forma_farmaceutica values
('tableta', 'Tableta sólida para tomar por vía oral'),
('capsula', 'Cápsula para tomar por vía oral'),
('jarabe', 'Líquido espeso para tomar por vía oral'),
('suspension', 'Líquido con partículas que se agita antes de tomar'),
('inyectable', 'Solución para aplicar con jeringa'),
('crema', 'Uso tópico sobre la piel'),
('gotas', 'Gotas oftálmicas, óticas u orales'),
('inhalador', 'Dosis que se inhala por la boca');

-- funcion que cumple un instrumento en la cirugia
create table funcion_instrumento (
    codigo varchar(12) primary key,
    descripcion varchar(100) not null
);

insert into funcion_instrumento values
('corte', 'Corta o diseca tejido'),
('contencion', 'Sujeta o sostiene tejidos o agujas'),
('hemostatica', 'Detiene el sangrado'),
('retractor', 'Separa los bordes de la herida'),
('accesorio', 'Apoyo durante el procedimiento'),
('implante', 'Queda dentro del paciente'),
('otro', 'Otra función');

-- funcion que cumple un equipo medico
create table funcion_equipo (
    codigo varchar(14) primary key,
    descripcion varchar(100) not null
);

insert into funcion_equipo values
('exploracion', 'Permite revisar al paciente'),
('diagnostico', 'Ayuda a identificar la enfermedad'),
('tratamiento', 'Se usa para tratar al paciente'),
('rehabilitacion', 'Apoya la recuperación'),
('otro', 'Otra función');

-- clasificacion del riesgo anestesico de la ASA
create table clasificacion_asa (
    codigo varchar(3) primary key,
    descripcion varchar(100) not null
);

insert into clasificacion_asa values
('I', 'Paciente sano'),
('II', 'Enfermedad sistémica leve'),
('III', 'Enfermedad sistémica grave'),
('IV', 'Enfermedad grave que amenaza la vida'),
('V', 'Paciente moribundo que no sobrevivirá sin la operación'),
('VI', 'Muerte cerebral, donante de órganos');

-- modalidad del medico dentro del hospital
create table tipo_medico (
    codigo varchar(12) primary key,
    descripcion varchar(100) not null
);

insert into tipo_medico values
('general', 'Médico general contratado'),
('especialista', 'Médico especialista contratado'),
('residente', 'Médico residente en formación'),
('interno', 'Médico interno en formación'),
('externo', 'Cirujano de otra institución que solo llega a operar');

-- medio por el que se asigna una cita de consulta externa
create table medio_asignacion (
    codigo varchar(20) primary key,
    descripcion varchar(100) not null
);

insert into medio_asignacion values
('telefonico', 'Llamada al número de Hospitales de Occidente'),
('correo_institucional', 'Correo institucional'),
('recepcion_general', 'Recepción general del hospital'),
('recepcion_medico', 'Recepción del médico');

-- se cambia cada CHECK por la llave foranea a su catalogo
alter table medicamento drop constraint ck_medicamento_forma;
alter table medicamento add constraint fk_medicamento_forma
    foreign key (forma_farmaceutica) references forma_farmaceutica(codigo)
    on delete restrict on update cascade;

alter table instrumento drop constraint ck_instrumento_funcion;
alter table instrumento add constraint fk_instrumento_funcion
    foreign key (funcion) references funcion_instrumento(codigo)
    on delete restrict on update cascade;

alter table equipo drop constraint ck_equipo_funcion;
alter table equipo add constraint fk_equipo_funcion
    foreign key (funcion) references funcion_equipo(codigo)
    on delete restrict on update cascade;

alter table chequeo_preanestesico drop constraint ck_chequeo_asa;
alter table chequeo_preanestesico add constraint fk_chequeo_asa
    foreign key (clasificacion_asa) references clasificacion_asa(codigo)
    on delete restrict on update cascade;

alter table medico drop constraint ck_medico_tipo;
alter table medico add constraint fk_medico_tipo
    foreign key (tipo_medico) references tipo_medico(codigo)
    on delete restrict on update cascade;

alter table cita drop constraint ck_cita_medio;
alter table cita add constraint fk_cita_medio
    foreign key (medio_asignacion) references medio_asignacion(codigo)
    on delete restrict on update cascade;

reset role;
