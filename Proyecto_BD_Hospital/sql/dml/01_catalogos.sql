-- Proyecto 1 - BD Hospitales de Occidente
-- 01_catalogos.sql : geografia, hospitales, infraestructura y catalogos (datos FICTICIOS)
--
-- Los datos se cargan con id fijo para que las referencias cruzadas sean
-- legibles; 99_secuencias.sql ajusta los identity al final.

set search_path to public;

-- ============================================================
-- geografia
-- ============================================================

-- los 22 departamentos de Guatemala
insert into departamento (id_departamento, nombre) values
(1,'Alta Verapaz'),(2,'Baja Verapaz'),(3,'Chimaltenango'),(4,'Chiquimula'),
(5,'El Progreso'),(6,'Escuintla'),(7,'Guatemala'),(8,'Huehuetenango'),(9,'Izabal'),
(10,'Jalapa'),(11,'Jutiapa'),(12,'Petén'),(13,'Quetzaltenango'),(14,'Quiché'),
(15,'Retalhuleu'),(16,'Sacatepéquez'),(17,'San Marcos'),(18,'Santa Rosa'),(19,'Sololá'),
(20,'Suchitepéquez'),(21,'Totonicapán'),(22,'Zacapa');

-- municipios usados en los datos de prueba
insert into municipio (id_municipio, id_departamento, nombre) values
(1, 13, 'Quetzaltenango'), (2, 13, 'Coatepeque'), (3, 13, 'Olintepeque'),
(4, 13, 'Zunil'), (5, 13, 'Cantel'), (6, 17, 'San Marcos'),
(7, 21, 'Totonicapán'), (8, 15, 'Retalhuleu');

-- ============================================================
-- hospitales e infraestructura
-- ============================================================

insert into hospital (id_hospital, nombre, informacion_especifica, direccion, id_municipio) values
(1, 'Hospital General de Occidente', 'Hospital general de tercer nivel; 4 quirófanos y 24 camillas de hospitalización.', '15 Av. 6-45, zona 3', 1),
(2, 'Hospital Regional de San Marcos', 'Hospital de referencia regional para el departamento de San Marcos.', '7a. calle 4-10, zona 2', 6),
(3, 'Hospital Infantil de Retalhuleu', 'Hospital especializado en atención pediátrica.', 'Boulevard El Malecón, zona 1', 8);

-- cada hospital tiene sus 4 unidades; el id indica hospital y unidad (21 = hospital 2, unidad 1)
insert into unidad_medica (id_unidad, id_hospital, tipo_unidad, costo_dia_hospitalizacion) values
(11, 1, 'Consulta Externa', null), (12, 1, 'Emergencias', null), (13, 1, 'Cirugía', null), (14, 1, 'Hospitalización', 600.00),
(21, 2, 'Consulta Externa', null), (22, 2, 'Emergencias', null), (23, 2, 'Cirugía', null), (24, 2, 'Hospitalización', 450.00),
(31, 3, 'Consulta Externa', null), (32, 3, 'Emergencias', null), (33, 3, 'Cirugía', null), (34, 3, 'Hospitalización', 520.00);

-- servicios del hospital 1
insert into servicio_atencion (id_servicio, id_unidad, nombre, costo) values
-- emergencias
(1, 12, 'Aislamiento y control de vía aérea y ventilación', 1200.00),
(2, 12, 'Control cardiocirculatorio', 1400.00),
(3, 12, 'Atención de pacientes politraumatizados', 1800.00),
(4, 12, 'Manejo, control y administración de drogas protocolizadas', 900.00),
(5, 12, 'Procedimientos de control y observación', 700.00),
(6, 12, 'Procedimientos terapéuticos/diagnósticos', 1100.00),
(7, 12, 'Procedimientos diagnósticos', 800.00),
-- hospitalizacion
(8, 14, 'Hematología', 1500.00),
(9, 14, 'Medicina interna', 1600.00),
(10, 14, 'Neumología', 1500.00),
(11, 14, 'Neurología', 1700.00),
(12, 14, 'Oncología', 2000.00),
(13, 14, 'Ortopedia', 1400.00),
(14, 14, 'Pediatría', 1600.00),
(15, 14, 'Unidad de cuidados intermedios', 1800.00),
(16, 14, 'Unidad de cuidado crítico de adultos', 2500.00),
-- cirugia (costo base segun el tipo de cirugia)
(17, 13, 'Cirugía General', 8500.00),
(18, 13, 'Cirugía Cardiovascular', 15000.00),
(19, 13, 'Cirugía Oncológica', 12000.00);

-- los hospitales 2 y 3 ofrecen los mismos servicios con su propio costo (id + 100 y + 200)
insert into servicio_atencion (id_servicio, id_unidad, nombre, costo)
select s.id_servicio + 100 * (h.n - 1), s.id_unidad + 10 * (h.n - 1), s.nombre, round(s.costo * h.factor, 2)
  from servicio_atencion s
 cross join (values (2, 0.85), (3, 0.90)) as h(n, factor)
 where s.id_unidad in (12, 13, 14);

-- camillas: hospitalizacion y emergencias de cada hospital
insert into camilla (id_camilla, id_unidad, numero)
select n, 14, n from generate_series(1, 24) n            -- hospital 1, hospitalizacion
union all
select 24 + n, 12, n from generate_series(1, 6) n        -- hospital 1, emergencias
union all
select 100 + n, 24, n from generate_series(1, 12) n      -- hospital 2, hospitalizacion
union all
select 112 + n, 22, n from generate_series(1, 4) n       -- hospital 2, emergencias
union all
select 200 + n, 34, n from generate_series(1, 10) n      -- hospital 3, hospitalizacion
union all
select 210 + n, 32, n from generate_series(1, 4) n;      -- hospital 3, emergencias

-- los 4 quirofanos de cada unidad de cirugia
insert into quirofano (id_quirofano, id_unidad, numero)
select 4 * (h - 1) + n, 10 * h + 3, n
  from generate_series(1, 3) h, generate_series(1, 4) n;

-- ============================================================
-- catalogos de recursos medicos
-- ============================================================

insert into insumo (id_insumo, nombre, material, tipo, unidad_medida, costo_unitario, stock_minimo, stock_actual) values
(1, 'Gasas estériles 10x10', 'algodón', 'quirurgico', 'paquete', 15.00, 50, 120),
(2, 'Guantes quirúrgicos', 'látex', 'quirurgico', 'caja', 85.00, 30, 80),
(3, 'Suero fisiológico 1L', 'solución salina', 'medico', 'bolsa', 12.00, 40, 100),
(4, 'Jeringa desechable 5ml', 'plástico', 'medico', 'unidad', 2.50, 100, 300),
(5, 'Catéter venoso central', 'poliuretano', 'medico', 'unidad', 45.00, 10, 25),
(6, 'Hoja de bisturí #10', 'acero inoxidable', 'quirurgico', 'unidad', 8.00, 20, 50),
(7, 'Sutura vicryl 3-0', 'poliglactina', 'quirurgico', 'unidad', 35.00, 15, 40),
(8, 'Algodón hidrófilo 100g', 'algodón', 'medico', 'rollo', 18.00, 25, 60),
(9, 'Yodopovidona solución 500ml', 'solución antiséptica', 'medico', 'frasco', 55.00, 10, 30),
(10, 'Guantes de examen', 'nitrilo', 'medico', 'caja', 70.00, 20, 50);

insert into instrumento (id_instrumento, nombre, descripcion, tipo, funcion) values
(1, 'Pinza Kelly', 'Pinza hemostática curva', 'quirurgico', 'hemostatica'),
(2, 'Pinza Mosquito', 'Pinza hemostática fina para vasos pequeños', 'quirurgico', 'hemostatica'),
(3, 'Porta agujas Mayo-Hegar', 'Sujeta la aguja durante la sutura', 'quirurgico', 'contencion'),
(4, 'Tijera Mayo', 'Tijera para tejidos densos', 'quirurgico', 'corte'),
(5, 'Tijera Metzenbaum', 'Tijera para tejidos delicados', 'quirurgico', 'corte'),
(6, 'Separador Farabeuf', 'Separa los bordes de la incisión', 'quirurgico', 'retractor'),
(7, 'Mango de bisturí #3', 'Mango para hojas de bisturí', 'quirurgico', 'corte'),
(8, 'Cánula de aspiración Yankauer', 'Aspira fluidos del campo operatorio', 'quirurgico', 'accesorio'),
(9, 'Pinza de electrocoagulación', 'Coagula vasos con corriente bipolar', 'quirurgico', 'hemostatica'),
(10, 'Placa de osteosíntesis', 'Placa de titanio para fijar fracturas', 'quirurgico', 'implante');

insert into equipo (id_equipo, nombre, descripcion, tipo, funcion) values
(1, 'Monitor de signos vitales', 'Monitor multiparamétrico de 5 derivaciones', 'medico', 'diagnostico'),
(2, 'Ventilador mecánico', 'Ventilador de cuidados críticos', 'medico', 'tratamiento'),
(3, 'Bomba de infusión', 'Bomba de infusión volumétrica', 'medico', 'tratamiento'),
(4, 'Desfibrilador', 'Desfibrilador con monitor', 'medico', 'tratamiento'),
(5, 'Arco en C', 'Arco en C móvil para fluoroscopia', 'quirurgico', 'diagnostico'),
(6, 'Microscopio quirúrgico', 'Microscopio para neurocirugía', 'quirurgico', 'exploracion'),
(7, 'Lámpara quirúrgica LED', 'Lámpara de alta intensidad para quirófano', 'quirurgico', 'otro'),
(8, 'Mesa de operaciones', 'Mesa quirúrgica electromecánica', 'quirurgico', 'otro');

insert into medicamento (id_medicamento, nombre_generico, concentracion, forma_farmaceutica) values
(1, 'Metoprolol', '50 mg', 'tableta'),
(2, 'Losartán', '50 mg', 'tableta'),
(3, 'Tramadol', '50 mg', 'tableta'),
(4, 'Paracetamol', '500 mg', 'tableta'),
(5, 'Ibuprofeno', '400 mg', 'tableta'),
(6, 'Amoxicilina', '500 mg', 'capsula'),
(7, 'Omeprazol', '20 mg', 'capsula'),
(8, 'Metformina', '850 mg', 'tableta'),
(9, 'Salbutamol', '100 mcg', 'inhalador'),
(10, 'Ceftriaxona', '1 g', 'inyectable');

insert into diagnostico (id_diagnostico, codigo_cie10, descripcion) values
(1, 'I10', 'Hipertensión esencial (primaria)'),
(2, 'K35.8', 'Apendicitis aguda, otra y la no especificada'),
(3, 'T07', 'Traumatismos múltiples, no especificados'),
(4, 'S42.3', 'Fractura de la diáfisis del húmero'),
(5, 'S06.0', 'Conmoción cerebral'),
(6, 'R50.9', 'Fiebre, no especificada'),
(7, 'E86', 'Depleción del volumen'),
(8, 'C18.9', 'Tumor maligno del colon, parte no especificada'),
(9, 'I35.0', 'Estenosis (de la válvula) aórtica'),
(10, 'J18.9', 'Neumonía, no especificada'),
(11, 'E11.9', 'Diabetes mellitus tipo 2, sin complicaciones');

-- ============================================================
-- catalogos de pacientes, cirugia y facturacion
-- ============================================================

insert into estado_civil (id_estado_civil, nombre) values
(1, 'Soltero(a)'), (2, 'Casado(a)'), (3, 'Unido(a)'), (4, 'Divorciado(a)'), (5, 'Viudo(a)');

insert into parentesco (id_parentesco, nombre) values
(1, 'Madre'), (2, 'Padre'), (3, 'Hermano(a)'), (4, 'Hijo(a)'), (5, 'Cónyuge'),
(6, 'Abuelo(a)'), (7, 'Tío(a)'), (8, 'Tutor legal'), (9, 'Otro');

insert into tipo_anestesia (id_tipo_anestesia, nombre) values
(1, 'General'), (2, 'Regional raquídea'), (3, 'Regional epidural'), (4, 'Local'), (5, 'Sedación');

insert into rol_quirurgico (id_rol, nombre, tipo_personal) values
(1, 'Cirujano', 'medico'), (2, 'Cirujano ayudante', 'medico'), (3, 'Anestesiólogo', 'medico'),
(4, 'Enfermero instrumentista', 'enfermero'), (5, 'Enfermero circulante', 'enfermero');

insert into metodo_pago (id_metodo_pago, nombre) values
(1, 'Efectivo'), (2, 'Tarjeta de crédito'), (3, 'Tarjeta de débito'), (4, 'Transferencia bancaria');

-- establecimientos fuera de la red (nombres ficticios)
insert into institucion_externa (id_institucion, nombre, direccion, id_municipio) values
(1, 'Sanatorio Privado Los Cipreses', '4a. calle 12-30, zona 1', 1),
(2, 'Centro Médico Costa Sur', 'Km 198 carretera al Pacífico', 2);

-- aspectos que el enfermero verifica en cada etapa, segun el enunciado
insert into aspecto_quirurgico (id_aspecto, etapa, seccion, nombre, tipo_evaluacion) values
(1,  'preoperatorio', 'Planificación', 'Disponibilidad de tabla quirúrgica', 'exito_falla'),
(2,  'preoperatorio', 'Planificación', 'Preparación de equipos y quirófano previo al ingreso del paciente', 'exito_falla'),
(3,  'preoperatorio', 'Planificación', 'Recepción y acogida del paciente en el quirófano', 'exito_falla'),
(4,  'preoperatorio', 'Entrada', 'Brazalete de identificación: nombre, procedimiento y lado o segmento a operar', 'exito_falla'),
(5,  'preoperatorio', 'Entrada', 'Ficha clínica: laboratorios, consentimiento firmado y evaluación preanestésica', 'exito_falla'),
(6,  'preoperatorio', 'Entrada', 'Arsenal instrumental estéril, implantes y equipos disponibles y operativos', 'exito_falla'),
(7,  'preoperatorio', 'Entrada', 'Anestesista comprueba medicamentos, drogas y materiales de la técnica anestésica', 'exito_falla'),
(8,  'intraoperatorio', 'Chequeo en quirófano', 'Presencia completa del equipo quirúrgico', 'exito_falla'),
(9,  'intraoperatorio', 'Chequeo en quirófano', 'Traslado correcto de camilla a mesa quirúrgica', 'exito_falla'),
(10, 'intraoperatorio', 'Chequeo en quirófano', 'Posicionamiento correcto en mesa operatoria', 'exito_falla'),
(11, 'intraoperatorio', 'Chequeo en quirófano', 'Placa instalada en el lugar correcto', 'exito_falla'),
(12, 'intraoperatorio', 'Pausa quirúrgica', 'Confirmación de todo el equipo de quirófano', 'exito_falla'),
(13, 'intraoperatorio', 'Pausa quirúrgica', 'Confirmación del paciente', 'exito_falla'),
(14, 'intraoperatorio', 'Pausa quirúrgica', 'Confirmación de buenas condiciones de esterilidad', 'exito_falla'),
(15, 'intraoperatorio', 'Pausa quirúrgica', 'Revisión de máquina de anestesia', 'exito_falla'),
(16, 'intraoperatorio', 'Pausa quirúrgica', 'Confirmación de suministro de anestesia', 'exito_falla'),
(17, 'intraoperatorio', 'Pausa quirúrgica', 'Cirujano indica plan quirúrgico', 'exito_falla'),
(18, 'intraoperatorio', 'Pausa quirúrgica', 'Incisión', 'exito_falla'),
(19, 'intraoperatorio', 'Gestión de cuidados', 'Registro de balance hídrico', 'aceptabilidad'),
(20, 'intraoperatorio', 'Gestión de cuidados', 'Registro de seguridad en administración de medicamentos', 'aceptabilidad'),
(21, 'intraoperatorio', 'Gestión de cuidados', 'Registro de transfusión de sangre', 'aceptabilidad'),
(22, 'intraoperatorio', 'Salida quirúrgica', 'El cirujano anuncia el fin de los procedimientos quirúrgicos', 'exito_falla'),
(23, 'intraoperatorio', 'Salida quirúrgica', 'Confirmación del procedimiento quirúrgico efectivamente realizado', 'exito_falla'),
(24, 'intraoperatorio', 'Salida quirúrgica', 'Conteo del instrumental satisfactorio', 'exito_falla'),
(25, 'intraoperatorio', 'Salida quirúrgica', 'Cierre de la incisión', 'exito_falla'),
(26, 'postoperatorio', 'Ingreso a sala de recuperación', 'Confirmación del tipo de cama para el paciente', 'exito_falla'),
(27, 'postoperatorio', 'Ingreso a sala de recuperación', 'Cama post anestésica disponible', 'exito_falla'),
(28, 'postoperatorio', 'Ingreso a sala de recuperación', 'Gases clínicos disponibles', 'exito_falla'),
(29, 'postoperatorio', 'Ingreso a sala de recuperación', 'Bombas de infusión disponibles', 'exito_falla'),
(30, 'postoperatorio', 'Ingreso a sala de recuperación', 'Monitores disponibles', 'exito_falla'),
(31, 'postoperatorio', 'Ingreso a sala de recuperación', 'Electrodos disponibles', 'exito_falla'),
(32, 'postoperatorio', 'Ingreso a sala de recuperación', 'Confirmación de la disposición de personal', 'exito_falla'),
(33, 'postoperatorio', 'Ingreso a sala de recuperación', 'Medicamentos disponibles', 'exito_falla'),
(34, 'postoperatorio', 'Ingreso a sala de recuperación', 'Portasueros disponibles', 'exito_falla'),
(35, 'postoperatorio', 'Traslado seguro', 'Signos vitales dentro de los límites normales', 'exito_falla'),
(36, 'postoperatorio', 'Traslado seguro', 'Zona operatoria limpia', 'exito_falla'),
(37, 'postoperatorio', 'Traslado seguro', 'Documentación del paciente: ficha clínica y chequeo preanestésico', 'exito_falla'),
(38, 'postoperatorio', 'Traslado seguro', 'Sueros de mantención pasando correctamente', 'exito_falla');
