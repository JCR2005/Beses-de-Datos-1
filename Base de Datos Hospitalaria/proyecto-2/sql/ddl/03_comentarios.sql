-- Proyecto 2 - BD Hospitales de Occidente
-- 03_comentarios.sql : descripcion de las tablas y columnas nuevas o modificadas
--
-- El diccionario de datos del documento se arma con estas descripciones.

begin;
set search_path to public;

-- la bitacora es del rol dueno_auditoria: la comenta el superusuario
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

set role admin;

comment on table personal is 'Supertipo con los datos comunes de todo el personal del hospital; sus subtipos son medico y enfermero.';
comment on column personal.id_personal is 'Identificador de la persona; es también la llave de su subtipo.';
comment on column personal.tipo_personal is 'Discriminador: indica si la persona es medico o enfermero.';
comment on column personal.nombres is 'Nombres de la persona.';
comment on column personal.apellidos is 'Apellidos de la persona.';
comment on column personal.dpi is 'Documento Personal de Identificación (CUI de 13 dígitos).';
comment on column personal.telefono is 'Teléfono de contacto.';
comment on column personal.direccion is 'Dirección de residencia.';
comment on column personal.id_municipio is 'Municipio de residencia.';
comment on column personal.area is 'Área de residencia: Urbana o Rural.';
comment on column personal.id_hospital is 'Hospital donde trabaja.';
comment on column personal.fecha_contratacion is 'Fecha de contratación; nula para los médicos externos, que no están contratados.';
comment on column personal.salario is 'Salario mensual en quetzales; nulo si no está contratado. Se audita cada cambio.';
comment on column personal.nivel_acceso is 'Nivel de acceso al sistema: consulta, operativo, supervisor o administrador. Se audita cada cambio.';

comment on table medico is 'Subtipo de personal: médicos de la cadena (los externos no están contratados, solo operan).';
comment on column medico.id_medico is 'Identificador del médico; es el mismo id_personal de su supertipo.';
comment on column medico.tipo_personal is 'Discriminador fijo en medico; junto con id_medico forma la FK hacia personal.';
comment on column medico.cargo is 'Cargo en la cadena de mando: director_medico, jefe_servicio o medico.';
comment on column medico.id_medico_superior is 'Superior directo dentro del mismo hospital (relación recursiva); nulo para el director.';
comment on column medico.id_especialidad is 'Especialidad del médico. Se audita cada cambio.';
comment on column medico.nombres is 'Copia sincronizada de personal.nombres (la mantiene un disparador).';
comment on column medico.apellidos is 'Copia sincronizada de personal.apellidos.';
comment on column medico.dpi is 'Copia sincronizada de personal.dpi.';
comment on column medico.telefono is 'Copia sincronizada de personal.telefono.';
comment on column medico.id_municipio is 'Copia sincronizada de personal.id_municipio.';
comment on column medico.area is 'Copia sincronizada de personal.area.';
comment on column medico.id_hospital is 'Copia sincronizada de personal.id_hospital.';

comment on table enfermero is 'Subtipo de personal: enfermeros registrados y practicantes de enfermería.';
comment on column enfermero.id_enfermero is 'Identificador del enfermero; es el mismo id_personal de su supertipo.';
comment on column enfermero.tipo_personal is 'Discriminador fijo en enfermero; junto con id_enfermero forma la FK hacia personal.';
comment on column enfermero.nombres is 'Copia sincronizada de personal.nombres (la mantiene un disparador).';
comment on column enfermero.apellidos is 'Copia sincronizada de personal.apellidos.';
comment on column enfermero.dpi is 'Copia sincronizada de personal.dpi.';
comment on column enfermero.telefono is 'Copia sincronizada de personal.telefono.';
comment on column enfermero.id_hospital is 'Copia sincronizada de personal.id_hospital.';

reset role;
commit;
