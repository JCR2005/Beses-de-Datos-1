-- ============================================================
-- 01_catalogos.sql : inserciones de catalogos y personal (datos FICTICIOS)
-- ============================================================

SET search_path TO public;

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

-- Especialidades (consulta externa + quirúrgicas)
INSERT INTO especialidad (id_especialidad, nombre) VALUES
(301, 'Cardiología'), (302, 'Dermatología'), (303, 'Fisioterapia'),
(304, 'Ginecología Oncológica'), (305, 'Hematología'), (306, 'Medicina Física y Rehabilitación'),
(307, 'Medicina General'), (308, 'Nutrición y Dietética'), (309, 'Odontología General'),
(310, 'Oftalmología'), (311, 'Psicología'), (312, 'Pediatría'), (313, 'Urología'),
(314, 'Terapia del Lenguaje'),
(315, 'Cirugía General'), (316, 'Cirugía Cardiovascular'), (317, 'Cirugía Oncológica'),
(318, 'Anestesiología');

-- Médicos (consultas, emergencias y cirujanos)
INSERT INTO medico (id_medico, nombres, apellidos, dpi, telefono, municipio_id, area, especialidad_id, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin) VALUES
(1001, 'Carmen', 'Ruiz Palacios', '2001123450101', '5551-2001', (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 307, 'general', 200.00, '08:00', '12:00'),
(1002, 'Roberto', 'Castillo Méndez', '2001123450102', '5551-2002', (SELECT id_municipio FROM municipio WHERE nombre='Olintepeque'), 'Urbana', 301, 'especialista', 220.00, '08:00', '11:30'),
(1003, 'Andrea', 'Soto Fuentes', '2001123450103', '5551-2003', (SELECT id_municipio FROM municipio WHERE nombre='San Marcos'), 'Rural', 303, 'especialista', 160.00, '09:00', '12:00'),
(1004, 'Julia', 'Paredes Ovalle', '2001123450104', '5551-2004', (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 312, 'especialista', 180.00, '08:00', '12:00'),
(1005, 'Miguel', 'Barrios Donis', '2001123450105', '5551-2005', (SELECT id_municipio FROM municipio WHERE nombre='Coatepeque'), 'Rural', 307, 'general', 180.00, '08:00', '12:00'),
(1006, 'Alejandro', 'Ramírez Lemus', '2001123450106', '5551-2006', (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 315, 'residente', NULL, NULL, NULL),
(1007, 'Hilda', 'Cifuentes Rojas', '2001123450107', '5551-2007', (SELECT id_municipio FROM municipio WHERE nombre='San Marcos'), 'Urbana', 316, 'externo', NULL, NULL, NULL),
(1008, 'Daniel', 'Morales Peña', '2001123450108', '5551-2008', (SELECT id_municipio FROM municipio WHERE nombre='Quetzaltenango'), 'Urbana', 318, 'interno', NULL, NULL, NULL),
(1009, 'Silvia', 'Vásquez Cotero', '2001123450109', '5551-2009', (SELECT id_municipio FROM municipio WHERE nombre='Totonicapán'), 'Urbana', 317, 'especialista', NULL, NULL, NULL);

-- Enfermeros
INSERT INTO enfermero (id_enfermero, nombres, apellidos, dpi, telefono, tipo) VALUES
(2001, 'Luis', 'Hernández Solís', '2001123450201', '5552-2001', 'registrado'),
(2002, 'Marta', 'Recinos Alvarado', '2001123450202', '5552-2002', 'registrado'),
(2003, 'José', 'Pérez Gaitán', '2001123450203', '5552-2003', 'practicante_de_enfermeria'),
(2004, 'Karen', 'Chacón Barrera', '2001123450204', '5552-2004', 'registrado');

-- Camillas (por hospital, numeración única dentro de cada hospital)
INSERT INTO camilla (id_camilla, hospital_id, unidad_id, numero, disponible) VALUES
(101, 1, 11, '101', TRUE), (102, 1, 11, '102', TRUE),
(111, 1, 12, '111', TRUE), (112, 1, 12, '112', TRUE), (113, 1, 12, '113', TRUE),
(121, 1, 14, '121', FALSE), (122, 1, 14, '122', TRUE), (123, 1, 14, '123', FALSE), (124, 1, 14, '124', TRUE),
(211, 2, 22, '211', TRUE), (212, 2, 22, '212', TRUE),
(221, 2, 24, '221', TRUE), (222, 2, 24, '222', TRUE);

-- Quirófanos
INSERT INTO quirofano (id_quirofano, hospital_id, numero, estado) VALUES
(1, 1, 'Q-1', 'disponible'), (2, 1, 'Q-2', 'ocupado'), (3, 1, 'Q-3', 'disponible'), (4, 1, 'Q-4', 'en_mantenimiento'),
(5, 2, 'Q-1', 'disponible'), (6, 2, 'Q-2', 'disponible');

-- Insumos
INSERT INTO insumo (id_insumo, nombre, descripcion, material, tipo) VALUES
(1, 'Solución salina 0.9% 1000 ml', 'Solución para hidratación parenteral.', 'Plástico', 'medico'),
(2, 'Catéter intravenoso 20G', 'Para acceso venoso periférico.', 'Acero/plástico', 'medico'),
(3, 'Seda quirúrgica 2-0', 'Hilo de sutura no absorbible.', 'Seda', 'quirurgico'),
(4, 'Gasa estéril 10x10', 'Para curación y campos operatorios.', 'Algodón', 'quirurgico'),
(5, 'Guantes quirúrgicos estériles', 'Guantes de látex sin polvo.', 'Látex', 'medico'),
(6, 'Propofol 10 mg/ml', 'Anestésico intravenoso de acción corta.', 'Vidrio', 'medico'),
(7, 'Sutura absorbible 3-0', 'Hilo de sutura reabsorbible.', 'Sintético', 'quirurgico'),
(8, 'Paracetamol 500 mg', 'Analgésico y antipirético.', 'Blíster', 'medico');

-- Instrumentos
INSERT INTO instrumento (id_instrumento, nombre, descripcion, tipo, funcion) VALUES
(1, 'Bisturí No. 3 con hoja No. 15', 'Bisturí desechable para incisiones.', 'quirurgico', 'corte'),
(2, 'Pinza de campo Backhaus', 'Fija campos quirúrgicos a la mesa.', 'quirurgico', 'contencion'),
(3, 'Pinza hemostática Mosquito', 'Controla sangrado de vasos pequeños.', 'quirurgico', 'hemostatica'),
(4, 'Separador de Farabeuf', 'Separa tejidos durante el abordaje.', 'quirurgico', 'retractor'),
(5, 'Pinza de anillo', 'Toma y sujeta piezas pequeñas.', 'quirurgico', 'contencion'),
(6, 'Tijeras Mayo curvas', 'Para corte de tejido y suturas.', 'quirurgico', 'corte');

-- Equipos
INSERT INTO equipo (id_equipo, nombre, descripcion, tipo, funcion) VALUES
(1, 'Monitor multiparamétrico', 'Monitorea ECG, SpO2 y presión.', 'medico', 'exploracion'),
(2, 'Electrobisturí', 'Corte y coagulación con corriente de alta frecuencia.', 'medico', 'tratamiento'),
(3, 'Ventilador mecánico', 'Asistencia respiratoria invasiva.', 'medico', 'tratamiento'),
(4, 'Bomba de infusión', 'Administración controlada de fármacos.', 'medico', 'tratamiento'),
(5, 'Laringoscopio', 'Visualización de vía aérea para intubación.', 'medico', 'diagnostico'),
(6, 'Mesa quirúrgica de anestesia', 'Mesón para equipamiento y medicación.', 'quirurgico', 'otro');