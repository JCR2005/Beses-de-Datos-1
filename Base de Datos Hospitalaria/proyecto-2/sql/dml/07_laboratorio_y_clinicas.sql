-- Proyecto 2 - BD Hospitales de Occidente
-- 07_laboratorio_y_clinicas.sql : examenes de laboratorio y ordenes de las consultas (datos FICTICIOS)
-- (las clinicas se crean en ddl/04 a partir de las citas)

set role admin;

insert into examen_laboratorio (id_examen, nombre, descripcion, costo) values
(1, 'Hematología completa', 'Conteo de glóbulos rojos, blancos y plaquetas', 75.00),
(2, 'Glucosa en ayunas', 'Nivel de azúcar en sangre', 35.00),
(3, 'Hemoglobina glicosilada', 'Control de diabetes de los últimos 3 meses', 120.00),
(4, 'Perfil de lípidos', 'Colesterol total, HDL, LDL y triglicéridos', 110.00),
(5, 'Creatinina', 'Función de los riñones', 40.00),
(6, 'Ácido úrico', 'Nivel de ácido úrico en sangre', 40.00),
(7, 'Examen general de orina', 'Análisis físico, químico y microscópico de la orina', 45.00),
(8, 'Examen de heces', 'Búsqueda de parásitos y sangre oculta', 45.00),
(9, 'TSH', 'Función de la tiroides', 130.00),
(10, 'Pruebas hepáticas', 'Función del hígado', 150.00),
(11, 'Electrolitos', 'Sodio, potasio y cloro', 95.00),
(12, 'Proteína C reactiva', 'Indicador de inflamación', 80.00),
(13, 'Prueba de embarazo', 'Hormona hCG en sangre', 60.00),
(14, 'Rayos X de tórax', 'Radiografía de pulmones y corazón', 175.00),
(15, 'Ultrasonido abdominal', 'Imagen de los órganos del abdomen', 300.00),
(16, 'Electrocardiograma', 'Actividad eléctrica del corazón', 150.00);

-- una de cada tres consultas termina con orden de laboratorio
insert into orden_laboratorio (id_orden, id_consulta, fecha, indicaciones)
select co.id_consulta, co.id_consulta, c.fecha_hora::date,
       case when co.id_consulta % 2 = 0 then 'Presentarse en ayunas de 8 horas.' else 'Traer resultados a la próxima cita.' end
from consulta co
inner join cita c on c.id_cita = co.id_cita
where co.id_consulta % 3 = 0;

-- cada orden pide uno o dos examenes
insert into orden_examen (id_orden, id_examen)
select id_orden, 1 + id_orden % 16 from orden_laboratorio
union
select id_orden, 1 + (id_orden + 5) % 16 from orden_laboratorio where id_orden % 2 = 0;

select setval(pg_get_serial_sequence('examen_laboratorio', 'id_examen'), (select max(id_examen) from examen_laboratorio));
select setval(pg_get_serial_sequence('orden_laboratorio', 'id_orden'), (select max(id_orden) from orden_laboratorio));

reset role;
