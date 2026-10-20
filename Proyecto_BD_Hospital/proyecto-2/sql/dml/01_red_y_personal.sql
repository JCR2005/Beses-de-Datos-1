-- Proyecto 2 - BD Hospitales de Occidente
-- 01_red_y_personal.sql : ampliacion de la red de hospitales y del personal (datos FICTICIOS)
--
-- Se agregan los hospitales 4 y 5 para que los rankings "top 3" comparen
-- entre varios hospitales, y personal suficiente para turnos, consultas y
-- cirugias en todos ellos, con su cadena de mando.

set role admin;
set search_path to public;

-- ============================================================
-- red de hospitales
-- ============================================================

insert into municipio (id_municipio, id_departamento, nombre) values
(9, 8, 'Huehuetenango'), (10, 8, 'Chiantla'), (11, 19, 'Sololá'),
(12, 19, 'Panajachel'), (13, 17, 'Malacatán'), (14, 15, 'San Sebastián');

insert into hospital (id_hospital, nombre, informacion_especifica, direccion, id_municipio) values
(4, 'Hospital de Occidente Huehuetenango', 'Hospital general de segundo nivel con énfasis en atención materno-infantil.', '5a. avenida 3-20, zona 1', 9),
(5, 'Hospital de Occidente Sololá', 'Hospital general de segundo nivel para la región del lago.', 'Calle principal 7-15, zona 2', 11);

insert into unidad_medica (id_unidad, id_hospital, tipo_unidad, costo_dia_hospitalizacion) values
(41, 4, 'Consulta Externa', null), (42, 4, 'Emergencias', null), (43, 4, 'Cirugía', null), (44, 4, 'Hospitalización', 480.00),
(51, 5, 'Consulta Externa', null), (52, 5, 'Emergencias', null), (53, 5, 'Cirugía', null), (54, 5, 'Hospitalización', 430.00);

-- los mismos servicios del hospital 1 con el costo propio de cada hospital (id + 300 y + 400)
insert into servicio_atencion (id_servicio, id_unidad, nombre, costo)
select s.id_servicio + 100 * (h.n - 1), s.id_unidad + 10 * (h.n - 1), s.nombre, round(s.costo * h.factor, 2)
  from servicio_atencion s
 cross join (values (4, 0.80), (5, 0.75)) as h(n, factor)
 where s.id_unidad in (12, 13, 14);

insert into camilla (id_camilla, id_unidad, numero)
select 300 + n, 44, n from generate_series(1, 14) n      -- hospital 4, hospitalizacion
union all
select 314 + n, 42, n from generate_series(1, 5) n       -- hospital 4, emergencias
union all
select 400 + n, 54, n from generate_series(1, 10) n      -- hospital 5, hospitalizacion
union all
select 410 + n, 52, n from generate_series(1, 4) n;      -- hospital 5, emergencias

insert into quirofano (id_quirofano, id_unidad, numero)
select 4 * (h - 1) + n, 10 * h + 3, n
  from generate_series(4, 5) h, generate_series(1, 4) n;

-- ============================================================
-- personal nuevo: primero el supertipo, luego su subtipo
-- ============================================================

insert into personal (id_personal, tipo_personal, nombres, apellidos, dpi, telefono, direccion, id_municipio, area, id_hospital, fecha_contratacion, salario, nivel_acceso) values
-- hospital 2
(1031, 'medico', 'Rosa María', 'Fuentes Galindo', '2001123450131', '5551-2031', '3 calle 5-12, zona 1', 6, 'Urbana', 2, '2016-02-01', 13000.00, 'operativo'),
(1032, 'medico', 'Esteban', 'Orozco Bámaca', '2001123450132', '5551-2032', '8 avenida 2-40, zona 3', 6, 'Rural', 2, '2019-07-15', 13000.00, 'operativo'),
(1033, 'medico', 'Leticia', 'Morales Chávez', '2001123450133', '5551-2033', '1 calle 9-03, zona 2', 6, 'Urbana', 2, '2011-03-10', 18500.00, 'operativo'),
(1034, 'medico', 'Iván', 'Coyoy Tzul', '2001123450134', '5551-2034', '6 calle 1-77, zona 4', 13, 'Urbana', 2, '2020-01-20', 18500.00, 'operativo'),
(1035, 'medico', 'Marisol', 'Ajanel Pérez', '2001123450135', '5551-2035', '2 avenida 6-18, zona 1', 6, 'Urbana', 2, '2023-08-01', 9500.00, 'operativo'),
-- hospital 3
(1036, 'medico', 'Otto René', 'Velásquez Lima', '2001123450136', '5551-2036', '4 calle 3-30, zona 1', 8, 'Urbana', 3, '2014-05-05', 13000.00, 'operativo'),
(1037, 'medico', 'Brenda', 'Sic Ixcot', '2001123450137', '5551-2037', 'Lotificación El Recreo, casa 14', 14, 'Rural', 3, '2021-11-02', 13000.00, 'operativo'),
(1038, 'medico', 'Mario', 'Cabrera Monterroso', '2001123450138', '5551-2038', '7 avenida 0-55, zona 1', 8, 'Urbana', 3, '2010-09-13', 18500.00, 'operativo'),
(1039, 'medico', 'Gloria', 'Tax Chiquitó', '2001123450139', '5551-2039', '5 calle 8-21, zona 2', 8, 'Urbana', 3, '2018-04-23', 18500.00, 'operativo'),
(1040, 'medico', 'Samuel', 'Barrios Juárez', '2001123450140', '5551-2040', '10 calle 2-09, zona 3', 8, 'Urbana', 3, '2017-06-12', 18500.00, 'operativo'),
-- hospital 4
(1041, 'medico', 'Ana Gabriela', 'Recinos Mérida', '2001123450141', '5551-2041', '2 calle 4-50, zona 1', 9, 'Urbana', 4, '2015-01-12', 13000.00, 'operativo'),
(1042, 'medico', 'Héctor Manuel', 'Gómez Ordóñez', '2001123450142', '5551-2042', 'Aldea Las Lagunas, casa 3', 10, 'Rural', 4, '2022-02-14', 13000.00, 'operativo'),
(1043, 'medico', 'Carolina', 'Herrera Villatoro', '2001123450143', '5551-2043', '6 avenida 1-15, zona 1', 9, 'Urbana', 4, '2009-10-01', 18500.00, 'operativo'),
(1044, 'medico', 'Jorge Mario', 'Alvarado Castillo', '2001123450144', '5551-2044', '3 avenida 7-02, zona 5', 9, 'Urbana', 4, '2016-08-08', 18500.00, 'operativo'),
(1045, 'medico', 'Patricia', 'López Mazariegos', '2001123450145', '5551-2045', '9 calle 3-44, zona 1', 9, 'Urbana', 4, '2013-03-18', 18500.00, 'operativo'),
(1046, 'medico', 'Kevin', 'Domingo Pascual', '2001123450146', '5551-2046', '1 avenida 2-08, zona 2', 10, 'Rural', 4, '2025-01-06', 6500.00, 'operativo'),
-- hospital 5
(1047, 'medico', 'Lucía', 'Cumes Xajil', '2001123450147', '5551-2047', 'Calle Santander 4-11', 12, 'Urbana', 5, '2014-07-21', 13000.00, 'operativo'),
(1048, 'medico', 'Diego', 'Yaxón Bocel', '2001123450148', '5551-2048', 'Cantón Pujujil, casa 8', 11, 'Rural', 5, '2020-09-28', 13000.00, 'operativo'),
(1049, 'medico', 'Sandra', 'Tuy Guarcax', '2001123450149', '5551-2049', '7 calle 2-33, zona 1', 11, 'Urbana', 5, '2008-02-04', 18500.00, 'operativo'),
(1050, 'medico', 'Alberto', 'Ramos Sajquiy', '2001123450150', '5551-2050', '3 avenida 5-60, zona 2', 11, 'Urbana', 5, '2012-12-03', 18500.00, 'operativo'),
(1051, 'medico', 'Mónica', 'Pirir Cutzal', '2001123450151', '5551-2051', 'Calle del Lago 1-09', 12, 'Urbana', 5, '2019-05-13', 18500.00, 'operativo'),
-- enfermeros de todos los hospitales
(2006, 'enfermero', 'Rosa', 'Xicará Pop', '2001123450206', '5552-2006', '2 calle 3-10, zona 1', 1, 'Urbana', 1, '2017-04-03', 7200.00, 'operativo'),
(2007, 'enfermero', 'Julio', 'Chay Tum', '2001123450207', '5552-2007', 'Aldea Chichimecas, casa 2', 5, 'Rural', 1, '2024-06-17', 3800.00, 'operativo'),
(2008, 'enfermero', 'Mirna', 'Ochoa Bravo', '2001123450208', '5552-2008', '5 avenida 1-22, zona 3', 6, 'Urbana', 2, '2016-10-10', 7200.00, 'operativo'),
(2009, 'enfermero', 'Wilson', 'Escobar Ruiz', '2001123450209', '5552-2009', '4 calle 6-07, zona 2', 13, 'Rural', 2, '2021-03-01', 7200.00, 'operativo'),
(2010, 'enfermero', 'Yesenia', 'Cardona Aguilar', '2001123450210', '5552-2010', '1 calle 2-80, zona 1', 6, 'Urbana', 2, '2025-02-03', 3800.00, 'operativo'),
(2011, 'enfermero', 'Ronaldo', 'Pineda Sosa', '2001123450211', '5552-2011', '6 calle 4-15, zona 1', 8, 'Urbana', 3, '2015-08-24', 7200.00, 'operativo'),
(2012, 'enfermero', 'Ingrid', 'Toc Chan', '2001123450212', '5552-2012', 'Colonia Las Flores, casa 9', 14, 'Rural', 3, '2019-01-14', 7200.00, 'operativo'),
(2013, 'enfermero', 'Elmer', 'Yac Sontay', '2001123450213', '5552-2013', '3 avenida 8-30, zona 2', 8, 'Urbana', 3, '2024-09-09', 3800.00, 'operativo'),
(2014, 'enfermero', 'Dora', 'Matías Gaspar', '2001123450214', '5552-2014', '4 calle 1-40, zona 1', 9, 'Urbana', 4, '2014-11-17', 7200.00, 'operativo'),
(2015, 'enfermero', 'Fredy', 'Mendoza Hidalgo', '2001123450215', '5552-2015', 'Caserío El Calvario, casa 5', 10, 'Rural', 4, '2020-05-04', 7200.00, 'operativo'),
(2016, 'enfermero', 'Sonia', 'Jiménez Sales', '2001123450216', '5552-2016', '2 avenida 3-03, zona 4', 9, 'Urbana', 4, '2025-03-10', 3800.00, 'operativo'),
(2017, 'enfermero', 'Pablo', 'Sicajau Tzep', '2001123450217', '5552-2017', 'Calle Rancho Grande 2-14', 12, 'Urbana', 5, '2016-06-06', 7200.00, 'operativo'),
(2018, 'enfermero', 'Claudia', 'Batz Sequén', '2001123450218', '5552-2018', 'Cantón Xajaxac, casa 1', 11, 'Rural', 5, '2018-08-20', 7200.00, 'operativo'),
(2019, 'enfermero', 'Edwin', 'Coj Lacán', '2001123450219', '5552-2019', '1 calle 5-25, zona 1', 11, 'Urbana', 5, '2024-10-07', 3800.00, 'operativo'),
(2020, 'enfermero', 'Vilma', 'Ixcoy Boj', '2001123450220', '5552-2020', '9 avenida 4-12, zona 2', 1, 'Urbana', 1, '2018-02-26', 7200.00, 'operativo');

-- subtipo medico: nombres, DPI, hospital y demas datos comunes los copia el disparador desde personal
insert into medico (id_medico, id_especialidad, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin) values
(1031, 307, 'general', 170.00, '08:00', '12:00'),
(1032, 307, 'general', 160.00, '08:00', '12:00'),
(1033, 301, 'especialista', 230.00, '08:00', '11:30'),
(1034, 312, 'especialista', 190.00, '08:00', '12:00'),
(1035, 315, 'residente', null, null, null),
(1036, 307, 'general', 165.00, '08:00', '12:00'),
(1037, 307, 'general', 150.00, '08:00', '12:00'),
(1038, 312, 'especialista', 210.00, '08:00', '12:00'),
(1039, 302, 'especialista', 175.00, '09:00', '12:00'),
(1040, 326, 'especialista', null, null, null),
(1041, 307, 'general', 160.00, '08:00', '12:00'),
(1042, 307, 'general', 150.00, '08:00', '12:00'),
(1043, 301, 'especialista', 215.00, '08:00', '11:30'),
(1044, 304, 'especialista', 205.00, '09:00', '12:00'),
(1045, 315, 'especialista', null, null, null),
(1046, 318, 'interno', null, null, null),
(1047, 307, 'general', 150.00, '08:00', '12:00'),
(1048, 307, 'general', 145.00, '08:00', '12:00'),
(1049, 312, 'especialista', 200.00, '08:00', '12:00'),
(1050, 324, 'especialista', null, null, null),
(1051, 311, 'especialista', 160.00, '09:00', '12:00');

insert into enfermero (id_enfermero, tipo)
select id_personal, case when salario < 5000 then 'practicante' else 'registrado' end
  from personal
 where tipo_personal = 'enfermero'
   and id_personal not in (select id_enfermero from enfermero);

-- ============================================================
-- cadena de mando: director -> jefes de servicio -> medicos
-- (de arriba hacia abajo, para que cada superior ya exista)
-- ============================================================

update medico set cargo = 'director_medico' where id_medico in (1002, 1033, 1038, 1043, 1049);
update medico set cargo = 'jefe_servicio' where id_medico in (1005, 1011, 1031, 1012, 1036, 1009, 1041, 1045, 1047, 1050);

update medico m set id_medico_superior = s.superior
  from (values
        -- hospital 1: dos servicios; en consulta externa la cadena llega a 4 niveles
        (1005, 1002), (1011, 1002),
        (1001, 1005), (1006, 1005), (1008, 1006),
        (1003, 1011), (1004, 1011), (1010, 1011), (1013, 1011), (1015, 1011), (1017, 1011), (1018, 1017),
        -- hospital 2
        (1031, 1033), (1012, 1033), (1032, 1031), (1035, 1031), (1014, 1012), (1019, 1012), (1034, 1012),
        -- hospital 3
        (1036, 1038), (1009, 1038), (1037, 1036), (1040, 1036), (1016, 1009), (1039, 1009),
        -- hospital 4
        (1041, 1043), (1045, 1043), (1042, 1041), (1046, 1042), (1044, 1045),
        -- hospital 5
        (1047, 1049), (1050, 1049), (1048, 1047), (1051, 1050)
       ) as s(medico, superior)
 where m.id_medico = s.medico;

-- nivel de acceso y salario segun el cargo
update personal p
   set nivel_acceso = case m.cargo when 'director_medico' then 'administrador' else 'supervisor' end,
       salario = case m.cargo when 'director_medico' then 28000.00 else 22000.00 end
  from medico m
 where m.id_medico = p.id_personal and m.cargo in ('director_medico','jefe_servicio');

-- el contador del supertipo sigue despues del mayor id usado
do $$
begin
    perform setval(pg_get_serial_sequence('personal', 'id_personal'), (select max(id_personal) from personal));
end $$;

reset role;
