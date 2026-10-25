-- Proyecto 2 - BD Hospitales de Occidente
-- 01_auditoria.sql : bitacora automatica de cambios sensibles del personal (Bloque F)
--
-- Cada vez que cambia el salario, el nivel de acceso o la especialidad de alguien,
-- un disparador lo anota solo en la bitacora: quien lo cambio, que campo, el valor
-- de antes, el valor nuevo y la hora. Asi no depende de que alguien se acuerde.
--
-- Lo crea el rol administrativo, como pide el enunciado.

set role admin;

-- la bitacora: una fila por cada campo que cambia
create table auditoria_personal (
    id_auditoria integer generated always as identity primary key,
    fecha_hora timestamptz not null default now(),   -- momento exacto del cambio
    usuario varchar(63) not null,                    -- quien hizo el cambio
    tabla varchar(30) not null,                      -- personal o medico
    id_registro integer not null,                    -- a quien se le cambio el dato
    campo varchar(30) not null,                      -- que campo cambio
    valor_anterior text,                             -- como estaba antes
    valor_nuevo text                                 -- como quedo
);

-- cuando cambia el salario o el nivel de acceso de alguien del personal
-- old = la fila antes del update, new = la fila despues
create function fn_auditar_personal() returns trigger language plpgsql as $$
begin
    -- is distinct from es como <> pero tambien sirve cuando el valor es null
    if new.salario is distinct from old.salario then
        insert into auditoria_personal (usuario, tabla, id_registro, campo, valor_anterior, valor_nuevo)
        values (current_user, 'personal', new.id_personal, 'salario', old.salario, new.salario);
    end if;
    if new.nivel_acceso is distinct from old.nivel_acceso then
        insert into auditoria_personal (usuario, tabla, id_registro, campo, valor_anterior, valor_nuevo)
        values (current_user, 'personal', new.id_personal, 'nivel_acceso', old.nivel_acceso, new.nivel_acceso);
    end if;
    return new;
end $$;

-- despues de cada update en personal se ejecuta la funcion de arriba, fila por fila
create trigger trg_auditar_personal after update on personal
    for each row execute function fn_auditar_personal();

-- cuando cambia la especialidad de un medico
create function fn_auditar_medico() returns trigger language plpgsql as $$
begin
    if new.id_especialidad is distinct from old.id_especialidad then
        insert into auditoria_personal (usuario, tabla, id_registro, campo, valor_anterior, valor_nuevo)
        values (current_user, 'medico', new.id_medico, 'id_especialidad', old.id_especialidad, new.id_especialidad);
    end if;
    return new;
end $$;

-- despues de cada update en medico se ejecuta la funcion de arriba, fila por fila
create trigger trg_auditar_medico after update on medico
    for each row execute function fn_auditar_medico();

reset role;
