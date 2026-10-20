-- Proyecto 1 - BD Hospitales de Occidente
-- 14_indices.sql : indices para llaves foraneas y fechas de consulta frecuente
--
-- PostgreSQL crea indice automaticamente solo para PRIMARY KEY y UNIQUE.
-- Sin indice en la llave foranea, cada JOIN con el padre y cada borrado o
-- actualizacion del padre recorre completa la tabla hija.
-- Las FK que ya son la primera columna de una PK o UNIQUE no lo necesitan.

set search_path to public;

-- ============================================================
-- llaves foraneas
-- ============================================================
create index ix_hospital_id_municipio on hospital (id_municipio);
create index ix_medico_id_especialidad on medico (id_especialidad);
create index ix_medico_id_hospital on medico (id_hospital);
create index ix_medico_id_municipio on medico (id_municipio);
create index ix_enfermero_id_hospital on enfermero (id_hospital);
create index ix_turno_medico_id_medico on turno_medico (id_medico);
create index ix_paciente_id_estado_civil on paciente (id_estado_civil);
create index ix_paciente_id_municipio on paciente (id_municipio);
create index ix_encargado_id_municipio on encargado (id_municipio);
create index ix_paciente_encargado_id_encargado on paciente_encargado (id_encargado);
create index ix_paciente_encargado_id_parentesco on paciente_encargado (id_parentesco);
create index ix_cita_id_medico on cita (id_medico);
create index ix_cita_id_paciente on cita (id_paciente);
create index ix_consulta_id_diagnostico on consulta (id_diagnostico);
create index ix_receta_medicamento_id_medicamento on receta_medicamento (id_medicamento);
create index ix_ingreso_id_camilla on ingreso (id_camilla);
create index ix_ingreso_id_medico_encargado on ingreso (id_medico_encargado);
create index ix_ingreso_id_paciente on ingreso (id_paciente);
create index ix_ingreso_id_quirofano on ingreso (id_quirofano);
create index ix_ingreso_id_servicio on ingreso (id_servicio);
create index ix_ingreso_id_turno on ingreso (id_turno);
create index ix_ingreso_id_unidad on ingreso (id_unidad);
create index ix_egreso_id_diagnostico_principal on egreso (id_diagnostico_principal);
create index ix_egreso_id_medico on egreso (id_medico);
create index ix_egreso_diagnostico_id_diagnostico on egreso_diagnostico (id_diagnostico);
create index ix_institucion_externa_id_municipio on institucion_externa (id_municipio);
create index ix_traslado_id_consulta on traslado (id_consulta);
create index ix_traslado_id_ingreso on traslado (id_ingreso);
create index ix_traslado_id_institucion_destino on traslado (id_institucion_destino);
create index ix_traslado_id_medico_indica on traslado (id_medico_indica);
create index ix_traslado_id_unidad_destino on traslado (id_unidad_destino);
create index ix_traslado_id_unidad_origen on traslado (id_unidad_origen);
create index ix_tipo_cirugia_id_especialidad on tipo_cirugia (id_especialidad);
create index ix_agendamiento_quirurgico_id_medico_cirujano on agendamiento_quirurgico (id_medico_cirujano);
create index ix_agendamiento_quirurgico_id_paciente on agendamiento_quirurgico (id_paciente);
create index ix_agendamiento_quirurgico_id_quirofano_solicitado on agendamiento_quirurgico (id_quirofano_solicitado);
create index ix_agendamiento_quirurgico_id_tipo_anestesia on agendamiento_quirurgico (id_tipo_anestesia);
create index ix_agendamiento_quirurgico_id_tipo_cirugia on agendamiento_quirurgico (id_tipo_cirugia);
create index ix_requerimiento_insumo_id_insumo on requerimiento_insumo (id_insumo);
create index ix_requerimiento_instrumento_id_instrumento on requerimiento_instrumento (id_instrumento);
create index ix_requerimiento_equipo_id_equipo on requerimiento_equipo (id_equipo);
create index ix_historia_clinica_id_medico on historia_clinica (id_medico);
create index ix_consentimiento_informado_id_medico on consentimiento_informado (id_medico);
create index ix_chequeo_preanestesico_id_medico_anestesista on chequeo_preanestesico (id_medico_anestesista);
create index ix_chequeo_preanestesico_id_medico_clasifica on chequeo_preanestesico (id_medico_clasifica);
create index ix_cirugia_id_ingreso on cirugia (id_ingreso);
create index ix_cirugia_id_quirofano on cirugia (id_quirofano);
create index ix_cirugia_personal_id_enfermero on cirugia_personal (id_enfermero);
create index ix_cirugia_personal_id_medico on cirugia_personal (id_medico);
create index ix_cirugia_personal_id_rol on cirugia_personal (id_rol);
create index ix_registro_procedimiento_id_aspecto on registro_procedimiento (id_aspecto);
create index ix_registro_procedimiento_id_enfermero on registro_procedimiento (id_enfermero);
create index ix_documentacion_etapa_id_enfermero on documentacion_etapa (id_enfermero);
create index ix_cirugia_insumo_id_insumo on cirugia_insumo (id_insumo);
create index ix_hospitalizacion_insumo_id_insumo on hospitalizacion_insumo (id_insumo);
create index ix_pago_id_metodo_pago on pago (id_metodo_pago);
create index ix_calificacion_id_consulta on calificacion (id_consulta);
create index ix_calificacion_id_encargado on calificacion (id_encargado);
create index ix_calificacion_id_enfermero on calificacion (id_enfermero);
create index ix_calificacion_id_hospital on calificacion (id_hospital);
create index ix_calificacion_id_medico on calificacion (id_medico);
create index ix_calificacion_id_paciente on calificacion (id_paciente);

-- ============================================================
-- fechas usadas para filtrar reportes por lapso de tiempo
-- ============================================================
create index ix_cita_fecha_hora on cita (fecha_hora);
create index ix_ingreso_fecha_hora on ingreso (fecha_hora_ingreso);
create index ix_egreso_fecha_hora on egreso (fecha_hora_egreso);
create index ix_cirugia_fecha_hora_inicio on cirugia (fecha_hora_inicio);
create index ix_factura_fecha_emision on factura (fecha_emision);
create index ix_pago_fecha_pago on pago (fecha_pago);
