-- Proyecto 1 - BD Hospitales de Occidente
-- 07_cirugia.sql : agendamiento, evaluacion preoperatoria y cirugia

-- el cirujano solicita la cirugia al comite medico
create table agendamiento_quirurgico (
    id_agendamiento serial primary key,
    paciente_id integer not null references paciente(id_paciente),
    medico_cirujano_id integer not null references medico(id_medico),
    caracter varchar(15) not null,
    historia_clinica text,
    tipo_procedimiento text not null,
    tiempo_estimado_min smallint not null,
    tipo_anestesia varchar(80) not null,
    fecha_hora_solicitud timestamptz not null,
    estado_solicitud varchar(15) not null,
    motivo_rechazo text,
    quirofano_solicitado_id integer references quirofano(id_quirofano),
    fecha_hora_agendada timestamptz,
    check (caracter in ('urgente','programado')),
    check (estado_solicitud in ('pendiente','aprobada','rechazada'))
);

-- interrogatorio y exploracion fisica antes de la cirugia
create table historia_clinica (
    id_historia_clinica serial primary key,
    agendamiento_id integer not null unique references agendamiento_quirurgico(id_agendamiento),
    medico_id integer not null references medico(id_medico),
    fecha date not null,
    fuente_interrogatorio varchar(10) not null,
    religion varchar(40),
    ocupacion varchar(60),
    lugar_nacimiento varchar(80),
    lugar_residencia varchar(80),
    antecedentes_heredofamiliares text not null,
    antecedentes_personales_no_patologicos text not null,
    antecedentes_patologicos text not null,
    padecimiento_actual text not null,
    interrogatorio_aparatos_sistemas text,
    sintomas_generales_terapeutica text,
    estudios_previos text,
    signos_vitales text,
    exploracion_general text,
    exploracion_sistematizada text,
    check (fuente_interrogatorio in ('directo','indirecto'))
);

-- el paciente y el medico firman para autorizar la cirugia
create table consentimiento_informado (
    id_consentimiento serial primary key,
    agendamiento_id integer not null references agendamiento_quirurgico(id_agendamiento) on delete cascade,
    procedimiento_nombre text not null,
    procedimiento_objetivo text not null,
    procedimiento_caracteristicas text not null,
    procedimiento_riesgos text not null,
    medico_nombre varchar(150) not null,
    medico_firmado boolean not null default false,
    paciente_firma_nombre varchar(150) not null,
    paciente_firmado boolean not null default false,
    fecha_obtencion date not null
);

-- evaluacion del riesgo de anestesia
create table chequeo_preanestesico (
    id_chequeo_preanestesico serial primary key,
    agendamiento_id integer not null unique references agendamiento_quirurgico(id_agendamiento),
    clasificacion_asa varchar(5) not null,
    medico_asa_nombre varchar(150) not null,
    plan_anestesia text not null,
    anestesista_nombre varchar(150) not null,
    check (clasificacion_asa in ('I','II','III','IV','V','VI'))
);

-- la cirugia se hace sobre un agendamiento que ya fue aprobado
create table cirugia (
    id_cirugia serial primary key,
    agendamiento_id integer not null unique references agendamiento_quirurgico(id_agendamiento),
    quirofano_id integer not null references quirofano(id_quirofano),
    paciente_id integer not null references paciente(id_paciente),
    cirujano_id integer not null references medico(id_medico),
    ingreso_id integer references ingreso(id_ingreso),
    fecha_hora_inicio timestamptz not null,
    fecha_hora_fin timestamptz,
    condicion_evolucion varchar(25),
    estado varchar(20) not null,
    check (condicion_evolucion in ('sin_complicaciones','complicaciones','complicaciones_graves')),
    check (estado in ('preoperatorio','intraoperatorio','postoperatorio','finalizada'))
);

-- el enfermero anota cada paso que se va haciendo
create table registro_procedimiento (
    id_registro_procedimiento serial primary key,
    cirugia_id integer not null references cirugia(id_cirugia) on delete cascade,
    etapa varchar(20) not null,
    aspecto varchar(60) not null,
    exito boolean not null,
    descripcion text,
    hora_registro timestamptz not null,
    enfermero_id integer not null references enfermero(id_enfermero),
    fecha_documentacion date,
    check (etapa in ('preoperatorio','intraoperatorio','postoperatorio'))
);

-- insumos, instrumentos y equipos que pide el cirujano
create table requerimiento_quirurgico (
    id_requerimiento serial primary key,
    agendamiento_id integer not null references agendamiento_quirurgico(id_agendamiento) on delete cascade,
    tipo_recurso varchar(20) not null,
    insumo_id integer references insumo(id_insumo),
    instrumento_id integer references instrumento(id_instrumento),
    equipo_id integer references equipo(id_equipo),
    cantidad smallint not null,
    check (tipo_recurso in ('insumo','instrumento','equipo'))
);

-- medicos y enfermeros que participan en la cirugia
create table cirugia_personal (
    id_cirugia_personal serial primary key,
    cirugia_id integer not null references cirugia(id_cirugia) on delete cascade,
    medico_id integer references medico(id_medico),
    enfermero_id integer references enfermero(id_enfermero),
    rol varchar(60) not null
);

-- insumos que se usaron de verdad en la operacion
create table cirugia_insumo (
    id_cirugia_insumo serial primary key,
    cirugia_id integer not null references cirugia(id_cirugia) on delete cascade,
    insumo_id integer not null references insumo(id_insumo),
    cantidad smallint not null,
    costo_unitario numeric(10,2) not null
);
