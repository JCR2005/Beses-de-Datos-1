-- Proyecto 1 - BD Hospitales de Occidente
-- 99_secuencias.sql : ajusta los identity despues de cargar datos con id fijo
--
-- Si el contador no se mueve, el siguiente INSERT sin id generaria un valor
-- que ya existe y chocaria con la llave primaria. Se recorre cada columna
-- identity del esquema y se deja su contador en el maximo id usado.

set search_path to public;

do $$
declare
    r record;
begin
    for r in
        select table_name, column_name
          from information_schema.columns
         where table_schema = 'public' and is_identity = 'YES'
    loop
        execute format(
            'select setval(pg_get_serial_sequence(%L, %L), coalesce(max(%I), 0) + 1, false) from %I',
            r.table_name, r.column_name, r.column_name, r.table_name);
    end loop;
end $$;
