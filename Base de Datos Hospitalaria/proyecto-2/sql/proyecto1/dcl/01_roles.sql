-- Proyecto 1 - BD Hospitales de Occidente
-- 01_roles.sql : control de acceso (DCL)
--
-- Roles:
--   visor -> solo lectura, para auditoria y reportes.
--   admin -> privilegios completos sobre el esquema y dueño de las tablas.
-- Las contraseñas no se guardan en el repositorio; despues de crear los roles
-- se asignan desde psql con:  \password visor   y   \password admin

create role visor login;
create role admin login;

-- solo los roles del proyecto se pueden conectar a esta base
revoke all on database hospital from public;
grant connect on database hospital to visor, admin;

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

-- ---------- visor: solo lectura de tablas ----------
grant usage on schema public to visor;
grant select on all tables in schema public to visor;

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

-- admin queda como dueño de las tablas: solo el dueño puede modificarlas
-- (alter table) y la extension del Proyecto 2 la hace el rol administrativo
alter table departamento owner to admin;
alter table municipio owner to admin;
alter table hospital owner to admin;
alter table unidad_medica owner to admin;
alter table servicio_atencion owner to admin;
alter table camilla owner to admin;
alter table quirofano owner to admin;
alter table especialidad owner to admin;
alter table medico owner to admin;
alter table enfermero owner to admin;
alter table turno_emergencia owner to admin;
alter table turno_medico owner to admin;
alter table insumo owner to admin;
alter table instrumento owner to admin;
alter table equipo owner to admin;
alter table medicamento owner to admin;
alter table diagnostico owner to admin;
alter table estado_civil owner to admin;
alter table parentesco owner to admin;
alter table paciente owner to admin;
alter table encargado owner to admin;
alter table paciente_encargado owner to admin;
alter table cita owner to admin;
alter table consulta owner to admin;
alter table receta owner to admin;
alter table receta_medicamento owner to admin;
alter table ingreso owner to admin;
alter table egreso owner to admin;
alter table egreso_diagnostico owner to admin;
alter table institucion_externa owner to admin;
alter table traslado owner to admin;
alter table tipo_anestesia owner to admin;
alter table tipo_cirugia owner to admin;
alter table aspecto_quirurgico owner to admin;
alter table rol_quirurgico owner to admin;
alter table agendamiento_quirurgico owner to admin;
alter table requerimiento_insumo owner to admin;
alter table requerimiento_instrumento owner to admin;
alter table requerimiento_equipo owner to admin;
alter table historia_clinica owner to admin;
alter table consentimiento_informado owner to admin;
alter table chequeo_preanestesico owner to admin;
alter table cirugia owner to admin;
alter table cirugia_personal owner to admin;
alter table registro_procedimiento owner to admin;
alter table documentacion_etapa owner to admin;
alter table cirugia_insumo owner to admin;
alter table hospitalizacion_insumo owner to admin;
alter table metodo_pago owner to admin;
alter table factura owner to admin;
alter table pago owner to admin;
alter table calificacion owner to admin;

-- lo que admin cree despues tambien lo puede leer visor
alter default privileges for role admin in schema public
    grant select on tables to visor;
alter default privileges for role admin in schema public
    revoke execute on functions from public;
alter default privileges for role admin in schema public
    grant execute on functions to visor;
