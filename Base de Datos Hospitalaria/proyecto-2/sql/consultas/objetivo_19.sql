-- Proyecto 2 - Objetivo 19 (Bloque E)
-- Aqui reviso el reporte de cirugias que nos dieron y propongo como separarlo en tablas.
--
-- El reporte viene todo en una sola tabla:
--   Reporte_Cirugia (Id_cirugia, Nombre_cirujano, Especialidad_cirujano, Nombre_paciente,
--                    Codigo_diagnostico, Descripcion_diagnostico, Nombre_insumo_1,
--                    Cantidad_insumo_1, Nombre_insumo_2, Cantidad_insumo_2, Fecha)
--
-- Que problemas tiene (una frase cada uno):
--   * 1FN: insumo_1 e insumo_2 son un grupo repetitivo, asi que no caben mas de 2 insumos y si usa uno queda vacio el otro.
--   * 2FN: al poner un insumo por fila la llave pasa a ser (cirugia, insumo), pero el cirujano, paciente, diagnostico y fecha solo dependen de la cirugia (media llave).
--   * 3FN: la especialidad depende del cirujano y la descripcion depende del codigo del diagnostico, no de la cirugia.
--   * Datos repetidos: la especialidad y la descripcion se vuelven a escribir en cada cirugia.
--   * Al actualizar: si un cirujano cambia de especialidad hay que cambiar todas sus filas, y si falta una queda contradictorio.
--   * Al insertar: no puedo guardar un cirujano, diagnostico o insumo nuevo hasta que salga en una cirugia.
--   * Al borrar: si borro la unica cirugia de un diagnostico tambien pierdo su descripcion.
--   * Identificador: usa nombres para identificar a las personas, y dos se pueden llamar igual.
--
-- Mi propueta en 3FN son las 7 tablas de abajo. Es solo la propuesta: no se corre
-- sobre la base del hospital porque ahi ya existen tablas con estos nombre.

-- las especialidades, cada una una sola vez
create table especialidad (
    id_especialidad integer generated always as identity primary key,
    nombre varchar(80) not null,
    constraint uq_especialidad_nombre unique (nombre)
);

-- cirujanos: la especialidad va aqui porque depende del cirujano, no de la cirugia
create table cirujano (
    id_cirujano integer generated always as identity primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    id_especialidad integer not null references especialidad(id_especialidad)
        on delete restrict on update cascade
);

-- los pacientes
create table paciente (
    id_paciente integer generated always as identity primary key,
    nombres varchar(100) not null,
    apellidos varchar(100) not null
);

-- diagnosticos: la descripcion va aqui porque depende del codigo, no de la cirugia
create table diagnostico (
    codigo_cie10 varchar(7) primary key,
    descripcion varchar(200) not null,
    -- el codigo CIE-10 tiene que medir de 3 a 7 (de K35 a K35.81)
    constraint ck_diagnostico_codigo check (length(codigo_cie10) between 3 and 7)
);

-- los insumos, cada uno una sola vez
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

-- los insumos de cada cirugia, ya sin limite de 2 (tabla intermedia N:M)
create table cirugia_insumo (
    id_cirugia integer not null references cirugia(id_cirugia)
        on delete cascade on update cascade,
    id_insumo integer not null references insumo(id_insumo)
        on delete restrict on update cascade,
    cantidad smallint not null,
    primary key (id_cirugia, id_insumo),
    -- por lo menos tiene que usar 1
    constraint ck_cirugia_insumo_cantidad check (cantidad > 0)
);
