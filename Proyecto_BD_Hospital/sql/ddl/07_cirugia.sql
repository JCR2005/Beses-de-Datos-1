-- Proyecto 1 - BD Hospitales de Occidente
-- 07_cirugia.sql : agendamiento, evaluacion preoperatoria y cirugia

-- el cirujano solicita la cirugia al comite medico
create table agendamiento_quirurgico (
    id_agendamiento serial primary key,
    paciente_id integer not null references paciente(id_paciente)
        on delete no action on update cascade,
    medico_cirujano_id integer not null references medico(id_medico)
        on delete no action on update cascade,
    caracter varchar(15) not null,
    historia_clinica text,
    tipo_procedimiento text not null,
    tiempo_estimado_min smallint not null,
    tipo_anestesia varchar(80) not null,
    fecha_hora_solicitud timestamptz not null,
    estado_solicitud varchar(15) not null,
    motivo_rechazo text,
    quirofano_solicitado_id integer references quirofano(id_quirofano)
        on delete no action on update cascade,
    fecha_hora_agendada timestamptz,
    -- valida si la cirugia es urgente o programada
    check (caracter in ('urgente','programado')),
    -- valida la decision del comite sobre la solicitud
    check (estado_solicitud in ('pendiente','aprobada','rechazada'))
);

-- interrogatorio y exploracion fisica antes de la cirugia
create table historia_clinica (
    id_historia_clinica serial primary key,
    agendamiento_id integer not null unique references agendamiento_quirurgico(id_agendamiento)
        on delete no action on update cascade,
    medico_id integer not null references medico(id_medico)
        on delete no action on update cascade,
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
    -- valida si la informacion se recibio del paciente o de un familiar
    check (fuente_interrogatorio in ('directo','indirecto'))
);

-- el paciente y el medico firman para autorizar la cirugia
create table consentimiento_informado (
    id_consentimiento serial primary key,
    agendamiento_id integer not null references agendamiento_quirurgico(id_agendamiento)
        on delete cascade on update cascade,
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
    agendamiento_id integer not null unique references agendamiento_quirurgico(id_agendamiento)
        on delete no action on update cascade,
    clasificacion_asa varchar(5) not null,
    medico_asa_nombre varchar(150) not null,
    plan_anestesia text not null,
    anestesista_nombre varchar(150) not null,
    -- valida la clasificacion de riesgo segun la society for american anesthesiologists
    check (clasificacion_asa in ('I','II','III','IV','V','VI'))
);

-- la cirugia se hace sobre un agendamiento que ya fue aprobado
create table cirugia (
    id_cirugia serial primary key,
    agendamiento_id integer not null unique references agendamiento_quirurgico(id_agendamiento)
        on delete no action on update cascade,
    quirofano_id integer not null references quirofano(id_quirofano)
        on delete no action on update cascade,
    paciente_id integer not null references paciente(id_paciente)
        on delete no action on update cascade,
    cirujano_id integer not null references medico(id_medico)
        on delete no action on update cascade,
    ingreso_id integer references ingreso(id_ingreso)
        on delete no action on update cascade,
    fecha_hora_inicio timestamptz not null,
    fecha_hora_fin timestamptz,
    condicion_evolucion varchar(25),
    estado varchar(20) not null,
    -- valida como termino la evolution del paciente en quirofano
    check (condicion_evolucion in ('sin_complicaciones','complicaciones','complicaciones_graves')),
    -- valida en que fase de la cirugia se encuentra el paciente
    check (estado in ('preoperatorio','intraoperatorio','postoperatorio','finalizada'))
);

-- el enfermero anota cada paso que se va haciendo
create table registro_procedimiento (
    id_registro_procedimiento serial primary key,
    cirugia_id integer not null references cirugia(id_cirugia)
        on delete cascade on update cascade,
    etapa varchar(20) not null,
    aspecto varchar(60) not null,
    exito boolean not null,
    descripcion text,
    hora_registro timestamptz not null,
    enfermero_id integer not null references enfermero(id_enfermero)
        on delete no action on update cascade,
    fecha_documentacion date,
    -- valida en que momento de la cirugia se documenta el paso
    check (etapa in ('preoperatorio','intraoperatorio','postoperatorio'))
);

-- insumos, instrumentos y equipos que pide el cirujano
create table requerimiento_quirurgico (
    id_requerimiento serial primary key,
    agendamiento_id integer not null references agendamiento_quirurgico(id_agendamiento)
        on delete cascade on update cascade,
    tipo_recurso varchar(20) not null,
    insumo_id integer references insumo(id_insumo)
        on delete no action on update cascade,
    instrumento_id integer references instrumento(id_instrumento)
        on delete no action on update cascade,
    equipo_id integer references equipo(id_equipo)
        on delete no action on update cascade,
    cantidad smallint not null,
    -- valida que clase de recurso se pide para la cirugia
    check (tipo_recurso in ('insumo','instrumento','equipo')),
    -- valida que solo este llena la llave foranea del tipo de recurso pedido
    check (
        (tipo_recurso = 'insumo' and insumo_id is not null
            and instrumento_id is null and equipo_id is null)
     or (tipo_recurso = 'instrumento' and instrumento_id is not null
            and insumo_id is null and equipo_id is null)
     or (tipo_recurso = 'equipo' and equipo_id is not null
            and insumo_id is null and instrumento_id is null)
    )
);

-- medicos y enfermeros que participan en la cirugia (asociativa M:N)
create table cirugia_personal (
    id_cirugia_personal serial primary key,
    cirugia_id integer not null references cirugia(id_cirugia)
        on delete cascade on update cascade,
    medico_id integer references medico(id_medico)
        on delete no action on update cascade,
    enfermero_id integer references enfermero(id_enfermero)
        on delete no action on update cascade,
    rol varchar(60) not null,
    -- valida que al menos participe un medico o un enfermero en la cirugia
    check ((medico_id is not null)::int + (enfermero_id is not null)::int >= 1)
);

-- insumos que se usaron de verdad en la operacion (asociativa M:N)
create table cirugia_insumo (
    id_cirugia_insumo serial primary key,
    cirugia_id integer not null references cirugia(id_cirugia)
        on delete cascade on update cascade,
    insumo_id integer not null references insumo(id_insumo)
        on delete no action on update cascade,
    cantidad smallint not null,
    costo_unitario numeric(10,2) not null
);