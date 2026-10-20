-- Proyecto 1 - BD Hospitales de Occidente
-- 01_roles.sql : control de acceso (DCL)
--
-- Roles:
--   visor -> solo lectura, para auditoria y reportes.
--   admin -> privilegios completos sobre el esquema.
-- Las contraseñas no se guardan en el repositorio; despues de crear los roles
-- se asignan desde psql con:  \password visor   y   \password admin

set search_path to public;

do $$
begin
    if not exists (select 1 from pg_roles where rolname = 'visor') then
        create role visor login nosuperuser nocreatedb nocreaterole;
    end if;
    if not exists (select 1 from pg_roles where rolname = 'admin') then
        create role admin login nosuperuser nocreatedb nocreaterole;
    end if;
end $$;

-- solo los roles del proyecto se pueden conectar a esta base
do $$
begin
    execute format('revoke all on database %I from public, visor, admin', current_database());
    execute format('grant connect on database %I to visor, admin', current_database());
end $$;

-- se parte de cero: nadie mas que el dueño tiene permisos sobre el esquema
revoke all on schema public from public, visor, admin;
revoke all on all tables in schema public from public, visor, admin;
revoke all on all sequences in schema public from public, visor, admin;
revoke all on all functions in schema public from public, visor, admin;

-- ---------- admin: lectura, escritura y creacion de objetos ----------
grant usage, create on schema public to admin;
grant all privileges on all tables in schema public to admin;
grant all privileges on all sequences in schema public to admin;
grant all privileges on all functions in schema public to admin;

-- ---------- visor: solo lectura de tablas y vistas ----------
grant usage on schema public to visor;
grant select on all tables in schema public to visor;
-- las vistas calculan la edad y el tipo de unidad con estas funciones
grant execute on function fn_edad(date, date), fn_tipo_unidad(integer) to visor;

-- los objetos que el dueño cree despues (Proyecto 2) heredan los mismos permisos
alter default privileges for role hospital in schema public
    grant all privileges on tables to admin;
alter default privileges for role hospital in schema public
    grant all privileges on sequences to admin;
alter default privileges for role hospital in schema public
    grant all privileges on functions to admin;
alter default privileges for role hospital in schema public
    grant select on tables to visor;
alter default privileges for role hospital in schema public
    revoke execute on functions from public;
