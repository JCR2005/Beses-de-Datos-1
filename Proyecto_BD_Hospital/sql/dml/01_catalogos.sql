-- ============================================================
-- 01_catalogos.sql : inserciones de catalogos y personal (datos FICTICIOS)
-- ============================================================

SET search_path TO public;

-- Catalogo geografico: 22 departamentos y 7 municipios usados en los datos
INSERT INTO departamento (nombre) VALUES
('Alta Verapaz'),('Baja Verapaz'),('Chimaltenango'),('Chiquimula'),
('El Progreso'),('Escuintla'),('Guatemala'),('Huehuetenango'),('Izabal'),
('Jalapa'),('Jutiapa'),('Petén'),('Quetzaltenango'),('Quiché'),
('Retalhuleu'),('Sacatepéquez'),('San Marcos'),('Santa Rosa'),('Sololá'),
('Suchitepéquez'),('Totonicapán'),('Zacapa');

INSERT INTO municipio (departamento_id, nombre)
SELECT id_departamento, 'Quetzaltenango' FROM departamento WHERE nombre='Quetzaltenango';
INSERT INTO municipio (departamento_id, nombre)
SELECT id_departamento, 'Coatepeque' FROM departamento WHERE nombre='Quetzaltenango';
INSERT INTO municipio (departamento_id, nombre)
SELECT id_departamento, 'Olintepeque' FROM departamento WHERE nombre='Quetzaltenango';
INSERT INTO municipio (departamento_id, nombre)
SELECT id_departamento, 'Zunil' FROM departamento WHERE nombre='Quetzaltenango';
INSERT INTO municipio (departamento_id, nombre)
SELECT id_departamento, 'Cantel' FROM departamento WHERE nombre='Quetzaltenango';
INSERT INTO municipio (departamento_id, nombre)
SELECT id_departamento, 'San Marcos' FROM departamento WHERE nombre='San Marcos';
INSERT INTO municipio (departamento_id, nombre)
SELECT id_departamento, 'Totonicapán' FROM departamento WHERE nombre='Totonicapán';

-- Hospitales de la cadena
INSERT INTO hospital (id_hospital, nombre, informacion_especifica, direccion) VALUES
(1, 'Hospital General de Occidente', 'Hospital general de tercer nivel; 4 quirófanos y 24 camillas de hospitalización.', '15 Av. 6-45, zona 3, Quetzaltenango'),
(2, 'Hospital Regional de San Marcos', 'Hospital de referencia regional para el departamento de San Marcos.', '7a. calle 4-10, zona 2, San Marcos'),
(3, 'Hospital Infantil de Retalhuleu', 'Hospital especializado en atención pediátrica.', 'Boulevard El Malecón, zona 1, Retalhuleu');

-- Unidades médicas de cada hospital (incluye "Otro" para traslados externos)
INSERT INTO unidad_medica (id_unidad, hospital_id, nombre, costo_dia_hospitalizacion) VALUES
(11, 1, 'Consulta Externa', NULL), (12, 1, 'Emergencias', NULL), (13, 1, 'Cirugia', NULL),
(14, 1, 'Hospitalizacion', 600.00), (15, 1, 'Otro', NULL),
(21, 2, 'Consulta Externa', NULL), (22, 2, 'Emergencias', NULL), (23, 2, 'Cirugia', NULL),
(24, 2, 'Hospitalizacion', 450.00), (25, 2, 'Otro', NULL),
(31, 3, 'Consulta Externa', NULL), (32, 3, 'Emergencias', NULL), (33, 3, 'Cirugia', NULL),
(34, 3, 'Hospitalizacion', 520.00), (35, 3, 'Otro', NULL);

-- Servicios de atención (tipo de servicio) por unidad
INSERT INTO servicio_atencion (id_servicio, unidad_id, nombre, costo) VALUES
-- Emergencias - Hospital 1
(1, 12, 'Aislamiento y control de vía aérea y ventilación', 1200.00),
(2, 12, 'Control cardiocirculatorio', 1400.00),
(3, 12, 'Atención de pacientes politraumatizados', 1800.00),
(4, 12, 'Manejo, control y administración de drogas protocolizadas', 900.00),
(5, 12, 'Procedimientos de control y observación', 700.00),
(6, 12, 'Procedimientos terapéuticos/diagnósticos', 1100.00),
(7, 12, 'Procedimientos diagnósticos', 800.00),
-- Hospitalización - Hospital 1
(8, 14, 'Hematología', 1500.00),
(9, 14, 'Medicina interna', 1600.00),
(10, 14, 'Neumología', 1500.00),
(11, 14, 'Neurología', 1700.00),
(12, 14, 'Oncología', 2000.00),
(13, 14, 'Ortopedia', 1400.00),
(14, 14, 'Pediatría', 1600.00),
(15, 14, 'Unidad de cuidados intermedios', 1800.00),
(16, 14, 'Unidad de cuidado crítico de adultos', 2500.00),
-- Cirugía - Hospital 1 (costo según tipo de cirugía)
(17, 13, 'Cirugía General', 8500.00),
(18, 13, 'Cirugía Cardiovascular', 15000.00),
(19, 13, 'Cirugía Oncológica', 12000.00);

-- Especialidades (consulta externa + quirurgicas)
-- 301-314: las 14 que el enunciado exige para Consulta Externa
-- 315-329: las 14 especialidades quirurgicas del enunciado
INSERT INTO especialidad (id_especialidad, nombre) VALUES
(301, 'Cardiología'), (302, 'Dermatología'), (303, 'Fisioterapia'),
(304, 'Ginecología Oncológica'), (305, 'Hematología'), (306, 'Medicina Física y Rehabilitación'),
(307, 'Medicina General'), (308, 'Nutrición y Dietética'), (309, 'Odontología General'),
(310, 'Oftalmología'), (311, 'Psicología'), (312, 'Pediatría'), (313, 'Urología'),
(314, 'Terapia del Lenguaje'),
(315, 'Cirugía General'), (316, 'Cirugía Cardiovascular'), (317, 'Cirugía Oncológica'),
(318, 'Anestesiología'),
(319, 'Cirugía de la Mano'), (320, 'Videolaparoscopia Quirúrgica'),
(321, 'Cirugía Ginecológica'), (322, 'Cirugía Neurológica'),
(323, 'Cirugía Oftalmológica'), (324, 'Cirugía Ortopédica'),
(325, 'Cirugía Otorrinolaringológica'), (326, 'Cirugía Pediátrica'),
(327, 'Cirugía Plástica'), (328, 'Cirugía de Tórax'), (329, 'Cirugía Urológica');

-- Médicos: cada uno pertenece a un hospital concreto.
-- Los externos (1007, 1008) no están contratados, solo llegan a cirugias.
INSERT INTO medico (id_medico, nombres, apellidos, dpi, telefono, hospital_id, municipio_id, area, especialidad_id, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin) VALUES
(1001, 'Carmen', 'Ruiz Palacios', '2001123450101', '5551-2001', 1, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 307, 'general', 200.00, '08:00', '12:00'),
(1002, 'Roberto', 'Castillo Méndez', '2001123450102', '5551-2002', 1, (SELECT id_municipio FROM municipio WHERE nombre='Olintepeque'), 'Urbana', 301, 'especialista', 220.00, '08:00', '11:30'),
(1003, 'Andrea', 'Soto Fuentes', '2001123450103', '5551-2003', 1, (SELECT id_municipio FROM municipio WHERE nombre='San Marcos'), 'Rural', 303, 'especialista', 160.00, '09:00', '12:00'),
(1004, 'Julia', 'Paredes Ovalle', '2001123450104', '5551-2004', 1, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 312, 'especialista', 180.00, '08:00', '12:00'),
(1005, 'Miguel', 'Barrios Donis', '2001123450105', '5551-2005', 1, (SELECT id_municipio FROM municipio WHERE nombre='Coatepeque'), 'Rural', 307, 'general', 180.00, '08:00', '12:00'),
(1006, 'Alejandro', 'Ramírez Lemus', '2001123450106', '5551-2006', 1, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 315, 'residente', NULL, NULL, NULL),
(1007, 'Hilda', 'Cifuentes Rojas', '2001123450107', '5551-2007', 2, (SELECT id_municipio FROM municipio WHERE nombre='San Marcos'), 'Urbana', 316, 'externo', NULL, NULL, NULL),
(1008, 'Daniel', 'Morales Peña', '2001123450108', '5551-2008', 1, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 318, 'interno', NULL, NULL, NULL),
(1009, 'Silvia', 'Vásquez Cotero', '2001123450109', '5551-2009', 3, (SELECT id_municipio FROM municipio WHERE nombre='Totonicapán'), 'Urbana', 317, 'especialista', NULL, NULL, NULL);

-- Medicos de consulta externa para las especialidades que estaban sin ninguno.
-- El enunciado pide al menos un medico por cada una de las 14 especialidades.
INSERT INTO medico (id_medico, nombres, apellidos, dpi, telefono, hospital_id, municipio_id, area, especialidad_id, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin) VALUES
(1010, 'Elena', 'Vasquez Sotelo', '2001123450110', '5551-2010', 1, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 302, 'especialista', 180.00, '08:00', '12:00'),
(1011, 'Marcos', 'Aguilar Salazar', '2001123450111', '5551-2011', 1, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 304, 'especialista', 210.00, '09:00', '12:00'),
(1012, 'Gabriela', 'Nájera', '2001123450112', '5551-2012', 2, (SELECT id_municipio FROM municipio WHERE nombre='San Marcos'), 'Urbana', 305, 'especialista', 195.00, '08:00', '11:30'),
(1013, 'Fernando', 'López', '2001123450113', '5551-2013', 1, (SELECT id_municipio FROM municipio WHERE nombre='Olintepeque'), 'Urbana', 306, 'especialista', 175.00, '09:00', '12:00'),
(1014, 'Claudia', 'Recinos', '2001123450114', '5551-2014', 2, (SELECT id_municipio FROM municipio WHERE nombre='San Marcos'), 'Urbana', 308, 'especialista', 150.00, '08:00', '12:00'),
(1015, 'Andrés', 'Chinchilla', '2001123450115', '5551-2015', 1, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 309, 'general', 130.00, '08:00', '12:00'),
(1016, 'Paola', 'Sandoval', '2001123450116', '5551-2016', 3, (SELECT id_municipio FROM municipio WHERE nombre='Totonicapán'), 'Urbana', 310, 'especialista', 185.00, '08:00', '12:00'),
(1017, 'Ricardo', 'Batz', '2001123450117', '5551-2017', 1, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 311, 'especialista', 165.00, '09:00', '12:00'),
(1018, 'Silvia', 'Gómez', '2001123450118', '5551-2018', 1, (SELECT id_municipio FROM municipio WHERE nombre='Olintepeque'), 'Urbana', 314, 'especialista', 140.00, '08:00', '12:00'),
(1019, 'Julio', 'Estrada', '2001123450119', '5551-2019', 2, (SELECT id_municipio FROM municipio WHERE nombre='San Marcos'), 'Urbana', 313, 'especialista', 190.00, '08:00', '12:00');

-- Cirujanos para las 14 especialidades quirurgicas del enunciado.
-- Son medicos externos: no estan contratados, solo llegan a cirugias,
-- por eso costo_primera_consulta y horarios van en NULL.
INSERT INTO medico (id_medico, nombres, apellidos, dpi, telefono, hospital_id, municipio_id, area, especialidad_id, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin) VALUES
(1020, 'René', 'Iguarán', '2001123450120', '5551-2020', 1, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 319, 'externo', NULL, NULL, NULL),
(1021, 'Wilfredo', 'Chávez', '2001123450121', '5551-2021', 2, (SELECT id_municipio FROM municipio WHERE nombre='San Marcos'), 'Urbana', 320, 'externo', NULL, NULL, NULL),
(1022, 'Ana', 'Lucero', '2001123450122', '5551-2022', 3, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 321, 'externo', NULL, NULL, NULL),
(1023, 'Héctor', 'Quirós', '2001123450123', '5551-2023', 1, (SELECT id_municipio FROM municipio WHERE nombre='Olintepeque'), 'Urbana', 322, 'externo', NULL, NULL, NULL),
(1024, 'Verónica', 'Aranda', '2001123450124', '5551-2024', 2, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 323, 'externo', NULL, NULL, NULL),
(1025, 'Gustavo', 'Rivas', '2001123450125', '5551-2025', 3, (SELECT id_municipio FROM municipio WHERE nombre='Totonicapán'), 'Urbana', 324, 'externo', NULL, NULL, NULL),
(1026, 'Mónica', 'Figueroa', '2001123450126', '5551-2026', 1, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 325, 'externo', NULL, NULL, NULL),
(1027, 'Pablo', 'Tzoc', '2001123450127', '5551-2027', 2, (SELECT id_municipio FROM municipio WHERE nombre='San Marcos'), 'Urbana', 326, 'externo', NULL, NULL, NULL),
(1028, 'Isabel', 'Contreras', '2001123450128', '5551-2028', 3, (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 327, 'externo', NULL, NULL, NULL),
(1029, 'Carlos', 'Menández', '2001123450129', '5551-2029', 1, (SELECT id_municipio FROM municipio WHERE nombre='Olintepeque'), 'Urbana', 328, 'externo', NULL, NULL, NULL),
(1030, 'Luis', 'Zambrano', '2001123450130', '5551-2030', 2, (SELECT id_municipio FROM municipio WHERE nombre='San Marcos'), 'Urbana', 329, 'externo', NULL, NULL, NULL);

-- Enfermeros
INSERT INTO enfermero (id_enfermero, nombres, apellidos, dpi, telefono, tipo) VALUES
(2001, 'Luis', 'Hernández Solís', '2001123450201', '5552-2001', 'registrado'),
(2002, 'Marta', 'Recinos Alvarado', '2001123450202', '5552-2002', 'registrado'),
(2003, 'Carlos', 'García Méndez', '2001123450203', '5552-2003', 'practicante_de_enfermeria'),
(2004, 'Ana', 'López Pérez', '2001123450204', '5552-2004', 'registrado'),
(2005, 'Pedro', 'Ramírez Soto', '2001123450205', '5552-2005', 'registrado');

-- Camillas (asignadas a unidades de hospitalizacion: 14, 24, 34)
INSERT INTO camilla (id_camilla, hospital_id, unidad_id, numero, disponible) VALUES
(1, 1, 14, 1, true), (2, 1, 14, 2, true), (3, 1, 14, 3, true), (4, 1, 14, 4, true),
(5, 1, 14, 5, true), (6, 1, 14, 6, true), (7, 1, 14, 7, true), (8, 1, 14, 8, true),
(9, 1, 14, 9, true), (10, 1, 14, 10, true), (11, 1, 14, 11, true), (12, 1, 14, 12, true),
(13, 1, 14, 13, true), (14, 1, 14, 14, true), (15, 1, 14, 15, true), (16, 1, 14, 16, true),
(17, 1, 14, 17, true), (18, 1, 14, 18, true), (19, 1, 14, 19, true), (20, 1, 14, 20, true),
(21, 1, 14, 21, true), (22, 1, 14, 22, true), (23, 1, 14, 23, true), (24, 1, 14, 24, true);

-- Quirofanos
INSERT INTO quirofano (id_quirofano, hospital_id, numero, estado) VALUES
(1, 1, 1, 'disponible'), (2, 1, 2, 'disponible'),
(3, 1, 3, 'disponible'), (4, 1, 4, 'disponible');

-- Insumos
INSERT INTO insumo (id_insumo, nombre, unidad_medida, costo_unitario, stock_minimo, stock_actual) VALUES
(1, 'Gasas estériles 10x10', 'paquete', 15.00, 50, 120),
(2, 'Guantes quirúrgicos látex', 'caja', 85.00, 30, 80),
(3, 'Suero fisiológico 1L', 'bolsa', 12.00, 40, 100),
(4, 'Jeringa desechable 5ml', 'unidad', 2.50, 100, 300),
(5, 'Catéter venoso central', 'unidad', 45.00, 10, 25),
(6, 'Bisturí #10', 'unidad', 8.00, 20, 50),
(7, 'Hilo vicryl 3-0', 'unidad', 35.00, 15, 40),
(8, 'Algodón hidrófilo 100g', 'rollo', 18.00, 25, 60),
(9, 'Betadine solución 500ml', 'frasco', 55.00, 10, 30),
(10, 'Guantes de examen nitrilo', 'caja', 70.00, 20, 50);

-- Instrumentos
INSERT INTO instrumento (id_instrumento, nombre, tipo, estado) VALUES
(1, 'Pinza Kelly', 'hemostasia', 'disponible'), (2, 'Pinza Mosquito', 'hemostasia', 'disponible'),
(3, 'Porta agujas Mayo-Hegar', 'sutura', 'disponible'), (4, 'Tijera Mayo', 'corte', 'disponible'),
(5, 'Tijera Metzenbaum', 'corte', 'disponible'), (6, 'Separador Farabeuf', 'separacion', 'disponible'),
(7, 'Cuchillo de bisturí #3', 'corte', 'disponible'), (8, 'Aspirador quirúrgico', 'aspiración', 'disponible'),
(9, 'Electrobisturí', 'coagulación', 'disponible'), (10, 'Lámpara de cirugía', 'iluminación', 'disponible');

-- Equipos
INSERT INTO equipo (id_equipo, nombre, descripcion, estado) VALUES
(1, 'Monitor de signos vitales', 'Monitor multiparamétrico 5 derivaciones', 'disponible'),
(2, 'Ventilador mecánico', 'Ventilador de cuidados críticos', 'disponible'),
(3, 'Bomba de infusión', 'Bomba de infusión volumétrica', 'disponible'),
(4, 'Desfibrilador', 'Desfibrilador monitor', 'disponible'),
(5, 'Arco en C', 'Arco en C móvil para fluoroscopia', 'disponible'),
(6, 'Microscopio quirúrgico', 'Microscopio para neurocirugía', 'disponible'),
(7, 'Lámpara de cirugía LED', 'Lámpara quirúrgica LED de alta intensidad', 'disponible'),
(8, 'Mesa de operaciones', 'Mesa quirúrgica electromecánica', 'disponible');