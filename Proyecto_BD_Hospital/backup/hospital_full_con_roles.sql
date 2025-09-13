--
-- PostgreSQL database cluster dump
--

\restrict 5CSWRgOYnVryjIwrGSSKd650IOwukfdFVni8PBNjMjV7YkIUdMvk6Srg3d3bt0m

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE hospital;
ALTER ROLE hospital WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:rCdeSmqCoG2C6TO6aak6JA==$KRidFNo1iPj3lWwUjIKuj5W1kScuIQhYOoUj98eE4OI=:iu6SPKZJNQPj6nObiDLJjbloVTe+83YYl38//XMhUmY=';
CREATE ROLE usuario_admin;
ALTER ROLE usuario_admin WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:XguL10dGCyFh6KF+de6f8A==$F2eTAXps1M26kAPdKQasgsiBpp23eS33C+yRTalJ1EQ=:wlgSb1KxUM3HZnduilUGoYIf6cYmqGEYXsRbJVgQsuQ=';
CREATE ROLE usuario_auditoria;
ALTER ROLE usuario_auditoria WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:P0TrVyK4ZeV+ZWy4UvxhNw==$eN+//l5qNEQzn9UfT2xjVa3TpP3ZkmCnfL8oFOpAeko=:/h4bJOC/VHTP0Xv/BJhndiFovPd0/p0wGYqsraFyA1w=';

--
-- User Configurations
--








\unrestrict 5CSWRgOYnVryjIwrGSSKd650IOwukfdFVni8PBNjMjV7YkIUdMvk6Srg3d3bt0m

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict Z5yslyLhAibrEEHGW2cd5kKyTKkRw9VN2TlLuA9phroE5WTWrlhrAn9t9i9zIUe

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
-- PostgreSQL database dump complete
--

\unrestrict Z5yslyLhAibrEEHGW2cd5kKyTKkRw9VN2TlLuA9phroE5WTWrlhrAn9t9i9zIUe

--
-- Database "bd_prueba_restauracion" dump
--

--
-- PostgreSQL database dump
--

\restrict JuUPmZyufJI1EJXiGweyIXFhyLDHqDoCygb3LJ2xsFeBJ4tYJlHscoQdyXE3wPl

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
-- Name: bd_prueba_restauracion; Type: DATABASE; Schema: -; Owner: hospital
--

CREATE DATABASE bd_prueba_restauracion WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE bd_prueba_restauracion OWNER TO hospital;

\unrestrict JuUPmZyufJI1EJXiGweyIXFhyLDHqDoCygb3LJ2xsFeBJ4tYJlHscoQdyXE3wPl
\connect bd_prueba_restauracion
\restrict JuUPmZyufJI1EJXiGweyIXFhyLDHqDoCygb3LJ2xsFeBJ4tYJlHscoQdyXE3wPl

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
-- PostgreSQL database dump complete
--

\unrestrict JuUPmZyufJI1EJXiGweyIXFhyLDHqDoCygb3LJ2xsFeBJ4tYJlHscoQdyXE3wPl

--
-- Database "bd_z" dump
--

--
-- PostgreSQL database dump
--

\restrict 12zZuX6AQOuwOaneHwH0dtU04V954K8f41wQk5WlRZeSWwOYfQMNNSAJSaCsgiA

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
-- Name: bd_z; Type: DATABASE; Schema: -; Owner: hospital
--

CREATE DATABASE bd_z WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE bd_z OWNER TO hospital;

\unrestrict 12zZuX6AQOuwOaneHwH0dtU04V954K8f41wQk5WlRZeSWwOYfQMNNSAJSaCsgiA
\connect bd_z
\restrict 12zZuX6AQOuwOaneHwH0dtU04V954K8f41wQk5WlRZeSWwOYfQMNNSAJSaCsgiA

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: hospital
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO hospital;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: hospital
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agendamiento_quirurgico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.agendamiento_quirurgico (
    id_agendamiento integer NOT NULL,
    paciente_id integer NOT NULL,
    medico_cirujano_id integer NOT NULL,
    caracter character varying(15) NOT NULL,
    historia_clinica text,
    tipo_procedimiento text NOT NULL,
    tiempo_estimado_min smallint NOT NULL,
    tipo_anestesia character varying(80) NOT NULL,
    fecha_hora_solicitud timestamp with time zone NOT NULL,
    estado_solicitud character varying(15) NOT NULL,
    motivo_rechazo text,
    quirofano_solicitado_id integer,
    fecha_hora_agendada timestamp with time zone,
    CONSTRAINT agendamiento_quirurgico_caracter_check CHECK (((caracter)::text = ANY ((ARRAY['urgente'::character varying, 'programado'::character varying])::text[]))),
    CONSTRAINT agendamiento_quirurgico_estado_solicitud_check CHECK (((estado_solicitud)::text = ANY ((ARRAY['pendiente'::character varying, 'aprobada'::character varying, 'rechazada'::character varying])::text[])))
);


ALTER TABLE public.agendamiento_quirurgico OWNER TO hospital;

--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.agendamiento_quirurgico_id_agendamiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.agendamiento_quirurgico_id_agendamiento_seq OWNER TO hospital;

--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.agendamiento_quirurgico_id_agendamiento_seq OWNED BY public.agendamiento_quirurgico.id_agendamiento;


--
-- Name: camilla; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.camilla (
    id_camilla integer NOT NULL,
    hospital_id integer NOT NULL,
    unidad_id integer NOT NULL,
    numero character varying(10) NOT NULL,
    disponible boolean DEFAULT true NOT NULL
);


ALTER TABLE public.camilla OWNER TO hospital;

--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.camilla_id_camilla_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.camilla_id_camilla_seq OWNER TO hospital;

--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.camilla_id_camilla_seq OWNED BY public.camilla.id_camilla;


--
-- Name: chequeo_preanestesico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.chequeo_preanestesico (
    id_chequeo_preanestesico integer NOT NULL,
    agendamiento_id integer NOT NULL,
    clasificacion_asa character varying(5) NOT NULL,
    medico_asa_nombre character varying(150) NOT NULL,
    plan_anestesia text NOT NULL,
    anestesista_nombre character varying(150) NOT NULL,
    CONSTRAINT chequeo_preanestesico_clasificacion_asa_check CHECK (((clasificacion_asa)::text = ANY ((ARRAY['I'::character varying, 'II'::character varying, 'III'::character varying, 'IV'::character varying, 'V'::character varying, 'VI'::character varying])::text[])))
);


ALTER TABLE public.chequeo_preanestesico OWNER TO hospital;

--
-- Name: chequeo_preanestesico_id_chequeo_preanestesico_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.chequeo_preanestesico_id_chequeo_preanestesico_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chequeo_preanestesico_id_chequeo_preanestesico_seq OWNER TO hospital;

--
-- Name: chequeo_preanestesico_id_chequeo_preanestesico_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.chequeo_preanestesico_id_chequeo_preanestesico_seq OWNED BY public.chequeo_preanestesico.id_chequeo_preanestesico;


--
-- Name: cirugia; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cirugia (
    id_cirugia integer NOT NULL,
    agendamiento_id integer NOT NULL,
    quirofano_id integer NOT NULL,
    paciente_id integer NOT NULL,
    cirujano_id integer NOT NULL,
    ingreso_id integer,
    fecha_hora_inicio timestamp with time zone NOT NULL,
    fecha_hora_fin timestamp with time zone,
    condicion_evolucion character varying(25),
    estado character varying(20) NOT NULL,
    CONSTRAINT cirugia_condicion_evolucion_check CHECK (((condicion_evolucion)::text = ANY ((ARRAY['sin_complicaciones'::character varying, 'complicaciones'::character varying, 'complicaciones_graves'::character varying])::text[]))),
    CONSTRAINT cirugia_estado_check CHECK (((estado)::text = ANY ((ARRAY['preoperatorio'::character varying, 'intraoperatorio'::character varying, 'postoperatorio'::character varying, 'finalizada'::character varying])::text[])))
);


ALTER TABLE public.cirugia OWNER TO hospital;

--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.cirugia_id_cirugia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cirugia_id_cirugia_seq OWNER TO hospital;

--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.cirugia_id_cirugia_seq OWNED BY public.cirugia.id_cirugia;


--
-- Name: cirugia_insumo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cirugia_insumo (
    id_cirugia_insumo integer NOT NULL,
    cirugia_id integer NOT NULL,
    insumo_id integer NOT NULL,
    cantidad smallint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL
);


ALTER TABLE public.cirugia_insumo OWNER TO hospital;

--
-- Name: cirugia_insumo_id_cirugia_insumo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.cirugia_insumo_id_cirugia_insumo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cirugia_insumo_id_cirugia_insumo_seq OWNER TO hospital;

--
-- Name: cirugia_insumo_id_cirugia_insumo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.cirugia_insumo_id_cirugia_insumo_seq OWNED BY public.cirugia_insumo.id_cirugia_insumo;


--
-- Name: cirugia_personal; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cirugia_personal (
    id_cirugia_personal integer NOT NULL,
    cirugia_id integer NOT NULL,
    medico_id integer,
    enfermero_id integer,
    rol character varying(60) NOT NULL
);


ALTER TABLE public.cirugia_personal OWNER TO hospital;

--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.cirugia_personal_id_cirugia_personal_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cirugia_personal_id_cirugia_personal_seq OWNER TO hospital;

--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.cirugia_personal_id_cirugia_personal_seq OWNED BY public.cirugia_personal.id_cirugia_personal;


--
-- Name: cita; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cita (
    id_cita integer NOT NULL,
    paciente_id integer NOT NULL,
    medico_id integer NOT NULL,
    fecha_hora timestamp with time zone NOT NULL,
    num_clinica character varying(20) NOT NULL,
    medio_asignacion character varying(20),
    estado character varying(20) DEFAULT 'programada'::character varying NOT NULL,
    es_reconsulta boolean DEFAULT false NOT NULL,
    es_referido boolean DEFAULT false NOT NULL,
    costo_base numeric(10,2),
    costo_aplicado numeric(10,2),
    cancelada_sin_aviso boolean DEFAULT false NOT NULL,
    CONSTRAINT cita_estado_check CHECK (((estado)::text = ANY ((ARRAY['programada'::character varying, 'realizada'::character varying, 'reprogramada'::character varying, 'cancelada'::character varying])::text[]))),
    CONSTRAINT cita_medio_asignacion_check CHECK (((medio_asignacion)::text = ANY ((ARRAY['telefonico'::character varying, 'correo_institucional'::character varying, 'recepcion_general'::character varying, 'recepcion_medico'::character varying])::text[])))
);


ALTER TABLE public.cita OWNER TO hospital;

--
-- Name: cita_id_cita_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.cita_id_cita_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cita_id_cita_seq OWNER TO hospital;

--
-- Name: cita_id_cita_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.cita_id_cita_seq OWNED BY public.cita.id_cita;


--
-- Name: consentimiento_informado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.consentimiento_informado (
    id_consentimiento integer NOT NULL,
    agendamiento_id integer NOT NULL,
    procedimiento_nombre text NOT NULL,
    procedimiento_objetivo text NOT NULL,
    procedimiento_caracteristicas text NOT NULL,
    procedimiento_riesgos text NOT NULL,
    medico_nombre character varying(150) NOT NULL,
    medico_firmado boolean DEFAULT false NOT NULL,
    paciente_firma_nombre character varying(150) NOT NULL,
    paciente_firmado boolean DEFAULT false NOT NULL,
    fecha_obtencion date NOT NULL
);


ALTER TABLE public.consentimiento_informado OWNER TO hospital;

--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.consentimiento_informado_id_consentimiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.consentimiento_informado_id_consentimiento_seq OWNER TO hospital;

--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.consentimiento_informado_id_consentimiento_seq OWNED BY public.consentimiento_informado.id_consentimiento;


--
-- Name: consulta; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.consulta (
    id_consulta integer NOT NULL,
    cita_id integer NOT NULL,
    paciente_id integer NOT NULL,
    medico_id integer NOT NULL,
    fecha date NOT NULL,
    diagnostico text NOT NULL,
    otros_datos text,
    notas_observaciones text
);


ALTER TABLE public.consulta OWNER TO hospital;

--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.consulta_id_consulta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.consulta_id_consulta_seq OWNER TO hospital;

--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.consulta_id_consulta_seq OWNED BY public.consulta.id_consulta;


--
-- Name: departamento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.departamento (
    id_departamento integer NOT NULL,
    nombre character varying(80) NOT NULL
);


ALTER TABLE public.departamento OWNER TO hospital;

--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.departamento_id_departamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departamento_id_departamento_seq OWNER TO hospital;

--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.departamento_id_departamento_seq OWNED BY public.departamento.id_departamento;


--
-- Name: egreso; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.egreso (
    id_egreso integer NOT NULL,
    ingreso_id integer NOT NULL,
    diagnostico_principal text NOT NULL,
    diagnosticos_secundarios text,
    motivo_egreso text NOT NULL,
    unidad_id integer NOT NULL,
    servicio_id integer,
    fecha_hora_egreso timestamp with time zone NOT NULL,
    medico_id integer NOT NULL,
    camilla_id integer,
    codigo_egreso character varying(15) NOT NULL,
    egreso_sin_consentimiento boolean DEFAULT false NOT NULL,
    motivo_egreso_sin_consentimiento text,
    dias_hospitalizado smallint,
    codigo_traslado character varying(20),
    referido_otro_hospital boolean DEFAULT false NOT NULL,
    CONSTRAINT egreso_codigo_egreso_check CHECK (((codigo_egreso)::text = ANY ((ARRAY['vivo'::character varying, 'muerto'::character varying, 'embarazo'::character varying, 'parto'::character varying])::text[])))
);


ALTER TABLE public.egreso OWNER TO hospital;

--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.egreso_id_egreso_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.egreso_id_egreso_seq OWNER TO hospital;

--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.egreso_id_egreso_seq OWNED BY public.egreso.id_egreso;


--
-- Name: encargado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.encargado (
    id_encargado integer NOT NULL,
    nombre character varying(150) NOT NULL,
    dpi character varying(20),
    telefono character varying(20),
    municipio_id integer NOT NULL,
    area character varying(10) NOT NULL,
    CONSTRAINT encargado_area_check CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[])))
);


ALTER TABLE public.encargado OWNER TO hospital;

--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.encargado_id_encargado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.encargado_id_encargado_seq OWNER TO hospital;

--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.encargado_id_encargado_seq OWNED BY public.encargado.id_encargado;


--
-- Name: enfermero; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.enfermero (
    id_enfermero integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character varying(20) NOT NULL,
    telefono character varying(20),
    tipo character varying(30) NOT NULL,
    CONSTRAINT enfermero_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['registrado'::character varying, 'practicante_de_enfermeria'::character varying])::text[])))
);


ALTER TABLE public.enfermero OWNER TO hospital;

--
-- Name: enfermero_id_enfermero_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.enfermero_id_enfermero_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.enfermero_id_enfermero_seq OWNER TO hospital;

--
-- Name: enfermero_id_enfermero_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.enfermero_id_enfermero_seq OWNED BY public.enfermero.id_enfermero;


--
-- Name: equipo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.equipo (
    id_equipo integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    estado character varying(20) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT equipo_estado_check CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'en_uso'::character varying, 'en_mantenimiento'::character varying])::text[])))
);


ALTER TABLE public.equipo OWNER TO hospital;

--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.equipo_id_equipo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipo_id_equipo_seq OWNER TO hospital;

--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.equipo_id_equipo_seq OWNED BY public.equipo.id_equipo;


--
-- Name: especialidad; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.especialidad (
    id_especialidad integer NOT NULL,
    nombre character varying(80) NOT NULL
);


ALTER TABLE public.especialidad OWNER TO hospital;

--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.especialidad_id_especialidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.especialidad_id_especialidad_seq OWNER TO hospital;

--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.especialidad_id_especialidad_seq OWNED BY public.especialidad.id_especialidad;


--
-- Name: factura; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.factura (
    id_factura integer NOT NULL,
    paciente_id integer NOT NULL,
    fecha_emision timestamp with time zone NOT NULL,
    descripcion text NOT NULL,
    total numeric(10,2) NOT NULL,
    cita_id integer,
    ingreso_id integer,
    cirugia_id integer,
    CONSTRAINT factura_total_check CHECK ((total >= (0)::numeric))
);


ALTER TABLE public.factura OWNER TO hospital;

--
-- Name: factura_id_factura_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.factura_id_factura_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.factura_id_factura_seq OWNER TO hospital;

--
-- Name: factura_id_factura_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.factura_id_factura_seq OWNED BY public.factura.id_factura;


--
-- Name: historia_clinica; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.historia_clinica (
    id_historia_clinica integer NOT NULL,
    agendamiento_id integer NOT NULL,
    medico_id integer NOT NULL,
    fecha date NOT NULL,
    fuente_interrogatorio character varying(10) NOT NULL,
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
    CONSTRAINT historia_clinica_fuente_interrogatorio_check CHECK (((fuente_interrogatorio)::text = ANY ((ARRAY['directo'::character varying, 'indirecto'::character varying])::text[])))
);


ALTER TABLE public.historia_clinica OWNER TO hospital;

--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.historia_clinica_id_historia_clinica_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historia_clinica_id_historia_clinica_seq OWNER TO hospital;

--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.historia_clinica_id_historia_clinica_seq OWNED BY public.historia_clinica.id_historia_clinica;


--
-- Name: hospital; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.hospital (
    id_hospital integer NOT NULL,
    nombre character varying(120) NOT NULL,
    informacion_especifica text,
    direccion character varying(250) NOT NULL
);


ALTER TABLE public.hospital OWNER TO hospital;

--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.hospital_id_hospital_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_id_hospital_seq OWNER TO hospital;

--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.hospital_id_hospital_seq OWNED BY public.hospital.id_hospital;


--
-- Name: hospitalizacion_insumo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.hospitalizacion_insumo (
    id_hospitalizacion_insumo integer NOT NULL,
    ingreso_id integer NOT NULL,
    insumo_id integer NOT NULL,
    cantidad smallint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL
);


ALTER TABLE public.hospitalizacion_insumo OWNER TO hospital;

--
-- Name: hospitalizacion_insumo_id_hospitalizacion_insumo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq OWNER TO hospital;

--
-- Name: hospitalizacion_insumo_id_hospitalizacion_insumo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq OWNED BY public.hospitalizacion_insumo.id_hospitalizacion_insumo;


--
-- Name: ingreso; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.ingreso (
    id_ingreso integer NOT NULL,
    paciente_id integer NOT NULL,
    unidad_id integer NOT NULL,
    servicio_id integer,
    camilla_id integer,
    motivo_ingreso text NOT NULL,
    fecha_hora_ingreso timestamp with time zone NOT NULL,
    medico_encargado_id integer NOT NULL,
    diagnostico_presuntivo text
);


ALTER TABLE public.ingreso OWNER TO hospital;

--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.ingreso_id_ingreso_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ingreso_id_ingreso_seq OWNER TO hospital;

--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.ingreso_id_ingreso_seq OWNED BY public.ingreso.id_ingreso;


--
-- Name: instrumento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.instrumento (
    id_instrumento integer NOT NULL,
    nombre character varying(120) NOT NULL,
    tipo character varying(30) NOT NULL,
    estado character varying(20) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT instrumento_estado_check CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'en_uso'::character varying, 'en_mantenimiento'::character varying])::text[])))
);


ALTER TABLE public.instrumento OWNER TO hospital;

--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.instrumento_id_instrumento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.instrumento_id_instrumento_seq OWNER TO hospital;

--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.instrumento_id_instrumento_seq OWNED BY public.instrumento.id_instrumento;


--
-- Name: insumo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.insumo (
    id_insumo integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    material character varying(80),
    tipo character varying(20),
    unidad_medida character varying(20),
    costo_unitario numeric(10,2),
    stock_minimo integer,
    stock_actual integer,
    CONSTRAINT insumo_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['medico'::character varying, 'quirurgico'::character varying, 'otro'::character varying])::text[])))
);


ALTER TABLE public.insumo OWNER TO hospital;

--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.insumo_id_insumo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.insumo_id_insumo_seq OWNER TO hospital;

--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.insumo_id_insumo_seq OWNED BY public.insumo.id_insumo;


--
-- Name: medico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.medico (
    id_medico integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character varying(20) NOT NULL,
    telefono character varying(20),
    hospital_id integer NOT NULL,
    municipio_id integer NOT NULL,
    area character varying(10) NOT NULL,
    especialidad_id integer,
    tipo_medico character varying(20) NOT NULL,
    costo_primera_consulta numeric(10,2),
    horario_inicio time without time zone,
    horario_fin time without time zone,
    CONSTRAINT medico_area_check CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[]))),
    CONSTRAINT medico_tipo_medico_check CHECK (((tipo_medico)::text = ANY ((ARRAY['residente'::character varying, 'interno'::character varying, 'externo'::character varying, 'general'::character varying, 'especialista'::character varying])::text[])))
);


ALTER TABLE public.medico OWNER TO hospital;

--
-- Name: medico_id_medico_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.medico_id_medico_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medico_id_medico_seq OWNER TO hospital;

--
-- Name: medico_id_medico_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.medico_id_medico_seq OWNED BY public.medico.id_medico;


--
-- Name: municipio; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.municipio (
    id_municipio integer NOT NULL,
    departamento_id integer NOT NULL,
    nombre character varying(80) NOT NULL
);


ALTER TABLE public.municipio OWNER TO hospital;

--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.municipio_id_municipio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.municipio_id_municipio_seq OWNER TO hospital;

--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.municipio_id_municipio_seq OWNED BY public.municipio.id_municipio;


--
-- Name: paciente; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.paciente (
    id_paciente integer NOT NULL,
    codigo_expediente character varying(20) NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    fecha_nacimiento date NOT NULL,
    "edad_años" smallint NOT NULL,
    sexo character varying(10) NOT NULL,
    dpi character varying(20),
    telefono character varying(20),
    municipio_id integer NOT NULL,
    area character varying(10) NOT NULL,
    estado_civil character varying(30),
    no_seguro_social character varying(30),
    CONSTRAINT paciente_area_check CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[]))),
    CONSTRAINT "paciente_edad_años_check" CHECK ((("edad_años" >= 0) AND ("edad_años" <= 120))),
    CONSTRAINT paciente_sexo_check CHECK (((sexo)::text = ANY ((ARRAY['Masculino'::character varying, 'Femenino'::character varying])::text[])))
);


ALTER TABLE public.paciente OWNER TO hospital;

--
-- Name: paciente_encargado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.paciente_encargado (
    id_paciente_encargado integer NOT NULL,
    paciente_id integer NOT NULL,
    encargado_id integer NOT NULL,
    parentesco character varying(40) NOT NULL
);


ALTER TABLE public.paciente_encargado OWNER TO hospital;

--
-- Name: paciente_encargado_id_paciente_encargado_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.paciente_encargado_id_paciente_encargado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paciente_encargado_id_paciente_encargado_seq OWNER TO hospital;

--
-- Name: paciente_encargado_id_paciente_encargado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.paciente_encargado_id_paciente_encargado_seq OWNED BY public.paciente_encargado.id_paciente_encargado;


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.paciente_id_paciente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paciente_id_paciente_seq OWNER TO hospital;

--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.paciente_id_paciente_seq OWNED BY public.paciente.id_paciente;


--
-- Name: pago; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.pago (
    id_pago integer NOT NULL,
    factura_id integer NOT NULL,
    numero_cuota smallint NOT NULL,
    total_cuotas smallint NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha_pago date NOT NULL,
    CONSTRAINT pago_monto_check CHECK ((monto > (0)::numeric)),
    CONSTRAINT pago_numero_cuota_check CHECK (((numero_cuota >= 1) AND (numero_cuota <= 12))),
    CONSTRAINT pago_total_cuotas_check CHECK (((total_cuotas >= 1) AND (total_cuotas <= 12)))
);


ALTER TABLE public.pago OWNER TO hospital;

--
-- Name: pago_id_pago_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.pago_id_pago_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pago_id_pago_seq OWNER TO hospital;

--
-- Name: pago_id_pago_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.pago_id_pago_seq OWNED BY public.pago.id_pago;


--
-- Name: quirofano; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.quirofano (
    id_quirofano integer NOT NULL,
    hospital_id integer NOT NULL,
    numero character varying(10) NOT NULL,
    estado character varying(20) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT quirofano_estado_check CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'ocupado'::character varying, 'en_mantenimiento'::character varying])::text[])))
);


ALTER TABLE public.quirofano OWNER TO hospital;

--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.quirofano_id_quirofano_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quirofano_id_quirofano_seq OWNER TO hospital;

--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.quirofano_id_quirofano_seq OWNED BY public.quirofano.id_quirofano;


--
-- Name: receta; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.receta (
    id_receta integer NOT NULL,
    consulta_id integer NOT NULL,
    fecha date NOT NULL,
    proxima_cita date
);


ALTER TABLE public.receta OWNER TO hospital;

--
-- Name: receta_id_receta_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.receta_id_receta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.receta_id_receta_seq OWNER TO hospital;

--
-- Name: receta_id_receta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.receta_id_receta_seq OWNED BY public.receta.id_receta;


--
-- Name: receta_medicamento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.receta_medicamento (
    id_receta_medicamento integer NOT NULL,
    receta_id integer NOT NULL,
    medicamento_nombre character varying(120) NOT NULL,
    dosis character varying(60) NOT NULL,
    duracion character varying(60)
);


ALTER TABLE public.receta_medicamento OWNER TO hospital;

--
-- Name: receta_medicamento_id_receta_medicamento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.receta_medicamento_id_receta_medicamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.receta_medicamento_id_receta_medicamento_seq OWNER TO hospital;

--
-- Name: receta_medicamento_id_receta_medicamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.receta_medicamento_id_receta_medicamento_seq OWNED BY public.receta_medicamento.id_receta_medicamento;


--
-- Name: registro_procedimiento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.registro_procedimiento (
    id_registro_procedimiento integer NOT NULL,
    cirugia_id integer NOT NULL,
    etapa character varying(20) NOT NULL,
    aspecto character varying(60) NOT NULL,
    exito boolean NOT NULL,
    descripcion text,
    hora_registro timestamp with time zone NOT NULL,
    enfermero_id integer NOT NULL,
    fecha_documentacion date,
    CONSTRAINT registro_procedimiento_etapa_check CHECK (((etapa)::text = ANY ((ARRAY['preoperatorio'::character varying, 'intraoperatorio'::character varying, 'postoperatorio'::character varying])::text[])))
);


ALTER TABLE public.registro_procedimiento OWNER TO hospital;

--
-- Name: registro_procedimiento_id_registro_procedimiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.registro_procedimiento_id_registro_procedimiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.registro_procedimiento_id_registro_procedimiento_seq OWNER TO hospital;

--
-- Name: registro_procedimiento_id_registro_procedimiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.registro_procedimiento_id_registro_procedimiento_seq OWNED BY public.registro_procedimiento.id_registro_procedimiento;


--
-- Name: requerimiento_quirurgico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.requerimiento_quirurgico (
    id_requerimiento integer NOT NULL,
    agendamiento_id integer NOT NULL,
    tipo_recurso character varying(20) NOT NULL,
    insumo_id integer,
    instrumento_id integer,
    equipo_id integer,
    cantidad smallint NOT NULL,
    CONSTRAINT requerimiento_quirurgico_check CHECK (((((tipo_recurso)::text = 'insumo'::text) AND (insumo_id IS NOT NULL) AND (instrumento_id IS NULL) AND (equipo_id IS NULL)) OR (((tipo_recurso)::text = 'instrumento'::text) AND (instrumento_id IS NOT NULL) AND (insumo_id IS NULL) AND (equipo_id IS NULL)) OR (((tipo_recurso)::text = 'equipo'::text) AND (equipo_id IS NOT NULL) AND (insumo_id IS NULL) AND (instrumento_id IS NULL)))),
    CONSTRAINT requerimiento_quirurgico_tipo_recurso_check CHECK (((tipo_recurso)::text = ANY ((ARRAY['insumo'::character varying, 'instrumento'::character varying, 'equipo'::character varying])::text[])))
);


ALTER TABLE public.requerimiento_quirurgico OWNER TO hospital;

--
-- Name: requerimiento_quirurgico_id_requerimiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.requerimiento_quirurgico_id_requerimiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.requerimiento_quirurgico_id_requerimiento_seq OWNER TO hospital;

--
-- Name: requerimiento_quirurgico_id_requerimiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.requerimiento_quirurgico_id_requerimiento_seq OWNED BY public.requerimiento_quirurgico.id_requerimiento;


--
-- Name: servicio_atencion; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.servicio_atencion (
    id_servicio integer NOT NULL,
    unidad_id integer NOT NULL,
    nombre character varying(80) NOT NULL,
    costo numeric(10,2)
);


ALTER TABLE public.servicio_atencion OWNER TO hospital;

--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.servicio_atencion_id_servicio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.servicio_atencion_id_servicio_seq OWNER TO hospital;

--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.servicio_atencion_id_servicio_seq OWNED BY public.servicio_atencion.id_servicio;


--
-- Name: traslado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.traslado (
    id_traslado integer NOT NULL,
    fecha_hora timestamp with time zone NOT NULL,
    paciente_id integer NOT NULL,
    medico_indica_id integer NOT NULL,
    unidad_origen_id integer NOT NULL,
    unidad_destino_id integer NOT NULL,
    interno_externo character varying(10) NOT NULL,
    hospital_externo_nombre character varying(120),
    hospital_externo_direccion character varying(250),
    ingreso_id integer,
    consulta_id integer,
    CONSTRAINT traslado_interno_externo_check CHECK (((interno_externo)::text = ANY ((ARRAY['interno'::character varying, 'externo'::character varying])::text[])))
);


ALTER TABLE public.traslado OWNER TO hospital;

--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.traslado_id_traslado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.traslado_id_traslado_seq OWNER TO hospital;

--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.traslado_id_traslado_seq OWNED BY public.traslado.id_traslado;


--
-- Name: unidad_medica; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.unidad_medica (
    id_unidad integer NOT NULL,
    hospital_id integer NOT NULL,
    nombre character varying(40) NOT NULL,
    costo_dia_hospitalizacion numeric(10,2),
    CONSTRAINT unidad_medica_nombre_check CHECK (((nombre)::text = ANY ((ARRAY['Consulta Externa'::character varying, 'Emergencias'::character varying, 'Cirugia'::character varying, 'Hospitalizacion'::character varying, 'Otro'::character varying])::text[])))
);


ALTER TABLE public.unidad_medica OWNER TO hospital;

--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.unidad_medica_id_unidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.unidad_medica_id_unidad_seq OWNER TO hospital;

--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.unidad_medica_id_unidad_seq OWNED BY public.unidad_medica.id_unidad;


--
-- Name: agendamiento_quirurgico id_agendamiento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico ALTER COLUMN id_agendamiento SET DEFAULT nextval('public.agendamiento_quirurgico_id_agendamiento_seq'::regclass);


--
-- Name: camilla id_camilla; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla ALTER COLUMN id_camilla SET DEFAULT nextval('public.camilla_id_camilla_seq'::regclass);


--
-- Name: chequeo_preanestesico id_chequeo_preanestesico; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico ALTER COLUMN id_chequeo_preanestesico SET DEFAULT nextval('public.chequeo_preanestesico_id_chequeo_preanestesico_seq'::regclass);


--
-- Name: cirugia id_cirugia; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia ALTER COLUMN id_cirugia SET DEFAULT nextval('public.cirugia_id_cirugia_seq'::regclass);


--
-- Name: cirugia_insumo id_cirugia_insumo; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo ALTER COLUMN id_cirugia_insumo SET DEFAULT nextval('public.cirugia_insumo_id_cirugia_insumo_seq'::regclass);


--
-- Name: cirugia_personal id_cirugia_personal; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal ALTER COLUMN id_cirugia_personal SET DEFAULT nextval('public.cirugia_personal_id_cirugia_personal_seq'::regclass);


--
-- Name: cita id_cita; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita ALTER COLUMN id_cita SET DEFAULT nextval('public.cita_id_cita_seq'::regclass);


--
-- Name: consentimiento_informado id_consentimiento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consentimiento_informado ALTER COLUMN id_consentimiento SET DEFAULT nextval('public.consentimiento_informado_id_consentimiento_seq'::regclass);


--
-- Name: consulta id_consulta; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta ALTER COLUMN id_consulta SET DEFAULT nextval('public.consulta_id_consulta_seq'::regclass);


--
-- Name: departamento id_departamento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.departamento ALTER COLUMN id_departamento SET DEFAULT nextval('public.departamento_id_departamento_seq'::regclass);


--
-- Name: egreso id_egreso; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso ALTER COLUMN id_egreso SET DEFAULT nextval('public.egreso_id_egreso_seq'::regclass);


--
-- Name: encargado id_encargado; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.encargado ALTER COLUMN id_encargado SET DEFAULT nextval('public.encargado_id_encargado_seq'::regclass);


--
-- Name: enfermero id_enfermero; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.enfermero ALTER COLUMN id_enfermero SET DEFAULT nextval('public.enfermero_id_enfermero_seq'::regclass);


--
-- Name: equipo id_equipo; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.equipo ALTER COLUMN id_equipo SET DEFAULT nextval('public.equipo_id_equipo_seq'::regclass);


--
-- Name: especialidad id_especialidad; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.especialidad ALTER COLUMN id_especialidad SET DEFAULT nextval('public.especialidad_id_especialidad_seq'::regclass);


--
-- Name: factura id_factura; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura ALTER COLUMN id_factura SET DEFAULT nextval('public.factura_id_factura_seq'::regclass);


--
-- Name: historia_clinica id_historia_clinica; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica ALTER COLUMN id_historia_clinica SET DEFAULT nextval('public.historia_clinica_id_historia_clinica_seq'::regclass);


--
-- Name: hospital id_hospital; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospital ALTER COLUMN id_hospital SET DEFAULT nextval('public.hospital_id_hospital_seq'::regclass);


--
-- Name: hospitalizacion_insumo id_hospitalizacion_insumo; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo ALTER COLUMN id_hospitalizacion_insumo SET DEFAULT nextval('public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq'::regclass);


--
-- Name: ingreso id_ingreso; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso ALTER COLUMN id_ingreso SET DEFAULT nextval('public.ingreso_id_ingreso_seq'::regclass);


--
-- Name: instrumento id_instrumento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.instrumento ALTER COLUMN id_instrumento SET DEFAULT nextval('public.instrumento_id_instrumento_seq'::regclass);


--
-- Name: insumo id_insumo; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.insumo ALTER COLUMN id_insumo SET DEFAULT nextval('public.insumo_id_insumo_seq'::regclass);


--
-- Name: medico id_medico; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico ALTER COLUMN id_medico SET DEFAULT nextval('public.medico_id_medico_seq'::regclass);


--
-- Name: municipio id_municipio; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.municipio ALTER COLUMN id_municipio SET DEFAULT nextval('public.municipio_id_municipio_seq'::regclass);


--
-- Name: paciente id_paciente; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente ALTER COLUMN id_paciente SET DEFAULT nextval('public.paciente_id_paciente_seq'::regclass);


--
-- Name: paciente_encargado id_paciente_encargado; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado ALTER COLUMN id_paciente_encargado SET DEFAULT nextval('public.paciente_encargado_id_paciente_encargado_seq'::regclass);


--
-- Name: pago id_pago; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago ALTER COLUMN id_pago SET DEFAULT nextval('public.pago_id_pago_seq'::regclass);


--
-- Name: quirofano id_quirofano; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano ALTER COLUMN id_quirofano SET DEFAULT nextval('public.quirofano_id_quirofano_seq'::regclass);


--
-- Name: receta id_receta; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta ALTER COLUMN id_receta SET DEFAULT nextval('public.receta_id_receta_seq'::regclass);


--
-- Name: receta_medicamento id_receta_medicamento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta_medicamento ALTER COLUMN id_receta_medicamento SET DEFAULT nextval('public.receta_medicamento_id_receta_medicamento_seq'::regclass);


--
-- Name: registro_procedimiento id_registro_procedimiento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento ALTER COLUMN id_registro_procedimiento SET DEFAULT nextval('public.registro_procedimiento_id_registro_procedimiento_seq'::regclass);


--
-- Name: requerimiento_quirurgico id_requerimiento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico ALTER COLUMN id_requerimiento SET DEFAULT nextval('public.requerimiento_quirurgico_id_requerimiento_seq'::regclass);


--
-- Name: servicio_atencion id_servicio; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion ALTER COLUMN id_servicio SET DEFAULT nextval('public.servicio_atencion_id_servicio_seq'::regclass);


--
-- Name: traslado id_traslado; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado ALTER COLUMN id_traslado SET DEFAULT nextval('public.traslado_id_traslado_seq'::regclass);


--
-- Name: unidad_medica id_unidad; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica ALTER COLUMN id_unidad SET DEFAULT nextval('public.unidad_medica_id_unidad_seq'::regclass);


--
-- Data for Name: agendamiento_quirurgico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.agendamiento_quirurgico (id_agendamiento, paciente_id, medico_cirujano_id, caracter, historia_clinica, tipo_procedimiento, tiempo_estimado_min, tipo_anestesia, fecha_hora_solicitud, estado_solicitud, motivo_rechazo, quirofano_solicitado_id, fecha_hora_agendada) FROM stdin;
1	5	1006	urgente	Apendicitis aguda confirmada por ecografía.	Apendicectomía abierta	90	General	2026-08-11 17:00:00+00	aprobada	\N	2	2026-08-12 00:30:00+00
2	7	1009	programado	Carcinoma colorrectal en estudio.	Resección oncológica de colon	160	General	2026-08-13 15:00:00+00	rechazada	El comité recomienda completar estudios de imagen y control nutricional previo a la intervención.	3	\N
3	6	1007	programado	Enfermedad valvular aórtica con estenosis severa.	Revascularización miocárdica	180	General	2026-09-08 16:00:00+00	pendiente	\N	\N	\N
\.


--
-- Data for Name: camilla; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.camilla (id_camilla, hospital_id, unidad_id, numero, disponible) FROM stdin;
1	1	14	1	t
2	1	14	2	t
3	1	14	3	t
4	1	14	4	t
5	1	14	5	t
6	1	14	6	t
7	1	14	7	t
8	1	14	8	t
9	1	14	9	t
10	1	14	10	t
11	1	14	11	t
12	1	14	12	t
13	1	14	13	t
14	1	14	14	t
15	1	14	15	t
16	1	14	16	t
17	1	14	17	t
18	1	14	18	t
19	1	14	19	t
20	1	14	20	t
21	1	14	21	t
22	1	14	22	t
23	1	14	23	t
24	1	14	24	t
\.


--
-- Data for Name: chequeo_preanestesico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.chequeo_preanestesico (id_chequeo_preanestesico, agendamiento_id, clasificacion_asa, medico_asa_nombre, plan_anestesia, anestesista_nombre) FROM stdin;
1	1	II	Alejandro Ramírez Lemus	Inducción con propofol, mantenimiento con sevoflurano, analgesia con morfina.	Daniel Morales Peña
\.


--
-- Data for Name: cirugia; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cirugia (id_cirugia, agendamiento_id, quirofano_id, paciente_id, cirujano_id, ingreso_id, fecha_hora_inicio, fecha_hora_fin, condicion_evolucion, estado) FROM stdin;
1	1	2	5	1006	4	2026-08-12 00:40:00+00	2026-08-12 02:10:00+00	sin_complicaciones	finalizada
\.


--
-- Data for Name: cirugia_insumo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cirugia_insumo (id_cirugia_insumo, cirugia_id, insumo_id, cantidad, costo_unitario) FROM stdin;
1	1	1	2	30.00
2	1	2	1	25.00
3	1	4	10	8.00
4	1	5	8	15.00
5	1	6	2	120.00
6	1	7	3	70.00
\.


--
-- Data for Name: cirugia_personal; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cirugia_personal (id_cirugia_personal, cirugia_id, medico_id, enfermero_id, rol) FROM stdin;
1	1	1006	\N	Cirujano
2	1	1008	\N	Anestesiólogo
3	1	\N	2001	Enfermero instrumentista
4	1	\N	2003	Enfermero circulante
\.


--
-- Data for Name: cita; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cita (id_cita, paciente_id, medico_id, fecha_hora, num_clinica, medio_asignacion, estado, es_reconsulta, es_referido, costo_base, costo_aplicado, cancelada_sin_aviso) FROM stdin;
1	1	1002	2026-08-10 15:00:00+00	A-101	telefonico	realizada	t	f	220.00	165.00	f
2	2	1003	2026-08-12 16:30:00+00	A-205	recepcion_general	reprogramada	f	f	160.00	160.00	f
3	4	1004	2026-08-15 14:30:00+00	B-110	telefonico	cancelada	f	f	180.00	198.00	t
4	6	1002	2026-09-20 15:30:00+00	A-101	correo_institucional	programada	f	t	220.00	176.00	f
5	5	1005	2026-08-11 15:15:00+00	A-108	recepcion_medico	realizada	f	f	180.00	180.00	f
\.


--
-- Data for Name: consentimiento_informado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.consentimiento_informado (id_consentimiento, agendamiento_id, procedimiento_nombre, procedimiento_objetivo, procedimiento_caracteristicas, procedimiento_riesgos, medico_nombre, medico_firmado, paciente_firma_nombre, paciente_firmado, fecha_obtencion) FROM stdin;
1	1	Apendicectomía abierta	Resección del apéndice inflamado para evitar perforación y peritonitis.	Incisión en fosa ilíaca derecha, ligadura y extirpación del apéndice, cierre por planos, bajo anestesia general.	Sangrado, infección de herida, lesión de estructuras vecinas, complicaciones anestésicas.	Alejandro Ramírez Lemus	t	Carlos De León Ortiz	t	2026-08-11
\.


--
-- Data for Name: consulta; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.consulta (id_consulta, cita_id, paciente_id, medico_id, fecha, diagnostico, otros_datos, notas_observaciones) FROM stdin;
1	1	1	1002	2026-08-10	Hipertensión arterial controlada en tratamiento.	Seguimiento a estudio cardiológico de 2025.	Paciente estable; continuar tratamiento y control en 30 días.
2	5	5	1005	2026-08-11	Sospecha de apendicitis aguda.	Dolor abdominal en fosa ilíaca derecha, mayor de 6 horas.	Se solicita valoración quirúrgica de urgencia; requiere hospitalización.
\.


--
-- Data for Name: departamento; Type: TABLE DATA; Schema: public; Owner: hospital
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
-- Data for Name: egreso; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.egreso (id_egreso, ingreso_id, diagnostico_principal, diagnosticos_secundarios, motivo_egreso, unidad_id, servicio_id, fecha_hora_egreso, medico_id, camilla_id, codigo_egreso, egreso_sin_consentimiento, motivo_egreso_sin_consentimiento, dias_hospitalizado, codigo_traslado, referido_otro_hospital) FROM stdin;
1	1	Politraumatismo; fractura de brazo derecho.	Traumatismo craneoencefálico leve.	Mejoría clínica.	12	3	2026-08-12 16:00:00+00	1001	1	vivo	f	\N	3	\N	f
2	3	Hipertensión arterial descompensada controlada.	\N	Estabilización y mejoría.	14	9	2026-08-18 15:30:00+00	1005	3	vivo	f	\N	4	\N	f
3	5	Postoperatorio de apendicectomía sin complicaciones.	\N	Recuperación satisfactoria.	14	15	2026-08-14 17:30:00+00	1006	4	vivo	f	\N	3	\N	f
\.


--
-- Data for Name: encargado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.encargado (id_encargado, nombre, dpi, telefono, municipio_id, area) FROM stdin;
301	Isabel Cruz López	8881123450101	5551-3001	1	Urbana
302	Roberto Méndez Rodríguez	8881123450102	5551-3002	1	Urbana
303	Karla Paz Veliz	8881123450103	5551-3003	6	Urbana
\.


--
-- Data for Name: enfermero; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.enfermero (id_enfermero, nombres, apellidos, dpi, telefono, tipo) FROM stdin;
2001	Luis	Hernández Solís	2001123450201	5552-2001	registrado
2002	Marta	Recinos Alvarado	2001123450202	5552-2002	registrado
2003	Carlos	García Méndez	2001123450203	5552-2003	practicante_de_enfermeria
2004	Ana	López Pérez	2001123450204	5552-2004	registrado
2005	Pedro	Ramírez Soto	2001123450205	5552-2005	registrado
\.


--
-- Data for Name: equipo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.equipo (id_equipo, nombre, descripcion, estado) FROM stdin;
1	Monitor de signos vitales	Monitor multiparamétrico 5 derivaciones	disponible
2	Ventilador mecánico	Ventilador de cuidados críticos	disponible
3	Bomba de infusión	Bomba de infusión volumétrica	disponible
4	Desfibrilador	Desfibrilador monitor	disponible
5	Arco en C	Arco en C móvil para fluoroscopia	disponible
6	Microscopio quirúrgico	Microscopio para neurocirugía	disponible
7	Lámpara de cirugía LED	Lámpara quirúrgica LED de alta intensidad	disponible
8	Mesa de operaciones	Mesa quirúrgica electromecánica	disponible
\.


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.especialidad (id_especialidad, nombre) FROM stdin;
301	Cardiología
302	Dermatología
303	Fisioterapia
304	Ginecología Oncológica
305	Hematología
306	Medicina Física y Rehabilitación
307	Medicina General
308	Nutrición y Dietética
309	Odontología General
310	Oftalmología
311	Psicología
312	Pediatría
313	Urología
314	Terapia del Lenguaje
315	Cirugía General
316	Cirugía Cardiovascular
317	Cirugía Oncológica
318	Anestesiología
319	Cirugía de la Mano
320	Videolaparoscopia Quirúrgica
321	Cirugía Ginecológica
322	Cirugía Neurológica
323	Cirugía Oftalmológica
324	Cirugía Ortopédica
325	Cirugía Otorrinolaringológica
326	Cirugía Pediátrica
327	Cirugía Plástica
328	Cirugía de Tórax
329	Cirugía Urológica
330	Nueva
\.


--
-- Data for Name: factura; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.factura (id_factura, paciente_id, fecha_emision, descripcion, total, cita_id, ingreso_id, cirugia_id) FROM stdin;
1	1	2026-08-10 17:30:00+00	Consulta de cardiología; reconsulta (75%).	165.00	1	\N	\N
2	3	2026-08-12 16:30:00+00	Atención de emergencia por politraumatismo; servicio de atención a pacientes politraumatizados.	1800.00	\N	1	\N
3	2	2026-08-18 15:45:00+00	Hospitalización 4 días: medicina interna + insumos médicos.	4390.00	\N	3	\N
4	5	2026-08-12 14:00:00+00	Cirugía: apendicectomía (cirugía general) + insumos utilizados.	9235.00	\N	\N	1
5	5	2026-08-14 18:00:00+00	Hospitalización postoperatoria: 3 días en cuidados intermedios + insumos.	3870.00	\N	5	\N
\.


--
-- Data for Name: historia_clinica; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.historia_clinica (id_historia_clinica, agendamiento_id, medico_id, fecha, fuente_interrogatorio, religion, ocupacion, lugar_nacimiento, lugar_residencia, antecedentes_heredofamiliares, antecedentes_personales_no_patologicos, antecedentes_patologicos, padecimiento_actual, interrogatorio_aparatos_sistemas, sintomas_generales_terapeutica, estudios_previos, signos_vitales, exploracion_general, exploracion_sistematizada) FROM stdin;
1	1	1006	2026-08-11	directo	Católica	Comerciante	Olintepeque, Quetzaltenango	Olintepeque, Quetzaltenango	Cardiopatía isquémica en padre; hipertensión en madre.	No fumador; consumo de alcohol ocasional; alimentación sin restricciones.	Ninguno conocido.	Dolor abdominal en fosa ilíaca derecha desde hace 8 horas, con náuseas.	Dolor intenso localizado, sin irradiación.	Paciente no había iniciado antibióticos previo a consulta.	Ecografía abdominal: líquido libre y engrosamiento apendicular.	TA 120/80, FC 92, T° 37.8.	Abdomen blando, doloroso a palpación en fosa ilíaca derecha.	Cabeza y cuello sin alteraciones; tórax y abdomen según lo referido; extremidades sin déficit motor.
\.


--
-- Data for Name: hospital; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.hospital (id_hospital, nombre, informacion_especifica, direccion) FROM stdin;
1	Hospital General de Occidente	Hospital general de tercer nivel; 4 quirófanos y 24 camillas de hospitalización.	15 Av. 6-45, zona 3, Quetzaltenango
2	Hospital Regional de San Marcos	Hospital de referencia regional para el departamento de San Marcos.	7a. calle 4-10, zona 2, San Marcos
3	Hospital Infantil de Retalhuleu	Hospital especializado en atención pediátrica.	Boulevard El Malecón, zona 1, Retalhuleu
\.


--
-- Data for Name: hospitalizacion_insumo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.hospitalizacion_insumo (id_hospitalizacion_insumo, ingreso_id, insumo_id, cantidad, costo_unitario) FROM stdin;
1	3	1	8	30.00
2	3	8	10	15.00
3	5	1	6	30.00
4	5	8	6	15.00
\.


--
-- Data for Name: ingreso; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.ingreso (id_ingreso, paciente_id, unidad_id, servicio_id, camilla_id, motivo_ingreso, fecha_hora_ingreso, medico_encargado_id, diagnostico_presuntivo) FROM stdin;
1	3	12	3	1	Politraumatismo por accidente de tránsito.	2026-08-10 04:10:00+00	1001	Traumatismo craneoencefálico leve; fractura de brazo derecho.
2	4	12	5	2	Fiebre alta persistente y deshidratación.	2026-08-20 20:05:00+00	1005	Cuadro febril viral en observación.
3	2	14	9	3	Hipertensión arterial descompensada.	2026-08-14 17:00:00+00	1005	Crisis hipertensiva en estudio.
4	5	13	17	\N	Ingreso a quirófano para apendicectomía de urgencia.	2026-08-12 00:35:00+00	1006	Apendicitis aguda.
5	5	14	15	4	Sala de recuperación postquirúrgica tras apendicectomía.	2026-08-12 03:00:00+00	1006	Postoperatorio de apendicectomía.
\.


--
-- Data for Name: instrumento; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.instrumento (id_instrumento, nombre, tipo, estado) FROM stdin;
1	Pinza Kelly	hemostasia	disponible
2	Pinza Mosquito	hemostasia	disponible
3	Porta agujas Mayo-Hegar	sutura	disponible
4	Tijera Mayo	corte	disponible
5	Tijera Metzenbaum	corte	disponible
6	Separador Farabeuf	separacion	disponible
7	Cuchillo de bisturí #3	corte	disponible
8	Aspirador quirúrgico	aspiración	disponible
9	Electrobisturí	coagulación	disponible
10	Lámpara de cirugía	iluminación	disponible
\.


--
-- Data for Name: insumo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.insumo (id_insumo, nombre, descripcion, material, tipo, unidad_medida, costo_unitario, stock_minimo, stock_actual) FROM stdin;
1	Gasas estériles 10x10	\N	\N	\N	paquete	15.00	50	120
2	Guantes quirúrgicos látex	\N	\N	\N	caja	85.00	30	80
3	Suero fisiológico 1L	\N	\N	\N	bolsa	12.00	40	100
4	Jeringa desechable 5ml	\N	\N	\N	unidad	2.50	100	300
5	Catéter venoso central	\N	\N	\N	unidad	45.00	10	25
6	Bisturí #10	\N	\N	\N	unidad	8.00	20	50
7	Hilo vicryl 3-0	\N	\N	\N	unidad	35.00	15	40
8	Algodón hidrófilo 100g	\N	\N	\N	rollo	18.00	25	60
9	Betadine solución 500ml	\N	\N	\N	frasco	55.00	10	30
10	Guantes de examen nitrilo	\N	\N	\N	caja	70.00	20	50
\.


--
-- Data for Name: medico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.medico (id_medico, nombres, apellidos, dpi, telefono, hospital_id, municipio_id, area, especialidad_id, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin) FROM stdin;
1001	Carmen	Ruiz Palacios	2001123450101	5551-2001	1	1	Urbana	307	general	200.00	08:00:00	12:00:00
1002	Roberto	Castillo Méndez	2001123450102	5551-2002	1	3	Urbana	301	especialista	220.00	08:00:00	11:30:00
1003	Andrea	Soto Fuentes	2001123450103	5551-2003	1	6	Rural	303	especialista	160.00	09:00:00	12:00:00
1004	Julia	Paredes Ovalle	2001123450104	5551-2004	1	1	Urbana	312	especialista	180.00	08:00:00	12:00:00
1005	Miguel	Barrios Donis	2001123450105	5551-2005	1	2	Rural	307	general	180.00	08:00:00	12:00:00
1006	Alejandro	Ramírez Lemus	2001123450106	5551-2006	1	1	Urbana	315	residente	\N	\N	\N
1007	Hilda	Cifuentes Rojas	2001123450107	5551-2007	2	6	Urbana	316	externo	\N	\N	\N
1008	Daniel	Morales Peña	2001123450108	5551-2008	1	1	Urbana	318	interno	\N	\N	\N
1009	Silvia	Vásquez Cotero	2001123450109	5551-2009	3	7	Urbana	317	especialista	\N	\N	\N
1010	Elena	Vasquez Sotelo	2001123450110	5551-2010	1	1	Urbana	302	especialista	180.00	08:00:00	12:00:00
1011	Marcos	Aguilar Salazar	2001123450111	5551-2011	1	1	Urbana	304	especialista	210.00	09:00:00	12:00:00
1012	Gabriela	Nájera	2001123450112	5551-2012	2	6	Urbana	305	especialista	195.00	08:00:00	11:30:00
1013	Fernando	López	2001123450113	5551-2013	1	3	Urbana	306	especialista	175.00	09:00:00	12:00:00
1014	Claudia	Recinos	2001123450114	5551-2014	2	6	Urbana	308	especialista	150.00	08:00:00	12:00:00
1015	Andrés	Chinchilla	2001123450115	5551-2015	1	1	Urbana	309	general	130.00	08:00:00	12:00:00
1016	Paola	Sandoval	2001123450116	5551-2016	3	7	Urbana	310	especialista	185.00	08:00:00	12:00:00
1017	Ricardo	Batz	2001123450117	5551-2017	1	1	Urbana	311	especialista	165.00	09:00:00	12:00:00
1018	Silvia	Gómez	2001123450118	5551-2018	1	3	Urbana	314	especialista	140.00	08:00:00	12:00:00
1019	Julio	Estrada	2001123450119	5551-2019	2	6	Urbana	313	especialista	190.00	08:00:00	12:00:00
1020	René	Iguarán	2001123450120	5551-2020	1	1	Urbana	319	externo	\N	\N	\N
1021	Wilfredo	Chávez	2001123450121	5551-2021	2	6	Urbana	320	externo	\N	\N	\N
1022	Ana	Lucero	2001123450122	5551-2022	3	1	Urbana	321	externo	\N	\N	\N
1023	Héctor	Quirós	2001123450123	5551-2023	1	3	Urbana	322	externo	\N	\N	\N
1024	Verónica	Aranda	2001123450124	5551-2024	2	1	Urbana	323	externo	\N	\N	\N
1025	Gustavo	Rivas	2001123450125	5551-2025	3	7	Urbana	324	externo	\N	\N	\N
1026	Mónica	Figueroa	2001123450126	5551-2026	1	1	Urbana	325	externo	\N	\N	\N
1027	Pablo	Tzoc	2001123450127	5551-2027	2	6	Urbana	326	externo	\N	\N	\N
1028	Isabel	Contreras	2001123450128	5551-2028	3	1	Urbana	327	externo	\N	\N	\N
1029	Carlos	Menández	2001123450129	5551-2029	1	3	Urbana	328	externo	\N	\N	\N
1030	Luis	Zambrano	2001123450130	5551-2030	2	6	Urbana	329	externo	\N	\N	\N
\.


--
-- Data for Name: municipio; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.municipio (id_municipio, departamento_id, nombre) FROM stdin;
1	13	Quetzaltenango
2	13	Coatepeque
3	13	Olintepeque
4	13	Zunil
5	13	Cantel
6	17	San Marcos
7	21	Totonicapán
8	1	Nuevo1
\.


--
-- Data for Name: paciente; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.paciente (id_paciente, codigo_expediente, nombres, apellidos, fecha_nacimiento, "edad_años", sexo, dpi, telefono, municipio_id, area, estado_civil, no_seguro_social) FROM stdin;
1	HG1-0001	María Fernanda	López García	1988-04-12	38	Femenino	2220123450123	5551-1001	1	Urbana	Casada	IGSS-88432
2	HG1-0002	Jorge Luis	Ramírez Sosa	1990-11-03	35	Masculino	3330123450456	5551-1002	6	Rural	Soltero	\N
3	HG1-0003	Pedro	Gómez Aguilar	1975-07-22	51	Masculino	4440123450789	5551-1003	5	Rural	Casado	\N
4	HG1-0004	Ana Lucía	Méndez Cruz	2015-05-30	11	Femenino	5550123450104	5551-1004	1	Urbana	Soltera	IGSS-22150
5	HG1-0005	Carlos	De León Ortiz	1982-09-15	43	Masculino	66601234501230	5551-1005	3	Urbana	Casado	\N
6	HG2-0001	Sofía	Rivera Paz	2001-02-25	25	Femenino	7770123450650	5551-1006	6	Urbana	Soltera	\N
7	HG1-0006	Luis Miguel	Castillo Fuentes	1968-01-19	58	Masculino	8880123450901	5551-1007	4	Rural	Viudo	\N
\.


--
-- Data for Name: paciente_encargado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.paciente_encargado (id_paciente_encargado, paciente_id, encargado_id, parentesco) FROM stdin;
401	4	301	Madre
402	4	302	Padre
403	6	303	Hermana
\.


--
-- Data for Name: pago; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.pago (id_pago, factura_id, numero_cuota, total_cuotas, monto, fecha_pago) FROM stdin;
1	1	1	1	165.00	2026-08-10
2	2	1	3	600.00	2026-08-12
3	2	2	3	600.00	2026-09-12
4	3	1	4	1097.50	2026-08-18
5	3	2	4	1097.50	2026-09-18
6	4	1	6	1539.17	2026-08-12
7	4	2	6	1539.17	2026-09-12
8	5	1	3	1290.00	2026-08-14
\.


--
-- Data for Name: quirofano; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.quirofano (id_quirofano, hospital_id, numero, estado) FROM stdin;
1	1	1	disponible
2	1	2	disponible
3	1	3	disponible
4	1	4	disponible
\.


--
-- Data for Name: receta; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.receta (id_receta, consulta_id, fecha, proxima_cita) FROM stdin;
1	1	2026-08-10	2026-09-10
2	2	2026-08-11	\N
\.


--
-- Data for Name: receta_medicamento; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.receta_medicamento (id_receta_medicamento, receta_id, medicamento_nombre, dosis, duracion) FROM stdin;
1	1	Metoprolol 50 mg	1 tableta cada 12 horas	30 días
2	1	Losartán 50 mg	1 tableta en la mañana	30 días
3	2	Tramadol 50 mg (dolor)	1 tableta hasta cada 8 horas según dolor	5 días
\.


--
-- Data for Name: registro_procedimiento; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.registro_procedimiento (id_registro_procedimiento, cirugia_id, etapa, aspecto, exito, descripcion, hora_registro, enfermero_id, fecha_documentacion) FROM stdin;
1	1	preoperatorio	planificacion	t	Tabla quirúrgica disponible, equipos y quirófano preparados.	2026-08-12 00:15:00+00	2001	2026-08-12
2	1	preoperatorio	entrada	t	Paciente identificado con brazalete; ficha clínica y consentimiento firmado verificados.	2026-08-12 00:38:00+00	2001	2026-08-12
3	1	intraoperatorio	chequeo_quirofano	t	Equipo quirúrgico completo; traslado y posicionamiento correctos.	2026-08-12 00:45:00+00	2002	2026-08-12
4	1	intraoperatorio	pausa_quirurgica	t	Paciente y procedimiento confirmados; condiciones de esterilidad adecuadas.	2026-08-12 00:50:00+00	2002	2026-08-12
5	1	intraoperatorio	balance_hidrico	t	Balance hídrico registrado sin alteraciones.	2026-08-12 01:10:00+00	2002	2026-08-12
6	1	intraoperatorio	salida_quirurgica	t	Conteo de instrumental satisfactorio; cierre de incisión.	2026-08-12 02:05:00+00	2002	2026-08-12
7	1	postoperatorio	ingreso_sala_recuperacion	t	Ingreso a sala de recuperación con evolución sin complicaciones.	2026-08-12 02:25:00+00	2003	2026-08-12
8	1	postoperatorio	traslado_seguro	t	Signos vitales normales; zona operatoria limpia; documentación completa.	2026-08-12 03:15:00+00	2003	2026-08-12
\.


--
-- Data for Name: requerimiento_quirurgico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.requerimiento_quirurgico (id_requerimiento, agendamiento_id, tipo_recurso, insumo_id, instrumento_id, equipo_id, cantidad) FROM stdin;
1	1	instrumento	\N	1	\N	1
2	1	insumo	6	\N	\N	2
3	1	equipo	\N	\N	1	1
4	2	equipo	\N	\N	3	1
5	2	instrumento	\N	3	\N	4
\.


--
-- Data for Name: servicio_atencion; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.servicio_atencion (id_servicio, unidad_id, nombre, costo) FROM stdin;
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
\.


--
-- Data for Name: traslado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.traslado (id_traslado, fecha_hora, paciente_id, medico_indica_id, unidad_origen_id, unidad_destino_id, interno_externo, hospital_externo_nombre, hospital_externo_direccion, ingreso_id, consulta_id) FROM stdin;
1	2026-08-11 16:00:00+00	5	1005	11	13	interno	\N	\N	\N	2
2	2026-08-12 03:30:00+00	5	1006	13	14	interno	\N	\N	4	\N
3	2026-08-21 14:00:00+00	4	1005	12	25	externo	Hospital Regional de San Marcos	7a. calle 4-10, zona 2, San Marcos	2	\N
\.


--
-- Data for Name: unidad_medica; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.unidad_medica (id_unidad, hospital_id, nombre, costo_dia_hospitalizacion) FROM stdin;
11	1	Consulta Externa	\N
12	1	Emergencias	\N
13	1	Cirugia	\N
14	1	Hospitalizacion	600.00
15	1	Otro	\N
21	2	Consulta Externa	\N
22	2	Emergencias	\N
23	2	Cirugia	\N
24	2	Hospitalizacion	450.00
25	2	Otro	\N
31	3	Consulta Externa	\N
32	3	Emergencias	\N
33	3	Cirugia	\N
34	3	Hospitalizacion	520.00
35	3	Otro	\N
\.


--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.agendamiento_quirurgico_id_agendamiento_seq', 3, true);


--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.camilla_id_camilla_seq', 24, true);


--
-- Name: chequeo_preanestesico_id_chequeo_preanestesico_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.chequeo_preanestesico_id_chequeo_preanestesico_seq', 1, true);


--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cirugia_id_cirugia_seq', 1, true);


--
-- Name: cirugia_insumo_id_cirugia_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cirugia_insumo_id_cirugia_insumo_seq', 6, true);


--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cirugia_personal_id_cirugia_personal_seq', 4, true);


--
-- Name: cita_id_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cita_id_cita_seq', 5, true);


--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.consentimiento_informado_id_consentimiento_seq', 1, true);


--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.consulta_id_consulta_seq', 2, true);


--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.departamento_id_departamento_seq', 22, true);


--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.egreso_id_egreso_seq', 3, true);


--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.encargado_id_encargado_seq', 303, true);


--
-- Name: enfermero_id_enfermero_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.enfermero_id_enfermero_seq', 2005, true);


--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.equipo_id_equipo_seq', 8, true);


--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.especialidad_id_especialidad_seq', 330, true);


--
-- Name: factura_id_factura_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.factura_id_factura_seq', 5, true);


--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.historia_clinica_id_historia_clinica_seq', 1, true);


--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.hospital_id_hospital_seq', 3, true);


--
-- Name: hospitalizacion_insumo_id_hospitalizacion_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq', 4, true);


--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.ingreso_id_ingreso_seq', 5, true);


--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.instrumento_id_instrumento_seq', 10, true);


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.insumo_id_insumo_seq', 10, true);


--
-- Name: medico_id_medico_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.medico_id_medico_seq', 1030, true);


--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.municipio_id_municipio_seq', 8, true);


--
-- Name: paciente_encargado_id_paciente_encargado_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.paciente_encargado_id_paciente_encargado_seq', 403, true);


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.paciente_id_paciente_seq', 7, true);


--
-- Name: pago_id_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.pago_id_pago_seq', 8, true);


--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.quirofano_id_quirofano_seq', 4, true);


--
-- Name: receta_id_receta_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.receta_id_receta_seq', 2, true);


--
-- Name: receta_medicamento_id_receta_medicamento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.receta_medicamento_id_receta_medicamento_seq', 3, true);


--
-- Name: registro_procedimiento_id_registro_procedimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.registro_procedimiento_id_registro_procedimiento_seq', 8, true);


--
-- Name: requerimiento_quirurgico_id_requerimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.requerimiento_quirurgico_id_requerimiento_seq', 5, true);


--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.servicio_atencion_id_servicio_seq', 19, true);


--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.traslado_id_traslado_seq', 3, true);


--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.unidad_medica_id_unidad_seq', 35, true);


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_pkey PRIMARY KEY (id_agendamiento);


--
-- Name: camilla camilla_hospital_id_numero_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_hospital_id_numero_key UNIQUE (hospital_id, numero);


--
-- Name: camilla camilla_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_pkey PRIMARY KEY (id_camilla);


--
-- Name: chequeo_preanestesico chequeo_preanestesico_agendamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_agendamiento_id_key UNIQUE (agendamiento_id);


--
-- Name: chequeo_preanestesico chequeo_preanestesico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_pkey PRIMARY KEY (id_chequeo_preanestesico);


--
-- Name: cirugia cirugia_agendamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_agendamiento_id_key UNIQUE (agendamiento_id);


--
-- Name: cirugia_insumo cirugia_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_pkey PRIMARY KEY (id_cirugia_insumo);


--
-- Name: cirugia_personal cirugia_personal_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_pkey PRIMARY KEY (id_cirugia_personal);


--
-- Name: cirugia cirugia_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_pkey PRIMARY KEY (id_cirugia);


--
-- Name: cita cita_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_pkey PRIMARY KEY (id_cita);


--
-- Name: consentimiento_informado consentimiento_informado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_pkey PRIMARY KEY (id_consentimiento);


--
-- Name: consulta consulta_cita_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_cita_id_key UNIQUE (cita_id);


--
-- Name: consulta consulta_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_pkey PRIMARY KEY (id_consulta);


--
-- Name: departamento departamento_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_nombre_key UNIQUE (nombre);


--
-- Name: departamento departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_pkey PRIMARY KEY (id_departamento);


--
-- Name: egreso egreso_ingreso_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_ingreso_id_key UNIQUE (ingreso_id);


--
-- Name: egreso egreso_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_pkey PRIMARY KEY (id_egreso);


--
-- Name: encargado encargado_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_dpi_key UNIQUE (dpi);


--
-- Name: encargado encargado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_pkey PRIMARY KEY (id_encargado);


--
-- Name: enfermero enfermero_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT enfermero_dpi_key UNIQUE (dpi);


--
-- Name: enfermero enfermero_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT enfermero_pkey PRIMARY KEY (id_enfermero);


--
-- Name: equipo equipo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.equipo
    ADD CONSTRAINT equipo_pkey PRIMARY KEY (id_equipo);


--
-- Name: especialidad especialidad_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_nombre_key UNIQUE (nombre);


--
-- Name: especialidad especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: factura factura_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_pkey PRIMARY KEY (id_factura);


--
-- Name: historia_clinica historia_clinica_agendamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_agendamiento_id_key UNIQUE (agendamiento_id);


--
-- Name: historia_clinica historia_clinica_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_pkey PRIMARY KEY (id_historia_clinica);


--
-- Name: hospital hospital_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (id_hospital);


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_pkey PRIMARY KEY (id_hospitalizacion_insumo);


--
-- Name: ingreso ingreso_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_pkey PRIMARY KEY (id_ingreso);


--
-- Name: instrumento instrumento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.instrumento
    ADD CONSTRAINT instrumento_pkey PRIMARY KEY (id_instrumento);


--
-- Name: insumo insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.insumo
    ADD CONSTRAINT insumo_pkey PRIMARY KEY (id_insumo);


--
-- Name: medico medico_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_dpi_key UNIQUE (dpi);


--
-- Name: medico medico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_pkey PRIMARY KEY (id_medico);


--
-- Name: municipio municipio_departamento_id_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_departamento_id_nombre_key UNIQUE (departamento_id, nombre);


--
-- Name: municipio municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_pkey PRIMARY KEY (id_municipio);


--
-- Name: paciente paciente_codigo_expediente_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_codigo_expediente_key UNIQUE (codigo_expediente);


--
-- Name: paciente paciente_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_dpi_key UNIQUE (dpi);


--
-- Name: paciente_encargado paciente_encargado_paciente_id_encargado_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_paciente_id_encargado_id_key UNIQUE (paciente_id, encargado_id);


--
-- Name: paciente_encargado paciente_encargado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_pkey PRIMARY KEY (id_paciente_encargado);


--
-- Name: paciente paciente_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id_paciente);


--
-- Name: pago pago_factura_id_numero_cuota_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_factura_id_numero_cuota_key UNIQUE (factura_id, numero_cuota);


--
-- Name: pago pago_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (id_pago);


--
-- Name: quirofano quirofano_hospital_id_numero_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_hospital_id_numero_key UNIQUE (hospital_id, numero);


--
-- Name: quirofano quirofano_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_pkey PRIMARY KEY (id_quirofano);


--
-- Name: receta receta_consulta_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_consulta_id_key UNIQUE (consulta_id);


--
-- Name: receta_medicamento receta_medicamento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_pkey PRIMARY KEY (id_receta_medicamento);


--
-- Name: receta receta_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_pkey PRIMARY KEY (id_receta);


--
-- Name: registro_procedimiento registro_procedimiento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_pkey PRIMARY KEY (id_registro_procedimiento);


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_pkey PRIMARY KEY (id_requerimiento);


--
-- Name: servicio_atencion servicio_atencion_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_pkey PRIMARY KEY (id_servicio);


--
-- Name: servicio_atencion servicio_atencion_unidad_id_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_unidad_id_nombre_key UNIQUE (unidad_id, nombre);


--
-- Name: traslado traslado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_pkey PRIMARY KEY (id_traslado);


--
-- Name: unidad_medica unidad_medica_hospital_id_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_hospital_id_nombre_key UNIQUE (hospital_id, nombre);


--
-- Name: unidad_medica unidad_medica_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_pkey PRIMARY KEY (id_unidad);


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_medico_cirujano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_medico_cirujano_id_fkey FOREIGN KEY (medico_cirujano_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_quirofano_solicitado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_quirofano_solicitado_id_fkey FOREIGN KEY (quirofano_solicitado_id) REFERENCES public.quirofano(id_quirofano) ON UPDATE CASCADE;


--
-- Name: camilla camilla_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: camilla camilla_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: chequeo_preanestesico chequeo_preanestesico_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE;


--
-- Name: cirugia cirugia_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE;


--
-- Name: cirugia cirugia_cirujano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_cirujano_id_fkey FOREIGN KEY (cirujano_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: cirugia cirugia_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE;


--
-- Name: cirugia_insumo cirugia_insumo_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_insumo cirugia_insumo_insumo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_insumo_id_fkey FOREIGN KEY (insumo_id) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE;


--
-- Name: cirugia cirugia_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: cirugia_personal cirugia_personal_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_personal cirugia_personal_enfermero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_enfermero_id_fkey FOREIGN KEY (enfermero_id) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE;


--
-- Name: cirugia_personal cirugia_personal_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: cirugia cirugia_quirofano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_quirofano_id_fkey FOREIGN KEY (quirofano_id) REFERENCES public.quirofano(id_quirofano) ON UPDATE CASCADE;


--
-- Name: cita cita_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: cita cita_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: consentimiento_informado consentimiento_informado_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consulta consulta_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.cita(id_cita) ON UPDATE CASCADE;


--
-- Name: consulta consulta_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: consulta consulta_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: egreso egreso_camilla_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_camilla_id_fkey FOREIGN KEY (camilla_id) REFERENCES public.camilla(id_camilla) ON UPDATE CASCADE;


--
-- Name: egreso egreso_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE;


--
-- Name: egreso egreso_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: egreso egreso_servicio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_servicio_id_fkey FOREIGN KEY (servicio_id) REFERENCES public.servicio_atencion(id_servicio) ON UPDATE CASCADE;


--
-- Name: egreso egreso_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE;


--
-- Name: encargado encargado_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE;


--
-- Name: factura factura_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE;


--
-- Name: factura factura_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.cita(id_cita) ON UPDATE CASCADE;


--
-- Name: factura factura_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE;


--
-- Name: factura factura_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: historia_clinica historia_clinica_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE;


--
-- Name: historia_clinica historia_clinica_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_insumo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_insumo_id_fkey FOREIGN KEY (insumo_id) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE;


--
-- Name: ingreso ingreso_camilla_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_camilla_id_fkey FOREIGN KEY (camilla_id) REFERENCES public.camilla(id_camilla) ON UPDATE CASCADE;


--
-- Name: ingreso ingreso_medico_encargado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_medico_encargado_id_fkey FOREIGN KEY (medico_encargado_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: ingreso ingreso_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: ingreso ingreso_servicio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_servicio_id_fkey FOREIGN KEY (servicio_id) REFERENCES public.servicio_atencion(id_servicio) ON UPDATE CASCADE;


--
-- Name: ingreso ingreso_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE;


--
-- Name: medico medico_especialidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_especialidad_id_fkey FOREIGN KEY (especialidad_id) REFERENCES public.especialidad(id_especialidad) ON UPDATE CASCADE;


--
-- Name: medico medico_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: medico medico_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE;


--
-- Name: municipio municipio_departamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamento(id_departamento) ON UPDATE CASCADE;


--
-- Name: paciente_encargado paciente_encargado_encargado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_encargado_id_fkey FOREIGN KEY (encargado_id) REFERENCES public.encargado(id_encargado) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente_encargado paciente_encargado_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente paciente_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE;


--
-- Name: pago pago_factura_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_factura_id_fkey FOREIGN KEY (factura_id) REFERENCES public.factura(id_factura) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: quirofano quirofano_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: receta receta_consulta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_consulta_id_fkey FOREIGN KEY (consulta_id) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE;


--
-- Name: receta_medicamento receta_medicamento_receta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_receta_id_fkey FOREIGN KEY (receta_id) REFERENCES public.receta(id_receta) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro_procedimiento registro_procedimiento_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro_procedimiento registro_procedimiento_enfermero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_enfermero_id_fkey FOREIGN KEY (enfermero_id) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_equipo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_equipo_id_fkey FOREIGN KEY (equipo_id) REFERENCES public.equipo(id_equipo) ON UPDATE CASCADE;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_instrumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_instrumento_id_fkey FOREIGN KEY (instrumento_id) REFERENCES public.instrumento(id_instrumento) ON UPDATE CASCADE;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_insumo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_insumo_id_fkey FOREIGN KEY (insumo_id) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE;


--
-- Name: servicio_atencion servicio_atencion_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: traslado traslado_consulta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_consulta_id_fkey FOREIGN KEY (consulta_id) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE;


--
-- Name: traslado traslado_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE;


--
-- Name: traslado traslado_medico_indica_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_medico_indica_id_fkey FOREIGN KEY (medico_indica_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: traslado traslado_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: traslado traslado_unidad_destino_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_unidad_destino_id_fkey FOREIGN KEY (unidad_destino_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE;


--
-- Name: traslado traslado_unidad_origen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_unidad_origen_id_fkey FOREIGN KEY (unidad_origen_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE;


--
-- Name: unidad_medica unidad_medica_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: hospital
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict 12zZuX6AQOuwOaneHwH0dtU04V954K8f41wQk5WlRZeSWwOYfQMNNSAJSaCsgiA

--
-- Database "hospital" dump
--

--
-- PostgreSQL database dump
--

\restrict T266OHoMvOIrdV5HmjOl5klQe5fRMmqErYilYQLhn1Xc3YwpYbis2YdfKPZSXmB

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
-- Name: hospital; Type: DATABASE; Schema: -; Owner: hospital
--

CREATE DATABASE hospital WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE hospital OWNER TO hospital;

\unrestrict T266OHoMvOIrdV5HmjOl5klQe5fRMmqErYilYQLhn1Xc3YwpYbis2YdfKPZSXmB
\connect hospital
\restrict T266OHoMvOIrdV5HmjOl5klQe5fRMmqErYilYQLhn1Xc3YwpYbis2YdfKPZSXmB

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: hospital
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO hospital;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: hospital
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agendamiento_quirurgico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.agendamiento_quirurgico (
    id_agendamiento integer NOT NULL,
    paciente_id integer NOT NULL,
    medico_cirujano_id integer NOT NULL,
    caracter character varying(15) NOT NULL,
    historia_clinica text,
    tipo_procedimiento text NOT NULL,
    tiempo_estimado_min smallint NOT NULL,
    tipo_anestesia character varying(80) NOT NULL,
    fecha_hora_solicitud timestamp with time zone NOT NULL,
    estado_solicitud character varying(15) NOT NULL,
    motivo_rechazo text,
    quirofano_solicitado_id integer,
    fecha_hora_agendada timestamp with time zone,
    CONSTRAINT agendamiento_quirurgico_caracter_check CHECK (((caracter)::text = ANY ((ARRAY['urgente'::character varying, 'programado'::character varying])::text[]))),
    CONSTRAINT agendamiento_quirurgico_estado_solicitud_check CHECK (((estado_solicitud)::text = ANY ((ARRAY['pendiente'::character varying, 'aprobada'::character varying, 'rechazada'::character varying])::text[])))
);


ALTER TABLE public.agendamiento_quirurgico OWNER TO hospital;

--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.agendamiento_quirurgico_id_agendamiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.agendamiento_quirurgico_id_agendamiento_seq OWNER TO hospital;

--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.agendamiento_quirurgico_id_agendamiento_seq OWNED BY public.agendamiento_quirurgico.id_agendamiento;


--
-- Name: camilla; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.camilla (
    id_camilla integer NOT NULL,
    hospital_id integer NOT NULL,
    unidad_id integer NOT NULL,
    numero character varying(10) NOT NULL,
    disponible boolean DEFAULT true NOT NULL
);


ALTER TABLE public.camilla OWNER TO hospital;

--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.camilla_id_camilla_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.camilla_id_camilla_seq OWNER TO hospital;

--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.camilla_id_camilla_seq OWNED BY public.camilla.id_camilla;


--
-- Name: chequeo_preanestesico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.chequeo_preanestesico (
    id_chequeo_preanestesico integer NOT NULL,
    agendamiento_id integer NOT NULL,
    clasificacion_asa character varying(5) NOT NULL,
    medico_asa_nombre character varying(150) NOT NULL,
    plan_anestesia text NOT NULL,
    anestesista_nombre character varying(150) NOT NULL,
    CONSTRAINT chequeo_preanestesico_clasificacion_asa_check CHECK (((clasificacion_asa)::text = ANY ((ARRAY['I'::character varying, 'II'::character varying, 'III'::character varying, 'IV'::character varying, 'V'::character varying, 'VI'::character varying])::text[])))
);


ALTER TABLE public.chequeo_preanestesico OWNER TO hospital;

--
-- Name: chequeo_preanestesico_id_chequeo_preanestesico_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.chequeo_preanestesico_id_chequeo_preanestesico_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chequeo_preanestesico_id_chequeo_preanestesico_seq OWNER TO hospital;

--
-- Name: chequeo_preanestesico_id_chequeo_preanestesico_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.chequeo_preanestesico_id_chequeo_preanestesico_seq OWNED BY public.chequeo_preanestesico.id_chequeo_preanestesico;


--
-- Name: cirugia; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cirugia (
    id_cirugia integer NOT NULL,
    agendamiento_id integer NOT NULL,
    quirofano_id integer NOT NULL,
    paciente_id integer NOT NULL,
    cirujano_id integer NOT NULL,
    ingreso_id integer,
    fecha_hora_inicio timestamp with time zone NOT NULL,
    fecha_hora_fin timestamp with time zone,
    condicion_evolucion character varying(25),
    estado character varying(20) NOT NULL,
    CONSTRAINT cirugia_condicion_evolucion_check CHECK (((condicion_evolucion)::text = ANY ((ARRAY['sin_complicaciones'::character varying, 'complicaciones'::character varying, 'complicaciones_graves'::character varying])::text[]))),
    CONSTRAINT cirugia_estado_check CHECK (((estado)::text = ANY ((ARRAY['preoperatorio'::character varying, 'intraoperatorio'::character varying, 'postoperatorio'::character varying, 'finalizada'::character varying])::text[])))
);


ALTER TABLE public.cirugia OWNER TO hospital;

--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.cirugia_id_cirugia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cirugia_id_cirugia_seq OWNER TO hospital;

--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.cirugia_id_cirugia_seq OWNED BY public.cirugia.id_cirugia;


--
-- Name: cirugia_insumo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cirugia_insumo (
    id_cirugia_insumo integer NOT NULL,
    cirugia_id integer NOT NULL,
    insumo_id integer NOT NULL,
    cantidad smallint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL
);


ALTER TABLE public.cirugia_insumo OWNER TO hospital;

--
-- Name: cirugia_insumo_id_cirugia_insumo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.cirugia_insumo_id_cirugia_insumo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cirugia_insumo_id_cirugia_insumo_seq OWNER TO hospital;

--
-- Name: cirugia_insumo_id_cirugia_insumo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.cirugia_insumo_id_cirugia_insumo_seq OWNED BY public.cirugia_insumo.id_cirugia_insumo;


--
-- Name: cirugia_personal; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cirugia_personal (
    id_cirugia_personal integer NOT NULL,
    cirugia_id integer NOT NULL,
    medico_id integer,
    enfermero_id integer,
    rol character varying(60) NOT NULL,
    CONSTRAINT cirugia_personal_check CHECK (((((medico_id IS NOT NULL))::integer + ((enfermero_id IS NOT NULL))::integer) >= 1))
);


ALTER TABLE public.cirugia_personal OWNER TO hospital;

--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.cirugia_personal_id_cirugia_personal_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cirugia_personal_id_cirugia_personal_seq OWNER TO hospital;

--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.cirugia_personal_id_cirugia_personal_seq OWNED BY public.cirugia_personal.id_cirugia_personal;


--
-- Name: cita; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cita (
    id_cita integer NOT NULL,
    paciente_id integer NOT NULL,
    medico_id integer NOT NULL,
    fecha_hora timestamp with time zone NOT NULL,
    num_clinica character varying(20) NOT NULL,
    medio_asignacion character varying(20),
    estado character varying(20) DEFAULT 'programada'::character varying NOT NULL,
    es_reconsulta boolean DEFAULT false NOT NULL,
    es_referido boolean DEFAULT false NOT NULL,
    costo_base numeric(10,2),
    costo_aplicado numeric(10,2),
    cancelada_sin_aviso boolean DEFAULT false NOT NULL,
    CONSTRAINT cita_estado_check CHECK (((estado)::text = ANY ((ARRAY['programada'::character varying, 'realizada'::character varying, 'reprogramada'::character varying, 'cancelada'::character varying])::text[]))),
    CONSTRAINT cita_medio_asignacion_check CHECK (((medio_asignacion)::text = ANY ((ARRAY['telefonico'::character varying, 'correo_institucional'::character varying, 'recepcion_general'::character varying, 'recepcion_medico'::character varying])::text[])))
);


ALTER TABLE public.cita OWNER TO hospital;

--
-- Name: cita_id_cita_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.cita_id_cita_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cita_id_cita_seq OWNER TO hospital;

--
-- Name: cita_id_cita_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.cita_id_cita_seq OWNED BY public.cita.id_cita;


--
-- Name: consentimiento_informado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.consentimiento_informado (
    id_consentimiento integer NOT NULL,
    agendamiento_id integer NOT NULL,
    procedimiento_nombre text NOT NULL,
    procedimiento_objetivo text NOT NULL,
    procedimiento_caracteristicas text NOT NULL,
    procedimiento_riesgos text NOT NULL,
    medico_nombre character varying(150) NOT NULL,
    medico_firmado boolean DEFAULT false NOT NULL,
    paciente_firma_nombre character varying(150) NOT NULL,
    paciente_firmado boolean DEFAULT false NOT NULL,
    fecha_obtencion date NOT NULL
);


ALTER TABLE public.consentimiento_informado OWNER TO hospital;

--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.consentimiento_informado_id_consentimiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.consentimiento_informado_id_consentimiento_seq OWNER TO hospital;

--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.consentimiento_informado_id_consentimiento_seq OWNED BY public.consentimiento_informado.id_consentimiento;


--
-- Name: consulta; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.consulta (
    id_consulta integer NOT NULL,
    cita_id integer NOT NULL,
    paciente_id integer NOT NULL,
    medico_id integer NOT NULL,
    fecha date NOT NULL,
    diagnostico text NOT NULL,
    otros_datos text,
    notas_observaciones text
);


ALTER TABLE public.consulta OWNER TO hospital;

--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.consulta_id_consulta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.consulta_id_consulta_seq OWNER TO hospital;

--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.consulta_id_consulta_seq OWNED BY public.consulta.id_consulta;


--
-- Name: departamento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.departamento (
    id_departamento integer NOT NULL,
    nombre character varying(80) NOT NULL
);


ALTER TABLE public.departamento OWNER TO hospital;

--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.departamento_id_departamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departamento_id_departamento_seq OWNER TO hospital;

--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.departamento_id_departamento_seq OWNED BY public.departamento.id_departamento;


--
-- Name: egreso; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.egreso (
    id_egreso integer NOT NULL,
    ingreso_id integer NOT NULL,
    diagnostico_principal text NOT NULL,
    diagnosticos_secundarios text,
    motivo_egreso text NOT NULL,
    unidad_id integer NOT NULL,
    servicio_id integer,
    fecha_hora_egreso timestamp with time zone NOT NULL,
    medico_id integer NOT NULL,
    camilla_id integer,
    codigo_egreso character varying(15) NOT NULL,
    egreso_sin_consentimiento boolean DEFAULT false NOT NULL,
    motivo_egreso_sin_consentimiento text,
    dias_hospitalizado smallint,
    codigo_traslado character varying(20),
    referido_otro_hospital boolean DEFAULT false NOT NULL,
    CONSTRAINT egreso_codigo_egreso_check CHECK (((codigo_egreso)::text = ANY ((ARRAY['vivo'::character varying, 'muerto'::character varying, 'embarazo'::character varying, 'parto'::character varying])::text[])))
);


ALTER TABLE public.egreso OWNER TO hospital;

--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.egreso_id_egreso_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.egreso_id_egreso_seq OWNER TO hospital;

--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.egreso_id_egreso_seq OWNED BY public.egreso.id_egreso;


--
-- Name: encargado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.encargado (
    id_encargado integer NOT NULL,
    nombre character varying(150) NOT NULL,
    dpi character varying(20),
    telefono character varying(20),
    municipio_id integer NOT NULL,
    area character varying(10) NOT NULL,
    CONSTRAINT encargado_area_check CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[])))
);


ALTER TABLE public.encargado OWNER TO hospital;

--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.encargado_id_encargado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.encargado_id_encargado_seq OWNER TO hospital;

--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.encargado_id_encargado_seq OWNED BY public.encargado.id_encargado;


--
-- Name: enfermero; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.enfermero (
    id_enfermero integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character varying(20) NOT NULL,
    telefono character varying(20),
    tipo character varying(30) NOT NULL,
    CONSTRAINT enfermero_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['registrado'::character varying, 'practicante_de_enfermeria'::character varying])::text[])))
);


ALTER TABLE public.enfermero OWNER TO hospital;

--
-- Name: enfermero_id_enfermero_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.enfermero_id_enfermero_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.enfermero_id_enfermero_seq OWNER TO hospital;

--
-- Name: enfermero_id_enfermero_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.enfermero_id_enfermero_seq OWNED BY public.enfermero.id_enfermero;


--
-- Name: equipo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.equipo (
    id_equipo integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    estado character varying(20) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT equipo_estado_check CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'en_uso'::character varying, 'en_mantenimiento'::character varying])::text[])))
);


ALTER TABLE public.equipo OWNER TO hospital;

--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.equipo_id_equipo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipo_id_equipo_seq OWNER TO hospital;

--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.equipo_id_equipo_seq OWNED BY public.equipo.id_equipo;


--
-- Name: especialidad; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.especialidad (
    id_especialidad integer NOT NULL,
    nombre character varying(80) NOT NULL
);


ALTER TABLE public.especialidad OWNER TO hospital;

--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.especialidad_id_especialidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.especialidad_id_especialidad_seq OWNER TO hospital;

--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.especialidad_id_especialidad_seq OWNED BY public.especialidad.id_especialidad;


--
-- Name: factura; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.factura (
    id_factura integer NOT NULL,
    paciente_id integer NOT NULL,
    fecha_emision timestamp with time zone NOT NULL,
    descripcion text NOT NULL,
    total numeric(10,2) NOT NULL,
    cita_id integer,
    ingreso_id integer,
    cirugia_id integer,
    CONSTRAINT factura_check CHECK ((((((cita_id IS NOT NULL))::integer + ((cirugia_id IS NOT NULL))::integer) + ((ingreso_id IS NOT NULL))::integer) = 1)),
    CONSTRAINT factura_total_check CHECK ((total >= (0)::numeric))
);


ALTER TABLE public.factura OWNER TO hospital;

--
-- Name: factura_id_factura_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.factura_id_factura_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.factura_id_factura_seq OWNER TO hospital;

--
-- Name: factura_id_factura_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.factura_id_factura_seq OWNED BY public.factura.id_factura;


--
-- Name: historia_clinica; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.historia_clinica (
    id_historia_clinica integer NOT NULL,
    agendamiento_id integer NOT NULL,
    medico_id integer NOT NULL,
    fecha date NOT NULL,
    fuente_interrogatorio character varying(10) NOT NULL,
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
    CONSTRAINT historia_clinica_fuente_interrogatorio_check CHECK (((fuente_interrogatorio)::text = ANY ((ARRAY['directo'::character varying, 'indirecto'::character varying])::text[])))
);


ALTER TABLE public.historia_clinica OWNER TO hospital;

--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.historia_clinica_id_historia_clinica_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historia_clinica_id_historia_clinica_seq OWNER TO hospital;

--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.historia_clinica_id_historia_clinica_seq OWNED BY public.historia_clinica.id_historia_clinica;


--
-- Name: hospital; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.hospital (
    id_hospital integer NOT NULL,
    nombre character varying(120) NOT NULL,
    informacion_especifica text,
    direccion character varying(250) NOT NULL
);


ALTER TABLE public.hospital OWNER TO hospital;

--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.hospital_id_hospital_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_id_hospital_seq OWNER TO hospital;

--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.hospital_id_hospital_seq OWNED BY public.hospital.id_hospital;


--
-- Name: hospitalizacion_insumo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.hospitalizacion_insumo (
    id_hospitalizacion_insumo integer NOT NULL,
    ingreso_id integer NOT NULL,
    insumo_id integer NOT NULL,
    cantidad smallint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL
);


ALTER TABLE public.hospitalizacion_insumo OWNER TO hospital;

--
-- Name: hospitalizacion_insumo_id_hospitalizacion_insumo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq OWNER TO hospital;

--
-- Name: hospitalizacion_insumo_id_hospitalizacion_insumo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq OWNED BY public.hospitalizacion_insumo.id_hospitalizacion_insumo;


--
-- Name: ingreso; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.ingreso (
    id_ingreso integer NOT NULL,
    paciente_id integer NOT NULL,
    unidad_id integer NOT NULL,
    servicio_id integer,
    camilla_id integer,
    motivo_ingreso text NOT NULL,
    fecha_hora_ingreso timestamp with time zone NOT NULL,
    medico_encargado_id integer NOT NULL,
    diagnostico_presuntivo text
);


ALTER TABLE public.ingreso OWNER TO hospital;

--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.ingreso_id_ingreso_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ingreso_id_ingreso_seq OWNER TO hospital;

--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.ingreso_id_ingreso_seq OWNED BY public.ingreso.id_ingreso;


--
-- Name: instrumento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.instrumento (
    id_instrumento integer NOT NULL,
    nombre character varying(120) NOT NULL,
    tipo character varying(30) NOT NULL,
    estado character varying(20) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT instrumento_estado_check CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'en_uso'::character varying, 'en_mantenimiento'::character varying])::text[])))
);


ALTER TABLE public.instrumento OWNER TO hospital;

--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.instrumento_id_instrumento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.instrumento_id_instrumento_seq OWNER TO hospital;

--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.instrumento_id_instrumento_seq OWNED BY public.instrumento.id_instrumento;


--
-- Name: insumo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.insumo (
    id_insumo integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    material character varying(80),
    tipo character varying(20),
    unidad_medida character varying(20),
    costo_unitario numeric(10,2),
    stock_minimo integer,
    stock_actual integer,
    CONSTRAINT insumo_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['medico'::character varying, 'quirurgico'::character varying, 'otro'::character varying])::text[])))
);


ALTER TABLE public.insumo OWNER TO hospital;

--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.insumo_id_insumo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.insumo_id_insumo_seq OWNER TO hospital;

--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.insumo_id_insumo_seq OWNED BY public.insumo.id_insumo;


--
-- Name: medico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.medico (
    id_medico integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character varying(20) NOT NULL,
    telefono character varying(20),
    hospital_id integer NOT NULL,
    municipio_id integer NOT NULL,
    area character varying(10) NOT NULL,
    especialidad_id integer,
    tipo_medico character varying(20) NOT NULL,
    costo_primera_consulta numeric(10,2),
    horario_inicio time without time zone,
    horario_fin time without time zone,
    CONSTRAINT medico_area_check CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[]))),
    CONSTRAINT medico_tipo_medico_check CHECK (((tipo_medico)::text = ANY ((ARRAY['residente'::character varying, 'interno'::character varying, 'externo'::character varying, 'general'::character varying, 'especialista'::character varying])::text[])))
);


ALTER TABLE public.medico OWNER TO hospital;

--
-- Name: medico_id_medico_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.medico_id_medico_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medico_id_medico_seq OWNER TO hospital;

--
-- Name: medico_id_medico_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.medico_id_medico_seq OWNED BY public.medico.id_medico;


--
-- Name: municipio; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.municipio (
    id_municipio integer NOT NULL,
    departamento_id integer NOT NULL,
    nombre character varying(80) NOT NULL
);


ALTER TABLE public.municipio OWNER TO hospital;

--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.municipio_id_municipio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.municipio_id_municipio_seq OWNER TO hospital;

--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.municipio_id_municipio_seq OWNED BY public.municipio.id_municipio;


--
-- Name: paciente; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.paciente (
    id_paciente integer NOT NULL,
    codigo_expediente character varying(20) NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    fecha_nacimiento date NOT NULL,
    "edad_años" smallint NOT NULL,
    sexo character varying(10) NOT NULL,
    dpi character varying(20),
    telefono character varying(20),
    municipio_id integer NOT NULL,
    area character varying(10) NOT NULL,
    estado_civil character varying(30),
    no_seguro_social character varying(30),
    CONSTRAINT paciente_area_check CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[]))),
    CONSTRAINT "paciente_edad_años_check" CHECK ((("edad_años" >= 0) AND ("edad_años" <= 120))),
    CONSTRAINT paciente_sexo_check CHECK (((sexo)::text = ANY ((ARRAY['Masculino'::character varying, 'Femenino'::character varying])::text[])))
);


ALTER TABLE public.paciente OWNER TO hospital;

--
-- Name: paciente_encargado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.paciente_encargado (
    id_paciente_encargado integer NOT NULL,
    paciente_id integer NOT NULL,
    encargado_id integer NOT NULL,
    parentesco character varying(40) NOT NULL
);


ALTER TABLE public.paciente_encargado OWNER TO hospital;

--
-- Name: paciente_encargado_id_paciente_encargado_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.paciente_encargado_id_paciente_encargado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paciente_encargado_id_paciente_encargado_seq OWNER TO hospital;

--
-- Name: paciente_encargado_id_paciente_encargado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.paciente_encargado_id_paciente_encargado_seq OWNED BY public.paciente_encargado.id_paciente_encargado;


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.paciente_id_paciente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paciente_id_paciente_seq OWNER TO hospital;

--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.paciente_id_paciente_seq OWNED BY public.paciente.id_paciente;


--
-- Name: pago; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.pago (
    id_pago integer NOT NULL,
    factura_id integer NOT NULL,
    numero_cuota smallint NOT NULL,
    total_cuotas smallint NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha_pago date NOT NULL,
    CONSTRAINT pago_monto_check CHECK ((monto > (0)::numeric)),
    CONSTRAINT pago_numero_cuota_check CHECK (((numero_cuota >= 1) AND (numero_cuota <= 12))),
    CONSTRAINT pago_total_cuotas_check CHECK (((total_cuotas >= 1) AND (total_cuotas <= 12)))
);


ALTER TABLE public.pago OWNER TO hospital;

--
-- Name: pago_id_pago_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.pago_id_pago_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pago_id_pago_seq OWNER TO hospital;

--
-- Name: pago_id_pago_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.pago_id_pago_seq OWNED BY public.pago.id_pago;


--
-- Name: quirofano; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.quirofano (
    id_quirofano integer NOT NULL,
    hospital_id integer NOT NULL,
    numero character varying(10) NOT NULL,
    estado character varying(20) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT quirofano_estado_check CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'ocupado'::character varying, 'en_mantenimiento'::character varying])::text[])))
);


ALTER TABLE public.quirofano OWNER TO hospital;

--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.quirofano_id_quirofano_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quirofano_id_quirofano_seq OWNER TO hospital;

--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.quirofano_id_quirofano_seq OWNED BY public.quirofano.id_quirofano;


--
-- Name: receta; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.receta (
    id_receta integer NOT NULL,
    consulta_id integer NOT NULL,
    fecha date NOT NULL,
    proxima_cita date
);


ALTER TABLE public.receta OWNER TO hospital;

--
-- Name: receta_id_receta_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.receta_id_receta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.receta_id_receta_seq OWNER TO hospital;

--
-- Name: receta_id_receta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.receta_id_receta_seq OWNED BY public.receta.id_receta;


--
-- Name: receta_medicamento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.receta_medicamento (
    id_receta_medicamento integer NOT NULL,
    receta_id integer NOT NULL,
    medicamento_nombre character varying(120) NOT NULL,
    dosis character varying(60) NOT NULL,
    duracion character varying(60)
);


ALTER TABLE public.receta_medicamento OWNER TO hospital;

--
-- Name: receta_medicamento_id_receta_medicamento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.receta_medicamento_id_receta_medicamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.receta_medicamento_id_receta_medicamento_seq OWNER TO hospital;

--
-- Name: receta_medicamento_id_receta_medicamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.receta_medicamento_id_receta_medicamento_seq OWNED BY public.receta_medicamento.id_receta_medicamento;


--
-- Name: registro_procedimiento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.registro_procedimiento (
    id_registro_procedimiento integer NOT NULL,
    cirugia_id integer NOT NULL,
    etapa character varying(20) NOT NULL,
    aspecto character varying(60) NOT NULL,
    exito boolean NOT NULL,
    descripcion text,
    hora_registro timestamp with time zone NOT NULL,
    enfermero_id integer NOT NULL,
    fecha_documentacion date,
    CONSTRAINT registro_procedimiento_etapa_check CHECK (((etapa)::text = ANY ((ARRAY['preoperatorio'::character varying, 'intraoperatorio'::character varying, 'postoperatorio'::character varying])::text[])))
);


ALTER TABLE public.registro_procedimiento OWNER TO hospital;

--
-- Name: registro_procedimiento_id_registro_procedimiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.registro_procedimiento_id_registro_procedimiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.registro_procedimiento_id_registro_procedimiento_seq OWNER TO hospital;

--
-- Name: registro_procedimiento_id_registro_procedimiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.registro_procedimiento_id_registro_procedimiento_seq OWNED BY public.registro_procedimiento.id_registro_procedimiento;


--
-- Name: requerimiento_quirurgico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.requerimiento_quirurgico (
    id_requerimiento integer NOT NULL,
    agendamiento_id integer NOT NULL,
    tipo_recurso character varying(20) NOT NULL,
    insumo_id integer,
    instrumento_id integer,
    equipo_id integer,
    cantidad smallint NOT NULL,
    CONSTRAINT requerimiento_quirurgico_check CHECK (((((tipo_recurso)::text = 'insumo'::text) AND (insumo_id IS NOT NULL) AND (instrumento_id IS NULL) AND (equipo_id IS NULL)) OR (((tipo_recurso)::text = 'instrumento'::text) AND (instrumento_id IS NOT NULL) AND (insumo_id IS NULL) AND (equipo_id IS NULL)) OR (((tipo_recurso)::text = 'equipo'::text) AND (equipo_id IS NOT NULL) AND (insumo_id IS NULL) AND (instrumento_id IS NULL)))),
    CONSTRAINT requerimiento_quirurgico_tipo_recurso_check CHECK (((tipo_recurso)::text = ANY ((ARRAY['insumo'::character varying, 'instrumento'::character varying, 'equipo'::character varying])::text[])))
);


ALTER TABLE public.requerimiento_quirurgico OWNER TO hospital;

--
-- Name: requerimiento_quirurgico_id_requerimiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.requerimiento_quirurgico_id_requerimiento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.requerimiento_quirurgico_id_requerimiento_seq OWNER TO hospital;

--
-- Name: requerimiento_quirurgico_id_requerimiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.requerimiento_quirurgico_id_requerimiento_seq OWNED BY public.requerimiento_quirurgico.id_requerimiento;


--
-- Name: servicio_atencion; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.servicio_atencion (
    id_servicio integer NOT NULL,
    unidad_id integer NOT NULL,
    nombre character varying(80) NOT NULL,
    costo numeric(10,2)
);


ALTER TABLE public.servicio_atencion OWNER TO hospital;

--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.servicio_atencion_id_servicio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.servicio_atencion_id_servicio_seq OWNER TO hospital;

--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.servicio_atencion_id_servicio_seq OWNED BY public.servicio_atencion.id_servicio;


--
-- Name: traslado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.traslado (
    id_traslado integer NOT NULL,
    fecha_hora timestamp with time zone NOT NULL,
    paciente_id integer NOT NULL,
    medico_indica_id integer NOT NULL,
    unidad_origen_id integer NOT NULL,
    unidad_destino_id integer NOT NULL,
    interno_externo character varying(10) NOT NULL,
    hospital_externo_nombre character varying(120),
    hospital_externo_direccion character varying(250),
    ingreso_id integer,
    consulta_id integer,
    CONSTRAINT traslado_check CHECK (((((consulta_id IS NOT NULL))::integer + ((ingreso_id IS NOT NULL))::integer) = 1)),
    CONSTRAINT traslado_interno_externo_check CHECK (((interno_externo)::text = ANY ((ARRAY['interno'::character varying, 'externo'::character varying])::text[])))
);


ALTER TABLE public.traslado OWNER TO hospital;

--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.traslado_id_traslado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.traslado_id_traslado_seq OWNER TO hospital;

--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.traslado_id_traslado_seq OWNED BY public.traslado.id_traslado;


--
-- Name: unidad_medica; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.unidad_medica (
    id_unidad integer NOT NULL,
    hospital_id integer NOT NULL,
    nombre character varying(40) NOT NULL,
    costo_dia_hospitalizacion numeric(10,2),
    CONSTRAINT unidad_medica_nombre_check CHECK (((nombre)::text = ANY ((ARRAY['Consulta Externa'::character varying, 'Emergencias'::character varying, 'Cirugia'::character varying, 'Hospitalizacion'::character varying, 'Otro'::character varying])::text[])))
);


ALTER TABLE public.unidad_medica OWNER TO hospital;

--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

CREATE SEQUENCE public.unidad_medica_id_unidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.unidad_medica_id_unidad_seq OWNER TO hospital;

--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hospital
--

ALTER SEQUENCE public.unidad_medica_id_unidad_seq OWNED BY public.unidad_medica.id_unidad;


--
-- Name: agendamiento_quirurgico id_agendamiento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico ALTER COLUMN id_agendamiento SET DEFAULT nextval('public.agendamiento_quirurgico_id_agendamiento_seq'::regclass);


--
-- Name: camilla id_camilla; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla ALTER COLUMN id_camilla SET DEFAULT nextval('public.camilla_id_camilla_seq'::regclass);


--
-- Name: chequeo_preanestesico id_chequeo_preanestesico; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico ALTER COLUMN id_chequeo_preanestesico SET DEFAULT nextval('public.chequeo_preanestesico_id_chequeo_preanestesico_seq'::regclass);


--
-- Name: cirugia id_cirugia; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia ALTER COLUMN id_cirugia SET DEFAULT nextval('public.cirugia_id_cirugia_seq'::regclass);


--
-- Name: cirugia_insumo id_cirugia_insumo; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo ALTER COLUMN id_cirugia_insumo SET DEFAULT nextval('public.cirugia_insumo_id_cirugia_insumo_seq'::regclass);


--
-- Name: cirugia_personal id_cirugia_personal; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal ALTER COLUMN id_cirugia_personal SET DEFAULT nextval('public.cirugia_personal_id_cirugia_personal_seq'::regclass);


--
-- Name: cita id_cita; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita ALTER COLUMN id_cita SET DEFAULT nextval('public.cita_id_cita_seq'::regclass);


--
-- Name: consentimiento_informado id_consentimiento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consentimiento_informado ALTER COLUMN id_consentimiento SET DEFAULT nextval('public.consentimiento_informado_id_consentimiento_seq'::regclass);


--
-- Name: consulta id_consulta; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta ALTER COLUMN id_consulta SET DEFAULT nextval('public.consulta_id_consulta_seq'::regclass);


--
-- Name: departamento id_departamento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.departamento ALTER COLUMN id_departamento SET DEFAULT nextval('public.departamento_id_departamento_seq'::regclass);


--
-- Name: egreso id_egreso; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso ALTER COLUMN id_egreso SET DEFAULT nextval('public.egreso_id_egreso_seq'::regclass);


--
-- Name: encargado id_encargado; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.encargado ALTER COLUMN id_encargado SET DEFAULT nextval('public.encargado_id_encargado_seq'::regclass);


--
-- Name: enfermero id_enfermero; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.enfermero ALTER COLUMN id_enfermero SET DEFAULT nextval('public.enfermero_id_enfermero_seq'::regclass);


--
-- Name: equipo id_equipo; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.equipo ALTER COLUMN id_equipo SET DEFAULT nextval('public.equipo_id_equipo_seq'::regclass);


--
-- Name: especialidad id_especialidad; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.especialidad ALTER COLUMN id_especialidad SET DEFAULT nextval('public.especialidad_id_especialidad_seq'::regclass);


--
-- Name: factura id_factura; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura ALTER COLUMN id_factura SET DEFAULT nextval('public.factura_id_factura_seq'::regclass);


--
-- Name: historia_clinica id_historia_clinica; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica ALTER COLUMN id_historia_clinica SET DEFAULT nextval('public.historia_clinica_id_historia_clinica_seq'::regclass);


--
-- Name: hospital id_hospital; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospital ALTER COLUMN id_hospital SET DEFAULT nextval('public.hospital_id_hospital_seq'::regclass);


--
-- Name: hospitalizacion_insumo id_hospitalizacion_insumo; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo ALTER COLUMN id_hospitalizacion_insumo SET DEFAULT nextval('public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq'::regclass);


--
-- Name: ingreso id_ingreso; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso ALTER COLUMN id_ingreso SET DEFAULT nextval('public.ingreso_id_ingreso_seq'::regclass);


--
-- Name: instrumento id_instrumento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.instrumento ALTER COLUMN id_instrumento SET DEFAULT nextval('public.instrumento_id_instrumento_seq'::regclass);


--
-- Name: insumo id_insumo; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.insumo ALTER COLUMN id_insumo SET DEFAULT nextval('public.insumo_id_insumo_seq'::regclass);


--
-- Name: medico id_medico; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico ALTER COLUMN id_medico SET DEFAULT nextval('public.medico_id_medico_seq'::regclass);


--
-- Name: municipio id_municipio; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.municipio ALTER COLUMN id_municipio SET DEFAULT nextval('public.municipio_id_municipio_seq'::regclass);


--
-- Name: paciente id_paciente; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente ALTER COLUMN id_paciente SET DEFAULT nextval('public.paciente_id_paciente_seq'::regclass);


--
-- Name: paciente_encargado id_paciente_encargado; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado ALTER COLUMN id_paciente_encargado SET DEFAULT nextval('public.paciente_encargado_id_paciente_encargado_seq'::regclass);


--
-- Name: pago id_pago; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago ALTER COLUMN id_pago SET DEFAULT nextval('public.pago_id_pago_seq'::regclass);


--
-- Name: quirofano id_quirofano; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano ALTER COLUMN id_quirofano SET DEFAULT nextval('public.quirofano_id_quirofano_seq'::regclass);


--
-- Name: receta id_receta; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta ALTER COLUMN id_receta SET DEFAULT nextval('public.receta_id_receta_seq'::regclass);


--
-- Name: receta_medicamento id_receta_medicamento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta_medicamento ALTER COLUMN id_receta_medicamento SET DEFAULT nextval('public.receta_medicamento_id_receta_medicamento_seq'::regclass);


--
-- Name: registro_procedimiento id_registro_procedimiento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento ALTER COLUMN id_registro_procedimiento SET DEFAULT nextval('public.registro_procedimiento_id_registro_procedimiento_seq'::regclass);


--
-- Name: requerimiento_quirurgico id_requerimiento; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico ALTER COLUMN id_requerimiento SET DEFAULT nextval('public.requerimiento_quirurgico_id_requerimiento_seq'::regclass);


--
-- Name: servicio_atencion id_servicio; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion ALTER COLUMN id_servicio SET DEFAULT nextval('public.servicio_atencion_id_servicio_seq'::regclass);


--
-- Name: traslado id_traslado; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado ALTER COLUMN id_traslado SET DEFAULT nextval('public.traslado_id_traslado_seq'::regclass);


--
-- Name: unidad_medica id_unidad; Type: DEFAULT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica ALTER COLUMN id_unidad SET DEFAULT nextval('public.unidad_medica_id_unidad_seq'::regclass);


--
-- Data for Name: agendamiento_quirurgico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.agendamiento_quirurgico (id_agendamiento, paciente_id, medico_cirujano_id, caracter, historia_clinica, tipo_procedimiento, tiempo_estimado_min, tipo_anestesia, fecha_hora_solicitud, estado_solicitud, motivo_rechazo, quirofano_solicitado_id, fecha_hora_agendada) FROM stdin;
1	5	1006	urgente	Apendicitis aguda confirmada por ecografía.	Apendicectomía abierta	90	General	2026-08-11 17:00:00+00	aprobada	\N	2	2026-08-12 00:30:00+00
2	7	1009	programado	Carcinoma colorrectal en estudio.	Resección oncológica de colon	160	General	2026-08-13 15:00:00+00	rechazada	El comité recomienda completar estudios de imagen y control nutricional previo a la intervención.	3	\N
3	6	1007	programado	Enfermedad valvular aórtica con estenosis severa.	Revascularización miocárdica	180	General	2026-09-08 16:00:00+00	pendiente	\N	\N	\N
\.


--
-- Data for Name: camilla; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.camilla (id_camilla, hospital_id, unidad_id, numero, disponible) FROM stdin;
1	1	14	1	t
2	1	14	2	t
3	1	14	3	t
4	1	14	4	t
5	1	14	5	t
6	1	14	6	t
7	1	14	7	t
8	1	14	8	t
9	1	14	9	t
10	1	14	10	t
11	1	14	11	t
12	1	14	12	t
13	1	14	13	t
14	1	14	14	t
15	1	14	15	t
16	1	14	16	t
17	1	14	17	t
18	1	14	18	t
19	1	14	19	t
20	1	14	20	t
21	1	14	21	t
22	1	14	22	t
23	1	14	23	t
24	1	14	24	t
\.


--
-- Data for Name: chequeo_preanestesico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.chequeo_preanestesico (id_chequeo_preanestesico, agendamiento_id, clasificacion_asa, medico_asa_nombre, plan_anestesia, anestesista_nombre) FROM stdin;
1	1	II	Alejandro Ramírez Lemus	Inducción con propofol, mantenimiento con sevoflurano, analgesia con morfina.	Daniel Morales Peña
\.


--
-- Data for Name: cirugia; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cirugia (id_cirugia, agendamiento_id, quirofano_id, paciente_id, cirujano_id, ingreso_id, fecha_hora_inicio, fecha_hora_fin, condicion_evolucion, estado) FROM stdin;
1	1	2	5	1006	4	2026-08-12 00:40:00+00	2026-08-12 02:10:00+00	sin_complicaciones	finalizada
\.


--
-- Data for Name: cirugia_insumo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cirugia_insumo (id_cirugia_insumo, cirugia_id, insumo_id, cantidad, costo_unitario) FROM stdin;
1	1	1	2	30.00
2	1	2	1	25.00
3	1	4	10	8.00
4	1	5	8	15.00
5	1	6	2	120.00
6	1	7	3	70.00
\.


--
-- Data for Name: cirugia_personal; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cirugia_personal (id_cirugia_personal, cirugia_id, medico_id, enfermero_id, rol) FROM stdin;
1	1	1006	\N	Cirujano
2	1	1008	\N	Anestesiólogo
3	1	\N	2001	Enfermero instrumentista
4	1	\N	2003	Enfermero circulante
\.


--
-- Data for Name: cita; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cita (id_cita, paciente_id, medico_id, fecha_hora, num_clinica, medio_asignacion, estado, es_reconsulta, es_referido, costo_base, costo_aplicado, cancelada_sin_aviso) FROM stdin;
1	1	1002	2026-08-10 15:00:00+00	A-101	telefonico	realizada	t	f	220.00	165.00	f
2	2	1003	2026-08-12 16:30:00+00	A-205	recepcion_general	reprogramada	f	f	160.00	160.00	f
3	4	1004	2026-08-15 14:30:00+00	B-110	telefonico	cancelada	f	f	180.00	198.00	t
4	6	1002	2026-09-20 15:30:00+00	A-101	correo_institucional	programada	f	t	220.00	176.00	f
5	5	1005	2026-08-11 15:15:00+00	A-108	recepcion_medico	realizada	f	f	180.00	180.00	f
\.


--
-- Data for Name: consentimiento_informado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.consentimiento_informado (id_consentimiento, agendamiento_id, procedimiento_nombre, procedimiento_objetivo, procedimiento_caracteristicas, procedimiento_riesgos, medico_nombre, medico_firmado, paciente_firma_nombre, paciente_firmado, fecha_obtencion) FROM stdin;
1	1	Apendicectomía abierta	Resección del apéndice inflamado para evitar perforación y peritonitis.	Incisión en fosa ilíaca derecha, ligadura y extirpación del apéndice, cierre por planos, bajo anestesia general.	Sangrado, infección de herida, lesión de estructuras vecinas, complicaciones anestésicas.	Alejandro Ramírez Lemus	t	Carlos De León Ortiz	t	2026-08-11
\.


--
-- Data for Name: consulta; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.consulta (id_consulta, cita_id, paciente_id, medico_id, fecha, diagnostico, otros_datos, notas_observaciones) FROM stdin;
1	1	1	1002	2026-08-10	Hipertensión arterial controlada en tratamiento.	Seguimiento a estudio cardiológico de 2025.	Paciente estable; continuar tratamiento y control en 30 días.
2	5	5	1005	2026-08-11	Sospecha de apendicitis aguda.	Dolor abdominal en fosa ilíaca derecha, mayor de 6 horas.	Se solicita valoración quirúrgica de urgencia; requiere hospitalización.
\.


--
-- Data for Name: departamento; Type: TABLE DATA; Schema: public; Owner: hospital
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
-- Data for Name: egreso; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.egreso (id_egreso, ingreso_id, diagnostico_principal, diagnosticos_secundarios, motivo_egreso, unidad_id, servicio_id, fecha_hora_egreso, medico_id, camilla_id, codigo_egreso, egreso_sin_consentimiento, motivo_egreso_sin_consentimiento, dias_hospitalizado, codigo_traslado, referido_otro_hospital) FROM stdin;
1	1	Politraumatismo; fractura de brazo derecho.	Traumatismo craneoencefálico leve.	Mejoría clínica.	12	3	2026-08-12 16:00:00+00	1001	1	vivo	f	\N	3	\N	f
2	3	Hipertensión arterial descompensada controlada.	\N	Estabilización y mejoría.	14	9	2026-08-18 15:30:00+00	1005	3	vivo	f	\N	4	\N	f
3	5	Postoperatorio de apendicectomía sin complicaciones.	\N	Recuperación satisfactoria.	14	15	2026-08-14 17:30:00+00	1006	4	vivo	f	\N	3	\N	f
\.


--
-- Data for Name: encargado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.encargado (id_encargado, nombre, dpi, telefono, municipio_id, area) FROM stdin;
301	Isabel Cruz López	8881123450101	5551-3001	1	Urbana
302	Roberto Méndez Rodríguez	8881123450102	5551-3002	1	Urbana
303	Karla Paz Veliz	8881123450103	5551-3003	6	Urbana
\.


--
-- Data for Name: enfermero; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.enfermero (id_enfermero, nombres, apellidos, dpi, telefono, tipo) FROM stdin;
2001	Luis	Hernández Solís	2001123450201	5552-2001	registrado
2002	Marta	Recinos Alvarado	2001123450202	5552-2002	registrado
2003	Carlos	García Méndez	2001123450203	5552-2003	practicante_de_enfermeria
2004	Ana	López Pérez	2001123450204	5552-2004	registrado
2005	Pedro	Ramírez Soto	2001123450205	5552-2005	registrado
\.


--
-- Data for Name: equipo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.equipo (id_equipo, nombre, descripcion, estado) FROM stdin;
1	Monitor de signos vitales	Monitor multiparamétrico 5 derivaciones	disponible
2	Ventilador mecánico	Ventilador de cuidados críticos	disponible
3	Bomba de infusión	Bomba de infusión volumétrica	disponible
4	Desfibrilador	Desfibrilador monitor	disponible
5	Arco en C	Arco en C móvil para fluoroscopia	disponible
6	Microscopio quirúrgico	Microscopio para neurocirugía	disponible
7	Lámpara de cirugía LED	Lámpara quirúrgica LED de alta intensidad	disponible
8	Mesa de operaciones	Mesa quirúrgica electromecánica	disponible
\.


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.especialidad (id_especialidad, nombre) FROM stdin;
301	Cardiología
302	Dermatología
303	Fisioterapia
304	Ginecología Oncológica
305	Hematología
306	Medicina Física y Rehabilitación
307	Medicina General
308	Nutrición y Dietética
309	Odontología General
310	Oftalmología
311	Psicología
312	Pediatría
313	Urología
314	Terapia del Lenguaje
315	Cirugía General
316	Cirugía Cardiovascular
317	Cirugía Oncológica
318	Anestesiología
319	Cirugía de la Mano
320	Videolaparoscopia Quirúrgica
321	Cirugía Ginecológica
322	Cirugía Neurológica
323	Cirugía Oftalmológica
324	Cirugía Ortopédica
325	Cirugía Otorrinolaringológica
326	Cirugía Pediátrica
327	Cirugía Plástica
328	Cirugía de Tórax
329	Cirugía Urológica
\.


--
-- Data for Name: factura; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.factura (id_factura, paciente_id, fecha_emision, descripcion, total, cita_id, ingreso_id, cirugia_id) FROM stdin;
1	1	2026-08-10 17:30:00+00	Consulta de cardiología; reconsulta (75%).	165.00	1	\N	\N
2	3	2026-08-12 16:30:00+00	Atención de emergencia por politraumatismo; servicio de atención a pacientes politraumatizados.	1800.00	\N	1	\N
3	2	2026-08-18 15:45:00+00	Hospitalización 4 días: medicina interna + insumos médicos.	4390.00	\N	3	\N
4	5	2026-08-12 14:00:00+00	Cirugía: apendicectomía (cirugía general) + insumos utilizados.	9235.00	\N	\N	1
5	5	2026-08-14 18:00:00+00	Hospitalización postoperatoria: 3 días en cuidados intermedios + insumos.	3870.00	\N	5	\N
\.


--
-- Data for Name: historia_clinica; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.historia_clinica (id_historia_clinica, agendamiento_id, medico_id, fecha, fuente_interrogatorio, religion, ocupacion, lugar_nacimiento, lugar_residencia, antecedentes_heredofamiliares, antecedentes_personales_no_patologicos, antecedentes_patologicos, padecimiento_actual, interrogatorio_aparatos_sistemas, sintomas_generales_terapeutica, estudios_previos, signos_vitales, exploracion_general, exploracion_sistematizada) FROM stdin;
1	1	1006	2026-08-11	directo	Católica	Comerciante	Olintepeque, Quetzaltenango	Olintepeque, Quetzaltenango	Cardiopatía isquémica en padre; hipertensión en madre.	No fumador; consumo de alcohol ocasional; alimentación sin restricciones.	Ninguno conocido.	Dolor abdominal en fosa ilíaca derecha desde hace 8 horas, con náuseas.	Dolor intenso localizado, sin irradiación.	Paciente no había iniciado antibióticos previo a consulta.	Ecografía abdominal: líquido libre y engrosamiento apendicular.	TA 120/80, FC 92, T° 37.8.	Abdomen blando, doloroso a palpación en fosa ilíaca derecha.	Cabeza y cuello sin alteraciones; tórax y abdomen según lo referido; extremidades sin déficit motor.
\.


--
-- Data for Name: hospital; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.hospital (id_hospital, nombre, informacion_especifica, direccion) FROM stdin;
1	Hospital General de Occidente	Hospital general de tercer nivel; 4 quirófanos y 24 camillas de hospitalización.	15 Av. 6-45, zona 3, Quetzaltenango
2	Hospital Regional de San Marcos	Hospital de referencia regional para el departamento de San Marcos.	7a. calle 4-10, zona 2, San Marcos
3	Hospital Infantil de Retalhuleu	Hospital especializado en atención pediátrica.	Boulevard El Malecón, zona 1, Retalhuleu
\.


--
-- Data for Name: hospitalizacion_insumo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.hospitalizacion_insumo (id_hospitalizacion_insumo, ingreso_id, insumo_id, cantidad, costo_unitario) FROM stdin;
1	3	1	8	30.00
2	3	8	10	15.00
3	5	1	6	30.00
4	5	8	6	15.00
\.


--
-- Data for Name: ingreso; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.ingreso (id_ingreso, paciente_id, unidad_id, servicio_id, camilla_id, motivo_ingreso, fecha_hora_ingreso, medico_encargado_id, diagnostico_presuntivo) FROM stdin;
1	3	12	3	1	Politraumatismo por accidente de tránsito.	2026-08-10 04:10:00+00	1001	Traumatismo craneoencefálico leve; fractura de brazo derecho.
2	4	12	5	2	Fiebre alta persistente y deshidratación.	2026-08-20 20:05:00+00	1005	Cuadro febril viral en observación.
3	2	14	9	3	Hipertensión arterial descompensada.	2026-08-14 17:00:00+00	1005	Crisis hipertensiva en estudio.
4	5	13	17	\N	Ingreso a quirófano para apendicectomía de urgencia.	2026-08-12 00:35:00+00	1006	Apendicitis aguda.
5	5	14	15	4	Sala de recuperación postquirúrgica tras apendicectomía.	2026-08-12 03:00:00+00	1006	Postoperatorio de apendicectomía.
\.


--
-- Data for Name: instrumento; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.instrumento (id_instrumento, nombre, tipo, estado) FROM stdin;
1	Pinza Kelly	hemostasia	disponible
2	Pinza Mosquito	hemostasia	disponible
3	Porta agujas Mayo-Hegar	sutura	disponible
4	Tijera Mayo	corte	disponible
5	Tijera Metzenbaum	corte	disponible
6	Separador Farabeuf	separacion	disponible
7	Cuchillo de bisturí #3	corte	disponible
8	Aspirador quirúrgico	aspiración	disponible
9	Electrobisturí	coagulación	disponible
10	Lámpara de cirugía	iluminación	disponible
\.


--
-- Data for Name: insumo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.insumo (id_insumo, nombre, descripcion, material, tipo, unidad_medida, costo_unitario, stock_minimo, stock_actual) FROM stdin;
1	Gasas estériles 10x10	\N	\N	\N	paquete	15.00	50	120
2	Guantes quirúrgicos látex	\N	\N	\N	caja	85.00	30	80
3	Suero fisiológico 1L	\N	\N	\N	bolsa	12.00	40	100
4	Jeringa desechable 5ml	\N	\N	\N	unidad	2.50	100	300
5	Catéter venoso central	\N	\N	\N	unidad	45.00	10	25
6	Bisturí #10	\N	\N	\N	unidad	8.00	20	50
7	Hilo vicryl 3-0	\N	\N	\N	unidad	35.00	15	40
8	Algodón hidrófilo 100g	\N	\N	\N	rollo	18.00	25	60
9	Betadine solución 500ml	\N	\N	\N	frasco	55.00	10	30
10	Guantes de examen nitrilo	\N	\N	\N	caja	70.00	20	50
\.


--
-- Data for Name: medico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.medico (id_medico, nombres, apellidos, dpi, telefono, hospital_id, municipio_id, area, especialidad_id, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin) FROM stdin;
1001	Carmen	Ruiz Palacios	2001123450101	5551-2001	1	1	Urbana	307	general	200.00	08:00:00	12:00:00
1002	Roberto	Castillo Méndez	2001123450102	5551-2002	1	3	Urbana	301	especialista	220.00	08:00:00	11:30:00
1003	Andrea	Soto Fuentes	2001123450103	5551-2003	1	6	Rural	303	especialista	160.00	09:00:00	12:00:00
1004	Julia	Paredes Ovalle	2001123450104	5551-2004	1	1	Urbana	312	especialista	180.00	08:00:00	12:00:00
1005	Miguel	Barrios Donis	2001123450105	5551-2005	1	2	Rural	307	general	180.00	08:00:00	12:00:00
1006	Alejandro	Ramírez Lemus	2001123450106	5551-2006	1	1	Urbana	315	residente	\N	\N	\N
1007	Hilda	Cifuentes Rojas	2001123450107	5551-2007	2	6	Urbana	316	externo	\N	\N	\N
1008	Daniel	Morales Peña	2001123450108	5551-2008	1	1	Urbana	318	interno	\N	\N	\N
1009	Silvia	Vásquez Cotero	2001123450109	5551-2009	3	7	Urbana	317	especialista	\N	\N	\N
1010	Elena	Vasquez Sotelo	2001123450110	5551-2010	1	1	Urbana	302	especialista	180.00	08:00:00	12:00:00
1011	Marcos	Aguilar Salazar	2001123450111	5551-2011	1	1	Urbana	304	especialista	210.00	09:00:00	12:00:00
1012	Gabriela	Nájera	2001123450112	5551-2012	2	6	Urbana	305	especialista	195.00	08:00:00	11:30:00
1013	Fernando	López	2001123450113	5551-2013	1	3	Urbana	306	especialista	175.00	09:00:00	12:00:00
1014	Claudia	Recinos	2001123450114	5551-2014	2	6	Urbana	308	especialista	150.00	08:00:00	12:00:00
1015	Andrés	Chinchilla	2001123450115	5551-2015	1	1	Urbana	309	general	130.00	08:00:00	12:00:00
1016	Paola	Sandoval	2001123450116	5551-2016	3	7	Urbana	310	especialista	185.00	08:00:00	12:00:00
1017	Ricardo	Batz	2001123450117	5551-2017	1	1	Urbana	311	especialista	165.00	09:00:00	12:00:00
1018	Silvia	Gómez	2001123450118	5551-2018	1	3	Urbana	314	especialista	140.00	08:00:00	12:00:00
1019	Julio	Estrada	2001123450119	5551-2019	2	6	Urbana	313	especialista	190.00	08:00:00	12:00:00
1020	René	Iguarán	2001123450120	5551-2020	1	1	Urbana	319	externo	\N	\N	\N
1021	Wilfredo	Chávez	2001123450121	5551-2021	2	6	Urbana	320	externo	\N	\N	\N
1022	Ana	Lucero	2001123450122	5551-2022	3	1	Urbana	321	externo	\N	\N	\N
1023	Héctor	Quirós	2001123450123	5551-2023	1	3	Urbana	322	externo	\N	\N	\N
1024	Verónica	Aranda	2001123450124	5551-2024	2	1	Urbana	323	externo	\N	\N	\N
1025	Gustavo	Rivas	2001123450125	5551-2025	3	7	Urbana	324	externo	\N	\N	\N
1026	Mónica	Figueroa	2001123450126	5551-2026	1	1	Urbana	325	externo	\N	\N	\N
1027	Pablo	Tzoc	2001123450127	5551-2027	2	6	Urbana	326	externo	\N	\N	\N
1028	Isabel	Contreras	2001123450128	5551-2028	3	1	Urbana	327	externo	\N	\N	\N
1029	Carlos	Menández	2001123450129	5551-2029	1	3	Urbana	328	externo	\N	\N	\N
1030	Luis	Zambrano	2001123450130	5551-2030	2	6	Urbana	329	externo	\N	\N	\N
\.


--
-- Data for Name: municipio; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.municipio (id_municipio, departamento_id, nombre) FROM stdin;
1	13	Quetzaltenango
2	13	Coatepeque
3	13	Olintepeque
4	13	Zunil
5	13	Cantel
6	17	San Marcos
7	21	Totonicapán
\.


--
-- Data for Name: paciente; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.paciente (id_paciente, codigo_expediente, nombres, apellidos, fecha_nacimiento, "edad_años", sexo, dpi, telefono, municipio_id, area, estado_civil, no_seguro_social) FROM stdin;
1	HG1-0001	María Fernanda	López García	1988-04-12	38	Femenino	2220123450123	5551-1001	1	Urbana	Casada	IGSS-88432
2	HG1-0002	Jorge Luis	Ramírez Sosa	1990-11-03	35	Masculino	3330123450456	5551-1002	6	Rural	Soltero	\N
3	HG1-0003	Pedro	Gómez Aguilar	1975-07-22	51	Masculino	4440123450789	5551-1003	5	Rural	Casado	\N
4	HG1-0004	Ana Lucía	Méndez Cruz	2015-05-30	11	Femenino	5550123450104	5551-1004	1	Urbana	Soltera	IGSS-22150
5	HG1-0005	Carlos	De León Ortiz	1982-09-15	43	Masculino	66601234501230	5551-1005	3	Urbana	Casado	\N
6	HG2-0001	Sofía	Rivera Paz	2001-02-25	25	Femenino	7770123450650	5551-1006	6	Urbana	Soltera	\N
7	HG1-0006	Luis Miguel	Castillo Fuentes	1968-01-19	58	Masculino	8880123450901	5551-1007	4	Rural	Viudo	\N
\.


--
-- Data for Name: paciente_encargado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.paciente_encargado (id_paciente_encargado, paciente_id, encargado_id, parentesco) FROM stdin;
401	4	301	Madre
402	4	302	Padre
403	6	303	Hermana
\.


--
-- Data for Name: pago; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.pago (id_pago, factura_id, numero_cuota, total_cuotas, monto, fecha_pago) FROM stdin;
1	1	1	1	165.00	2026-08-10
2	2	1	3	600.00	2026-08-12
3	2	2	3	600.00	2026-09-12
4	3	1	4	1097.50	2026-08-18
5	3	2	4	1097.50	2026-09-18
6	4	1	6	1539.17	2026-08-12
7	4	2	6	1539.17	2026-09-12
8	5	1	3	1290.00	2026-08-14
\.


--
-- Data for Name: quirofano; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.quirofano (id_quirofano, hospital_id, numero, estado) FROM stdin;
1	1	1	disponible
2	1	2	disponible
3	1	3	disponible
4	1	4	disponible
\.


--
-- Data for Name: receta; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.receta (id_receta, consulta_id, fecha, proxima_cita) FROM stdin;
1	1	2026-08-10	2026-09-10
2	2	2026-08-11	\N
\.


--
-- Data for Name: receta_medicamento; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.receta_medicamento (id_receta_medicamento, receta_id, medicamento_nombre, dosis, duracion) FROM stdin;
1	1	Metoprolol 50 mg	1 tableta cada 12 horas	30 días
2	1	Losartán 50 mg	1 tableta en la mañana	30 días
3	2	Tramadol 50 mg (dolor)	1 tableta hasta cada 8 horas según dolor	5 días
\.


--
-- Data for Name: registro_procedimiento; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.registro_procedimiento (id_registro_procedimiento, cirugia_id, etapa, aspecto, exito, descripcion, hora_registro, enfermero_id, fecha_documentacion) FROM stdin;
1	1	preoperatorio	planificacion	t	Tabla quirúrgica disponible, equipos y quirófano preparados.	2026-08-12 00:15:00+00	2001	2026-08-12
2	1	preoperatorio	entrada	t	Paciente identificado con brazalete; ficha clínica y consentimiento firmado verificados.	2026-08-12 00:38:00+00	2001	2026-08-12
3	1	intraoperatorio	chequeo_quirofano	t	Equipo quirúrgico completo; traslado y posicionamiento correctos.	2026-08-12 00:45:00+00	2002	2026-08-12
4	1	intraoperatorio	pausa_quirurgica	t	Paciente y procedimiento confirmados; condiciones de esterilidad adecuadas.	2026-08-12 00:50:00+00	2002	2026-08-12
5	1	intraoperatorio	balance_hidrico	t	Balance hídrico registrado sin alteraciones.	2026-08-12 01:10:00+00	2002	2026-08-12
6	1	intraoperatorio	salida_quirurgica	t	Conteo de instrumental satisfactorio; cierre de incisión.	2026-08-12 02:05:00+00	2002	2026-08-12
7	1	postoperatorio	ingreso_sala_recuperacion	t	Ingreso a sala de recuperación con evolución sin complicaciones.	2026-08-12 02:25:00+00	2003	2026-08-12
8	1	postoperatorio	traslado_seguro	t	Signos vitales normales; zona operatoria limpia; documentación completa.	2026-08-12 03:15:00+00	2003	2026-08-12
\.


--
-- Data for Name: requerimiento_quirurgico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.requerimiento_quirurgico (id_requerimiento, agendamiento_id, tipo_recurso, insumo_id, instrumento_id, equipo_id, cantidad) FROM stdin;
1	1	instrumento	\N	1	\N	1
2	1	insumo	6	\N	\N	2
3	1	equipo	\N	\N	1	1
4	2	equipo	\N	\N	3	1
5	2	instrumento	\N	3	\N	4
\.


--
-- Data for Name: servicio_atencion; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.servicio_atencion (id_servicio, unidad_id, nombre, costo) FROM stdin;
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
\.


--
-- Data for Name: traslado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.traslado (id_traslado, fecha_hora, paciente_id, medico_indica_id, unidad_origen_id, unidad_destino_id, interno_externo, hospital_externo_nombre, hospital_externo_direccion, ingreso_id, consulta_id) FROM stdin;
1	2026-08-11 16:00:00+00	5	1005	11	13	interno	\N	\N	\N	2
2	2026-08-12 03:30:00+00	5	1006	13	14	interno	\N	\N	4	\N
3	2026-08-21 14:00:00+00	4	1005	12	25	externo	Hospital Regional de San Marcos	7a. calle 4-10, zona 2, San Marcos	2	\N
\.


--
-- Data for Name: unidad_medica; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.unidad_medica (id_unidad, hospital_id, nombre, costo_dia_hospitalizacion) FROM stdin;
11	1	Consulta Externa	\N
12	1	Emergencias	\N
13	1	Cirugia	\N
14	1	Hospitalizacion	600.00
15	1	Otro	\N
21	2	Consulta Externa	\N
22	2	Emergencias	\N
23	2	Cirugia	\N
24	2	Hospitalizacion	450.00
25	2	Otro	\N
31	3	Consulta Externa	\N
32	3	Emergencias	\N
33	3	Cirugia	\N
34	3	Hospitalizacion	520.00
35	3	Otro	\N
\.


--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.agendamiento_quirurgico_id_agendamiento_seq', 3, true);


--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.camilla_id_camilla_seq', 24, true);


--
-- Name: chequeo_preanestesico_id_chequeo_preanestesico_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.chequeo_preanestesico_id_chequeo_preanestesico_seq', 1, true);


--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cirugia_id_cirugia_seq', 1, true);


--
-- Name: cirugia_insumo_id_cirugia_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cirugia_insumo_id_cirugia_insumo_seq', 6, true);


--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cirugia_personal_id_cirugia_personal_seq', 4, true);


--
-- Name: cita_id_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cita_id_cita_seq', 5, true);


--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.consentimiento_informado_id_consentimiento_seq', 1, true);


--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.consulta_id_consulta_seq', 2, true);


--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.departamento_id_departamento_seq', 22, true);


--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.egreso_id_egreso_seq', 3, true);


--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.encargado_id_encargado_seq', 303, true);


--
-- Name: enfermero_id_enfermero_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.enfermero_id_enfermero_seq', 2005, true);


--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.equipo_id_equipo_seq', 8, true);


--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.especialidad_id_especialidad_seq', 329, true);


--
-- Name: factura_id_factura_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.factura_id_factura_seq', 5, true);


--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.historia_clinica_id_historia_clinica_seq', 1, true);


--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.hospital_id_hospital_seq', 3, true);


--
-- Name: hospitalizacion_insumo_id_hospitalizacion_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq', 4, true);


--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.ingreso_id_ingreso_seq', 5, true);


--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.instrumento_id_instrumento_seq', 10, true);


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.insumo_id_insumo_seq', 10, true);


--
-- Name: medico_id_medico_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.medico_id_medico_seq', 1030, true);


--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.municipio_id_municipio_seq', 7, true);


--
-- Name: paciente_encargado_id_paciente_encargado_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.paciente_encargado_id_paciente_encargado_seq', 403, true);


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.paciente_id_paciente_seq', 7, true);


--
-- Name: pago_id_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.pago_id_pago_seq', 8, true);


--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.quirofano_id_quirofano_seq', 4, true);


--
-- Name: receta_id_receta_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.receta_id_receta_seq', 2, true);


--
-- Name: receta_medicamento_id_receta_medicamento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.receta_medicamento_id_receta_medicamento_seq', 3, true);


--
-- Name: registro_procedimiento_id_registro_procedimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.registro_procedimiento_id_registro_procedimiento_seq', 8, true);


--
-- Name: requerimiento_quirurgico_id_requerimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.requerimiento_quirurgico_id_requerimiento_seq', 5, true);


--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.servicio_atencion_id_servicio_seq', 19, true);


--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.traslado_id_traslado_seq', 3, true);


--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.unidad_medica_id_unidad_seq', 35, true);


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_pkey PRIMARY KEY (id_agendamiento);


--
-- Name: camilla camilla_hospital_id_numero_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_hospital_id_numero_key UNIQUE (hospital_id, numero);


--
-- Name: camilla camilla_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_pkey PRIMARY KEY (id_camilla);


--
-- Name: chequeo_preanestesico chequeo_preanestesico_agendamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_agendamiento_id_key UNIQUE (agendamiento_id);


--
-- Name: chequeo_preanestesico chequeo_preanestesico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_pkey PRIMARY KEY (id_chequeo_preanestesico);


--
-- Name: cirugia cirugia_agendamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_agendamiento_id_key UNIQUE (agendamiento_id);


--
-- Name: cirugia_insumo cirugia_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_pkey PRIMARY KEY (id_cirugia_insumo);


--
-- Name: cirugia_personal cirugia_personal_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_pkey PRIMARY KEY (id_cirugia_personal);


--
-- Name: cirugia cirugia_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_pkey PRIMARY KEY (id_cirugia);


--
-- Name: cita cita_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_pkey PRIMARY KEY (id_cita);


--
-- Name: consentimiento_informado consentimiento_informado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_pkey PRIMARY KEY (id_consentimiento);


--
-- Name: consulta consulta_cita_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_cita_id_key UNIQUE (cita_id);


--
-- Name: consulta consulta_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_pkey PRIMARY KEY (id_consulta);


--
-- Name: departamento departamento_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_nombre_key UNIQUE (nombre);


--
-- Name: departamento departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_pkey PRIMARY KEY (id_departamento);


--
-- Name: egreso egreso_ingreso_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_ingreso_id_key UNIQUE (ingreso_id);


--
-- Name: egreso egreso_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_pkey PRIMARY KEY (id_egreso);


--
-- Name: encargado encargado_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_dpi_key UNIQUE (dpi);


--
-- Name: encargado encargado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_pkey PRIMARY KEY (id_encargado);


--
-- Name: enfermero enfermero_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT enfermero_dpi_key UNIQUE (dpi);


--
-- Name: enfermero enfermero_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT enfermero_pkey PRIMARY KEY (id_enfermero);


--
-- Name: equipo equipo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.equipo
    ADD CONSTRAINT equipo_pkey PRIMARY KEY (id_equipo);


--
-- Name: especialidad especialidad_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_nombre_key UNIQUE (nombre);


--
-- Name: especialidad especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: factura factura_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_pkey PRIMARY KEY (id_factura);


--
-- Name: historia_clinica historia_clinica_agendamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_agendamiento_id_key UNIQUE (agendamiento_id);


--
-- Name: historia_clinica historia_clinica_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_pkey PRIMARY KEY (id_historia_clinica);


--
-- Name: hospital hospital_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (id_hospital);


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_pkey PRIMARY KEY (id_hospitalizacion_insumo);


--
-- Name: ingreso ingreso_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_pkey PRIMARY KEY (id_ingreso);


--
-- Name: instrumento instrumento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.instrumento
    ADD CONSTRAINT instrumento_pkey PRIMARY KEY (id_instrumento);


--
-- Name: insumo insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.insumo
    ADD CONSTRAINT insumo_pkey PRIMARY KEY (id_insumo);


--
-- Name: medico medico_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_dpi_key UNIQUE (dpi);


--
-- Name: medico medico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_pkey PRIMARY KEY (id_medico);


--
-- Name: municipio municipio_departamento_id_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_departamento_id_nombre_key UNIQUE (departamento_id, nombre);


--
-- Name: municipio municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_pkey PRIMARY KEY (id_municipio);


--
-- Name: paciente paciente_codigo_expediente_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_codigo_expediente_key UNIQUE (codigo_expediente);


--
-- Name: paciente paciente_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_dpi_key UNIQUE (dpi);


--
-- Name: paciente_encargado paciente_encargado_paciente_id_encargado_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_paciente_id_encargado_id_key UNIQUE (paciente_id, encargado_id);


--
-- Name: paciente_encargado paciente_encargado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_pkey PRIMARY KEY (id_paciente_encargado);


--
-- Name: paciente paciente_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id_paciente);


--
-- Name: pago pago_factura_id_numero_cuota_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_factura_id_numero_cuota_key UNIQUE (factura_id, numero_cuota);


--
-- Name: pago pago_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (id_pago);


--
-- Name: quirofano quirofano_hospital_id_numero_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_hospital_id_numero_key UNIQUE (hospital_id, numero);


--
-- Name: quirofano quirofano_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_pkey PRIMARY KEY (id_quirofano);


--
-- Name: receta receta_consulta_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_consulta_id_key UNIQUE (consulta_id);


--
-- Name: receta_medicamento receta_medicamento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_pkey PRIMARY KEY (id_receta_medicamento);


--
-- Name: receta receta_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_pkey PRIMARY KEY (id_receta);


--
-- Name: registro_procedimiento registro_procedimiento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_pkey PRIMARY KEY (id_registro_procedimiento);


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_pkey PRIMARY KEY (id_requerimiento);


--
-- Name: servicio_atencion servicio_atencion_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_pkey PRIMARY KEY (id_servicio);


--
-- Name: servicio_atencion servicio_atencion_unidad_id_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_unidad_id_nombre_key UNIQUE (unidad_id, nombre);


--
-- Name: traslado traslado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_pkey PRIMARY KEY (id_traslado);


--
-- Name: unidad_medica unidad_medica_hospital_id_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_hospital_id_nombre_key UNIQUE (hospital_id, nombre);


--
-- Name: unidad_medica unidad_medica_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_pkey PRIMARY KEY (id_unidad);


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_medico_cirujano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_medico_cirujano_id_fkey FOREIGN KEY (medico_cirujano_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_quirofano_solicitado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_quirofano_solicitado_id_fkey FOREIGN KEY (quirofano_solicitado_id) REFERENCES public.quirofano(id_quirofano) ON UPDATE CASCADE;


--
-- Name: camilla camilla_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: camilla camilla_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: chequeo_preanestesico chequeo_preanestesico_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE;


--
-- Name: cirugia cirugia_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE;


--
-- Name: cirugia cirugia_cirujano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_cirujano_id_fkey FOREIGN KEY (cirujano_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: cirugia cirugia_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE;


--
-- Name: cirugia_insumo cirugia_insumo_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_insumo cirugia_insumo_insumo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_insumo_id_fkey FOREIGN KEY (insumo_id) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE;


--
-- Name: cirugia cirugia_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: cirugia_personal cirugia_personal_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_personal cirugia_personal_enfermero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_enfermero_id_fkey FOREIGN KEY (enfermero_id) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE;


--
-- Name: cirugia_personal cirugia_personal_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: cirugia cirugia_quirofano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_quirofano_id_fkey FOREIGN KEY (quirofano_id) REFERENCES public.quirofano(id_quirofano) ON UPDATE CASCADE;


--
-- Name: cita cita_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: cita cita_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: consentimiento_informado consentimiento_informado_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consulta consulta_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.cita(id_cita) ON UPDATE CASCADE;


--
-- Name: consulta consulta_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: consulta consulta_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: egreso egreso_camilla_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_camilla_id_fkey FOREIGN KEY (camilla_id) REFERENCES public.camilla(id_camilla) ON UPDATE CASCADE;


--
-- Name: egreso egreso_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE;


--
-- Name: egreso egreso_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: egreso egreso_servicio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_servicio_id_fkey FOREIGN KEY (servicio_id) REFERENCES public.servicio_atencion(id_servicio) ON UPDATE CASCADE;


--
-- Name: egreso egreso_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE;


--
-- Name: encargado encargado_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE;


--
-- Name: factura factura_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE;


--
-- Name: factura factura_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.cita(id_cita) ON UPDATE CASCADE;


--
-- Name: factura factura_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE;


--
-- Name: factura factura_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: historia_clinica historia_clinica_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE;


--
-- Name: historia_clinica historia_clinica_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_insumo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_insumo_id_fkey FOREIGN KEY (insumo_id) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE;


--
-- Name: ingreso ingreso_camilla_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_camilla_id_fkey FOREIGN KEY (camilla_id) REFERENCES public.camilla(id_camilla) ON UPDATE CASCADE;


--
-- Name: ingreso ingreso_medico_encargado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_medico_encargado_id_fkey FOREIGN KEY (medico_encargado_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: ingreso ingreso_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: ingreso ingreso_servicio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_servicio_id_fkey FOREIGN KEY (servicio_id) REFERENCES public.servicio_atencion(id_servicio) ON UPDATE CASCADE;


--
-- Name: ingreso ingreso_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE;


--
-- Name: medico medico_especialidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_especialidad_id_fkey FOREIGN KEY (especialidad_id) REFERENCES public.especialidad(id_especialidad) ON UPDATE CASCADE;


--
-- Name: medico medico_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: medico medico_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE;


--
-- Name: municipio municipio_departamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamento(id_departamento) ON UPDATE CASCADE;


--
-- Name: paciente_encargado paciente_encargado_encargado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_encargado_id_fkey FOREIGN KEY (encargado_id) REFERENCES public.encargado(id_encargado) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente_encargado paciente_encargado_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente paciente_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE;


--
-- Name: pago pago_factura_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_factura_id_fkey FOREIGN KEY (factura_id) REFERENCES public.factura(id_factura) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: quirofano quirofano_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: receta receta_consulta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_consulta_id_fkey FOREIGN KEY (consulta_id) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE;


--
-- Name: receta_medicamento receta_medicamento_receta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_receta_id_fkey FOREIGN KEY (receta_id) REFERENCES public.receta(id_receta) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro_procedimiento registro_procedimiento_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro_procedimiento registro_procedimiento_enfermero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_enfermero_id_fkey FOREIGN KEY (enfermero_id) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_equipo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_equipo_id_fkey FOREIGN KEY (equipo_id) REFERENCES public.equipo(id_equipo) ON UPDATE CASCADE;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_instrumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_instrumento_id_fkey FOREIGN KEY (instrumento_id) REFERENCES public.instrumento(id_instrumento) ON UPDATE CASCADE;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_insumo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_insumo_id_fkey FOREIGN KEY (insumo_id) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE;


--
-- Name: servicio_atencion servicio_atencion_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: traslado traslado_consulta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_consulta_id_fkey FOREIGN KEY (consulta_id) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE;


--
-- Name: traslado traslado_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE;


--
-- Name: traslado traslado_medico_indica_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_medico_indica_id_fkey FOREIGN KEY (medico_indica_id) REFERENCES public.medico(id_medico) ON UPDATE CASCADE;


--
-- Name: traslado traslado_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE;


--
-- Name: traslado traslado_unidad_destino_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_unidad_destino_id_fkey FOREIGN KEY (unidad_destino_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE;


--
-- Name: traslado traslado_unidad_origen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_unidad_origen_id_fkey FOREIGN KEY (unidad_origen_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE;


--
-- Name: unidad_medica unidad_medica_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DATABASE hospital; Type: ACL; Schema: -; Owner: hospital
--

REVOKE CONNECT,TEMPORARY ON DATABASE hospital FROM PUBLIC;
GRANT TEMPORARY ON DATABASE hospital TO PUBLIC;
GRANT CONNECT ON DATABASE hospital TO usuario_auditoria;
GRANT CONNECT ON DATABASE hospital TO usuario_admin;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: hospital
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict T266OHoMvOIrdV5HmjOl5klQe5fRMmqErYilYQLhn1Xc3YwpYbis2YdfKPZSXmB

--
-- Database "hospital_restaurada" dump
--

--
-- PostgreSQL database dump
--

\restrict ZH0k4Wb5g8xTyqT85v5GzbzcY3JvhS9eaQTCx2tav1Urr5XRjUiWTgL1E9cKhcB

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
-- Name: hospital_restaurada; Type: DATABASE; Schema: -; Owner: hospital
--

CREATE DATABASE hospital_restaurada WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE hospital_restaurada OWNER TO hospital;

\unrestrict ZH0k4Wb5g8xTyqT85v5GzbzcY3JvhS9eaQTCx2tav1Urr5XRjUiWTgL1E9cKhcB
\connect hospital_restaurada
\restrict ZH0k4Wb5g8xTyqT85v5GzbzcY3JvhS9eaQTCx2tav1Urr5XRjUiWTgL1E9cKhcB

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
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'Esquema principal de la base de datos de Hospitales de Occidente.';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agendamiento_quirurgico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.agendamiento_quirurgico (
    id_agendamiento integer NOT NULL,
    paciente_id integer NOT NULL,
    medico_cirujano_id integer NOT NULL,
    caracter character varying(15) NOT NULL,
    historia_clinica text,
    tipo_procedimiento text NOT NULL,
    tiempo_estimado_min smallint NOT NULL,
    tipo_anestesia character varying(80) NOT NULL,
    fecha_hora_solicitud timestamp with time zone NOT NULL,
    estado_solicitud character varying(15) NOT NULL,
    motivo_rechazo text,
    quirofano_solicitado_id integer,
    fecha_hora_agendada timestamp with time zone,
    CONSTRAINT chk_agendamiento_caracter CHECK (((caracter)::text = ANY (ARRAY[('urgente'::character varying)::text, ('programado'::character varying)::text]))),
    CONSTRAINT chk_agendamiento_estado CHECK (((estado_solicitud)::text = ANY (ARRAY[('pendiente'::character varying)::text, ('aprobada'::character varying)::text, ('rechazada'::character varying)::text]))),
    CONSTRAINT chk_agendamiento_rechazo CHECK ((((estado_solicitud)::text <> 'rechazada'::text) OR (motivo_rechazo IS NOT NULL))),
    CONSTRAINT chk_agendamiento_tiempo CHECK ((tiempo_estimado_min > 0))
);


ALTER TABLE public.agendamiento_quirurgico OWNER TO hospital;

--
-- Name: CONSTRAINT chk_agendamiento_caracter ON agendamiento_quirurgico; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_agendamiento_caracter ON public.agendamiento_quirurgico IS 'Valida caracter de la cirugia: urgente o programado.';


--
-- Name: CONSTRAINT chk_agendamiento_estado ON agendamiento_quirurgico; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_agendamiento_estado ON public.agendamiento_quirurgico IS 'Valida estado de la solicitud (pendiente, aprobada, rechazada).';


--
-- Name: CONSTRAINT chk_agendamiento_rechazo ON agendamiento_quirurgico; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_agendamiento_rechazo ON public.agendamiento_quirurgico IS 'Valida que una solicitud rechazada indique las razones.';


--
-- Name: CONSTRAINT chk_agendamiento_tiempo ON agendamiento_quirurgico; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_agendamiento_tiempo ON public.agendamiento_quirurgico IS 'Valida que el tiempo estimado de la intervencion sea positivo.';


--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.agendamiento_quirurgico ALTER COLUMN id_agendamiento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.agendamiento_quirurgico_id_agendamiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: camilla; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.camilla (
    id_camilla integer NOT NULL,
    hospital_id integer NOT NULL,
    unidad_id integer NOT NULL,
    numero character varying(10) NOT NULL,
    disponible boolean DEFAULT true NOT NULL
);


ALTER TABLE public.camilla OWNER TO hospital;

--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.camilla ALTER COLUMN id_camilla ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.camilla_id_camilla_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: chequeo_preanestesico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.chequeo_preanestesico (
    id_chequeo_preanestesico integer NOT NULL,
    agendamiento_id integer NOT NULL,
    clasificacion_asa character varying(5) NOT NULL,
    medico_asa_nombre character varying(150) NOT NULL,
    plan_anestesia text NOT NULL,
    anestesista_nombre character varying(150) NOT NULL,
    CONSTRAINT chk_preanestesico_asa CHECK (((clasificacion_asa)::text = ANY (ARRAY[('I'::character varying)::text, ('II'::character varying)::text, ('III'::character varying)::text, ('IV'::character varying)::text, ('V'::character varying)::text, ('VI'::character varying)::text])))
);


ALTER TABLE public.chequeo_preanestesico OWNER TO hospital;

--
-- Name: CONSTRAINT chk_preanestesico_asa ON chequeo_preanestesico; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_preanestesico_asa ON public.chequeo_preanestesico IS 'Valida clasificacion ASA del riesgo anestesico (I a VI).';


--
-- Name: chequeo_preanestesico_id_chequeo_preanestesico_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.chequeo_preanestesico ALTER COLUMN id_chequeo_preanestesico ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.chequeo_preanestesico_id_chequeo_preanestesico_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cirugia; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cirugia (
    id_cirugia integer NOT NULL,
    agendamiento_id integer NOT NULL,
    quirofano_id integer NOT NULL,
    paciente_id integer NOT NULL,
    cirujano_id integer NOT NULL,
    ingreso_id integer,
    fecha_hora_inicio timestamp with time zone NOT NULL,
    fecha_hora_fin timestamp with time zone,
    condicion_evolucion character varying(25),
    estado character varying(20) NOT NULL,
    CONSTRAINT chk_cirugia_condicion CHECK (((condicion_evolucion)::text = ANY (ARRAY[('sin_complicaciones'::character varying)::text, ('complicaciones'::character varying)::text, ('complicaciones_graves'::character varying)::text]))),
    CONSTRAINT chk_cirugia_estado CHECK (((estado)::text = ANY (ARRAY[('preoperatorio'::character varying)::text, ('intraoperatorio'::character varying)::text, ('postoperatorio'::character varying)::text, ('finalizada'::character varying)::text])))
);


ALTER TABLE public.cirugia OWNER TO hospital;

--
-- Name: CONSTRAINT chk_cirugia_condicion ON cirugia; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_cirugia_condicion ON public.cirugia IS 'Valida condicion de evolucion durante la cirugia (sin complicaciones, complicaciones, complicaciones graves).';


--
-- Name: CONSTRAINT chk_cirugia_estado ON cirugia; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_cirugia_estado ON public.cirugia IS 'Valida etapa de la cirugia (preoperatorio, intraoperatorio, postoperatorio, finalizada).';


--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.cirugia ALTER COLUMN id_cirugia ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cirugia_id_cirugia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cirugia_insumo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cirugia_insumo (
    id_cirugia_insumo integer NOT NULL,
    cirugia_id integer NOT NULL,
    insumo_id integer NOT NULL,
    cantidad smallint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL,
    CONSTRAINT chk_cirugia_insumo_cantidad CHECK ((cantidad > 0)),
    CONSTRAINT chk_cirugia_insumo_costo CHECK ((costo_unitario >= (0)::numeric))
);


ALTER TABLE public.cirugia_insumo OWNER TO hospital;

--
-- Name: CONSTRAINT chk_cirugia_insumo_cantidad ON cirugia_insumo; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_cirugia_insumo_cantidad ON public.cirugia_insumo IS 'Valida cantidad de insumo utilizada mayor que cero.';


--
-- Name: CONSTRAINT chk_cirugia_insumo_costo ON cirugia_insumo; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_cirugia_insumo_costo ON public.cirugia_insumo IS 'Valida costo unitario del insumo no negativo.';


--
-- Name: cirugia_insumo_id_cirugia_insumo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.cirugia_insumo ALTER COLUMN id_cirugia_insumo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cirugia_insumo_id_cirugia_insumo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cirugia_personal; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cirugia_personal (
    id_cirugia_personal integer NOT NULL,
    cirugia_id integer NOT NULL,
    medico_id integer,
    enfermero_id integer,
    rol character varying(60) NOT NULL,
    CONSTRAINT chk_personal_un_tipo CHECK (((((medico_id IS NOT NULL))::integer + ((enfermero_id IS NOT NULL))::integer) = 1))
);


ALTER TABLE public.cirugia_personal OWNER TO hospital;

--
-- Name: CONSTRAINT chk_personal_un_tipo ON cirugia_personal; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_personal_un_tipo ON public.cirugia_personal IS 'Valida que la participacion corresponda a un medico o a un enfermero, no a ambos.';


--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.cirugia_personal ALTER COLUMN id_cirugia_personal ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cirugia_personal_id_cirugia_personal_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cita; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.cita (
    id_cita integer NOT NULL,
    paciente_id integer NOT NULL,
    medico_id integer NOT NULL,
    fecha_hora timestamp with time zone NOT NULL,
    num_clinica character varying(20) NOT NULL,
    medio_asignacion character varying(20),
    estado character varying(20) DEFAULT 'programada'::character varying NOT NULL,
    es_reconsulta boolean DEFAULT false NOT NULL,
    es_referido boolean DEFAULT false NOT NULL,
    costo_base numeric(10,2),
    costo_aplicado numeric(10,2),
    cancelada_sin_aviso boolean DEFAULT false NOT NULL,
    CONSTRAINT chk_cita_costo_aplicado CHECK (((costo_aplicado IS NULL) OR (costo_aplicado >= (0)::numeric))),
    CONSTRAINT chk_cita_costos CHECK (((costo_base IS NULL) OR (costo_base >= (0)::numeric))),
    CONSTRAINT chk_cita_estado CHECK (((estado)::text = ANY (ARRAY[('programada'::character varying)::text, ('realizada'::character varying)::text, ('reprogramada'::character varying)::text, ('cancelada'::character varying)::text]))),
    CONSTRAINT chk_cita_medio CHECK (((medio_asignacion)::text = ANY (ARRAY[('telefonico'::character varying)::text, ('correo_institucional'::character varying)::text, ('recepcion_general'::character varying)::text, ('recepcion_medico'::character varying)::text])))
);


ALTER TABLE public.cita OWNER TO hospital;

--
-- Name: CONSTRAINT chk_cita_costo_aplicado ON cita; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_cita_costo_aplicado ON public.cita IS 'Valida que el costo aplicado (con descuentos/sobrecargos) sea mayor o igual a cero.';


--
-- Name: CONSTRAINT chk_cita_costos ON cita; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_cita_costos ON public.cita IS 'Valida que el costo base de la cita sea mayor o igual a cero.';


--
-- Name: CONSTRAINT chk_cita_estado ON cita; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_cita_estado ON public.cita IS 'Valida estado de la cita (programada, realizada, reprogramada, cancelada).';


--
-- Name: CONSTRAINT chk_cita_medio ON cita; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_cita_medio ON public.cita IS 'Valida medio de asignacion de la cita (telefonico, correo, recepciones).';


--
-- Name: cita_id_cita_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.cita ALTER COLUMN id_cita ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cita_id_cita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: consentimiento_informado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.consentimiento_informado (
    id_consentimiento integer NOT NULL,
    agendamiento_id integer NOT NULL,
    procedimiento_nombre text NOT NULL,
    procedimiento_objetivo text NOT NULL,
    procedimiento_caracteristicas text NOT NULL,
    procedimiento_riesgos text NOT NULL,
    medico_nombre character varying(150) NOT NULL,
    medico_firmado boolean DEFAULT false NOT NULL,
    paciente_firma_nombre character varying(150) NOT NULL,
    paciente_firmado boolean DEFAULT false NOT NULL,
    fecha_obtencion date NOT NULL
);


ALTER TABLE public.consentimiento_informado OWNER TO hospital;

--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.consentimiento_informado ALTER COLUMN id_consentimiento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.consentimiento_informado_id_consentimiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: consulta; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.consulta (
    id_consulta integer NOT NULL,
    cita_id integer NOT NULL,
    paciente_id integer NOT NULL,
    medico_id integer NOT NULL,
    fecha date NOT NULL,
    diagnostico text NOT NULL,
    otros_datos text,
    notas_observaciones text
);


ALTER TABLE public.consulta OWNER TO hospital;

--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.consulta ALTER COLUMN id_consulta ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.consulta_id_consulta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: egreso; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.egreso (
    id_egreso integer NOT NULL,
    ingreso_id integer NOT NULL,
    diagnostico_principal text NOT NULL,
    diagnosticos_secundarios text,
    motivo_egreso text NOT NULL,
    unidad_id integer NOT NULL,
    servicio_id integer,
    fecha_hora_egreso timestamp with time zone NOT NULL,
    medico_id integer NOT NULL,
    camilla_id integer,
    codigo_egreso character varying(15) NOT NULL,
    egreso_sin_consentimiento boolean DEFAULT false NOT NULL,
    motivo_egreso_sin_consentimiento text,
    dias_hospitalizado smallint,
    codigo_traslado character varying(20),
    referido_otro_hospital boolean DEFAULT false NOT NULL,
    CONSTRAINT chk_egreso_codigo CHECK (((codigo_egreso)::text = ANY (ARRAY[('vivo'::character varying)::text, ('muerto'::character varying)::text, ('embarazo'::character varying)::text, ('parto'::character varying)::text]))),
    CONSTRAINT chk_egreso_consentimiento CHECK (((NOT egreso_sin_consentimiento) OR (motivo_egreso_sin_consentimiento IS NOT NULL))),
    CONSTRAINT chk_egreso_dias CHECK (((dias_hospitalizado IS NULL) OR (dias_hospitalizado > 0)))
);


ALTER TABLE public.egreso OWNER TO hospital;

--
-- Name: CONSTRAINT chk_egreso_codigo ON egreso; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_egreso_codigo ON public.egreso IS 'Valida codigo de egreso (vivo, muerto, embarazo, parto).';


--
-- Name: CONSTRAINT chk_egreso_consentimiento ON egreso; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_egreso_consentimiento ON public.egreso IS 'Valida que el motivo sea obligatorio cuando hubo egreso sin consentimiento medico.';


--
-- Name: CONSTRAINT chk_egreso_dias ON egreso; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_egreso_dias ON public.egreso IS 'Valida que los dias hospitalizado sean positivos cuando se registran.';


--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.egreso ALTER COLUMN id_egreso ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.egreso_id_egreso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: encargado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.encargado (
    id_encargado integer NOT NULL,
    nombre character varying(150) NOT NULL,
    dpi character varying(20),
    telefono character varying(20),
    municipio character varying(80),
    departamento character varying(80),
    area character varying(10),
    CONSTRAINT chk_encargado_area CHECK (((area)::text = ANY (ARRAY[('Urbana'::character varying)::text, ('Rural'::character varying)::text])))
);


ALTER TABLE public.encargado OWNER TO hospital;

--
-- Name: CONSTRAINT chk_encargado_area ON encargado; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_encargado_area ON public.encargado IS 'Valida area de residencia del encargado (Urbana/Rural).';


--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.encargado ALTER COLUMN id_encargado ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.encargado_id_encargado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: enfermero; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.enfermero (
    id_enfermero integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character varying(20) NOT NULL,
    telefono character varying(20),
    tipo character varying(30) NOT NULL,
    CONSTRAINT chk_enfermero_tipo CHECK (((tipo)::text = ANY (ARRAY[('registrado'::character varying)::text, ('practicante_de_enfermeria'::character varying)::text])))
);


ALTER TABLE public.enfermero OWNER TO hospital;

--
-- Name: CONSTRAINT chk_enfermero_tipo ON enfermero; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_enfermero_tipo ON public.enfermero IS 'Valida tipo de enfermero: registrado o practicante de enfermeria.';


--
-- Name: enfermero_id_enfermero_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.enfermero ALTER COLUMN id_enfermero ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.enfermero_id_enfermero_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: equipo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.equipo (
    id_equipo integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    tipo character varying(20) NOT NULL,
    funcion character varying(30) NOT NULL,
    CONSTRAINT chk_equipo_funcion CHECK (((funcion)::text = ANY (ARRAY[('exploracion'::character varying)::text, ('diagnostico'::character varying)::text, ('tratamiento'::character varying)::text, ('rehabilitacion'::character varying)::text, ('otro'::character varying)::text]))),
    CONSTRAINT chk_equipo_tipo CHECK (((tipo)::text = ANY (ARRAY[('medico'::character varying)::text, ('quirurgico'::character varying)::text, ('otro'::character varying)::text])))
);


ALTER TABLE public.equipo OWNER TO hospital;

--
-- Name: CONSTRAINT chk_equipo_funcion ON equipo; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_equipo_funcion ON public.equipo IS 'Valida funcion del equipo (exploracion, diagnostico, tratamiento, rehabilitacion, otro).';


--
-- Name: CONSTRAINT chk_equipo_tipo ON equipo; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_equipo_tipo ON public.equipo IS 'Valida tipo de equipo: medico, quirurgico u otro.';


--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.equipo ALTER COLUMN id_equipo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.equipo_id_equipo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: especialidad; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.especialidad (
    id_especialidad integer NOT NULL,
    nombre character varying(80) NOT NULL
);


ALTER TABLE public.especialidad OWNER TO hospital;

--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.especialidad ALTER COLUMN id_especialidad ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.especialidad_id_especialidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: factura; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.factura (
    id_factura integer NOT NULL,
    paciente_id integer NOT NULL,
    fecha_emision timestamp with time zone NOT NULL,
    descripcion text NOT NULL,
    total numeric(10,2) NOT NULL,
    cita_id integer,
    ingreso_id integer,
    cirugia_id integer,
    CONSTRAINT chk_factura_origen CHECK ((((((cita_id IS NOT NULL))::integer + ((ingreso_id IS NOT NULL))::integer) + ((cirugia_id IS NOT NULL))::integer) >= 1)),
    CONSTRAINT chk_factura_total CHECK ((total >= (0)::numeric))
);


ALTER TABLE public.factura OWNER TO hospital;

--
-- Name: CONSTRAINT chk_factura_origen ON factura; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_factura_origen ON public.factura IS 'Valida que la factura este asociada a al menos un servicio (cita, ingreso o cirugia).';


--
-- Name: CONSTRAINT chk_factura_total ON factura; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_factura_total ON public.factura IS 'Valida que el total de la factura no sea negativo.';


--
-- Name: factura_id_factura_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.factura ALTER COLUMN id_factura ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.factura_id_factura_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: historia_clinica; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.historia_clinica (
    id_historia_clinica integer NOT NULL,
    agendamiento_id integer NOT NULL,
    medico_id integer NOT NULL,
    fecha date NOT NULL,
    fuente_interrogatorio character varying(10) NOT NULL,
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
    CONSTRAINT chk_historia_fuente CHECK (((fuente_interrogatorio)::text = ANY (ARRAY[('directo'::character varying)::text, ('indirecto'::character varying)::text])))
);


ALTER TABLE public.historia_clinica OWNER TO hospital;

--
-- Name: CONSTRAINT chk_historia_fuente ON historia_clinica; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_historia_fuente ON public.historia_clinica IS 'Valida fuente del interrogatorio: directo (paciente) o indirecto (familiar/amigo).';


--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.historia_clinica ALTER COLUMN id_historia_clinica ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.historia_clinica_id_historia_clinica_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hospital; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.hospital (
    id_hospital integer NOT NULL,
    nombre character varying(120) NOT NULL,
    informacion_especifica text,
    direccion character varying(250) NOT NULL
);


ALTER TABLE public.hospital OWNER TO hospital;

--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.hospital ALTER COLUMN id_hospital ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.hospital_id_hospital_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hospitalizacion_insumo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.hospitalizacion_insumo (
    id_hospitalizacion_insumo integer NOT NULL,
    ingreso_id integer NOT NULL,
    insumo_id integer NOT NULL,
    cantidad smallint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL,
    CONSTRAINT chk_hospitalizacion_insumo_cantidad CHECK ((cantidad > 0)),
    CONSTRAINT chk_hospitalizacion_insumo_costo CHECK ((costo_unitario >= (0)::numeric))
);


ALTER TABLE public.hospitalizacion_insumo OWNER TO hospital;

--
-- Name: CONSTRAINT chk_hospitalizacion_insumo_cantidad ON hospitalizacion_insumo; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_hospitalizacion_insumo_cantidad ON public.hospitalizacion_insumo IS 'Valida cantidad de insumo usada mayor que cero.';


--
-- Name: CONSTRAINT chk_hospitalizacion_insumo_costo ON hospitalizacion_insumo; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_hospitalizacion_insumo_costo ON public.hospitalizacion_insumo IS 'Valida costo unitario del insumo no negativo.';


--
-- Name: hospitalizacion_insumo_id_hospitalizacion_insumo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.hospitalizacion_insumo ALTER COLUMN id_hospitalizacion_insumo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ingreso; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.ingreso (
    id_ingreso integer NOT NULL,
    paciente_id integer NOT NULL,
    unidad_id integer NOT NULL,
    servicio_id integer,
    camilla_id integer,
    motivo_ingreso text NOT NULL,
    fecha_hora_ingreso timestamp with time zone NOT NULL,
    medico_encargado_id integer NOT NULL,
    diagnostico_presuntivo text
);


ALTER TABLE public.ingreso OWNER TO hospital;

--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.ingreso ALTER COLUMN id_ingreso ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ingreso_id_ingreso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: instrumento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.instrumento (
    id_instrumento integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    tipo character varying(20) NOT NULL,
    funcion character varying(30) NOT NULL,
    CONSTRAINT chk_instrumento_funcion CHECK (((funcion)::text = ANY (ARRAY[('corte'::character varying)::text, ('contencion'::character varying)::text, ('hemostatica'::character varying)::text, ('retractor'::character varying)::text, ('accesorio'::character varying)::text, ('implante'::character varying)::text, ('otro'::character varying)::text]))),
    CONSTRAINT chk_instrumento_tipo CHECK (((tipo)::text = ANY (ARRAY[('medico'::character varying)::text, ('quirurgico'::character varying)::text, ('otro'::character varying)::text])))
);


ALTER TABLE public.instrumento OWNER TO hospital;

--
-- Name: CONSTRAINT chk_instrumento_funcion ON instrumento; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_instrumento_funcion ON public.instrumento IS 'Valida funcion del instrumento (corte, contencion, hemostatica, retractor, accesorio, implante, otro).';


--
-- Name: CONSTRAINT chk_instrumento_tipo ON instrumento; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_instrumento_tipo ON public.instrumento IS 'Valida tipo de instrumento: medico, quirurgico u otro.';


--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.instrumento ALTER COLUMN id_instrumento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.instrumento_id_instrumento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insumo; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.insumo (
    id_insumo integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    material character varying(80),
    tipo character varying(20) NOT NULL,
    CONSTRAINT chk_insumo_tipo CHECK (((tipo)::text = ANY (ARRAY[('medico'::character varying)::text, ('quirurgico'::character varying)::text, ('otro'::character varying)::text])))
);


ALTER TABLE public.insumo OWNER TO hospital;

--
-- Name: CONSTRAINT chk_insumo_tipo ON insumo; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_insumo_tipo ON public.insumo IS 'Valida tipo de insumo: medico, quirurgico u otro.';


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.insumo ALTER COLUMN id_insumo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.insumo_id_insumo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: medico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.medico (
    id_medico integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character varying(20) NOT NULL,
    telefono character varying(20),
    municipio character varying(80),
    departamento character varying(80),
    area character varying(10),
    especialidad_id integer,
    tipo_medico character varying(20) NOT NULL,
    costo_primera_consulta numeric(10,2),
    horario_inicio time without time zone,
    horario_fin time without time zone,
    CONSTRAINT chk_medico_area CHECK (((area)::text = ANY (ARRAY[('Urbana'::character varying)::text, ('Rural'::character varying)::text]))),
    CONSTRAINT chk_medico_tipo CHECK (((tipo_medico)::text = ANY (ARRAY[('residente'::character varying)::text, ('interno'::character varying)::text, ('externo'::character varying)::text, ('general'::character varying)::text, ('especialista'::character varying)::text])))
);


ALTER TABLE public.medico OWNER TO hospital;

--
-- Name: CONSTRAINT chk_medico_area ON medico; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_medico_area ON public.medico IS 'Valida area de residencia del medico (Urbana/Rural).';


--
-- Name: CONSTRAINT chk_medico_tipo ON medico; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_medico_tipo ON public.medico IS 'Valida el tipo de contratacion del medico (residente, interno, externo, general, especialista).';


--
-- Name: medico_id_medico_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.medico ALTER COLUMN id_medico ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.medico_id_medico_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: paciente; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.paciente (
    id_paciente integer NOT NULL,
    codigo_expediente character varying(20) NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    fecha_nacimiento date NOT NULL,
    "edad_años" smallint NOT NULL,
    sexo character varying(10) NOT NULL,
    dpi character varying(20),
    telefono character varying(20),
    municipio character varying(80),
    departamento character varying(80),
    area character varying(10),
    estado_civil character varying(30),
    no_seguro_social character varying(30),
    CONSTRAINT chk_paciente_area CHECK (((area)::text = ANY (ARRAY[('Urbana'::character varying)::text, ('Rural'::character varying)::text]))),
    CONSTRAINT chk_paciente_edad CHECK ((("edad_años" >= 0) AND ("edad_años" <= 120))),
    CONSTRAINT chk_paciente_sexo CHECK (((sexo)::text = ANY (ARRAY[('Masculino'::character varying)::text, ('Femenino'::character varying)::text])))
);


ALTER TABLE public.paciente OWNER TO hospital;

--
-- Name: CONSTRAINT chk_paciente_area ON paciente; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_paciente_area ON public.paciente IS 'Valida area de residencia (Urbana/Rural).';


--
-- Name: CONSTRAINT chk_paciente_edad ON paciente; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_paciente_edad ON public.paciente IS 'Valida rango de edad plausible (0 a 120 años).';


--
-- Name: CONSTRAINT chk_paciente_sexo ON paciente; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_paciente_sexo ON public.paciente IS 'Valida sexo (Masculino/Femenino).';


--
-- Name: paciente_encargado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.paciente_encargado (
    id_paciente_encargado integer NOT NULL,
    paciente_id integer NOT NULL,
    encargado_id integer NOT NULL,
    parentesco character varying(40) NOT NULL
);


ALTER TABLE public.paciente_encargado OWNER TO hospital;

--
-- Name: paciente_encargado_id_paciente_encargado_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.paciente_encargado ALTER COLUMN id_paciente_encargado ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.paciente_encargado_id_paciente_encargado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.paciente ALTER COLUMN id_paciente ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.paciente_id_paciente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pago; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.pago (
    id_pago integer NOT NULL,
    factura_id integer NOT NULL,
    numero_cuota smallint NOT NULL,
    total_cuotas smallint NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha_pago date NOT NULL,
    CONSTRAINT chk_pago_cuota_menor CHECK ((numero_cuota <= total_cuotas)),
    CONSTRAINT chk_pago_monto CHECK ((monto > (0)::numeric)),
    CONSTRAINT chk_pago_numero_cuota CHECK (((numero_cuota >= 1) AND (numero_cuota <= 12))),
    CONSTRAINT chk_pago_total_cuotas CHECK (((total_cuotas >= 1) AND (total_cuotas <= 12)))
);


ALTER TABLE public.pago OWNER TO hospital;

--
-- Name: CONSTRAINT chk_pago_cuota_menor ON pago; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_pago_cuota_menor ON public.pago IS 'Valida que el numero de cuota no supere el total de cuotas.';


--
-- Name: CONSTRAINT chk_pago_monto ON pago; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_pago_monto ON public.pago IS 'Valida que el monto del pago sea mayor que cero.';


--
-- Name: CONSTRAINT chk_pago_numero_cuota ON pago; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_pago_numero_cuota ON public.pago IS 'Valida numero de cuota entre 1 y 12.';


--
-- Name: CONSTRAINT chk_pago_total_cuotas ON pago; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_pago_total_cuotas ON public.pago IS 'Valida total de cuotas entre 1 y 12 pagos.';


--
-- Name: pago_id_pago_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.pago ALTER COLUMN id_pago ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pago_id_pago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: quirofano; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.quirofano (
    id_quirofano integer NOT NULL,
    hospital_id integer NOT NULL,
    numero character varying(10) NOT NULL,
    estado character varying(20) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT chk_quirofano_estado CHECK (((estado)::text = ANY (ARRAY[('disponible'::character varying)::text, ('ocupado'::character varying)::text, ('en_mantenimiento'::character varying)::text])))
);


ALTER TABLE public.quirofano OWNER TO hospital;

--
-- Name: CONSTRAINT chk_quirofano_estado ON quirofano; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_quirofano_estado ON public.quirofano IS 'Valida que el estado del quirofano sea disponible, ocupado o en mantenimiento.';


--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.quirofano ALTER COLUMN id_quirofano ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.quirofano_id_quirofano_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: receta; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.receta (
    id_receta integer NOT NULL,
    consulta_id integer NOT NULL,
    fecha date NOT NULL,
    proxima_cita date
);


ALTER TABLE public.receta OWNER TO hospital;

--
-- Name: receta_id_receta_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.receta ALTER COLUMN id_receta ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.receta_id_receta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: receta_medicamento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.receta_medicamento (
    id_receta_medicamento integer NOT NULL,
    receta_id integer NOT NULL,
    medicamento_nombre character varying(120) NOT NULL,
    dosis character varying(60) NOT NULL,
    duracion character varying(60)
);


ALTER TABLE public.receta_medicamento OWNER TO hospital;

--
-- Name: receta_medicamento_id_receta_medicamento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.receta_medicamento ALTER COLUMN id_receta_medicamento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.receta_medicamento_id_receta_medicamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: registro_procedimiento; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.registro_procedimiento (
    id_registro_procedimiento integer NOT NULL,
    cirugia_id integer NOT NULL,
    etapa character varying(20) NOT NULL,
    aspecto character varying(60) NOT NULL,
    exito boolean NOT NULL,
    descripcion text,
    hora_registro timestamp with time zone NOT NULL,
    enfermero_id integer NOT NULL,
    fecha_documentacion date,
    CONSTRAINT chk_registro_etapa CHECK (((etapa)::text = ANY (ARRAY[('preoperatorio'::character varying)::text, ('intraoperatorio'::character varying)::text, ('postoperatorio'::character varying)::text])))
);


ALTER TABLE public.registro_procedimiento OWNER TO hospital;

--
-- Name: CONSTRAINT chk_registro_etapa ON registro_procedimiento; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_registro_etapa ON public.registro_procedimiento IS 'Valida etapa del proceso registrado (preoperatorio, intraoperatorio, postoperatorio).';


--
-- Name: registro_procedimiento_id_registro_procedimiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.registro_procedimiento ALTER COLUMN id_registro_procedimiento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.registro_procedimiento_id_registro_procedimiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: requerimiento_quirurgico; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.requerimiento_quirurgico (
    id_requerimiento integer NOT NULL,
    agendamiento_id integer NOT NULL,
    tipo_recurso character varying(20) NOT NULL,
    insumo_id integer,
    instrumento_id integer,
    equipo_id integer,
    cantidad smallint NOT NULL,
    CONSTRAINT chk_requerimiento_cantidad CHECK ((cantidad > 0)),
    CONSTRAINT chk_requerimiento_tipo CHECK (((tipo_recurso)::text = ANY (ARRAY[('insumo'::character varying)::text, ('instrumento'::character varying)::text, ('equipo'::character varying)::text]))),
    CONSTRAINT chk_requerimiento_un_recurso CHECK ((((((insumo_id IS NOT NULL))::integer + ((instrumento_id IS NOT NULL))::integer) + ((equipo_id IS NOT NULL))::integer) = 1))
);


ALTER TABLE public.requerimiento_quirurgico OWNER TO hospital;

--
-- Name: CONSTRAINT chk_requerimiento_cantidad ON requerimiento_quirurgico; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_requerimiento_cantidad ON public.requerimiento_quirurgico IS 'Valida cantidad requerida mayor que cero.';


--
-- Name: CONSTRAINT chk_requerimiento_tipo ON requerimiento_quirurgico; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_requerimiento_tipo ON public.requerimiento_quirurgico IS 'Valida tipo de recurso requerido (insumo, instrumento o equipo).';


--
-- Name: CONSTRAINT chk_requerimiento_un_recurso ON requerimiento_quirurgico; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_requerimiento_un_recurso ON public.requerimiento_quirurgico IS 'Valida que el requerimiento referencia exactamente un recurso real.';


--
-- Name: requerimiento_quirurgico_id_requerimiento_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.requerimiento_quirurgico ALTER COLUMN id_requerimiento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.requerimiento_quirurgico_id_requerimiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: servicio_atencion; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.servicio_atencion (
    id_servicio integer NOT NULL,
    unidad_id integer NOT NULL,
    nombre character varying(80) NOT NULL,
    costo numeric(10,2)
);


ALTER TABLE public.servicio_atencion OWNER TO hospital;

--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.servicio_atencion ALTER COLUMN id_servicio ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.servicio_atencion_id_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: traslado; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.traslado (
    id_traslado integer NOT NULL,
    fecha_hora timestamp with time zone NOT NULL,
    paciente_id integer NOT NULL,
    medico_indica_id integer NOT NULL,
    unidad_origen_id integer NOT NULL,
    unidad_destino_id integer NOT NULL,
    interno_externo character varying(10) NOT NULL,
    hospital_externo_nombre character varying(120),
    hospital_externo_direccion character varying(250),
    ingreso_id integer,
    consulta_id integer,
    CONSTRAINT chk_traslado_externo CHECK ((((interno_externo)::text <> 'externo'::text) OR ((hospital_externo_nombre IS NOT NULL) AND (hospital_externo_direccion IS NOT NULL)))),
    CONSTRAINT chk_traslado_tipo CHECK (((interno_externo)::text = ANY (ARRAY[('interno'::character varying)::text, ('externo'::character varying)::text])))
);


ALTER TABLE public.traslado OWNER TO hospital;

--
-- Name: CONSTRAINT chk_traslado_externo ON traslado; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_traslado_externo ON public.traslado IS 'Valida que un traslado externo indique nombre y direccion del hospital destino.';


--
-- Name: CONSTRAINT chk_traslado_tipo ON traslado; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_traslado_tipo ON public.traslado IS 'Valida tipo de traslado: interno o externo a la institucion.';


--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.traslado ALTER COLUMN id_traslado ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.traslado_id_traslado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: unidad_medica; Type: TABLE; Schema: public; Owner: hospital
--

CREATE TABLE public.unidad_medica (
    id_unidad integer NOT NULL,
    hospital_id integer NOT NULL,
    nombre character varying(40) NOT NULL,
    costo_dia_hospitalizacion numeric(10,2),
    CONSTRAINT chk_unidad_nombre CHECK (((nombre)::text = ANY (ARRAY[('Consulta Externa'::character varying)::text, ('Emergencias'::character varying)::text, ('Cirugia'::character varying)::text, ('Hospitalizacion'::character varying)::text, ('Otro'::character varying)::text])))
);


ALTER TABLE public.unidad_medica OWNER TO hospital;

--
-- Name: CONSTRAINT chk_unidad_nombre ON unidad_medica; Type: COMMENT; Schema: public; Owner: hospital
--

COMMENT ON CONSTRAINT chk_unidad_nombre ON public.unidad_medica IS 'Valida que la unidad sea una de las 4 unidades medicas o "Otro" (traslados externos).';


--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE; Schema: public; Owner: hospital
--

ALTER TABLE public.unidad_medica ALTER COLUMN id_unidad ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.unidad_medica_id_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: agendamiento_quirurgico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.agendamiento_quirurgico (id_agendamiento, paciente_id, medico_cirujano_id, caracter, historia_clinica, tipo_procedimiento, tiempo_estimado_min, tipo_anestesia, fecha_hora_solicitud, estado_solicitud, motivo_rechazo, quirofano_solicitado_id, fecha_hora_agendada) FROM stdin;
1	5	1006	urgente	Apendicitis aguda confirmada por ecografía.	Apendicectomía abierta	90	General	2026-08-11 17:00:00+00	aprobada	\N	2	2026-08-12 00:30:00+00
2	7	1009	programado	Carcinoma colorrectal en estudio.	Resección oncológica de colon	160	General	2026-08-13 15:00:00+00	rechazada	El comité recomienda completar estudios de imagen y control nutricional previo a la intervención.	3	\N
3	6	1007	programado	Enfermedad valvular aórtica con estenosis severa.	Revascularización miocárdica	180	General	2026-09-08 16:00:00+00	pendiente	\N	\N	\N
\.


--
-- Data for Name: camilla; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.camilla (id_camilla, hospital_id, unidad_id, numero, disponible) FROM stdin;
101	1	11	101	t
102	1	11	102	t
111	1	12	111	t
112	1	12	112	t
113	1	12	113	t
121	1	14	121	f
122	1	14	122	t
123	1	14	123	f
124	1	14	124	t
211	2	22	211	t
212	2	22	212	t
221	2	24	221	t
222	2	24	222	t
\.


--
-- Data for Name: chequeo_preanestesico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.chequeo_preanestesico (id_chequeo_preanestesico, agendamiento_id, clasificacion_asa, medico_asa_nombre, plan_anestesia, anestesista_nombre) FROM stdin;
1	1	II	Alejandro Ramírez Lemus	Inducción con propofol, mantenimiento con sevoflurano, analgesia con morfina.	Daniel Morales Peña
\.


--
-- Data for Name: cirugia; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cirugia (id_cirugia, agendamiento_id, quirofano_id, paciente_id, cirujano_id, ingreso_id, fecha_hora_inicio, fecha_hora_fin, condicion_evolucion, estado) FROM stdin;
1	1	2	5	1006	4	2026-08-12 00:40:00+00	2026-08-12 02:10:00+00	sin_complicaciones	finalizada
\.


--
-- Data for Name: cirugia_insumo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cirugia_insumo (id_cirugia_insumo, cirugia_id, insumo_id, cantidad, costo_unitario) FROM stdin;
1	1	1	2	30.00
2	1	2	1	25.00
3	1	4	10	8.00
4	1	5	8	15.00
5	1	6	2	120.00
6	1	7	3	70.00
\.


--
-- Data for Name: cirugia_personal; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cirugia_personal (id_cirugia_personal, cirugia_id, medico_id, enfermero_id, rol) FROM stdin;
1	1	1006	\N	Cirujano
2	1	1008	\N	Anestesiólogo
3	1	\N	2001	Enfermero instrumentista
4	1	\N	2003	Enfermero circulante
\.


--
-- Data for Name: cita; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.cita (id_cita, paciente_id, medico_id, fecha_hora, num_clinica, medio_asignacion, estado, es_reconsulta, es_referido, costo_base, costo_aplicado, cancelada_sin_aviso) FROM stdin;
1	1	1002	2026-08-10 15:00:00+00	A-101	telefonico	realizada	t	f	220.00	165.00	f
2	2	1003	2026-08-12 16:30:00+00	A-205	recepcion_general	reprogramada	f	f	160.00	160.00	f
3	4	1004	2026-08-15 14:30:00+00	B-110	telefonico	cancelada	f	f	180.00	198.00	t
4	6	1002	2026-09-20 15:30:00+00	A-101	correo_institucional	programada	f	t	220.00	176.00	f
5	5	1005	2026-08-11 15:15:00+00	A-108	recepcion_medico	realizada	f	f	180.00	180.00	f
\.


--
-- Data for Name: consentimiento_informado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.consentimiento_informado (id_consentimiento, agendamiento_id, procedimiento_nombre, procedimiento_objetivo, procedimiento_caracteristicas, procedimiento_riesgos, medico_nombre, medico_firmado, paciente_firma_nombre, paciente_firmado, fecha_obtencion) FROM stdin;
1	1	Apendicectomía abierta	Resección del apéndice inflamado para evitar perforación y peritonitis.	Incisión en fosa ilíaca derecha, ligadura y extirpación del apéndice, cierre por planos, bajo anestesia general.	Sangrado, infección de herida, lesión de estructuras vecinas, complicaciones anestésicas.	Alejandro Ramírez Lemus	t	Carlos De León Ortiz	t	2026-08-11
\.


--
-- Data for Name: consulta; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.consulta (id_consulta, cita_id, paciente_id, medico_id, fecha, diagnostico, otros_datos, notas_observaciones) FROM stdin;
1	1	1	1002	2026-08-10	Hipertensión arterial controlada en tratamiento.	Seguimiento a estudio cardiológico de 2025.	Paciente estable; continuar tratamiento y control en 30 días.
2	5	5	1005	2026-08-11	Sospecha de apendicitis aguda.	Dolor abdominal en fosa ilíaca derecha, mayor de 6 horas.	Se solicita valoración quirúrgica de urgencia; requiere hospitalización.
\.


--
-- Data for Name: egreso; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.egreso (id_egreso, ingreso_id, diagnostico_principal, diagnosticos_secundarios, motivo_egreso, unidad_id, servicio_id, fecha_hora_egreso, medico_id, camilla_id, codigo_egreso, egreso_sin_consentimiento, motivo_egreso_sin_consentimiento, dias_hospitalizado, codigo_traslado, referido_otro_hospital) FROM stdin;
1	1	Politraumatismo; fractura de brazo derecho.	Traumatismo craneoencefálico leve.	Mejoría clínica.	12	3	2026-08-12 16:00:00+00	1001	111	vivo	f	\N	3	\N	f
2	3	Hipertensión arterial descompensada controlada.	\N	Estabilización y mejoría.	14	9	2026-08-18 15:30:00+00	1005	121	vivo	f	\N	4	\N	f
3	5	Postoperatorio de apendicectomía sin complicaciones.	\N	Recuperación satisfactoria.	14	15	2026-08-14 17:30:00+00	1006	123	vivo	f	\N	3	\N	f
\.


--
-- Data for Name: encargado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.encargado (id_encargado, nombre, dpi, telefono, municipio, departamento, area) FROM stdin;
301	Isabel Cruz López	8881123450101	5551-3001	Quetzaltenango	Quetzaltenango	Urbana
302	Roberto Méndez Rodríguez	8881123450102	5551-3002	Quetzaltenango	Quetzaltenango	Urbana
303	Karla Paz Veliz	8881123450103	5551-3003	San Marcos	San Marcos	Urbana
\.


--
-- Data for Name: enfermero; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.enfermero (id_enfermero, nombres, apellidos, dpi, telefono, tipo) FROM stdin;
2001	Luis	Hernández Solís	2001123450201	5552-2001	registrado
2002	Marta	Recinos Alvarado	2001123450202	5552-2002	registrado
2003	José	Pérez Gaitán	2001123450203	5552-2003	practicante_de_enfermeria
2004	Karen	Chacón Barrera	2001123450204	5552-2004	registrado
\.


--
-- Data for Name: equipo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.equipo (id_equipo, nombre, descripcion, tipo, funcion) FROM stdin;
1	Monitor multiparamétrico	Monitorea ECG, SpO2 y presión.	medico	exploracion
2	Electrobisturí	Corte y coagulación con corriente de alta frecuencia.	medico	tratamiento
3	Ventilador mecánico	Asistencia respiratoria invasiva.	medico	tratamiento
4	Bomba de infusión	Administración controlada de fármacos.	medico	tratamiento
5	Laringoscopio	Visualización de vía aérea para intubación.	medico	diagnostico
6	Mesa quirúrgica de anestesia	Mesón para equipamiento y medicación.	quirurgico	otro
\.


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.especialidad (id_especialidad, nombre) FROM stdin;
301	Cardiología
302	Dermatología
303	Fisioterapia
304	Ginecología Oncológica
305	Hematología
306	Medicina Física y Rehabilitación
307	Medicina General
308	Nutrición y Dietética
309	Odontología General
310	Oftalmología
311	Psicología
312	Pediatría
313	Urología
314	Terapia del Lenguaje
315	Cirugía General
316	Cirugía Cardiovascular
317	Cirugía Oncológica
318	Anestesiología
\.


--
-- Data for Name: factura; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.factura (id_factura, paciente_id, fecha_emision, descripcion, total, cita_id, ingreso_id, cirugia_id) FROM stdin;
1	1	2026-08-10 17:30:00+00	Consulta de cardiología; reconsulta (75%).	165.00	1	\N	\N
2	3	2026-08-12 16:30:00+00	Atención de emergencia por politraumatismo; servicio de atención a pacientes politraumatizados.	1800.00	\N	1	\N
3	2	2026-08-18 15:45:00+00	Hospitalización 4 días: medicina interna + insumos médicos.	4390.00	\N	3	\N
4	5	2026-08-12 14:00:00+00	Cirugía: apendicectomía (cirugía general) + insumos utilizados.	9235.00	\N	\N	1
5	5	2026-08-14 18:00:00+00	Hospitalización postoperatoria: 3 días en cuidados intermedios + insumos.	3870.00	\N	5	\N
\.


--
-- Data for Name: historia_clinica; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.historia_clinica (id_historia_clinica, agendamiento_id, medico_id, fecha, fuente_interrogatorio, religion, ocupacion, lugar_nacimiento, lugar_residencia, antecedentes_heredofamiliares, antecedentes_personales_no_patologicos, antecedentes_patologicos, padecimiento_actual, interrogatorio_aparatos_sistemas, sintomas_generales_terapeutica, estudios_previos, signos_vitales, exploracion_general, exploracion_sistematizada) FROM stdin;
1	1	1006	2026-08-11	directo	Católica	Comerciante	Olintepeque, Quetzaltenango	Olintepeque, Quetzaltenango	Cardiopatía isquémica en padre; hipertensión en madre.	No fumador; consumo de alcohol ocasional; alimentación sin restricciones.	Ninguno conocido.	Dolor abdominal en fosa ilíaca derecha desde hace 8 horas, con náuseas.	Dolor intenso localizado, sin irradiación.	Paciente no había iniciado antibióticos previo a consulta.	Ecografía abdominal: líquido libre y engrosamiento apendicular.	TA 120/80, FC 92, T° 37.8.	Abdomen blando, doloroso a palpación en fosa ilíaca derecha.	Cabeza y cuello sin alteraciones; tórax y abdomen según lo referido; extremidades sin déficit motor.
\.


--
-- Data for Name: hospital; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.hospital (id_hospital, nombre, informacion_especifica, direccion) FROM stdin;
1	Hospital General de Occidente	Hospital general de tercer nivel; 4 quirófanos y 24 camillas de hospitalización.	15 Av. 6-45, zona 3, Quetzaltenango
2	Hospital Regional de San Marcos	Hospital de referencia regional para el departamento de San Marcos.	7a. calle 4-10, zona 2, San Marcos
3	Hospital Infantil de Retalhuleu	Hospital especializado en atención pediátrica.	Boulevard El Malecón, zona 1, Retalhuleu
\.


--
-- Data for Name: hospitalizacion_insumo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.hospitalizacion_insumo (id_hospitalizacion_insumo, ingreso_id, insumo_id, cantidad, costo_unitario) FROM stdin;
1	3	1	8	30.00
2	3	8	10	15.00
3	5	1	6	30.00
4	5	8	6	15.00
\.


--
-- Data for Name: ingreso; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.ingreso (id_ingreso, paciente_id, unidad_id, servicio_id, camilla_id, motivo_ingreso, fecha_hora_ingreso, medico_encargado_id, diagnostico_presuntivo) FROM stdin;
1	3	12	3	111	Politraumatismo por accidente de tránsito.	2026-08-10 04:10:00+00	1001	Traumatismo craneoencefálico leve; fractura de brazo derecho.
2	4	12	5	112	Fiebre alta persistente y deshidratación.	2026-08-20 20:05:00+00	1005	Cuadro febril viral en observación.
3	2	14	9	121	Hipertensión arterial descompensada.	2026-08-14 17:00:00+00	1005	Crisis hipertensiva en estudio.
4	5	13	17	\N	Ingreso a quirófano para apendicectomía de urgencia.	2026-08-12 00:35:00+00	1006	Apendicitis aguda.
5	5	14	15	123	Sala de recuperación postquirúrgica tras apendicectomía.	2026-08-12 03:00:00+00	1006	Postoperatorio de apendicectomía.
\.


--
-- Data for Name: instrumento; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.instrumento (id_instrumento, nombre, descripcion, tipo, funcion) FROM stdin;
1	Bisturí No. 3 con hoja No. 15	Bisturí desechable para incisiones.	quirurgico	corte
2	Pinza de campo Backhaus	Fija campos quirúrgicos a la mesa.	quirurgico	contencion
3	Pinza hemostática Mosquito	Controla sangrado de vasos pequeños.	quirurgico	hemostatica
4	Separador de Farabeuf	Separa tejidos durante el abordaje.	quirurgico	retractor
5	Pinza de anillo	Toma y sujeta piezas pequeñas.	quirurgico	contencion
6	Tijeras Mayo curvas	Para corte de tejido y suturas.	quirurgico	corte
\.


--
-- Data for Name: insumo; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.insumo (id_insumo, nombre, descripcion, material, tipo) FROM stdin;
1	Solución salina 0.9% 1000 ml	Solución para hidratación parenteral.	Plástico	medico
2	Catéter intravenoso 20G	Para acceso venoso periférico.	Acero/plástico	medico
3	Seda quirúrgica 2-0	Hilo de sutura no absorbible.	Seda	quirurgico
4	Gasa estéril 10x10	Para curación y campos operatorios.	Algodón	quirurgico
5	Guantes quirúrgicos estériles	Guantes de látex sin polvo.	Látex	medico
6	Propofol 10 mg/ml	Anestésico intravenoso de acción corta.	Vidrio	medico
7	Sutura absorbible 3-0	Hilo de sutura reabsorbible.	Sintético	quirurgico
8	Paracetamol 500 mg	Analgésico y antipirético.	Blíster	medico
\.


--
-- Data for Name: medico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.medico (id_medico, nombres, apellidos, dpi, telefono, municipio, departamento, area, especialidad_id, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin) FROM stdin;
1001	Carmen	Ruiz Palacios	2001123450101	5551-2001	Quetzaltenango	Quetzaltenango	Urbana	307	general	200.00	08:00:00	12:00:00
1002	Roberto	Castillo Méndez	2001123450102	5551-2002	Olintepeque	Quetzaltenango	Urbana	301	especialista	220.00	08:00:00	11:30:00
1003	Andrea	Soto Fuentes	2001123450103	5551-2003	San Marcos	San Marcos	Rural	303	especialista	160.00	09:00:00	12:00:00
1004	Julia	Paredes Ovalle	2001123450104	5551-2004	Quetzaltenango	Quetzaltenango	Urbana	312	especialista	180.00	08:00:00	12:00:00
1005	Miguel	Barrios Donis	2001123450105	5551-2005	Coatepeque	Quetzaltenango	Rural	307	general	180.00	08:00:00	12:00:00
1006	Alejandro	Ramírez Lemus	2001123450106	5551-2006	Quetzaltenango	Quetzaltenango	Urbana	315	residente	\N	\N	\N
1007	Hilda	Cifuentes Rojas	2001123450107	5551-2007	San Marcos	San Marcos	Urbana	316	externo	\N	\N	\N
1008	Daniel	Morales Peña	2001123450108	5551-2008	Quetzaltenango	Quetzaltenango	Urbana	318	interno	\N	\N	\N
1009	Silvia	Vásquez Cotero	2001123450109	5551-2009	Totonicapán	Totonicapán	Urbana	317	especialista	\N	\N	\N
\.


--
-- Data for Name: paciente; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.paciente (id_paciente, codigo_expediente, nombres, apellidos, fecha_nacimiento, "edad_años", sexo, dpi, telefono, municipio, departamento, area, estado_civil, no_seguro_social) FROM stdin;
1	HG1-0001	María Fernanda	López García	1988-04-12	38	Femenino	2220123450123	5551-1001	Quetzaltenango	Quetzaltenango	Urbana	Casada	IGSS-88432
2	HG1-0002	Jorge Luis	Ramírez Sosa	1990-11-03	35	Masculino	3330123450456	5551-1002	San Marcos	San Marcos	Rural	Soltero	\N
3	HG1-0003	Pedro	Gómez Aguilar	1975-07-22	51	Masculino	4440123450789	5551-1003	Cantel	Quetzaltenango	Rural	Casado	\N
4	HG1-0004	Ana Lucía	Méndez Cruz	2015-05-30	11	Femenino	5550123450104	5551-1004	Quetzaltenango	Quetzaltenango	Urbana	Soltera	IGSS-22150
5	HG1-0005	Carlos	De León Ortiz	1982-09-15	43	Masculino	66601234501230	5551-1005	Olintepeque	Quetzaltenango	Urbana	Casado	\N
6	HG2-0001	Sofía	Rivera Paz	2001-02-25	25	Femenino	7770123450650	5551-1006	San Marcos	San Marcos	Urbana	Soltera	\N
7	HG1-0006	Luis Miguel	Castillo Fuentes	1968-01-19	58	Masculino	8880123450901	5551-1007	Zunil	Quetzaltenango	Rural	Viudo	\N
\.


--
-- Data for Name: paciente_encargado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.paciente_encargado (id_paciente_encargado, paciente_id, encargado_id, parentesco) FROM stdin;
401	4	301	Madre
402	4	302	Padre
403	6	303	Hermana
\.


--
-- Data for Name: pago; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.pago (id_pago, factura_id, numero_cuota, total_cuotas, monto, fecha_pago) FROM stdin;
1	1	1	1	165.00	2026-08-10
2	2	1	3	600.00	2026-08-12
3	2	2	3	600.00	2026-09-12
4	3	1	4	1097.50	2026-08-18
5	3	2	4	1097.50	2026-09-18
6	4	1	6	1539.17	2026-08-12
7	4	2	6	1539.17	2026-09-12
8	5	1	3	1290.00	2026-08-14
\.


--
-- Data for Name: quirofano; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.quirofano (id_quirofano, hospital_id, numero, estado) FROM stdin;
1	1	Q-1	disponible
2	1	Q-2	ocupado
3	1	Q-3	disponible
4	1	Q-4	en_mantenimiento
5	2	Q-1	disponible
6	2	Q-2	disponible
\.


--
-- Data for Name: receta; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.receta (id_receta, consulta_id, fecha, proxima_cita) FROM stdin;
1	1	2026-08-10	2026-09-10
2	2	2026-08-11	\N
\.


--
-- Data for Name: receta_medicamento; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.receta_medicamento (id_receta_medicamento, receta_id, medicamento_nombre, dosis, duracion) FROM stdin;
1	1	Metoprolol 50 mg	1 tableta cada 12 horas	30 días
2	1	Losartán 50 mg	1 tableta en la mañana	30 días
3	2	Tramadol 50 mg (dolor)	1 tableta hasta cada 8 horas según dolor	5 días
\.


--
-- Data for Name: registro_procedimiento; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.registro_procedimiento (id_registro_procedimiento, cirugia_id, etapa, aspecto, exito, descripcion, hora_registro, enfermero_id, fecha_documentacion) FROM stdin;
1	1	preoperatorio	planificacion	t	Tabla quirúrgica disponible, equipos y quirófano preparados.	2026-08-12 00:15:00+00	2001	2026-08-12
2	1	preoperatorio	entrada	t	Paciente identificado con brazalete; ficha clínica y consentimiento firmado verificados.	2026-08-12 00:38:00+00	2001	2026-08-12
3	1	intraoperatorio	chequeo_quirofano	t	Equipo quirúrgico completo; traslado y posicionamiento correctos.	2026-08-12 00:45:00+00	2002	2026-08-12
4	1	intraoperatorio	pausa_quirurgica	t	Paciente y procedimiento confirmados; condiciones de esterilidad adecuadas.	2026-08-12 00:50:00+00	2002	2026-08-12
5	1	intraoperatorio	balance_hidrico	t	Balance hídrico registrado sin alteraciones.	2026-08-12 01:10:00+00	2002	2026-08-12
6	1	intraoperatorio	salida_quirurgica	t	Conteo de instrumental satisfactorio; cierre de incisión.	2026-08-12 02:05:00+00	2002	2026-08-12
7	1	postoperatorio	ingreso_sala_recuperacion	t	Ingreso a sala de recuperación con evolución sin complicaciones.	2026-08-12 02:25:00+00	2003	2026-08-12
8	1	postoperatorio	traslado_seguro	t	Signos vitales normales; zona operatoria limpia; documentación completa.	2026-08-12 03:15:00+00	2003	2026-08-12
\.


--
-- Data for Name: requerimiento_quirurgico; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.requerimiento_quirurgico (id_requerimiento, agendamiento_id, tipo_recurso, insumo_id, instrumento_id, equipo_id, cantidad) FROM stdin;
1	1	instrumento	\N	1	\N	1
2	1	insumo	6	\N	\N	2
3	1	equipo	\N	\N	1	1
4	2	equipo	\N	\N	3	1
5	2	instrumento	\N	3	\N	4
\.


--
-- Data for Name: servicio_atencion; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.servicio_atencion (id_servicio, unidad_id, nombre, costo) FROM stdin;
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
\.


--
-- Data for Name: traslado; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.traslado (id_traslado, fecha_hora, paciente_id, medico_indica_id, unidad_origen_id, unidad_destino_id, interno_externo, hospital_externo_nombre, hospital_externo_direccion, ingreso_id, consulta_id) FROM stdin;
1	2026-08-11 16:00:00+00	5	1005	11	13	interno	\N	\N	\N	2
2	2026-08-12 03:30:00+00	5	1006	13	14	interno	\N	\N	4	\N
3	2026-08-21 14:00:00+00	4	1005	12	25	externo	Hospital Regional de San Marcos	7a. calle 4-10, zona 2, San Marcos	2	\N
\.


--
-- Data for Name: unidad_medica; Type: TABLE DATA; Schema: public; Owner: hospital
--

COPY public.unidad_medica (id_unidad, hospital_id, nombre, costo_dia_hospitalizacion) FROM stdin;
11	1	Consulta Externa	\N
12	1	Emergencias	\N
13	1	Cirugia	\N
14	1	Hospitalizacion	600.00
15	1	Otro	\N
21	2	Consulta Externa	\N
22	2	Emergencias	\N
23	2	Cirugia	\N
24	2	Hospitalizacion	450.00
25	2	Otro	\N
31	3	Consulta Externa	\N
32	3	Emergencias	\N
33	3	Cirugia	\N
34	3	Hospitalizacion	520.00
35	3	Otro	\N
\.


--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.agendamiento_quirurgico_id_agendamiento_seq', 4, false);


--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.camilla_id_camilla_seq', 223, false);


--
-- Name: chequeo_preanestesico_id_chequeo_preanestesico_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.chequeo_preanestesico_id_chequeo_preanestesico_seq', 2, false);


--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cirugia_id_cirugia_seq', 2, false);


--
-- Name: cirugia_insumo_id_cirugia_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cirugia_insumo_id_cirugia_insumo_seq', 7, false);


--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cirugia_personal_id_cirugia_personal_seq', 5, false);


--
-- Name: cita_id_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.cita_id_cita_seq', 6, false);


--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.consentimiento_informado_id_consentimiento_seq', 2, false);


--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.consulta_id_consulta_seq', 3, false);


--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.egreso_id_egreso_seq', 4, false);


--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.encargado_id_encargado_seq', 304, false);


--
-- Name: enfermero_id_enfermero_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.enfermero_id_enfermero_seq', 2005, false);


--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.equipo_id_equipo_seq', 7, false);


--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.especialidad_id_especialidad_seq', 319, true);


--
-- Name: factura_id_factura_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.factura_id_factura_seq', 6, false);


--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.historia_clinica_id_historia_clinica_seq', 2, false);


--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.hospital_id_hospital_seq', 4, false);


--
-- Name: hospitalizacion_insumo_id_hospitalizacion_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq', 5, false);


--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.ingreso_id_ingreso_seq', 6, false);


--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.instrumento_id_instrumento_seq', 7, false);


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.insumo_id_insumo_seq', 9, false);


--
-- Name: medico_id_medico_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.medico_id_medico_seq', 1010, false);


--
-- Name: paciente_encargado_id_paciente_encargado_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.paciente_encargado_id_paciente_encargado_seq', 404, false);


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.paciente_id_paciente_seq', 8, false);


--
-- Name: pago_id_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.pago_id_pago_seq', 9, false);


--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.quirofano_id_quirofano_seq', 7, false);


--
-- Name: receta_id_receta_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.receta_id_receta_seq', 3, false);


--
-- Name: receta_medicamento_id_receta_medicamento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.receta_medicamento_id_receta_medicamento_seq', 4, false);


--
-- Name: registro_procedimiento_id_registro_procedimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.registro_procedimiento_id_registro_procedimiento_seq', 9, false);


--
-- Name: requerimiento_quirurgico_id_requerimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.requerimiento_quirurgico_id_requerimiento_seq', 6, false);


--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.servicio_atencion_id_servicio_seq', 20, false);


--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.traslado_id_traslado_seq', 4, false);


--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: hospital
--

SELECT pg_catalog.setval('public.unidad_medica_id_unidad_seq', 36, false);


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_pkey PRIMARY KEY (id_agendamiento);


--
-- Name: camilla camilla_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_pkey PRIMARY KEY (id_camilla);


--
-- Name: chequeo_preanestesico chequeo_preanestesico_agendamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_agendamiento_id_key UNIQUE (agendamiento_id);


--
-- Name: chequeo_preanestesico chequeo_preanestesico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_pkey PRIMARY KEY (id_chequeo_preanestesico);


--
-- Name: cirugia cirugia_agendamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_agendamiento_id_key UNIQUE (agendamiento_id);


--
-- Name: cirugia_insumo cirugia_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_pkey PRIMARY KEY (id_cirugia_insumo);


--
-- Name: cirugia_personal cirugia_personal_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_pkey PRIMARY KEY (id_cirugia_personal);


--
-- Name: cirugia cirugia_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_pkey PRIMARY KEY (id_cirugia);


--
-- Name: cita cita_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_pkey PRIMARY KEY (id_cita);


--
-- Name: consentimiento_informado consentimiento_informado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_pkey PRIMARY KEY (id_consentimiento);


--
-- Name: consulta consulta_cita_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_cita_id_key UNIQUE (cita_id);


--
-- Name: consulta consulta_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_pkey PRIMARY KEY (id_consulta);


--
-- Name: egreso egreso_ingreso_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_ingreso_id_key UNIQUE (ingreso_id);


--
-- Name: egreso egreso_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_pkey PRIMARY KEY (id_egreso);


--
-- Name: encargado encargado_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_dpi_key UNIQUE (dpi);


--
-- Name: encargado encargado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_pkey PRIMARY KEY (id_encargado);


--
-- Name: enfermero enfermero_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT enfermero_dpi_key UNIQUE (dpi);


--
-- Name: enfermero enfermero_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT enfermero_pkey PRIMARY KEY (id_enfermero);


--
-- Name: equipo equipo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.equipo
    ADD CONSTRAINT equipo_pkey PRIMARY KEY (id_equipo);


--
-- Name: especialidad especialidad_nombre_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_nombre_key UNIQUE (nombre);


--
-- Name: especialidad especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: factura factura_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_pkey PRIMARY KEY (id_factura);


--
-- Name: historia_clinica historia_clinica_agendamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_agendamiento_id_key UNIQUE (agendamiento_id);


--
-- Name: historia_clinica historia_clinica_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_pkey PRIMARY KEY (id_historia_clinica);


--
-- Name: hospital hospital_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (id_hospital);


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_pkey PRIMARY KEY (id_hospitalizacion_insumo);


--
-- Name: ingreso ingreso_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_pkey PRIMARY KEY (id_ingreso);


--
-- Name: instrumento instrumento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.instrumento
    ADD CONSTRAINT instrumento_pkey PRIMARY KEY (id_instrumento);


--
-- Name: insumo insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.insumo
    ADD CONSTRAINT insumo_pkey PRIMARY KEY (id_insumo);


--
-- Name: medico medico_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_dpi_key UNIQUE (dpi);


--
-- Name: medico medico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_pkey PRIMARY KEY (id_medico);


--
-- Name: paciente paciente_codigo_expediente_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_codigo_expediente_key UNIQUE (codigo_expediente);


--
-- Name: paciente paciente_dpi_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_dpi_key UNIQUE (dpi);


--
-- Name: paciente_encargado paciente_encargado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_pkey PRIMARY KEY (id_paciente_encargado);


--
-- Name: paciente paciente_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id_paciente);


--
-- Name: pago pago_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (id_pago);


--
-- Name: quirofano quirofano_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_pkey PRIMARY KEY (id_quirofano);


--
-- Name: receta receta_consulta_id_key; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_consulta_id_key UNIQUE (consulta_id);


--
-- Name: receta_medicamento receta_medicamento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_pkey PRIMARY KEY (id_receta_medicamento);


--
-- Name: receta receta_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_pkey PRIMARY KEY (id_receta);


--
-- Name: registro_procedimiento registro_procedimiento_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_pkey PRIMARY KEY (id_registro_procedimiento);


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_pkey PRIMARY KEY (id_requerimiento);


--
-- Name: servicio_atencion servicio_atencion_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_pkey PRIMARY KEY (id_servicio);


--
-- Name: traslado traslado_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_pkey PRIMARY KEY (id_traslado);


--
-- Name: unidad_medica unidad_medica_pkey; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_pkey PRIMARY KEY (id_unidad);


--
-- Name: camilla uq_camilla_hospital_numero; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT uq_camilla_hospital_numero UNIQUE (hospital_id, numero);


--
-- Name: paciente_encargado uq_paciente_encargado; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT uq_paciente_encargado UNIQUE (paciente_id, encargado_id);


--
-- Name: pago uq_pago_cuota; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT uq_pago_cuota UNIQUE (factura_id, numero_cuota);


--
-- Name: quirofano uq_quirofano_hospital_numero; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT uq_quirofano_hospital_numero UNIQUE (hospital_id, numero);


--
-- Name: servicio_atencion uq_servicio_unidad; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT uq_servicio_unidad UNIQUE (unidad_id, nombre);


--
-- Name: unidad_medica uq_unidad_hospital_nombre; Type: CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT uq_unidad_hospital_nombre UNIQUE (hospital_id, nombre);


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_medico_cirujano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_medico_cirujano_id_fkey FOREIGN KEY (medico_cirujano_id) REFERENCES public.medico(id_medico) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_quirofano_solicitado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_quirofano_solicitado_id_fkey FOREIGN KEY (quirofano_solicitado_id) REFERENCES public.quirofano(id_quirofano) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: camilla camilla_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: camilla camilla_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: chequeo_preanestesico chequeo_preanestesico_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia cirugia_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia cirugia_cirujano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_cirujano_id_fkey FOREIGN KEY (cirujano_id) REFERENCES public.medico(id_medico) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cirugia cirugia_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: cirugia_insumo cirugia_insumo_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_insumo cirugia_insumo_insumo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_insumo_id_fkey FOREIGN KEY (insumo_id) REFERENCES public.insumo(id_insumo) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cirugia cirugia_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cirugia_personal cirugia_personal_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_personal cirugia_personal_enfermero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_enfermero_id_fkey FOREIGN KEY (enfermero_id) REFERENCES public.enfermero(id_enfermero) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: cirugia_personal cirugia_personal_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: cirugia cirugia_quirofano_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_quirofano_id_fkey FOREIGN KEY (quirofano_id) REFERENCES public.quirofano(id_quirofano) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cita cita_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cita cita_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: consentimiento_informado consentimiento_informado_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consulta consulta_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.cita(id_cita) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consulta consulta_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: consulta consulta_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: egreso egreso_camilla_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_camilla_id_fkey FOREIGN KEY (camilla_id) REFERENCES public.camilla(id_camilla) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: egreso egreso_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: egreso egreso_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: egreso egreso_servicio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_servicio_id_fkey FOREIGN KEY (servicio_id) REFERENCES public.servicio_atencion(id_servicio) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: egreso egreso_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: factura factura_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: factura factura_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.cita(id_cita) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: factura factura_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: factura factura_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: historia_clinica historia_clinica_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: historia_clinica historia_clinica_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medico(id_medico) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_insumo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_insumo_id_fkey FOREIGN KEY (insumo_id) REFERENCES public.insumo(id_insumo) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_camilla_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_camilla_id_fkey FOREIGN KEY (camilla_id) REFERENCES public.camilla(id_camilla) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: ingreso ingreso_medico_encargado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_medico_encargado_id_fkey FOREIGN KEY (medico_encargado_id) REFERENCES public.medico(id_medico) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_servicio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_servicio_id_fkey FOREIGN KEY (servicio_id) REFERENCES public.servicio_atencion(id_servicio) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: ingreso ingreso_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: medico medico_especialidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_especialidad_id_fkey FOREIGN KEY (especialidad_id) REFERENCES public.especialidad(id_especialidad) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: paciente_encargado paciente_encargado_encargado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_encargado_id_fkey FOREIGN KEY (encargado_id) REFERENCES public.encargado(id_encargado) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente_encargado paciente_encargado_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pago pago_factura_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_factura_id_fkey FOREIGN KEY (factura_id) REFERENCES public.factura(id_factura) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: quirofano quirofano_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: receta receta_consulta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_consulta_id_fkey FOREIGN KEY (consulta_id) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: receta_medicamento receta_medicamento_receta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_receta_id_fkey FOREIGN KEY (receta_id) REFERENCES public.receta(id_receta) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro_procedimiento registro_procedimiento_cirugia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_cirugia_id_fkey FOREIGN KEY (cirugia_id) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro_procedimiento registro_procedimiento_enfermero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_enfermero_id_fkey FOREIGN KEY (enfermero_id) REFERENCES public.enfermero(id_enfermero) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_agendamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_agendamiento_id_fkey FOREIGN KEY (agendamiento_id) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_equipo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_equipo_id_fkey FOREIGN KEY (equipo_id) REFERENCES public.equipo(id_equipo) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_instrumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_instrumento_id_fkey FOREIGN KEY (instrumento_id) REFERENCES public.instrumento(id_instrumento) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: requerimiento_quirurgico requerimiento_quirurgico_insumo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.requerimiento_quirurgico
    ADD CONSTRAINT requerimiento_quirurgico_insumo_id_fkey FOREIGN KEY (insumo_id) REFERENCES public.insumo(id_insumo) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: servicio_atencion servicio_atencion_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: traslado traslado_consulta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_consulta_id_fkey FOREIGN KEY (consulta_id) REFERENCES public.consulta(id_consulta) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: traslado traslado_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES public.ingreso(id_ingreso) ON UPDATE SET NULL ON DELETE SET NULL;


--
-- Name: traslado traslado_medico_indica_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_medico_indica_id_fkey FOREIGN KEY (medico_indica_id) REFERENCES public.medico(id_medico) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: traslado traslado_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id_paciente) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: traslado traslado_unidad_destino_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_unidad_destino_id_fkey FOREIGN KEY (unidad_destino_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: traslado traslado_unidad_origen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_unidad_origen_id_fkey FOREIGN KEY (unidad_origen_id) REFERENCES public.unidad_medica(id_unidad) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: unidad_medica unidad_medica_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hospital
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO usuario_admin;
GRANT USAGE ON SCHEMA public TO usuario_auditoria;


--
-- Name: TABLE agendamiento_quirurgico; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.agendamiento_quirurgico TO usuario_admin;
GRANT SELECT ON TABLE public.agendamiento_quirurgico TO usuario_auditoria;


--
-- Name: SEQUENCE agendamiento_quirurgico_id_agendamiento_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.agendamiento_quirurgico_id_agendamiento_seq TO usuario_admin;


--
-- Name: TABLE camilla; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.camilla TO usuario_admin;
GRANT SELECT ON TABLE public.camilla TO usuario_auditoria;


--
-- Name: SEQUENCE camilla_id_camilla_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.camilla_id_camilla_seq TO usuario_admin;


--
-- Name: TABLE chequeo_preanestesico; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.chequeo_preanestesico TO usuario_admin;
GRANT SELECT ON TABLE public.chequeo_preanestesico TO usuario_auditoria;


--
-- Name: SEQUENCE chequeo_preanestesico_id_chequeo_preanestesico_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.chequeo_preanestesico_id_chequeo_preanestesico_seq TO usuario_admin;


--
-- Name: TABLE cirugia; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.cirugia TO usuario_admin;
GRANT SELECT ON TABLE public.cirugia TO usuario_auditoria;


--
-- Name: SEQUENCE cirugia_id_cirugia_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.cirugia_id_cirugia_seq TO usuario_admin;


--
-- Name: TABLE cirugia_insumo; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.cirugia_insumo TO usuario_admin;
GRANT SELECT ON TABLE public.cirugia_insumo TO usuario_auditoria;


--
-- Name: SEQUENCE cirugia_insumo_id_cirugia_insumo_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.cirugia_insumo_id_cirugia_insumo_seq TO usuario_admin;


--
-- Name: TABLE cirugia_personal; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.cirugia_personal TO usuario_admin;
GRANT SELECT ON TABLE public.cirugia_personal TO usuario_auditoria;


--
-- Name: SEQUENCE cirugia_personal_id_cirugia_personal_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.cirugia_personal_id_cirugia_personal_seq TO usuario_admin;


--
-- Name: TABLE cita; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.cita TO usuario_admin;
GRANT SELECT ON TABLE public.cita TO usuario_auditoria;


--
-- Name: SEQUENCE cita_id_cita_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.cita_id_cita_seq TO usuario_admin;


--
-- Name: TABLE consentimiento_informado; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.consentimiento_informado TO usuario_admin;
GRANT SELECT ON TABLE public.consentimiento_informado TO usuario_auditoria;


--
-- Name: SEQUENCE consentimiento_informado_id_consentimiento_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.consentimiento_informado_id_consentimiento_seq TO usuario_admin;


--
-- Name: TABLE consulta; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.consulta TO usuario_admin;
GRANT SELECT ON TABLE public.consulta TO usuario_auditoria;


--
-- Name: SEQUENCE consulta_id_consulta_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.consulta_id_consulta_seq TO usuario_admin;


--
-- Name: TABLE egreso; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.egreso TO usuario_admin;
GRANT SELECT ON TABLE public.egreso TO usuario_auditoria;


--
-- Name: SEQUENCE egreso_id_egreso_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.egreso_id_egreso_seq TO usuario_admin;


--
-- Name: TABLE encargado; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.encargado TO usuario_admin;
GRANT SELECT ON TABLE public.encargado TO usuario_auditoria;


--
-- Name: SEQUENCE encargado_id_encargado_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.encargado_id_encargado_seq TO usuario_admin;


--
-- Name: TABLE enfermero; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.enfermero TO usuario_admin;
GRANT SELECT ON TABLE public.enfermero TO usuario_auditoria;


--
-- Name: SEQUENCE enfermero_id_enfermero_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.enfermero_id_enfermero_seq TO usuario_admin;


--
-- Name: TABLE equipo; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.equipo TO usuario_admin;
GRANT SELECT ON TABLE public.equipo TO usuario_auditoria;


--
-- Name: SEQUENCE equipo_id_equipo_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.equipo_id_equipo_seq TO usuario_admin;


--
-- Name: TABLE especialidad; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.especialidad TO usuario_admin;
GRANT SELECT ON TABLE public.especialidad TO usuario_auditoria;


--
-- Name: SEQUENCE especialidad_id_especialidad_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.especialidad_id_especialidad_seq TO usuario_admin;


--
-- Name: TABLE factura; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.factura TO usuario_admin;
GRANT SELECT ON TABLE public.factura TO usuario_auditoria;


--
-- Name: SEQUENCE factura_id_factura_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.factura_id_factura_seq TO usuario_admin;


--
-- Name: TABLE historia_clinica; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.historia_clinica TO usuario_admin;
GRANT SELECT ON TABLE public.historia_clinica TO usuario_auditoria;


--
-- Name: SEQUENCE historia_clinica_id_historia_clinica_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.historia_clinica_id_historia_clinica_seq TO usuario_admin;


--
-- Name: TABLE hospital; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.hospital TO usuario_admin;
GRANT SELECT ON TABLE public.hospital TO usuario_auditoria;


--
-- Name: SEQUENCE hospital_id_hospital_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.hospital_id_hospital_seq TO usuario_admin;


--
-- Name: TABLE hospitalizacion_insumo; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.hospitalizacion_insumo TO usuario_admin;
GRANT SELECT ON TABLE public.hospitalizacion_insumo TO usuario_auditoria;


--
-- Name: SEQUENCE hospitalizacion_insumo_id_hospitalizacion_insumo_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.hospitalizacion_insumo_id_hospitalizacion_insumo_seq TO usuario_admin;


--
-- Name: TABLE ingreso; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.ingreso TO usuario_admin;
GRANT SELECT ON TABLE public.ingreso TO usuario_auditoria;


--
-- Name: SEQUENCE ingreso_id_ingreso_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.ingreso_id_ingreso_seq TO usuario_admin;


--
-- Name: TABLE instrumento; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.instrumento TO usuario_admin;
GRANT SELECT ON TABLE public.instrumento TO usuario_auditoria;


--
-- Name: SEQUENCE instrumento_id_instrumento_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.instrumento_id_instrumento_seq TO usuario_admin;


--
-- Name: TABLE insumo; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.insumo TO usuario_admin;
GRANT SELECT ON TABLE public.insumo TO usuario_auditoria;


--
-- Name: SEQUENCE insumo_id_insumo_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.insumo_id_insumo_seq TO usuario_admin;


--
-- Name: TABLE medico; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.medico TO usuario_admin;
GRANT SELECT ON TABLE public.medico TO usuario_auditoria;


--
-- Name: SEQUENCE medico_id_medico_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.medico_id_medico_seq TO usuario_admin;


--
-- Name: TABLE paciente; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.paciente TO usuario_admin;
GRANT SELECT ON TABLE public.paciente TO usuario_auditoria;


--
-- Name: TABLE paciente_encargado; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.paciente_encargado TO usuario_admin;
GRANT SELECT ON TABLE public.paciente_encargado TO usuario_auditoria;


--
-- Name: SEQUENCE paciente_encargado_id_paciente_encargado_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.paciente_encargado_id_paciente_encargado_seq TO usuario_admin;


--
-- Name: SEQUENCE paciente_id_paciente_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.paciente_id_paciente_seq TO usuario_admin;


--
-- Name: TABLE pago; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.pago TO usuario_admin;
GRANT SELECT ON TABLE public.pago TO usuario_auditoria;


--
-- Name: SEQUENCE pago_id_pago_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.pago_id_pago_seq TO usuario_admin;


--
-- Name: TABLE quirofano; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.quirofano TO usuario_admin;
GRANT SELECT ON TABLE public.quirofano TO usuario_auditoria;


--
-- Name: SEQUENCE quirofano_id_quirofano_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.quirofano_id_quirofano_seq TO usuario_admin;


--
-- Name: TABLE receta; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.receta TO usuario_admin;
GRANT SELECT ON TABLE public.receta TO usuario_auditoria;


--
-- Name: SEQUENCE receta_id_receta_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.receta_id_receta_seq TO usuario_admin;


--
-- Name: TABLE receta_medicamento; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.receta_medicamento TO usuario_admin;
GRANT SELECT ON TABLE public.receta_medicamento TO usuario_auditoria;


--
-- Name: SEQUENCE receta_medicamento_id_receta_medicamento_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.receta_medicamento_id_receta_medicamento_seq TO usuario_admin;


--
-- Name: TABLE registro_procedimiento; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.registro_procedimiento TO usuario_admin;
GRANT SELECT ON TABLE public.registro_procedimiento TO usuario_auditoria;


--
-- Name: SEQUENCE registro_procedimiento_id_registro_procedimiento_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.registro_procedimiento_id_registro_procedimiento_seq TO usuario_admin;


--
-- Name: TABLE requerimiento_quirurgico; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.requerimiento_quirurgico TO usuario_admin;
GRANT SELECT ON TABLE public.requerimiento_quirurgico TO usuario_auditoria;


--
-- Name: SEQUENCE requerimiento_quirurgico_id_requerimiento_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.requerimiento_quirurgico_id_requerimiento_seq TO usuario_admin;


--
-- Name: TABLE servicio_atencion; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.servicio_atencion TO usuario_admin;
GRANT SELECT ON TABLE public.servicio_atencion TO usuario_auditoria;


--
-- Name: SEQUENCE servicio_atencion_id_servicio_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.servicio_atencion_id_servicio_seq TO usuario_admin;


--
-- Name: TABLE traslado; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.traslado TO usuario_admin;
GRANT SELECT ON TABLE public.traslado TO usuario_auditoria;


--
-- Name: SEQUENCE traslado_id_traslado_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.traslado_id_traslado_seq TO usuario_admin;


--
-- Name: TABLE unidad_medica; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON TABLE public.unidad_medica TO usuario_admin;
GRANT SELECT ON TABLE public.unidad_medica TO usuario_auditoria;


--
-- Name: SEQUENCE unidad_medica_id_unidad_seq; Type: ACL; Schema: public; Owner: hospital
--

GRANT ALL ON SEQUENCE public.unidad_medica_id_unidad_seq TO usuario_admin;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: hospital
--

ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT ALL ON SEQUENCES TO usuario_admin;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: hospital
--

ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT SELECT ON TABLES TO usuario_auditoria;
ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT ALL ON TABLES TO usuario_admin;


--
-- PostgreSQL database dump complete
--

\unrestrict ZH0k4Wb5g8xTyqT85v5GzbzcY3JvhS9eaQTCx2tav1Urr5XRjUiWTgL1E9cKhcB

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

\restrict pzRWYsgF36p72RiCVXpj46cU420yxwGc51U5mM2uBcg9cyXmUXMvPIbtanbbMHn

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
-- PostgreSQL database dump complete
--

\unrestrict pzRWYsgF36p72RiCVXpj46cU420yxwGc51U5mM2uBcg9cyXmUXMvPIbtanbbMHn

--
-- PostgreSQL database cluster dump complete
--

