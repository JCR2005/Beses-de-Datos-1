-- Proyecto 1 - BD Hospitales de Occidente
-- 00_esquema.sql : convenciones del modelo y funciones de apoyo
--
-- Se ejecuta sobre una base de datos recien creada (createdb hospital).
--
-- Convenciones:
--   * tablas y columnas en snake_case y en singular.
--   * la llave primaria se llama id_<tabla> y es identity.
--   * la llave foranea se llama igual que la PK a la que apunta; si una tabla
--     referencia dos veces a la misma, se agrega el rol (id_medico_cirujano).
--   * restricciones con nombre: uq_ (unique), ck_ (check).
--   * no se guardan datos derivables (edad, dias hospitalizado): se calculan
--     en las vistas de 12_vistas.sql.
--
-- Acciones referenciales usadas (la justificacion de cada FK esta en el PDF):
--   on update cascade  -> en todas: las PK son identity y no se modifican, pero
--                         si llegara a pasar los hijos deben seguir al padre.
--   on delete restrict -> el hijo es historia clinica o financiera que no se
--                         puede perder, o el padre es un valor de catalogo.
--   on delete cascade  -> el hijo es un detalle que no existe sin su padre.

create schema if not exists public;
set search_path to public;

-- todas las fechas y horas se muestran en hora de Guatemala (UTC-6)
do $$
begin
    execute format('alter database %I set timezone to %L', current_database(), 'America/Guatemala');
end $$;
set timezone to 'America/Guatemala';

-- edad cumplida en una fecha dada; se usa en vistas y reportes
create function fn_edad(p_fecha_nacimiento date, p_fecha date default current_date)
returns smallint
language sql immutable
as $$
    select extract(year from age(p_fecha, p_fecha_nacimiento))::smallint;
$$;
