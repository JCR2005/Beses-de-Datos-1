-- Proyecto 2 - BD Hospitales de Occidente
-- 02_prueba.sql : demostracion de la bitacora de cambios sensibles (objetivo 20)
--
-- Los cambios los hace el rol administrativo, como lo haria el sistema de
-- Recursos Humanos; app.usuario identifica a la persona que opera la aplicacion.

set search_path to public;
set role admin;

-- cambio 1: aumento de salario a la doctora Carmen Ruiz (1001)
begin;
select set_config('app.usuario', 'rrhh.lperez', true);
update personal set salario = salario + 1500.00 where id_personal = 1001;
commit;

-- cambio 2: el doctor Andrés Chinchilla (1015) pasa de Odontología General a Medicina General
begin;
select set_config('app.usuario', 'rrhh.lperez', true);
update medico set id_especialidad = 307 where id_medico = 1015;
commit;

-- cambio 3: un mismo UPDATE cambia salario y nivel de acceso: se registran las dos filas
begin;
select set_config('app.usuario', 'direccion.hgo', true);
update personal set salario = 22000.00, nivel_acceso = 'supervisor' where id_personal = 1004;
commit;

-- un UPDATE que deja el mismo valor no genera registro
update personal set salario = salario where id_personal = 1002;

-- resultado registrado en la bitacora
select id_auditoria, fecha_hora, usuario_bd, usuario_sesion, usuario_aplicacion,
       tabla, id_registro, campo, valor_anterior, valor_nuevo
  from auditoria_personal
 order by id_auditoria;

-- la bitacora no se puede alterar, ni siquiera con el rol administrativo
do $$
begin
    delete from auditoria_personal;
exception when insufficient_privilege then
    raise notice 'admin no puede borrar la bitácora: %', sqlerrm;
end $$;

do $$
begin
    insert into auditoria_personal (usuario_bd, usuario_sesion, tabla, id_registro, campo)
    values ('falso', 'falso', 'personal', 1, 'salario');
exception when insufficient_privilege then
    raise notice 'admin no puede escribir registros falsos: %', sqlerrm;
end $$;

reset role;
