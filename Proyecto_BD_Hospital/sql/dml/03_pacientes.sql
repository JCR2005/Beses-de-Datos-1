-- Proyecto 1 - BD Hospitales de Occidente
-- 03_pacientes.sql : pacientes y encargados (datos FICTICIOS)

set search_path to public;

insert into paciente (id_paciente, numero_expediente, nombres, apellidos, fecha_nacimiento, sexo, dpi, telefono, id_municipio, area, id_estado_civil, numero_seguro_social) values
(1, 'HG1-0001', 'María Fernanda', 'López García', '1988-04-12', 'Femenino', '2220123450123', '5551-1001', 1, 'Urbana', 2, 'IGSS-88432'),
(2, 'HG1-0002', 'Jorge Luis', 'Ramírez Sosa', '1990-11-03', 'Masculino', '3330123450456', '5551-1002', 6, 'Rural', 1, null),
(3, 'HG1-0003', 'Pedro', 'Gómez Aguilar', '1975-07-22', 'Masculino', '4440123450789', '5551-1003', 5, 'Rural', 2, null),
(4, 'HG1-0004', 'Ana Lucía', 'Méndez Cruz', '2015-05-30', 'Femenino', null, '5551-1004', 1, 'Urbana', 1, 'IGSS-22150'),
(5, 'HG1-0005', 'Carlos', 'De León Ortiz', '1982-09-15', 'Masculino', '6660123450123', '5551-1005', 3, 'Urbana', 2, null),
(6, 'HG2-0001', 'Sofía', 'Rivera Paz', '2001-02-25', 'Femenino', '7770123450650', '5551-1006', 6, 'Urbana', 1, null),
(7, 'HG1-0006', 'Luis Miguel', 'Castillo Fuentes', '1968-01-19', 'Masculino', '8880123450901', '5551-1007', 4, 'Rural', 5, null);

insert into encargado (id_encargado, nombres, apellidos, dpi, telefono, id_municipio, area) values
(301, 'Isabel', 'Cruz López', '8881123450101', '5551-3001', 1, 'Urbana'),
(302, 'Roberto', 'Méndez Rodríguez', '8881123450102', '5551-3002', 1, 'Urbana'),
(303, 'Karla', 'Paz Veliz', '8881123450103', '5551-3003', 6, 'Urbana');

-- la paciente 4 es menor de edad: sus padres son sus encargados
insert into paciente_encargado (id_paciente, id_encargado, id_parentesco) values
(4, 301, 1),
(4, 302, 2),
(6, 303, 3);
