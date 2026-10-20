--
-- PostgreSQL database dump
--

\restrict fgJUgfaaKt6lRmvmD5KqOd8LZq63L4BWBiYHjreDgEt8WWSgivO5MPFyRKwJssI

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg13+2)
-- Dumped by pg_dump version 18.6 (Debian 18.6-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fn_agendamiento_aprobado(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_agendamiento_aprobado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if (select estado_solicitud from agendamiento_quirurgico
         where id_agendamiento = new.id_agendamiento) <> 'aprobada' then
        raise exception 'El agendamiento % no está aprobado por el comité (%)', new.id_agendamiento, tg_table_name;
    end if;
    return new;
end $$;


--
-- Name: fn_calificacion_consulta(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_calificacion_consulta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if new.id_consulta is not null and new.id_medico is distinct from
       (select ci.id_medico from consulta co join cita ci on ci.id_cita = co.id_cita
         where co.id_consulta = new.id_consulta) then
        raise exception 'La calificación de la consulta % debe ser para el médico que la atendió', new.id_consulta;
    end if;
    return new;
end $$;


--
-- Name: fn_camilla_unidad(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_camilla_unidad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if fn_tipo_unidad(new.id_unidad) not in ('Emergencias','Hospitalización') then
        raise exception 'La camilla % debe pertenecer a Emergencias u Hospitalización', new.numero;
    end if;
    return new;
end $$;


--
-- Name: fn_cirugia_personal_rol(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_cirugia_personal_rol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    v_tipo varchar;
begin
    select tipo_personal into v_tipo from rol_quirurgico where id_rol = new.id_rol;
    if (v_tipo = 'medico' and new.id_medico is null) or (v_tipo = 'enfermero' and new.id_enfermero is null) then
        raise exception 'El rol % lo debe cumplir un %', new.id_rol, v_tipo;
    end if;
    return new;
end $$;


--
-- Name: fn_consulta_cita(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_consulta_cita() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if (select estado from cita where id_cita = new.id_cita) <> 'realizada' then
        raise exception 'La cita % no está realizada; no puede tener consulta', new.id_cita;
    end if;
    return new;
end $$;


--
-- Name: fn_edad(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_edad(p_fecha_nacimiento date, p_fecha date DEFAULT CURRENT_DATE) RETURNS smallint
    LANGUAGE sql IMMUTABLE
    AS $$
    select extract(year from age(p_fecha, p_fecha_nacimiento))::smallint;
$$;


--
-- Name: fn_egreso_fecha(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_egreso_fecha() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    v_ingreso timestamptz;
begin
    select fecha_hora_ingreso into v_ingreso from ingreso where id_ingreso = new.id_ingreso;
    if new.fecha_hora_egreso < v_ingreso then
        raise exception 'El egreso (%) es anterior al ingreso (%)', new.fecha_hora_egreso, v_ingreso;
    end if;
    return new;
end $$;


--
-- Name: fn_hosp_insumo_ingreso(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_hosp_insumo_ingreso() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if fn_tipo_unidad((select id_unidad from ingreso where id_ingreso = new.id_ingreso)) <> 'Hospitalización' then
        raise exception 'El ingreso % no es de Hospitalización', new.id_ingreso;
    end if;
    return new;
end $$;


--
-- Name: fn_ingreso_consistencia(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_ingreso_consistencia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    v_tipo varchar;
    v_turno turno_emergencia%rowtype;
    v_inicio timestamptz;
begin
    v_tipo := fn_tipo_unidad(new.id_unidad);
    if v_tipo = 'Consulta Externa' then
        raise exception 'Consulta Externa no usa ficha de ingreso';
    end if;
    if new.id_servicio is not null
       and (select id_unidad from servicio_atencion where id_servicio = new.id_servicio) <> new.id_unidad then
        raise exception 'El servicio % no pertenece a la unidad del ingreso', new.id_servicio;
    end if;
    if new.id_camilla is not null
       and (select id_unidad from camilla where id_camilla = new.id_camilla) <> new.id_unidad then
        raise exception 'La camilla % no pertenece a la unidad del ingreso', new.id_camilla;
    end if;
    if new.id_quirofano is not null
       and (select id_unidad from quirofano where id_quirofano = new.id_quirofano) <> new.id_unidad then
        raise exception 'El quirófano % no pertenece a la unidad del ingreso', new.id_quirofano;
    end if;
    if (new.id_turno is not null) <> (v_tipo = 'Emergencias') then
        raise exception 'Solo los ingresos a Emergencias llevan turno, prioridad y espera';
    end if;
    if new.id_turno is not null then
        select * into v_turno from turno_emergencia where id_turno = new.id_turno;
        -- las jornadas se definen en hora local de Guatemala
        v_inicio := (v_turno.fecha + case v_turno.jornada when 'diurno' then time '07:00' else time '19:00' end)
                    at time zone 'America/Guatemala';
        if v_turno.id_unidad <> new.id_unidad
           or new.fecha_hora_ingreso < v_inicio
           or new.fecha_hora_ingreso >= v_inicio + interval '12 hours' then
            raise exception 'El ingreso no ocurre dentro del turno % de esa unidad', new.id_turno;
        end if;
    end if;
    return new;
end $$;


--
-- Name: fn_paciente_nacimiento(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_paciente_nacimiento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if new.fecha_nacimiento > current_date then
        raise exception 'La fecha de nacimiento % está en el futuro', new.fecha_nacimiento;
    end if;
    return new;
end $$;


--
-- Name: fn_pago_plan(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_pago_plan() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    v_factura factura%rowtype;
    v_pagado numeric;
begin
    select * into v_factura from factura where id_factura = new.id_factura;
    if new.numero_cuota > v_factura.numero_cuotas then
        raise exception 'La cuota % excede el plan de % cuotas de la factura %',
            new.numero_cuota, v_factura.numero_cuotas, new.id_factura;
    end if;
    select coalesce(sum(monto), 0) into v_pagado
      from pago where id_factura = new.id_factura and id_pago is distinct from new.id_pago;
    if v_pagado + new.monto > v_factura.total then
        raise exception 'Lo pagado (%) superaría el total de la factura (%)', v_pagado + new.monto, v_factura.total;
    end if;
    return new;
end $$;


--
-- Name: fn_quirofano_unidad(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_quirofano_unidad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if fn_tipo_unidad(new.id_unidad) <> 'Cirugía' then
        raise exception 'El quirófano % debe pertenecer a la unidad de Cirugía', new.numero;
    end if;
    return new;
end $$;


--
-- Name: fn_receta_proxima_cita(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_receta_proxima_cita() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    v_fecha date;
begin
    select ci.fecha_hora::date into v_fecha
      from consulta co join cita ci on ci.id_cita = co.id_cita
     where co.id_consulta = new.id_consulta;
    if new.fecha_proxima_cita <= v_fecha then
        raise exception 'La próxima cita (%) debe ser posterior a la consulta (%)', new.fecha_proxima_cita, v_fecha;
    end if;
    return new;
end $$;


--
-- Name: fn_registro_resultado(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_registro_resultado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    v_tipo varchar;
begin
    select tipo_evaluacion into v_tipo from aspecto_quirurgico where id_aspecto = new.id_aspecto;
    if (v_tipo = 'exito_falla' and new.resultado not in ('exito','falla'))
       or (v_tipo = 'aceptabilidad' and new.resultado not in ('aceptable','medianamente_aceptable','no_aceptable')) then
        raise exception 'El resultado "%" no es válido para un aspecto evaluado por %', new.resultado, v_tipo;
    end if;
    return new;
end $$;


--
-- Name: fn_tipo_unidad(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_tipo_unidad(p_id_unidad integer) RETURNS character varying
    LANGUAGE sql STABLE
    AS $$
    select tipo_unidad from unidad_medica where id_unidad = p_id_unidad;
$$;


--
-- Name: fn_traslado_origen(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_traslado_origen() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    v_origen integer;
begin
    if new.id_ingreso is not null then
        select id_unidad into v_origen from ingreso where id_ingreso = new.id_ingreso;
    else
        select u.id_unidad into v_origen
          from consulta co
          join cita ci on ci.id_cita = co.id_cita
          join medico me on me.id_medico = ci.id_medico
          join unidad_medica u on u.id_hospital = me.id_hospital and u.tipo_unidad = 'Consulta Externa'
         where co.id_consulta = new.id_consulta;
    end if;
    if new.id_unidad_origen <> v_origen then
        raise exception 'La unidad de origen % no coincide con la de la ficha de origen (%)', new.id_unidad_origen, v_origen;
    end if;
    return new;
end $$;


--
-- Name: fn_turno_medico_hospital(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_turno_medico_hospital() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if (select id_hospital from medico where id_medico = new.id_medico)
       <> (select u.id_hospital from turno_emergencia t
             join unidad_medica u on u.id_unidad = t.id_unidad
            where t.id_turno = new.id_turno) then
        raise exception 'El médico % no pertenece al hospital del turno %', new.id_medico, new.id_turno;
    end if;
    return new;
end $$;


--
-- Name: fn_turno_unidad(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_turno_unidad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if fn_tipo_unidad(new.id_unidad) <> 'Emergencias' then
        raise exception 'El turno debe pertenecer a la unidad de Emergencias';
    end if;
    return new;
end $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agendamiento_quirurgico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agendamiento_quirurgico (
    id_agendamiento integer NOT NULL,
    id_paciente integer NOT NULL,
    id_medico_cirujano integer NOT NULL,
    id_tipo_cirugia integer NOT NULL,
    id_tipo_anestesia integer NOT NULL,
    caracter character varying(10) NOT NULL,
    resumen_clinico text NOT NULL,
    tiempo_estimado_min smallint NOT NULL,
    fecha_hora_solicitud timestamp with time zone NOT NULL,
    estado_solicitud character varying(9) DEFAULT 'pendiente'::character varying NOT NULL,
    motivo_rechazo text,
    id_quirofano_solicitado integer,
    fecha_hora_agendada timestamp with time zone,
    CONSTRAINT ck_agendamiento_aprobada CHECK ((((estado_solicitud)::text = 'aprobada'::text) = (fecha_hora_agendada IS NOT NULL))),
    CONSTRAINT ck_agendamiento_caracter CHECK (((caracter)::text = ANY ((ARRAY['urgente'::character varying, 'programado'::character varying])::text[]))),
    CONSTRAINT ck_agendamiento_estado CHECK (((estado_solicitud)::text = ANY ((ARRAY['pendiente'::character varying, 'aprobada'::character varying, 'rechazada'::character varying])::text[]))),
    CONSTRAINT ck_agendamiento_fechas CHECK ((fecha_hora_agendada >= fecha_hora_solicitud)),
    CONSTRAINT ck_agendamiento_rechazo CHECK ((((estado_solicitud)::text = 'rechazada'::text) = (motivo_rechazo IS NOT NULL))),
    CONSTRAINT ck_agendamiento_tiempo CHECK ((tiempo_estimado_min > 0))
);


--
-- Name: TABLE agendamiento_quirurgico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.agendamiento_quirurgico IS 'Solicitud de cirugía que el cirujano envía al comité médico.';


--
-- Name: COLUMN agendamiento_quirurgico.caracter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.agendamiento_quirurgico.caracter IS 'urgente o programado.';


--
-- Name: COLUMN agendamiento_quirurgico.resumen_clinico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.agendamiento_quirurgico.resumen_clinico IS 'Resumen de la historia clínica que justifica la cirugía.';


--
-- Name: COLUMN agendamiento_quirurgico.tiempo_estimado_min; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.agendamiento_quirurgico.tiempo_estimado_min IS 'Tiempo estimado de la intervención en minutos.';


--
-- Name: COLUMN agendamiento_quirurgico.fecha_hora_solicitud; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.agendamiento_quirurgico.fecha_hora_solicitud IS 'Fecha y hora en que se envió la solicitud.';


--
-- Name: COLUMN agendamiento_quirurgico.estado_solicitud; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.agendamiento_quirurgico.estado_solicitud IS 'Decisión del comité: pendiente, aprobada o rechazada.';


--
-- Name: COLUMN agendamiento_quirurgico.motivo_rechazo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.agendamiento_quirurgico.motivo_rechazo IS 'Razones del rechazo (base de cirugías rechazadas).';


--
-- Name: COLUMN agendamiento_quirurgico.fecha_hora_agendada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.agendamiento_quirurgico.fecha_hora_agendada IS 'Fecha y hora asignadas al aprobarse.';


--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.agendamiento_quirurgico ALTER COLUMN id_agendamiento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.agendamiento_quirurgico_id_agendamiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: aspecto_quirurgico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aspecto_quirurgico (
    id_aspecto integer NOT NULL,
    etapa character varying(15) NOT NULL,
    seccion character varying(40) NOT NULL,
    nombre character varying(150) NOT NULL,
    tipo_evaluacion character varying(13) NOT NULL,
    CONSTRAINT ck_aspecto_etapa CHECK (((etapa)::text = ANY ((ARRAY['preoperatorio'::character varying, 'intraoperatorio'::character varying, 'postoperatorio'::character varying])::text[]))),
    CONSTRAINT ck_aspecto_evaluacion CHECK (((tipo_evaluacion)::text = ANY ((ARRAY['exito_falla'::character varying, 'aceptabilidad'::character varying])::text[])))
);


--
-- Name: TABLE aspecto_quirurgico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.aspecto_quirurgico IS 'Aspectos que el enfermero verifica en cada etapa de la cirugía.';


--
-- Name: COLUMN aspecto_quirurgico.etapa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.aspecto_quirurgico.etapa IS 'preoperatorio, intraoperatorio o postoperatorio.';


--
-- Name: COLUMN aspecto_quirurgico.seccion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.aspecto_quirurgico.seccion IS 'Sección de la etapa (Planificación, Entrada, Pausa quirúrgica...).';


--
-- Name: COLUMN aspecto_quirurgico.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.aspecto_quirurgico.nombre IS 'Aspecto que se verifica.';


--
-- Name: COLUMN aspecto_quirurgico.tipo_evaluacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.aspecto_quirurgico.tipo_evaluacion IS 'exito_falla o aceptabilidad.';


--
-- Name: aspecto_quirurgico_id_aspecto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.aspecto_quirurgico ALTER COLUMN id_aspecto ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.aspecto_quirurgico_id_aspecto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: calificacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calificacion (
    id_calificacion integer NOT NULL,
    id_paciente integer NOT NULL,
    fecha date NOT NULL,
    puntuacion smallint NOT NULL,
    comentario text,
    id_hospital integer,
    id_medico integer,
    id_enfermero integer,
    id_encargado integer,
    id_consulta integer,
    CONSTRAINT ck_calificacion_evaluado CHECK ((num_nonnulls(id_hospital, id_medico, id_enfermero, id_encargado) = 1)),
    CONSTRAINT ck_calificacion_puntuacion CHECK (((puntuacion >= 1) AND (puntuacion <= 5)))
);


--
-- Name: TABLE calificacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.calificacion IS 'Calificación de la calidad del servicio de un hospital, médico, enfermero o encargado.';


--
-- Name: COLUMN calificacion.fecha; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.calificacion.fecha IS 'Fecha de la calificación.';


--
-- Name: COLUMN calificacion.puntuacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.calificacion.puntuacion IS 'Puntuación de 1 (peor) a 5 (mejor).';


--
-- Name: COLUMN calificacion.comentario; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.calificacion.comentario IS 'Comentario opcional.';


--
-- Name: calificacion_id_calificacion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.calificacion ALTER COLUMN id_calificacion ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.calificacion_id_calificacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: camilla; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.camilla (
    id_camilla integer NOT NULL,
    id_unidad integer NOT NULL,
    numero smallint NOT NULL,
    disponible boolean DEFAULT true NOT NULL,
    CONSTRAINT ck_camilla_numero CHECK ((numero > 0))
);


--
-- Name: TABLE camilla; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.camilla IS 'Camillas de las unidades de Emergencias y Hospitalización.';


--
-- Name: COLUMN camilla.numero; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camilla.numero IS 'Número de la camilla dentro de su unidad.';


--
-- Name: COLUMN camilla.disponible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.camilla.disponible IS 'Indica si la camilla está libre.';


--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.camilla ALTER COLUMN id_camilla ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.camilla_id_camilla_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: chequeo_preanestesico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chequeo_preanestesico (
    id_chequeo integer NOT NULL,
    id_agendamiento integer NOT NULL,
    clasificacion_asa character varying(3) NOT NULL,
    id_medico_clasifica integer NOT NULL,
    plan_anestesia text NOT NULL,
    id_medico_anestesista integer NOT NULL,
    CONSTRAINT ck_chequeo_asa CHECK (((clasificacion_asa)::text = ANY ((ARRAY['I'::character varying, 'II'::character varying, 'III'::character varying, 'IV'::character varying, 'V'::character varying, 'VI'::character varying])::text[])))
);


--
-- Name: TABLE chequeo_preanestesico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.chequeo_preanestesico IS 'Evaluación del riesgo anestésico (ASA) y plan de anestesia.';


--
-- Name: COLUMN chequeo_preanestesico.clasificacion_asa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.chequeo_preanestesico.clasificacion_asa IS 'Clasificación ASA del riesgo anestésico (I a VI).';


--
-- Name: COLUMN chequeo_preanestesico.plan_anestesia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.chequeo_preanestesico.plan_anestesia IS 'Plan de anestesia.';


--
-- Name: chequeo_preanestesico_id_chequeo_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.chequeo_preanestesico ALTER COLUMN id_chequeo ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.chequeo_preanestesico_id_chequeo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cirugia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cirugia (
    id_cirugia integer NOT NULL,
    id_agendamiento integer NOT NULL,
    id_quirofano integer NOT NULL,
    id_ingreso integer,
    fecha_hora_inicio timestamp with time zone NOT NULL,
    fecha_hora_fin timestamp with time zone,
    estado character varying(15) DEFAULT 'preoperatorio'::character varying NOT NULL,
    condicion_evolucion character varying(21),
    CONSTRAINT ck_cirugia_estado CHECK (((estado)::text = ANY ((ARRAY['preoperatorio'::character varying, 'intraoperatorio'::character varying, 'postoperatorio'::character varying, 'finalizada'::character varying])::text[]))),
    CONSTRAINT ck_cirugia_evolucion CHECK (((condicion_evolucion)::text = ANY ((ARRAY['sin_complicaciones'::character varying, 'complicaciones'::character varying, 'complicaciones_graves'::character varying])::text[]))),
    CONSTRAINT ck_cirugia_fechas CHECK ((fecha_hora_fin >= fecha_hora_inicio)),
    CONSTRAINT ck_cirugia_finalizada CHECK ((((estado)::text <> 'finalizada'::text) OR ((fecha_hora_fin IS NOT NULL) AND (condicion_evolucion IS NOT NULL))))
);


--
-- Name: TABLE cirugia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cirugia IS 'Cirugía realizada a partir de un agendamiento aprobado.';


--
-- Name: COLUMN cirugia.fecha_hora_inicio; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cirugia.fecha_hora_inicio IS 'Inicio de la cirugía.';


--
-- Name: COLUMN cirugia.fecha_hora_fin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cirugia.fecha_hora_fin IS 'Fin de la cirugía.';


--
-- Name: COLUMN cirugia.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cirugia.estado IS 'preoperatorio, intraoperatorio, postoperatorio o finalizada.';


--
-- Name: COLUMN cirugia.condicion_evolucion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cirugia.condicion_evolucion IS 'sin_complicaciones, complicaciones o complicaciones_graves.';


--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.cirugia ALTER COLUMN id_cirugia ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.cirugia_id_cirugia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cirugia_insumo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cirugia_insumo (
    id_cirugia integer NOT NULL,
    id_insumo integer NOT NULL,
    cantidad smallint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL,
    CONSTRAINT ck_cirugia_insumo_cantidad CHECK ((cantidad > 0)),
    CONSTRAINT ck_cirugia_insumo_costo CHECK ((costo_unitario >= (0)::numeric))
);


--
-- Name: TABLE cirugia_insumo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cirugia_insumo IS 'Insumos usados en la cirugía.';


--
-- Name: COLUMN cirugia_insumo.cantidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cirugia_insumo.cantidad IS 'Cantidad usada.';


--
-- Name: COLUMN cirugia_insumo.costo_unitario; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cirugia_insumo.costo_unitario IS 'Costo por unidad al momento de usarlo.';


--
-- Name: cirugia_personal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cirugia_personal (
    id_cirugia_personal integer NOT NULL,
    id_cirugia integer NOT NULL,
    id_medico integer,
    id_enfermero integer,
    id_rol integer NOT NULL,
    CONSTRAINT ck_cirugia_personal CHECK ((num_nonnulls(id_medico, id_enfermero) = 1))
);


--
-- Name: TABLE cirugia_personal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cirugia_personal IS 'Médicos y enfermeros que participan en la cirugía.';


--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.cirugia_personal ALTER COLUMN id_cirugia_personal ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.cirugia_personal_id_cirugia_personal_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cita; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cita (
    id_cita integer NOT NULL,
    id_paciente integer NOT NULL,
    id_medico integer NOT NULL,
    fecha_hora timestamp with time zone NOT NULL,
    numero_clinica character varying(10) NOT NULL,
    medio_asignacion character varying(20) NOT NULL,
    estado character varying(12) DEFAULT 'programada'::character varying NOT NULL,
    es_reconsulta boolean DEFAULT false NOT NULL,
    es_referido boolean DEFAULT false NOT NULL,
    cancelada_sin_aviso boolean DEFAULT false NOT NULL,
    costo_base numeric(10,2) NOT NULL,
    costo_final numeric(10,2) NOT NULL,
    CONSTRAINT ck_cita_costos CHECK (((costo_base >= (0)::numeric) AND (costo_final >= (0)::numeric))),
    CONSTRAINT ck_cita_estado CHECK (((estado)::text = ANY ((ARRAY['programada'::character varying, 'realizada'::character varying, 'reprogramada'::character varying, 'cancelada'::character varying])::text[]))),
    CONSTRAINT ck_cita_medio CHECK (((medio_asignacion)::text = ANY ((ARRAY['telefonico'::character varying, 'correo_institucional'::character varying, 'recepcion_general'::character varying, 'recepcion_medico'::character varying])::text[]))),
    CONSTRAINT ck_cita_sin_aviso CHECK (((NOT cancelada_sin_aviso) OR ((estado)::text = 'cancelada'::text)))
);


--
-- Name: TABLE cita; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cita IS 'Citas programadas de consulta externa.';


--
-- Name: COLUMN cita.fecha_hora; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cita.fecha_hora IS 'Fecha y hora de la cita.';


--
-- Name: COLUMN cita.numero_clinica; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cita.numero_clinica IS 'Clínica o consultorio donde se atiende.';


--
-- Name: COLUMN cita.medio_asignacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cita.medio_asignacion IS 'Medio por el que se asignó: teléfono, correo, recepción general o del médico.';


--
-- Name: COLUMN cita.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cita.estado IS 'programada, realizada, reprogramada o cancelada.';


--
-- Name: COLUMN cita.es_reconsulta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cita.es_reconsulta IS 'Indica si es reconsulta (cuesta 75% de la primera consulta).';


--
-- Name: COLUMN cita.es_referido; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cita.es_referido IS 'Indica si el paciente fue referido por una institución (cuesta 80%).';


--
-- Name: COLUMN cita.cancelada_sin_aviso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cita.cancelada_sin_aviso IS 'Indica si se canceló sin avisar (sobrecargo de 10% en la siguiente cita).';


--
-- Name: COLUMN cita.costo_base; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cita.costo_base IS 'Costo de primera consulta del médico al momento de agendar.';


--
-- Name: COLUMN cita.costo_final; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cita.costo_final IS 'Costo cobrado después de aplicar las reglas de descuento o sobrecargo.';


--
-- Name: cita_id_cita_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.cita ALTER COLUMN id_cita ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.cita_id_cita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: consentimiento_informado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consentimiento_informado (
    id_consentimiento integer NOT NULL,
    id_agendamiento integer NOT NULL,
    id_medico integer NOT NULL,
    procedimiento_nombre character varying(150) NOT NULL,
    procedimiento_objetivo text NOT NULL,
    procedimiento_caracteristicas text NOT NULL,
    procedimiento_riesgos text NOT NULL,
    medico_firmo boolean DEFAULT false NOT NULL,
    firmante_nombre character varying(150) NOT NULL,
    firmante_relacion character varying(20) NOT NULL,
    firmante_firmo boolean DEFAULT false NOT NULL,
    fecha_obtencion date NOT NULL,
    CONSTRAINT ck_consentimiento_firmante CHECK (((firmante_relacion)::text = ANY ((ARRAY['paciente'::character varying, 'familiar'::character varying, 'tutor'::character varying, 'representante_legal'::character varying])::text[])))
);


--
-- Name: TABLE consentimiento_informado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.consentimiento_informado IS 'Consentimiento informado firmado para la cirugía.';


--
-- Name: COLUMN consentimiento_informado.procedimiento_nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consentimiento_informado.procedimiento_nombre IS 'Nombre específico del procedimiento.';


--
-- Name: COLUMN consentimiento_informado.procedimiento_objetivo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consentimiento_informado.procedimiento_objetivo IS 'Objetivo del procedimiento.';


--
-- Name: COLUMN consentimiento_informado.procedimiento_caracteristicas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consentimiento_informado.procedimiento_caracteristicas IS 'Características del procedimiento.';


--
-- Name: COLUMN consentimiento_informado.procedimiento_riesgos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consentimiento_informado.procedimiento_riesgos IS 'Posibles riesgos del procedimiento.';


--
-- Name: COLUMN consentimiento_informado.medico_firmo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consentimiento_informado.medico_firmo IS 'Indica si el médico firmó.';


--
-- Name: COLUMN consentimiento_informado.firmante_nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consentimiento_informado.firmante_nombre IS 'Nombre de quien firma por el paciente.';


--
-- Name: COLUMN consentimiento_informado.firmante_relacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consentimiento_informado.firmante_relacion IS 'paciente, familiar, tutor o representante_legal.';


--
-- Name: COLUMN consentimiento_informado.firmante_firmo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consentimiento_informado.firmante_firmo IS 'Indica si el paciente o su representante firmó.';


--
-- Name: COLUMN consentimiento_informado.fecha_obtencion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consentimiento_informado.fecha_obtencion IS 'Fecha en que se obtuvo el consentimiento.';


--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.consentimiento_informado ALTER COLUMN id_consentimiento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.consentimiento_informado_id_consentimiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: consulta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consulta (
    id_consulta integer NOT NULL,
    id_cita integer NOT NULL,
    id_diagnostico integer NOT NULL,
    otros_datos text,
    notas_observaciones text
);


--
-- Name: TABLE consulta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.consulta IS 'Consulta realizada en una cita.';


--
-- Name: COLUMN consulta.otros_datos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consulta.otros_datos IS 'Otros datos de interés clínico.';


--
-- Name: COLUMN consulta.notas_observaciones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.consulta.notas_observaciones IS 'Notas u observaciones del médico.';


--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.consulta ALTER COLUMN id_consulta ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.consulta_id_consulta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departamento (
    id_departamento integer NOT NULL,
    nombre character varying(80) NOT NULL
);


--
-- Name: TABLE departamento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.departamento IS 'Departamentos de Guatemala.';


--
-- Name: COLUMN departamento.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.departamento.nombre IS 'Nombre del departamento.';


--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.departamento ALTER COLUMN id_departamento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.departamento_id_departamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: diagnostico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diagnostico (
    id_diagnostico integer NOT NULL,
    codigo_cie10 character varying(7) NOT NULL,
    descripcion character varying(200) NOT NULL,
    CONSTRAINT ck_diagnostico_codigo CHECK (((codigo_cie10)::text ~ '^[A-Z][0-9]{2}(\.[0-9]{1,2})?$'::text))
);


--
-- Name: TABLE diagnostico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.diagnostico IS 'Diagnósticos de la Clasificación Internacional de Enfermedades (CIE-10).';


--
-- Name: COLUMN diagnostico.codigo_cie10; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.diagnostico.codigo_cie10 IS 'Código CIE-10 del diagnóstico.';


--
-- Name: COLUMN diagnostico.descripcion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.diagnostico.descripcion IS 'Descripción oficial del diagnóstico.';


--
-- Name: diagnostico_id_diagnostico_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.diagnostico ALTER COLUMN id_diagnostico ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.diagnostico_id_diagnostico_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: documentacion_etapa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documentacion_etapa (
    id_cirugia integer NOT NULL,
    etapa character varying(15) NOT NULL,
    id_enfermero integer NOT NULL,
    fecha_envio date NOT NULL,
    CONSTRAINT ck_documentacion_etapa CHECK (((etapa)::text = ANY ((ARRAY['preoperatorio'::character varying, 'intraoperatorio'::character varying, 'postoperatorio'::character varying])::text[])))
);


--
-- Name: TABLE documentacion_etapa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.documentacion_etapa IS 'Documentación de cada etapa de la cirugía enviada a secretaría.';


--
-- Name: COLUMN documentacion_etapa.etapa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.documentacion_etapa.etapa IS 'Etapa documentada.';


--
-- Name: COLUMN documentacion_etapa.fecha_envio; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.documentacion_etapa.fecha_envio IS 'Fecha de envío a secretaría.';


--
-- Name: egreso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.egreso (
    id_egreso integer NOT NULL,
    id_ingreso integer NOT NULL,
    id_medico integer NOT NULL,
    id_diagnostico_principal integer NOT NULL,
    fecha_hora_egreso timestamp with time zone NOT NULL,
    motivo_egreso text NOT NULL,
    codigo_egreso character varying(8) NOT NULL,
    sin_consentimiento boolean DEFAULT false NOT NULL,
    motivo_sin_consentimiento text,
    codigo_traslado character varying(20),
    referido_otro_hospital boolean DEFAULT false NOT NULL,
    CONSTRAINT ck_egreso_codigo CHECK (((codigo_egreso)::text = ANY ((ARRAY['vivo'::character varying, 'muerto'::character varying, 'embarazo'::character varying, 'parto'::character varying])::text[]))),
    CONSTRAINT ck_egreso_sin_consentimiento CHECK ((sin_consentimiento = (motivo_sin_consentimiento IS NOT NULL)))
);


--
-- Name: TABLE egreso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.egreso IS 'Ficha de egreso que cierra un ingreso.';


--
-- Name: COLUMN egreso.fecha_hora_egreso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.egreso.fecha_hora_egreso IS 'Fecha y hora del egreso.';


--
-- Name: COLUMN egreso.motivo_egreso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.egreso.motivo_egreso IS 'Motivo del egreso.';


--
-- Name: COLUMN egreso.codigo_egreso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.egreso.codigo_egreso IS 'Condición de salida: vivo, muerto, embarazo o parto.';


--
-- Name: COLUMN egreso.sin_consentimiento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.egreso.sin_consentimiento IS 'Indica si el paciente salió sin consentimiento médico.';


--
-- Name: COLUMN egreso.motivo_sin_consentimiento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.egreso.motivo_sin_consentimiento IS 'Motivo del egreso sin consentimiento.';


--
-- Name: COLUMN egreso.codigo_traslado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.egreso.codigo_traslado IS 'Código de traslado, si el egreso fue por traslado.';


--
-- Name: COLUMN egreso.referido_otro_hospital; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.egreso.referido_otro_hospital IS 'Indica si fue referido a otro hospital o establecimiento.';


--
-- Name: egreso_diagnostico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.egreso_diagnostico (
    id_egreso integer NOT NULL,
    id_diagnostico integer NOT NULL
);


--
-- Name: TABLE egreso_diagnostico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.egreso_diagnostico IS 'Diagnósticos secundarios de cada egreso.';


--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.egreso ALTER COLUMN id_egreso ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.egreso_id_egreso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: encargado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.encargado (
    id_encargado integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character(13) NOT NULL,
    telefono character varying(9),
    id_municipio integer NOT NULL,
    area character varying(6) NOT NULL,
    CONSTRAINT ck_encargado_area CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[]))),
    CONSTRAINT ck_encargado_dpi CHECK ((dpi ~ '^[0-9]{13}$'::text)),
    CONSTRAINT ck_encargado_telefono CHECK (((telefono)::text ~ '^[0-9]{4}-?[0-9]{4}$'::text))
);


--
-- Name: TABLE encargado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.encargado IS 'Personas responsables de un paciente.';


--
-- Name: COLUMN encargado.nombres; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.encargado.nombres IS 'Nombres del encargado.';


--
-- Name: COLUMN encargado.apellidos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.encargado.apellidos IS 'Apellidos del encargado.';


--
-- Name: COLUMN encargado.dpi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.encargado.dpi IS 'CUI de 13 dígitos.';


--
-- Name: COLUMN encargado.telefono; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.encargado.telefono IS 'Teléfono de contacto.';


--
-- Name: COLUMN encargado.area; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.encargado.area IS 'Área de residencia: Urbana o Rural.';


--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.encargado ALTER COLUMN id_encargado ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.encargado_id_encargado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: enfermero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enfermero (
    id_enfermero integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character(13) NOT NULL,
    telefono character varying(9),
    id_hospital integer NOT NULL,
    tipo character varying(12) NOT NULL,
    CONSTRAINT ck_enfermero_dpi CHECK ((dpi ~ '^[0-9]{13}$'::text)),
    CONSTRAINT ck_enfermero_telefono CHECK (((telefono)::text ~ '^[0-9]{4}-?[0-9]{4}$'::text)),
    CONSTRAINT ck_enfermero_tipo CHECK (((tipo)::text = ANY ((ARRAY['registrado'::character varying, 'practicante'::character varying])::text[])))
);


--
-- Name: TABLE enfermero; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.enfermero IS 'Enfermeros registrados y practicantes de enfermería.';


--
-- Name: COLUMN enfermero.nombres; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.enfermero.nombres IS 'Nombres del enfermero.';


--
-- Name: COLUMN enfermero.apellidos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.enfermero.apellidos IS 'Apellidos del enfermero.';


--
-- Name: COLUMN enfermero.dpi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.enfermero.dpi IS 'Documento Personal de Identificación (CUI de 13 dígitos).';


--
-- Name: COLUMN enfermero.telefono; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.enfermero.telefono IS 'Teléfono de contacto.';


--
-- Name: COLUMN enfermero.tipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.enfermero.tipo IS 'registrado o practicante.';


--
-- Name: enfermero_id_enfermero_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.enfermero ALTER COLUMN id_enfermero ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.enfermero_id_enfermero_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: equipo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipo (
    id_equipo integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    tipo character varying(10) NOT NULL,
    funcion character varying(14) NOT NULL,
    estado character varying(16) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT ck_equipo_estado CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'en_uso'::character varying, 'en_mantenimiento'::character varying])::text[]))),
    CONSTRAINT ck_equipo_funcion CHECK (((funcion)::text = ANY ((ARRAY['exploracion'::character varying, 'diagnostico'::character varying, 'tratamiento'::character varying, 'rehabilitacion'::character varying, 'otro'::character varying])::text[]))),
    CONSTRAINT ck_equipo_tipo CHECK (((tipo)::text = ANY ((ARRAY['medico'::character varying, 'quirurgico'::character varying, 'otro'::character varying])::text[])))
);


--
-- Name: TABLE equipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.equipo IS 'Equipos médicos y quirúrgicos.';


--
-- Name: COLUMN equipo.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.equipo.nombre IS 'Nombre del equipo.';


--
-- Name: COLUMN equipo.descripcion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.equipo.descripcion IS 'Descripción del equipo.';


--
-- Name: COLUMN equipo.tipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.equipo.tipo IS 'medico, quirurgico u otro.';


--
-- Name: COLUMN equipo.funcion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.equipo.funcion IS 'exploracion, diagnostico, tratamiento, rehabilitacion u otro.';


--
-- Name: COLUMN equipo.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.equipo.estado IS 'disponible, en_uso o en_mantenimiento.';


--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.equipo ALTER COLUMN id_equipo ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.equipo_id_equipo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: especialidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.especialidad (
    id_especialidad integer NOT NULL,
    nombre character varying(80) NOT NULL,
    tipo character varying(10) NOT NULL,
    CONSTRAINT ck_especialidad_tipo CHECK (((tipo)::text = ANY ((ARRAY['clinica'::character varying, 'quirurgica'::character varying])::text[])))
);


--
-- Name: TABLE especialidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.especialidad IS 'Especialidades médicas clínicas y quirúrgicas.';


--
-- Name: COLUMN especialidad.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.especialidad.nombre IS 'Nombre de la especialidad.';


--
-- Name: COLUMN especialidad.tipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.especialidad.tipo IS 'clinica (consulta) o quirurgica (cirugía).';


--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.especialidad ALTER COLUMN id_especialidad ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.especialidad_id_especialidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.estado_civil (
    id_estado_civil integer NOT NULL,
    nombre character varying(20) NOT NULL
);


--
-- Name: TABLE estado_civil; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.estado_civil IS 'Catálogo de estados civiles.';


--
-- Name: COLUMN estado_civil.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.estado_civil.nombre IS 'Estado civil.';


--
-- Name: estado_civil_id_estado_civil_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.estado_civil ALTER COLUMN id_estado_civil ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.estado_civil_id_estado_civil_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: factura; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.factura (
    id_factura integer NOT NULL,
    id_cita integer,
    id_ingreso integer,
    id_cirugia integer,
    fecha_emision timestamp with time zone NOT NULL,
    descripcion text NOT NULL,
    total numeric(10,2) NOT NULL,
    numero_cuotas smallint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_factura_cita_contado CHECK (((id_cita IS NULL) OR (numero_cuotas = 1))),
    CONSTRAINT ck_factura_cuotas CHECK (((numero_cuotas >= 1) AND (numero_cuotas <= 12))),
    CONSTRAINT ck_factura_origen CHECK ((num_nonnulls(id_cita, id_ingreso, id_cirugia) = 1)),
    CONSTRAINT ck_factura_total CHECK ((total >= (0)::numeric))
);


--
-- Name: TABLE factura; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.factura IS 'Factura emitida al terminar una consulta, emergencia, hospitalización o cirugía.';


--
-- Name: COLUMN factura.fecha_emision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.factura.fecha_emision IS 'Fecha y hora de emisión.';


--
-- Name: COLUMN factura.descripcion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.factura.descripcion IS 'Descripción breve de los servicios facturados.';


--
-- Name: COLUMN factura.total; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.factura.total IS 'Monto total en quetzales.';


--
-- Name: COLUMN factura.numero_cuotas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.factura.numero_cuotas IS 'Número de cuotas mensuales del plan de pago (1 a 12).';


--
-- Name: factura_id_factura_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.factura ALTER COLUMN id_factura ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.factura_id_factura_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: historia_clinica; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.historia_clinica (
    id_historia_clinica integer NOT NULL,
    id_agendamiento integer NOT NULL,
    id_medico integer NOT NULL,
    fecha date NOT NULL,
    fuente_interrogatorio character varying(9) NOT NULL,
    religion character varying(40),
    ocupacion character varying(60),
    lugar_nacimiento character varying(80),
    lugar_residencia character varying(80),
    antecedentes_heredofamiliares text NOT NULL,
    antecedentes_personales_no_patologicos text CONSTRAINT historia_clinica_antecedentes_personales_no_patologico_not_null NOT NULL,
    antecedentes_patologicos text NOT NULL,
    padecimiento_actual text NOT NULL,
    interrogatorio_aparatos_sistemas text,
    sintomas_generales_terapeutica text,
    estudios_previos text,
    signos_vitales text,
    exploracion_general text,
    exploracion_sistematizada text,
    CONSTRAINT ck_historia_fuente CHECK (((fuente_interrogatorio)::text = ANY ((ARRAY['directo'::character varying, 'indirecto'::character varying])::text[])))
);


--
-- Name: TABLE historia_clinica; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.historia_clinica IS 'Interrogatorio y exploración física del paciente antes de la cirugía.';


--
-- Name: COLUMN historia_clinica.fecha; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.fecha IS 'Fecha de elaboración.';


--
-- Name: COLUMN historia_clinica.fuente_interrogatorio; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.fuente_interrogatorio IS 'directo (del paciente) o indirecto (de un familiar o amigo).';


--
-- Name: COLUMN historia_clinica.religion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.religion IS 'Religión del paciente.';


--
-- Name: COLUMN historia_clinica.ocupacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.ocupacion IS 'Ocupación del paciente.';


--
-- Name: COLUMN historia_clinica.lugar_nacimiento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.lugar_nacimiento IS 'Lugar de nacimiento.';


--
-- Name: COLUMN historia_clinica.lugar_residencia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.lugar_residencia IS 'Lugar de residencia.';


--
-- Name: COLUMN historia_clinica.antecedentes_heredofamiliares; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.antecedentes_heredofamiliares IS 'Antecedentes heredofamiliares.';


--
-- Name: COLUMN historia_clinica.antecedentes_personales_no_patologicos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.antecedentes_personales_no_patologicos IS 'Antecedentes personales no patológicos.';


--
-- Name: COLUMN historia_clinica.antecedentes_patologicos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.antecedentes_patologicos IS 'Antecedentes patológicos.';


--
-- Name: COLUMN historia_clinica.padecimiento_actual; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.padecimiento_actual IS 'Padecimiento actual.';


--
-- Name: COLUMN historia_clinica.interrogatorio_aparatos_sistemas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.interrogatorio_aparatos_sistemas IS 'Interrogatorio por aparatos y sistemas.';


--
-- Name: COLUMN historia_clinica.sintomas_generales_terapeutica; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.sintomas_generales_terapeutica IS 'Síntomas generales y terapéutica empleada.';


--
-- Name: COLUMN historia_clinica.estudios_previos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.estudios_previos IS 'Estudios previos.';


--
-- Name: COLUMN historia_clinica.signos_vitales; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.signos_vitales IS 'Signos vitales.';


--
-- Name: COLUMN historia_clinica.exploracion_general; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.exploracion_general IS 'Exploración general.';


--
-- Name: COLUMN historia_clinica.exploracion_sistematizada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.historia_clinica.exploracion_sistematizada IS 'Exploración de cabeza, cuello, tórax, abdomen, extremidades, columna y cavidades.';


--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.historia_clinica ALTER COLUMN id_historia_clinica ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.historia_clinica_id_historia_clinica_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hospital; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hospital (
    id_hospital integer NOT NULL,
    nombre character varying(120) NOT NULL,
    informacion_especifica text,
    direccion character varying(250) NOT NULL,
    id_municipio integer NOT NULL
);


--
-- Name: TABLE hospital; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.hospital IS 'Hospitales de la cadena Hospitales de Occidente.';


--
-- Name: COLUMN hospital.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.hospital.nombre IS 'Nombre del hospital.';


--
-- Name: COLUMN hospital.informacion_especifica; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.hospital.informacion_especifica IS 'Información específica del hospital (nivel, capacidad, especialización).';


--
-- Name: COLUMN hospital.direccion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.hospital.direccion IS 'Dirección del hospital.';


--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.hospital ALTER COLUMN id_hospital ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.hospital_id_hospital_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hospitalizacion_insumo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hospitalizacion_insumo (
    id_ingreso integer NOT NULL,
    id_insumo integer NOT NULL,
    cantidad smallint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL,
    CONSTRAINT ck_hosp_insumo_cantidad CHECK ((cantidad > 0)),
    CONSTRAINT ck_hosp_insumo_costo CHECK ((costo_unitario >= (0)::numeric))
);


--
-- Name: TABLE hospitalizacion_insumo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.hospitalizacion_insumo IS 'Insumos usados durante un internamiento.';


--
-- Name: COLUMN hospitalizacion_insumo.cantidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.hospitalizacion_insumo.cantidad IS 'Cantidad usada durante el internamiento.';


--
-- Name: COLUMN hospitalizacion_insumo.costo_unitario; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.hospitalizacion_insumo.costo_unitario IS 'Costo por unidad al momento de usarlo.';


--
-- Name: ingreso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ingreso (
    id_ingreso integer NOT NULL,
    id_paciente integer NOT NULL,
    id_unidad integer NOT NULL,
    id_servicio integer,
    id_medico_encargado integer NOT NULL,
    id_camilla integer,
    id_quirofano integer,
    id_turno integer,
    fecha_hora_ingreso timestamp with time zone NOT NULL,
    motivo_ingreso text NOT NULL,
    diagnostico_presuntivo text,
    prioridad_triage smallint,
    turnos_espera smallint,
    CONSTRAINT ck_ingreso_espera CHECK ((turnos_espera >= 0)),
    CONSTRAINT ck_ingreso_prioridad CHECK (((prioridad_triage >= 1) AND (prioridad_triage <= 5))),
    CONSTRAINT ck_ingreso_triage CHECK ((num_nulls(id_turno, prioridad_triage, turnos_espera) = ANY (ARRAY[0, 3]))),
    CONSTRAINT ck_ingreso_ubicacion CHECK (((id_camilla IS NULL) OR (id_quirofano IS NULL)))
);


--
-- Name: TABLE ingreso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ingreso IS 'Ficha de ingreso a Emergencias, Cirugía u Hospitalización.';


--
-- Name: COLUMN ingreso.fecha_hora_ingreso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingreso.fecha_hora_ingreso IS 'Fecha y hora del ingreso.';


--
-- Name: COLUMN ingreso.motivo_ingreso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingreso.motivo_ingreso IS 'Motivo por el que ingresa el paciente.';


--
-- Name: COLUMN ingreso.diagnostico_presuntivo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingreso.diagnostico_presuntivo IS 'Diagnóstico presuntivo de ingreso.';


--
-- Name: COLUMN ingreso.prioridad_triage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingreso.prioridad_triage IS 'Prioridad de atención en emergencias: 1 la más urgente, 5 la menos.';


--
-- Name: COLUMN ingreso.turnos_espera; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingreso.turnos_espera IS 'Turnos que esperó por falta de camilla libre (solo emergencias).';


--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ingreso ALTER COLUMN id_ingreso ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ingreso_id_ingreso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: institucion_externa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.institucion_externa (
    id_institucion integer NOT NULL,
    nombre character varying(120) NOT NULL,
    direccion character varying(250) NOT NULL,
    id_municipio integer NOT NULL
);


--
-- Name: TABLE institucion_externa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.institucion_externa IS 'Hospitales y establecimientos fuera de la cadena que reciben traslados.';


--
-- Name: COLUMN institucion_externa.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.institucion_externa.nombre IS 'Nombre de la institución.';


--
-- Name: COLUMN institucion_externa.direccion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.institucion_externa.direccion IS 'Dirección de la institución.';


--
-- Name: institucion_externa_id_institucion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.institucion_externa ALTER COLUMN id_institucion ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.institucion_externa_id_institucion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: instrumento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instrumento (
    id_instrumento integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    tipo character varying(10) NOT NULL,
    funcion character varying(12) NOT NULL,
    estado character varying(16) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT ck_instrumento_estado CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'en_uso'::character varying, 'en_mantenimiento'::character varying])::text[]))),
    CONSTRAINT ck_instrumento_funcion CHECK (((funcion)::text = ANY ((ARRAY['corte'::character varying, 'contencion'::character varying, 'hemostatica'::character varying, 'retractor'::character varying, 'accesorio'::character varying, 'implante'::character varying, 'otro'::character varying])::text[]))),
    CONSTRAINT ck_instrumento_tipo CHECK (((tipo)::text = ANY ((ARRAY['medico'::character varying, 'quirurgico'::character varying, 'otro'::character varying])::text[])))
);


--
-- Name: TABLE instrumento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.instrumento IS 'Instrumental médico y quirúrgico.';


--
-- Name: COLUMN instrumento.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.instrumento.nombre IS 'Nombre del instrumento.';


--
-- Name: COLUMN instrumento.descripcion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.instrumento.descripcion IS 'Descripción del instrumento.';


--
-- Name: COLUMN instrumento.tipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.instrumento.tipo IS 'medico, quirurgico u otro.';


--
-- Name: COLUMN instrumento.funcion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.instrumento.funcion IS 'corte, contencion, hemostatica, retractor, accesorio, implante u otro.';


--
-- Name: COLUMN instrumento.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.instrumento.estado IS 'disponible, en_uso o en_mantenimiento.';


--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.instrumento ALTER COLUMN id_instrumento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.instrumento_id_instrumento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insumo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.insumo (
    id_insumo integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    material character varying(80),
    tipo character varying(10) NOT NULL,
    unidad_medida character varying(20) NOT NULL,
    costo_unitario numeric(10,2) NOT NULL,
    stock_minimo integer DEFAULT 0 NOT NULL,
    stock_actual integer DEFAULT 0 NOT NULL,
    CONSTRAINT ck_insumo_costo CHECK ((costo_unitario >= (0)::numeric)),
    CONSTRAINT ck_insumo_stock CHECK (((stock_minimo >= 0) AND (stock_actual >= 0))),
    CONSTRAINT ck_insumo_tipo CHECK (((tipo)::text = ANY ((ARRAY['medico'::character varying, 'quirurgico'::character varying, 'otro'::character varying])::text[])))
);


--
-- Name: TABLE insumo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.insumo IS 'Insumos médicos y quirúrgicos con su inventario.';


--
-- Name: COLUMN insumo.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.insumo.nombre IS 'Nombre del insumo.';


--
-- Name: COLUMN insumo.descripcion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.insumo.descripcion IS 'Descripción del insumo.';


--
-- Name: COLUMN insumo.material; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.insumo.material IS 'Material del que está hecho.';


--
-- Name: COLUMN insumo.tipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.insumo.tipo IS 'medico, quirurgico u otro.';


--
-- Name: COLUMN insumo.unidad_medida; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.insumo.unidad_medida IS 'Unidad en que se despacha (caja, unidad, bolsa...).';


--
-- Name: COLUMN insumo.costo_unitario; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.insumo.costo_unitario IS 'Costo actual por unidad.';


--
-- Name: COLUMN insumo.stock_minimo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.insumo.stock_minimo IS 'Existencia mínima antes de reabastecer.';


--
-- Name: COLUMN insumo.stock_actual; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.insumo.stock_actual IS 'Existencia actual en inventario.';


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.insumo ALTER COLUMN id_insumo ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.insumo_id_insumo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: medicamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medicamento (
    id_medicamento integer NOT NULL,
    nombre_generico character varying(80) NOT NULL,
    concentracion character varying(30) NOT NULL,
    forma_farmaceutica character varying(12) NOT NULL,
    CONSTRAINT ck_medicamento_forma CHECK (((forma_farmaceutica)::text = ANY ((ARRAY['tableta'::character varying, 'capsula'::character varying, 'jarabe'::character varying, 'suspension'::character varying, 'inyectable'::character varying, 'crema'::character varying, 'gotas'::character varying, 'inhalador'::character varying])::text[])))
);


--
-- Name: TABLE medicamento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.medicamento IS 'Medicamentos que se pueden recetar.';


--
-- Name: COLUMN medicamento.nombre_generico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medicamento.nombre_generico IS 'Nombre genérico (principio activo).';


--
-- Name: COLUMN medicamento.concentracion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medicamento.concentracion IS 'Concentración por unidad (ej. 50 mg).';


--
-- Name: COLUMN medicamento.forma_farmaceutica; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medicamento.forma_farmaceutica IS 'Presentación: tableta, cápsula, jarabe, inyectable...';


--
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.medicamento ALTER COLUMN id_medicamento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.medicamento_id_medicamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: medico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medico (
    id_medico integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character(13) NOT NULL,
    telefono character varying(9),
    id_hospital integer NOT NULL,
    id_municipio integer NOT NULL,
    area character varying(6) NOT NULL,
    id_especialidad integer NOT NULL,
    tipo_medico character varying(12) NOT NULL,
    costo_primera_consulta numeric(10,2),
    horario_inicio time without time zone,
    horario_fin time without time zone,
    CONSTRAINT ck_medico_area CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[]))),
    CONSTRAINT ck_medico_costo CHECK ((costo_primera_consulta >= (0)::numeric)),
    CONSTRAINT ck_medico_dpi CHECK ((dpi ~ '^[0-9]{13}$'::text)),
    CONSTRAINT ck_medico_externo CHECK ((((tipo_medico)::text <> 'externo'::text) OR ((horario_inicio IS NULL) AND (costo_primera_consulta IS NULL)))),
    CONSTRAINT ck_medico_horario CHECK (((horario_inicio < horario_fin) AND (horario_fin <= '13:00:00'::time without time zone))),
    CONSTRAINT ck_medico_horario_completo CHECK (((horario_inicio IS NULL) = (horario_fin IS NULL))),
    CONSTRAINT ck_medico_telefono CHECK (((telefono)::text ~ '^[0-9]{4}-?[0-9]{4}$'::text)),
    CONSTRAINT ck_medico_tipo CHECK (((tipo_medico)::text = ANY ((ARRAY['general'::character varying, 'especialista'::character varying, 'residente'::character varying, 'interno'::character varying, 'externo'::character varying])::text[])))
);


--
-- Name: TABLE medico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.medico IS 'Médicos de la cadena; los externos solo llegan a operar.';


--
-- Name: COLUMN medico.nombres; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medico.nombres IS 'Nombres del médico.';


--
-- Name: COLUMN medico.apellidos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medico.apellidos IS 'Apellidos del médico.';


--
-- Name: COLUMN medico.dpi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medico.dpi IS 'Documento Personal de Identificación (CUI de 13 dígitos).';


--
-- Name: COLUMN medico.telefono; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medico.telefono IS 'Teléfono de contacto.';


--
-- Name: COLUMN medico.area; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medico.area IS 'Área de residencia: Urbana o Rural.';


--
-- Name: COLUMN medico.tipo_medico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medico.tipo_medico IS 'Modalidad: general, especialista, residente, interno o externo.';


--
-- Name: COLUMN medico.costo_primera_consulta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medico.costo_primera_consulta IS 'Costo de la primera consulta; base para reconsultas y referidos.';


--
-- Name: COLUMN medico.horario_inicio; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medico.horario_inicio IS 'Inicio del horario de consulta externa (turno matutino).';


--
-- Name: COLUMN medico.horario_fin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.medico.horario_fin IS 'Fin del horario de consulta externa.';


--
-- Name: medico_id_medico_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.medico ALTER COLUMN id_medico ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.medico_id_medico_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: metodo_pago; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metodo_pago (
    id_metodo_pago integer NOT NULL,
    nombre character varying(30) NOT NULL
);


--
-- Name: TABLE metodo_pago; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.metodo_pago IS 'Métodos de pago aceptados.';


--
-- Name: COLUMN metodo_pago.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.metodo_pago.nombre IS 'Método de pago.';


--
-- Name: metodo_pago_id_metodo_pago_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.metodo_pago ALTER COLUMN id_metodo_pago ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.metodo_pago_id_metodo_pago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.municipio (
    id_municipio integer NOT NULL,
    id_departamento integer NOT NULL,
    nombre character varying(80) NOT NULL
);


--
-- Name: TABLE municipio; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.municipio IS 'Municipios de cada departamento.';


--
-- Name: COLUMN municipio.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.municipio.nombre IS 'Nombre del municipio.';


--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.municipio ALTER COLUMN id_municipio ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.municipio_id_municipio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: paciente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paciente (
    id_paciente integer NOT NULL,
    numero_expediente character varying(20) NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    fecha_nacimiento date NOT NULL,
    sexo character varying(9) NOT NULL,
    dpi character(13),
    telefono character varying(9),
    id_municipio integer NOT NULL,
    area character varying(6) NOT NULL,
    id_estado_civil integer,
    numero_seguro_social character varying(30),
    CONSTRAINT ck_paciente_area CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[]))),
    CONSTRAINT ck_paciente_dpi CHECK ((dpi ~ '^[0-9]{13}$'::text)),
    CONSTRAINT ck_paciente_fecha_nacimiento CHECK ((fecha_nacimiento >= '1900-01-01'::date)),
    CONSTRAINT ck_paciente_sexo CHECK (((sexo)::text = ANY ((ARRAY['Masculino'::character varying, 'Femenino'::character varying])::text[]))),
    CONSTRAINT ck_paciente_telefono CHECK (((telefono)::text ~ '^[0-9]{4}-?[0-9]{4}$'::text))
);


--
-- Name: TABLE paciente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.paciente IS 'Pacientes atendidos en la red.';


--
-- Name: COLUMN paciente.numero_expediente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.paciente.numero_expediente IS 'Número de expediente clínico del paciente.';


--
-- Name: COLUMN paciente.nombres; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.paciente.nombres IS 'Nombres del paciente.';


--
-- Name: COLUMN paciente.apellidos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.paciente.apellidos IS 'Apellidos del paciente.';


--
-- Name: COLUMN paciente.fecha_nacimiento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.paciente.fecha_nacimiento IS 'Fecha de nacimiento; la edad se calcula con fn_edad.';


--
-- Name: COLUMN paciente.sexo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.paciente.sexo IS 'Masculino o Femenino.';


--
-- Name: COLUMN paciente.dpi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.paciente.dpi IS 'CUI de 13 dígitos; opcional para menores de edad.';


--
-- Name: COLUMN paciente.telefono; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.paciente.telefono IS 'Teléfono de contacto.';


--
-- Name: COLUMN paciente.area; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.paciente.area IS 'Área de residencia: Urbana o Rural.';


--
-- Name: COLUMN paciente.numero_seguro_social; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.paciente.numero_seguro_social IS 'Número de afiliación al seguro social, si tiene.';


--
-- Name: paciente_encargado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paciente_encargado (
    id_paciente integer NOT NULL,
    id_encargado integer NOT NULL,
    id_parentesco integer NOT NULL
);


--
-- Name: TABLE paciente_encargado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.paciente_encargado IS 'Encargados de cada paciente y su parentesco.';


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.paciente ALTER COLUMN id_paciente ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.paciente_id_paciente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pago; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pago (
    id_pago integer NOT NULL,
    id_factura integer NOT NULL,
    numero_cuota smallint NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha_pago date NOT NULL,
    id_metodo_pago integer NOT NULL,
    CONSTRAINT ck_pago_cuota CHECK (((numero_cuota >= 1) AND (numero_cuota <= 12))),
    CONSTRAINT ck_pago_monto CHECK ((monto > (0)::numeric))
);


--
-- Name: TABLE pago; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.pago IS 'Pago de una cuota de la factura.';


--
-- Name: COLUMN pago.numero_cuota; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pago.numero_cuota IS 'Número de cuota que se paga.';


--
-- Name: COLUMN pago.monto; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pago.monto IS 'Monto pagado.';


--
-- Name: COLUMN pago.fecha_pago; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pago.fecha_pago IS 'Fecha del pago.';


--
-- Name: pago_id_pago_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.pago ALTER COLUMN id_pago ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.pago_id_pago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: parentesco; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parentesco (
    id_parentesco integer NOT NULL,
    nombre character varying(20) NOT NULL
);


--
-- Name: TABLE parentesco; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.parentesco IS 'Catálogo de parentescos entre paciente y encargado.';


--
-- Name: COLUMN parentesco.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.parentesco.nombre IS 'Parentesco o relación con el paciente.';


--
-- Name: parentesco_id_parentesco_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.parentesco ALTER COLUMN id_parentesco ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.parentesco_id_parentesco_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: quirofano; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quirofano (
    id_quirofano integer NOT NULL,
    id_unidad integer NOT NULL,
    numero smallint NOT NULL,
    estado character varying(16) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT ck_quirofano_estado CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'ocupado'::character varying, 'en_mantenimiento'::character varying])::text[]))),
    CONSTRAINT ck_quirofano_numero CHECK ((numero > 0))
);


--
-- Name: TABLE quirofano; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.quirofano IS 'Quirófanos de la unidad de Cirugía.';


--
-- Name: COLUMN quirofano.numero; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quirofano.numero IS 'Número del quirófano dentro de la unidad de cirugía.';


--
-- Name: COLUMN quirofano.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quirofano.estado IS 'Estado: disponible, ocupado o en_mantenimiento.';


--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.quirofano ALTER COLUMN id_quirofano ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.quirofano_id_quirofano_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: receta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.receta (
    id_receta integer NOT NULL,
    id_consulta integer NOT NULL,
    fecha_proxima_cita date
);


--
-- Name: TABLE receta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.receta IS 'Receta entregada al final de la consulta.';


--
-- Name: COLUMN receta.fecha_proxima_cita; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.receta.fecha_proxima_cita IS 'Fecha sugerida para la próxima cita de seguimiento.';


--
-- Name: receta_id_receta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.receta ALTER COLUMN id_receta ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.receta_id_receta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: receta_medicamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.receta_medicamento (
    id_receta integer NOT NULL,
    id_medicamento integer NOT NULL,
    dosis character varying(80) NOT NULL,
    duracion character varying(40) NOT NULL
);


--
-- Name: TABLE receta_medicamento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.receta_medicamento IS 'Medicamentos prescritos en cada receta.';


--
-- Name: COLUMN receta_medicamento.dosis; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.receta_medicamento.dosis IS 'Dosis indicada.';


--
-- Name: COLUMN receta_medicamento.duracion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.receta_medicamento.duracion IS 'Duración del tratamiento.';


--
-- Name: registro_procedimiento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registro_procedimiento (
    id_registro integer NOT NULL,
    id_cirugia integer NOT NULL,
    id_aspecto integer NOT NULL,
    resultado character varying(22) NOT NULL,
    descripcion text,
    fecha_hora_registro timestamp with time zone NOT NULL,
    id_enfermero integer NOT NULL,
    CONSTRAINT ck_registro_resultado CHECK (((resultado)::text = ANY ((ARRAY['exito'::character varying, 'falla'::character varying, 'aceptable'::character varying, 'medianamente_aceptable'::character varying, 'no_aceptable'::character varying])::text[])))
);


--
-- Name: TABLE registro_procedimiento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.registro_procedimiento IS 'Resultado de cada aspecto verificado durante la cirugía.';


--
-- Name: COLUMN registro_procedimiento.resultado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registro_procedimiento.resultado IS 'exito/falla, o aceptable/medianamente_aceptable/no_aceptable.';


--
-- Name: COLUMN registro_procedimiento.descripcion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registro_procedimiento.descripcion IS 'Descripción de lo observado.';


--
-- Name: COLUMN registro_procedimiento.fecha_hora_registro; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registro_procedimiento.fecha_hora_registro IS 'Hora en que se registró.';


--
-- Name: registro_procedimiento_id_registro_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.registro_procedimiento ALTER COLUMN id_registro ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.registro_procedimiento_id_registro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: requerimiento_equipo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requerimiento_equipo (
    id_agendamiento integer NOT NULL,
    id_equipo integer NOT NULL,
    cantidad smallint NOT NULL,
    CONSTRAINT ck_req_equipo_cantidad CHECK ((cantidad > 0))
);


--
-- Name: TABLE requerimiento_equipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.requerimiento_equipo IS 'Equipos que solicita el cirujano en el agendamiento.';


--
-- Name: COLUMN requerimiento_equipo.cantidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.requerimiento_equipo.cantidad IS 'Cantidad solicitada.';


--
-- Name: requerimiento_instrumento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requerimiento_instrumento (
    id_agendamiento integer NOT NULL,
    id_instrumento integer NOT NULL,
    cantidad smallint NOT NULL,
    CONSTRAINT ck_req_instrumento_cantidad CHECK ((cantidad > 0))
);


--
-- Name: TABLE requerimiento_instrumento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.requerimiento_instrumento IS 'Instrumental que solicita el cirujano en el agendamiento.';


--
-- Name: COLUMN requerimiento_instrumento.cantidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.requerimiento_instrumento.cantidad IS 'Cantidad solicitada.';


--
-- Name: requerimiento_insumo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requerimiento_insumo (
    id_agendamiento integer NOT NULL,
    id_insumo integer NOT NULL,
    cantidad smallint NOT NULL,
    CONSTRAINT ck_req_insumo_cantidad CHECK ((cantidad > 0))
);


--
-- Name: TABLE requerimiento_insumo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.requerimiento_insumo IS 'Insumos que solicita el cirujano en el agendamiento.';


--
-- Name: COLUMN requerimiento_insumo.cantidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.requerimiento_insumo.cantidad IS 'Cantidad solicitada.';


--
-- Name: rol_quirurgico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rol_quirurgico (
    id_rol integer NOT NULL,
    nombre character varying(40) NOT NULL,
    tipo_personal character varying(9) NOT NULL,
    CONSTRAINT ck_rol_tipo_personal CHECK (((tipo_personal)::text = ANY ((ARRAY['medico'::character varying, 'enfermero'::character varying])::text[])))
);


--
-- Name: TABLE rol_quirurgico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.rol_quirurgico IS 'Rol que cumple cada persona del equipo quirúrgico.';


--
-- Name: COLUMN rol_quirurgico.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rol_quirurgico.nombre IS 'Nombre del rol.';


--
-- Name: COLUMN rol_quirurgico.tipo_personal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rol_quirurgico.tipo_personal IS 'Quién cumple el rol: medico o enfermero.';


--
-- Name: rol_quirurgico_id_rol_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.rol_quirurgico ALTER COLUMN id_rol ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.rol_quirurgico_id_rol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: servicio_atencion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.servicio_atencion (
    id_servicio integer NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(80) NOT NULL,
    costo numeric(10,2) NOT NULL,
    CONSTRAINT ck_servicio_costo CHECK ((costo >= (0)::numeric))
);


--
-- Name: TABLE servicio_atencion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.servicio_atencion IS 'Tipo de atención médica que ofrece cada unidad, con su costo.';


--
-- Name: COLUMN servicio_atencion.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.servicio_atencion.nombre IS 'Nombre del servicio de atención.';


--
-- Name: COLUMN servicio_atencion.costo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.servicio_atencion.costo IS 'Costo del servicio en quetzales.';


--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.servicio_atencion ALTER COLUMN id_servicio ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.servicio_atencion_id_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tipo_anestesia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tipo_anestesia (
    id_tipo_anestesia integer NOT NULL,
    nombre character varying(40) NOT NULL
);


--
-- Name: TABLE tipo_anestesia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tipo_anestesia IS 'Catálogo de tipos de anestesia.';


--
-- Name: COLUMN tipo_anestesia.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tipo_anestesia.nombre IS 'Tipo de anestesia.';


--
-- Name: tipo_anestesia_id_tipo_anestesia_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tipo_anestesia ALTER COLUMN id_tipo_anestesia ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tipo_anestesia_id_tipo_anestesia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tipo_cirugia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tipo_cirugia (
    id_tipo_cirugia integer NOT NULL,
    nombre character varying(120) NOT NULL,
    id_especialidad integer NOT NULL
);


--
-- Name: TABLE tipo_cirugia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tipo_cirugia IS 'Procedimientos quirúrgicos que ofrece la red.';


--
-- Name: COLUMN tipo_cirugia.nombre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tipo_cirugia.nombre IS 'Nombre del procedimiento quirúrgico.';


--
-- Name: tipo_cirugia_id_tipo_cirugia_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tipo_cirugia ALTER COLUMN id_tipo_cirugia ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tipo_cirugia_id_tipo_cirugia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: traslado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.traslado (
    id_traslado integer NOT NULL,
    fecha_hora timestamp with time zone NOT NULL,
    id_medico_indica integer NOT NULL,
    id_consulta integer,
    id_ingreso integer,
    id_unidad_origen integer NOT NULL,
    tipo_traslado character varying(7) NOT NULL,
    id_unidad_destino integer,
    id_institucion_destino integer,
    CONSTRAINT ck_traslado_destino CHECK (((((tipo_traslado)::text = 'interno'::text) AND (id_unidad_destino IS NOT NULL) AND (id_institucion_destino IS NULL)) OR (((tipo_traslado)::text = 'externo'::text) AND (id_institucion_destino IS NOT NULL) AND (id_unidad_destino IS NULL)))),
    CONSTRAINT ck_traslado_origen CHECK ((num_nonnulls(id_consulta, id_ingreso) = 1)),
    CONSTRAINT ck_traslado_tipo CHECK (((tipo_traslado)::text = ANY ((ARRAY['interno'::character varying, 'externo'::character varying])::text[]))),
    CONSTRAINT ck_traslado_unidades CHECK ((id_unidad_origen <> id_unidad_destino))
);


--
-- Name: TABLE traslado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.traslado IS 'Ficha de traslado de un paciente entre unidades o hacia fuera de la red.';


--
-- Name: COLUMN traslado.fecha_hora; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.traslado.fecha_hora IS 'Fecha y hora del traslado.';


--
-- Name: COLUMN traslado.tipo_traslado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.traslado.tipo_traslado IS 'interno (dentro de la red) o externo (fuera de la red).';


--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.traslado ALTER COLUMN id_traslado ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.traslado_id_traslado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: turno_emergencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.turno_emergencia (
    id_turno integer NOT NULL,
    id_unidad integer NOT NULL,
    fecha date NOT NULL,
    jornada character varying(8) NOT NULL,
    CONSTRAINT ck_turno_jornada CHECK (((jornada)::text = ANY ((ARRAY['diurno'::character varying, 'nocturno'::character varying])::text[])))
);


--
-- Name: TABLE turno_emergencia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.turno_emergencia IS 'Turnos de 12 horas de la unidad de Emergencias.';


--
-- Name: COLUMN turno_emergencia.fecha; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.turno_emergencia.fecha IS 'Fecha en que inicia el turno.';


--
-- Name: COLUMN turno_emergencia.jornada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.turno_emergencia.jornada IS 'diurno (07:00-19:00) o nocturno (19:00-07:00).';


--
-- Name: turno_emergencia_id_turno_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.turno_emergencia ALTER COLUMN id_turno ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.turno_emergencia_id_turno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: turno_medico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.turno_medico (
    id_turno integer NOT NULL,
    id_medico integer NOT NULL
);


--
-- Name: TABLE turno_medico; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.turno_medico IS 'Médicos asignados a cada turno de emergencia.';


--
-- Name: unidad_medica; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unidad_medica (
    id_unidad integer NOT NULL,
    id_hospital integer NOT NULL,
    tipo_unidad character varying(20) NOT NULL,
    costo_dia_hospitalizacion numeric(10,2),
    CONSTRAINT ck_unidad_costo_dia CHECK ((costo_dia_hospitalizacion >= (0)::numeric)),
    CONSTRAINT ck_unidad_costo_hospitalizacion CHECK ((((tipo_unidad)::text = 'Hospitalización'::text) = (costo_dia_hospitalizacion IS NOT NULL))),
    CONSTRAINT ck_unidad_tipo CHECK (((tipo_unidad)::text = ANY ((ARRAY['Consulta Externa'::character varying, 'Emergencias'::character varying, 'Cirugía'::character varying, 'Hospitalización'::character varying])::text[])))
);


--
-- Name: TABLE unidad_medica; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.unidad_medica IS 'Unidades de atención de cada hospital: Consulta Externa, Emergencias, Cirugía y Hospitalización.';


--
-- Name: COLUMN unidad_medica.tipo_unidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.unidad_medica.tipo_unidad IS 'Tipo de unidad: Consulta Externa, Emergencias, Cirugía u Hospitalización.';


--
-- Name: COLUMN unidad_medica.costo_dia_hospitalizacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.unidad_medica.costo_dia_hospitalizacion IS 'Costo por día internado; solo aplica a Hospitalización.';


--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.unidad_medica ALTER COLUMN id_unidad ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.unidad_medica_id_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: v_cirugia; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_cirugia AS
 SELECT c.id_cirugia,
    a.id_agendamiento,
    a.id_paciente,
    a.id_medico_cirujano,
    a.id_tipo_cirugia,
    u.id_hospital,
    c.id_quirofano,
    c.fecha_hora_inicio,
    c.fecha_hora_fin,
    c.estado,
    c.condicion_evolucion
   FROM (((public.cirugia c
     JOIN public.agendamiento_quirurgico a ON ((a.id_agendamiento = c.id_agendamiento)))
     JOIN public.quirofano q ON ((q.id_quirofano = c.id_quirofano)))
     JOIN public.unidad_medica u ON ((u.id_unidad = q.id_unidad)));


--
-- Name: v_consulta; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_consulta AS
 SELECT co.id_consulta,
    ci.id_cita,
    ci.fecha_hora,
    ci.id_paciente,
    ci.id_medico,
    me.id_hospital,
    me.id_especialidad,
    co.id_diagnostico,
    ci.costo_final
   FROM ((public.consulta co
     JOIN public.cita ci ON ((ci.id_cita = co.id_cita)))
     JOIN public.medico me ON ((me.id_medico = ci.id_medico)));


--
-- Name: v_estancia; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_estancia AS
 SELECT i.id_ingreso,
    i.id_paciente,
    u.id_hospital,
    i.id_unidad,
    u.tipo_unidad,
    i.id_servicio,
    i.id_camilla,
    i.fecha_hora_ingreso,
    public.fn_edad(p.fecha_nacimiento, (i.fecha_hora_ingreso)::date) AS edad_al_ingreso,
    e.id_egreso,
    e.fecha_hora_egreso,
    e.codigo_egreso,
    ((e.fecha_hora_egreso)::date - (i.fecha_hora_ingreso)::date) AS dias_hospitalizado
   FROM (((public.ingreso i
     JOIN public.unidad_medica u ON ((u.id_unidad = i.id_unidad)))
     JOIN public.paciente p ON ((p.id_paciente = i.id_paciente)))
     LEFT JOIN public.egreso e ON ((e.id_ingreso = i.id_ingreso)));


--
-- Name: v_factura; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_factura AS
 SELECT f.id_factura,
    f.fecha_emision,
    f.total,
    f.numero_cuotas,
    COALESCE(ci.id_paciente, i.id_paciente, a.id_paciente) AS id_paciente,
    u.id_hospital,
    u.id_unidad,
    u.tipo_unidad,
    COALESCE(pg.total_pagado, (0)::numeric) AS total_pagado,
    (f.total - COALESCE(pg.total_pagado, (0)::numeric)) AS saldo
   FROM (((((((((public.factura f
     LEFT JOIN public.cita ci ON ((ci.id_cita = f.id_cita)))
     LEFT JOIN public.medico me ON ((me.id_medico = ci.id_medico)))
     LEFT JOIN public.unidad_medica uc ON (((uc.id_hospital = me.id_hospital) AND ((uc.tipo_unidad)::text = 'Consulta Externa'::text))))
     LEFT JOIN public.ingreso i ON ((i.id_ingreso = f.id_ingreso)))
     LEFT JOIN public.cirugia c ON ((c.id_cirugia = f.id_cirugia)))
     LEFT JOIN public.agendamiento_quirurgico a ON ((a.id_agendamiento = c.id_agendamiento)))
     LEFT JOIN public.quirofano q ON ((q.id_quirofano = c.id_quirofano)))
     JOIN public.unidad_medica u ON ((u.id_unidad = COALESCE(uc.id_unidad, i.id_unidad, q.id_unidad))))
     LEFT JOIN ( SELECT pago.id_factura,
            sum(pago.monto) AS total_pagado
           FROM public.pago
          GROUP BY pago.id_factura) pg ON ((pg.id_factura = f.id_factura)));


--
-- Name: v_paciente; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_paciente AS
 SELECT p.id_paciente,
    p.numero_expediente,
    p.nombres,
    p.apellidos,
    p.fecha_nacimiento,
    public.fn_edad(p.fecha_nacimiento) AS edad,
    p.sexo,
    p.dpi,
    p.telefono,
    ec.nombre AS estado_civil,
    m.nombre AS municipio,
    d.nombre AS departamento,
    p.area,
    p.numero_seguro_social
   FROM (((public.paciente p
     JOIN public.municipio m ON ((m.id_municipio = p.id_municipio)))
     JOIN public.departamento d ON ((d.id_departamento = m.id_departamento)))
     LEFT JOIN public.estado_civil ec ON ((ec.id_estado_civil = p.id_estado_civil)));


--
-- Data for Name: agendamiento_quirurgico; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agendamiento_quirurgico (id_agendamiento, id_paciente, id_medico_cirujano, id_tipo_cirugia, id_tipo_anestesia, caracter, resumen_clinico, tiempo_estimado_min, fecha_hora_solicitud, estado_solicitud, motivo_rechazo, id_quirofano_solicitado, fecha_hora_agendada) FROM stdin;
1	5	1006	1	1	urgente	Apendicitis aguda confirmada por ecografía.	90	2026-08-11 11:00:00-06	aprobada	\N	2	2026-08-11 18:30:00-06
2	7	1009	4	1	programado	Carcinoma colorrectal en estudio.	160	2026-08-13 09:00:00-06	rechazada	El comité recomienda completar estudios de imagen y control nutricional previo a la intervención.	11	\N
3	6	1007	7	1	programado	Enfermedad valvular aórtica con estenosis severa.	180	2026-09-08 10:00:00-06	pendiente	\N	\N	\N
\.


--
-- Data for Name: aspecto_quirurgico; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.aspecto_quirurgico (id_aspecto, etapa, seccion, nombre, tipo_evaluacion) FROM stdin;
1	preoperatorio	Planificación	Disponibilidad de tabla quirúrgica	exito_falla
2	preoperatorio	Planificación	Preparación de equipos y quirófano previo al ingreso del paciente	exito_falla
3	preoperatorio	Planificación	Recepción y acogida del paciente en el quirófano	exito_falla
4	preoperatorio	Entrada	Brazalete de identificación: nombre, procedimiento y lado o segmento a operar	exito_falla
5	preoperatorio	Entrada	Ficha clínica: laboratorios, consentimiento firmado y evaluación preanestésica	exito_falla
6	preoperatorio	Entrada	Arsenal instrumental estéril, implantes y equipos disponibles y operativos	exito_falla
7	preoperatorio	Entrada	Anestesista comprueba medicamentos, drogas y materiales de la técnica anestésica	exito_falla
8	intraoperatorio	Chequeo en quirófano	Presencia completa del equipo quirúrgico	exito_falla
9	intraoperatorio	Chequeo en quirófano	Traslado correcto de camilla a mesa quirúrgica	exito_falla
10	intraoperatorio	Chequeo en quirófano	Posicionamiento correcto en mesa operatoria	exito_falla
11	intraoperatorio	Chequeo en quirófano	Placa instalada en el lugar correcto	exito_falla
12	intraoperatorio	Pausa quirúrgica	Confirmación de todo el equipo de quirófano	exito_falla
13	intraoperatorio	Pausa quirúrgica	Confirmación del paciente	exito_falla
14	intraoperatorio	Pausa quirúrgica	Confirmación de buenas condiciones de esterilidad	exito_falla
15	intraoperatorio	Pausa quirúrgica	Revisión de máquina de anestesia	exito_falla
16	intraoperatorio	Pausa quirúrgica	Confirmación de suministro de anestesia	exito_falla
17	intraoperatorio	Pausa quirúrgica	Cirujano indica plan quirúrgico	exito_falla
18	intraoperatorio	Pausa quirúrgica	Incisión	exito_falla
19	intraoperatorio	Gestión de cuidados	Registro de balance hídrico	aceptabilidad
20	intraoperatorio	Gestión de cuidados	Registro de seguridad en administración de medicamentos	aceptabilidad
21	intraoperatorio	Gestión de cuidados	Registro de transfusión de sangre	aceptabilidad
22	intraoperatorio	Salida quirúrgica	El cirujano anuncia el fin de los procedimientos quirúrgicos	exito_falla
23	intraoperatorio	Salida quirúrgica	Confirmación del procedimiento quirúrgico efectivamente realizado	exito_falla
24	intraoperatorio	Salida quirúrgica	Conteo del instrumental satisfactorio	exito_falla
25	intraoperatorio	Salida quirúrgica	Cierre de la incisión	exito_falla
26	postoperatorio	Ingreso a sala de recuperación	Confirmación del tipo de cama para el paciente	exito_falla
27	postoperatorio	Ingreso a sala de recuperación	Cama post anestésica disponible	exito_falla
28	postoperatorio	Ingreso a sala de recuperación	Gases clínicos disponibles	exito_falla
29	postoperatorio	Ingreso a sala de recuperación	Bombas de infusión disponibles	exito_falla
30	postoperatorio	Ingreso a sala de recuperación	Monitores disponibles	exito_falla
31	postoperatorio	Ingreso a sala de recuperación	Electrodos disponibles	exito_falla
32	postoperatorio	Ingreso a sala de recuperación	Confirmación de la disposición de personal	exito_falla
33	postoperatorio	Ingreso a sala de recuperación	Medicamentos disponibles	exito_falla
34	postoperatorio	Ingreso a sala de recuperación	Portasueros disponibles	exito_falla
35	postoperatorio	Traslado seguro	Signos vitales dentro de los límites normales	exito_falla
36	postoperatorio	Traslado seguro	Zona operatoria limpia	exito_falla
37	postoperatorio	Traslado seguro	Documentación del paciente: ficha clínica y chequeo preanestésico	exito_falla
38	postoperatorio	Traslado seguro	Sueros de mantención pasando correctamente	exito_falla
\.


--
-- Data for Name: calificacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.calificacion (id_calificacion, id_paciente, fecha, puntuacion, comentario, id_hospital, id_medico, id_enfermero, id_encargado, id_consulta) FROM stdin;
1	1	2026-08-10	5	Atención puntual y ordenada.	1	\N	\N	\N	\N
2	3	2026-08-12	4	Buena atención en emergencias, espera corta.	1	\N	\N	\N	\N
3	2	2026-08-18	3	Habitación cómoda, pero demoras en los trámites.	1	\N	\N	\N	\N
4	1	2026-08-10	5	Explicó claramente el tratamiento.	\N	1002	\N	\N	1
5	5	2026-08-11	4	Detectó a tiempo la apendicitis.	\N	1005	\N	\N	2
6	5	2026-08-14	5	Cirugía sin complicaciones y buen seguimiento.	\N	1006	\N	\N	\N
7	3	2026-08-12	4	Atención rápida en emergencias.	\N	1001	\N	\N	\N
8	5	2026-08-14	5	Muy atento durante la recuperación.	\N	\N	2003	\N	\N
9	5	2026-08-12	4	\N	\N	\N	2001	\N	\N
10	4	2026-08-21	4	Estuvo pendiente de todos los trámites de la paciente.	\N	\N	\N	301	\N
\.


--
-- Data for Name: camilla; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.camilla (id_camilla, id_unidad, numero, disponible) FROM stdin;
1	14	1	t
2	14	2	t
3	14	3	t
4	14	4	t
5	14	5	t
6	14	6	t
7	14	7	t
8	14	8	t
9	14	9	t
10	14	10	t
11	14	11	t
12	14	12	t
13	14	13	t
14	14	14	t
15	14	15	t
16	14	16	t
17	14	17	t
18	14	18	t
19	14	19	t
20	14	20	t
21	14	21	t
22	14	22	t
23	14	23	t
24	14	24	t
25	12	1	t
26	12	2	t
27	12	3	t
28	12	4	t
29	12	5	t
30	12	6	t
101	24	1	t
102	24	2	t
103	24	3	t
104	24	4	t
105	24	5	t
106	24	6	t
107	24	7	t
108	24	8	t
109	24	9	t
110	24	10	t
111	24	11	t
112	24	12	t
113	22	1	t
114	22	2	t
115	22	3	t
116	22	4	t
201	34	1	t
202	34	2	t
203	34	3	t
204	34	4	t
205	34	5	t
206	34	6	t
207	34	7	t
208	34	8	t
209	34	9	t
210	34	10	t
211	32	1	t
212	32	2	t
213	32	3	t
214	32	4	t
\.


--
-- Data for Name: chequeo_preanestesico; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.chequeo_preanestesico (id_chequeo, id_agendamiento, clasificacion_asa, id_medico_clasifica, plan_anestesia, id_medico_anestesista) FROM stdin;
1	1	II	1006	Inducción con propofol, mantenimiento con sevoflurano, analgesia con morfina.	1008
\.


--
-- Data for Name: cirugia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cirugia (id_cirugia, id_agendamiento, id_quirofano, id_ingreso, fecha_hora_inicio, fecha_hora_fin, estado, condicion_evolucion) FROM stdin;
1	1	2	4	2026-08-11 18:40:00-06	2026-08-11 20:10:00-06	finalizada	sin_complicaciones
\.


--
-- Data for Name: cirugia_insumo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cirugia_insumo (id_cirugia, id_insumo, cantidad, costo_unitario) FROM stdin;
1	1	2	30.00
1	2	1	25.00
1	4	10	8.00
1	5	8	15.00
1	6	2	120.00
1	7	3	70.00
\.


--
-- Data for Name: cirugia_personal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cirugia_personal (id_cirugia_personal, id_cirugia, id_medico, id_enfermero, id_rol) FROM stdin;
1	1	1006	\N	1
2	1	1008	\N	3
3	1	\N	2001	4
4	1	\N	2003	5
\.


--
-- Data for Name: cita; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cita (id_cita, id_paciente, id_medico, fecha_hora, numero_clinica, medio_asignacion, estado, es_reconsulta, es_referido, cancelada_sin_aviso, costo_base, costo_final) FROM stdin;
1	1	1002	2026-08-10 09:00:00-06	A-101	telefonico	realizada	t	f	f	220.00	165.00
2	2	1003	2026-08-12 10:30:00-06	A-205	recepcion_general	reprogramada	f	f	f	160.00	160.00
3	4	1004	2026-08-15 08:30:00-06	B-110	telefonico	cancelada	f	f	t	180.00	198.00
4	6	1002	2026-09-20 09:30:00-06	A-101	correo_institucional	programada	f	t	f	220.00	176.00
5	5	1005	2026-08-11 09:15:00-06	A-108	recepcion_medico	realizada	f	f	f	180.00	180.00
\.


--
-- Data for Name: consentimiento_informado; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.consentimiento_informado (id_consentimiento, id_agendamiento, id_medico, procedimiento_nombre, procedimiento_objetivo, procedimiento_caracteristicas, procedimiento_riesgos, medico_firmo, firmante_nombre, firmante_relacion, firmante_firmo, fecha_obtencion) FROM stdin;
1	1	1006	Apendicectomía abierta	Resección del apéndice inflamado para evitar perforación y peritonitis.	Incisión en fosa ilíaca derecha, ligadura y extirpación del apéndice, cierre por planos, bajo anestesia general.	Sangrado, infección de herida, lesión de estructuras vecinas, complicaciones anestésicas.	t	Carlos De León Ortiz	paciente	t	2026-08-11
\.


--
-- Data for Name: consulta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.consulta (id_consulta, id_cita, id_diagnostico, otros_datos, notas_observaciones) FROM stdin;
1	1	1	Seguimiento a estudio cardiológico de 2025.	Paciente estable; continuar tratamiento y control en 30 días.
2	5	2	Dolor abdominal en fosa ilíaca derecha de más de 6 horas.	Se solicita valoración quirúrgica de urgencia; requiere hospitalización.
\.


--
-- Data for Name: departamento; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departamento (id_departamento, nombre) FROM stdin;
1	Alta Verapaz
2	Baja Verapaz
3	Chimaltenango
4	Chiquimula
5	El Progreso
6	Escuintla
7	Guatemala
8	Huehuetenango
9	Izabal
10	Jalapa
11	Jutiapa
12	Petén
13	Quetzaltenango
14	Quiché
15	Retalhuleu
16	Sacatepéquez
17	San Marcos
18	Santa Rosa
19	Sololá
20	Suchitepéquez
21	Totonicapán
22	Zacapa
\.


--
-- Data for Name: diagnostico; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.diagnostico (id_diagnostico, codigo_cie10, descripcion) FROM stdin;
1	I10	Hipertensión esencial (primaria)
2	K35.8	Apendicitis aguda, otra y la no especificada
3	T07	Traumatismos múltiples, no especificados
4	S42.3	Fractura de la diáfisis del húmero
5	S06.0	Conmoción cerebral
6	R50.9	Fiebre, no especificada
7	E86	Depleción del volumen
8	C18.9	Tumor maligno del colon, parte no especificada
9	I35.0	Estenosis (de la válvula) aórtica
10	J18.9	Neumonía, no especificada
11	E11.9	Diabetes mellitus tipo 2, sin complicaciones
\.


--
-- Data for Name: documentacion_etapa; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.documentacion_etapa (id_cirugia, etapa, id_enfermero, fecha_envio) FROM stdin;
1	preoperatorio	2001	2026-08-12
1	intraoperatorio	2002	2026-08-12
1	postoperatorio	2003	2026-08-12
\.


--
-- Data for Name: egreso; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.egreso (id_egreso, id_ingreso, id_medico, id_diagnostico_principal, fecha_hora_egreso, motivo_egreso, codigo_egreso, sin_consentimiento, motivo_sin_consentimiento, codigo_traslado, referido_otro_hospital) FROM stdin;
1	1	1001	3	2026-08-12 10:00:00-06	Mejoría clínica.	vivo	f	\N	\N	f
2	3	1005	1	2026-08-18 09:30:00-06	Estabilización y mejoría.	vivo	f	\N	\N	f
3	5	1006	2	2026-08-14 11:30:00-06	Recuperación satisfactoria sin complicaciones.	vivo	f	\N	\N	f
\.


--
-- Data for Name: egreso_diagnostico; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.egreso_diagnostico (id_egreso, id_diagnostico) FROM stdin;
1	5
1	4
\.


--
-- Data for Name: encargado; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.encargado (id_encargado, nombres, apellidos, dpi, telefono, id_municipio, area) FROM stdin;
301	Isabel	Cruz López	8881123450101	5551-3001	1	Urbana
302	Roberto	Méndez Rodríguez	8881123450102	5551-3002	1	Urbana
303	Karla	Paz Veliz	8881123450103	5551-3003	6	Urbana
\.


--
-- Data for Name: enfermero; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.enfermero (id_enfermero, nombres, apellidos, dpi, telefono, id_hospital, tipo) FROM stdin;
2001	Luis	Hernández Solís	2001123450201	5552-2001	1	registrado
2002	Marta	Recinos Alvarado	2001123450202	5552-2002	1	registrado
2003	Carlos	García Méndez	2001123450203	5552-2003	1	practicante
2004	Ana	López Pérez	2001123450204	5552-2004	1	registrado
2005	Pedro	Ramírez Soto	2001123450205	5552-2005	1	registrado
\.


--
-- Data for Name: equipo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipo (id_equipo, nombre, descripcion, tipo, funcion, estado) FROM stdin;
1	Monitor de signos vitales	Monitor multiparamétrico de 5 derivaciones	medico	diagnostico	disponible
2	Ventilador mecánico	Ventilador de cuidados críticos	medico	tratamiento	disponible
3	Bomba de infusión	Bomba de infusión volumétrica	medico	tratamiento	disponible
4	Desfibrilador	Desfibrilador con monitor	medico	tratamiento	disponible
5	Arco en C	Arco en C móvil para fluoroscopia	quirurgico	diagnostico	disponible
6	Microscopio quirúrgico	Microscopio para neurocirugía	quirurgico	exploracion	disponible
7	Lámpara quirúrgica LED	Lámpara de alta intensidad para quirófano	quirurgico	otro	disponible
8	Mesa de operaciones	Mesa quirúrgica electromecánica	quirurgico	otro	disponible
\.


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.especialidad (id_especialidad, nombre, tipo) FROM stdin;
301	Cardiología	clinica
302	Dermatología	clinica
303	Fisioterapia	clinica
304	Ginecología Oncológica	clinica
305	Hematología	clinica
306	Medicina Física y Rehabilitación	clinica
307	Medicina General	clinica
308	Nutrición y Dietética	clinica
309	Odontología General	clinica
310	Oftalmología	clinica
311	Psicología	clinica
312	Pediatría	clinica
313	Urología	clinica
314	Terapia del Lenguaje	clinica
315	Cirugía General	quirurgica
316	Cirugía Cardiovascular	quirurgica
317	Cirugía Oncológica	quirurgica
318	Anestesiología	clinica
319	Cirugía de la Mano	quirurgica
320	Videolaparoscopia Quirúrgica	quirurgica
321	Cirugía Ginecológica	quirurgica
322	Cirugía Neurológica	quirurgica
323	Cirugía Oftalmológica	quirurgica
324	Cirugía Ortopédica	quirurgica
325	Cirugía Otorrinolaringológica	quirurgica
326	Cirugía Pediátrica	quirurgica
327	Cirugía Plástica	quirurgica
328	Cirugía de Tórax	quirurgica
329	Cirugía Urológica	quirurgica
\.


--
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.estado_civil (id_estado_civil, nombre) FROM stdin;
1	Soltero(a)
2	Casado(a)
3	Unido(a)
4	Divorciado(a)
5	Viudo(a)
\.


--
-- Data for Name: factura; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.factura (id_factura, id_cita, id_ingreso, id_cirugia, fecha_emision, descripcion, total, numero_cuotas) FROM stdin;
1	1	\N	\N	2026-08-10 11:30:00-06	Consulta de cardiología; reconsulta (75%).	165.00	1
2	\N	1	\N	2026-08-12 10:30:00-06	Atención de emergencia por politraumatismo.	1800.00	3
3	\N	3	\N	2026-08-18 09:45:00-06	Hospitalización 4 días: medicina interna + insumos médicos.	4390.00	4
4	\N	\N	1	2026-08-12 08:00:00-06	Cirugía: apendicectomía (cirugía general) + insumos utilizados.	9235.00	6
5	\N	5	\N	2026-08-14 12:00:00-06	Hospitalización postoperatoria: 3 días en cuidados intermedios + insumos.	3870.00	3
\.


--
-- Data for Name: historia_clinica; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.historia_clinica (id_historia_clinica, id_agendamiento, id_medico, fecha, fuente_interrogatorio, religion, ocupacion, lugar_nacimiento, lugar_residencia, antecedentes_heredofamiliares, antecedentes_personales_no_patologicos, antecedentes_patologicos, padecimiento_actual, interrogatorio_aparatos_sistemas, sintomas_generales_terapeutica, estudios_previos, signos_vitales, exploracion_general, exploracion_sistematizada) FROM stdin;
1	1	1006	2026-08-11	directo	Católica	Comerciante	Olintepeque, Quetzaltenango	Olintepeque, Quetzaltenango	Cardiopatía isquémica en padre; hipertensión en madre.	No fumador; consumo de alcohol ocasional; alimentación sin restricciones.	Ninguno conocido.	Dolor abdominal en fosa ilíaca derecha desde hace 8 horas, con náuseas.	Dolor intenso localizado, sin irradiación.	Paciente no había iniciado antibióticos previo a consulta.	Ecografía abdominal: líquido libre y engrosamiento apendicular.	TA 120/80, FC 92, T° 37.8.	Abdomen blando, doloroso a palpación en fosa ilíaca derecha.	Cabeza y cuello sin alteraciones; tórax y abdomen según lo referido; extremidades sin déficit motor.
\.


--
-- Data for Name: hospital; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hospital (id_hospital, nombre, informacion_especifica, direccion, id_municipio) FROM stdin;
1	Hospital General de Occidente	Hospital general de tercer nivel; 4 quirófanos y 24 camillas de hospitalización.	15 Av. 6-45, zona 3	1
2	Hospital Regional de San Marcos	Hospital de referencia regional para el departamento de San Marcos.	7a. calle 4-10, zona 2	6
3	Hospital Infantil de Retalhuleu	Hospital especializado en atención pediátrica.	Boulevard El Malecón, zona 1	8
\.


--
-- Data for Name: hospitalizacion_insumo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hospitalizacion_insumo (id_ingreso, id_insumo, cantidad, costo_unitario) FROM stdin;
3	1	8	30.00
3	8	10	15.00
5	1	6	30.00
5	8	6	15.00
\.


--
-- Data for Name: ingreso; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ingreso (id_ingreso, id_paciente, id_unidad, id_servicio, id_medico_encargado, id_camilla, id_quirofano, id_turno, fecha_hora_ingreso, motivo_ingreso, diagnostico_presuntivo, prioridad_triage, turnos_espera) FROM stdin;
1	3	12	3	1001	25	\N	1	2026-08-09 22:10:00-06	Politraumatismo por accidente de tránsito.	Traumatismo craneoencefálico leve; fractura de brazo derecho.	2	0
2	4	12	5	1005	26	\N	2	2026-08-20 14:05:00-06	Fiebre alta persistente y deshidratación.	Cuadro febril viral en observación.	3	1
3	2	14	9	1005	3	\N	\N	2026-08-14 11:00:00-06	Hipertensión arterial descompensada.	Crisis hipertensiva en estudio.	\N	\N
4	5	13	17	1006	\N	2	\N	2026-08-11 18:35:00-06	Ingreso a quirófano para apendicectomía de urgencia.	Apendicitis aguda.	\N	\N
5	5	14	15	1006	4	\N	\N	2026-08-11 21:00:00-06	Sala de recuperación postquirúrgica tras apendicectomía.	Postoperatorio de apendicectomía.	\N	\N
\.


--
-- Data for Name: institucion_externa; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.institucion_externa (id_institucion, nombre, direccion, id_municipio) FROM stdin;
1	Sanatorio Privado Los Cipreses	4a. calle 12-30, zona 1	1
2	Centro Médico Costa Sur	Km 198 carretera al Pacífico	2
\.


--
-- Data for Name: instrumento; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.instrumento (id_instrumento, nombre, descripcion, tipo, funcion, estado) FROM stdin;
1	Pinza Kelly	Pinza hemostática curva	quirurgico	hemostatica	disponible
2	Pinza Mosquito	Pinza hemostática fina para vasos pequeños	quirurgico	hemostatica	disponible
3	Porta agujas Mayo-Hegar	Sujeta la aguja durante la sutura	quirurgico	contencion	disponible
4	Tijera Mayo	Tijera para tejidos densos	quirurgico	corte	disponible
5	Tijera Metzenbaum	Tijera para tejidos delicados	quirurgico	corte	disponible
6	Separador Farabeuf	Separa los bordes de la incisión	quirurgico	retractor	disponible
7	Mango de bisturí #3	Mango para hojas de bisturí	quirurgico	corte	disponible
8	Cánula de aspiración Yankauer	Aspira fluidos del campo operatorio	quirurgico	accesorio	disponible
9	Pinza de electrocoagulación	Coagula vasos con corriente bipolar	quirurgico	hemostatica	disponible
10	Placa de osteosíntesis	Placa de titanio para fijar fracturas	quirurgico	implante	disponible
\.


--
-- Data for Name: insumo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.insumo (id_insumo, nombre, descripcion, material, tipo, unidad_medida, costo_unitario, stock_minimo, stock_actual) FROM stdin;
1	Gasas estériles 10x10	\N	algodón	quirurgico	paquete	15.00	50	120
2	Guantes quirúrgicos	\N	látex	quirurgico	caja	85.00	30	80
3	Suero fisiológico 1L	\N	solución salina	medico	bolsa	12.00	40	100
4	Jeringa desechable 5ml	\N	plástico	medico	unidad	2.50	100	300
5	Catéter venoso central	\N	poliuretano	medico	unidad	45.00	10	25
6	Hoja de bisturí #10	\N	acero inoxidable	quirurgico	unidad	8.00	20	50
7	Sutura vicryl 3-0	\N	poliglactina	quirurgico	unidad	35.00	15	40
8	Algodón hidrófilo 100g	\N	algodón	medico	rollo	18.00	25	60
9	Yodopovidona solución 500ml	\N	solución antiséptica	medico	frasco	55.00	10	30
10	Guantes de examen	\N	nitrilo	medico	caja	70.00	20	50
\.


--
-- Data for Name: medicamento; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.medicamento (id_medicamento, nombre_generico, concentracion, forma_farmaceutica) FROM stdin;
1	Metoprolol	50 mg	tableta
2	Losartán	50 mg	tableta
3	Tramadol	50 mg	tableta
4	Paracetamol	500 mg	tableta
5	Ibuprofeno	400 mg	tableta
6	Amoxicilina	500 mg	capsula
7	Omeprazol	20 mg	capsula
8	Metformina	850 mg	tableta
9	Salbutamol	100 mcg	inhalador
10	Ceftriaxona	1 g	inyectable
\.


--
-- Data for Name: medico; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.medico (id_medico, nombres, apellidos, dpi, telefono, id_hospital, id_municipio, area, id_especialidad, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin) FROM stdin;
1001	Carmen	Ruiz Palacios	2001123450101	5551-2001	1	1	Urbana	307	general	200.00	08:00:00	12:00:00
1002	Roberto	Castillo Méndez	2001123450102	5551-2002	1	3	Urbana	301	especialista	220.00	08:00:00	11:30:00
1003	Andrea	Soto Fuentes	2001123450103	5551-2003	1	6	Rural	303	especialista	160.00	09:00:00	12:00:00
1004	Julia	Paredes Ovalle	2001123450104	5551-2004	1	1	Urbana	312	especialista	180.00	08:00:00	12:00:00
1005	Miguel	Barrios Donis	2001123450105	5551-2005	1	2	Rural	307	general	180.00	08:00:00	12:00:00
1006	Alejandro	Ramírez Lemus	2001123450106	5551-2006	1	1	Urbana	315	residente	\N	\N	\N
1008	Daniel	Morales Peña	2001123450108	5551-2008	1	1	Urbana	318	interno	\N	\N	\N
1009	Silvia	Vásquez Cotero	2001123450109	5551-2009	3	7	Urbana	317	especialista	\N	\N	\N
1010	Elena	Vásquez Sotelo	2001123450110	5551-2010	1	1	Urbana	302	especialista	180.00	08:00:00	12:00:00
1011	Marcos	Aguilar Salazar	2001123450111	5551-2011	1	1	Urbana	304	especialista	210.00	09:00:00	12:00:00
1012	Gabriela	Nájera Ruiz	2001123450112	5551-2012	2	6	Urbana	305	especialista	195.00	08:00:00	11:30:00
1013	Fernando	López Arriaga	2001123450113	5551-2013	1	3	Urbana	306	especialista	175.00	09:00:00	12:00:00
1014	Claudia	Recinos Toj	2001123450114	5551-2014	2	6	Urbana	308	especialista	150.00	08:00:00	12:00:00
1015	Andrés	Chinchilla Paz	2001123450115	5551-2015	1	1	Urbana	309	general	130.00	08:00:00	12:00:00
1016	Paola	Sandoval Itzep	2001123450116	5551-2016	3	7	Urbana	310	especialista	185.00	08:00:00	12:00:00
1017	Ricardo	Batz Coyoy	2001123450117	5551-2017	1	1	Urbana	311	especialista	165.00	09:00:00	12:00:00
1018	Silvia	Gómez Tuch	2001123450118	5551-2018	1	3	Urbana	314	especialista	140.00	08:00:00	12:00:00
1019	Julio	Estrada Mazariegos	2001123450119	5551-2019	2	6	Urbana	313	especialista	190.00	08:00:00	12:00:00
1007	Hilda	Cifuentes Rojas	2001123450107	5551-2007	2	6	Urbana	316	externo	\N	\N	\N
1020	René	Iguarán Solís	2001123450120	5551-2020	1	1	Urbana	319	externo	\N	\N	\N
1021	Wilfredo	Chávez Orozco	2001123450121	5551-2021	2	6	Urbana	320	externo	\N	\N	\N
1022	Ana	Lucero Fuentes	2001123450122	5551-2022	3	1	Urbana	321	externo	\N	\N	\N
1023	Héctor	Quirós Barrios	2001123450123	5551-2023	1	3	Urbana	322	externo	\N	\N	\N
1024	Verónica	Aranda Cruz	2001123450124	5551-2024	2	1	Urbana	323	externo	\N	\N	\N
1025	Gustavo	Rivas Monzón	2001123450125	5551-2025	3	7	Urbana	324	externo	\N	\N	\N
1026	Mónica	Figueroa Lam	2001123450126	5551-2026	1	1	Urbana	325	externo	\N	\N	\N
1027	Pablo	Tzoc Ajcá	2001123450127	5551-2027	2	6	Urbana	326	externo	\N	\N	\N
1028	Isabel	Contreras Mejía	2001123450128	5551-2028	3	1	Urbana	327	externo	\N	\N	\N
1029	Carlos	Menéndez Ralda	2001123450129	5551-2029	1	3	Urbana	328	externo	\N	\N	\N
1030	Luis	Zambrano Sic	2001123450130	5551-2030	2	6	Urbana	329	externo	\N	\N	\N
\.


--
-- Data for Name: metodo_pago; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.metodo_pago (id_metodo_pago, nombre) FROM stdin;
1	Efectivo
2	Tarjeta de crédito
3	Tarjeta de débito
4	Transferencia bancaria
\.


--
-- Data for Name: municipio; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.municipio (id_municipio, id_departamento, nombre) FROM stdin;
1	13	Quetzaltenango
2	13	Coatepeque
3	13	Olintepeque
4	13	Zunil
5	13	Cantel
6	17	San Marcos
7	21	Totonicapán
8	15	Retalhuleu
\.


--
-- Data for Name: paciente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.paciente (id_paciente, numero_expediente, nombres, apellidos, fecha_nacimiento, sexo, dpi, telefono, id_municipio, area, id_estado_civil, numero_seguro_social) FROM stdin;
1	HG1-0001	María Fernanda	López García	1988-04-12	Femenino	2220123450123	5551-1001	1	Urbana	2	IGSS-88432
2	HG1-0002	Jorge Luis	Ramírez Sosa	1990-11-03	Masculino	3330123450456	5551-1002	6	Rural	1	\N
3	HG1-0003	Pedro	Gómez Aguilar	1975-07-22	Masculino	4440123450789	5551-1003	5	Rural	2	\N
4	HG1-0004	Ana Lucía	Méndez Cruz	2015-05-30	Femenino	\N	5551-1004	1	Urbana	1	IGSS-22150
5	HG1-0005	Carlos	De León Ortiz	1982-09-15	Masculino	6660123450123	5551-1005	3	Urbana	2	\N
6	HG2-0001	Sofía	Rivera Paz	2001-02-25	Femenino	7770123450650	5551-1006	6	Urbana	1	\N
7	HG1-0006	Luis Miguel	Castillo Fuentes	1968-01-19	Masculino	8880123450901	5551-1007	4	Rural	5	\N
\.


--
-- Data for Name: paciente_encargado; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.paciente_encargado (id_paciente, id_encargado, id_parentesco) FROM stdin;
4	301	1
4	302	2
6	303	3
\.


--
-- Data for Name: pago; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pago (id_pago, id_factura, numero_cuota, monto, fecha_pago, id_metodo_pago) FROM stdin;
1	1	1	165.00	2026-08-10	1
2	2	1	600.00	2026-08-12	2
3	2	2	600.00	2026-09-12	2
4	3	1	1097.50	2026-08-18	3
5	3	2	1097.50	2026-09-18	1
6	4	1	1539.17	2026-08-12	2
7	4	2	1539.17	2026-09-12	2
8	5	1	1290.00	2026-08-14	3
\.


--
-- Data for Name: parentesco; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parentesco (id_parentesco, nombre) FROM stdin;
1	Madre
2	Padre
3	Hermano(a)
4	Hijo(a)
5	Cónyuge
6	Abuelo(a)
7	Tío(a)
8	Tutor legal
9	Otro
\.


--
-- Data for Name: quirofano; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quirofano (id_quirofano, id_unidad, numero, estado) FROM stdin;
1	13	1	disponible
2	13	2	disponible
3	13	3	disponible
4	13	4	disponible
5	23	1	disponible
6	23	2	disponible
7	23	3	disponible
8	23	4	disponible
9	33	1	disponible
10	33	2	disponible
11	33	3	disponible
12	33	4	disponible
\.


--
-- Data for Name: receta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.receta (id_receta, id_consulta, fecha_proxima_cita) FROM stdin;
1	1	2026-09-10
2	2	\N
\.


--
-- Data for Name: receta_medicamento; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.receta_medicamento (id_receta, id_medicamento, dosis, duracion) FROM stdin;
1	1	1 tableta cada 12 horas	30 días
1	2	1 tableta en la mañana	30 días
2	3	1 tableta hasta cada 8 horas según dolor	5 días
\.


--
-- Data for Name: registro_procedimiento; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.registro_procedimiento (id_registro, id_cirugia, id_aspecto, resultado, descripcion, fecha_hora_registro, id_enfermero) FROM stdin;
1	1	1	exito	Tabla quirúrgica disponible, equipos y quirófano preparados.	2026-08-11 18:15:00-06	2001
2	1	4	exito	Paciente identificado con brazalete; ficha clínica y consentimiento verificados.	2026-08-11 18:38:00-06	2001
3	1	8	exito	Equipo quirúrgico completo; traslado y posicionamiento correctos.	2026-08-11 18:45:00-06	2002
4	1	13	exito	Paciente y procedimiento confirmados; condiciones de esterilidad adecuadas.	2026-08-11 18:50:00-06	2002
5	1	19	aceptable	Balance hídrico registrado sin alteraciones.	2026-08-11 19:10:00-06	2002
6	1	24	exito	Conteo de instrumental satisfactorio; cierre de incisión.	2026-08-11 20:05:00-06	2002
7	1	26	exito	Ingreso a sala de recuperación con evolución sin complicaciones.	2026-08-11 20:25:00-06	2003
8	1	35	exito	Signos vitales normales; zona operatoria limpia; documentación completa.	2026-08-11 21:15:00-06	2003
\.


--
-- Data for Name: requerimiento_equipo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.requerimiento_equipo (id_agendamiento, id_equipo, cantidad) FROM stdin;
1	1	1
2	3	1
\.


--
-- Data for Name: requerimiento_instrumento; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.requerimiento_instrumento (id_agendamiento, id_instrumento, cantidad) FROM stdin;
1	1	1
2	3	4
\.


--
-- Data for Name: requerimiento_insumo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.requerimiento_insumo (id_agendamiento, id_insumo, cantidad) FROM stdin;
1	6	2
\.


--
-- Data for Name: rol_quirurgico; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rol_quirurgico (id_rol, nombre, tipo_personal) FROM stdin;
1	Cirujano	medico
2	Cirujano ayudante	medico
3	Anestesiólogo	medico
4	Enfermero instrumentista	enfermero
5	Enfermero circulante	enfermero
\.


--
-- Data for Name: servicio_atencion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.servicio_atencion (id_servicio, id_unidad, nombre, costo) FROM stdin;
1	12	Aislamiento y control de vía aérea y ventilación	1200.00
2	12	Control cardiocirculatorio	1400.00
3	12	Atención de pacientes politraumatizados	1800.00
4	12	Manejo, control y administración de drogas protocolizadas	900.00
5	12	Procedimientos de control y observación	700.00
6	12	Procedimientos terapéuticos/diagnósticos	1100.00
7	12	Procedimientos diagnósticos	800.00
8	14	Hematología	1500.00
9	14	Medicina interna	1600.00
10	14	Neumología	1500.00
11	14	Neurología	1700.00
12	14	Oncología	2000.00
13	14	Ortopedia	1400.00
14	14	Pediatría	1600.00
15	14	Unidad de cuidados intermedios	1800.00
16	14	Unidad de cuidado crítico de adultos	2500.00
17	13	Cirugía General	8500.00
18	13	Cirugía Cardiovascular	15000.00
19	13	Cirugía Oncológica	12000.00
101	22	Aislamiento y control de vía aérea y ventilación	1020.00
201	32	Aislamiento y control de vía aérea y ventilación	1080.00
102	22	Control cardiocirculatorio	1190.00
202	32	Control cardiocirculatorio	1260.00
103	22	Atención de pacientes politraumatizados	1530.00
203	32	Atención de pacientes politraumatizados	1620.00
104	22	Manejo, control y administración de drogas protocolizadas	765.00
204	32	Manejo, control y administración de drogas protocolizadas	810.00
105	22	Procedimientos de control y observación	595.00
205	32	Procedimientos de control y observación	630.00
106	22	Procedimientos terapéuticos/diagnósticos	935.00
206	32	Procedimientos terapéuticos/diagnósticos	990.00
107	22	Procedimientos diagnósticos	680.00
207	32	Procedimientos diagnósticos	720.00
108	24	Hematología	1275.00
208	34	Hematología	1350.00
109	24	Medicina interna	1360.00
209	34	Medicina interna	1440.00
110	24	Neumología	1275.00
210	34	Neumología	1350.00
111	24	Neurología	1445.00
211	34	Neurología	1530.00
112	24	Oncología	1700.00
212	34	Oncología	1800.00
113	24	Ortopedia	1190.00
213	34	Ortopedia	1260.00
114	24	Pediatría	1360.00
214	34	Pediatría	1440.00
115	24	Unidad de cuidados intermedios	1530.00
215	34	Unidad de cuidados intermedios	1620.00
116	24	Unidad de cuidado crítico de adultos	2125.00
216	34	Unidad de cuidado crítico de adultos	2250.00
117	23	Cirugía General	7225.00
217	33	Cirugía General	7650.00
118	23	Cirugía Cardiovascular	12750.00
218	33	Cirugía Cardiovascular	13500.00
119	23	Cirugía Oncológica	10200.00
219	33	Cirugía Oncológica	10800.00
\.


--
-- Data for Name: tipo_anestesia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tipo_anestesia (id_tipo_anestesia, nombre) FROM stdin;
1	General
2	Regional raquídea
3	Regional epidural
4	Local
5	Sedación
\.


--
-- Data for Name: tipo_cirugia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tipo_cirugia (id_tipo_cirugia, nombre, id_especialidad) FROM stdin;
1	Apendicectomía abierta	315
2	Colecistectomía laparoscópica	320
3	Hernioplastia inguinal	315
4	Resección oncológica de colon	317
5	Mastectomía	317
6	Revascularización miocárdica	316
7	Reemplazo de válvula aórtica	316
8	Reducción de fractura	324
9	Cesárea	321
10	Cirugía de catarata	323
\.


--
-- Data for Name: traslado; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.traslado (id_traslado, fecha_hora, id_medico_indica, id_consulta, id_ingreso, id_unidad_origen, tipo_traslado, id_unidad_destino, id_institucion_destino) FROM stdin;
1	2026-08-11 10:00:00-06	1005	2	\N	11	interno	13	\N
2	2026-08-11 21:30:00-06	1006	\N	4	13	interno	14	\N
3	2026-08-21 08:00:00-06	1005	\N	2	12	interno	22	\N
\.


--
-- Data for Name: turno_emergencia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.turno_emergencia (id_turno, id_unidad, fecha, jornada) FROM stdin;
1	12	2026-08-09	nocturno
2	12	2026-08-20	diurno
\.


--
-- Data for Name: turno_medico; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.turno_medico (id_turno, id_medico) FROM stdin;
1	1001
1	1005
2	1001
2	1005
\.


--
-- Data for Name: unidad_medica; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.unidad_medica (id_unidad, id_hospital, tipo_unidad, costo_dia_hospitalizacion) FROM stdin;
11	1	Consulta Externa	\N
12	1	Emergencias	\N
13	1	Cirugía	\N
14	1	Hospitalización	600.00
21	2	Consulta Externa	\N
22	2	Emergencias	\N
23	2	Cirugía	\N
24	2	Hospitalización	450.00
31	3	Consulta Externa	\N
32	3	Emergencias	\N
33	3	Cirugía	\N
34	3	Hospitalización	520.00
\.


--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.agendamiento_quirurgico_id_agendamiento_seq', 4, false);


--
-- Name: aspecto_quirurgico_id_aspecto_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.aspecto_quirurgico_id_aspecto_seq', 39, false);


--
-- Name: calificacion_id_calificacion_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.calificacion_id_calificacion_seq', 11, false);


--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.camilla_id_camilla_seq', 215, false);


--
-- Name: chequeo_preanestesico_id_chequeo_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.chequeo_preanestesico_id_chequeo_seq', 2, false);


--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cirugia_id_cirugia_seq', 2, false);


--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cirugia_personal_id_cirugia_personal_seq', 5, false);


--
-- Name: cita_id_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cita_id_cita_seq', 6, false);


--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.consentimiento_informado_id_consentimiento_seq', 2, false);


--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.consulta_id_consulta_seq', 3, false);


--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.departamento_id_departamento_seq', 23, false);


--
-- Name: diagnostico_id_diagnostico_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.diagnostico_id_diagnostico_seq', 12, false);


--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.egreso_id_egreso_seq', 4, false);


--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.encargado_id_encargado_seq', 304, false);


--
-- Name: enfermero_id_enfermero_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.enfermero_id_enfermero_seq', 2006, false);


--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipo_id_equipo_seq', 9, false);


--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.especialidad_id_especialidad_seq', 330, false);


--
-- Name: estado_civil_id_estado_civil_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.estado_civil_id_estado_civil_seq', 6, false);


--
-- Name: factura_id_factura_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.factura_id_factura_seq', 6, false);


--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.historia_clinica_id_historia_clinica_seq', 2, false);


--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hospital_id_hospital_seq', 4, false);


--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ingreso_id_ingreso_seq', 6, false);


--
-- Name: institucion_externa_id_institucion_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.institucion_externa_id_institucion_seq', 3, false);


--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.instrumento_id_instrumento_seq', 11, false);


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.insumo_id_insumo_seq', 11, false);


--
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.medicamento_id_medicamento_seq', 11, false);


--
-- Name: medico_id_medico_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.medico_id_medico_seq', 1031, false);


--
-- Name: metodo_pago_id_metodo_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.metodo_pago_id_metodo_pago_seq', 5, false);


--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.municipio_id_municipio_seq', 9, false);


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.paciente_id_paciente_seq', 8, false);


--
-- Name: pago_id_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pago_id_pago_seq', 9, false);


--
-- Name: parentesco_id_parentesco_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parentesco_id_parentesco_seq', 10, false);


--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quirofano_id_quirofano_seq', 13, false);


--
-- Name: receta_id_receta_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.receta_id_receta_seq', 3, false);


--
-- Name: registro_procedimiento_id_registro_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.registro_procedimiento_id_registro_seq', 9, false);


--
-- Name: rol_quirurgico_id_rol_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rol_quirurgico_id_rol_seq', 6, false);


--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.servicio_atencion_id_servicio_seq', 220, false);


--
-- Name: tipo_anestesia_id_tipo_anestesia_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tipo_anestesia_id_tipo_anestesia_seq', 6, false);


--
-- Name: tipo_cirugia_id_tipo_cirugia_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tipo_cirugia_id_tipo_cirugia_seq', 11, false);


--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.traslado_id_traslado_seq', 4, false);


--
-- Name: turno_emergencia_id_turno_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.turno_emergencia_id_turno_seq', 3, false);


--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.unidad_medica_id_unidad_seq', 35, false);


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_pkey PRIMARY KEY (id_agendamiento);


--
-- Name: aspecto_quirurgico aspecto_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aspecto_quirurgico
    ADD CONSTRAINT aspecto_quirurgico_pkey PRIMARY KEY (id_aspecto);


--
-- Name: calificacion calificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_pkey PRIMARY KEY (id_calificacion);


--
-- Name: camilla camilla_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_pkey PRIMARY KEY (id_camilla);


--
-- Name: chequeo_preanestesico chequeo_preanestesico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_pkey PRIMARY KEY (id_chequeo);


--
-- Name: cirugia_insumo cirugia_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_pkey PRIMARY KEY (id_cirugia, id_insumo);


--
-- Name: cirugia_personal cirugia_personal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_pkey PRIMARY KEY (id_cirugia_personal);


--
-- Name: cirugia cirugia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_pkey PRIMARY KEY (id_cirugia);


--
-- Name: cita cita_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_pkey PRIMARY KEY (id_cita);


--
-- Name: consentimiento_informado consentimiento_informado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_pkey PRIMARY KEY (id_consentimiento);


--
-- Name: consulta consulta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_pkey PRIMARY KEY (id_consulta);


--
-- Name: departamento departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_pkey PRIMARY KEY (id_departamento);


--
-- Name: diagnostico diagnostico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnostico
    ADD CONSTRAINT diagnostico_pkey PRIMARY KEY (id_diagnostico);


--
-- Name: documentacion_etapa documentacion_etapa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentacion_etapa
    ADD CONSTRAINT documentacion_etapa_pkey PRIMARY KEY (id_cirugia, etapa);


--
-- Name: egreso_diagnostico egreso_diagnostico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egreso_diagnostico
    ADD CONSTRAINT egreso_diagnostico_pkey PRIMARY KEY (id_egreso, id_diagnostico);


--
-- Name: egreso egreso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_pkey PRIMARY KEY (id_egreso);


--
-- Name: encargado encargado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_pkey PRIMARY KEY (id_encargado);


--
-- Name: enfermero enfermero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT enfermero_pkey PRIMARY KEY (id_enfermero);


--
-- Name: equipo equipo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipo
    ADD CONSTRAINT equipo_pkey PRIMARY KEY (id_equipo);


--
-- Name: especialidad especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: estado_civil estado_civil_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


--
-- Name: factura factura_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_pkey PRIMARY KEY (id_factura);


--
-- Name: historia_clinica historia_clinica_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_pkey PRIMARY KEY (id_historia_clinica);


--
-- Name: hospital hospital_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (id_hospital);


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_pkey PRIMARY KEY (id_ingreso, id_insumo);


--
-- Name: ingreso ingreso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_pkey PRIMARY KEY (id_ingreso);


--
-- Name: institucion_externa institucion_externa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.institucion_externa
    ADD CONSTRAINT institucion_externa_pkey PRIMARY KEY (id_institucion);


--
-- Name: instrumento instrumento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrumento
    ADD CONSTRAINT instrumento_pkey PRIMARY KEY (id_instrumento);


--
-- Name: insumo insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insumo
    ADD CONSTRAINT insumo_pkey PRIMARY KEY (id_insumo);


--
-- Name: medicamento medicamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicamento
    ADD CONSTRAINT medicamento_pkey PRIMARY KEY (id_medicamento);


--
-- Name: medico medico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_pkey PRIMARY KEY (id_medico);


--
-- Name: metodo_pago metodo_pago_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metodo_pago
    ADD CONSTRAINT metodo_pago_pkey PRIMARY KEY (id_metodo_pago);


--
-- Name: municipio municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_pkey PRIMARY KEY (id_municipio);


--
-- Name: paciente_encargado paciente_encargado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_pkey PRIMARY KEY (id_paciente, id_encargado);


--
-- Name: paciente paciente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id_paciente);


--
-- Name: pago pago_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (id_pago);


--
-- Name: parentesco parentesco_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parentesco
    ADD CONSTRAINT parentesco_pkey PRIMARY KEY (id_parentesco);


--
-- Name: quirofano quirofano_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_pkey PRIMARY KEY (id_quirofano);


--
-- Name: receta_medicamento receta_medicamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_pkey PRIMARY KEY (id_receta, id_medicamento);


--
-- Name: receta receta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_pkey PRIMARY KEY (id_receta);


--
-- Name: registro_procedimiento registro_procedimiento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_pkey PRIMARY KEY (id_registro);


--
-- Name: requerimiento_equipo requerimiento_equipo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requerimiento_equipo
    ADD CONSTRAINT requerimiento_equipo_pkey PRIMARY KEY (id_agendamiento, id_equipo);


--
-- Name: requerimiento_instrumento requerimiento_instrumento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requerimiento_instrumento
    ADD CONSTRAINT requerimiento_instrumento_pkey PRIMARY KEY (id_agendamiento, id_instrumento);


--
-- Name: requerimiento_insumo requerimiento_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requerimiento_insumo
    ADD CONSTRAINT requerimiento_insumo_pkey PRIMARY KEY (id_agendamiento, id_insumo);


--
-- Name: rol_quirurgico rol_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol_quirurgico
    ADD CONSTRAINT rol_quirurgico_pkey PRIMARY KEY (id_rol);


--
-- Name: servicio_atencion servicio_atencion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_pkey PRIMARY KEY (id_servicio);


--
-- Name: tipo_anestesia tipo_anestesia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_anestesia
    ADD CONSTRAINT tipo_anestesia_pkey PRIMARY KEY (id_tipo_anestesia);


--
-- Name: tipo_cirugia tipo_cirugia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_cirugia
    ADD CONSTRAINT tipo_cirugia_pkey PRIMARY KEY (id_tipo_cirugia);


--
-- Name: traslado traslado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_pkey PRIMARY KEY (id_traslado);


--
-- Name: turno_emergencia turno_emergencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno_emergencia
    ADD CONSTRAINT turno_emergencia_pkey PRIMARY KEY (id_turno);


--
-- Name: turno_medico turno_medico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno_medico
    ADD CONSTRAINT turno_medico_pkey PRIMARY KEY (id_turno, id_medico);


--
-- Name: unidad_medica unidad_medica_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_pkey PRIMARY KEY (id_unidad);


--
-- Name: aspecto_quirurgico uq_aspecto_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aspecto_quirurgico
    ADD CONSTRAINT uq_aspecto_nombre UNIQUE (seccion, nombre);


--
-- Name: camilla uq_camilla_numero; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT uq_camilla_numero UNIQUE (id_unidad, numero);


--
-- Name: chequeo_preanestesico uq_chequeo_agendamiento; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT uq_chequeo_agendamiento UNIQUE (id_agendamiento);


--
-- Name: cirugia uq_cirugia_agendamiento; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT uq_cirugia_agendamiento UNIQUE (id_agendamiento);


--
-- Name: cirugia_personal uq_cirugia_enfermero; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT uq_cirugia_enfermero UNIQUE (id_cirugia, id_enfermero);


--
-- Name: cirugia_personal uq_cirugia_medico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT uq_cirugia_medico UNIQUE (id_cirugia, id_medico);


--
-- Name: consentimiento_informado uq_consentimiento_agendamiento; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT uq_consentimiento_agendamiento UNIQUE (id_agendamiento);


--
-- Name: consulta uq_consulta_cita; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT uq_consulta_cita UNIQUE (id_cita);


--
-- Name: departamento uq_departamento_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT uq_departamento_nombre UNIQUE (nombre);


--
-- Name: diagnostico uq_diagnostico_codigo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnostico
    ADD CONSTRAINT uq_diagnostico_codigo UNIQUE (codigo_cie10);


--
-- Name: egreso uq_egreso_ingreso; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT uq_egreso_ingreso UNIQUE (id_ingreso);


--
-- Name: encargado uq_encargado_dpi; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT uq_encargado_dpi UNIQUE (dpi);


--
-- Name: enfermero uq_enfermero_dpi; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT uq_enfermero_dpi UNIQUE (dpi);


--
-- Name: equipo uq_equipo_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipo
    ADD CONSTRAINT uq_equipo_nombre UNIQUE (nombre);


--
-- Name: especialidad uq_especialidad_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT uq_especialidad_nombre UNIQUE (nombre);


--
-- Name: estado_civil uq_estado_civil_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estado_civil
    ADD CONSTRAINT uq_estado_civil_nombre UNIQUE (nombre);


--
-- Name: factura uq_factura_cirugia; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT uq_factura_cirugia UNIQUE (id_cirugia);


--
-- Name: factura uq_factura_cita; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT uq_factura_cita UNIQUE (id_cita);


--
-- Name: factura uq_factura_ingreso; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT uq_factura_ingreso UNIQUE (id_ingreso);


--
-- Name: historia_clinica uq_historia_agendamiento; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT uq_historia_agendamiento UNIQUE (id_agendamiento);


--
-- Name: hospital uq_hospital_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT uq_hospital_nombre UNIQUE (nombre);


--
-- Name: institucion_externa uq_institucion_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.institucion_externa
    ADD CONSTRAINT uq_institucion_nombre UNIQUE (nombre);


--
-- Name: instrumento uq_instrumento_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrumento
    ADD CONSTRAINT uq_instrumento_nombre UNIQUE (nombre);


--
-- Name: insumo uq_insumo_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insumo
    ADD CONSTRAINT uq_insumo_nombre UNIQUE (nombre);


--
-- Name: medicamento uq_medicamento; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicamento
    ADD CONSTRAINT uq_medicamento UNIQUE (nombre_generico, concentracion, forma_farmaceutica);


--
-- Name: medico uq_medico_dpi; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT uq_medico_dpi UNIQUE (dpi);


--
-- Name: metodo_pago uq_metodo_pago_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metodo_pago
    ADD CONSTRAINT uq_metodo_pago_nombre UNIQUE (nombre);


--
-- Name: municipio uq_municipio_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT uq_municipio_nombre UNIQUE (id_departamento, nombre);


--
-- Name: paciente uq_paciente_dpi; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT uq_paciente_dpi UNIQUE (dpi);


--
-- Name: paciente uq_paciente_expediente; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT uq_paciente_expediente UNIQUE (numero_expediente);


--
-- Name: pago uq_pago_cuota; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT uq_pago_cuota UNIQUE (id_factura, numero_cuota);


--
-- Name: parentesco uq_parentesco_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parentesco
    ADD CONSTRAINT uq_parentesco_nombre UNIQUE (nombre);


--
-- Name: quirofano uq_quirofano_numero; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT uq_quirofano_numero UNIQUE (id_unidad, numero);


--
-- Name: receta uq_receta_consulta; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT uq_receta_consulta UNIQUE (id_consulta);


--
-- Name: registro_procedimiento uq_registro_aspecto; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT uq_registro_aspecto UNIQUE (id_cirugia, id_aspecto);


--
-- Name: rol_quirurgico uq_rol_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol_quirurgico
    ADD CONSTRAINT uq_rol_nombre UNIQUE (nombre);


--
-- Name: servicio_atencion uq_servicio_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT uq_servicio_nombre UNIQUE (id_unidad, nombre);


--
-- Name: tipo_anestesia uq_tipo_anestesia_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_anestesia
    ADD CONSTRAINT uq_tipo_anestesia_nombre UNIQUE (nombre);


--
-- Name: tipo_cirugia uq_tipo_cirugia_nombre; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_cirugia
    ADD CONSTRAINT uq_tipo_cirugia_nombre UNIQUE (nombre);


--
-- Name: turno_emergencia uq_turno; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno_emergencia
    ADD CONSTRAINT uq_turno UNIQUE (id_unidad, fecha, jornada);


--
-- Name: unidad_medica uq_unidad_tipo; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT uq_unidad_tipo UNIQUE (id_hospital, tipo_unidad);


--
-- Name: ix_agendamiento_quirurgico_id_medico_cirujano; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agendamiento_quirurgico_id_medico_cirujano ON public.agendamiento_quirurgico USING btree (id_medico_cirujano);


--
-- Name: ix_agendamiento_quirurgico_id_paciente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agendamiento_quirurgico_id_paciente ON public.agendamiento_quirurgico USING btree (id_paciente);


--
-- Name: ix_agendamiento_quirurgico_id_quirofano_solicitado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agendamiento_quirurgico_id_quirofano_solicitado ON public.agendamiento_quirurgico USING btree (id_quirofano_solicitado);


--
-- Name: ix_agendamiento_quirurgico_id_tipo_anestesia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agendamiento_quirurgico_id_tipo_anestesia ON public.agendamiento_quirurgico USING btree (id_tipo_anestesia);


--
-- Name: ix_agendamiento_quirurgico_id_tipo_cirugia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agendamiento_quirurgico_id_tipo_cirugia ON public.agendamiento_quirurgico USING btree (id_tipo_cirugia);


--
-- Name: ix_calificacion_id_consulta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calificacion_id_consulta ON public.calificacion USING btree (id_consulta);


--
-- Name: ix_calificacion_id_encargado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calificacion_id_encargado ON public.calificacion USING btree (id_encargado);


--
-- Name: ix_calificacion_id_enfermero; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calificacion_id_enfermero ON public.calificacion USING btree (id_enfermero);


--
-- Name: ix_calificacion_id_hospital; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calificacion_id_hospital ON public.calificacion USING btree (id_hospital);


--
-- Name: ix_calificacion_id_medico; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calificacion_id_medico ON public.calificacion USING btree (id_medico);


--
-- Name: ix_calificacion_id_paciente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calificacion_id_paciente ON public.calificacion USING btree (id_paciente);


--
-- Name: ix_chequeo_preanestesico_id_medico_anestesista; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_chequeo_preanestesico_id_medico_anestesista ON public.chequeo_preanestesico USING btree (id_medico_anestesista);


--
-- Name: ix_chequeo_preanestesico_id_medico_clasifica; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_chequeo_preanestesico_id_medico_clasifica ON public.chequeo_preanestesico USING btree (id_medico_clasifica);


--
-- Name: ix_cirugia_fecha_hora_inicio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cirugia_fecha_hora_inicio ON public.cirugia USING btree (fecha_hora_inicio);


--
-- Name: ix_cirugia_id_ingreso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cirugia_id_ingreso ON public.cirugia USING btree (id_ingreso);


--
-- Name: ix_cirugia_id_quirofano; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cirugia_id_quirofano ON public.cirugia USING btree (id_quirofano);


--
-- Name: ix_cirugia_insumo_id_insumo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cirugia_insumo_id_insumo ON public.cirugia_insumo USING btree (id_insumo);


--
-- Name: ix_cirugia_personal_id_enfermero; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cirugia_personal_id_enfermero ON public.cirugia_personal USING btree (id_enfermero);


--
-- Name: ix_cirugia_personal_id_medico; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cirugia_personal_id_medico ON public.cirugia_personal USING btree (id_medico);


--
-- Name: ix_cirugia_personal_id_rol; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cirugia_personal_id_rol ON public.cirugia_personal USING btree (id_rol);


--
-- Name: ix_cita_fecha_hora; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cita_fecha_hora ON public.cita USING btree (fecha_hora);


--
-- Name: ix_cita_id_medico; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cita_id_medico ON public.cita USING btree (id_medico);


--
-- Name: ix_cita_id_paciente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cita_id_paciente ON public.cita USING btree (id_paciente);


--
-- Name: ix_consentimiento_informado_id_medico; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_consentimiento_informado_id_medico ON public.consentimiento_informado USING btree (id_medico);


--
-- Name: ix_consulta_id_diagnostico; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_consulta_id_diagnostico ON public.consulta USING btree (id_diagnostico);


--
-- Name: ix_documentacion_etapa_id_enfermero; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_documentacion_etapa_id_enfermero ON public.documentacion_etapa USING btree (id_enfermero);


--
-- Name: ix_egreso_diagnostico_id_diagnostico; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_egreso_diagnostico_id_diagnostico ON public.egreso_diagnostico USING btree (id_diagnostico);


--
-- Name: ix_egreso_fecha_hora; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_egreso_fecha_hora ON public.egreso USING btree (fecha_hora_egreso);


--
-- Name: ix_egreso_id_diagnostico_principal; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_egreso_id_diagnostico_principal ON public.egreso USING btree (id_diagnostico_principal);


--
-- Name: ix_egreso_id_medico; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_egreso_id_medico ON public.egreso USING btree (id_medico);


--
-- Name: ix_encargado_id_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_encargado_id_municipio ON public.encargado USING btree (id_municipio);


--
-- Name: ix_enfermero_id_hospital; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_enfermero_id_hospital ON public.enfermero USING btree (id_hospital);


--
-- Name: ix_factura_fecha_emision; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_factura_fecha_emision ON public.factura USING btree (fecha_emision);


--
-- Name: ix_historia_clinica_id_medico; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_historia_clinica_id_medico ON public.historia_clinica USING btree (id_medico);


--
-- Name: ix_hospital_id_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_hospital_id_municipio ON public.hospital USING btree (id_municipio);


--
-- Name: ix_hospitalizacion_insumo_id_insumo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_hospitalizacion_insumo_id_insumo ON public.hospitalizacion_insumo USING btree (id_insumo);


--
-- Name: ix_ingreso_fecha_hora; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ingreso_fecha_hora ON public.ingreso USING btree (fecha_hora_ingreso);


--
-- Name: ix_ingreso_id_camilla; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ingreso_id_camilla ON public.ingreso USING btree (id_camilla);


--
-- Name: ix_ingreso_id_medico_encargado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ingreso_id_medico_encargado ON public.ingreso USING btree (id_medico_encargado);


--
-- Name: ix_ingreso_id_paciente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ingreso_id_paciente ON public.ingreso USING btree (id_paciente);


--
-- Name: ix_ingreso_id_quirofano; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ingreso_id_quirofano ON public.ingreso USING btree (id_quirofano);


--
-- Name: ix_ingreso_id_servicio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ingreso_id_servicio ON public.ingreso USING btree (id_servicio);


--
-- Name: ix_ingreso_id_turno; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ingreso_id_turno ON public.ingreso USING btree (id_turno);


--
-- Name: ix_ingreso_id_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ingreso_id_unidad ON public.ingreso USING btree (id_unidad);


--
-- Name: ix_institucion_externa_id_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_institucion_externa_id_municipio ON public.institucion_externa USING btree (id_municipio);


--
-- Name: ix_medico_id_especialidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_medico_id_especialidad ON public.medico USING btree (id_especialidad);


--
-- Name: ix_medico_id_hospital; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_medico_id_hospital ON public.medico USING btree (id_hospital);


--
-- Name: ix_medico_id_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_medico_id_municipio ON public.medico USING btree (id_municipio);


--
-- Name: ix_paciente_encargado_id_encargado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_paciente_encargado_id_encargado ON public.paciente_encargado USING btree (id_encargado);


--
-- Name: ix_paciente_encargado_id_parentesco; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_paciente_encargado_id_parentesco ON public.paciente_encargado USING btree (id_parentesco);


--
-- Name: ix_paciente_id_estado_civil; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_paciente_id_estado_civil ON public.paciente USING btree (id_estado_civil);


--
-- Name: ix_paciente_id_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_paciente_id_municipio ON public.paciente USING btree (id_municipio);


--
-- Name: ix_pago_fecha_pago; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_pago_fecha_pago ON public.pago USING btree (fecha_pago);


--
-- Name: ix_pago_id_metodo_pago; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_pago_id_metodo_pago ON public.pago USING btree (id_metodo_pago);


--
-- Name: ix_receta_medicamento_id_medicamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_receta_medicamento_id_medicamento ON public.receta_medicamento USING btree (id_medicamento);


--
-- Name: ix_registro_procedimiento_id_aspecto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_registro_procedimiento_id_aspecto ON public.registro_procedimiento USING btree (id_aspecto);


--
-- Name: ix_registro_procedimiento_id_enfermero; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_registro_procedimiento_id_enfermero ON public.registro_procedimiento USING btree (id_enfermero);


--
-- Name: ix_requerimiento_equipo_id_equipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_requerimiento_equipo_id_equipo ON public.requerimiento_equipo USING btree (id_equipo);


--
-- Name: ix_requerimiento_instrumento_id_instrumento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_requerimiento_instrumento_id_instrumento ON public.requerimiento_instrumento USING btree (id_instrumento);


--
-- Name: ix_requerimiento_insumo_id_insumo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_requerimiento_insumo_id_insumo ON public.requerimiento_insumo USING btree (id_insumo);


--
-- Name: ix_tipo_cirugia_id_especialidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_tipo_cirugia_id_especialidad ON public.tipo_cirugia USING btree (id_especialidad);


--
-- Name: ix_traslado_id_consulta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_traslado_id_consulta ON public.traslado USING btree (id_consulta);


--
-- Name: ix_traslado_id_ingreso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_traslado_id_ingreso ON public.traslado USING btree (id_ingreso);


--
-- Name: ix_traslado_id_institucion_destino; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_traslado_id_institucion_destino ON public.traslado USING btree (id_institucion_destino);


--
-- Name: ix_traslado_id_medico_indica; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_traslado_id_medico_indica ON public.traslado USING btree (id_medico_indica);


--
-- Name: ix_traslado_id_unidad_destino; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_traslado_id_unidad_destino ON public.traslado USING btree (id_unidad_destino);


--
-- Name: ix_traslado_id_unidad_origen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_traslado_id_unidad_origen ON public.traslado USING btree (id_unidad_origen);


--
-- Name: ix_turno_medico_id_medico; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_turno_medico_id_medico ON public.turno_medico USING btree (id_medico);


--
-- Name: calificacion trg_calificacion_consulta; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_calificacion_consulta BEFORE INSERT OR UPDATE ON public.calificacion FOR EACH ROW EXECUTE FUNCTION public.fn_calificacion_consulta();


--
-- Name: camilla trg_camilla_unidad; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_camilla_unidad BEFORE INSERT OR UPDATE ON public.camilla FOR EACH ROW EXECUTE FUNCTION public.fn_camilla_unidad();


--
-- Name: chequeo_preanestesico trg_chequeo_aprobado; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_chequeo_aprobado BEFORE INSERT OR UPDATE OF id_agendamiento ON public.chequeo_preanestesico FOR EACH ROW EXECUTE FUNCTION public.fn_agendamiento_aprobado();


--
-- Name: cirugia trg_cirugia_aprobada; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_cirugia_aprobada BEFORE INSERT OR UPDATE OF id_agendamiento ON public.cirugia FOR EACH ROW EXECUTE FUNCTION public.fn_agendamiento_aprobado();


--
-- Name: cirugia_personal trg_cirugia_personal_rol; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_cirugia_personal_rol BEFORE INSERT OR UPDATE ON public.cirugia_personal FOR EACH ROW EXECUTE FUNCTION public.fn_cirugia_personal_rol();


--
-- Name: consentimiento_informado trg_consentimiento_aprobado; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_consentimiento_aprobado BEFORE INSERT OR UPDATE OF id_agendamiento ON public.consentimiento_informado FOR EACH ROW EXECUTE FUNCTION public.fn_agendamiento_aprobado();


--
-- Name: consulta trg_consulta_cita; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_consulta_cita BEFORE INSERT OR UPDATE OF id_cita ON public.consulta FOR EACH ROW EXECUTE FUNCTION public.fn_consulta_cita();


--
-- Name: egreso trg_egreso_fecha; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_egreso_fecha BEFORE INSERT OR UPDATE ON public.egreso FOR EACH ROW EXECUTE FUNCTION public.fn_egreso_fecha();


--
-- Name: hospitalizacion_insumo trg_hosp_insumo_ingreso; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_hosp_insumo_ingreso BEFORE INSERT OR UPDATE ON public.hospitalizacion_insumo FOR EACH ROW EXECUTE FUNCTION public.fn_hosp_insumo_ingreso();


--
-- Name: ingreso trg_ingreso_consistencia; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_ingreso_consistencia BEFORE INSERT OR UPDATE ON public.ingreso FOR EACH ROW EXECUTE FUNCTION public.fn_ingreso_consistencia();


--
-- Name: paciente trg_paciente_nacimiento; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_paciente_nacimiento BEFORE INSERT OR UPDATE OF fecha_nacimiento ON public.paciente FOR EACH ROW EXECUTE FUNCTION public.fn_paciente_nacimiento();


--
-- Name: pago trg_pago_plan; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_pago_plan BEFORE INSERT OR UPDATE ON public.pago FOR EACH ROW EXECUTE FUNCTION public.fn_pago_plan();


--
-- Name: quirofano trg_quirofano_unidad; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_quirofano_unidad BEFORE INSERT OR UPDATE ON public.quirofano FOR EACH ROW EXECUTE FUNCTION public.fn_quirofano_unidad();


--
-- Name: receta trg_receta_proxima_cita; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_receta_proxima_cita BEFORE INSERT OR UPDATE ON public.receta FOR EACH ROW EXECUTE FUNCTION public.fn_receta_proxima_cita();


--
-- Name: registro_procedimiento trg_registro_resultado; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_registro_resultado BEFORE INSERT OR UPDATE ON public.registro_procedimiento FOR EACH ROW EXECUTE FUNCTION public.fn_registro_resultado();


--
-- Name: traslado trg_traslado_origen; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_traslado_origen BEFORE INSERT OR UPDATE ON public.traslado FOR EACH ROW EXECUTE FUNCTION public.fn_traslado_origen();


--
-- Name: turno_medico trg_turno_medico_hospital; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_turno_medico_hospital BEFORE INSERT OR UPDATE ON public.turno_medico FOR EACH ROW EXECUTE FUNCTION public.fn_turno_medico_hospital();


--
-- Name: turno_emergencia trg_turno_unidad; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_turno_unidad BEFORE INSERT OR UPDATE ON public.turno_emergencia FOR EACH ROW EXECUTE FUNCTION public.fn_turno_unidad();


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_id_medico_cirujano_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_id_medico_cirujano_fkey FOREIGN KEY (id_medico_cirujano) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_id_quirofano_solicitado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_id_quirofano_solicitado_fkey FOREIGN KEY (id_quirofano_solicitado) REFERENCES public.quirofano(id_quirofano) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_id_tipo_anestesia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_id_tipo_anestesia_fkey FOREIGN KEY (id_tipo_anestesia) REFERENCES public.tipo_anestesia(id_tipo_anestesia) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_id_tipo_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_id_tipo_cirugia_fkey FOREIGN KEY (id_tipo_cirugia) REFERENCES public.tipo_cirugia(id_tipo_cirugia) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_consulta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_consulta_fkey FOREIGN KEY (id_consulta) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_encargado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_encargado_fkey FOREIGN KEY (id_encargado) REFERENCES public.encargado(id_encargado) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_enfermero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_enfermero_fkey FOREIGN KEY (id_enfermero) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_hospital_fkey FOREIGN KEY (id_hospital) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: camilla camilla_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: chequeo_preanestesico chequeo_preanestesico_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: chequeo_preanestesico chequeo_preanestesico_id_medico_anestesista_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_id_medico_anestesista_fkey FOREIGN KEY (id_medico_anestesista) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: chequeo_preanestesico chequeo_preanestesico_id_medico_clasifica_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_id_medico_clasifica_fkey FOREIGN KEY (id_medico_clasifica) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia cirugia_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia cirugia_id_ingreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_id_ingreso_fkey FOREIGN KEY (id_ingreso) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia cirugia_id_quirofano_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_id_quirofano_fkey FOREIGN KEY (id_quirofano) REFERENCES public.quirofano(id_quirofano) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_insumo cirugia_insumo_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_insumo cirugia_insumo_id_insumo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_id_insumo_fkey FOREIGN KEY (id_insumo) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_personal cirugia_personal_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_personal cirugia_personal_id_enfermero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_id_enfermero_fkey FOREIGN KEY (id_enfermero) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_personal cirugia_personal_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_personal cirugia_personal_id_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES public.rol_quirurgico(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cita cita_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cita cita_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consentimiento_informado consentimiento_informado_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consentimiento_informado consentimiento_informado_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consulta consulta_id_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_id_cita_fkey FOREIGN KEY (id_cita) REFERENCES public.cita(id_cita) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consulta consulta_id_diagnostico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_id_diagnostico_fkey FOREIGN KEY (id_diagnostico) REFERENCES public.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: documentacion_etapa documentacion_etapa_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentacion_etapa
    ADD CONSTRAINT documentacion_etapa_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documentacion_etapa documentacion_etapa_id_enfermero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentacion_etapa
    ADD CONSTRAINT documentacion_etapa_id_enfermero_fkey FOREIGN KEY (id_enfermero) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso_diagnostico egreso_diagnostico_id_diagnostico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egreso_diagnostico
    ADD CONSTRAINT egreso_diagnostico_id_diagnostico_fkey FOREIGN KEY (id_diagnostico) REFERENCES public.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso_diagnostico egreso_diagnostico_id_egreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egreso_diagnostico
    ADD CONSTRAINT egreso_diagnostico_id_egreso_fkey FOREIGN KEY (id_egreso) REFERENCES public.egreso(id_egreso) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: egreso egreso_id_diagnostico_principal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_id_diagnostico_principal_fkey FOREIGN KEY (id_diagnostico_principal) REFERENCES public.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso egreso_id_ingreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_id_ingreso_fkey FOREIGN KEY (id_ingreso) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso egreso_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: encargado encargado_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: enfermero enfermero_id_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT enfermero_id_hospital_fkey FOREIGN KEY (id_hospital) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura factura_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura factura_id_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_cita_fkey FOREIGN KEY (id_cita) REFERENCES public.cita(id_cita) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura factura_id_ingreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_ingreso_fkey FOREIGN KEY (id_ingreso) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: historia_clinica historia_clinica_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: historia_clinica historia_clinica_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: hospital hospital_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_id_ingreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_id_ingreso_fkey FOREIGN KEY (id_ingreso) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_id_insumo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_id_insumo_fkey FOREIGN KEY (id_insumo) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_camilla_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_camilla_fkey FOREIGN KEY (id_camilla) REFERENCES public.camilla(id_camilla) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_medico_encargado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_medico_encargado_fkey FOREIGN KEY (id_medico_encargado) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_quirofano_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_quirofano_fkey FOREIGN KEY (id_quirofano) REFERENCES public.quirofano(id_quirofano) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES public.servicio_atencion(id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_turno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_turno_fkey FOREIGN KEY (id_turno) REFERENCES public.turno_emergencia(id_turno) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: institucion_externa institucion_externa_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.institucion_externa
    ADD CONSTRAINT institucion_externa_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: medico medico_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: medico medico_id_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_id_hospital_fkey FOREIGN KEY (id_hospital) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: medico medico_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: municipio municipio_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.departamento(id_departamento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: paciente_encargado paciente_encargado_id_encargado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_id_encargado_fkey FOREIGN KEY (id_encargado) REFERENCES public.encargado(id_encargado) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente_encargado paciente_encargado_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente_encargado paciente_encargado_id_parentesco_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_id_parentesco_fkey FOREIGN KEY (id_parentesco) REFERENCES public.parentesco(id_parentesco) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: paciente paciente_id_estado_civil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_id_estado_civil_fkey FOREIGN KEY (id_estado_civil) REFERENCES public.estado_civil(id_estado_civil) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: paciente paciente_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pago pago_id_factura_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_id_factura_fkey FOREIGN KEY (id_factura) REFERENCES public.factura(id_factura) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pago pago_id_metodo_pago_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_id_metodo_pago_fkey FOREIGN KEY (id_metodo_pago) REFERENCES public.metodo_pago(id_metodo_pago) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: quirofano quirofano_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: receta receta_id_consulta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_id_consulta_fkey FOREIGN KEY (id_consulta) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: receta_medicamento receta_medicamento_id_medicamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_id_medicamento_fkey FOREIGN KEY (id_medicamento) REFERENCES public.medicamento(id_medicamento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: receta_medicamento receta_medicamento_id_receta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_id_receta_fkey FOREIGN KEY (id_receta) REFERENCES public.receta(id_receta) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro_procedimiento registro_procedimiento_id_aspecto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_id_aspecto_fkey FOREIGN KEY (id_aspecto) REFERENCES public.aspecto_quirurgico(id_aspecto) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: registro_procedimiento registro_procedimiento_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro_procedimiento registro_procedimiento_id_enfermero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_id_enfermero_fkey FOREIGN KEY (id_enfermero) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: requerimiento_equipo requerimiento_equipo_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requerimiento_equipo
    ADD CONSTRAINT requerimiento_equipo_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: requerimiento_equipo requerimiento_equipo_id_equipo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requerimiento_equipo
    ADD CONSTRAINT requerimiento_equipo_id_equipo_fkey FOREIGN KEY (id_equipo) REFERENCES public.equipo(id_equipo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: requerimiento_instrumento requerimiento_instrumento_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requerimiento_instrumento
    ADD CONSTRAINT requerimiento_instrumento_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: requerimiento_instrumento requerimiento_instrumento_id_instrumento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requerimiento_instrumento
    ADD CONSTRAINT requerimiento_instrumento_id_instrumento_fkey FOREIGN KEY (id_instrumento) REFERENCES public.instrumento(id_instrumento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: requerimiento_insumo requerimiento_insumo_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requerimiento_insumo
    ADD CONSTRAINT requerimiento_insumo_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: requerimiento_insumo requerimiento_insumo_id_insumo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requerimiento_insumo
    ADD CONSTRAINT requerimiento_insumo_id_insumo_fkey FOREIGN KEY (id_insumo) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: servicio_atencion servicio_atencion_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tipo_cirugia tipo_cirugia_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_cirugia
    ADD CONSTRAINT tipo_cirugia_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_consulta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_consulta_fkey FOREIGN KEY (id_consulta) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_ingreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_ingreso_fkey FOREIGN KEY (id_ingreso) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_institucion_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_institucion_destino_fkey FOREIGN KEY (id_institucion_destino) REFERENCES public.institucion_externa(id_institucion) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_medico_indica_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_medico_indica_fkey FOREIGN KEY (id_medico_indica) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_unidad_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_unidad_destino_fkey FOREIGN KEY (id_unidad_destino) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_unidad_origen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_unidad_origen_fkey FOREIGN KEY (id_unidad_origen) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: turno_emergencia turno_emergencia_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno_emergencia
    ADD CONSTRAINT turno_emergencia_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: turno_medico turno_medico_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno_medico
    ADD CONSTRAINT turno_medico_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: turno_medico turno_medico_id_turno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno_medico
    ADD CONSTRAINT turno_medico_id_turno_fkey FOREIGN KEY (id_turno) REFERENCES public.turno_emergencia(id_turno) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: unidad_medica unidad_medica_id_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_id_hospital_fkey FOREIGN KEY (id_hospital) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO admin;
GRANT USAGE ON SCHEMA public TO visor;


--
-- Name: FUNCTION fn_agendamiento_aprobado(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_agendamiento_aprobado() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_agendamiento_aprobado() TO admin;


--
-- Name: FUNCTION fn_calificacion_consulta(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_calificacion_consulta() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_calificacion_consulta() TO admin;


--
-- Name: FUNCTION fn_camilla_unidad(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_camilla_unidad() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_camilla_unidad() TO admin;


--
-- Name: FUNCTION fn_cirugia_personal_rol(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_cirugia_personal_rol() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_cirugia_personal_rol() TO admin;


--
-- Name: FUNCTION fn_consulta_cita(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_consulta_cita() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_consulta_cita() TO admin;


--
-- Name: FUNCTION fn_edad(p_fecha_nacimiento date, p_fecha date); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_edad(p_fecha_nacimiento date, p_fecha date) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_edad(p_fecha_nacimiento date, p_fecha date) TO admin;
GRANT ALL ON FUNCTION public.fn_edad(p_fecha_nacimiento date, p_fecha date) TO visor;


--
-- Name: FUNCTION fn_egreso_fecha(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_egreso_fecha() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_egreso_fecha() TO admin;


--
-- Name: FUNCTION fn_hosp_insumo_ingreso(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_hosp_insumo_ingreso() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_hosp_insumo_ingreso() TO admin;


--
-- Name: FUNCTION fn_ingreso_consistencia(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_ingreso_consistencia() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_ingreso_consistencia() TO admin;


--
-- Name: FUNCTION fn_paciente_nacimiento(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_paciente_nacimiento() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_paciente_nacimiento() TO admin;


--
-- Name: FUNCTION fn_pago_plan(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_pago_plan() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_pago_plan() TO admin;


--
-- Name: FUNCTION fn_quirofano_unidad(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_quirofano_unidad() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_quirofano_unidad() TO admin;


--
-- Name: FUNCTION fn_receta_proxima_cita(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_receta_proxima_cita() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_receta_proxima_cita() TO admin;


--
-- Name: FUNCTION fn_registro_resultado(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_registro_resultado() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_registro_resultado() TO admin;


--
-- Name: FUNCTION fn_tipo_unidad(p_id_unidad integer); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_tipo_unidad(p_id_unidad integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_tipo_unidad(p_id_unidad integer) TO admin;
GRANT ALL ON FUNCTION public.fn_tipo_unidad(p_id_unidad integer) TO visor;


--
-- Name: FUNCTION fn_traslado_origen(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_traslado_origen() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_traslado_origen() TO admin;


--
-- Name: FUNCTION fn_turno_medico_hospital(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_turno_medico_hospital() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_turno_medico_hospital() TO admin;


--
-- Name: FUNCTION fn_turno_unidad(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.fn_turno_unidad() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_turno_unidad() TO admin;


--
-- Name: TABLE agendamiento_quirurgico; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.agendamiento_quirurgico TO admin;
GRANT SELECT ON TABLE public.agendamiento_quirurgico TO visor;


--
-- Name: SEQUENCE agendamiento_quirurgico_id_agendamiento_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.agendamiento_quirurgico_id_agendamiento_seq TO admin;


--
-- Name: TABLE aspecto_quirurgico; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.aspecto_quirurgico TO admin;
GRANT SELECT ON TABLE public.aspecto_quirurgico TO visor;


--
-- Name: SEQUENCE aspecto_quirurgico_id_aspecto_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.aspecto_quirurgico_id_aspecto_seq TO admin;


--
-- Name: TABLE calificacion; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.calificacion TO admin;
GRANT SELECT ON TABLE public.calificacion TO visor;


--
-- Name: SEQUENCE calificacion_id_calificacion_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.calificacion_id_calificacion_seq TO admin;


--
-- Name: TABLE camilla; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.camilla TO admin;
GRANT SELECT ON TABLE public.camilla TO visor;


--
-- Name: SEQUENCE camilla_id_camilla_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.camilla_id_camilla_seq TO admin;


--
-- Name: TABLE chequeo_preanestesico; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.chequeo_preanestesico TO admin;
GRANT SELECT ON TABLE public.chequeo_preanestesico TO visor;


--
-- Name: SEQUENCE chequeo_preanestesico_id_chequeo_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.chequeo_preanestesico_id_chequeo_seq TO admin;


--
-- Name: TABLE cirugia; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.cirugia TO admin;
GRANT SELECT ON TABLE public.cirugia TO visor;


--
-- Name: SEQUENCE cirugia_id_cirugia_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.cirugia_id_cirugia_seq TO admin;


--
-- Name: TABLE cirugia_insumo; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.cirugia_insumo TO admin;
GRANT SELECT ON TABLE public.cirugia_insumo TO visor;


--
-- Name: TABLE cirugia_personal; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.cirugia_personal TO admin;
GRANT SELECT ON TABLE public.cirugia_personal TO visor;


--
-- Name: SEQUENCE cirugia_personal_id_cirugia_personal_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.cirugia_personal_id_cirugia_personal_seq TO admin;


--
-- Name: TABLE cita; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.cita TO admin;
GRANT SELECT ON TABLE public.cita TO visor;


--
-- Name: SEQUENCE cita_id_cita_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.cita_id_cita_seq TO admin;


--
-- Name: TABLE consentimiento_informado; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.consentimiento_informado TO admin;
GRANT SELECT ON TABLE public.consentimiento_informado TO visor;


--
-- Name: SEQUENCE consentimiento_informado_id_consentimiento_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.consentimiento_informado_id_consentimiento_seq TO admin;


--
-- Name: TABLE consulta; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.consulta TO admin;
GRANT SELECT ON TABLE public.consulta TO visor;


--
-- Name: SEQUENCE consulta_id_consulta_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.consulta_id_consulta_seq TO admin;


--
-- Name: TABLE departamento; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.departamento TO admin;
GRANT SELECT ON TABLE public.departamento TO visor;


--
-- Name: SEQUENCE departamento_id_departamento_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.departamento_id_departamento_seq TO admin;


--
-- Name: TABLE diagnostico; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.diagnostico TO admin;
GRANT SELECT ON TABLE public.diagnostico TO visor;


--
-- Name: SEQUENCE diagnostico_id_diagnostico_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.diagnostico_id_diagnostico_seq TO admin;


--
-- Name: TABLE documentacion_etapa; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.documentacion_etapa TO admin;
GRANT SELECT ON TABLE public.documentacion_etapa TO visor;


--
-- Name: TABLE egreso; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.egreso TO admin;
GRANT SELECT ON TABLE public.egreso TO visor;


--
-- Name: TABLE egreso_diagnostico; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.egreso_diagnostico TO admin;
GRANT SELECT ON TABLE public.egreso_diagnostico TO visor;


--
-- Name: SEQUENCE egreso_id_egreso_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.egreso_id_egreso_seq TO admin;


--
-- Name: TABLE encargado; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.encargado TO admin;
GRANT SELECT ON TABLE public.encargado TO visor;


--
-- Name: SEQUENCE encargado_id_encargado_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.encargado_id_encargado_seq TO admin;


--
-- Name: TABLE enfermero; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.enfermero TO admin;
GRANT SELECT ON TABLE public.enfermero TO visor;


--
-- Name: SEQUENCE enfermero_id_enfermero_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.enfermero_id_enfermero_seq TO admin;


--
-- Name: TABLE equipo; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.equipo TO admin;
GRANT SELECT ON TABLE public.equipo TO visor;


--
-- Name: SEQUENCE equipo_id_equipo_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.equipo_id_equipo_seq TO admin;


--
-- Name: TABLE especialidad; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.especialidad TO admin;
GRANT SELECT ON TABLE public.especialidad TO visor;


--
-- Name: SEQUENCE especialidad_id_especialidad_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.especialidad_id_especialidad_seq TO admin;


--
-- Name: TABLE estado_civil; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.estado_civil TO admin;
GRANT SELECT ON TABLE public.estado_civil TO visor;


--
-- Name: SEQUENCE estado_civil_id_estado_civil_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.estado_civil_id_estado_civil_seq TO admin;


--
-- Name: TABLE factura; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.factura TO admin;
GRANT SELECT ON TABLE public.factura TO visor;


--
-- Name: SEQUENCE factura_id_factura_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.factura_id_factura_seq TO admin;


--
-- Name: TABLE historia_clinica; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.historia_clinica TO admin;
GRANT SELECT ON TABLE public.historia_clinica TO visor;


--
-- Name: SEQUENCE historia_clinica_id_historia_clinica_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.historia_clinica_id_historia_clinica_seq TO admin;


--
-- Name: TABLE hospital; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.hospital TO admin;
GRANT SELECT ON TABLE public.hospital TO visor;


--
-- Name: SEQUENCE hospital_id_hospital_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.hospital_id_hospital_seq TO admin;


--
-- Name: TABLE hospitalizacion_insumo; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.hospitalizacion_insumo TO admin;
GRANT SELECT ON TABLE public.hospitalizacion_insumo TO visor;


--
-- Name: TABLE ingreso; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.ingreso TO admin;
GRANT SELECT ON TABLE public.ingreso TO visor;


--
-- Name: SEQUENCE ingreso_id_ingreso_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.ingreso_id_ingreso_seq TO admin;


--
-- Name: TABLE institucion_externa; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.institucion_externa TO admin;
GRANT SELECT ON TABLE public.institucion_externa TO visor;


--
-- Name: SEQUENCE institucion_externa_id_institucion_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.institucion_externa_id_institucion_seq TO admin;


--
-- Name: TABLE instrumento; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.instrumento TO admin;
GRANT SELECT ON TABLE public.instrumento TO visor;


--
-- Name: SEQUENCE instrumento_id_instrumento_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.instrumento_id_instrumento_seq TO admin;


--
-- Name: TABLE insumo; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.insumo TO admin;
GRANT SELECT ON TABLE public.insumo TO visor;


--
-- Name: SEQUENCE insumo_id_insumo_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.insumo_id_insumo_seq TO admin;


--
-- Name: TABLE medicamento; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.medicamento TO admin;
GRANT SELECT ON TABLE public.medicamento TO visor;


--
-- Name: SEQUENCE medicamento_id_medicamento_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.medicamento_id_medicamento_seq TO admin;


--
-- Name: TABLE medico; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.medico TO admin;
GRANT SELECT ON TABLE public.medico TO visor;


--
-- Name: SEQUENCE medico_id_medico_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.medico_id_medico_seq TO admin;


--
-- Name: TABLE metodo_pago; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.metodo_pago TO admin;
GRANT SELECT ON TABLE public.metodo_pago TO visor;


--
-- Name: SEQUENCE metodo_pago_id_metodo_pago_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.metodo_pago_id_metodo_pago_seq TO admin;


--
-- Name: TABLE municipio; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.municipio TO admin;
GRANT SELECT ON TABLE public.municipio TO visor;


--
-- Name: SEQUENCE municipio_id_municipio_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.municipio_id_municipio_seq TO admin;


--
-- Name: TABLE paciente; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.paciente TO admin;
GRANT SELECT ON TABLE public.paciente TO visor;


--
-- Name: TABLE paciente_encargado; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.paciente_encargado TO admin;
GRANT SELECT ON TABLE public.paciente_encargado TO visor;


--
-- Name: SEQUENCE paciente_id_paciente_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.paciente_id_paciente_seq TO admin;


--
-- Name: TABLE pago; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.pago TO admin;
GRANT SELECT ON TABLE public.pago TO visor;


--
-- Name: SEQUENCE pago_id_pago_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.pago_id_pago_seq TO admin;


--
-- Name: TABLE parentesco; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.parentesco TO admin;
GRANT SELECT ON TABLE public.parentesco TO visor;


--
-- Name: SEQUENCE parentesco_id_parentesco_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.parentesco_id_parentesco_seq TO admin;


--
-- Name: TABLE quirofano; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.quirofano TO admin;
GRANT SELECT ON TABLE public.quirofano TO visor;


--
-- Name: SEQUENCE quirofano_id_quirofano_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.quirofano_id_quirofano_seq TO admin;


--
-- Name: TABLE receta; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.receta TO admin;
GRANT SELECT ON TABLE public.receta TO visor;


--
-- Name: SEQUENCE receta_id_receta_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.receta_id_receta_seq TO admin;


--
-- Name: TABLE receta_medicamento; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.receta_medicamento TO admin;
GRANT SELECT ON TABLE public.receta_medicamento TO visor;


--
-- Name: TABLE registro_procedimiento; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.registro_procedimiento TO admin;
GRANT SELECT ON TABLE public.registro_procedimiento TO visor;


--
-- Name: SEQUENCE registro_procedimiento_id_registro_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.registro_procedimiento_id_registro_seq TO admin;


--
-- Name: TABLE requerimiento_equipo; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.requerimiento_equipo TO admin;
GRANT SELECT ON TABLE public.requerimiento_equipo TO visor;


--
-- Name: TABLE requerimiento_instrumento; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.requerimiento_instrumento TO admin;
GRANT SELECT ON TABLE public.requerimiento_instrumento TO visor;


--
-- Name: TABLE requerimiento_insumo; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.requerimiento_insumo TO admin;
GRANT SELECT ON TABLE public.requerimiento_insumo TO visor;


--
-- Name: TABLE rol_quirurgico; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.rol_quirurgico TO admin;
GRANT SELECT ON TABLE public.rol_quirurgico TO visor;


--
-- Name: SEQUENCE rol_quirurgico_id_rol_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.rol_quirurgico_id_rol_seq TO admin;


--
-- Name: TABLE servicio_atencion; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.servicio_atencion TO admin;
GRANT SELECT ON TABLE public.servicio_atencion TO visor;


--
-- Name: SEQUENCE servicio_atencion_id_servicio_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.servicio_atencion_id_servicio_seq TO admin;


--
-- Name: TABLE tipo_anestesia; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.tipo_anestesia TO admin;
GRANT SELECT ON TABLE public.tipo_anestesia TO visor;


--
-- Name: SEQUENCE tipo_anestesia_id_tipo_anestesia_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.tipo_anestesia_id_tipo_anestesia_seq TO admin;


--
-- Name: TABLE tipo_cirugia; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.tipo_cirugia TO admin;
GRANT SELECT ON TABLE public.tipo_cirugia TO visor;


--
-- Name: SEQUENCE tipo_cirugia_id_tipo_cirugia_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.tipo_cirugia_id_tipo_cirugia_seq TO admin;


--
-- Name: TABLE traslado; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.traslado TO admin;
GRANT SELECT ON TABLE public.traslado TO visor;


--
-- Name: SEQUENCE traslado_id_traslado_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.traslado_id_traslado_seq TO admin;


--
-- Name: TABLE turno_emergencia; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.turno_emergencia TO admin;
GRANT SELECT ON TABLE public.turno_emergencia TO visor;


--
-- Name: SEQUENCE turno_emergencia_id_turno_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.turno_emergencia_id_turno_seq TO admin;


--
-- Name: TABLE turno_medico; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.turno_medico TO admin;
GRANT SELECT ON TABLE public.turno_medico TO visor;


--
-- Name: TABLE unidad_medica; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.unidad_medica TO admin;
GRANT SELECT ON TABLE public.unidad_medica TO visor;


--
-- Name: SEQUENCE unidad_medica_id_unidad_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.unidad_medica_id_unidad_seq TO admin;


--
-- Name: TABLE v_cirugia; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.v_cirugia TO admin;
GRANT SELECT ON TABLE public.v_cirugia TO visor;


--
-- Name: TABLE v_consulta; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.v_consulta TO admin;
GRANT SELECT ON TABLE public.v_consulta TO visor;


--
-- Name: TABLE v_estancia; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.v_estancia TO admin;
GRANT SELECT ON TABLE public.v_estancia TO visor;


--
-- Name: TABLE v_factura; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.v_factura TO admin;
GRANT SELECT ON TABLE public.v_factura TO visor;


--
-- Name: TABLE v_paciente; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.v_paciente TO admin;
GRANT SELECT ON TABLE public.v_paciente TO visor;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT ALL ON SEQUENCES TO admin;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT ALL ON FUNCTIONS TO admin;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT SELECT ON TABLES TO visor;
ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT ALL ON TABLES TO admin;


--
-- PostgreSQL database dump complete
--

\unrestrict fgJUgfaaKt6lRmvmD5KqOd8LZq63L4BWBiYHjreDgEt8WWSgivO5MPFyRKwJssI

