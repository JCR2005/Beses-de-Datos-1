-- Proyecto 2 - BD Hospitales de Occidente
-- 02_prueba.sql : prueba de la bitacora de cambios sensibles (objetivo 20)
--
-- Se hacen 3 cambios con el rol administrativo y al final se ve lo que quedo anotado.

set role admin;

-- cambio 1: aumento de salario a la doctora Carmen Ruiz (1001)
update personal set salario = salario + 1500.00 where id_personal = 1001;

-- cambio 2: el doctor Andrés Chinchilla (1015) pasa de Odontología General a Medicina General
update medico set id_especialidad = 307 where id_medico = 1015;

-- cambio 3: en un mismo update cambian salario y nivel de acceso, se anotan las dos cosas
update personal set salario = 22000.00, nivel_acceso = 'supervisor' where id_personal = 1004;

-- este update deja el mismo valor, asi que no se anota nada
update personal set salario = salario where id_personal = 1002;

-- lo que quedo en la bitacora
select id_auditoria, fecha_hora, usuario, tabla, id_registro, campo, valor_anterior, valor_nuevo
from auditoria_personal
order by id_auditoria;

reset role;
