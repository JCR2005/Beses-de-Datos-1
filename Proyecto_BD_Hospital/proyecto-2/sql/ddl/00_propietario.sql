-- Proyecto 2 - BD Hospitales de Occidente
-- 00_propietario.sql : el rol administrativo pasa a ser dueño del esquema
--
-- En PostgreSQL solo el dueño de una tabla puede alterarla (ALTER TABLE) o
-- crearle disparadores. El enunciado pide que la extension del modelo
-- (Bloque B) y la auditoria (Bloque F) las haga el rol administrativo, asi
-- que primero se le transfiere la propiedad de lo creado en el Proyecto 1.
--
-- Lo ejecuta el dueño actual (hospital). Se puede ejecutar varias veces.

set search_path to public;

do $$
declare
    r record;
begin
    -- tablas y vistas (las secuencias identity cambian de dueño junto con su tabla)
    for r in
        select c.relname, c.relkind
          from pg_class c
         where c.relnamespace = 'public'::regnamespace
           and c.relkind in ('r', 'v')
           and pg_get_userbyid(c.relowner) <> 'admin'
    loop
        execute format('alter %s %I owner to admin',
                       case r.relkind when 'v' then 'view' else 'table' end, r.relname);
    end loop;

    -- funciones (incluye las de los disparadores)
    for r in
        select p.oid::regprocedure as firma
          from pg_proc p
         where p.pronamespace = 'public'::regnamespace
           and pg_get_userbyid(p.proowner) <> 'admin'
    loop
        execute format('alter function %s owner to admin', r.firma);
    end loop;
end $$;

-- lo que admin cree desde ahora (Proyecto 2) queda disponible para visor:
-- lectura de tablas y vistas, y ejecucion de las funciones de consulta
alter default privileges for role admin in schema public
    grant select on tables to visor;
alter default privileges for role admin in schema public
    revoke execute on functions from public;
alter default privileges for role admin in schema public
    grant execute on functions to visor;
