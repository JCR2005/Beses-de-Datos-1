-- ============================================================
-- 02_pacientes.sql : pacientes y encargados (datos FICTICIOS)
-- ============================================================

SET search_path TO public;

-- Pacientes (todos los datos son ficticios, sin uso de información real de personas)
INSERT INTO paciente (id_paciente, codigo_expediente, nombres, apellidos, fecha_nacimiento, edad_años, sexo, dpi, telefono, municipio, departamento, area, estado_civil, no_seguro_social) OVERRIDING SYSTEM VALUE VALUES
(1, 'HG1-0001', 'María Fernanda', 'López García', '1988-04-12', 38, 'Femenino', '2220123450123', '5551-1001', 'Quetzaltenango', 'Quetzaltenango', 'Urbana', 'Casada', 'IGSS-88432'),
(2, 'HG1-0002', 'Jorge Luis', 'Ramírez Sosa', '1990-11-03', 35, 'Masculino', '3330123450456', '5551-1002', 'San Marcos', 'San Marcos', 'Rural', 'Soltero', NULL),
(3, 'HG1-0003', 'Pedro', 'Gómez Aguilar', '1975-07-22', 51, 'Masculino', '4440123450789', '5551-1003', 'Cantel', 'Quetzaltenango', 'Rural', 'Casado', NULL),
(4, 'HG1-0004', 'Ana Lucía', 'Méndez Cruz', '2015-05-30', 11, 'Femenino', '5550123450104', '5551-1004', 'Quetzaltenango', 'Quetzaltenango', 'Urbana', 'Soltera', 'IGSS-22150'),
(5, 'HG1-0005', 'Carlos', 'De León Ortiz', '1982-09-15', 43, 'Masculino', '66601234501230', '5551-1005', 'Olintepeque', 'Quetzaltenango', 'Urbana', 'Casado', NULL),
(6, 'HG2-0001', 'Sofía', 'Rivera Paz', '2001-02-25', 25, 'Femenino', '7770123450650', '5551-1006', 'San Marcos', 'San Marcos', 'Urbana', 'Soltera', NULL),
(7, 'HG1-0006', 'Luis Miguel', 'Castillo Fuentes', '1968-01-19', 58, 'Masculino', '8880123450901', '5551-1007', 'Zunil', 'Quetzaltenango', 'Rural', 'Viudo', NULL);

-- Encargados de pacientes
INSERT INTO encargado (id_encargado, nombre, dpi, telefono, municipio, departamento, area) OVERRIDING SYSTEM VALUE VALUES
(301, 'Isabel Cruz López', '8881123450101', '5551-3001', 'Quetzaltenango', 'Quetzaltenango', 'Urbana'),
(302, 'Roberto Méndez Rodríguez', '8881123450102', '5551-3002', 'Quetzaltenango', 'Quetzaltenango', 'Urbana'),
(303, 'Karla Paz Veliz', '8881123450103', '5551-3003', 'San Marcos', 'San Marcos', 'Urbana');

-- Relación paciente-encargado
INSERT INTO paciente_encargado (id_paciente_encargado, paciente_id, encargado_id, parentesco) OVERRIDING SYSTEM VALUE VALUES
(401, 4, 301, 'Madre'),
(402, 4, 302, 'Padre'),
(403, 6, 303, 'Hermana');