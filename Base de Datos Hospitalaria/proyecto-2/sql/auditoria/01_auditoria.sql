-- Proyecto 2 - BD Hospitales de Occidente
-- 01_auditoria.sql : bitacora automatica de cambios sensibles del personal (Bloque F)
--
-- Cada cambio de salario, nivel de acceso o especialidad queda registrado por
-- disparadores de la base, sin depender de la aplicacion ni del usuario.
--
-- Para que la bitacora sea confiable nadie debe poder modificarla, ni siquiera
-- el rol administrativo. Por eso:
--   * la tabla pertenece a un rol sin login (dueno_auditoria) creado aqui por
--     el superusuario, porque admin no puede crear roles;
--   * solo la funcion fn_registrar_auditoria (security definer, del mismo rol)
--     puede insertar en ella;
--   * admin crea los disparadores sobre sus tablas y solo puede leer la bitacora.

begin;
set search_path to public;

-- ============================================================
-- parte del superusuario: rol dueño, tabla y funcion de registro
-- ============================================================

do $$
begin
    if not exists (select 1 from pg_roles where rolname = 'dueno_auditoria') then
        create role dueno_auditoria nologin;
    end if;
end $$;

grant usage, create on schema public to dueno_auditoria;

-- bitacora de cambios de datos sensibles: una fila por campo modificado
create table auditoria_personal (
    id_auditoria bigint generated always as identity primary key,
    fecha_hora timestamptz not null default clock_timestamp(),
    usuario_bd varchar(63) not null,
    usuario_sesion varchar(63) not null,
    usuario_aplicacion varchar(100),
    tabla varchar(30) not null,
    id_registro integer not null,
    campo varchar(30) not null,
    valor_anterior text,
    valor_nuevo text,
    -- valida que solo se registren los campos sensibles que se auditan
    constraint ck_auditoria_campo check (campo in ('salario','nivel_acceso','id_especialidad')),
    -- valida que la tabla auditada sea una de las del personal
    constraint ck_auditoria_tabla check (tabla in ('personal','medico'))
);
alter table auditoria_personal owner to dueno_auditoria;

-- unica via para escribir en la bitacora; se ejecuta con los permisos de su dueño
-- y solo acepta llamadas hechas desde un disparador, no desde una consulta directa
create function fn_registrar_auditoria(p_usuario_bd text, p_tabla text, p_id integer,
                                       p_campo text, p_anterior text, p_nuevo text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    if pg_trigger_depth() = 0 then
        raise exception 'La bitácora solo se escribe desde los disparadores de auditoría';
    end if;
    insert into auditoria_personal (usuario_bd, usuario_sesion, usuario_aplicacion, tabla, id_registro,
                                    campo, valor_anterior, valor_nuevo)
    values (p_usuario_bd, session_user, nullif(current_setting('app.usuario', true), ''),
            p_tabla, p_id, p_campo, p_anterior, p_nuevo);
end $$;
alter function fn_registrar_auditoria(text, text, integer, text, text, text) owner to dueno_auditoria;

-- nadie escribe directo en la bitacora; admin y visor solo la leen.
-- se revoca tambien a admin porque los privilegios por defecto del Proyecto 1
-- le dan todos los permisos sobre las tablas nuevas que crea el superusuario
revoke all on auditoria_personal from public, admin, visor;
grant select on auditoria_personal to admin, visor;
revoke execute on function fn_registrar_auditoria(text, text, integer, text, text, text) from public;
grant execute on function fn_registrar_auditoria(text, text, integer, text, text, text) to admin;

-- descripcion de la bitacora para el diccionario de datos
comment on table auditoria_personal is 'Bitácora automática de los cambios de salario, nivel de acceso y especialidad del personal.';
comment on column auditoria_personal.id_auditoria is 'Identificador del registro de la bitácora (lo genera la base, no se puede asignar).';
comment on column auditoria_personal.fecha_hora is 'Momento exacto del cambio (clock_timestamp).';
comment on column auditoria_personal.usuario_bd is 'Rol de base de datos que hizo el cambio.';
comment on column auditoria_personal.usuario_sesion is 'Usuario con el que se inició la sesión (distinto del rol si se usó SET ROLE).';
comment on column auditoria_personal.usuario_aplicacion is 'Usuario de la aplicación que hizo el cambio, enviado en la variable app.usuario.';
comment on column auditoria_personal.tabla is 'Tabla donde ocurrió el cambio: personal o medico.';
comment on column auditoria_personal.id_registro is 'Identificador de la persona cuyo dato cambió (id_personal = id_medico).';
comment on column auditoria_personal.campo is 'Campo que cambió: salario, nivel_acceso o id_especialidad.';
comment on column auditoria_personal.valor_anterior is 'Valor antes del cambio.';
comment on column auditoria_personal.valor_nuevo is 'Valor después del cambio.';


-- ============================================================
-- parte del rol administrativo: disparadores sobre sus tablas
-- ============================================================

set role admin;

-- salario y nivel de acceso de cualquier persona del personal
create function fn_auditar_personal() returns trigger language plpgsql as $$
begin
    -- current_user aqui es el rol que hizo el cambio (la funcion no es security definer)
    if new.salario is distinct from old.salario then
        perform fn_registrar_auditoria(current_user, 'personal', new.id_personal, 'salario',
                                       old.salario::text, new.salario::text);
    end if;
    if new.nivel_acceso is distinct from old.nivel_acceso then
        perform fn_registrar_auditoria(current_user, 'personal', new.id_personal, 'nivel_acceso',
                                       old.nivel_acceso, new.nivel_acceso);
    end if;
    return null;
end $$;

create trigger trg_auditar_personal after update of salario, nivel_acceso on personal
    for each row execute function fn_auditar_personal();

-- especialidad del medico; se guarda el id y el nombre para que la bitacora se lea sola
create function fn_auditar_medico() returns trigger language plpgsql as $$
begin
    perform fn_registrar_auditoria(current_user, 'medico', new.id_medico, 'id_especialidad',
        old.id_especialidad || ' - ' || (select nombre from especialidad where id_especialidad = old.id_especialidad),
        new.id_especialidad || ' - ' || (select nombre from especialidad where id_especialidad = new.id_especialidad));
    return null;
end $$;

create trigger trg_auditar_medico after update of id_especialidad on medico
    for each row when (new.id_especialidad is distinct from old.id_especialidad)
    execute function fn_auditar_medico();

reset role;
commit;
