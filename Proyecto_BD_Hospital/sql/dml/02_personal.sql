-- Proyecto 1 - BD Hospitales de Occidente
-- 02_personal.sql : especialidades, medicos, enfermeros y turnos de emergencia (datos FICTICIOS)

set search_path to public;

-- 301-314: las 14 especialidades de consulta externa; 315-329: las quirurgicas del enunciado
insert into especialidad (id_especialidad, nombre, tipo) values
(301, 'Cardiología', 'clinica'), (302, 'Dermatología', 'clinica'), (303, 'Fisioterapia', 'clinica'),
(304, 'Ginecología Oncológica', 'clinica'), (305, 'Hematología', 'clinica'),
(306, 'Medicina Física y Rehabilitación', 'clinica'), (307, 'Medicina General', 'clinica'),
(308, 'Nutrición y Dietética', 'clinica'), (309, 'Odontología General', 'clinica'),
(310, 'Oftalmología', 'clinica'), (311, 'Psicología', 'clinica'), (312, 'Pediatría', 'clinica'),
(313, 'Urología', 'clinica'), (314, 'Terapia del Lenguaje', 'clinica'),
(315, 'Cirugía General', 'quirurgica'), (316, 'Cirugía Cardiovascular', 'quirurgica'),
(317, 'Cirugía Oncológica', 'quirurgica'), (318, 'Anestesiología', 'clinica'),
(319, 'Cirugía de la Mano', 'quirurgica'), (320, 'Videolaparoscopia Quirúrgica', 'quirurgica'),
(321, 'Cirugía Ginecológica', 'quirurgica'), (322, 'Cirugía Neurológica', 'quirurgica'),
(323, 'Cirugía Oftalmológica', 'quirurgica'), (324, 'Cirugía Ortopédica', 'quirurgica'),
(325, 'Cirugía Otorrinolaringológica', 'quirurgica'), (326, 'Cirugía Pediátrica', 'quirurgica'),
(327, 'Cirugía Plástica', 'quirurgica'), (328, 'Cirugía de Tórax', 'quirurgica'),
(329, 'Cirugía Urológica', 'quirurgica');

-- procedimientos quirurgicos y la especialidad que los realiza
insert into tipo_cirugia (id_tipo_cirugia, nombre, id_especialidad) values
(1, 'Apendicectomía abierta', 315),
(2, 'Colecistectomía laparoscópica', 320),
(3, 'Hernioplastia inguinal', 315),
(4, 'Resección oncológica de colon', 317),
(5, 'Mastectomía', 317),
(6, 'Revascularización miocárdica', 316),
(7, 'Reemplazo de válvula aórtica', 316),
(8, 'Reducción de fractura', 324),
(9, 'Cesárea', 321),
(10, 'Cirugía de catarata', 323);

-- medicos de planta: generales, especialistas, residentes e internos
insert into medico (id_medico, nombres, apellidos, dpi, telefono, id_hospital, id_municipio, area, id_especialidad, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin) values
(1001, 'Carmen', 'Ruiz Palacios', '2001123450101', '5551-2001', 1, 1, 'Urbana', 307, 'general', 200.00, '08:00', '12:00'),
(1002, 'Roberto', 'Castillo Méndez', '2001123450102', '5551-2002', 1, 3, 'Urbana', 301, 'especialista', 220.00, '08:00', '11:30'),
(1003, 'Andrea', 'Soto Fuentes', '2001123450103', '5551-2003', 1, 6, 'Rural', 303, 'especialista', 160.00, '09:00', '12:00'),
(1004, 'Julia', 'Paredes Ovalle', '2001123450104', '5551-2004', 1, 1, 'Urbana', 312, 'especialista', 180.00, '08:00', '12:00'),
(1005, 'Miguel', 'Barrios Donis', '2001123450105', '5551-2005', 1, 2, 'Rural', 307, 'general', 180.00, '08:00', '12:00'),
(1006, 'Alejandro', 'Ramírez Lemus', '2001123450106', '5551-2006', 1, 1, 'Urbana', 315, 'residente', null, null, null),
(1008, 'Daniel', 'Morales Peña', '2001123450108', '5551-2008', 1, 1, 'Urbana', 318, 'interno', null, null, null),
(1009, 'Silvia', 'Vásquez Cotero', '2001123450109', '5551-2009', 3, 7, 'Urbana', 317, 'especialista', null, null, null),
(1010, 'Elena', 'Vásquez Sotelo', '2001123450110', '5551-2010', 1, 1, 'Urbana', 302, 'especialista', 180.00, '08:00', '12:00'),
(1011, 'Marcos', 'Aguilar Salazar', '2001123450111', '5551-2011', 1, 1, 'Urbana', 304, 'especialista', 210.00, '09:00', '12:00'),
(1012, 'Gabriela', 'Nájera Ruiz', '2001123450112', '5551-2012', 2, 6, 'Urbana', 305, 'especialista', 195.00, '08:00', '11:30'),
(1013, 'Fernando', 'López Arriaga', '2001123450113', '5551-2013', 1, 3, 'Urbana', 306, 'especialista', 175.00, '09:00', '12:00'),
(1014, 'Claudia', 'Recinos Toj', '2001123450114', '5551-2014', 2, 6, 'Urbana', 308, 'especialista', 150.00, '08:00', '12:00'),
(1015, 'Andrés', 'Chinchilla Paz', '2001123450115', '5551-2015', 1, 1, 'Urbana', 309, 'general', 130.00, '08:00', '12:00'),
(1016, 'Paola', 'Sandoval Itzep', '2001123450116', '5551-2016', 3, 7, 'Urbana', 310, 'especialista', 185.00, '08:00', '12:00'),
(1017, 'Ricardo', 'Batz Coyoy', '2001123450117', '5551-2017', 1, 1, 'Urbana', 311, 'especialista', 165.00, '09:00', '12:00'),
(1018, 'Silvia', 'Gómez Tuch', '2001123450118', '5551-2018', 1, 3, 'Urbana', 314, 'especialista', 140.00, '08:00', '12:00'),
(1019, 'Julio', 'Estrada Mazariegos', '2001123450119', '5551-2019', 2, 6, 'Urbana', 313, 'especialista', 190.00, '08:00', '12:00');

-- cirujanos externos: no estan contratados, solo llegan a operar (sin horario ni costo de consulta)
insert into medico (id_medico, nombres, apellidos, dpi, telefono, id_hospital, id_municipio, area, id_especialidad, tipo_medico) values
(1007, 'Hilda', 'Cifuentes Rojas', '2001123450107', '5551-2007', 2, 6, 'Urbana', 316, 'externo'),
(1020, 'René', 'Iguarán Solís', '2001123450120', '5551-2020', 1, 1, 'Urbana', 319, 'externo'),
(1021, 'Wilfredo', 'Chávez Orozco', '2001123450121', '5551-2021', 2, 6, 'Urbana', 320, 'externo'),
(1022, 'Ana', 'Lucero Fuentes', '2001123450122', '5551-2022', 3, 1, 'Urbana', 321, 'externo'),
(1023, 'Héctor', 'Quirós Barrios', '2001123450123', '5551-2023', 1, 3, 'Urbana', 322, 'externo'),
(1024, 'Verónica', 'Aranda Cruz', '2001123450124', '5551-2024', 2, 1, 'Urbana', 323, 'externo'),
(1025, 'Gustavo', 'Rivas Monzón', '2001123450125', '5551-2025', 3, 7, 'Urbana', 324, 'externo'),
(1026, 'Mónica', 'Figueroa Lam', '2001123450126', '5551-2026', 1, 1, 'Urbana', 325, 'externo'),
(1027, 'Pablo', 'Tzoc Ajcá', '2001123450127', '5551-2027', 2, 6, 'Urbana', 326, 'externo'),
(1028, 'Isabel', 'Contreras Mejía', '2001123450128', '5551-2028', 3, 1, 'Urbana', 327, 'externo'),
(1029, 'Carlos', 'Menéndez Ralda', '2001123450129', '5551-2029', 1, 3, 'Urbana', 328, 'externo'),
(1030, 'Luis', 'Zambrano Sic', '2001123450130', '5551-2030', 2, 6, 'Urbana', 329, 'externo');

-- enfermeros del hospital 1
insert into enfermero (id_enfermero, nombres, apellidos, dpi, telefono, id_hospital, tipo) values
(2001, 'Luis', 'Hernández Solís', '2001123450201', '5552-2001', 1, 'registrado'),
(2002, 'Marta', 'Recinos Alvarado', '2001123450202', '5552-2002', 1, 'registrado'),
(2003, 'Carlos', 'García Méndez', '2001123450203', '5552-2003', 1, 'practicante'),
(2004, 'Ana', 'López Pérez', '2001123450204', '5552-2004', 1, 'registrado'),
(2005, 'Pedro', 'Ramírez Soto', '2001123450205', '5552-2005', 1, 'registrado');

-- turnos de 12 horas de emergencias del hospital 1, con al menos 2 medicos por turno
insert into turno_emergencia (id_turno, id_unidad, fecha, jornada) values
(1, 12, '2026-08-09', 'nocturno'),
(2, 12, '2026-08-20', 'diurno');

insert into turno_medico (id_turno, id_medico) values
(1, 1001), (1, 1005),
(2, 1001), (2, 1005);
