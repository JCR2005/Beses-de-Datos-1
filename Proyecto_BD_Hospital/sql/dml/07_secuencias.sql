-- Proyecto 1 - BD Hospitales de Occidente
-- 07_secuencias.sql : ajusta las secuencias despues de cargar los datos

-- como cargamos los registros con su id fijo, dejamos la secuencia en el
-- ultimo id usado para que los siguientes registros no se repitan
select setval('hospital_id_hospital_seq', (select max(id_hospital) from hospital));
select setval('medico_id_medico_seq', (select max(id_medico) from medico));
select setval('enfermero_id_enfermero_seq', (select max(id_enfermero) from enfermero));
select setval('paciente_id_paciente_seq', (select max(id_paciente) from paciente));
select setval('encargado_id_encargado_seq', (select max(id_encargado) from encargado));
select setval('cita_id_cita_seq', (select max(id_cita) from cita));
select setval('consulta_id_consulta_seq', (select max(id_consulta) from consulta));
select setval('factura_id_factura_seq', (select max(id_factura) from factura));
select setval('pago_id_pago_seq', (select max(id_pago) from pago));
select setval('ingreso_id_ingreso_seq', (select max(id_ingreso) from ingreso));
select setval('cirugia_id_cirugia_seq', (select max(id_cirugia) from cirugia));
