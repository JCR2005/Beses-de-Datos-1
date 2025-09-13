-- Proyecto 1 - BD Hospitales de Occidente
-- 07_secuencias.sql : ajusta TODAS las secuencias despues de cargar los datos
--
-- Los datos de prueba se cargan con su id fijo para que las referencias
-- cruzadas sean legibles. Si no movemos la secuencia, el siguiente INSERT
-- que omita el id genera un 1 y choca con la llave primaria.
-- Por eso, para cada tabla con id SERIAL dejamos la secuencia en el maximo
-- id realmente usado. is_called = true hace que el proximo valor siga
-- al maximo en lugar de repetirlo.

select setval('agendamiento_quirurgico_id_agendamiento_seq', (select max(id_agendamiento) from agendamiento_quirurgico), true);
select setval('camilla_id_camilla_seq', (select max(id_camilla) from camilla), true);
select setval('chequeo_preanestesico_id_chequeo_preanestesico_seq', (select max(id_chequeo_preanestesico) from chequeo_preanestesico), true);
select setval('cirugia_id_cirugia_seq', (select max(id_cirugia) from cirugia), true);
select setval('cirugia_insumo_id_cirugia_insumo_seq', (select max(id_cirugia_insumo) from cirugia_insumo), true);
select setval('cirugia_personal_id_cirugia_personal_seq', (select max(id_cirugia_personal) from cirugia_personal), true);
select setval('cita_id_cita_seq', (select max(id_cita) from cita), true);
select setval('consentimiento_informado_id_consentimiento_seq', (select max(id_consentimiento) from consentimiento_informado), true);
select setval('consulta_id_consulta_seq', (select max(id_consulta) from consulta), true);
select setval('departamento_id_departamento_seq', (select max(id_departamento) from departamento), true);
select setval('egreso_id_egreso_seq', (select max(id_egreso) from egreso), true);
select setval('encargado_id_encargado_seq', (select max(id_encargado) from encargado), true);
select setval('enfermero_id_enfermero_seq', (select max(id_enfermero) from enfermero), true);
select setval('equipo_id_equipo_seq', (select max(id_equipo) from equipo), true);
select setval('especialidad_id_especialidad_seq', (select max(id_especialidad) from especialidad), true);
select setval('factura_id_factura_seq', (select max(id_factura) from factura), true);
select setval('historia_clinica_id_historia_clinica_seq', (select max(id_historia_clinica) from historia_clinica), true);
select setval('hospital_id_hospital_seq', (select max(id_hospital) from hospital), true);
select setval('hospitalizacion_insumo_id_hospitalizacion_insumo_seq', (select max(id_hospitalizacion_insumo) from hospitalizacion_insumo), true);
select setval('ingreso_id_ingreso_seq', (select max(id_ingreso) from ingreso), true);
select setval('instrumento_id_instrumento_seq', (select max(id_instrumento) from instrumento), true);
select setval('insumo_id_insumo_seq', (select max(id_insumo) from insumo), true);
select setval('medico_id_medico_seq', (select max(id_medico) from medico), true);
select setval('municipio_id_municipio_seq', (select max(id_municipio) from municipio), true);
select setval('paciente_id_paciente_seq', (select max(id_paciente) from paciente), true);
select setval('paciente_encargado_id_paciente_encargado_seq', (select max(id_paciente_encargado) from paciente_encargado), true);
select setval('pago_id_pago_seq', (select max(id_pago) from pago), true);
select setval('quirofano_id_quirofano_seq', (select max(id_quirofano) from quirofano), true);
select setval('receta_id_receta_seq', (select max(id_receta) from receta), true);
select setval('receta_medicamento_id_receta_medicamento_seq', (select max(id_receta_medicamento) from receta_medicamento), true);
select setval('registro_procedimiento_id_registro_procedimiento_seq', (select max(id_registro_procedimiento) from registro_procedimiento), true);
select setval('requerimiento_quirurgico_id_requerimiento_seq', (select max(id_requerimiento) from requerimiento_quirurgico), true);
select setval('servicio_atencion_id_servicio_seq', (select max(id_servicio) from servicio_atencion), true);
select setval('traslado_id_traslado_seq', (select max(id_traslado) from traslado), true);
select setval('unidad_medica_id_unidad_seq', (select max(id_unidad) from unidad_medica), true);
