-- Proyecto 2 - Objetivo 19 (Bloque E)
-- Revision del reporte de cirugias y propuesta normalizada.
--
-- Estructura actual, una sola tabla:
--   Reporte_Cirugia (Id_cirugia, Nombre_cirujano, Especialidad_cirujano, Nombre_paciente,
--                    Codigo_diagnostico, Descripcion_diagnostico, Nombre_insumo_1,
--                    Cantidad_insumo_1, Nombre_insumo_2, Cantidad_insumo_2, Fecha)
--
-- Problemas (el analisis completo esta en el PDF):
--   * 1FN: Nombre_insumo_1/2 y Cantidad_insumo_1/2 son un grupo repetitivo; no
--     se puede registrar un tercer insumo y sobran nulos cuando se usa uno solo.
--   * 2FN: al separar los insumos la llave seria (Id_cirugia, insumo) y los demas
--     datos dependen solo de Id_cirugia (dependencia parcial).
--   * 3FN: Nombre_cirujano -> Especialidad_cirujano y Codigo_diagnostico ->
--     Descripcion_diagnostico son dependencias transitivas a traves de Id_cirugia.
--   * Redundancia: la especialidad del cirujano y la descripcion del diagnostico
--     se repiten en cada cirugia.
--   * Anomalia de actualizacion: cambiar la especialidad de un cirujano obliga a
--     modificar todas sus filas; si falta una, el reporte queda contradictorio.
--   * Anomalia de insercion: no se puede registrar un cirujano, un diagnostico o
--     un insumo que todavia no aparece en ninguna cirugia.
--   * Anomalia de eliminacion: borrar la unica cirugia de un diagnostico borra
--     tambien su descripcion.
--   * Los nombres no sirven como identificador: dos personas pueden llamarse igual.
--
-- La propuesta se crea en el esquema propuesta_bloque_e para no mezclarla con
-- el modelo del hospital (que ya resuelve esto con medico, especialidad,
-- diagnostico, insumo, cirugia y cirugia_insumo).

begin;
set search_path to public;

-- el superusuario crea el esquema y se lo asigna al rol administrativo
create schema propuesta_bloque_e authorization admin;
grant usage on schema propuesta_bloque_e to visor;

set role admin;
set search_path to propuesta_bloque_e;

-- ============================================================
-- estructura original, solo para mostrar las anomalias
-- ============================================================

-- reporte tal como lo usa el area de informatica (sin normalizar)
create table reporte_cirugia (
    id_cirugia integer primary key,
    nombre_cirujano varchar(150),
    especialidad_cirujano varchar(80),
    nombre_paciente varchar(150),
    codigo_diagnostico varchar(7),
    descripcion_diagnostico varchar(200),
    nombre_insumo_1 varchar(120),
    cantidad_insumo_1 smallint,
    nombre_insumo_2 varchar(120),
    cantidad_insumo_2 smallint,
    fecha date
);

insert into reporte_cirugia values
(1, 'Ana López', 'Cirugía General', 'Pedro Gómez', 'K35.8', 'Apendicitis aguda', 'Gasas estériles', 4, 'Sutura vicryl 3-0', 2, '2026-03-02'),
(2, 'Ana López', 'Cirugía General', 'Lucía Paz', 'K40.9', 'Hernia inguinal', 'Gasas estériles', 3, null, null, '2026-03-09'),
-- la especialidad de Ana López quedo distinta en esta fila: anomalia de actualizacion
(3, 'Ana López', 'Videolaparoscopia', 'Mario Sic', 'K35.8', 'Apendicitis aguda', 'Gasas estériles', 2, 'Hoja de bisturí #10', 1, '2026-03-15'),
(4, 'Luis Rojas', 'Cirugía Ortopédica', 'Sofía Tum', 'S72.0', 'Fractura del cuello del fémur', 'Placa de osteosíntesis', 1, 'Gasas estériles', 6, '2026-03-20');

-- ============================================================
-- propuesta normalizada (3FN)
-- ============================================================

-- especialidades quirurgicas
create table especialidad (
    id_especialidad integer generated always as identity primary key,
    nombre varchar(80) not null,
    constraint uq_especialidad_nombre unique (nombre)
);

-- cirujanos: la especialidad depende del cirujano, no de la cirugia
create table cirujano (
    id_cirujano integer generated always as identity primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    id_especialidad integer not null references especialidad(id_especialidad)
        on delete restrict on update cascade
);

-- pacientes
create table paciente (
    id_paciente integer generated always as identity primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null
);

-- diagnosticos: la descripcion depende del codigo, no de la cirugia
create table diagnostico (
    codigo_cie10 varchar(7) primary key,
    descripcion varchar(200) not null,
    -- valida el formato del codigo CIE-10
    constraint ck_diagnostico_codigo check (codigo_cie10 ~ '^[A-Z][0-9]{2}(\.[0-9]{1,2})?$')
);

-- insumos
create table insumo (
    id_insumo integer generated always as identity primary key,
    nombre varchar(120) not null,
    constraint uq_insumo_nombre unique (nombre)
);

-- cada cirugia: quien opera, a quien, por que diagnostico y cuando
create table cirugia (
    id_cirugia integer primary key,
    id_cirujano integer not null references cirujano(id_cirujano)
        on delete restrict on update cascade,
    id_paciente integer not null references paciente(id_paciente)
        on delete restrict on update cascade,
    codigo_cie10 varchar(7) not null references diagnostico(codigo_cie10)
        on delete restrict on update cascade,
    fecha date not null
);

-- insumos de cada cirugia, sin limite de cantidad de insumos (asociativa M:N)
create table cirugia_insumo (
    id_cirugia integer not null references cirugia(id_cirugia)
        on delete cascade on update cascade,
    id_insumo integer not null references insumo(id_insumo)
        on delete restrict on update cascade,
    cantidad smallint not null,
    primary key (id_cirugia, id_insumo),
    -- valida que se use al menos una unidad
    constraint ck_cirugia_insumo_cantidad check (cantidad > 0)
);

-- migracion de los datos del reporte a la propuesta; la especialidad
-- contradictoria de la fila 3 se corrige al guardarla una sola vez
insert into especialidad (nombre) values ('Cirugía General'), ('Cirugía Ortopédica');
insert into cirujano (nombres, apellidos, id_especialidad)
values ('Ana', 'López', (select id_especialidad from especialidad where nombre = 'Cirugía General')),
       ('Luis', 'Rojas', (select id_especialidad from especialidad where nombre = 'Cirugía Ortopédica'));
insert into paciente (nombres, apellidos)
values ('Pedro', 'Gómez'), ('Lucía', 'Paz'), ('Mario', 'Sic'), ('Sofía', 'Tum');
insert into diagnostico
select distinct codigo_diagnostico, descripcion_diagnostico from reporte_cirugia;
insert into insumo (nombre)
select nombre_insumo_1 from reporte_cirugia union
select nombre_insumo_2 from reporte_cirugia where nombre_insumo_2 is not null;
insert into cirugia
select r.id_cirugia, c.id_cirujano, p.id_paciente, r.codigo_diagnostico, r.fecha
  from reporte_cirugia r
  join cirujano c on c.nombres || ' ' || c.apellidos = r.nombre_cirujano
  join paciente p on p.nombres || ' ' || p.apellidos = r.nombre_paciente;
insert into cirugia_insumo
select r.id_cirugia, i.id_insumo, r.cantidad_insumo_1
  from reporte_cirugia r join insumo i on i.nombre = r.nombre_insumo_1
union all
select r.id_cirugia, i.id_insumo, r.cantidad_insumo_2
  from reporte_cirugia r join insumo i on i.nombre = r.nombre_insumo_2;

grant select on all tables in schema propuesta_bloque_e to visor;

reset role;
commit;

-- el reporte se reconstruye con JOIN, sin perder informacion y con un
-- numero ilimitado de insumos por cirugia (una fila por insumo)
set role visor;
select ci.id_cirugia, cj.nombres || ' ' || cj.apellidos as cirujano, es.nombre as especialidad,
       p.nombres || ' ' || p.apellidos as paciente, d.codigo_cie10, d.descripcion,
       i.nombre as insumo, x.cantidad, ci.fecha
  from propuesta_bloque_e.cirugia ci
  join propuesta_bloque_e.cirujano cj on cj.id_cirujano = ci.id_cirujano
  join propuesta_bloque_e.especialidad es on es.id_especialidad = cj.id_especialidad
  join propuesta_bloque_e.paciente p on p.id_paciente = ci.id_paciente
  join propuesta_bloque_e.diagnostico d on d.codigo_cie10 = ci.codigo_cie10
  join propuesta_bloque_e.cirugia_insumo x on x.id_cirugia = ci.id_cirugia
  join propuesta_bloque_e.insumo i on i.id_insumo = x.id_insumo
 order by ci.id_cirugia, i.nombre;
reset role;
