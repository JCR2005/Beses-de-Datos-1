-- Proyecto 1 - BD Hospitales de Occidente
-- 99_secuencias.sql : ajusta los identity despues de cargar datos con id fijo
--
-- Si el contador no se mueve, el siguiente INSERT sin id generaria un valor
-- que ya existe y chocaria con la llave primaria. A cada tabla se le deja
-- su contador en el siguiente numero despues del mayor id usado.

select setval(pg_get_serial_sequence('departamento', 'id_departamento'), coalesce(max(id_departamento), 0) + 1, false) from departamento;
select setval(pg_get_serial_sequence('municipio', 'id_municipio'), coalesce(max(id_municipio), 0) + 1, false) from municipio;
select setval(pg_get_serial_sequence('hospital', 'id_hospital'), coalesce(max(id_hospital), 0) + 1, false) from hospital;
select setval(pg_get_serial_sequence('unidad_medica', 'id_unidad'), coalesce(max(id_unidad), 0) + 1, false) from unidad_medica;
select setval(pg_get_serial_sequence('servicio_atencion', 'id_servicio'), coalesce(max(id_servicio), 0) + 1, false) from servicio_atencion;
select setval(pg_get_serial_sequence('camilla', 'id_camilla'), coalesce(max(id_camilla), 0) + 1, false) from camilla;
select setval(pg_get_serial_sequence('quirofano', 'id_quirofano'), coalesce(max(id_quirofano), 0) + 1, false) from quirofano;
select setval(pg_get_serial_sequence('especialidad', 'id_especialidad'), coalesce(max(id_especialidad), 0) + 1, false) from especialidad;
select setval(pg_get_serial_sequence('medico', 'id_medico'), coalesce(max(id_medico), 0) + 1, false) from medico;
select setval(pg_get_serial_sequence('enfermero', 'id_enfermero'), coalesce(max(id_enfermero), 0) + 1, false) from enfermero;
select setval(pg_get_serial_sequence('turno_emergencia', 'id_turno'), coalesce(max(id_turno), 0) + 1, false) from turno_emergencia;
select setval(pg_get_serial_sequence('insumo', 'id_insumo'), coalesce(max(id_insumo), 0) + 1, false) from insumo;
select setval(pg_get_serial_sequence('instrumento', 'id_instrumento'), coalesce(max(id_instrumento), 0) + 1, false) from instrumento;
select setval(pg_get_serial_sequence('equipo', 'id_equipo'), coalesce(max(id_equipo), 0) + 1, false) from equipo;
select setval(pg_get_serial_sequence('medicamento', 'id_medicamento'), coalesce(max(id_medicamento), 0) + 1, false) from medicamento;
select setval(pg_get_serial_sequence('diagnostico', 'id_diagnostico'), coalesce(max(id_diagnostico), 0) + 1, false) from diagnostico;
select setval(pg_get_serial_sequence('estado_civil', 'id_estado_civil'), coalesce(max(id_estado_civil), 0) + 1, false) from estado_civil;
select setval(pg_get_serial_sequence('parentesco', 'id_parentesco'), coalesce(max(id_parentesco), 0) + 1, false) from parentesco;
select setval(pg_get_serial_sequence('paciente', 'id_paciente'), coalesce(max(id_paciente), 0) + 1, false) from paciente;
select setval(pg_get_serial_sequence('encargado', 'id_encargado'), coalesce(max(id_encargado), 0) + 1, false) from encargado;
select setval(pg_get_serial_sequence('cita', 'id_cita'), coalesce(max(id_cita), 0) + 1, false) from cita;
select setval(pg_get_serial_sequence('consulta', 'id_consulta'), coalesce(max(id_consulta), 0) + 1, false) from consulta;
select setval(pg_get_serial_sequence('receta', 'id_receta'), coalesce(max(id_receta), 0) + 1, false) from receta;
select setval(pg_get_serial_sequence('ingreso', 'id_ingreso'), coalesce(max(id_ingreso), 0) + 1, false) from ingreso;
select setval(pg_get_serial_sequence('egreso', 'id_egreso'), coalesce(max(id_egreso), 0) + 1, false) from egreso;
select setval(pg_get_serial_sequence('institucion_externa', 'id_institucion'), coalesce(max(id_institucion), 0) + 1, false) from institucion_externa;
select setval(pg_get_serial_sequence('traslado', 'id_traslado'), coalesce(max(id_traslado), 0) + 1, false) from traslado;
select setval(pg_get_serial_sequence('tipo_anestesia', 'id_tipo_anestesia'), coalesce(max(id_tipo_anestesia), 0) + 1, false) from tipo_anestesia;
select setval(pg_get_serial_sequence('tipo_cirugia', 'id_tipo_cirugia'), coalesce(max(id_tipo_cirugia), 0) + 1, false) from tipo_cirugia;
select setval(pg_get_serial_sequence('aspecto_quirurgico', 'id_aspecto'), coalesce(max(id_aspecto), 0) + 1, false) from aspecto_quirurgico;
select setval(pg_get_serial_sequence('rol_quirurgico', 'id_rol'), coalesce(max(id_rol), 0) + 1, false) from rol_quirurgico;
select setval(pg_get_serial_sequence('agendamiento_quirurgico', 'id_agendamiento'), coalesce(max(id_agendamiento), 0) + 1, false) from agendamiento_quirurgico;
select setval(pg_get_serial_sequence('historia_clinica', 'id_historia_clinica'), coalesce(max(id_historia_clinica), 0) + 1, false) from historia_clinica;
select setval(pg_get_serial_sequence('consentimiento_informado', 'id_consentimiento'), coalesce(max(id_consentimiento), 0) + 1, false) from consentimiento_informado;
select setval(pg_get_serial_sequence('chequeo_preanestesico', 'id_chequeo'), coalesce(max(id_chequeo), 0) + 1, false) from chequeo_preanestesico;
select setval(pg_get_serial_sequence('cirugia', 'id_cirugia'), coalesce(max(id_cirugia), 0) + 1, false) from cirugia;
select setval(pg_get_serial_sequence('cirugia_personal', 'id_cirugia_personal'), coalesce(max(id_cirugia_personal), 0) + 1, false) from cirugia_personal;
select setval(pg_get_serial_sequence('registro_procedimiento', 'id_registro'), coalesce(max(id_registro), 0) + 1, false) from registro_procedimiento;
select setval(pg_get_serial_sequence('metodo_pago', 'id_metodo_pago'), coalesce(max(id_metodo_pago), 0) + 1, false) from metodo_pago;
select setval(pg_get_serial_sequence('factura', 'id_factura'), coalesce(max(id_factura), 0) + 1, false) from factura;
select setval(pg_get_serial_sequence('pago', 'id_pago'), coalesce(max(id_pago), 0) + 1, false) from pago;
select setval(pg_get_serial_sequence('calificacion', 'id_calificacion'), coalesce(max(id_calificacion), 0) + 1, false) from calificacion;
