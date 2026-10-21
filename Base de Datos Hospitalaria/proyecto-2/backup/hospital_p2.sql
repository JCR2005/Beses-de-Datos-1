--
-- PostgreSQL database dump
--

\restrict rzQAxmA6FzkGGVLi5ZCH93GYZO07ubAS15Q7Uac1qWFbBt4zEsdYh8IzrHh6Qa0

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
-- Name: propuesta_bloque_e; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA propuesta_bloque_e;


ALTER SCHEMA propuesta_bloque_e OWNER TO admin;

--
-- Name: fn_agendamiento_aprobado(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_agendamiento_aprobado() OWNER TO admin;

--
-- Name: fn_auditar_medico(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_auditar_medico() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    perform fn_registrar_auditoria(current_user, 'medico', new.id_medico, 'id_especialidad',
        old.id_especialidad || ' - ' || (select nombre from especialidad where id_especialidad = old.id_especialidad),
        new.id_especialidad || ' - ' || (select nombre from especialidad where id_especialidad = new.id_especialidad));
    return null;
end $$;


ALTER FUNCTION public.fn_auditar_medico() OWNER TO admin;

--
-- Name: fn_auditar_personal(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_auditar_personal() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    -- current_user aqui es el rol que hizo el cambio (la funcion no es security definer)
    if new.salario is distinct from old.salario then
        perform fn_registrar_auditoria(current_user, 'personal', new.id_personal, 'salario',
                                       old.salario::text, new.salario::text);
    end if;
    if new.nivel_acceso is distinct from old.nivel_acceso then
        perform fn_registrar_auditoria(current_user, 'personal', new.id_personal, 'nivel_acceso',
                                       old.nivel_acceso, new.nivel_acceso);
    end if;
    return null;
end $$;


ALTER FUNCTION public.fn_auditar_personal() OWNER TO admin;

--
-- Name: fn_cadena_mando(integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_cadena_mando(p_id_medico integer) RETURNS TABLE(nivel integer, id_medico integer, medico text, cargo character varying, especialidad character varying, hospital character varying)
    LANGUAGE sql STABLE
    AS $$
    with recursive cadena (nivel, id_medico, id_medico_superior) as (
        select 0, m.id_medico, m.id_medico_superior
          from medico m
         where m.id_medico = p_id_medico
        union all
        select c.nivel + 1, m.id_medico, m.id_medico_superior
          from cadena c
          join medico m on m.id_medico = c.id_medico_superior
    )
    select c.nivel, m.id_medico, m.nombres || ' ' || m.apellidos, m.cargo, es.nombre, h.nombre
      from cadena c
      join medico m on m.id_medico = c.id_medico
      join especialidad es on es.id_especialidad = m.id_especialidad
      join hospital h on h.id_hospital = m.id_hospital
     order by c.nivel;
$$;


ALTER FUNCTION public.fn_cadena_mando(p_id_medico integer) OWNER TO admin;

--
-- Name: FUNCTION fn_cadena_mando(p_id_medico integer); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_cadena_mando(p_id_medico integer) IS 'Objetivo 16: cadena de supervisión de un médico hasta el director.';


--
-- Name: fn_calificacion_consulta(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_calificacion_consulta() OWNER TO admin;

--
-- Name: fn_camilla_unidad(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_camilla_unidad() OWNER TO admin;

--
-- Name: fn_cirugia_personal_rol(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_cirugia_personal_rol() OWNER TO admin;

--
-- Name: fn_consulta_cita(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_consulta_cita() OWNER TO admin;

--
-- Name: fn_edad(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_edad(p_fecha_nacimiento date, p_fecha date DEFAULT CURRENT_DATE) RETURNS smallint
    LANGUAGE sql IMMUTABLE
    AS $$
    select extract(year from age(p_fecha, p_fecha_nacimiento))::smallint;
$$;


ALTER FUNCTION public.fn_edad(p_fecha_nacimiento date, p_fecha date) OWNER TO admin;

--
-- Name: fn_egreso_fecha(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_egreso_fecha() OWNER TO admin;

--
-- Name: fn_enfermero_desde_personal(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_enfermero_desde_personal() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    p personal%rowtype;
begin
    select * into p from personal where id_personal = new.id_enfermero;
    if not found or p.tipo_personal <> 'enfermero' then
        raise exception 'El enfermero % debe registrarse primero en personal como enfermero', new.id_enfermero;
    end if;
    new.nombres := p.nombres;
    new.apellidos := p.apellidos;
    new.dpi := p.dpi;
    new.telefono := p.telefono;
    new.id_hospital := p.id_hospital;
    return new;
end $$;


ALTER FUNCTION public.fn_enfermero_desde_personal() OWNER TO admin;

--
-- Name: fn_hosp_insumo_ingreso(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_hosp_insumo_ingreso() OWNER TO admin;

--
-- Name: fn_ingreso_consistencia(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_ingreso_consistencia() OWNER TO admin;

--
-- Name: fn_medico_desde_personal(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_medico_desde_personal() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    p personal%rowtype;
begin
    select * into p from personal where id_personal = new.id_medico;
    if not found or p.tipo_personal <> 'medico' then
        raise exception 'El médico % debe registrarse primero en personal como medico', new.id_medico;
    end if;
    new.nombres := p.nombres;
    new.apellidos := p.apellidos;
    new.dpi := p.dpi;
    new.telefono := p.telefono;
    new.id_municipio := p.id_municipio;
    new.area := p.area;
    new.id_hospital := p.id_hospital;
    return new;
end $$;


ALTER FUNCTION public.fn_medico_desde_personal() OWNER TO admin;

--
-- Name: fn_medico_jerarquia(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_medico_jerarquia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if new.id_medico_superior is null then
        return new;
    end if;
    if (select id_hospital from medico where id_medico = new.id_medico_superior) <> new.id_hospital then
        raise exception 'El superior % no trabaja en el hospital del médico %', new.id_medico_superior, new.id_medico;
    end if;
    -- se sube por la cadena desde el nuevo superior; si se llega al propio medico hay un ciclo
    if exists (
        with recursive cadena(id_medico) as (
            select new.id_medico_superior
            union
            select m.id_medico_superior
              from medico m join cadena c on m.id_medico = c.id_medico
             where m.id_medico_superior is not null
        )
        select 1 from cadena where id_medico = new.id_medico
    ) then
        raise exception 'Asignar a % como superior de % crearía un ciclo en la cadena de mando',
            new.id_medico_superior, new.id_medico;
    end if;
    return new;
end $$;


ALTER FUNCTION public.fn_medico_jerarquia() OWNER TO admin;

--
-- Name: fn_objetivo_01(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_01(p_desde date, p_hasta date) RETURNS TABLE(hospital character varying, reservaciones bigint, consultas bigint, proximas_consultas bigint, demanda_total bigint)
    LANGUAGE sql STABLE
    AS $$
    with cita_lapso as (
        select ci.id_cita, ci.estado, me.id_hospital
          from cita ci
          join medico me on me.id_medico = ci.id_medico
         where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
    ), conteo as (
        select cl.id_hospital,
               count(*) filter (where cl.estado <> 'cancelada') as reservaciones,
               count(co.id_consulta) as consultas,
               count(re.fecha_proxima_cita) as proximas_consultas
          from cita_lapso cl
          left join consulta co on co.id_cita = cl.id_cita
          left join receta re on re.id_consulta = co.id_consulta
         group by cl.id_hospital
    )
    select h.nombre, c.reservaciones, c.consultas, c.proximas_consultas,
           c.reservaciones + c.consultas + c.proximas_consultas
      from conteo c
      join hospital h on h.id_hospital = c.id_hospital
     order by 5 desc, h.nombre
     limit 3;
$$;


ALTER FUNCTION public.fn_objetivo_01(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_01(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_01(p_desde date, p_hasta date) IS 'Objetivo 1: 3 hospitales con mayor demanda en consulta externa.';


--
-- Name: fn_objetivo_02(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_02(p_desde date, p_hasta date) RETURNS TABLE(posicion bigint, medico text, especialidad character varying, hospital character varying, calificacion_promedio numeric, calificaciones bigint, consultas bigint)
    LANGUAGE sql STABLE
    AS $$
    with consulta_lapso as (
        select co.id_consulta, ci.id_medico
          from consulta co
          join cita ci on ci.id_cita = co.id_cita
         where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
    ), por_medico as (
        select cl.id_medico,
               avg(ca.puntuacion) as promedio,
               count(ca.id_calificacion) as calificaciones,
               count(distinct cl.id_consulta) as consultas
          from consulta_lapso cl
          left join calificacion ca on ca.id_consulta = cl.id_consulta
         group by cl.id_medico
        having count(ca.id_calificacion) > 0
    )
    select rank() over (order by pm.promedio, pm.consultas desc),
           me.nombres || ' ' || me.apellidos, es.nombre, h.nombre,
           round(pm.promedio, 2), pm.calificaciones, pm.consultas
      from por_medico pm
      join medico me on me.id_medico = pm.id_medico
      join especialidad es on es.id_especialidad = me.id_especialidad
      join hospital h on h.id_hospital = me.id_hospital
     order by pm.promedio, pm.consultas desc
     limit 5;
$$;


ALTER FUNCTION public.fn_objetivo_02(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_02(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_02(p_desde date, p_hasta date) IS 'Objetivo 2: 5 médicos de consulta externa con menor calificación promedio.';


--
-- Name: fn_objetivo_03(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_03(p_desde date, p_hasta date) RETURNS TABLE(posicion bigint, medico text, hospital character varying, turnos bigint, horas_laboradas bigint, egresos_vivos bigint)
    LANGUAGE sql STABLE
    AS $$
    with turnos as (
        select tm.id_medico, count(*) as turnos
          from turno_medico tm
          join turno_emergencia t on t.id_turno = tm.id_turno
         where t.fecha between p_desde and p_hasta
         group by tm.id_medico
    ), egresos as (
        select e.id_medico, count(*) as egresos
          from egreso e
          join ingreso i on i.id_ingreso = e.id_ingreso
          join unidad_medica u on u.id_unidad = i.id_unidad
         where u.tipo_unidad = 'Emergencias'
           and e.codigo_egreso = 'vivo' and not e.sin_consentimiento
           and e.fecha_hora_egreso >= p_desde and e.fecha_hora_egreso < p_hasta + 1
         group by e.id_medico
    )
    select rank() over (order by coalesce(eg.egresos, 0) desc, t.turnos desc),
           me.nombres || ' ' || me.apellidos, h.nombre,
           t.turnos, t.turnos * 12, coalesce(eg.egresos, 0)
      from turnos t
      join medico me on me.id_medico = t.id_medico
      join hospital h on h.id_hospital = me.id_hospital
      left join egresos eg on eg.id_medico = t.id_medico
     order by 1
     limit 5;
$$;


ALTER FUNCTION public.fn_objetivo_03(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_03(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_03(p_desde date, p_hasta date) IS 'Objetivo 3: 5 mejores médicos de emergencias.';


--
-- Name: fn_objetivo_04(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_04(p_desde date, p_hasta date) RETURNS TABLE(hospital character varying, ingresos bigint, egresos bigint, atendidos_sin_espera bigint, porcentaje_sin_espera numeric, promedio_turnos_espera numeric)
    LANGUAGE sql STABLE
    AS $$
    select h.nombre,
           count(*),
           count(e.id_egreso),
           count(*) filter (where i.turnos_espera = 0),
           round(100.0 * count(*) filter (where i.turnos_espera = 0) / count(*), 1),
           round(avg(i.turnos_espera), 2)
      from ingreso i
      join unidad_medica u on u.id_unidad = i.id_unidad
      join hospital h on h.id_hospital = u.id_hospital
      left join egreso e on e.id_ingreso = i.id_ingreso
     where u.tipo_unidad = 'Emergencias'
       and i.fecha_hora_ingreso >= p_desde and i.fecha_hora_ingreso < p_hasta + 1
     group by h.id_hospital, h.nombre
     order by 5 desc, 6, 2 desc
     limit 3;
$$;


ALTER FUNCTION public.fn_objetivo_04(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_04(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_04(p_desde date, p_hasta date) IS 'Objetivo 4: 3 hospitales con mayor disponibilidad de camillas en emergencias.';


--
-- Name: fn_objetivo_05(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_05(p_desde date, p_hasta date) RETURNS TABLE(cirujano text, especialidad character varying, agendamientos_aprobados bigint, insumos bigint, instrumentos bigint, equipos bigint, recursos_por_cirugia numeric)
    LANGUAGE sql STABLE
    AS $$
    with aprobado as (
        select a.id_agendamiento, a.id_medico_cirujano
          from agendamiento_quirurgico a
         where a.estado_solicitud = 'aprobada'
           and a.fecha_hora_solicitud >= p_desde and a.fecha_hora_solicitud < p_hasta + 1
    ), recursos as (
        select ap.id_medico_cirujano,
               count(*) as aprobados,
               sum((select coalesce(sum(cantidad), 0) from requerimiento_insumo r where r.id_agendamiento = ap.id_agendamiento)) as insumos,
               sum((select coalesce(sum(cantidad), 0) from requerimiento_instrumento r where r.id_agendamiento = ap.id_agendamiento)) as instrumentos,
               sum((select coalesce(sum(cantidad), 0) from requerimiento_equipo r where r.id_agendamiento = ap.id_agendamiento)) as equipos
          from aprobado ap
         group by ap.id_medico_cirujano
    )
    select me.nombres || ' ' || me.apellidos, es.nombre, r.aprobados,
           r.insumos::bigint, r.instrumentos::bigint, r.equipos::bigint,
           round((r.insumos + r.instrumentos + r.equipos) / r.aprobados, 2)
      from recursos r
      join medico me on me.id_medico = r.id_medico_cirujano
      join especialidad es on es.id_especialidad = me.id_especialidad
     order by r.aprobados desc, 7
     limit 3;
$$;


ALTER FUNCTION public.fn_objetivo_05(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_05(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_05(p_desde date, p_hasta date) IS 'Objetivo 5: 3 cirujanos más eficientes (más aprobados, menos recursos).';


--
-- Name: fn_objetivo_06(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_06(p_desde date, p_hasta date) RETURNS TABLE(tipo_cirugia character varying, especialidad character varying, cirugias bigint, ingresos numeric)
    LANGUAGE sql STABLE
    AS $$
    with cirugia_exitosa as (
        select c.id_cirugia, a.id_tipo_cirugia
          from cirugia c
          join agendamiento_quirurgico a on a.id_agendamiento = c.id_agendamiento
         where c.condicion_evolucion = 'sin_complicaciones'
           and c.fecha_hora_inicio >= p_desde and c.fecha_hora_inicio < p_hasta + 1
           and not exists (
                select 1
                  from registro_procedimiento rp
                  join aspecto_quirurgico ap on ap.id_aspecto = rp.id_aspecto
                 where rp.id_cirugia = c.id_cirugia
                   and ap.etapa = 'intraoperatorio'
                   and rp.resultado not in ('exito', 'aceptable'))
    )
    select t.nombre, es.nombre, count(*), sum(f.total)
      from cirugia_exitosa ce
      join factura f on f.id_cirugia = ce.id_cirugia
      join tipo_cirugia t on t.id_tipo_cirugia = ce.id_tipo_cirugia
      join especialidad es on es.id_especialidad = t.id_especialidad
     group by t.id_tipo_cirugia, t.nombre, es.nombre
     order by 4 desc
     limit 3;
$$;


ALTER FUNCTION public.fn_objetivo_06(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_06(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_06(p_desde date, p_hasta date) IS 'Objetivo 6: 3 tipos de cirugía con mayores ingresos sin complicaciones.';


--
-- Name: fn_objetivo_07(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_07(p_desde date, p_hasta date) RETURNS TABLE(hospital character varying, ingresos numeric, camillas_asignadas bigint, costo_promedio_servicio numeric, ingreso_por_camilla numeric)
    LANGUAGE sql STABLE
    AS $$
    select h.nombre,
           sum(f.total),
           count(distinct i.id_camilla),
           round(avg(s.costo), 2),
           round(sum(f.total) / count(distinct i.id_camilla), 2)
      from factura f
      join ingreso i on i.id_ingreso = f.id_ingreso
      join unidad_medica u on u.id_unidad = i.id_unidad
      join hospital h on h.id_hospital = u.id_hospital
      join servicio_atencion s on s.id_servicio = i.id_servicio
     where u.tipo_unidad = 'Hospitalización'
       and f.fecha_emision >= p_desde and f.fecha_emision < p_hasta + 1
     group by h.id_hospital, h.nombre
     order by 5 desc
     limit 3;
$$;


ALTER FUNCTION public.fn_objetivo_07(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_07(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_07(p_desde date, p_hasta date) IS 'Objetivo 7: 3 hospitales con mayor ingreso por camilla en hospitalización.';


--
-- Name: fn_objetivo_08(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_08(p_desde date, p_hasta date) RETURNS TABLE(hospital character varying, unidad character varying, efectivo numeric, tarjeta_credito numeric, tarjeta_debito numeric)
    LANGUAGE sql STABLE
    AS $$
    select h.nombre, vf.tipo_unidad,
           coalesce(sum(p.monto) filter (where mp.nombre = 'Efectivo'), 0),
           coalesce(sum(p.monto) filter (where mp.nombre = 'Tarjeta de crédito'), 0),
           coalesce(sum(p.monto) filter (where mp.nombre = 'Tarjeta de débito'), 0)
      from pago p
      join metodo_pago mp on mp.id_metodo_pago = p.id_metodo_pago
      join v_factura vf on vf.id_factura = p.id_factura
      join hospital h on h.id_hospital = vf.id_hospital
     where p.fecha_pago between p_desde and p_hasta
     group by h.id_hospital, h.nombre, vf.tipo_unidad
     order by h.id_hospital, vf.tipo_unidad;
$$;


ALTER FUNCTION public.fn_objetivo_08(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_08(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_08(p_desde date, p_hasta date) IS 'Objetivo 8: pagos por método (efectivo, crédito, débito) por hospital y unidad.';


--
-- Name: fn_objetivo_09(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_09(p_desde date, p_hasta date) RETURNS TABLE(hospital character varying, ingresos_fichas bigint, citas bigint, consultas bigint, visitas bigint, monto_facturado numeric, ingreso_por_visita numeric)
    LANGUAGE sql STABLE
    AS $$
    with fichas as (
        select u.id_hospital, count(*) as n
          from ingreso i join unidad_medica u on u.id_unidad = i.id_unidad
         where i.fecha_hora_ingreso >= p_desde and i.fecha_hora_ingreso < p_hasta + 1
         group by u.id_hospital
    ), citas as (
        select me.id_hospital, count(*) filter (where ci.estado <> 'cancelada') as citas, count(co.id_consulta) as consultas
          from cita ci
          join medico me on me.id_medico = ci.id_medico
          left join consulta co on co.id_cita = ci.id_cita
         where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
         group by me.id_hospital
    ), facturado as (
        select id_hospital, sum(total) as monto
          from v_factura
         where fecha_emision >= p_desde and fecha_emision < p_hasta + 1
         group by id_hospital
    )
    select h.nombre, coalesce(fi.n, 0), coalesce(c.citas, 0), coalesce(c.consultas, 0),
           coalesce(fi.n, 0) + coalesce(c.citas, 0),
           coalesce(fa.monto, 0),
           round(coalesce(fa.monto, 0) / nullif(coalesce(fi.n, 0) + coalesce(c.citas, 0), 0), 2)
      from hospital h
      left join fichas fi on fi.id_hospital = h.id_hospital
      left join citas c on c.id_hospital = h.id_hospital
      left join facturado fa on fa.id_hospital = h.id_hospital
     order by 7 desc nulls last
     limit 3;
$$;


ALTER FUNCTION public.fn_objetivo_09(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_09(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_09(p_desde date, p_hasta date) IS 'Objetivo 9: 3 hospitales con mayor ingreso por visita.';


--
-- Name: fn_objetivo_10(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_10() RETURNS TABLE(hospital character varying, fecha_mas_decesos date, decesos_en_fecha bigint, unidad_con_mas_decesos character varying, decesos_en_unidad bigint, decesos_totales bigint)
    LANGUAGE sql STABLE
    AS $$
    with deceso as (
        select u.id_hospital, u.tipo_unidad, e.fecha_hora_egreso::date as fecha
          from egreso e
          join ingreso i on i.id_ingreso = e.id_ingreso
          join unidad_medica u on u.id_unidad = i.id_unidad
         where e.codigo_egreso = 'muerto'
    ), por_fecha as (
        select id_hospital, fecha, count(*) as n,
               row_number() over (partition by id_hospital order by count(*) desc, fecha desc) as orden
          from deceso group by id_hospital, fecha
    ), por_unidad as (
        select id_hospital, tipo_unidad, count(*) as n,
               row_number() over (partition by id_hospital order by count(*) desc, tipo_unidad) as orden,
               sum(count(*)) over (partition by id_hospital) as total
          from deceso group by id_hospital, tipo_unidad
    )
    select h.nombre, pf.fecha, pf.n, pu.tipo_unidad, pu.n, pu.total::bigint
      from por_fecha pf
      join por_unidad pu on pu.id_hospital = pf.id_hospital and pu.orden = 1
      join hospital h on h.id_hospital = pf.id_hospital
     where pf.orden = 1
     order by pf.n desc, pu.total desc, h.nombre;
$$;


ALTER FUNCTION public.fn_objetivo_10() OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_10(); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_10() IS 'Objetivo 10: fecha con más decesos y unidad con más decesos por hospital.';


--
-- Name: fn_objetivo_11(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_11(p_desde date, p_hasta date) RETURNS TABLE(hospital character varying, facturas bigint, total_facturado numeric, total_cobrado numeric, pendiente_de_cobro numeric)
    LANGUAGE sql STABLE
    AS $$
    with facturado as (
        select id_hospital, count(*) as facturas, sum(total) as total
          from v_factura
         where fecha_emision >= p_desde and fecha_emision < p_hasta + 1
         group by id_hospital
    ), cobrado as (
        select vf.id_hospital, sum(p.monto) as total
          from pago p join v_factura vf on vf.id_factura = p.id_factura
         where p.fecha_pago between p_desde and p_hasta
         group by vf.id_hospital
    )
    select h.nombre, coalesce(f.facturas, 0), coalesce(f.total, 0), coalesce(c.total, 0),
           coalesce(f.total, 0) - coalesce(c.total, 0)
      from hospital h
      left join facturado f on f.id_hospital = h.id_hospital
      left join cobrado c on c.id_hospital = h.id_hospital
     order by 3 desc;
$$;


ALTER FUNCTION public.fn_objetivo_11(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_11(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_11(p_desde date, p_hasta date) IS 'Objetivo 11: ingresos totales (facturado y cobrado) por hospital.';


--
-- Name: fn_objetivo_12(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_12(p_desde date, p_hasta date) RETURNS TABLE(hospital character varying, jornada character varying, ingresos bigint, edad_promedio numeric, masculino bigint, femenino bigint)
    LANGUAGE sql STABLE
    AS $$
    select h.nombre, t.jornada, count(*),
           round(avg(fn_edad(p.fecha_nacimiento, i.fecha_hora_ingreso::date)), 1),
           count(*) filter (where p.sexo = 'Masculino'),
           count(*) filter (where p.sexo = 'Femenino')
      from ingreso i
      join turno_emergencia t on t.id_turno = i.id_turno
      join unidad_medica u on u.id_unidad = i.id_unidad
      join hospital h on h.id_hospital = u.id_hospital
      join paciente p on p.id_paciente = i.id_paciente
     where i.fecha_hora_ingreso >= p_desde and i.fecha_hora_ingreso < p_hasta + 1
     group by h.id_hospital, h.nombre, t.jornada
     order by h.id_hospital, t.jornada;
$$;


ALTER FUNCTION public.fn_objetivo_12(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_12(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_12(p_desde date, p_hasta date) IS 'Objetivo 12: edad promedio y sexo en emergencias por hospital y turno.';


--
-- Name: fn_objetivo_13(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_13(p_desde date, p_hasta date) RETURNS TABLE(hospital character varying, fecha date, especialidad character varying, sexo character varying, citas bigint)
    LANGUAGE sql STABLE
    AS $$
    select h.nombre, ci.fecha_hora::date, es.nombre, p.sexo, count(*)
      from cita ci
      join paciente p on p.id_paciente = ci.id_paciente
      join medico me on me.id_medico = ci.id_medico
      join especialidad es on es.id_especialidad = me.id_especialidad
      join hospital h on h.id_hospital = me.id_hospital
     where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
     group by h.id_hospital, h.nombre, ci.fecha_hora::date, es.nombre, p.sexo
     order by h.id_hospital, 2, 3, 4;
$$;


ALTER FUNCTION public.fn_objetivo_13(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_13(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_13(p_desde date, p_hasta date) IS 'Objetivo 13: citas por hospital, fecha, especialidad y sexo.';


--
-- Name: fn_objetivo_14(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_14(p_desde date, p_hasta date) RETURNS TABLE(hospital character varying, unidad character varying, facturas bigint, promedio_cuotas numeric, minimo_cuotas smallint, maximo_cuotas smallint)
    LANGUAGE sql STABLE
    AS $$
    select h.nombre, vf.tipo_unidad, count(*), round(avg(vf.numero_cuotas), 2),
           min(vf.numero_cuotas), max(vf.numero_cuotas)
      from v_factura vf
      join hospital h on h.id_hospital = vf.id_hospital
     where vf.fecha_emision >= p_desde and vf.fecha_emision < p_hasta + 1
     group by h.id_hospital, h.nombre, vf.tipo_unidad
     order by h.id_hospital, vf.tipo_unidad;
$$;


ALTER FUNCTION public.fn_objetivo_14(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_14(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_14(p_desde date, p_hasta date) IS 'Objetivo 14: promedio de cuotas por unidad y hospital.';


--
-- Name: fn_objetivo_17_correlacionada(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_17_correlacionada(p_desde date, p_hasta date) RETURNS TABLE(id_medico integer, medico text, hospital character varying, calificacion_promedio numeric, posicion_en_hospital bigint, posicion_en_cadena bigint)
    LANGUAGE sql STABLE
    AS $$
    with pm as materialized (select * from fn_promedio_medico(p_desde, p_hasta))
    select p1.id_medico, me.nombres || ' ' || me.apellidos, h.nombre, round(p1.promedio, 2),
           1 + (select count(*) from pm p2 where p2.id_hospital = p1.id_hospital and p2.promedio < p1.promedio),
           1 + (select count(*) from pm p2 where p2.promedio < p1.promedio)
      from pm p1
      join medico me on me.id_medico = p1.id_medico
      join hospital h on h.id_hospital = p1.id_hospital
     order by 6, 3, 2;
$$;


ALTER FUNCTION public.fn_objetivo_17_correlacionada(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_17_correlacionada(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_17_correlacionada(p_desde date, p_hasta date) IS 'Objetivo 17 (forma B): ranking por hospital y global con subconsultas correlacionadas.';


--
-- Name: fn_objetivo_17_ventana(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_17_ventana(p_desde date, p_hasta date) RETURNS TABLE(id_medico integer, medico text, hospital character varying, calificacion_promedio numeric, posicion_en_hospital bigint, posicion_en_cadena bigint)
    LANGUAGE sql STABLE
    AS $$
    select pm.id_medico, me.nombres || ' ' || me.apellidos, h.nombre, round(pm.promedio, 2),
           rank() over (partition by pm.id_hospital order by pm.promedio),
           rank() over (order by pm.promedio)
      from fn_promedio_medico(p_desde, p_hasta) pm
      join medico me on me.id_medico = pm.id_medico
      join hospital h on h.id_hospital = pm.id_hospital
     order by 6, 3, 2;
$$;


ALTER FUNCTION public.fn_objetivo_17_ventana(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_17_ventana(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_17_ventana(p_desde date, p_hasta date) IS 'Objetivo 17 (forma A): ranking por hospital y global con funciones de ventana.';


--
-- Name: fn_objetivo_18(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_objetivo_18(p_desde date, p_hasta date) RETURNS TABLE(id_paciente integer, numero_expediente character varying, paciente text, edad smallint, sexo character varying)
    LANGUAGE sql STABLE
    AS $$
    with atencion (id_paciente, tipo_unidad) as (
        select ci.id_paciente, 'Consulta Externa'::varchar
          from consulta co join cita ci on ci.id_cita = co.id_cita
         where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
        union
        select i.id_paciente, u.tipo_unidad
          from ingreso i join unidad_medica u on u.id_unidad = i.id_unidad
         where i.fecha_hora_ingreso >= p_desde and i.fecha_hora_ingreso < p_hasta + 1
    ), unidad (tipo_unidad) as (
        values ('Consulta Externa'), ('Emergencias'), ('Cirugía'), ('Hospitalización')
    )
    select p.id_paciente, p.numero_expediente, p.nombres || ' ' || p.apellidos, fn_edad(p.fecha_nacimiento), p.sexo
      from paciente p
     where not exists (                       -- no existe una unidad...
            select 1 from unidad u
             where not exists (               -- ...en la que el paciente no haya sido atendido
                    select 1 from atencion a
                     where a.id_paciente = p.id_paciente and a.tipo_unidad = u.tipo_unidad))
     order by p.id_paciente;
$$;


ALTER FUNCTION public.fn_objetivo_18(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: FUNCTION fn_objetivo_18(p_desde date, p_hasta date); Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON FUNCTION public.fn_objetivo_18(p_desde date, p_hasta date) IS 'Objetivo 18: pacientes atendidos en las 4 unidades (división relacional).';


--
-- Name: fn_paciente_nacimiento(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_paciente_nacimiento() OWNER TO admin;

--
-- Name: fn_pago_plan(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_pago_plan() OWNER TO admin;

--
-- Name: fn_personal_a_subtipo(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_personal_a_subtipo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if new.tipo_personal = 'medico' then
        -- el disparador del subtipo vuelve a leer los datos desde personal
        update medico set id_medico = id_medico where id_medico = new.id_personal;
    else
        update enfermero set id_enfermero = id_enfermero where id_enfermero = new.id_personal;
    end if;
    return null;
end $$;


ALTER FUNCTION public.fn_personal_a_subtipo() OWNER TO admin;

--
-- Name: fn_personal_completo(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_personal_completo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if (new.tipo_personal = 'medico' and not exists (select 1 from medico where id_medico = new.id_personal))
       or (new.tipo_personal = 'enfermero' and not exists (select 1 from enfermero where id_enfermero = new.id_personal)) then
        raise exception 'La persona % (%) no tiene registro en su subtipo', new.id_personal, new.tipo_personal;
    end if;
    return null;
end $$;


ALTER FUNCTION public.fn_personal_completo() OWNER TO admin;

--
-- Name: fn_promedio_medico(date, date); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_promedio_medico(p_desde date, p_hasta date) RETURNS TABLE(id_medico integer, id_hospital integer, promedio numeric, calificaciones bigint)
    LANGUAGE sql STABLE
    AS $$
    select ci.id_medico, me.id_hospital, avg(ca.puntuacion), count(*)
      from calificacion ca
      join consulta co on co.id_consulta = ca.id_consulta
      join cita ci on ci.id_cita = co.id_cita
      join medico me on me.id_medico = ci.id_medico
     where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
     group by ci.id_medico, me.id_hospital;
$$;


ALTER FUNCTION public.fn_promedio_medico(p_desde date, p_hasta date) OWNER TO admin;

--
-- Name: fn_quirofano_unidad(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_quirofano_unidad() OWNER TO admin;

--
-- Name: fn_receta_proxima_cita(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_receta_proxima_cita() OWNER TO admin;

--
-- Name: fn_registrar_auditoria(text, text, integer, text, text, text); Type: FUNCTION; Schema: public; Owner: dueno_auditoria
--

CREATE FUNCTION public.fn_registrar_auditoria(p_usuario_bd text, p_tabla text, p_id integer, p_campo text, p_anterior text, p_nuevo text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
    if pg_trigger_depth() = 0 then
        raise exception 'La bitácora solo se escribe desde los disparadores de auditoría';
    end if;
    insert into auditoria_personal (usuario_bd, usuario_sesion, usuario_aplicacion, tabla, id_registro,
                                    campo, valor_anterior, valor_nuevo)
    values (p_usuario_bd, session_user, nullif(current_setting('app.usuario', true), ''),
            p_tabla, p_id, p_campo, p_anterior, p_nuevo);
end $$;


ALTER FUNCTION public.fn_registrar_auditoria(p_usuario_bd text, p_tabla text, p_id integer, p_campo text, p_anterior text, p_nuevo text) OWNER TO dueno_auditoria;

--
-- Name: fn_registro_resultado(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_registro_resultado() OWNER TO admin;

--
-- Name: fn_tipo_unidad(integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.fn_tipo_unidad(p_id_unidad integer) RETURNS character varying
    LANGUAGE sql STABLE
    AS $$
    select tipo_unidad from unidad_medica where id_unidad = p_id_unidad;
$$;


ALTER FUNCTION public.fn_tipo_unidad(p_id_unidad integer) OWNER TO admin;

--
-- Name: fn_traslado_origen(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_traslado_origen() OWNER TO admin;

--
-- Name: fn_turno_medico_hospital(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_turno_medico_hospital() OWNER TO admin;

--
-- Name: fn_turno_unidad(); Type: FUNCTION; Schema: public; Owner: admin
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


ALTER FUNCTION public.fn_turno_unidad() OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cirugia; Type: TABLE; Schema: propuesta_bloque_e; Owner: admin
--

CREATE TABLE propuesta_bloque_e.cirugia (
    id_cirugia integer NOT NULL,
    id_cirujano integer NOT NULL,
    id_paciente integer NOT NULL,
    codigo_cie10 character varying(7) NOT NULL,
    fecha date NOT NULL
);


ALTER TABLE propuesta_bloque_e.cirugia OWNER TO admin;

--
-- Name: cirugia_insumo; Type: TABLE; Schema: propuesta_bloque_e; Owner: admin
--

CREATE TABLE propuesta_bloque_e.cirugia_insumo (
    id_cirugia integer NOT NULL,
    id_insumo integer NOT NULL,
    cantidad smallint NOT NULL,
    CONSTRAINT ck_cirugia_insumo_cantidad CHECK ((cantidad > 0))
);


ALTER TABLE propuesta_bloque_e.cirugia_insumo OWNER TO admin;

--
-- Name: cirujano; Type: TABLE; Schema: propuesta_bloque_e; Owner: admin
--

CREATE TABLE propuesta_bloque_e.cirujano (
    id_cirujano integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    id_especialidad integer NOT NULL
);


ALTER TABLE propuesta_bloque_e.cirujano OWNER TO admin;

--
-- Name: cirujano_id_cirujano_seq; Type: SEQUENCE; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE propuesta_bloque_e.cirujano ALTER COLUMN id_cirujano ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME propuesta_bloque_e.cirujano_id_cirujano_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: diagnostico; Type: TABLE; Schema: propuesta_bloque_e; Owner: admin
--

CREATE TABLE propuesta_bloque_e.diagnostico (
    codigo_cie10 character varying(7) NOT NULL,
    descripcion character varying(200) NOT NULL,
    CONSTRAINT ck_diagnostico_codigo CHECK (((codigo_cie10)::text ~ '^[A-Z][0-9]{2}(\.[0-9]{1,2})?$'::text))
);


ALTER TABLE propuesta_bloque_e.diagnostico OWNER TO admin;

--
-- Name: especialidad; Type: TABLE; Schema: propuesta_bloque_e; Owner: admin
--

CREATE TABLE propuesta_bloque_e.especialidad (
    id_especialidad integer NOT NULL,
    nombre character varying(80) NOT NULL
);


ALTER TABLE propuesta_bloque_e.especialidad OWNER TO admin;

--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE propuesta_bloque_e.especialidad ALTER COLUMN id_especialidad ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME propuesta_bloque_e.especialidad_id_especialidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insumo; Type: TABLE; Schema: propuesta_bloque_e; Owner: admin
--

CREATE TABLE propuesta_bloque_e.insumo (
    id_insumo integer NOT NULL,
    nombre character varying(120) NOT NULL
);


ALTER TABLE propuesta_bloque_e.insumo OWNER TO admin;

--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE propuesta_bloque_e.insumo ALTER COLUMN id_insumo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME propuesta_bloque_e.insumo_id_insumo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: paciente; Type: TABLE; Schema: propuesta_bloque_e; Owner: admin
--

CREATE TABLE propuesta_bloque_e.paciente (
    id_paciente integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL
);


ALTER TABLE propuesta_bloque_e.paciente OWNER TO admin;

--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE propuesta_bloque_e.paciente ALTER COLUMN id_paciente ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME propuesta_bloque_e.paciente_id_paciente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: reporte_cirugia; Type: TABLE; Schema: propuesta_bloque_e; Owner: admin
--

CREATE TABLE propuesta_bloque_e.reporte_cirugia (
    id_cirugia integer NOT NULL,
    nombre_cirujano character varying(150),
    especialidad_cirujano character varying(80),
    nombre_paciente character varying(150),
    codigo_diagnostico character varying(7),
    descripcion_diagnostico character varying(200),
    nombre_insumo_1 character varying(120),
    cantidad_insumo_1 smallint,
    nombre_insumo_2 character varying(120),
    cantidad_insumo_2 smallint,
    fecha date
);


ALTER TABLE propuesta_bloque_e.reporte_cirugia OWNER TO admin;

--
-- Name: agendamiento_quirurgico; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.agendamiento_quirurgico OWNER TO admin;

--
-- Name: TABLE agendamiento_quirurgico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.agendamiento_quirurgico IS 'Solicitud de cirugía que el cirujano envía al comité médico.';


--
-- Name: COLUMN agendamiento_quirurgico.caracter; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.agendamiento_quirurgico.caracter IS 'urgente o programado.';


--
-- Name: COLUMN agendamiento_quirurgico.resumen_clinico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.agendamiento_quirurgico.resumen_clinico IS 'Resumen de la historia clínica que justifica la cirugía.';


--
-- Name: COLUMN agendamiento_quirurgico.tiempo_estimado_min; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.agendamiento_quirurgico.tiempo_estimado_min IS 'Tiempo estimado de la intervención en minutos.';


--
-- Name: COLUMN agendamiento_quirurgico.fecha_hora_solicitud; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.agendamiento_quirurgico.fecha_hora_solicitud IS 'Fecha y hora en que se envió la solicitud.';


--
-- Name: COLUMN agendamiento_quirurgico.estado_solicitud; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.agendamiento_quirurgico.estado_solicitud IS 'Decisión del comité: pendiente, aprobada o rechazada.';


--
-- Name: COLUMN agendamiento_quirurgico.motivo_rechazo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.agendamiento_quirurgico.motivo_rechazo IS 'Razones del rechazo (base de cirugías rechazadas).';


--
-- Name: COLUMN agendamiento_quirurgico.fecha_hora_agendada; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.agendamiento_quirurgico.fecha_hora_agendada IS 'Fecha y hora asignadas al aprobarse.';


--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: aspecto_quirurgico; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.aspecto_quirurgico OWNER TO admin;

--
-- Name: TABLE aspecto_quirurgico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.aspecto_quirurgico IS 'Aspectos que el enfermero verifica en cada etapa de la cirugía.';


--
-- Name: COLUMN aspecto_quirurgico.etapa; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.aspecto_quirurgico.etapa IS 'preoperatorio, intraoperatorio o postoperatorio.';


--
-- Name: COLUMN aspecto_quirurgico.seccion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.aspecto_quirurgico.seccion IS 'Sección de la etapa (Planificación, Entrada, Pausa quirúrgica...).';


--
-- Name: COLUMN aspecto_quirurgico.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.aspecto_quirurgico.nombre IS 'Aspecto que se verifica.';


--
-- Name: COLUMN aspecto_quirurgico.tipo_evaluacion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.aspecto_quirurgico.tipo_evaluacion IS 'exito_falla o aceptabilidad.';


--
-- Name: aspecto_quirurgico_id_aspecto_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: auditoria_personal; Type: TABLE; Schema: public; Owner: dueno_auditoria
--

CREATE TABLE public.auditoria_personal (
    id_auditoria bigint NOT NULL,
    fecha_hora timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    usuario_bd character varying(63) NOT NULL,
    usuario_sesion character varying(63) NOT NULL,
    usuario_aplicacion character varying(100),
    tabla character varying(30) NOT NULL,
    id_registro integer NOT NULL,
    campo character varying(30) NOT NULL,
    valor_anterior text,
    valor_nuevo text,
    CONSTRAINT ck_auditoria_campo CHECK (((campo)::text = ANY ((ARRAY['salario'::character varying, 'nivel_acceso'::character varying, 'id_especialidad'::character varying])::text[]))),
    CONSTRAINT ck_auditoria_tabla CHECK (((tabla)::text = ANY ((ARRAY['personal'::character varying, 'medico'::character varying])::text[])))
);


ALTER TABLE public.auditoria_personal OWNER TO dueno_auditoria;

--
-- Name: TABLE auditoria_personal; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON TABLE public.auditoria_personal IS 'Bitácora automática de los cambios de salario, nivel de acceso y especialidad del personal.';


--
-- Name: COLUMN auditoria_personal.id_auditoria; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON COLUMN public.auditoria_personal.id_auditoria IS 'Identificador del registro de la bitácora (lo genera la base, no se puede asignar).';


--
-- Name: COLUMN auditoria_personal.fecha_hora; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON COLUMN public.auditoria_personal.fecha_hora IS 'Momento exacto del cambio (clock_timestamp).';


--
-- Name: COLUMN auditoria_personal.usuario_bd; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON COLUMN public.auditoria_personal.usuario_bd IS 'Rol de base de datos que hizo el cambio.';


--
-- Name: COLUMN auditoria_personal.usuario_sesion; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON COLUMN public.auditoria_personal.usuario_sesion IS 'Usuario con el que se inició la sesión (distinto del rol si se usó SET ROLE).';


--
-- Name: COLUMN auditoria_personal.usuario_aplicacion; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON COLUMN public.auditoria_personal.usuario_aplicacion IS 'Usuario de la aplicación que hizo el cambio, enviado en la variable app.usuario.';


--
-- Name: COLUMN auditoria_personal.tabla; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON COLUMN public.auditoria_personal.tabla IS 'Tabla donde ocurrió el cambio: personal o medico.';


--
-- Name: COLUMN auditoria_personal.id_registro; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON COLUMN public.auditoria_personal.id_registro IS 'Identificador de la persona cuyo dato cambió (id_personal = id_medico).';


--
-- Name: COLUMN auditoria_personal.campo; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON COLUMN public.auditoria_personal.campo IS 'Campo que cambió: salario, nivel_acceso o id_especialidad.';


--
-- Name: COLUMN auditoria_personal.valor_anterior; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON COLUMN public.auditoria_personal.valor_anterior IS 'Valor antes del cambio.';


--
-- Name: COLUMN auditoria_personal.valor_nuevo; Type: COMMENT; Schema: public; Owner: dueno_auditoria
--

COMMENT ON COLUMN public.auditoria_personal.valor_nuevo IS 'Valor después del cambio.';


--
-- Name: auditoria_personal_id_auditoria_seq; Type: SEQUENCE; Schema: public; Owner: dueno_auditoria
--

ALTER TABLE public.auditoria_personal ALTER COLUMN id_auditoria ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.auditoria_personal_id_auditoria_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: calificacion; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.calificacion OWNER TO admin;

--
-- Name: TABLE calificacion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.calificacion IS 'Calificación de la calidad del servicio de un hospital, médico, enfermero o encargado.';


--
-- Name: COLUMN calificacion.fecha; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.calificacion.fecha IS 'Fecha de la calificación.';


--
-- Name: COLUMN calificacion.puntuacion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.calificacion.puntuacion IS 'Puntuación de 1 (peor) a 5 (mejor).';


--
-- Name: COLUMN calificacion.comentario; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.calificacion.comentario IS 'Comentario opcional.';


--
-- Name: calificacion_id_calificacion_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: camilla; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.camilla (
    id_camilla integer NOT NULL,
    id_unidad integer NOT NULL,
    numero smallint NOT NULL,
    disponible boolean DEFAULT true NOT NULL,
    CONSTRAINT ck_camilla_numero CHECK ((numero > 0))
);


ALTER TABLE public.camilla OWNER TO admin;

--
-- Name: TABLE camilla; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.camilla IS 'Camillas de las unidades de Emergencias y Hospitalización.';


--
-- Name: COLUMN camilla.numero; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.camilla.numero IS 'Número de la camilla dentro de su unidad.';


--
-- Name: COLUMN camilla.disponible; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.camilla.disponible IS 'Indica si la camilla está libre.';


--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: chequeo_preanestesico; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.chequeo_preanestesico OWNER TO admin;

--
-- Name: TABLE chequeo_preanestesico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.chequeo_preanestesico IS 'Evaluación del riesgo anestésico (ASA) y plan de anestesia.';


--
-- Name: COLUMN chequeo_preanestesico.clasificacion_asa; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.chequeo_preanestesico.clasificacion_asa IS 'Clasificación ASA del riesgo anestésico (I a VI).';


--
-- Name: COLUMN chequeo_preanestesico.plan_anestesia; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.chequeo_preanestesico.plan_anestesia IS 'Plan de anestesia.';


--
-- Name: chequeo_preanestesico_id_chequeo_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: cirugia; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.cirugia OWNER TO admin;

--
-- Name: TABLE cirugia; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.cirugia IS 'Cirugía realizada a partir de un agendamiento aprobado.';


--
-- Name: COLUMN cirugia.fecha_hora_inicio; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cirugia.fecha_hora_inicio IS 'Inicio de la cirugía.';


--
-- Name: COLUMN cirugia.fecha_hora_fin; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cirugia.fecha_hora_fin IS 'Fin de la cirugía.';


--
-- Name: COLUMN cirugia.estado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cirugia.estado IS 'preoperatorio, intraoperatorio, postoperatorio o finalizada.';


--
-- Name: COLUMN cirugia.condicion_evolucion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cirugia.condicion_evolucion IS 'sin_complicaciones, complicaciones o complicaciones_graves.';


--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: cirugia_insumo; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.cirugia_insumo (
    id_cirugia integer NOT NULL,
    id_insumo integer NOT NULL,
    cantidad smallint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL,
    CONSTRAINT ck_cirugia_insumo_cantidad CHECK ((cantidad > 0)),
    CONSTRAINT ck_cirugia_insumo_costo CHECK ((costo_unitario >= (0)::numeric))
);


ALTER TABLE public.cirugia_insumo OWNER TO admin;

--
-- Name: TABLE cirugia_insumo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.cirugia_insumo IS 'Insumos usados en la cirugía.';


--
-- Name: COLUMN cirugia_insumo.cantidad; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cirugia_insumo.cantidad IS 'Cantidad usada.';


--
-- Name: COLUMN cirugia_insumo.costo_unitario; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cirugia_insumo.costo_unitario IS 'Costo por unidad al momento de usarlo.';


--
-- Name: cirugia_personal; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.cirugia_personal (
    id_cirugia_personal integer NOT NULL,
    id_cirugia integer NOT NULL,
    id_medico integer,
    id_enfermero integer,
    id_rol integer NOT NULL,
    CONSTRAINT ck_cirugia_personal CHECK ((num_nonnulls(id_medico, id_enfermero) = 1))
);


ALTER TABLE public.cirugia_personal OWNER TO admin;

--
-- Name: TABLE cirugia_personal; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.cirugia_personal IS 'Médicos y enfermeros que participan en la cirugía.';


--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: cita; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.cita OWNER TO admin;

--
-- Name: TABLE cita; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.cita IS 'Citas programadas de consulta externa.';


--
-- Name: COLUMN cita.fecha_hora; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cita.fecha_hora IS 'Fecha y hora de la cita.';


--
-- Name: COLUMN cita.numero_clinica; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cita.numero_clinica IS 'Clínica o consultorio donde se atiende.';


--
-- Name: COLUMN cita.medio_asignacion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cita.medio_asignacion IS 'Medio por el que se asignó: teléfono, correo, recepción general o del médico.';


--
-- Name: COLUMN cita.estado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cita.estado IS 'programada, realizada, reprogramada o cancelada.';


--
-- Name: COLUMN cita.es_reconsulta; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cita.es_reconsulta IS 'Indica si es reconsulta (cuesta 75% de la primera consulta).';


--
-- Name: COLUMN cita.es_referido; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cita.es_referido IS 'Indica si el paciente fue referido por una institución (cuesta 80%).';


--
-- Name: COLUMN cita.cancelada_sin_aviso; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cita.cancelada_sin_aviso IS 'Indica si se canceló sin avisar (sobrecargo de 10% en la siguiente cita).';


--
-- Name: COLUMN cita.costo_base; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cita.costo_base IS 'Costo de primera consulta del médico al momento de agendar.';


--
-- Name: COLUMN cita.costo_final; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cita.costo_final IS 'Costo cobrado después de aplicar las reglas de descuento o sobrecargo.';


--
-- Name: cita_id_cita_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: consentimiento_informado; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.consentimiento_informado OWNER TO admin;

--
-- Name: TABLE consentimiento_informado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.consentimiento_informado IS 'Consentimiento informado firmado para la cirugía.';


--
-- Name: COLUMN consentimiento_informado.procedimiento_nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consentimiento_informado.procedimiento_nombre IS 'Nombre específico del procedimiento.';


--
-- Name: COLUMN consentimiento_informado.procedimiento_objetivo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consentimiento_informado.procedimiento_objetivo IS 'Objetivo del procedimiento.';


--
-- Name: COLUMN consentimiento_informado.procedimiento_caracteristicas; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consentimiento_informado.procedimiento_caracteristicas IS 'Características del procedimiento.';


--
-- Name: COLUMN consentimiento_informado.procedimiento_riesgos; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consentimiento_informado.procedimiento_riesgos IS 'Posibles riesgos del procedimiento.';


--
-- Name: COLUMN consentimiento_informado.medico_firmo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consentimiento_informado.medico_firmo IS 'Indica si el médico firmó.';


--
-- Name: COLUMN consentimiento_informado.firmante_nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consentimiento_informado.firmante_nombre IS 'Nombre de quien firma por el paciente.';


--
-- Name: COLUMN consentimiento_informado.firmante_relacion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consentimiento_informado.firmante_relacion IS 'paciente, familiar, tutor o representante_legal.';


--
-- Name: COLUMN consentimiento_informado.firmante_firmo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consentimiento_informado.firmante_firmo IS 'Indica si el paciente o su representante firmó.';


--
-- Name: COLUMN consentimiento_informado.fecha_obtencion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consentimiento_informado.fecha_obtencion IS 'Fecha en que se obtuvo el consentimiento.';


--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: consulta; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.consulta (
    id_consulta integer NOT NULL,
    id_cita integer NOT NULL,
    id_diagnostico integer NOT NULL,
    otros_datos text,
    notas_observaciones text
);


ALTER TABLE public.consulta OWNER TO admin;

--
-- Name: TABLE consulta; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.consulta IS 'Consulta realizada en una cita.';


--
-- Name: COLUMN consulta.otros_datos; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consulta.otros_datos IS 'Otros datos de interés clínico.';


--
-- Name: COLUMN consulta.notas_observaciones; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.consulta.notas_observaciones IS 'Notas u observaciones del médico.';


--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: departamento; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.departamento (
    id_departamento integer NOT NULL,
    nombre character varying(80) NOT NULL
);


ALTER TABLE public.departamento OWNER TO admin;

--
-- Name: TABLE departamento; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.departamento IS 'Departamentos de Guatemala.';


--
-- Name: COLUMN departamento.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.departamento.nombre IS 'Nombre del departamento.';


--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: diagnostico; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.diagnostico (
    id_diagnostico integer NOT NULL,
    codigo_cie10 character varying(7) NOT NULL,
    descripcion character varying(200) NOT NULL,
    CONSTRAINT ck_diagnostico_codigo CHECK (((codigo_cie10)::text ~ '^[A-Z][0-9]{2}(\.[0-9]{1,2})?$'::text))
);


ALTER TABLE public.diagnostico OWNER TO admin;

--
-- Name: TABLE diagnostico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.diagnostico IS 'Diagnósticos de la Clasificación Internacional de Enfermedades (CIE-10).';


--
-- Name: COLUMN diagnostico.codigo_cie10; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.diagnostico.codigo_cie10 IS 'Código CIE-10 del diagnóstico.';


--
-- Name: COLUMN diagnostico.descripcion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.diagnostico.descripcion IS 'Descripción oficial del diagnóstico.';


--
-- Name: diagnostico_id_diagnostico_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: documentacion_etapa; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.documentacion_etapa (
    id_cirugia integer NOT NULL,
    etapa character varying(15) NOT NULL,
    id_enfermero integer NOT NULL,
    fecha_envio date NOT NULL,
    CONSTRAINT ck_documentacion_etapa CHECK (((etapa)::text = ANY ((ARRAY['preoperatorio'::character varying, 'intraoperatorio'::character varying, 'postoperatorio'::character varying])::text[])))
);


ALTER TABLE public.documentacion_etapa OWNER TO admin;

--
-- Name: TABLE documentacion_etapa; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.documentacion_etapa IS 'Documentación de cada etapa de la cirugía enviada a secretaría.';


--
-- Name: COLUMN documentacion_etapa.etapa; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.documentacion_etapa.etapa IS 'Etapa documentada.';


--
-- Name: COLUMN documentacion_etapa.fecha_envio; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.documentacion_etapa.fecha_envio IS 'Fecha de envío a secretaría.';


--
-- Name: egreso; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.egreso OWNER TO admin;

--
-- Name: TABLE egreso; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.egreso IS 'Ficha de egreso que cierra un ingreso.';


--
-- Name: COLUMN egreso.fecha_hora_egreso; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.egreso.fecha_hora_egreso IS 'Fecha y hora del egreso.';


--
-- Name: COLUMN egreso.motivo_egreso; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.egreso.motivo_egreso IS 'Motivo del egreso.';


--
-- Name: COLUMN egreso.codigo_egreso; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.egreso.codigo_egreso IS 'Condición de salida: vivo, muerto, embarazo o parto.';


--
-- Name: COLUMN egreso.sin_consentimiento; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.egreso.sin_consentimiento IS 'Indica si el paciente salió sin consentimiento médico.';


--
-- Name: COLUMN egreso.motivo_sin_consentimiento; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.egreso.motivo_sin_consentimiento IS 'Motivo del egreso sin consentimiento.';


--
-- Name: COLUMN egreso.codigo_traslado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.egreso.codigo_traslado IS 'Código de traslado, si el egreso fue por traslado.';


--
-- Name: COLUMN egreso.referido_otro_hospital; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.egreso.referido_otro_hospital IS 'Indica si fue referido a otro hospital o establecimiento.';


--
-- Name: egreso_diagnostico; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.egreso_diagnostico (
    id_egreso integer NOT NULL,
    id_diagnostico integer NOT NULL
);


ALTER TABLE public.egreso_diagnostico OWNER TO admin;

--
-- Name: TABLE egreso_diagnostico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.egreso_diagnostico IS 'Diagnósticos secundarios de cada egreso.';


--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: encargado; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.encargado OWNER TO admin;

--
-- Name: TABLE encargado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.encargado IS 'Personas responsables de un paciente.';


--
-- Name: COLUMN encargado.nombres; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.encargado.nombres IS 'Nombres del encargado.';


--
-- Name: COLUMN encargado.apellidos; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.encargado.apellidos IS 'Apellidos del encargado.';


--
-- Name: COLUMN encargado.dpi; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.encargado.dpi IS 'CUI de 13 dígitos.';


--
-- Name: COLUMN encargado.telefono; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.encargado.telefono IS 'Teléfono de contacto.';


--
-- Name: COLUMN encargado.area; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.encargado.area IS 'Área de residencia: Urbana o Rural.';


--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: enfermero; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.enfermero (
    id_enfermero integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character(13) NOT NULL,
    telefono character varying(9),
    id_hospital integer NOT NULL,
    tipo character varying(12) NOT NULL,
    tipo_personal character varying(9) DEFAULT 'enfermero'::character varying NOT NULL,
    CONSTRAINT ck_enfermero_dpi CHECK ((dpi ~ '^[0-9]{13}$'::text)),
    CONSTRAINT ck_enfermero_telefono CHECK (((telefono)::text ~ '^[0-9]{4}-?[0-9]{4}$'::text)),
    CONSTRAINT ck_enfermero_tipo CHECK (((tipo)::text = ANY ((ARRAY['registrado'::character varying, 'practicante'::character varying])::text[]))),
    CONSTRAINT ck_enfermero_tipo_personal CHECK (((tipo_personal)::text = 'enfermero'::text))
);


ALTER TABLE public.enfermero OWNER TO admin;

--
-- Name: TABLE enfermero; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.enfermero IS 'Subtipo de personal: enfermeros registrados y practicantes de enfermería.';


--
-- Name: COLUMN enfermero.id_enfermero; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.enfermero.id_enfermero IS 'Identificador del enfermero; es el mismo id_personal de su supertipo.';


--
-- Name: COLUMN enfermero.nombres; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.enfermero.nombres IS 'Copia sincronizada de personal.nombres (la mantiene un disparador).';


--
-- Name: COLUMN enfermero.apellidos; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.enfermero.apellidos IS 'Copia sincronizada de personal.apellidos.';


--
-- Name: COLUMN enfermero.dpi; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.enfermero.dpi IS 'Copia sincronizada de personal.dpi.';


--
-- Name: COLUMN enfermero.telefono; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.enfermero.telefono IS 'Copia sincronizada de personal.telefono.';


--
-- Name: COLUMN enfermero.id_hospital; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.enfermero.id_hospital IS 'Copia sincronizada de personal.id_hospital.';


--
-- Name: COLUMN enfermero.tipo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.enfermero.tipo IS 'registrado o practicante.';


--
-- Name: COLUMN enfermero.tipo_personal; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.enfermero.tipo_personal IS 'Discriminador fijo en enfermero; junto con id_enfermero forma la FK hacia personal.';


--
-- Name: equipo; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.equipo OWNER TO admin;

--
-- Name: TABLE equipo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.equipo IS 'Equipos médicos y quirúrgicos.';


--
-- Name: COLUMN equipo.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.equipo.nombre IS 'Nombre del equipo.';


--
-- Name: COLUMN equipo.descripcion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.equipo.descripcion IS 'Descripción del equipo.';


--
-- Name: COLUMN equipo.tipo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.equipo.tipo IS 'medico, quirurgico u otro.';


--
-- Name: COLUMN equipo.funcion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.equipo.funcion IS 'exploracion, diagnostico, tratamiento, rehabilitacion u otro.';


--
-- Name: COLUMN equipo.estado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.equipo.estado IS 'disponible, en_uso o en_mantenimiento.';


--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: especialidad; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.especialidad (
    id_especialidad integer NOT NULL,
    nombre character varying(80) NOT NULL,
    tipo character varying(10) NOT NULL,
    CONSTRAINT ck_especialidad_tipo CHECK (((tipo)::text = ANY ((ARRAY['clinica'::character varying, 'quirurgica'::character varying])::text[])))
);


ALTER TABLE public.especialidad OWNER TO admin;

--
-- Name: TABLE especialidad; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.especialidad IS 'Especialidades médicas clínicas y quirúrgicas.';


--
-- Name: COLUMN especialidad.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.especialidad.nombre IS 'Nombre de la especialidad.';


--
-- Name: COLUMN especialidad.tipo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.especialidad.tipo IS 'clinica (consulta) o quirurgica (cirugía).';


--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: estado_civil; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.estado_civil (
    id_estado_civil integer NOT NULL,
    nombre character varying(20) NOT NULL
);


ALTER TABLE public.estado_civil OWNER TO admin;

--
-- Name: TABLE estado_civil; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.estado_civil IS 'Catálogo de estados civiles.';


--
-- Name: COLUMN estado_civil.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.estado_civil.nombre IS 'Estado civil.';


--
-- Name: estado_civil_id_estado_civil_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: factura; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.factura OWNER TO admin;

--
-- Name: TABLE factura; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.factura IS 'Factura emitida al terminar una consulta, emergencia, hospitalización o cirugía.';


--
-- Name: COLUMN factura.fecha_emision; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.factura.fecha_emision IS 'Fecha y hora de emisión.';


--
-- Name: COLUMN factura.descripcion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.factura.descripcion IS 'Descripción breve de los servicios facturados.';


--
-- Name: COLUMN factura.total; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.factura.total IS 'Monto total en quetzales.';


--
-- Name: COLUMN factura.numero_cuotas; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.factura.numero_cuotas IS 'Número de cuotas mensuales del plan de pago (1 a 12).';


--
-- Name: factura_id_factura_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: historia_clinica; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.historia_clinica OWNER TO admin;

--
-- Name: TABLE historia_clinica; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.historia_clinica IS 'Interrogatorio y exploración física del paciente antes de la cirugía.';


--
-- Name: COLUMN historia_clinica.fecha; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.fecha IS 'Fecha de elaboración.';


--
-- Name: COLUMN historia_clinica.fuente_interrogatorio; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.fuente_interrogatorio IS 'directo (del paciente) o indirecto (de un familiar o amigo).';


--
-- Name: COLUMN historia_clinica.religion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.religion IS 'Religión del paciente.';


--
-- Name: COLUMN historia_clinica.ocupacion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.ocupacion IS 'Ocupación del paciente.';


--
-- Name: COLUMN historia_clinica.lugar_nacimiento; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.lugar_nacimiento IS 'Lugar de nacimiento.';


--
-- Name: COLUMN historia_clinica.lugar_residencia; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.lugar_residencia IS 'Lugar de residencia.';


--
-- Name: COLUMN historia_clinica.antecedentes_heredofamiliares; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.antecedentes_heredofamiliares IS 'Antecedentes heredofamiliares.';


--
-- Name: COLUMN historia_clinica.antecedentes_personales_no_patologicos; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.antecedentes_personales_no_patologicos IS 'Antecedentes personales no patológicos.';


--
-- Name: COLUMN historia_clinica.antecedentes_patologicos; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.antecedentes_patologicos IS 'Antecedentes patológicos.';


--
-- Name: COLUMN historia_clinica.padecimiento_actual; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.padecimiento_actual IS 'Padecimiento actual.';


--
-- Name: COLUMN historia_clinica.interrogatorio_aparatos_sistemas; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.interrogatorio_aparatos_sistemas IS 'Interrogatorio por aparatos y sistemas.';


--
-- Name: COLUMN historia_clinica.sintomas_generales_terapeutica; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.sintomas_generales_terapeutica IS 'Síntomas generales y terapéutica empleada.';


--
-- Name: COLUMN historia_clinica.estudios_previos; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.estudios_previos IS 'Estudios previos.';


--
-- Name: COLUMN historia_clinica.signos_vitales; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.signos_vitales IS 'Signos vitales.';


--
-- Name: COLUMN historia_clinica.exploracion_general; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.exploracion_general IS 'Exploración general.';


--
-- Name: COLUMN historia_clinica.exploracion_sistematizada; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.historia_clinica.exploracion_sistematizada IS 'Exploración de cabeza, cuello, tórax, abdomen, extremidades, columna y cavidades.';


--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: hospital; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.hospital (
    id_hospital integer NOT NULL,
    nombre character varying(120) NOT NULL,
    informacion_especifica text,
    direccion character varying(250) NOT NULL,
    id_municipio integer NOT NULL
);


ALTER TABLE public.hospital OWNER TO admin;

--
-- Name: TABLE hospital; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.hospital IS 'Hospitales de la cadena Hospitales de Occidente.';


--
-- Name: COLUMN hospital.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.hospital.nombre IS 'Nombre del hospital.';


--
-- Name: COLUMN hospital.informacion_especifica; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.hospital.informacion_especifica IS 'Información específica del hospital (nivel, capacidad, especialización).';


--
-- Name: COLUMN hospital.direccion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.hospital.direccion IS 'Dirección del hospital.';


--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: hospitalizacion_insumo; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.hospitalizacion_insumo (
    id_ingreso integer NOT NULL,
    id_insumo integer NOT NULL,
    cantidad smallint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL,
    CONSTRAINT ck_hosp_insumo_cantidad CHECK ((cantidad > 0)),
    CONSTRAINT ck_hosp_insumo_costo CHECK ((costo_unitario >= (0)::numeric))
);


ALTER TABLE public.hospitalizacion_insumo OWNER TO admin;

--
-- Name: TABLE hospitalizacion_insumo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.hospitalizacion_insumo IS 'Insumos usados durante un internamiento.';


--
-- Name: COLUMN hospitalizacion_insumo.cantidad; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.hospitalizacion_insumo.cantidad IS 'Cantidad usada durante el internamiento.';


--
-- Name: COLUMN hospitalizacion_insumo.costo_unitario; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.hospitalizacion_insumo.costo_unitario IS 'Costo por unidad al momento de usarlo.';


--
-- Name: ingreso; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.ingreso OWNER TO admin;

--
-- Name: TABLE ingreso; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.ingreso IS 'Ficha de ingreso a Emergencias, Cirugía u Hospitalización.';


--
-- Name: COLUMN ingreso.fecha_hora_ingreso; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.ingreso.fecha_hora_ingreso IS 'Fecha y hora del ingreso.';


--
-- Name: COLUMN ingreso.motivo_ingreso; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.ingreso.motivo_ingreso IS 'Motivo por el que ingresa el paciente.';


--
-- Name: COLUMN ingreso.diagnostico_presuntivo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.ingreso.diagnostico_presuntivo IS 'Diagnóstico presuntivo de ingreso.';


--
-- Name: COLUMN ingreso.prioridad_triage; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.ingreso.prioridad_triage IS 'Prioridad de atención en emergencias: 1 la más urgente, 5 la menos.';


--
-- Name: COLUMN ingreso.turnos_espera; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.ingreso.turnos_espera IS 'Turnos que esperó por falta de camilla libre (solo emergencias).';


--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: institucion_externa; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.institucion_externa (
    id_institucion integer NOT NULL,
    nombre character varying(120) NOT NULL,
    direccion character varying(250) NOT NULL,
    id_municipio integer NOT NULL
);


ALTER TABLE public.institucion_externa OWNER TO admin;

--
-- Name: TABLE institucion_externa; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.institucion_externa IS 'Hospitales y establecimientos fuera de la cadena que reciben traslados.';


--
-- Name: COLUMN institucion_externa.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.institucion_externa.nombre IS 'Nombre de la institución.';


--
-- Name: COLUMN institucion_externa.direccion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.institucion_externa.direccion IS 'Dirección de la institución.';


--
-- Name: institucion_externa_id_institucion_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: instrumento; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.instrumento OWNER TO admin;

--
-- Name: TABLE instrumento; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.instrumento IS 'Instrumental médico y quirúrgico.';


--
-- Name: COLUMN instrumento.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.instrumento.nombre IS 'Nombre del instrumento.';


--
-- Name: COLUMN instrumento.descripcion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.instrumento.descripcion IS 'Descripción del instrumento.';


--
-- Name: COLUMN instrumento.tipo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.instrumento.tipo IS 'medico, quirurgico u otro.';


--
-- Name: COLUMN instrumento.funcion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.instrumento.funcion IS 'corte, contencion, hemostatica, retractor, accesorio, implante u otro.';


--
-- Name: COLUMN instrumento.estado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.instrumento.estado IS 'disponible, en_uso o en_mantenimiento.';


--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: insumo; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.insumo OWNER TO admin;

--
-- Name: TABLE insumo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.insumo IS 'Insumos médicos y quirúrgicos con su inventario.';


--
-- Name: COLUMN insumo.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.insumo.nombre IS 'Nombre del insumo.';


--
-- Name: COLUMN insumo.descripcion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.insumo.descripcion IS 'Descripción del insumo.';


--
-- Name: COLUMN insumo.material; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.insumo.material IS 'Material del que está hecho.';


--
-- Name: COLUMN insumo.tipo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.insumo.tipo IS 'medico, quirurgico u otro.';


--
-- Name: COLUMN insumo.unidad_medida; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.insumo.unidad_medida IS 'Unidad en que se despacha (caja, unidad, bolsa...).';


--
-- Name: COLUMN insumo.costo_unitario; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.insumo.costo_unitario IS 'Costo actual por unidad.';


--
-- Name: COLUMN insumo.stock_minimo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.insumo.stock_minimo IS 'Existencia mínima antes de reabastecer.';


--
-- Name: COLUMN insumo.stock_actual; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.insumo.stock_actual IS 'Existencia actual en inventario.';


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: medicamento; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.medicamento (
    id_medicamento integer NOT NULL,
    nombre_generico character varying(80) NOT NULL,
    concentracion character varying(30) NOT NULL,
    forma_farmaceutica character varying(12) NOT NULL,
    CONSTRAINT ck_medicamento_forma CHECK (((forma_farmaceutica)::text = ANY ((ARRAY['tableta'::character varying, 'capsula'::character varying, 'jarabe'::character varying, 'suspension'::character varying, 'inyectable'::character varying, 'crema'::character varying, 'gotas'::character varying, 'inhalador'::character varying])::text[])))
);


ALTER TABLE public.medicamento OWNER TO admin;

--
-- Name: TABLE medicamento; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.medicamento IS 'Medicamentos que se pueden recetar.';


--
-- Name: COLUMN medicamento.nombre_generico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medicamento.nombre_generico IS 'Nombre genérico (principio activo).';


--
-- Name: COLUMN medicamento.concentracion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medicamento.concentracion IS 'Concentración por unidad (ej. 50 mg).';


--
-- Name: COLUMN medicamento.forma_farmaceutica; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medicamento.forma_farmaceutica IS 'Presentación: tableta, cápsula, jarabe, inyectable...';


--
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: medico; Type: TABLE; Schema: public; Owner: admin
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
    tipo_personal character varying(9) DEFAULT 'medico'::character varying NOT NULL,
    cargo character varying(15) DEFAULT 'medico'::character varying NOT NULL,
    id_medico_superior integer,
    CONSTRAINT ck_medico_area CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[]))),
    CONSTRAINT ck_medico_cargo CHECK (((cargo)::text = ANY ((ARRAY['director_medico'::character varying, 'jefe_servicio'::character varying, 'medico'::character varying])::text[]))),
    CONSTRAINT ck_medico_costo CHECK ((costo_primera_consulta >= (0)::numeric)),
    CONSTRAINT ck_medico_director_sin_superior CHECK ((((cargo)::text <> 'director_medico'::text) OR (id_medico_superior IS NULL))),
    CONSTRAINT ck_medico_dpi CHECK ((dpi ~ '^[0-9]{13}$'::text)),
    CONSTRAINT ck_medico_externo CHECK ((((tipo_medico)::text <> 'externo'::text) OR ((horario_inicio IS NULL) AND (costo_primera_consulta IS NULL)))),
    CONSTRAINT ck_medico_horario CHECK (((horario_inicio < horario_fin) AND (horario_fin <= '13:00:00'::time without time zone))),
    CONSTRAINT ck_medico_horario_completo CHECK (((horario_inicio IS NULL) = (horario_fin IS NULL))),
    CONSTRAINT ck_medico_superior_propio CHECK ((id_medico_superior <> id_medico)),
    CONSTRAINT ck_medico_telefono CHECK (((telefono)::text ~ '^[0-9]{4}-?[0-9]{4}$'::text)),
    CONSTRAINT ck_medico_tipo CHECK (((tipo_medico)::text = ANY ((ARRAY['general'::character varying, 'especialista'::character varying, 'residente'::character varying, 'interno'::character varying, 'externo'::character varying])::text[]))),
    CONSTRAINT ck_medico_tipo_personal CHECK (((tipo_personal)::text = 'medico'::text))
);


ALTER TABLE public.medico OWNER TO admin;

--
-- Name: TABLE medico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.medico IS 'Subtipo de personal: médicos de la cadena (los externos no están contratados, solo operan).';


--
-- Name: COLUMN medico.id_medico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.id_medico IS 'Identificador del médico; es el mismo id_personal de su supertipo.';


--
-- Name: COLUMN medico.nombres; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.nombres IS 'Copia sincronizada de personal.nombres (la mantiene un disparador).';


--
-- Name: COLUMN medico.apellidos; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.apellidos IS 'Copia sincronizada de personal.apellidos.';


--
-- Name: COLUMN medico.dpi; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.dpi IS 'Copia sincronizada de personal.dpi.';


--
-- Name: COLUMN medico.telefono; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.telefono IS 'Copia sincronizada de personal.telefono.';


--
-- Name: COLUMN medico.id_hospital; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.id_hospital IS 'Copia sincronizada de personal.id_hospital.';


--
-- Name: COLUMN medico.id_municipio; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.id_municipio IS 'Copia sincronizada de personal.id_municipio.';


--
-- Name: COLUMN medico.area; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.area IS 'Copia sincronizada de personal.area.';


--
-- Name: COLUMN medico.id_especialidad; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.id_especialidad IS 'Especialidad del médico. Se audita cada cambio.';


--
-- Name: COLUMN medico.tipo_medico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.tipo_medico IS 'Modalidad: general, especialista, residente, interno o externo.';


--
-- Name: COLUMN medico.costo_primera_consulta; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.costo_primera_consulta IS 'Costo de la primera consulta; base para reconsultas y referidos.';


--
-- Name: COLUMN medico.horario_inicio; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.horario_inicio IS 'Inicio del horario de consulta externa (turno matutino).';


--
-- Name: COLUMN medico.horario_fin; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.horario_fin IS 'Fin del horario de consulta externa.';


--
-- Name: COLUMN medico.tipo_personal; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.tipo_personal IS 'Discriminador fijo en medico; junto con id_medico forma la FK hacia personal.';


--
-- Name: COLUMN medico.cargo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.cargo IS 'Cargo en la cadena de mando: director_medico, jefe_servicio o medico.';


--
-- Name: COLUMN medico.id_medico_superior; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.medico.id_medico_superior IS 'Superior directo dentro del mismo hospital (relación recursiva); nulo para el director.';


--
-- Name: metodo_pago; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.metodo_pago (
    id_metodo_pago integer NOT NULL,
    nombre character varying(30) NOT NULL
);


ALTER TABLE public.metodo_pago OWNER TO admin;

--
-- Name: TABLE metodo_pago; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.metodo_pago IS 'Métodos de pago aceptados.';


--
-- Name: COLUMN metodo_pago.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.metodo_pago.nombre IS 'Método de pago.';


--
-- Name: metodo_pago_id_metodo_pago_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: municipio; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.municipio (
    id_municipio integer NOT NULL,
    id_departamento integer NOT NULL,
    nombre character varying(80) NOT NULL
);


ALTER TABLE public.municipio OWNER TO admin;

--
-- Name: TABLE municipio; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.municipio IS 'Municipios de cada departamento.';


--
-- Name: COLUMN municipio.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.municipio.nombre IS 'Nombre del municipio.';


--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: paciente; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.paciente OWNER TO admin;

--
-- Name: TABLE paciente; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.paciente IS 'Pacientes atendidos en la red.';


--
-- Name: COLUMN paciente.numero_expediente; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.paciente.numero_expediente IS 'Número de expediente clínico del paciente.';


--
-- Name: COLUMN paciente.nombres; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.paciente.nombres IS 'Nombres del paciente.';


--
-- Name: COLUMN paciente.apellidos; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.paciente.apellidos IS 'Apellidos del paciente.';


--
-- Name: COLUMN paciente.fecha_nacimiento; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.paciente.fecha_nacimiento IS 'Fecha de nacimiento; la edad se calcula con fn_edad.';


--
-- Name: COLUMN paciente.sexo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.paciente.sexo IS 'Masculino o Femenino.';


--
-- Name: COLUMN paciente.dpi; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.paciente.dpi IS 'CUI de 13 dígitos; opcional para menores de edad.';


--
-- Name: COLUMN paciente.telefono; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.paciente.telefono IS 'Teléfono de contacto.';


--
-- Name: COLUMN paciente.area; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.paciente.area IS 'Área de residencia: Urbana o Rural.';


--
-- Name: COLUMN paciente.numero_seguro_social; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.paciente.numero_seguro_social IS 'Número de afiliación al seguro social, si tiene.';


--
-- Name: paciente_encargado; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.paciente_encargado (
    id_paciente integer NOT NULL,
    id_encargado integer NOT NULL,
    id_parentesco integer NOT NULL
);


ALTER TABLE public.paciente_encargado OWNER TO admin;

--
-- Name: TABLE paciente_encargado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.paciente_encargado IS 'Encargados de cada paciente y su parentesco.';


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: pago; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.pago OWNER TO admin;

--
-- Name: TABLE pago; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.pago IS 'Pago de una cuota de la factura.';


--
-- Name: COLUMN pago.numero_cuota; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.pago.numero_cuota IS 'Número de cuota que se paga.';


--
-- Name: COLUMN pago.monto; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.pago.monto IS 'Monto pagado.';


--
-- Name: COLUMN pago.fecha_pago; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.pago.fecha_pago IS 'Fecha del pago.';


--
-- Name: pago_id_pago_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: parentesco; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.parentesco (
    id_parentesco integer NOT NULL,
    nombre character varying(20) NOT NULL
);


ALTER TABLE public.parentesco OWNER TO admin;

--
-- Name: TABLE parentesco; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.parentesco IS 'Catálogo de parentescos entre paciente y encargado.';


--
-- Name: COLUMN parentesco.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.parentesco.nombre IS 'Parentesco o relación con el paciente.';


--
-- Name: parentesco_id_parentesco_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: personal; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.personal (
    id_personal integer NOT NULL,
    tipo_personal character varying(9) NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character(13) NOT NULL,
    telefono character varying(9),
    direccion character varying(250) NOT NULL,
    id_municipio integer NOT NULL,
    area character varying(6) NOT NULL,
    id_hospital integer NOT NULL,
    fecha_contratacion date,
    salario numeric(10,2),
    nivel_acceso character varying(13) DEFAULT 'consulta'::character varying NOT NULL,
    CONSTRAINT ck_personal_area CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[]))),
    CONSTRAINT ck_personal_contratacion CHECK ((fecha_contratacion >= '1970-01-01'::date)),
    CONSTRAINT ck_personal_contratado CHECK (((fecha_contratacion IS NULL) = (salario IS NULL))),
    CONSTRAINT ck_personal_dpi CHECK ((dpi ~ '^[0-9]{13}$'::text)),
    CONSTRAINT ck_personal_nivel_acceso CHECK (((nivel_acceso)::text = ANY ((ARRAY['consulta'::character varying, 'operativo'::character varying, 'supervisor'::character varying, 'administrador'::character varying])::text[]))),
    CONSTRAINT ck_personal_salario CHECK ((salario >= (0)::numeric)),
    CONSTRAINT ck_personal_telefono CHECK (((telefono)::text ~ '^[0-9]{4}-?[0-9]{4}$'::text)),
    CONSTRAINT ck_personal_tipo CHECK (((tipo_personal)::text = ANY ((ARRAY['medico'::character varying, 'enfermero'::character varying])::text[])))
);


ALTER TABLE public.personal OWNER TO admin;

--
-- Name: TABLE personal; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.personal IS 'Supertipo con los datos comunes de todo el personal del hospital; sus subtipos son medico y enfermero.';


--
-- Name: COLUMN personal.id_personal; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.id_personal IS 'Identificador de la persona; es también la llave de su subtipo.';


--
-- Name: COLUMN personal.tipo_personal; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.tipo_personal IS 'Discriminador: indica si la persona es medico o enfermero.';


--
-- Name: COLUMN personal.nombres; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.nombres IS 'Nombres de la persona.';


--
-- Name: COLUMN personal.apellidos; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.apellidos IS 'Apellidos de la persona.';


--
-- Name: COLUMN personal.dpi; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.dpi IS 'Documento Personal de Identificación (CUI de 13 dígitos).';


--
-- Name: COLUMN personal.telefono; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.telefono IS 'Teléfono de contacto.';


--
-- Name: COLUMN personal.direccion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.direccion IS 'Dirección de residencia.';


--
-- Name: COLUMN personal.id_municipio; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.id_municipio IS 'Municipio de residencia.';


--
-- Name: COLUMN personal.area; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.area IS 'Área de residencia: Urbana o Rural.';


--
-- Name: COLUMN personal.id_hospital; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.id_hospital IS 'Hospital donde trabaja.';


--
-- Name: COLUMN personal.fecha_contratacion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.fecha_contratacion IS 'Fecha de contratación; nula para los médicos externos, que no están contratados.';


--
-- Name: COLUMN personal.salario; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.salario IS 'Salario mensual en quetzales; nulo si no está contratado. Se audita cada cambio.';


--
-- Name: COLUMN personal.nivel_acceso; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.personal.nivel_acceso IS 'Nivel de acceso al sistema: consulta, operativo, supervisor o administrador. Se audita cada cambio.';


--
-- Name: personal_id_personal_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

ALTER TABLE public.personal ALTER COLUMN id_personal ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.personal_id_personal_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: quirofano; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.quirofano (
    id_quirofano integer NOT NULL,
    id_unidad integer NOT NULL,
    numero smallint NOT NULL,
    estado character varying(16) DEFAULT 'disponible'::character varying NOT NULL,
    CONSTRAINT ck_quirofano_estado CHECK (((estado)::text = ANY ((ARRAY['disponible'::character varying, 'ocupado'::character varying, 'en_mantenimiento'::character varying])::text[]))),
    CONSTRAINT ck_quirofano_numero CHECK ((numero > 0))
);


ALTER TABLE public.quirofano OWNER TO admin;

--
-- Name: TABLE quirofano; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.quirofano IS 'Quirófanos de la unidad de Cirugía.';


--
-- Name: COLUMN quirofano.numero; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.quirofano.numero IS 'Número del quirófano dentro de la unidad de cirugía.';


--
-- Name: COLUMN quirofano.estado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.quirofano.estado IS 'Estado: disponible, ocupado o en_mantenimiento.';


--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: receta; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.receta (
    id_receta integer NOT NULL,
    id_consulta integer NOT NULL,
    fecha_proxima_cita date
);


ALTER TABLE public.receta OWNER TO admin;

--
-- Name: TABLE receta; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.receta IS 'Receta entregada al final de la consulta.';


--
-- Name: COLUMN receta.fecha_proxima_cita; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.receta.fecha_proxima_cita IS 'Fecha sugerida para la próxima cita de seguimiento.';


--
-- Name: receta_id_receta_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: receta_medicamento; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.receta_medicamento (
    id_receta integer NOT NULL,
    id_medicamento integer NOT NULL,
    dosis character varying(80) NOT NULL,
    duracion character varying(40) NOT NULL
);


ALTER TABLE public.receta_medicamento OWNER TO admin;

--
-- Name: TABLE receta_medicamento; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.receta_medicamento IS 'Medicamentos prescritos en cada receta.';


--
-- Name: COLUMN receta_medicamento.dosis; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.receta_medicamento.dosis IS 'Dosis indicada.';


--
-- Name: COLUMN receta_medicamento.duracion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.receta_medicamento.duracion IS 'Duración del tratamiento.';


--
-- Name: registro_procedimiento; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.registro_procedimiento OWNER TO admin;

--
-- Name: TABLE registro_procedimiento; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.registro_procedimiento IS 'Resultado de cada aspecto verificado durante la cirugía.';


--
-- Name: COLUMN registro_procedimiento.resultado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.registro_procedimiento.resultado IS 'exito/falla, o aceptable/medianamente_aceptable/no_aceptable.';


--
-- Name: COLUMN registro_procedimiento.descripcion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.registro_procedimiento.descripcion IS 'Descripción de lo observado.';


--
-- Name: COLUMN registro_procedimiento.fecha_hora_registro; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.registro_procedimiento.fecha_hora_registro IS 'Hora en que se registró.';


--
-- Name: registro_procedimiento_id_registro_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: requerimiento_equipo; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.requerimiento_equipo (
    id_agendamiento integer NOT NULL,
    id_equipo integer NOT NULL,
    cantidad smallint NOT NULL,
    CONSTRAINT ck_req_equipo_cantidad CHECK ((cantidad > 0))
);


ALTER TABLE public.requerimiento_equipo OWNER TO admin;

--
-- Name: TABLE requerimiento_equipo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.requerimiento_equipo IS 'Equipos que solicita el cirujano en el agendamiento.';


--
-- Name: COLUMN requerimiento_equipo.cantidad; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.requerimiento_equipo.cantidad IS 'Cantidad solicitada.';


--
-- Name: requerimiento_instrumento; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.requerimiento_instrumento (
    id_agendamiento integer NOT NULL,
    id_instrumento integer NOT NULL,
    cantidad smallint NOT NULL,
    CONSTRAINT ck_req_instrumento_cantidad CHECK ((cantidad > 0))
);


ALTER TABLE public.requerimiento_instrumento OWNER TO admin;

--
-- Name: TABLE requerimiento_instrumento; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.requerimiento_instrumento IS 'Instrumental que solicita el cirujano en el agendamiento.';


--
-- Name: COLUMN requerimiento_instrumento.cantidad; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.requerimiento_instrumento.cantidad IS 'Cantidad solicitada.';


--
-- Name: requerimiento_insumo; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.requerimiento_insumo (
    id_agendamiento integer NOT NULL,
    id_insumo integer NOT NULL,
    cantidad smallint NOT NULL,
    CONSTRAINT ck_req_insumo_cantidad CHECK ((cantidad > 0))
);


ALTER TABLE public.requerimiento_insumo OWNER TO admin;

--
-- Name: TABLE requerimiento_insumo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.requerimiento_insumo IS 'Insumos que solicita el cirujano en el agendamiento.';


--
-- Name: COLUMN requerimiento_insumo.cantidad; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.requerimiento_insumo.cantidad IS 'Cantidad solicitada.';


--
-- Name: rol_quirurgico; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.rol_quirurgico (
    id_rol integer NOT NULL,
    nombre character varying(40) NOT NULL,
    tipo_personal character varying(9) NOT NULL,
    CONSTRAINT ck_rol_tipo_personal CHECK (((tipo_personal)::text = ANY ((ARRAY['medico'::character varying, 'enfermero'::character varying])::text[])))
);


ALTER TABLE public.rol_quirurgico OWNER TO admin;

--
-- Name: TABLE rol_quirurgico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.rol_quirurgico IS 'Rol que cumple cada persona del equipo quirúrgico.';


--
-- Name: COLUMN rol_quirurgico.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.rol_quirurgico.nombre IS 'Nombre del rol.';


--
-- Name: COLUMN rol_quirurgico.tipo_personal; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.rol_quirurgico.tipo_personal IS 'Quién cumple el rol: medico o enfermero.';


--
-- Name: rol_quirurgico_id_rol_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: servicio_atencion; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.servicio_atencion (
    id_servicio integer NOT NULL,
    id_unidad integer NOT NULL,
    nombre character varying(80) NOT NULL,
    costo numeric(10,2) NOT NULL,
    CONSTRAINT ck_servicio_costo CHECK ((costo >= (0)::numeric))
);


ALTER TABLE public.servicio_atencion OWNER TO admin;

--
-- Name: TABLE servicio_atencion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.servicio_atencion IS 'Tipo de atención médica que ofrece cada unidad, con su costo.';


--
-- Name: COLUMN servicio_atencion.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.servicio_atencion.nombre IS 'Nombre del servicio de atención.';


--
-- Name: COLUMN servicio_atencion.costo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.servicio_atencion.costo IS 'Costo del servicio en quetzales.';


--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: tipo_anestesia; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tipo_anestesia (
    id_tipo_anestesia integer NOT NULL,
    nombre character varying(40) NOT NULL
);


ALTER TABLE public.tipo_anestesia OWNER TO admin;

--
-- Name: TABLE tipo_anestesia; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.tipo_anestesia IS 'Catálogo de tipos de anestesia.';


--
-- Name: COLUMN tipo_anestesia.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.tipo_anestesia.nombre IS 'Tipo de anestesia.';


--
-- Name: tipo_anestesia_id_tipo_anestesia_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: tipo_cirugia; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tipo_cirugia (
    id_tipo_cirugia integer NOT NULL,
    nombre character varying(120) NOT NULL,
    id_especialidad integer NOT NULL
);


ALTER TABLE public.tipo_cirugia OWNER TO admin;

--
-- Name: TABLE tipo_cirugia; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.tipo_cirugia IS 'Procedimientos quirúrgicos que ofrece la red.';


--
-- Name: COLUMN tipo_cirugia.nombre; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.tipo_cirugia.nombre IS 'Nombre del procedimiento quirúrgico.';


--
-- Name: tipo_cirugia_id_tipo_cirugia_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: traslado; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.traslado OWNER TO admin;

--
-- Name: TABLE traslado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.traslado IS 'Ficha de traslado de un paciente entre unidades o hacia fuera de la red.';


--
-- Name: COLUMN traslado.fecha_hora; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.traslado.fecha_hora IS 'Fecha y hora del traslado.';


--
-- Name: COLUMN traslado.tipo_traslado; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.traslado.tipo_traslado IS 'interno (dentro de la red) o externo (fuera de la red).';


--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: turno_emergencia; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.turno_emergencia (
    id_turno integer NOT NULL,
    id_unidad integer NOT NULL,
    fecha date NOT NULL,
    jornada character varying(8) NOT NULL,
    CONSTRAINT ck_turno_jornada CHECK (((jornada)::text = ANY ((ARRAY['diurno'::character varying, 'nocturno'::character varying])::text[])))
);


ALTER TABLE public.turno_emergencia OWNER TO admin;

--
-- Name: TABLE turno_emergencia; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.turno_emergencia IS 'Turnos de 12 horas de la unidad de Emergencias.';


--
-- Name: COLUMN turno_emergencia.fecha; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.turno_emergencia.fecha IS 'Fecha en que inicia el turno.';


--
-- Name: COLUMN turno_emergencia.jornada; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.turno_emergencia.jornada IS 'diurno (07:00-19:00) o nocturno (19:00-07:00).';


--
-- Name: turno_emergencia_id_turno_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: turno_medico; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.turno_medico (
    id_turno integer NOT NULL,
    id_medico integer NOT NULL
);


ALTER TABLE public.turno_medico OWNER TO admin;

--
-- Name: TABLE turno_medico; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.turno_medico IS 'Médicos asignados a cada turno de emergencia.';


--
-- Name: unidad_medica; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.unidad_medica OWNER TO admin;

--
-- Name: TABLE unidad_medica; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.unidad_medica IS 'Unidades de atención de cada hospital: Consulta Externa, Emergencias, Cirugía y Hospitalización.';


--
-- Name: COLUMN unidad_medica.tipo_unidad; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.unidad_medica.tipo_unidad IS 'Tipo de unidad: Consulta Externa, Emergencias, Cirugía u Hospitalización.';


--
-- Name: COLUMN unidad_medica.costo_dia_hospitalizacion; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.unidad_medica.costo_dia_hospitalizacion IS 'Costo por día internado; solo aplica a Hospitalización.';


--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE; Schema: public; Owner: admin
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
-- Name: v_cirugia; Type: VIEW; Schema: public; Owner: admin
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


ALTER VIEW public.v_cirugia OWNER TO admin;

--
-- Name: v_consulta; Type: VIEW; Schema: public; Owner: admin
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


ALTER VIEW public.v_consulta OWNER TO admin;

--
-- Name: v_estancia; Type: VIEW; Schema: public; Owner: admin
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


ALTER VIEW public.v_estancia OWNER TO admin;

--
-- Name: v_factura; Type: VIEW; Schema: public; Owner: admin
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


ALTER VIEW public.v_factura OWNER TO admin;

--
-- Name: v_paciente; Type: VIEW; Schema: public; Owner: admin
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


ALTER VIEW public.v_paciente OWNER TO admin;

--
-- Data for Name: cirugia; Type: TABLE DATA; Schema: propuesta_bloque_e; Owner: admin
--

COPY propuesta_bloque_e.cirugia (id_cirugia, id_cirujano, id_paciente, codigo_cie10, fecha) FROM stdin;
1	1	1	K35.8	2026-03-02
2	1	2	K40.9	2026-03-09
3	1	3	K35.8	2026-03-15
4	2	4	S72.0	2026-03-20
\.


--
-- Data for Name: cirugia_insumo; Type: TABLE DATA; Schema: propuesta_bloque_e; Owner: admin
--

COPY propuesta_bloque_e.cirugia_insumo (id_cirugia, id_insumo, cantidad) FROM stdin;
4	3	1
3	4	2
2	4	3
1	4	4
3	1	1
1	2	2
4	4	6
\.


--
-- Data for Name: cirujano; Type: TABLE DATA; Schema: propuesta_bloque_e; Owner: admin
--

COPY propuesta_bloque_e.cirujano (id_cirujano, nombres, apellidos, id_especialidad) FROM stdin;
1	Ana	López	1
2	Luis	Rojas	2
\.


--
-- Data for Name: diagnostico; Type: TABLE DATA; Schema: propuesta_bloque_e; Owner: admin
--

COPY propuesta_bloque_e.diagnostico (codigo_cie10, descripcion) FROM stdin;
S72.0	Fractura del cuello del fémur
K40.9	Hernia inguinal
K35.8	Apendicitis aguda
\.


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: propuesta_bloque_e; Owner: admin
--

COPY propuesta_bloque_e.especialidad (id_especialidad, nombre) FROM stdin;
1	Cirugía General
2	Cirugía Ortopédica
\.


--
-- Data for Name: insumo; Type: TABLE DATA; Schema: propuesta_bloque_e; Owner: admin
--

COPY propuesta_bloque_e.insumo (id_insumo, nombre) FROM stdin;
1	Hoja de bisturí #10
2	Sutura vicryl 3-0
3	Placa de osteosíntesis
4	Gasas estériles
\.


--
-- Data for Name: paciente; Type: TABLE DATA; Schema: propuesta_bloque_e; Owner: admin
--

COPY propuesta_bloque_e.paciente (id_paciente, nombres, apellidos) FROM stdin;
1	Pedro	Gómez
2	Lucía	Paz
3	Mario	Sic
4	Sofía	Tum
\.


--
-- Data for Name: reporte_cirugia; Type: TABLE DATA; Schema: propuesta_bloque_e; Owner: admin
--

COPY propuesta_bloque_e.reporte_cirugia (id_cirugia, nombre_cirujano, especialidad_cirujano, nombre_paciente, codigo_diagnostico, descripcion_diagnostico, nombre_insumo_1, cantidad_insumo_1, nombre_insumo_2, cantidad_insumo_2, fecha) FROM stdin;
1	Ana López	Cirugía General	Pedro Gómez	K35.8	Apendicitis aguda	Gasas estériles	4	Sutura vicryl 3-0	2	2026-03-02
2	Ana López	Cirugía General	Lucía Paz	K40.9	Hernia inguinal	Gasas estériles	3	\N	\N	2026-03-09
3	Ana López	Videolaparoscopia	Mario Sic	K35.8	Apendicitis aguda	Gasas estériles	2	Hoja de bisturí #10	1	2026-03-15
4	Luis Rojas	Cirugía Ortopédica	Sofía Tum	S72.0	Fractura del cuello del fémur	Placa de osteosíntesis	1	Gasas estériles	6	2026-03-20
\.


--
-- Data for Name: agendamiento_quirurgico; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.agendamiento_quirurgico (id_agendamiento, id_paciente, id_medico_cirujano, id_tipo_cirugia, id_tipo_anestesia, caracter, resumen_clinico, tiempo_estimado_min, fecha_hora_solicitud, estado_solicitud, motivo_rechazo, id_quirofano_solicitado, fecha_hora_agendada) FROM stdin;
1	5	1006	1	1	urgente	Apendicitis aguda confirmada por ecografía.	90	2026-08-11 11:00:00-06	aprobada	\N	2	2026-08-11 18:30:00-06
2	7	1009	4	1	programado	Carcinoma colorrectal en estudio.	160	2026-08-13 09:00:00-06	rechazada	El comité recomienda completar estudios de imagen y control nutricional previo a la intervención.	11	\N
3	6	1007	7	1	programado	Enfermedad valvular aórtica con estenosis severa.	180	2026-09-08 10:00:00-06	pendiente	\N	\N	\N
101	18	1020	11	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	73	2026-01-18 08:00:00-06	aprobada	\N	2	2026-01-20 15:00:00-06
102	35	1021	2	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	86	2026-01-24 08:00:00-06	aprobada	\N	7	2026-01-27 15:00:00-06
103	52	1028	15	2	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	99	2026-01-30 08:00:00-06	aprobada	\N	12	2026-02-03 15:00:00-06
104	2	1009	4	3	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	112	2026-02-05 08:00:00-06	aprobada	\N	9	2026-02-06 15:00:00-06
105	19	1023	12	4	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	125	2026-02-11 08:00:00-06	aprobada	\N	2	2026-02-13 15:00:00-06
106	36	1040	14	5	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	138	2026-02-17 08:00:00-06	rechazada	El comité solicita estudios complementarios antes de programar la intervención.	11	\N
107	53	1006	3	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	151	2026-02-23 08:00:00-06	aprobada	\N	4	2026-02-27 15:00:00-06
108	3	1045	1	1	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	164	2026-03-01 08:00:00-06	aprobada	\N	13	2026-03-02 15:00:00-06
109	20	1026	13	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	177	2026-03-07 08:00:00-06	pendiente	\N	2	\N
110	37	1027	14	2	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	190	2026-03-13 08:00:00-06	aprobada	\N	7	2026-03-16 15:00:00-06
111	54	1045	3	3	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	203	2026-03-19 08:00:00-06	aprobada	\N	16	2026-03-23 15:00:00-06
112	4	1009	4	4	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	66	2026-03-25 08:00:00-06	rechazada	El comité solicita estudios complementarios antes de programar la intervención.	9	\N
113	21	1022	9	5	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	79	2026-03-31 08:00:00-06	aprobada	\N	10	2026-04-02 15:00:00-06
114	38	1045	1	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	92	2026-04-06 08:00:00-06	aprobada	\N	15	2026-04-09 15:00:00-06
115	55	1035	3	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	105	2026-04-12 08:00:00-06	aprobada	\N	8	2026-04-16 15:00:00-06
116	5	1006	1	1	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	118	2026-04-18 08:00:00-06	aprobada	\N	1	2026-04-19 15:00:00-06
117	22	1025	8	2	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	131	2026-04-24 08:00:00-06	aprobada	\N	10	2026-04-26 15:00:00-06
118	39	1006	1	3	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	144	2026-04-30 08:00:00-06	rechazada	El comité solicita estudios complementarios antes de programar la intervención.	3	\N
119	56	1007	7	4	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	157	2026-05-06 08:00:00-06	aprobada	\N	8	2026-05-10 15:00:00-06
120	6	1029	16	5	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	170	2026-05-12 08:00:00-06	aprobada	\N	1	2026-05-13 15:00:00-06
121	23	1030	17	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	183	2026-05-18 08:00:00-06	aprobada	\N	6	2026-05-20 15:00:00-06
122	40	1050	8	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	196	2026-05-24 08:00:00-06	aprobada	\N	19	2026-05-27 15:00:00-06
123	57	1050	8	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	209	2026-05-30 08:00:00-06	aprobada	\N	20	2026-06-03 15:00:00-06
124	7	1024	10	2	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	72	2026-06-05 08:00:00-06	rechazada	El comité solicita estudios complementarios antes de programar la intervención.	5	\N
125	24	1006	3	3	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	85	2026-06-11 08:00:00-06	aprobada	\N	2	2026-06-13 15:00:00-06
126	41	1020	11	4	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	98	2026-06-17 08:00:00-06	aprobada	\N	3	2026-06-20 15:00:00-06
127	58	1021	2	5	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	111	2026-06-23 08:00:00-06	pendiente	\N	8	\N
128	8	1028	15	1	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	124	2026-06-29 08:00:00-06	aprobada	\N	9	2026-06-30 15:00:00-06
129	25	1009	5	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	137	2026-07-05 08:00:00-06	aprobada	\N	10	2026-07-07 15:00:00-06
130	42	1023	12	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	150	2026-07-11 08:00:00-06	rechazada	El comité solicita estudios complementarios antes de programar la intervención.	3	\N
131	59	1040	14	2	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	163	2026-07-17 08:00:00-06	aprobada	\N	12	2026-07-21 15:00:00-06
132	9	1006	1	3	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	176	2026-07-23 08:00:00-06	aprobada	\N	1	2026-07-24 15:00:00-06
133	26	1045	3	4	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	189	2026-07-29 08:00:00-06	aprobada	\N	14	2026-07-31 15:00:00-06
134	43	1026	13	5	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	202	2026-08-04 08:00:00-06	aprobada	\N	3	2026-08-07 15:00:00-06
135	60	1027	14	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	65	2026-08-10 08:00:00-06	aprobada	\N	8	2026-08-14 15:00:00-06
136	10	1045	1	1	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	78	2026-08-16 08:00:00-06	rechazada	El comité solicita estudios complementarios antes de programar la intervención.	13	\N
137	27	1009	5	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	91	2026-08-22 08:00:00-06	aprobada	\N	10	2026-08-24 15:00:00-06
138	44	1022	9	2	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	104	2026-08-28 08:00:00-06	aprobada	\N	11	2026-08-31 15:00:00-06
139	61	1045	3	3	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	117	2026-09-03 08:00:00-06	aprobada	\N	16	2026-09-07 15:00:00-06
140	11	1035	1	4	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	130	2026-09-09 08:00:00-06	aprobada	\N	5	2026-09-10 15:00:00-06
141	28	1006	3	5	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	143	2026-09-15 08:00:00-06	aprobada	\N	2	2026-09-17 15:00:00-06
142	45	1025	8	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	156	2026-09-21 08:00:00-06	rechazada	El comité solicita estudios complementarios antes de programar la intervención.	11	\N
143	62	1006	3	1	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	169	2026-09-27 08:00:00-06	aprobada	\N	4	2026-10-01 15:00:00-06
144	12	1007	6	1	urgente	Paciente valorado en consulta; se indica tratamiento quirúrgico.	182	2026-10-03 08:00:00-06	aprobada	\N	5	2026-10-04 15:00:00-06
145	29	1029	16	2	programado	Paciente valorado en consulta; se indica tratamiento quirúrgico.	195	2026-01-12 08:00:00-06	pendiente	\N	2	\N
\.


--
-- Data for Name: aspecto_quirurgico; Type: TABLE DATA; Schema: public; Owner: admin
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
-- Data for Name: auditoria_personal; Type: TABLE DATA; Schema: public; Owner: dueno_auditoria
--

COPY public.auditoria_personal (id_auditoria, fecha_hora, usuario_bd, usuario_sesion, usuario_aplicacion, tabla, id_registro, campo, valor_anterior, valor_nuevo) FROM stdin;
1	2026-10-20 18:13:17.681033-06	admin	hospital	rrhh.lperez	personal	1001	salario	13000.00	14500.00
2	2026-10-20 18:13:17.684541-06	admin	hospital	rrhh.lperez	medico	1015	id_especialidad	309 - Odontología General	307 - Medicina General
3	2026-10-20 18:13:17.685358-06	admin	hospital	direccion.hgo	personal	1004	salario	18500.00	22000.00
4	2026-10-20 18:13:17.685423-06	admin	hospital	direccion.hgo	personal	1004	nivel_acceso	operativo	supervisor
\.


--
-- Data for Name: calificacion; Type: TABLE DATA; Schema: public; Owner: admin
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
11	8	2026-01-18	2	Tuve que esperar bastante.	\N	1010	\N	\N	101
12	15	2026-01-31	1	\N	\N	1015	\N	\N	102
13	22	2026-02-13	2	\N	\N	1031	\N	\N	103
14	29	2026-02-26	4	Muy buena explicación del tratamiento.	\N	1037	\N	\N	104
15	43	2026-03-24	2	\N	\N	1051	\N	\N	106
16	11	2026-05-28	2	\N	\N	1042	\N	\N	111
17	18	2026-06-10	5	Muy buena explicación del tratamiento.	\N	1049	\N	\N	112
18	25	2026-06-23	5	Tuve que esperar bastante.	\N	1004	\N	\N	113
19	32	2026-07-06	3	\N	\N	1013	\N	\N	114
20	46	2026-08-01	5	Muy buena explicación del tratamiento.	\N	1034	\N	\N	116
21	14	2026-10-05	3	Tuve que esperar bastante.	\N	1017	\N	\N	121
22	21	2026-10-18	5	\N	\N	1033	\N	\N	122
23	28	2026-01-14	4	\N	\N	1039	\N	\N	123
24	35	2026-01-27	3	Muy buena explicación del tratamiento.	\N	1047	\N	\N	124
25	49	2026-02-22	1	\N	\N	1011	\N	\N	126
26	17	2026-04-28	3	\N	\N	1001	\N	\N	131
27	24	2026-05-11	1	Muy buena explicación del tratamiento.	\N	1010	\N	\N	132
28	31	2026-05-24	1	Tuve que esperar bastante.	\N	1015	\N	\N	133
29	38	2026-06-06	3	\N	\N	1031	\N	\N	134
30	52	2026-07-02	4	Muy buena explicación del tratamiento.	\N	1043	\N	\N	136
31	20	2026-09-05	1	Tuve que esperar bastante.	\N	1036	\N	\N	141
32	27	2026-09-18	3	\N	\N	1042	\N	\N	142
33	34	2026-10-01	5	\N	\N	1049	\N	\N	143
34	41	2026-10-14	4	Muy buena explicación del tratamiento.	\N	1004	\N	\N	144
35	55	2026-01-23	5	\N	\N	1018	\N	\N	146
36	23	2026-03-29	3	\N	\N	1012	\N	\N	151
37	30	2026-04-11	4	Muy buena explicación del tratamiento.	\N	1017	\N	\N	152
38	37	2026-04-24	3	Tuve que esperar bastante.	\N	1033	\N	\N	153
39	44	2026-05-07	5	\N	\N	1039	\N	\N	154
40	58	2026-06-02	2	Muy buena explicación del tratamiento.	\N	1002	\N	\N	156
41	26	2026-08-06	5	Tuve que esperar bastante.	\N	1044	\N	\N	161
42	33	2026-08-19	1	\N	\N	1001	\N	\N	162
43	40	2026-09-01	1	\N	\N	1010	\N	\N	163
44	47	2026-09-14	2	Muy buena explicación del tratamiento.	\N	1015	\N	\N	164
45	61	2026-10-10	3	\N	\N	1037	\N	\N	166
46	29	2026-02-27	4	\N	\N	1019	\N	\N	171
47	36	2026-03-12	2	Muy buena explicación del tratamiento.	\N	1036	\N	\N	172
48	43	2026-03-25	4	Tuve que esperar bastante.	\N	1042	\N	\N	173
49	50	2026-04-07	4	\N	\N	1049	\N	\N	174
50	64	2026-05-03	5	Muy buena explicación del tratamiento.	\N	1013	\N	\N	176
51	32	2026-07-07	4	Tuve que esperar bastante.	\N	1003	\N	\N	181
52	39	2026-07-20	4	\N	\N	1012	\N	\N	182
53	46	2026-08-02	2	\N	\N	1017	\N	\N	183
54	53	2026-08-15	4	Muy buena explicación del tratamiento.	\N	1033	\N	\N	184
55	67	2026-09-10	2	\N	\N	1047	\N	\N	186
56	35	2026-01-28	5	\N	\N	1038	\N	\N	191
57	42	2026-02-10	4	Muy buena explicación del tratamiento.	\N	1044	\N	\N	192
58	49	2026-02-23	2	Tuve que esperar bastante.	\N	1001	\N	\N	193
59	56	2026-03-08	2	\N	\N	1010	\N	\N	194
60	3	2026-04-03	2	Muy buena explicación del tratamiento.	\N	1031	\N	\N	196
61	38	2026-06-07	4	Tuve que esperar bastante.	\N	1014	\N	\N	201
62	45	2026-06-20	5	\N	\N	1019	\N	\N	202
63	52	2026-07-03	3	\N	\N	1036	\N	\N	203
64	59	2026-07-16	2	Muy buena explicación del tratamiento.	\N	1042	\N	\N	204
65	6	2026-08-11	5	\N	\N	1004	\N	\N	206
66	41	2026-10-15	4	\N	\N	1048	\N	\N	211
67	48	2026-01-11	5	Muy buena explicación del tratamiento.	\N	1003	\N	\N	212
68	55	2026-01-24	2	Tuve que esperar bastante.	\N	1012	\N	\N	213
69	62	2026-02-06	3	\N	\N	1017	\N	\N	214
70	9	2026-03-04	4	Muy buena explicación del tratamiento.	\N	1039	\N	\N	216
71	44	2026-05-08	4	Tuve que esperar bastante.	\N	1032	\N	\N	221
72	51	2026-05-21	3	\N	\N	1038	\N	\N	222
73	58	2026-06-03	5	\N	\N	1044	\N	\N	223
74	65	2026-06-16	3	Muy buena explicación del tratamiento.	\N	1001	\N	\N	224
75	12	2026-07-12	1	\N	\N	1015	\N	\N	226
76	47	2026-09-15	1	\N	\N	1005	\N	\N	231
77	54	2026-09-28	5	Muy buena explicación del tratamiento.	\N	1014	\N	\N	232
78	61	2026-10-11	5	Tuve que esperar bastante.	\N	1019	\N	\N	233
79	1	2026-01-07	1	\N	\N	1036	\N	\N	234
80	15	2026-02-02	5	Muy buena explicación del tratamiento.	\N	1049	\N	\N	236
81	50	2026-04-08	2	Tuve que esperar bastante.	\N	1041	\N	\N	241
82	57	2026-04-21	5	\N	\N	1048	\N	\N	242
83	64	2026-05-04	3	\N	\N	1003	\N	\N	243
84	4	2026-05-17	3	Muy buena explicación del tratamiento.	\N	1012	\N	\N	244
85	18	2026-06-12	3	\N	\N	1033	\N	\N	246
86	53	2026-08-16	3	\N	\N	1016	\N	\N	251
87	60	2026-08-29	2	Muy buena explicación del tratamiento.	\N	1032	\N	\N	252
88	67	2026-09-11	4	Tuve que esperar bastante.	\N	1038	\N	\N	253
89	7	2026-09-24	5	\N	\N	1044	\N	\N	254
90	21	2026-10-20	1	Muy buena explicación del tratamiento.	\N	1010	\N	\N	256
91	56	2026-03-09	1	Tuve que esperar bastante.	\N	1051	\N	\N	261
92	63	2026-03-22	1	\N	\N	1005	\N	\N	262
93	3	2026-04-04	5	\N	\N	1014	\N	\N	263
94	10	2026-04-17	4	Muy buena explicación del tratamiento.	\N	1019	\N	\N	264
95	24	2026-05-13	4	\N	\N	1042	\N	\N	266
96	59	2026-07-17	5	\N	\N	1034	\N	\N	271
97	66	2026-07-30	3	Muy buena explicación del tratamiento.	\N	1041	\N	\N	272
98	6	2026-08-12	3	Tuve que esperar bastante.	\N	1048	\N	\N	273
99	13	2026-08-25	4	\N	\N	1003	\N	\N	274
100	27	2026-09-20	2	Muy buena explicación del tratamiento.	\N	1017	\N	\N	276
101	62	2026-02-07	3	Tuve que esperar bastante.	\N	1011	\N	\N	281
102	2	2026-02-20	1	\N	\N	1016	\N	\N	282
103	9	2026-03-05	3	\N	\N	1032	\N	\N	283
104	16	2026-03-18	5	Muy buena explicación del tratamiento.	\N	1038	\N	\N	284
105	30	2026-04-13	2	\N	\N	1001	\N	\N	286
106	65	2026-06-17	3	\N	\N	1043	\N	\N	291
107	5	2026-06-30	2	Muy buena explicación del tratamiento.	\N	1051	\N	\N	292
108	12	2026-07-13	2	Tuve que esperar bastante.	\N	1005	\N	\N	293
109	19	2026-07-26	4	\N	\N	1014	\N	\N	294
110	33	2026-08-21	3	Muy buena explicación del tratamiento.	\N	1036	\N	\N	296
111	1	2026-01-08	4	Tuve que esperar bastante.	\N	1018	\N	\N	301
112	8	2026-01-21	5	\N	\N	1034	\N	\N	302
113	15	2026-02-03	1	\N	\N	1041	\N	\N	303
114	22	2026-02-16	4	Muy buena explicación del tratamiento.	\N	1048	\N	\N	304
115	36	2026-03-14	2	\N	\N	1012	\N	\N	306
116	4	2026-05-18	4	\N	\N	1002	\N	\N	311
117	11	2026-05-31	1	Muy buena explicación del tratamiento.	\N	1011	\N	\N	312
118	18	2026-06-13	2	Tuve que esperar bastante.	\N	1016	\N	\N	313
119	25	2026-06-26	4	\N	\N	1032	\N	\N	314
120	39	2026-07-22	5	Muy buena explicación del tratamiento.	\N	1044	\N	\N	316
121	4	2026-01-17	5	\N	2	\N	\N	\N	\N
122	7	2026-01-24	4	\N	3	\N	\N	\N	\N
123	10	2026-01-31	3	\N	4	\N	\N	\N	\N
124	13	2026-02-07	2	\N	5	\N	\N	\N	\N
125	16	2026-02-14	2	\N	1	\N	\N	\N	\N
126	19	2026-02-21	5	\N	2	\N	\N	\N	\N
127	22	2026-02-28	4	\N	3	\N	\N	\N	\N
128	25	2026-03-07	3	\N	4	\N	\N	\N	\N
129	28	2026-03-14	2	\N	5	\N	\N	\N	\N
130	31	2026-03-21	2	\N	1	\N	\N	\N	\N
131	34	2026-03-28	5	\N	2	\N	\N	\N	\N
132	37	2026-04-04	4	\N	3	\N	\N	\N	\N
133	40	2026-04-11	3	\N	4	\N	\N	\N	\N
134	43	2026-04-18	2	\N	5	\N	\N	\N	\N
135	46	2026-04-25	2	\N	1	\N	\N	\N	\N
136	49	2026-05-02	5	\N	2	\N	\N	\N	\N
137	52	2026-05-09	4	\N	3	\N	\N	\N	\N
138	55	2026-05-16	3	\N	4	\N	\N	\N	\N
139	58	2026-05-23	2	\N	5	\N	\N	\N	\N
140	61	2026-05-30	2	\N	1	\N	\N	\N	\N
141	64	2026-06-06	5	\N	2	\N	\N	\N	\N
142	67	2026-06-13	4	\N	3	\N	\N	\N	\N
143	3	2026-06-20	3	\N	4	\N	\N	\N	\N
144	6	2026-06-27	2	\N	5	\N	\N	\N	\N
145	9	2026-07-04	2	\N	1	\N	\N	\N	\N
146	12	2026-07-11	5	\N	2	\N	\N	\N	\N
147	15	2026-07-18	4	\N	3	\N	\N	\N	\N
148	18	2026-07-25	3	\N	4	\N	\N	\N	\N
149	21	2026-08-01	2	\N	5	\N	\N	\N	\N
150	24	2026-08-08	2	\N	1	\N	\N	\N	\N
151	27	2026-08-15	5	\N	2	\N	\N	\N	\N
152	30	2026-08-22	4	\N	3	\N	\N	\N	\N
153	33	2026-08-29	3	\N	4	\N	\N	\N	\N
154	36	2026-09-05	2	\N	5	\N	\N	\N	\N
155	39	2026-09-12	2	\N	1	\N	\N	\N	\N
156	42	2026-09-19	5	\N	2	\N	\N	\N	\N
157	45	2026-09-26	4	\N	3	\N	\N	\N	\N
158	48	2026-10-03	3	\N	4	\N	\N	\N	\N
159	51	2026-10-10	2	\N	5	\N	\N	\N	\N
160	54	2026-01-10	2	\N	1	\N	\N	\N	\N
161	6	2026-02-12	3	\N	\N	\N	2002	\N	\N
162	11	2026-02-23	4	\N	\N	\N	2003	\N	\N
163	16	2026-03-06	5	Atención amable y oportuna.	\N	\N	2004	\N	\N
164	21	2026-03-17	2	\N	\N	\N	2005	\N	\N
165	26	2026-03-28	3	\N	\N	\N	2006	\N	\N
166	31	2026-04-08	4	Atención amable y oportuna.	\N	\N	2007	\N	\N
167	36	2026-04-19	5	\N	\N	\N	2008	\N	\N
168	41	2026-04-30	2	\N	\N	\N	2009	\N	\N
169	46	2026-05-11	3	Atención amable y oportuna.	\N	\N	2010	\N	\N
170	51	2026-05-22	4	\N	\N	\N	2011	\N	\N
171	56	2026-06-02	5	\N	\N	\N	2012	\N	\N
172	61	2026-06-13	2	Atención amable y oportuna.	\N	\N	2013	\N	\N
173	66	2026-06-24	3	\N	\N	\N	2014	\N	\N
174	4	2026-07-05	4	\N	\N	\N	2015	\N	\N
175	9	2026-07-16	5	Atención amable y oportuna.	\N	\N	2016	\N	\N
176	14	2026-07-27	2	\N	\N	\N	2017	\N	\N
177	19	2026-08-07	3	\N	\N	\N	2018	\N	\N
178	24	2026-08-18	4	Atención amable y oportuna.	\N	\N	2019	\N	\N
179	29	2026-08-29	5	\N	\N	\N	2020	\N	\N
180	34	2026-09-09	2	\N	\N	\N	2001	\N	\N
181	13	2026-06-26	5	Acompañó al paciente en todos los trámites.	\N	\N	\N	317	\N
182	20	2026-06-13	4	Acompañó al paciente en todos los trámites.	\N	\N	\N	304	\N
183	26	2026-06-19	4	Acompañó al paciente en todos los trámites.	\N	\N	\N	310	\N
184	27	2026-06-20	5	Acompañó al paciente en todos los trámites.	\N	\N	\N	311	\N
185	13	2026-06-13	4	Acompañó al paciente en todos los trámites.	\N	\N	\N	304	\N
186	20	2026-06-20	5	Acompañó al paciente en todos los trámites.	\N	\N	\N	311	\N
187	27	2026-06-27	3	Acompañó al paciente en todos los trámites.	\N	\N	\N	318	\N
\.


--
-- Data for Name: camilla; Type: TABLE DATA; Schema: public; Owner: admin
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
301	44	1	t
302	44	2	t
303	44	3	t
304	44	4	t
305	44	5	t
306	44	6	t
307	44	7	t
308	44	8	t
309	44	9	t
310	44	10	t
311	44	11	t
312	44	12	t
313	44	13	t
314	44	14	t
315	42	1	t
316	42	2	t
317	42	3	t
318	42	4	t
319	42	5	t
401	54	1	t
402	54	2	t
403	54	3	t
404	54	4	t
405	54	5	t
406	54	6	t
407	54	7	t
408	54	8	t
409	54	9	t
410	54	10	t
411	52	1	t
412	52	2	t
413	52	3	t
414	52	4	t
\.


--
-- Data for Name: chequeo_preanestesico; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.chequeo_preanestesico (id_chequeo, id_agendamiento, clasificacion_asa, id_medico_clasifica, plan_anestesia, id_medico_anestesista) FROM stdin;
1	1	II	1006	Inducción con propofol, mantenimiento con sevoflurano, analgesia con morfina.	1008
144	144	I	1007	Plan anestésico acorde al tipo de anestesia solicitado.	1007
119	119	III	1007	Plan anestésico acorde al tipo de anestesia solicitado.	1007
126	126	II	1020	Plan anestésico acorde al tipo de anestesia solicitado.	1008
101	101	II	1020	Plan anestésico acorde al tipo de anestesia solicitado.	1008
102	102	II	1021	Plan anestésico acorde al tipo de anestesia solicitado.	1021
138	138	II	1022	Plan anestésico acorde al tipo de anestesia solicitado.	1022
113	113	II	1022	Plan anestésico acorde al tipo de anestesia solicitado.	1022
105	105	II	1023	Plan anestésico acorde al tipo de anestesia solicitado.	1008
117	117	II	1025	Plan anestésico acorde al tipo de anestesia solicitado.	1025
134	134	II	1026	Plan anestésico acorde al tipo de anestesia solicitado.	1008
135	135	III	1027	Plan anestésico acorde al tipo de anestesia solicitado.	1027
110	110	II	1027	Plan anestésico acorde al tipo de anestesia solicitado.	1027
128	128	I	1028	Plan anestésico acorde al tipo de anestesia solicitado.	1028
103	103	III	1028	Plan anestésico acorde al tipo de anestesia solicitado.	1028
120	120	I	1029	Plan anestésico acorde al tipo de anestesia solicitado.	1008
121	121	II	1030	Plan anestésico acorde al tipo de anestesia solicitado.	1030
143	143	III	1006	Plan anestésico acorde al tipo de anestesia solicitado.	1008
141	141	II	1006	Plan anestésico acorde al tipo de anestesia solicitado.	1008
132	132	I	1006	Plan anestésico acorde al tipo de anestesia solicitado.	1008
125	125	II	1006	Plan anestésico acorde al tipo de anestesia solicitado.	1008
116	116	I	1006	Plan anestésico acorde al tipo de anestesia solicitado.	1008
107	107	III	1006	Plan anestésico acorde al tipo de anestesia solicitado.	1008
140	140	I	1035	Plan anestésico acorde al tipo de anestesia solicitado.	1035
115	115	III	1035	Plan anestésico acorde al tipo de anestesia solicitado.	1035
131	131	III	1040	Plan anestésico acorde al tipo de anestesia solicitado.	1040
137	137	II	1009	Plan anestésico acorde al tipo de anestesia solicitado.	1009
129	129	II	1009	Plan anestésico acorde al tipo de anestesia solicitado.	1009
104	104	I	1009	Plan anestésico acorde al tipo de anestesia solicitado.	1009
139	139	III	1045	Plan anestésico acorde al tipo de anestesia solicitado.	1046
133	133	II	1045	Plan anestésico acorde al tipo de anestesia solicitado.	1046
114	114	II	1045	Plan anestésico acorde al tipo de anestesia solicitado.	1046
111	111	III	1045	Plan anestésico acorde al tipo de anestesia solicitado.	1046
108	108	I	1045	Plan anestésico acorde al tipo de anestesia solicitado.	1046
123	123	III	1050	Plan anestésico acorde al tipo de anestesia solicitado.	1050
122	122	II	1050	Plan anestésico acorde al tipo de anestesia solicitado.	1050
\.


--
-- Data for Name: cirugia; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.cirugia (id_cirugia, id_agendamiento, id_quirofano, id_ingreso, fecha_hora_inicio, fecha_hora_fin, estado, condicion_evolucion) FROM stdin;
1	1	2	4	2026-08-11 18:40:00-06	2026-08-11 20:10:00-06	finalizada	sin_complicaciones
101	101	2	3001	2026-01-20 15:00:00-06	2026-01-20 16:03:00-06	finalizada	sin_complicaciones
102	102	7	3002	2026-01-27 15:00:00-06	2026-01-27 16:26:00-06	finalizada	sin_complicaciones
103	103	12	3003	2026-02-03 15:00:00-06	2026-02-03 16:49:00-06	finalizada	sin_complicaciones
104	104	9	3004	2026-02-06 15:00:00-06	2026-02-06 17:12:00-06	finalizada	sin_complicaciones
105	105	2	3005	2026-02-13 15:00:00-06	2026-02-13 16:45:00-06	finalizada	complicaciones
107	107	4	3007	2026-02-27 15:00:00-06	2026-02-27 17:31:00-06	finalizada	sin_complicaciones
108	108	13	3008	2026-03-02 15:00:00-06	2026-03-02 17:54:00-06	finalizada	sin_complicaciones
110	110	7	3010	2026-03-16 15:00:00-06	2026-03-16 17:50:00-06	finalizada	complicaciones_graves
111	111	16	3011	2026-03-23 15:00:00-06	2026-03-23 18:13:00-06	finalizada	sin_complicaciones
113	113	10	3013	2026-04-02 15:00:00-06	2026-04-02 16:29:00-06	finalizada	sin_complicaciones
114	114	15	3014	2026-04-09 15:00:00-06	2026-04-09 16:52:00-06	finalizada	sin_complicaciones
115	115	8	3015	2026-04-16 15:00:00-06	2026-04-16 16:25:00-06	finalizada	sin_complicaciones
116	116	1	3016	2026-04-19 15:00:00-06	2026-04-19 16:48:00-06	finalizada	sin_complicaciones
117	117	10	3017	2026-04-26 15:00:00-06	2026-04-26 17:11:00-06	finalizada	sin_complicaciones
119	119	8	3019	2026-05-10 15:00:00-06	2026-05-10 17:57:00-06	finalizada	complicaciones
120	120	1	3020	2026-05-13 15:00:00-06	2026-05-13 17:30:00-06	finalizada	sin_complicaciones
121	121	6	3021	2026-05-20 15:00:00-06	2026-05-20 17:53:00-06	finalizada	complicaciones_graves
122	122	19	3022	2026-05-27 15:00:00-06	2026-05-27 18:16:00-06	finalizada	sin_complicaciones
123	123	20	3023	2026-06-03 15:00:00-06	2026-06-03 18:39:00-06	finalizada	sin_complicaciones
125	125	2	3025	2026-06-13 15:00:00-06	2026-06-13 16:05:00-06	finalizada	sin_complicaciones
126	126	3	3026	2026-06-20 15:00:00-06	2026-06-20 16:28:00-06	finalizada	complicaciones
128	128	9	3028	2026-06-30 15:00:00-06	2026-06-30 17:14:00-06	finalizada	sin_complicaciones
129	129	10	3029	2026-07-07 15:00:00-06	2026-07-07 17:37:00-06	finalizada	sin_complicaciones
131	131	12	3031	2026-07-21 15:00:00-06	2026-07-21 17:33:00-06	finalizada	sin_complicaciones
132	132	1	3032	2026-07-24 15:00:00-06	2026-07-24 17:56:00-06	finalizada	complicaciones_graves
133	133	14	3033	2026-07-31 15:00:00-06	2026-07-31 18:19:00-06	finalizada	complicaciones
134	134	3	3034	2026-08-07 15:00:00-06	2026-08-07 18:42:00-06	finalizada	sin_complicaciones
135	135	8	3035	2026-08-14 15:00:00-06	2026-08-14 15:45:00-06	finalizada	sin_complicaciones
137	137	10	3037	2026-08-24 15:00:00-06	2026-08-24 16:31:00-06	finalizada	sin_complicaciones
138	138	11	3038	2026-08-31 15:00:00-06	2026-08-31 16:54:00-06	finalizada	sin_complicaciones
139	139	16	3039	2026-09-07 15:00:00-06	2026-09-07 17:17:00-06	finalizada	sin_complicaciones
140	140	5	3040	2026-09-10 15:00:00-06	2026-09-10 16:50:00-06	finalizada	complicaciones
141	141	2	3041	2026-09-17 15:00:00-06	2026-09-17 17:13:00-06	finalizada	sin_complicaciones
143	143	4	3043	2026-10-01 15:00:00-06	2026-10-01 17:59:00-06	finalizada	complicaciones_graves
144	144	5	3044	2026-10-04 15:00:00-06	2026-10-04 18:22:00-06	finalizada	sin_complicaciones
\.


--
-- Data for Name: cirugia_insumo; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.cirugia_insumo (id_cirugia, id_insumo, cantidad, costo_unitario) FROM stdin;
1	1	2	30.00
1	2	1	25.00
1	4	10	8.00
1	5	8	15.00
1	6	2	120.00
1	7	3	70.00
101	2	7	85.00
101	4	3	2.50
101	8	3	18.00
102	3	2	12.00
102	5	1	45.00
102	9	3	55.00
103	4	3	2.50
103	6	2	8.00
103	10	3	70.00
104	5	4	45.00
104	7	3	35.00
104	1	3	15.00
105	6	5	8.00
105	8	1	18.00
105	2	3	85.00
107	8	7	18.00
107	10	3	70.00
107	4	3	2.50
108	9	2	55.00
108	1	1	15.00
108	5	3	45.00
110	1	4	15.00
110	3	3	12.00
110	7	3	35.00
111	2	5	85.00
111	4	1	2.50
111	8	3	18.00
113	4	7	2.50
113	6	3	8.00
113	10	3	70.00
114	5	2	45.00
114	7	1	35.00
114	1	3	15.00
115	6	3	8.00
115	8	2	18.00
115	2	3	85.00
116	7	4	35.00
116	9	3	55.00
116	3	3	12.00
117	8	5	18.00
117	10	1	70.00
117	4	3	2.50
119	10	7	70.00
119	2	3	85.00
119	6	3	8.00
120	1	2	15.00
120	3	1	12.00
120	7	3	35.00
121	2	3	85.00
121	4	2	2.50
121	8	3	18.00
122	3	4	12.00
122	5	3	45.00
122	9	3	55.00
123	4	5	2.50
123	6	1	8.00
123	10	3	70.00
125	6	7	8.00
125	8	3	18.00
125	2	3	85.00
126	7	2	35.00
126	9	1	55.00
126	3	3	12.00
128	9	4	55.00
128	1	3	15.00
128	5	3	45.00
129	10	5	70.00
129	2	1	85.00
129	6	3	8.00
131	2	7	85.00
131	4	3	2.50
131	8	3	18.00
132	3	2	12.00
132	5	1	45.00
132	9	3	55.00
133	4	3	2.50
133	6	2	8.00
133	10	3	70.00
134	5	4	45.00
134	7	3	35.00
134	1	3	15.00
135	6	5	8.00
135	8	1	18.00
135	2	3	85.00
137	8	7	18.00
137	10	3	70.00
137	4	3	2.50
138	9	2	55.00
138	1	1	15.00
138	5	3	45.00
139	10	3	70.00
139	2	2	85.00
139	6	3	8.00
140	1	4	15.00
140	3	3	12.00
140	7	3	35.00
141	2	5	85.00
141	4	1	2.50
141	8	3	18.00
143	4	7	2.50
143	6	3	8.00
143	10	3	70.00
144	5	2	45.00
144	7	1	35.00
144	1	3	15.00
\.


--
-- Data for Name: cirugia_personal; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.cirugia_personal (id_cirugia_personal, id_cirugia, id_medico, id_enfermero, id_rol) FROM stdin;
1	1	1006	\N	1
2	1	1008	\N	3
3	1	\N	2001	4
4	1	\N	2003	5
5	101	1020	\N	1
6	102	1021	\N	1
7	103	1028	\N	1
8	104	1009	\N	1
9	105	1023	\N	1
10	107	1006	\N	1
11	108	1045	\N	1
12	110	1027	\N	1
13	111	1045	\N	1
14	113	1022	\N	1
15	114	1045	\N	1
16	115	1035	\N	1
17	116	1006	\N	1
18	117	1025	\N	1
19	119	1007	\N	1
20	120	1029	\N	1
21	121	1030	\N	1
22	122	1050	\N	1
23	123	1050	\N	1
24	125	1006	\N	1
25	126	1020	\N	1
26	128	1028	\N	1
27	129	1009	\N	1
28	131	1040	\N	1
29	132	1006	\N	1
30	133	1045	\N	1
31	134	1026	\N	1
32	135	1027	\N	1
33	137	1009	\N	1
34	138	1022	\N	1
35	139	1045	\N	1
36	140	1035	\N	1
37	141	1006	\N	1
38	143	1006	\N	1
39	144	1007	\N	1
40	126	1008	\N	3
41	101	1008	\N	3
42	105	1008	\N	3
43	134	1008	\N	3
44	120	1008	\N	3
45	143	1008	\N	3
46	141	1008	\N	3
47	132	1008	\N	3
48	125	1008	\N	3
49	116	1008	\N	3
50	107	1008	\N	3
51	139	1046	\N	3
52	133	1046	\N	3
53	114	1046	\N	3
54	111	1046	\N	3
55	108	1046	\N	3
56	101	\N	2004	4
57	101	\N	2005	5
58	102	\N	2008	4
59	102	\N	2009	5
60	103	\N	2012	4
61	103	\N	2013	5
62	104	\N	2011	4
63	104	\N	2012	5
64	105	\N	2001	4
65	105	\N	2002	5
66	107	\N	2003	4
67	107	\N	2004	5
68	108	\N	2014	4
69	108	\N	2015	5
70	110	\N	2008	4
71	110	\N	2009	5
72	111	\N	2015	4
73	111	\N	2016	5
74	113	\N	2012	4
75	113	\N	2013	5
76	114	\N	2014	4
77	114	\N	2015	5
78	115	\N	2009	4
79	115	\N	2010	5
80	116	\N	2005	4
81	116	\N	2006	5
82	117	\N	2012	4
83	117	\N	2013	5
84	119	\N	2009	4
85	119	\N	2010	5
86	120	\N	2002	4
87	120	\N	2003	5
88	121	\N	2009	4
89	121	\N	2010	5
90	122	\N	2017	4
91	122	\N	2018	5
92	123	\N	2018	4
93	123	\N	2019	5
94	125	\N	2007	4
95	125	\N	2020	5
96	126	\N	2001	4
97	126	\N	2002	5
98	128	\N	2011	4
99	128	\N	2012	5
100	129	\N	2012	4
101	129	\N	2013	5
102	131	\N	2012	4
103	131	\N	2013	5
104	132	\N	2007	4
105	132	\N	2020	5
106	133	\N	2015	4
107	133	\N	2016	5
108	134	\N	2002	4
109	134	\N	2003	5
110	135	\N	2009	4
111	135	\N	2010	5
112	137	\N	2012	4
113	137	\N	2013	5
114	138	\N	2011	4
115	138	\N	2012	5
116	139	\N	2015	4
117	139	\N	2016	5
118	140	\N	2008	4
119	140	\N	2009	5
120	141	\N	2002	4
121	141	\N	2003	5
122	143	\N	2004	4
123	143	\N	2005	5
124	144	\N	2008	4
125	144	\N	2009	5
\.


--
-- Data for Name: cita; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.cita (id_cita, id_paciente, id_medico, fecha_hora, numero_clinica, medio_asignacion, estado, es_reconsulta, es_referido, cancelada_sin_aviso, costo_base, costo_final) FROM stdin;
1	1	1002	2026-08-10 09:00:00-06	A-101	telefonico	realizada	t	f	f	220.00	165.00
2	2	1003	2026-08-12 10:30:00-06	A-205	recepcion_general	reprogramada	f	f	f	160.00	160.00
3	4	1004	2026-08-15 08:30:00-06	B-110	telefonico	cancelada	f	f	t	180.00	198.00
4	6	1002	2026-09-20 09:30:00-06	A-101	correo_institucional	programada	f	t	f	220.00	176.00
5	5	1005	2026-08-11 09:15:00-06	A-108	recepcion_medico	realizada	f	f	f	180.00	180.00
101	8	1010	2026-01-18 08:30:00-06	C-110	correo_institucional	realizada	f	f	f	180.00	180.00
102	15	1015	2026-01-31 09:00:00-06	C-115	recepcion_general	realizada	f	f	f	130.00	130.00
103	22	1031	2026-02-13 09:30:00-06	C-131	recepcion_medico	realizada	t	f	f	170.00	127.50
104	29	1037	2026-02-26 10:00:00-06	C-137	telefonico	realizada	f	f	f	150.00	150.00
105	36	1043	2026-03-11 08:00:00-06	C-143	correo_institucional	reprogramada	f	f	f	215.00	215.00
106	43	1051	2026-03-24 09:30:00-06	C-151	recepcion_general	realizada	t	f	f	160.00	120.00
107	50	1005	2026-04-06 09:00:00-06	C-105	recepcion_medico	realizada	f	t	f	180.00	144.00
108	57	1014	2026-04-19 09:30:00-06	C-114	telefonico	realizada	f	f	f	150.00	150.00
109	64	1019	2026-05-02 10:00:00-06	C-119	correo_institucional	realizada	t	f	f	190.00	142.50
110	4	1036	2026-05-15 08:00:00-06	C-136	recepcion_general	cancelada	f	f	f	165.00	165.00
111	11	1042	2026-05-28 08:30:00-06	C-142	recepcion_medico	realizada	f	f	f	150.00	150.00
112	18	1049	2026-06-10 09:00:00-06	C-149	telefonico	realizada	t	f	f	200.00	150.00
113	25	1004	2026-06-23 09:30:00-06	C-104	correo_institucional	realizada	f	f	f	180.00	180.00
114	32	1013	2026-07-06 11:00:00-06	C-113	recepcion_general	realizada	f	t	f	175.00	140.00
115	39	1018	2026-07-19 08:00:00-06	C-118	recepcion_medico	reprogramada	t	f	f	140.00	105.00
116	46	1034	2026-08-01 08:30:00-06	C-134	telefonico	realizada	f	f	f	190.00	190.00
117	53	1041	2026-08-14 09:00:00-06	C-141	correo_institucional	realizada	f	f	f	160.00	160.00
118	60	1048	2026-08-27 09:30:00-06	C-148	recepcion_general	realizada	t	f	f	145.00	108.75
119	67	1003	2026-09-09 11:00:00-06	C-103	recepcion_medico	realizada	f	f	f	160.00	160.00
120	7	1012	2026-09-22 08:00:00-06	C-112	telefonico	cancelada	f	f	t	195.00	195.00
121	14	1017	2026-10-05 09:30:00-06	C-117	correo_institucional	realizada	t	f	f	165.00	123.75
122	21	1033	2026-10-18 09:00:00-06	C-133	recepcion_general	realizada	f	f	f	230.00	230.00
123	28	1039	2026-01-14 10:30:00-06	C-139	recepcion_medico	realizada	f	f	f	175.00	175.00
124	35	1047	2026-01-27 10:00:00-06	C-147	telefonico	realizada	t	f	f	150.00	112.50
125	42	1002	2026-02-09 08:00:00-06	C-102	correo_institucional	reprogramada	f	f	f	220.00	220.00
126	49	1011	2026-02-22 09:30:00-06	C-111	recepcion_general	realizada	f	f	f	210.00	210.00
127	56	1016	2026-03-07 09:00:00-06	C-116	recepcion_medico	realizada	t	f	f	185.00	138.75
128	63	1032	2026-03-20 09:30:00-06	C-132	telefonico	realizada	f	t	f	160.00	128.00
129	3	1038	2026-04-02 10:00:00-06	C-138	correo_institucional	realizada	f	f	f	210.00	210.00
130	10	1044	2026-04-15 09:00:00-06	C-144	recepcion_general	cancelada	t	f	f	205.00	153.75
131	17	1001	2026-04-28 08:30:00-06	C-101	recepcion_medico	realizada	f	f	f	200.00	200.00
132	24	1010	2026-05-11 09:00:00-06	C-110	telefonico	realizada	f	f	f	180.00	180.00
133	31	1015	2026-05-24 09:30:00-06	C-115	correo_institucional	realizada	t	f	f	130.00	97.50
134	38	1031	2026-06-06 10:00:00-06	C-131	recepcion_general	realizada	f	f	f	170.00	170.00
135	45	1037	2026-06-19 08:00:00-06	C-137	recepcion_medico	reprogramada	f	t	f	150.00	120.00
136	52	1043	2026-07-02 08:30:00-06	C-143	telefonico	realizada	t	f	f	215.00	161.25
137	59	1051	2026-07-15 10:00:00-06	C-151	correo_institucional	realizada	f	f	f	160.00	160.00
138	66	1005	2026-07-28 09:30:00-06	C-105	recepcion_general	realizada	f	f	f	180.00	180.00
139	6	1014	2026-08-10 10:00:00-06	C-114	recepcion_medico	realizada	t	f	f	150.00	112.50
140	13	1019	2026-08-23 08:00:00-06	C-119	telefonico	cancelada	f	f	t	190.00	190.00
141	20	1036	2026-09-05 08:30:00-06	C-136	correo_institucional	realizada	f	f	f	165.00	165.00
142	27	1042	2026-09-18 09:00:00-06	C-142	recepcion_general	realizada	t	f	f	150.00	112.50
143	34	1049	2026-10-01 09:30:00-06	C-149	recepcion_medico	realizada	f	f	f	200.00	200.00
144	41	1004	2026-10-14 10:00:00-06	C-104	telefonico	realizada	f	f	f	180.00	180.00
145	48	1013	2026-01-10 09:00:00-06	C-113	correo_institucional	reprogramada	t	f	f	175.00	131.25
146	55	1018	2026-01-23 08:30:00-06	C-118	recepcion_general	realizada	f	f	f	140.00	140.00
147	62	1034	2026-02-05 09:00:00-06	C-134	recepcion_medico	realizada	f	f	f	190.00	190.00
148	2	1041	2026-02-18 09:30:00-06	C-141	telefonico	realizada	t	f	f	160.00	120.00
149	9	1048	2026-03-03 10:00:00-06	C-148	correo_institucional	realizada	f	t	f	145.00	116.00
150	16	1003	2026-03-16 09:00:00-06	C-103	recepcion_general	cancelada	f	f	f	160.00	160.00
151	23	1012	2026-03-29 08:30:00-06	C-112	recepcion_medico	realizada	t	f	f	195.00	146.25
152	30	1017	2026-04-11 10:00:00-06	C-117	telefonico	realizada	f	f	f	165.00	165.00
153	37	1033	2026-04-24 09:30:00-06	C-133	correo_institucional	realizada	f	f	f	230.00	230.00
154	44	1039	2026-05-07 11:00:00-06	C-139	recepcion_general	realizada	t	f	f	175.00	131.25
155	51	1047	2026-05-20 08:00:00-06	C-147	recepcion_medico	reprogramada	f	f	f	150.00	150.00
156	58	1002	2026-06-02 08:30:00-06	C-102	telefonico	realizada	f	t	f	220.00	176.00
157	65	1011	2026-06-15 10:00:00-06	C-111	correo_institucional	realizada	t	f	f	210.00	157.50
158	5	1016	2026-06-28 09:30:00-06	C-116	recepcion_general	realizada	f	f	f	185.00	185.00
159	12	1032	2026-07-11 10:00:00-06	C-132	recepcion_medico	realizada	f	f	f	160.00	160.00
160	19	1038	2026-07-24 08:00:00-06	C-138	telefonico	cancelada	t	f	t	210.00	157.50
161	26	1044	2026-08-06 09:30:00-06	C-144	correo_institucional	realizada	f	f	f	205.00	205.00
162	33	1001	2026-08-19 09:00:00-06	C-101	recepcion_general	realizada	f	f	f	200.00	200.00
163	40	1010	2026-09-01 09:30:00-06	C-110	recepcion_medico	realizada	t	f	f	180.00	135.00
164	47	1015	2026-09-14 10:00:00-06	C-115	telefonico	realizada	f	f	f	130.00	130.00
165	54	1031	2026-09-27 08:00:00-06	C-131	correo_institucional	reprogramada	f	f	f	170.00	170.00
166	61	1037	2026-10-10 08:30:00-06	C-137	recepcion_general	realizada	t	f	f	150.00	112.50
167	1	1043	2026-01-06 09:00:00-06	C-143	recepcion_medico	realizada	f	f	f	215.00	215.00
168	8	1051	2026-01-19 10:30:00-06	C-151	telefonico	realizada	f	f	f	160.00	160.00
169	15	1005	2026-02-01 10:00:00-06	C-105	correo_institucional	realizada	t	f	f	180.00	135.00
170	22	1014	2026-02-14 08:00:00-06	C-114	recepcion_general	cancelada	f	t	f	150.00	120.00
171	29	1019	2026-02-27 08:30:00-06	C-119	recepcion_medico	realizada	f	f	f	190.00	190.00
172	36	1036	2026-03-12 09:00:00-06	C-136	telefonico	realizada	t	f	f	165.00	123.75
173	43	1042	2026-03-25 09:30:00-06	C-142	correo_institucional	realizada	f	f	f	150.00	150.00
174	50	1049	2026-04-07 10:00:00-06	C-149	recepcion_general	realizada	f	f	f	200.00	200.00
175	57	1004	2026-04-20 08:00:00-06	C-104	recepcion_medico	reprogramada	t	f	f	180.00	135.00
176	64	1013	2026-05-03 09:30:00-06	C-113	telefonico	realizada	f	f	f	175.00	175.00
177	4	1018	2026-05-16 09:00:00-06	C-118	correo_institucional	realizada	f	t	f	140.00	112.00
178	11	1034	2026-05-29 09:30:00-06	C-134	recepcion_general	realizada	t	f	f	190.00	142.50
179	18	1041	2026-06-11 10:00:00-06	C-141	recepcion_medico	realizada	f	f	f	160.00	160.00
180	25	1048	2026-06-24 08:00:00-06	C-148	telefonico	cancelada	f	f	t	145.00	145.00
181	32	1003	2026-07-07 09:30:00-06	C-103	correo_institucional	realizada	t	f	f	160.00	120.00
182	39	1012	2026-07-20 09:00:00-06	C-112	recepcion_general	realizada	f	f	f	195.00	195.00
183	46	1017	2026-08-02 10:30:00-06	C-117	recepcion_medico	realizada	f	f	f	165.00	165.00
184	53	1033	2026-08-15 10:00:00-06	C-133	telefonico	realizada	t	f	f	230.00	172.50
185	60	1039	2026-08-28 09:00:00-06	C-139	correo_institucional	reprogramada	f	f	f	175.00	175.00
186	67	1047	2026-09-10 08:30:00-06	C-147	recepcion_general	realizada	f	f	f	150.00	150.00
187	7	1002	2026-09-23 09:00:00-06	C-102	recepcion_medico	realizada	t	f	f	220.00	165.00
188	14	1011	2026-10-06 10:30:00-06	C-111	telefonico	realizada	f	f	f	210.00	210.00
189	21	1016	2026-10-19 10:00:00-06	C-116	correo_institucional	realizada	f	f	f	185.00	185.00
190	28	1032	2026-01-15 08:00:00-06	C-132	recepcion_general	cancelada	t	f	f	160.00	120.00
191	35	1038	2026-01-28 08:30:00-06	C-138	recepcion_medico	realizada	f	t	f	210.00	168.00
192	42	1044	2026-02-10 10:00:00-06	C-144	telefonico	realizada	f	f	f	205.00	205.00
193	49	1001	2026-02-23 09:30:00-06	C-101	correo_institucional	realizada	t	f	f	200.00	150.00
194	56	1010	2026-03-08 10:00:00-06	C-110	recepcion_general	realizada	f	f	f	180.00	180.00
195	63	1015	2026-03-21 08:00:00-06	C-115	recepcion_medico	reprogramada	f	f	f	130.00	130.00
196	3	1031	2026-04-03 08:30:00-06	C-131	telefonico	realizada	t	f	f	170.00	127.50
197	10	1037	2026-04-16 09:00:00-06	C-137	correo_institucional	realizada	f	f	f	150.00	150.00
198	17	1043	2026-04-29 09:30:00-06	C-143	recepcion_general	realizada	f	t	f	215.00	172.00
199	24	1051	2026-05-12 11:00:00-06	C-151	recepcion_medico	realizada	t	f	f	160.00	120.00
200	31	1005	2026-05-25 08:00:00-06	C-105	telefonico	cancelada	f	f	t	180.00	180.00
201	38	1014	2026-06-07 08:30:00-06	C-114	correo_institucional	realizada	f	f	f	150.00	150.00
202	45	1019	2026-06-20 09:00:00-06	C-119	recepcion_general	realizada	t	f	f	190.00	142.50
203	52	1036	2026-07-03 09:30:00-06	C-136	recepcion_medico	realizada	f	f	f	165.00	165.00
204	59	1042	2026-07-16 10:00:00-06	C-142	telefonico	realizada	f	f	f	150.00	150.00
205	66	1049	2026-07-29 08:00:00-06	C-149	correo_institucional	reprogramada	t	f	f	200.00	150.00
206	6	1004	2026-08-11 08:30:00-06	C-104	recepcion_general	realizada	f	f	f	180.00	180.00
207	13	1013	2026-08-24 10:00:00-06	C-113	recepcion_medico	realizada	f	f	f	175.00	175.00
208	20	1018	2026-09-06 09:30:00-06	C-118	telefonico	realizada	t	f	f	140.00	105.00
209	27	1034	2026-09-19 10:00:00-06	C-134	correo_institucional	realizada	f	f	f	190.00	190.00
210	34	1041	2026-10-02 08:00:00-06	C-141	recepcion_general	cancelada	f	f	f	160.00	160.00
211	41	1048	2026-10-15 08:30:00-06	C-148	recepcion_medico	realizada	t	f	f	145.00	108.75
212	48	1003	2026-01-11 10:00:00-06	C-103	telefonico	realizada	f	t	f	160.00	128.00
213	55	1012	2026-01-24 09:30:00-06	C-112	correo_institucional	realizada	f	f	f	195.00	195.00
214	62	1017	2026-02-06 11:00:00-06	C-117	recepcion_general	realizada	t	f	f	165.00	123.75
215	2	1033	2026-02-19 08:00:00-06	C-133	recepcion_medico	reprogramada	f	f	f	230.00	230.00
216	9	1039	2026-03-04 09:30:00-06	C-139	telefonico	realizada	f	f	f	175.00	175.00
217	16	1047	2026-03-17 09:00:00-06	C-147	correo_institucional	realizada	t	f	f	150.00	112.50
218	23	1002	2026-03-30 09:30:00-06	C-102	recepcion_general	realizada	f	f	f	220.00	220.00
219	30	1011	2026-04-12 11:00:00-06	C-111	recepcion_medico	realizada	f	t	f	210.00	168.00
220	37	1016	2026-04-25 08:00:00-06	C-116	telefonico	cancelada	t	f	t	185.00	138.75
221	44	1032	2026-05-08 08:30:00-06	C-132	correo_institucional	realizada	f	f	f	160.00	160.00
222	51	1038	2026-05-21 09:00:00-06	C-138	recepcion_general	realizada	f	f	f	210.00	210.00
223	58	1044	2026-06-03 10:30:00-06	C-144	recepcion_medico	realizada	t	f	f	205.00	153.75
224	65	1001	2026-06-16 10:00:00-06	C-101	telefonico	realizada	f	f	f	200.00	200.00
225	5	1010	2026-06-29 08:00:00-06	C-110	correo_institucional	reprogramada	f	f	f	180.00	180.00
226	12	1015	2026-07-12 08:30:00-06	C-115	recepcion_general	realizada	t	f	f	130.00	97.50
227	19	1031	2026-07-25 09:00:00-06	C-131	recepcion_medico	realizada	f	f	f	170.00	170.00
228	26	1037	2026-08-07 09:30:00-06	C-137	telefonico	realizada	f	f	f	150.00	150.00
229	33	1043	2026-08-20 10:00:00-06	C-143	correo_institucional	realizada	t	f	f	215.00	161.25
230	40	1051	2026-09-02 09:00:00-06	C-151	recepcion_general	cancelada	f	f	f	160.00	160.00
231	47	1005	2026-09-15 08:30:00-06	C-105	recepcion_medico	realizada	f	f	f	180.00	180.00
232	54	1014	2026-09-28 09:00:00-06	C-114	telefonico	realizada	t	f	f	150.00	112.50
233	61	1019	2026-10-11 09:30:00-06	C-119	correo_institucional	realizada	f	t	f	190.00	152.00
234	1	1036	2026-01-07 10:00:00-06	C-136	recepcion_general	realizada	f	f	f	165.00	165.00
235	8	1042	2026-01-20 08:00:00-06	C-142	recepcion_medico	reprogramada	t	f	f	150.00	112.50
236	15	1049	2026-02-02 08:30:00-06	C-149	telefonico	realizada	f	f	f	200.00	200.00
237	22	1004	2026-02-15 09:00:00-06	C-104	correo_institucional	realizada	f	f	f	180.00	180.00
238	29	1013	2026-02-28 10:30:00-06	C-113	recepcion_general	realizada	t	f	f	175.00	131.25
239	36	1018	2026-03-13 10:00:00-06	C-118	recepcion_medico	realizada	f	f	f	140.00	140.00
240	43	1034	2026-03-26 08:00:00-06	C-134	telefonico	cancelada	f	t	t	190.00	152.00
241	50	1041	2026-04-08 08:30:00-06	C-141	correo_institucional	realizada	t	f	f	160.00	120.00
242	57	1048	2026-04-21 09:00:00-06	C-148	recepcion_general	realizada	f	f	f	145.00	145.00
243	64	1003	2026-05-04 10:30:00-06	C-103	recepcion_medico	realizada	f	f	f	160.00	160.00
244	4	1012	2026-05-17 10:00:00-06	C-112	telefonico	realizada	t	f	f	195.00	146.25
245	11	1017	2026-05-30 09:00:00-06	C-117	correo_institucional	reprogramada	f	f	f	165.00	165.00
246	18	1033	2026-06-12 08:30:00-06	C-133	recepcion_general	realizada	f	f	f	230.00	230.00
247	25	1039	2026-06-25 10:00:00-06	C-139	recepcion_medico	realizada	t	f	f	175.00	131.25
248	32	1047	2026-07-08 09:30:00-06	C-147	telefonico	realizada	f	f	f	150.00	150.00
249	39	1002	2026-07-21 10:00:00-06	C-102	correo_institucional	realizada	f	f	f	220.00	220.00
250	46	1011	2026-08-03 09:00:00-06	C-111	recepcion_general	cancelada	t	f	f	210.00	157.50
251	53	1016	2026-08-16 08:30:00-06	C-116	recepcion_medico	realizada	f	f	f	185.00	185.00
252	60	1032	2026-08-29 09:00:00-06	C-132	telefonico	realizada	f	f	f	160.00	160.00
253	67	1038	2026-09-11 09:30:00-06	C-138	correo_institucional	realizada	t	f	f	210.00	157.50
254	7	1044	2026-09-24 11:00:00-06	C-144	recepcion_general	realizada	f	t	f	205.00	164.00
255	14	1001	2026-10-07 08:00:00-06	C-101	recepcion_medico	reprogramada	f	f	f	200.00	200.00
256	21	1010	2026-10-20 08:30:00-06	C-110	telefonico	realizada	t	f	f	180.00	135.00
257	28	1015	2026-01-16 09:00:00-06	C-115	correo_institucional	realizada	f	f	f	130.00	130.00
258	35	1031	2026-01-29 09:30:00-06	C-131	recepcion_general	realizada	f	f	f	170.00	170.00
259	42	1037	2026-02-11 10:00:00-06	C-137	recepcion_medico	realizada	t	f	f	150.00	112.50
260	49	1043	2026-02-24 08:00:00-06	C-143	telefonico	cancelada	f	f	t	215.00	215.00
261	56	1051	2026-03-09 09:30:00-06	C-151	correo_institucional	realizada	f	t	f	160.00	128.00
262	63	1005	2026-03-22 09:00:00-06	C-105	recepcion_general	realizada	t	f	f	180.00	135.00
263	3	1014	2026-04-04 09:30:00-06	C-114	recepcion_medico	realizada	f	f	f	150.00	150.00
264	10	1019	2026-04-17 10:00:00-06	C-119	telefonico	realizada	f	f	f	190.00	190.00
265	17	1036	2026-04-30 08:00:00-06	C-136	correo_institucional	reprogramada	t	f	f	165.00	123.75
266	24	1042	2026-05-13 08:30:00-06	C-142	recepcion_general	realizada	f	f	f	150.00	150.00
267	31	1049	2026-05-26 09:00:00-06	C-149	recepcion_medico	realizada	f	f	f	200.00	200.00
268	38	1004	2026-06-08 09:30:00-06	C-104	telefonico	realizada	t	f	f	180.00	135.00
269	45	1013	2026-06-21 11:00:00-06	C-113	correo_institucional	realizada	f	f	f	175.00	175.00
270	52	1018	2026-07-04 08:00:00-06	C-118	recepcion_general	cancelada	f	f	f	140.00	140.00
271	59	1034	2026-07-17 08:30:00-06	C-134	recepcion_medico	realizada	t	f	f	190.00	142.50
272	66	1041	2026-07-30 09:00:00-06	C-141	telefonico	realizada	f	f	f	160.00	160.00
273	6	1048	2026-08-12 09:30:00-06	C-148	correo_institucional	realizada	f	f	f	145.00	145.00
274	13	1003	2026-08-25 11:00:00-06	C-103	recepcion_general	realizada	t	f	f	160.00	120.00
275	20	1012	2026-09-07 08:00:00-06	C-112	recepcion_medico	reprogramada	f	t	f	195.00	156.00
276	27	1017	2026-09-20 09:30:00-06	C-117	telefonico	realizada	f	f	f	165.00	165.00
277	34	1033	2026-10-03 09:00:00-06	C-133	correo_institucional	realizada	t	f	f	230.00	172.50
278	41	1039	2026-10-16 10:30:00-06	C-139	recepcion_general	realizada	f	f	f	175.00	175.00
279	48	1047	2026-01-12 10:00:00-06	C-147	recepcion_medico	realizada	f	f	f	150.00	150.00
280	55	1002	2026-01-25 08:00:00-06	C-102	telefonico	cancelada	t	f	t	220.00	165.00
281	62	1011	2026-02-07 09:30:00-06	C-111	correo_institucional	realizada	f	f	f	210.00	210.00
282	2	1016	2026-02-20 09:00:00-06	C-116	recepcion_general	realizada	f	t	f	185.00	148.00
283	9	1032	2026-03-05 09:30:00-06	C-132	recepcion_medico	realizada	t	f	f	160.00	120.00
284	16	1038	2026-03-18 10:00:00-06	C-138	telefonico	realizada	f	f	f	210.00	210.00
285	23	1044	2026-03-31 09:00:00-06	C-144	correo_institucional	reprogramada	f	f	f	205.00	205.00
286	30	1001	2026-04-13 08:30:00-06	C-101	recepcion_general	realizada	t	f	f	200.00	150.00
287	37	1010	2026-04-26 09:00:00-06	C-110	recepcion_medico	realizada	f	f	f	180.00	180.00
288	44	1015	2026-05-09 09:30:00-06	C-115	telefonico	realizada	f	f	f	130.00	130.00
289	51	1031	2026-05-22 10:00:00-06	C-131	correo_institucional	realizada	t	f	f	170.00	127.50
290	58	1037	2026-06-04 08:00:00-06	C-137	recepcion_general	cancelada	f	f	f	150.00	150.00
291	65	1043	2026-06-17 08:30:00-06	C-143	recepcion_medico	realizada	f	f	f	215.00	215.00
292	5	1051	2026-06-30 10:00:00-06	C-151	telefonico	realizada	t	f	f	160.00	120.00
293	12	1005	2026-07-13 09:30:00-06	C-105	correo_institucional	realizada	f	f	f	180.00	180.00
294	19	1014	2026-07-26 10:00:00-06	C-114	recepcion_general	realizada	f	f	f	150.00	150.00
295	26	1019	2026-08-08 08:00:00-06	C-119	recepcion_medico	reprogramada	t	f	f	190.00	142.50
296	33	1036	2026-08-21 08:30:00-06	C-136	telefonico	realizada	f	t	f	165.00	132.00
297	40	1042	2026-09-03 09:00:00-06	C-142	correo_institucional	realizada	f	f	f	150.00	150.00
298	47	1049	2026-09-16 09:30:00-06	C-149	recepcion_general	realizada	t	f	f	200.00	150.00
299	54	1004	2026-09-29 10:00:00-06	C-104	recepcion_medico	realizada	f	f	f	180.00	180.00
300	61	1013	2026-10-12 09:00:00-06	C-113	telefonico	cancelada	f	f	t	175.00	175.00
301	1	1018	2026-01-08 08:30:00-06	C-118	correo_institucional	realizada	t	f	f	140.00	105.00
302	8	1034	2026-01-21 09:00:00-06	C-134	recepcion_general	realizada	f	f	f	190.00	190.00
303	15	1041	2026-02-03 09:30:00-06	C-141	recepcion_medico	realizada	f	t	f	160.00	128.00
304	22	1048	2026-02-16 10:00:00-06	C-148	telefonico	realizada	t	f	f	145.00	108.75
305	29	1003	2026-03-01 09:00:00-06	C-103	correo_institucional	reprogramada	f	f	f	160.00	160.00
306	36	1012	2026-03-14 08:30:00-06	C-112	recepcion_general	realizada	f	f	f	195.00	195.00
307	43	1017	2026-03-27 10:00:00-06	C-117	recepcion_medico	realizada	t	f	f	165.00	123.75
308	50	1033	2026-04-09 09:30:00-06	C-133	telefonico	realizada	f	f	f	230.00	230.00
309	57	1039	2026-04-22 11:00:00-06	C-139	correo_institucional	realizada	f	f	f	175.00	175.00
310	64	1047	2026-05-05 08:00:00-06	C-147	recepcion_general	cancelada	t	f	f	150.00	112.50
311	4	1002	2026-05-18 08:30:00-06	C-102	recepcion_medico	realizada	f	f	f	220.00	220.00
312	11	1011	2026-05-31 10:00:00-06	C-111	telefonico	realizada	f	f	f	210.00	210.00
313	18	1016	2026-06-13 09:30:00-06	C-116	correo_institucional	realizada	t	f	f	185.00	138.75
314	25	1032	2026-06-26 10:00:00-06	C-132	recepcion_general	realizada	f	f	f	160.00	160.00
315	32	1038	2026-07-09 08:00:00-06	C-138	recepcion_medico	reprogramada	f	f	f	210.00	210.00
316	39	1044	2026-07-22 09:30:00-06	C-144	telefonico	realizada	t	f	f	205.00	153.75
317	46	1001	2026-08-04 09:00:00-06	C-101	correo_institucional	realizada	f	t	f	200.00	160.00
318	53	1010	2026-08-17 09:30:00-06	C-110	recepcion_general	realizada	f	f	f	180.00	180.00
319	60	1015	2026-08-30 10:00:00-06	C-115	recepcion_medico	realizada	t	f	f	130.00	97.50
320	67	1031	2026-09-12 08:00:00-06	C-131	telefonico	cancelada	f	f	t	170.00	170.00
\.


--
-- Data for Name: consentimiento_informado; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.consentimiento_informado (id_consentimiento, id_agendamiento, id_medico, procedimiento_nombre, procedimiento_objetivo, procedimiento_caracteristicas, procedimiento_riesgos, medico_firmo, firmante_nombre, firmante_relacion, firmante_firmo, fecha_obtencion) FROM stdin;
1	1	1006	Apendicectomía abierta	Resección del apéndice inflamado para evitar perforación y peritonitis.	Incisión en fosa ilíaca derecha, ligadura y extirpación del apéndice, cierre por planos, bajo anestesia general.	Sangrado, infección de herida, lesión de estructuras vecinas, complicaciones anestésicas.	t	Carlos De León Ortiz	paciente	t	2026-08-11
104	104	1009	Resección oncológica de colon	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Jorge Luis Ramírez Sosa	paciente	t	2026-02-05
108	108	1045	Apendicectomía abierta	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Pedro Gómez Aguilar	paciente	t	2026-03-01
116	116	1006	Apendicectomía abierta	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Carlos De León Ortiz	paciente	t	2026-04-18
120	120	1029	Lobectomía pulmonar	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Sofía Rivera Paz	paciente	t	2026-05-12
128	128	1028	Rinoplastia reconstructiva	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Paola Méndez Soto	paciente	t	2026-06-29
132	132	1006	Apendicectomía abierta	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Andrés Cruz Sic	paciente	t	2026-07-23
140	140	1035	Apendicectomía abierta	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Héctor Fuentes Chávez	paciente	t	2026-09-09
144	144	1007	Revascularización miocárdica	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Claudia Vásquez Paz	paciente	t	2026-10-03
101	101	1020	Reparación de tendones flexores de la mano	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Carmen Xicará Ruiz	paciente	t	2026-01-18
105	105	1023	Craneotomía para drenaje de hematoma	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Luis Fernando Batz Rojas	paciente	t	2026-02-11
113	113	1022	Cesárea	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Mario López Sic	paciente	t	2026-03-31
117	117	1025	Reducción de fractura	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Gabriela Pérez Tum	paciente	t	2026-04-24
121	121	1030	Prostatectomía	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Pedro Morales Chávez	paciente	t	2026-05-18
125	125	1006	Hernioplastia inguinal	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Verónica Hernández Paz	paciente	t	2026-06-11
129	129	1009	Mastectomía	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Ricardo Castillo Lima	paciente	t	2026-07-05
133	133	1045	Hernioplastia inguinal	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Julia Ramírez Ixcot	tutor	t	2026-07-29
137	137	1009	Mastectomía	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Fernando Gómez Pop	tutor	t	2026-08-22
141	141	1006	Hernioplastia inguinal	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Daniela Méndez Barrios	paciente	t	2026-09-15
102	102	1021	Colecistectomía laparoscópica	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Diego Tzul Chávez	paciente	t	2026-01-24
110	110	1027	Herniorrafia umbilical pediátrica	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Jorge Ajcá Lima	paciente	t	2026-03-13
114	114	1045	Apendicectomía abierta	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Paola Xicará Ixcot	paciente	t	2026-04-06
122	122	1050	Reducción de fractura	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Marta García Barrios	tutor	t	2026-05-24
126	126	1020	Reparación de tendones flexores de la mano	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Héctor López Chan	paciente	t	2026-06-17
134	134	1026	Amigdalectomía	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Rafael Morales Rojas	paciente	t	2026-08-04
138	138	1022	Cesárea	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Elena Hernández Soto	paciente	t	2026-08-28
103	103	1028	Rinoplastia reconstructiva	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Gabriela Vásquez Barrios	paciente	t	2026-01-30
107	107	1006	Hernioplastia inguinal	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Pedro Juárez Chan	tutor	t	2026-02-23
111	111	1045	Hernioplastia inguinal	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Verónica Sosa Ruiz	tutor	t	2026-03-19
115	115	1035	Hernioplastia inguinal	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Ricardo Tzul Rojas	paciente	t	2026-04-12
119	119	1007	Reemplazo de válvula aórtica	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Julia Coyoy Soto	paciente	t	2026-05-06
123	123	1050	Reducción de fractura	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Fernando Ajcá Sic	paciente	t	2026-05-30
131	131	1040	Herniorrafia umbilical pediátrica	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Óscar Batz Chávez	paciente	t	2026-07-17
135	135	1027	Herniorrafia umbilical pediátrica	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	María José García Paz	tutor	t	2026-08-10
139	139	1045	Hernioplastia inguinal	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Carlos López Lima	paciente	t	2026-09-03
143	143	1006	Hernioplastia inguinal	Tratar quirúrgicamente el padecimiento del paciente.	Procedimiento bajo la anestesia indicada en el agendamiento.	Sangrado, infección y complicaciones anestésicas.	t	Lucía Pérez Ixcot	paciente	t	2026-09-27
\.


--
-- Data for Name: consulta; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.consulta (id_consulta, id_cita, id_diagnostico, otros_datos, notas_observaciones) FROM stdin;
1	1	1	Seguimiento a estudio cardiológico de 2025.	Paciente estable; continuar tratamiento y control en 30 días.
2	5	2	Dolor abdominal en fosa ilíaca derecha de más de 6 horas.	Se solicita valoración quirúrgica de urgencia; requiere hospitalización.
101	101	7	\N	Primera consulta; se indica tratamiento y control.
102	102	8	\N	Primera consulta; se indica tratamiento y control.
103	103	9	\N	Reconsulta de seguimiento; evolución favorable.
104	104	10	\N	Primera consulta; se indica tratamiento y control.
106	106	12	\N	Reconsulta de seguimiento; evolución favorable.
107	107	13	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
108	108	14	\N	Primera consulta; se indica tratamiento y control.
109	109	15	\N	Reconsulta de seguimiento; evolución favorable.
111	111	17	\N	Primera consulta; se indica tratamiento y control.
112	112	18	\N	Reconsulta de seguimiento; evolución favorable.
113	113	19	\N	Primera consulta; se indica tratamiento y control.
114	114	1	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
116	116	3	\N	Primera consulta; se indica tratamiento y control.
117	117	4	\N	Primera consulta; se indica tratamiento y control.
118	118	5	\N	Reconsulta de seguimiento; evolución favorable.
119	119	6	\N	Primera consulta; se indica tratamiento y control.
121	121	8	\N	Reconsulta de seguimiento; evolución favorable.
122	122	9	\N	Primera consulta; se indica tratamiento y control.
123	123	10	\N	Primera consulta; se indica tratamiento y control.
124	124	11	\N	Reconsulta de seguimiento; evolución favorable.
126	126	13	\N	Primera consulta; se indica tratamiento y control.
127	127	14	\N	Reconsulta de seguimiento; evolución favorable.
128	128	15	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
129	129	16	\N	Primera consulta; se indica tratamiento y control.
131	131	18	\N	Primera consulta; se indica tratamiento y control.
132	132	19	\N	Primera consulta; se indica tratamiento y control.
133	133	1	\N	Reconsulta de seguimiento; evolución favorable.
134	134	2	\N	Primera consulta; se indica tratamiento y control.
136	136	4	\N	Reconsulta de seguimiento; evolución favorable.
137	137	5	\N	Primera consulta; se indica tratamiento y control.
138	138	6	\N	Primera consulta; se indica tratamiento y control.
139	139	7	\N	Reconsulta de seguimiento; evolución favorable.
141	141	9	\N	Primera consulta; se indica tratamiento y control.
142	142	10	\N	Reconsulta de seguimiento; evolución favorable.
143	143	11	\N	Primera consulta; se indica tratamiento y control.
144	144	12	\N	Primera consulta; se indica tratamiento y control.
146	146	14	\N	Primera consulta; se indica tratamiento y control.
147	147	15	\N	Primera consulta; se indica tratamiento y control.
148	148	16	\N	Reconsulta de seguimiento; evolución favorable.
149	149	17	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
151	151	19	\N	Reconsulta de seguimiento; evolución favorable.
152	152	1	\N	Primera consulta; se indica tratamiento y control.
153	153	2	\N	Primera consulta; se indica tratamiento y control.
154	154	3	\N	Reconsulta de seguimiento; evolución favorable.
156	156	5	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
157	157	6	\N	Reconsulta de seguimiento; evolución favorable.
158	158	7	\N	Primera consulta; se indica tratamiento y control.
159	159	8	\N	Primera consulta; se indica tratamiento y control.
161	161	10	\N	Primera consulta; se indica tratamiento y control.
162	162	11	\N	Primera consulta; se indica tratamiento y control.
163	163	12	\N	Reconsulta de seguimiento; evolución favorable.
164	164	13	\N	Primera consulta; se indica tratamiento y control.
166	166	15	\N	Reconsulta de seguimiento; evolución favorable.
167	167	16	\N	Primera consulta; se indica tratamiento y control.
168	168	17	\N	Primera consulta; se indica tratamiento y control.
169	169	18	\N	Reconsulta de seguimiento; evolución favorable.
171	171	1	\N	Primera consulta; se indica tratamiento y control.
172	172	2	\N	Reconsulta de seguimiento; evolución favorable.
173	173	3	\N	Primera consulta; se indica tratamiento y control.
174	174	4	\N	Primera consulta; se indica tratamiento y control.
176	176	6	\N	Primera consulta; se indica tratamiento y control.
177	177	7	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
178	178	8	\N	Reconsulta de seguimiento; evolución favorable.
179	179	9	\N	Primera consulta; se indica tratamiento y control.
181	181	11	\N	Reconsulta de seguimiento; evolución favorable.
182	182	12	\N	Primera consulta; se indica tratamiento y control.
183	183	13	\N	Primera consulta; se indica tratamiento y control.
184	184	14	\N	Reconsulta de seguimiento; evolución favorable.
186	186	16	\N	Primera consulta; se indica tratamiento y control.
187	187	17	\N	Reconsulta de seguimiento; evolución favorable.
188	188	18	\N	Primera consulta; se indica tratamiento y control.
189	189	19	\N	Primera consulta; se indica tratamiento y control.
191	191	2	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
192	192	3	\N	Primera consulta; se indica tratamiento y control.
193	193	4	\N	Reconsulta de seguimiento; evolución favorable.
194	194	5	\N	Primera consulta; se indica tratamiento y control.
196	196	7	\N	Reconsulta de seguimiento; evolución favorable.
197	197	8	\N	Primera consulta; se indica tratamiento y control.
198	198	9	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
199	199	10	\N	Reconsulta de seguimiento; evolución favorable.
201	201	12	\N	Primera consulta; se indica tratamiento y control.
202	202	13	\N	Reconsulta de seguimiento; evolución favorable.
203	203	14	\N	Primera consulta; se indica tratamiento y control.
204	204	15	\N	Primera consulta; se indica tratamiento y control.
206	206	17	\N	Primera consulta; se indica tratamiento y control.
207	207	18	\N	Primera consulta; se indica tratamiento y control.
208	208	19	\N	Reconsulta de seguimiento; evolución favorable.
209	209	1	\N	Primera consulta; se indica tratamiento y control.
211	211	3	\N	Reconsulta de seguimiento; evolución favorable.
212	212	4	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
213	213	5	\N	Primera consulta; se indica tratamiento y control.
214	214	6	\N	Reconsulta de seguimiento; evolución favorable.
216	216	8	\N	Primera consulta; se indica tratamiento y control.
217	217	9	\N	Reconsulta de seguimiento; evolución favorable.
218	218	10	\N	Primera consulta; se indica tratamiento y control.
219	219	11	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
221	221	13	\N	Primera consulta; se indica tratamiento y control.
222	222	14	\N	Primera consulta; se indica tratamiento y control.
223	223	15	\N	Reconsulta de seguimiento; evolución favorable.
224	224	16	\N	Primera consulta; se indica tratamiento y control.
226	226	18	\N	Reconsulta de seguimiento; evolución favorable.
227	227	19	\N	Primera consulta; se indica tratamiento y control.
228	228	1	\N	Primera consulta; se indica tratamiento y control.
229	229	2	\N	Reconsulta de seguimiento; evolución favorable.
231	231	4	\N	Primera consulta; se indica tratamiento y control.
232	232	5	\N	Reconsulta de seguimiento; evolución favorable.
233	233	6	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
234	234	7	\N	Primera consulta; se indica tratamiento y control.
236	236	9	\N	Primera consulta; se indica tratamiento y control.
237	237	10	\N	Primera consulta; se indica tratamiento y control.
238	238	11	\N	Reconsulta de seguimiento; evolución favorable.
239	239	12	\N	Primera consulta; se indica tratamiento y control.
241	241	14	\N	Reconsulta de seguimiento; evolución favorable.
242	242	15	\N	Primera consulta; se indica tratamiento y control.
243	243	16	\N	Primera consulta; se indica tratamiento y control.
244	244	17	\N	Reconsulta de seguimiento; evolución favorable.
246	246	19	\N	Primera consulta; se indica tratamiento y control.
247	247	1	\N	Reconsulta de seguimiento; evolución favorable.
248	248	2	\N	Primera consulta; se indica tratamiento y control.
249	249	3	\N	Primera consulta; se indica tratamiento y control.
251	251	5	\N	Primera consulta; se indica tratamiento y control.
252	252	6	\N	Primera consulta; se indica tratamiento y control.
253	253	7	\N	Reconsulta de seguimiento; evolución favorable.
254	254	8	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
256	256	10	\N	Reconsulta de seguimiento; evolución favorable.
257	257	11	\N	Primera consulta; se indica tratamiento y control.
258	258	12	\N	Primera consulta; se indica tratamiento y control.
259	259	13	\N	Reconsulta de seguimiento; evolución favorable.
261	261	15	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
262	262	16	\N	Reconsulta de seguimiento; evolución favorable.
263	263	17	\N	Primera consulta; se indica tratamiento y control.
264	264	18	\N	Primera consulta; se indica tratamiento y control.
266	266	1	\N	Primera consulta; se indica tratamiento y control.
267	267	2	\N	Primera consulta; se indica tratamiento y control.
268	268	3	\N	Reconsulta de seguimiento; evolución favorable.
269	269	4	\N	Primera consulta; se indica tratamiento y control.
271	271	6	\N	Reconsulta de seguimiento; evolución favorable.
272	272	7	\N	Primera consulta; se indica tratamiento y control.
273	273	8	\N	Primera consulta; se indica tratamiento y control.
274	274	9	\N	Reconsulta de seguimiento; evolución favorable.
276	276	11	\N	Primera consulta; se indica tratamiento y control.
277	277	12	\N	Reconsulta de seguimiento; evolución favorable.
278	278	13	\N	Primera consulta; se indica tratamiento y control.
279	279	14	\N	Primera consulta; se indica tratamiento y control.
281	281	16	\N	Primera consulta; se indica tratamiento y control.
282	282	17	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
283	283	18	\N	Reconsulta de seguimiento; evolución favorable.
284	284	19	\N	Primera consulta; se indica tratamiento y control.
286	286	2	\N	Reconsulta de seguimiento; evolución favorable.
287	287	3	\N	Primera consulta; se indica tratamiento y control.
288	288	4	\N	Primera consulta; se indica tratamiento y control.
289	289	5	\N	Reconsulta de seguimiento; evolución favorable.
291	291	7	\N	Primera consulta; se indica tratamiento y control.
292	292	8	\N	Reconsulta de seguimiento; evolución favorable.
293	293	9	\N	Primera consulta; se indica tratamiento y control.
294	294	10	\N	Primera consulta; se indica tratamiento y control.
296	296	12	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
297	297	13	\N	Primera consulta; se indica tratamiento y control.
298	298	14	\N	Reconsulta de seguimiento; evolución favorable.
299	299	15	\N	Primera consulta; se indica tratamiento y control.
301	301	17	\N	Reconsulta de seguimiento; evolución favorable.
302	302	18	\N	Primera consulta; se indica tratamiento y control.
303	303	19	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
304	304	1	\N	Reconsulta de seguimiento; evolución favorable.
306	306	3	\N	Primera consulta; se indica tratamiento y control.
307	307	4	\N	Reconsulta de seguimiento; evolución favorable.
308	308	5	\N	Primera consulta; se indica tratamiento y control.
309	309	6	\N	Primera consulta; se indica tratamiento y control.
311	311	8	\N	Primera consulta; se indica tratamiento y control.
312	312	9	\N	Primera consulta; se indica tratamiento y control.
313	313	10	\N	Reconsulta de seguimiento; evolución favorable.
314	314	11	\N	Primera consulta; se indica tratamiento y control.
316	316	13	\N	Reconsulta de seguimiento; evolución favorable.
317	317	14	Paciente referido por centro de salud.	Primera consulta; se indica tratamiento y control.
318	318	15	\N	Primera consulta; se indica tratamiento y control.
319	319	16	\N	Reconsulta de seguimiento; evolución favorable.
\.


--
-- Data for Name: departamento; Type: TABLE DATA; Schema: public; Owner: admin
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
-- Data for Name: diagnostico; Type: TABLE DATA; Schema: public; Owner: admin
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
12	J06.9	Infección aguda de las vías respiratorias superiores, no especificada
13	K29.7	Gastritis, no especificada
14	M54.5	Lumbago no especificado
15	L20.9	Dermatitis atópica, no especificada
16	H10.9	Conjuntivitis, no especificada
17	F41.1	Trastorno de ansiedad generalizada
18	Z00.0	Examen médico general
19	N39.0	Infección de vías urinarias, sitio no especificado
\.


--
-- Data for Name: documentacion_etapa; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.documentacion_etapa (id_cirugia, etapa, id_enfermero, fecha_envio) FROM stdin;
1	preoperatorio	2001	2026-08-12
1	intraoperatorio	2002	2026-08-12
1	postoperatorio	2003	2026-08-12
101	preoperatorio	2004	2026-01-21
101	intraoperatorio	2004	2026-01-21
101	postoperatorio	2004	2026-01-21
102	preoperatorio	2008	2026-01-28
102	intraoperatorio	2008	2026-01-28
102	postoperatorio	2008	2026-01-28
103	preoperatorio	2012	2026-02-04
103	intraoperatorio	2012	2026-02-04
103	postoperatorio	2012	2026-02-04
104	preoperatorio	2011	2026-02-07
104	intraoperatorio	2011	2026-02-07
104	postoperatorio	2011	2026-02-07
105	preoperatorio	2001	2026-02-14
105	intraoperatorio	2001	2026-02-14
105	postoperatorio	2001	2026-02-14
107	preoperatorio	2003	2026-02-28
107	intraoperatorio	2003	2026-02-28
107	postoperatorio	2003	2026-02-28
108	preoperatorio	2014	2026-03-03
108	intraoperatorio	2014	2026-03-03
108	postoperatorio	2014	2026-03-03
110	preoperatorio	2008	2026-03-17
110	intraoperatorio	2008	2026-03-17
110	postoperatorio	2008	2026-03-17
111	preoperatorio	2015	2026-03-24
111	intraoperatorio	2015	2026-03-24
111	postoperatorio	2015	2026-03-24
113	preoperatorio	2012	2026-04-03
113	intraoperatorio	2012	2026-04-03
113	postoperatorio	2012	2026-04-03
114	preoperatorio	2014	2026-04-10
114	intraoperatorio	2014	2026-04-10
114	postoperatorio	2014	2026-04-10
115	preoperatorio	2009	2026-04-17
115	intraoperatorio	2009	2026-04-17
115	postoperatorio	2009	2026-04-17
116	preoperatorio	2005	2026-04-20
116	intraoperatorio	2005	2026-04-20
116	postoperatorio	2005	2026-04-20
117	preoperatorio	2012	2026-04-27
117	intraoperatorio	2012	2026-04-27
117	postoperatorio	2012	2026-04-27
119	preoperatorio	2009	2026-05-11
119	intraoperatorio	2009	2026-05-11
119	postoperatorio	2009	2026-05-11
120	preoperatorio	2002	2026-05-14
120	intraoperatorio	2002	2026-05-14
120	postoperatorio	2002	2026-05-14
121	preoperatorio	2009	2026-05-21
121	intraoperatorio	2009	2026-05-21
121	postoperatorio	2009	2026-05-21
122	preoperatorio	2017	2026-05-28
122	intraoperatorio	2017	2026-05-28
122	postoperatorio	2017	2026-05-28
123	preoperatorio	2018	2026-06-04
123	intraoperatorio	2018	2026-06-04
123	postoperatorio	2018	2026-06-04
125	preoperatorio	2007	2026-06-14
125	intraoperatorio	2007	2026-06-14
125	postoperatorio	2007	2026-06-14
126	preoperatorio	2001	2026-06-21
126	intraoperatorio	2001	2026-06-21
126	postoperatorio	2001	2026-06-21
128	preoperatorio	2011	2026-07-01
128	intraoperatorio	2011	2026-07-01
128	postoperatorio	2011	2026-07-01
129	preoperatorio	2012	2026-07-08
129	intraoperatorio	2012	2026-07-08
129	postoperatorio	2012	2026-07-08
131	preoperatorio	2012	2026-07-22
131	intraoperatorio	2012	2026-07-22
131	postoperatorio	2012	2026-07-22
132	preoperatorio	2007	2026-07-25
132	intraoperatorio	2007	2026-07-25
132	postoperatorio	2007	2026-07-25
133	preoperatorio	2015	2026-08-01
133	intraoperatorio	2015	2026-08-01
133	postoperatorio	2015	2026-08-01
134	preoperatorio	2002	2026-08-08
134	intraoperatorio	2002	2026-08-08
134	postoperatorio	2002	2026-08-08
135	preoperatorio	2009	2026-08-15
135	intraoperatorio	2009	2026-08-15
135	postoperatorio	2009	2026-08-15
137	preoperatorio	2012	2026-08-25
137	intraoperatorio	2012	2026-08-25
137	postoperatorio	2012	2026-08-25
138	preoperatorio	2011	2026-09-01
138	intraoperatorio	2011	2026-09-01
138	postoperatorio	2011	2026-09-01
139	preoperatorio	2015	2026-09-08
139	intraoperatorio	2015	2026-09-08
139	postoperatorio	2015	2026-09-08
140	preoperatorio	2008	2026-09-11
140	intraoperatorio	2008	2026-09-11
140	postoperatorio	2008	2026-09-11
141	preoperatorio	2002	2026-09-18
141	intraoperatorio	2002	2026-09-18
141	postoperatorio	2002	2026-09-18
143	preoperatorio	2004	2026-10-02
143	intraoperatorio	2004	2026-10-02
143	postoperatorio	2004	2026-10-02
144	preoperatorio	2008	2026-10-05
144	intraoperatorio	2008	2026-10-05
144	postoperatorio	2008	2026-10-05
\.


--
-- Data for Name: egreso; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.egreso (id_egreso, id_ingreso, id_medico, id_diagnostico_principal, fecha_hora_egreso, motivo_egreso, codigo_egreso, sin_consentimiento, motivo_sin_consentimiento, codigo_traslado, referido_otro_hospital) FROM stdin;
1	1	1001	3	2026-08-12 10:00:00-06	Mejoría clínica.	vivo	f	\N	\N	f
2	3	1005	1	2026-08-18 09:30:00-06	Estabilización y mejoría.	vivo	f	\N	\N	f
3	5	1006	2	2026-08-14 11:30:00-06	Recuperación satisfactoria sin complicaciones.	vivo	f	\N	\N	f
1001	1001	1035	6	2026-01-27 00:37:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1002	1002	1036	11	2026-02-16 14:14:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1003	1003	1042	16	2026-03-10 03:51:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1004	1004	1047	2	2026-03-30 17:28:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1005	1005	1006	7	2026-04-21 07:05:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1006	1006	1032	12	2026-05-11 20:42:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1008	1008	1041	3	2026-06-22 23:56:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1009	1009	1048	8	2026-07-14 13:33:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1010	1010	1001	13	2026-08-04 03:10:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1011	1011	1035	18	2026-08-25 16:47:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1012	1012	1036	4	2026-09-15 06:24:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1013	1013	1046	9	2026-10-06 20:01:00-06	Mejoría clínica.	vivo	t	El paciente decidió retirarse antes del alta.	\N	f
1015	1015	1005	19	2026-02-05 23:15:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1016	1016	1031	5	2026-02-26 12:52:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1017	1017	1037	10	2026-03-20 02:29:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1018	1018	1041	15	2026-04-09 16:06:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1019	1019	1048	1	2026-04-30 18:03:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1020	1020	1001	6	2026-05-21 07:40:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1022	1022	1036	16	2026-07-02 10:54:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1023	1023	1046	2	2026-07-24 00:31:00-06	Fallecimiento.	muerto	f	\N	\N	f
1024	1024	1047	7	2026-08-13 14:08:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1025	1025	1005	12	2026-09-04 03:45:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1026	1026	1031	17	2026-09-24 17:22:00-06	Mejoría clínica.	vivo	t	El paciente decidió retirarse antes del alta.	\N	f
1027	1027	1037	3	2026-10-16 06:59:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1029	1029	1048	13	2026-02-15 10:13:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1030	1030	1001	18	2026-03-07 23:50:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1031	1031	1032	4	2026-03-29 13:27:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1032	1032	1036	9	2026-04-19 03:04:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1033	1033	1046	14	2026-05-10 16:41:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1034	1034	1047	19	2026-05-31 06:18:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1036	1036	1031	10	2026-07-12 09:32:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1037	1037	1037	15	2026-08-02 23:09:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1038	1038	1041	1	2026-08-23 01:06:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1039	1039	1048	6	2026-09-13 14:43:00-06	Mejoría clínica.	vivo	t	El paciente decidió retirarse antes del alta.	\N	f
1040	1040	1005	11	2026-10-02 12:20:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1041	1041	1032	16	2026-01-12 01:57:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1043	1043	1042	7	2026-02-23 05:11:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1044	1044	1047	12	2026-03-15 18:48:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1045	1045	1006	17	2026-04-06 08:25:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1046	1046	1031	3	2026-04-26 22:02:00-06	Fallecimiento.	muerto	f	\N	\N	f
1047	1047	1037	8	2026-05-18 11:39:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1048	1048	1041	13	2026-06-08 01:16:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1050	1050	1001	4	2026-07-20 04:30:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1051	1051	1035	9	2026-08-10 18:07:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1052	1052	1036	14	2026-08-31 07:44:00-06	Mejoría clínica.	vivo	t	El paciente decidió retirarse antes del alta.	\N	f
1053	1053	1042	19	2026-09-21 21:21:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1054	1054	1047	5	2026-10-12 10:58:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1055	1055	1006	10	2026-01-22 00:35:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1057	1057	1037	1	2026-03-04 16:09:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1058	1058	1041	6	2026-03-25 05:46:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1059	1059	1048	11	2026-04-15 19:23:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1060	1060	1001	16	2026-05-06 09:00:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1061	1061	1035	2	2026-05-27 22:37:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1062	1062	1036	7	2026-06-17 12:14:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1064	1064	1047	17	2026-07-29 15:28:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1065	1065	1005	3	2026-08-20 05:05:00-06	Mejoría clínica.	vivo	t	El paciente decidió retirarse antes del alta.	\N	f
1066	1066	1031	8	2026-09-09 18:42:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1067	1067	1037	13	2026-10-01 08:19:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1068	1068	1041	18	2026-01-09 21:56:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1069	1069	1048	4	2026-01-31 11:33:00-06	Fallecimiento.	muerto	f	\N	\N	f
1071	1071	1032	14	2026-03-14 14:47:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1072	1072	1036	19	2026-04-04 04:24:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1073	1073	1046	5	2026-04-25 18:01:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1074	1074	1047	10	2026-05-16 07:38:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1075	1075	1005	15	2026-06-06 21:15:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1076	1076	1031	1	2026-06-26 23:12:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1078	1078	1041	11	2026-08-08 02:26:00-06	Mejoría clínica.	vivo	t	El paciente decidió retirarse antes del alta.	\N	f
1079	1079	1048	16	2026-08-29 16:03:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1080	1080	1001	2	2026-09-17 13:40:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1081	1081	1032	7	2026-10-09 03:17:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1082	1082	1036	12	2026-01-17 16:54:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1083	1083	1046	17	2026-02-08 06:31:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1085	1085	1006	8	2026-03-22 09:45:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1086	1086	1031	13	2026-04-11 23:22:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1087	1087	1037	18	2026-05-03 12:59:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1088	1088	1041	4	2026-05-24 02:36:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1089	1089	1048	9	2026-06-14 16:13:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1090	1090	1005	14	2026-07-05 05:50:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1092	1092	1036	5	2026-08-16 09:04:00-06	Fallecimiento.	muerto	f	\N	\N	f
1093	1093	1042	10	2026-09-06 22:41:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1094	1094	1047	15	2026-09-27 12:18:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1095	1095	1006	1	2026-01-06 14:15:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1096	1096	1031	6	2026-01-27 03:52:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1097	1097	1037	11	2026-02-17 17:29:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1099	1099	1048	2	2026-03-31 20:43:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1100	1100	1001	7	2026-04-21 10:20:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1101	1101	1035	12	2026-05-12 23:57:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1102	1102	1036	17	2026-06-02 13:34:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1103	1103	1042	3	2026-06-24 03:11:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1104	1104	1047	8	2026-07-14 16:48:00-06	Mejoría clínica.	vivo	t	El paciente decidió retirarse antes del alta.	\N	f
1106	1106	1031	18	2026-08-25 20:02:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1107	1107	1037	4	2026-09-16 09:39:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1108	1108	1041	9	2026-10-06 23:16:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1109	1109	1048	14	2026-01-16 12:53:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1110	1110	1001	19	2026-02-06 02:30:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1111	1111	1035	5	2026-02-27 16:07:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1113	1113	1046	15	2026-04-10 19:21:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1114	1114	1047	1	2026-04-30 21:18:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1115	1115	1005	6	2026-05-22 10:55:00-06	Fallecimiento.	muerto	f	\N	\N	f
1116	1116	1031	11	2026-06-12 00:32:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1117	1117	1037	16	2026-07-03 14:09:00-06	Traslado a hospitalización.	vivo	t	El paciente decidió retirarse antes del alta.	\N	f
1118	1118	1042	2	2026-07-24 03:46:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1120	1120	1001	12	2026-09-02 15:00:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1121	1121	1032	17	2026-09-24 04:37:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1122	1122	1036	3	2026-10-14 18:14:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1123	1123	1046	8	2026-01-24 07:51:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1124	1124	1047	13	2026-02-13 21:28:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1125	1125	1005	18	2026-03-07 11:05:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1127	1127	1037	9	2026-04-18 14:19:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1128	1128	1041	14	2026-05-09 03:56:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1129	1129	1048	19	2026-05-30 17:33:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1130	1130	1001	5	2026-06-20 07:10:00-06	Mejoría clínica.	vivo	t	El paciente decidió retirarse antes del alta.	\N	f
1131	1131	1032	10	2026-07-11 20:47:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1132	1132	1036	15	2026-08-01 10:24:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1134	1134	1047	6	2026-09-12 01:58:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1135	1135	1006	11	2026-10-03 15:35:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1136	1136	1031	16	2026-01-12 05:12:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1137	1137	1037	2	2026-02-02 18:49:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1138	1138	1041	7	2026-02-23 08:26:00-06	Fallecimiento.	muerto	f	\N	\N	f
1139	1139	1048	12	2026-03-16 22:03:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1141	1141	1035	3	2026-04-28 01:17:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1142	1142	1036	8	2026-05-18 14:54:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1143	1143	1042	13	2026-06-09 04:31:00-06	Mejoría clínica.	vivo	t	El paciente decidió retirarse antes del alta.	\N	f
1144	1144	1047	18	2026-06-29 18:08:00-06	Traslado a hospitalización.	vivo	f	\N	\N	f
1145	1145	1006	4	2026-07-21 07:45:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1146	1146	1032	9	2026-08-10 21:22:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1148	1148	1041	19	2026-09-22 00:36:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1149	1149	1048	5	2026-10-13 14:13:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1150	1150	1001	10	2026-01-22 03:50:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1151	1151	1001	3	2026-06-14 02:10:00-06	Fallecimiento.	muerto	f	\N	\N	f
1152	1152	1005	3	2026-06-14 05:45:00-06	Fallecimiento.	muerto	f	\N	\N	f
1153	1153	1001	3	2026-06-15 10:00:00-06	Mejoría clínica.	vivo	f	\N	\N	f
1154	1154	1031	3	2026-03-21 14:30:00-06	Fallecimiento.	muerto	f	\N	\N	f
1155	1155	1031	3	2026-03-21 18:05:00-06	Fallecimiento.	muerto	f	\N	\N	f
2001	2001	1042	11	2026-01-15 13:00:00-06	Alta médica.	vivo	f	\N	\N	f
2002	2002	1019	2	2026-01-21 14:00:00-06	Alta médica.	vivo	f	\N	\N	f
2003	2003	1050	5	2026-01-27 15:00:00-06	Alta médica.	vivo	f	\N	\N	f
2004	2004	1038	19	2026-02-02 16:00:00-06	Alta médica.	vivo	f	\N	\N	f
2005	2005	1006	10	2026-02-08 17:00:00-06	Alta médica.	vivo	f	\N	\N	f
2006	2006	1041	11	2026-02-14 18:00:00-06	Alta médica.	vivo	f	\N	\N	f
2007	2007	1035	2	2026-02-20 19:00:00-06	Alta médica.	vivo	f	\N	\N	f
2009	2009	1036	19	2026-02-23 13:00:00-06	Alta médica.	vivo	f	\N	\N	f
2010	2010	1015	10	2026-03-01 14:00:00-06	Alta médica.	vivo	f	\N	\N	f
2011	2011	1046	11	2026-03-07 15:00:00-06	Alta médica.	vivo	f	\N	\N	f
2012	2012	1032	2	2026-03-13 16:00:00-06	Alta médica.	vivo	f	\N	\N	f
2013	2013	1050	5	2026-03-19 17:00:00-06	Alta médica.	vivo	f	\N	\N	f
2014	2014	1009	19	2026-03-25 18:00:00-06	Alta médica.	vivo	f	\N	\N	f
2015	2015	1003	10	2026-03-31 19:00:00-06	Alta médica.	vivo	f	\N	\N	f
2017	2017	1014	2	2026-04-12 13:00:00-06	Alta médica.	vivo	f	\N	\N	f
2018	2018	1050	5	2026-04-09 14:00:00-06	Alta médica.	vivo	f	\N	\N	f
2019	2019	1039	19	2026-04-15 15:00:00-06	Fallecimiento.	muerto	f	\N	\N	f
2020	2020	1010	10	2026-04-21 16:00:00-06	Alta médica.	vivo	f	\N	\N	f
2021	2021	1044	11	2026-04-27 17:00:00-06	Alta médica.	vivo	f	\N	\N	f
2022	2022	1034	2	2026-05-03 18:00:00-06	Alta médica.	vivo	f	\N	\N	f
2023	2023	1050	5	2026-05-09 19:00:00-06	Alta médica.	vivo	f	\N	\N	f
2025	2025	1018	10	2026-05-21 13:00:00-06	Alta médica.	vivo	f	\N	\N	f
2026	2026	1043	11	2026-05-27 14:00:00-06	Alta médica.	vivo	f	\N	\N	f
2027	2027	1031	2	2026-05-24 15:00:00-06	Alta médica.	vivo	f	\N	\N	f
2028	2028	1050	5	2026-05-30 16:00:00-06	Alta médica.	vivo	f	\N	\N	f
2029	2029	1016	19	2026-06-05 17:00:00-06	Alta médica.	vivo	f	\N	\N	f
2030	2030	1005	10	2026-06-11 18:00:00-06	Alta médica.	vivo	f	\N	\N	f
2031	2031	1042	11	2026-06-17 19:00:00-06	Alta médica.	vivo	f	\N	\N	f
2033	2033	1050	5	2026-06-29 13:00:00-06	Alta médica.	vivo	f	\N	\N	f
2034	2034	1040	19	2026-07-05 14:00:00-06	Alta médica.	vivo	f	\N	\N	f
2035	2035	1013	10	2026-07-11 15:00:00-06	Alta médica.	vivo	f	\N	\N	f
2036	2036	1041	11	2026-07-08 16:00:00-06	Alta médica.	vivo	f	\N	\N	f
2037	2037	1033	2	2026-07-14 17:00:00-06	Alta médica.	vivo	f	\N	\N	f
2038	2038	1050	5	2026-07-20 18:00:00-06	Fallecimiento.	muerto	f	\N	\N	f
2039	2039	1038	19	2026-07-26 19:00:00-06	Alta médica.	vivo	f	\N	\N	f
2041	2041	1046	11	2026-08-07 13:00:00-06	Alta médica.	vivo	f	\N	\N	f
2042	2042	1019	2	2026-08-13 14:00:00-06	Alta médica.	vivo	f	\N	\N	f
2043	2043	1050	5	2026-08-19 15:00:00-06	Alta médica.	vivo	f	\N	\N	f
2044	2044	1036	19	2026-08-25 16:00:00-06	Alta médica.	vivo	f	\N	\N	f
2045	2045	1008	10	2026-08-22 17:00:00-06	Alta médica.	vivo	f	\N	\N	f
2046	2046	1045	11	2026-08-28 18:00:00-06	Alta médica.	vivo	f	\N	\N	f
2047	2047	1035	2	2026-09-03 19:00:00-06	Alta médica.	vivo	f	\N	\N	f
2049	2049	1009	19	2026-09-15 13:00:00-06	Alta médica.	vivo	f	\N	\N	f
2050	2050	1017	10	2026-09-21 14:00:00-06	Alta médica.	vivo	f	\N	\N	f
2051	2051	1044	11	2026-09-27 15:00:00-06	Alta médica.	vivo	f	\N	\N	f
2052	2052	1032	2	2026-10-03 16:00:00-06	Alta médica.	vivo	f	\N	\N	f
2053	2053	1050	5	2026-10-09 17:00:00-06	Alta médica.	vivo	f	\N	\N	f
2054	2054	1039	19	2026-10-06 18:00:00-06	Alta médica.	vivo	f	\N	\N	f
2055	2055	1004	10	2026-10-12 19:00:00-06	Alta médica.	vivo	f	\N	\N	f
2057	2057	1014	2	2026-01-17 13:00:00-06	Fallecimiento.	muerto	f	\N	\N	f
2058	2058	1050	5	2026-01-23 14:00:00-06	Alta médica.	vivo	f	\N	\N	f
2059	2059	1037	19	2026-01-29 15:00:00-06	Alta médica.	vivo	f	\N	\N	f
2060	2060	1011	10	2026-02-04 16:00:00-06	Alta médica.	vivo	f	\N	\N	f
3001	3001	1020	2	2026-01-20 16:33:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3002	3002	1021	2	2026-01-27 16:56:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3003	3003	1028	2	2026-02-03 17:19:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3004	3004	1009	2	2026-02-06 17:42:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3005	3005	1023	2	2026-02-13 17:15:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3007	3007	1006	2	2026-02-27 18:01:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3008	3008	1045	2	2026-03-02 18:24:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3010	3010	1027	2	2026-03-16 18:20:00-06	Fallecimiento en sala de operaciones.	muerto	f	\N	\N	f
3011	3011	1045	2	2026-03-23 18:43:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3013	3013	1022	2	2026-04-02 16:59:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3014	3014	1045	2	2026-04-09 17:22:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3015	3015	1035	2	2026-04-16 16:55:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3016	3016	1006	2	2026-04-19 17:18:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3017	3017	1025	2	2026-04-26 17:41:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3019	3019	1007	2	2026-05-10 18:27:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3020	3020	1029	2	2026-05-13 18:00:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3021	3021	1030	2	2026-05-20 18:23:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3022	3022	1050	2	2026-05-27 18:46:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3023	3023	1050	2	2026-06-03 19:09:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3025	3025	1006	2	2026-06-13 16:35:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3026	3026	1020	2	2026-06-20 16:58:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3028	3028	1028	2	2026-06-30 17:44:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3029	3029	1009	2	2026-07-07 18:07:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3031	3031	1040	2	2026-07-21 18:03:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3032	3032	1006	2	2026-07-24 18:26:00-06	Fallecimiento en sala de operaciones.	muerto	f	\N	\N	f
3033	3033	1045	2	2026-07-31 18:49:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3034	3034	1026	2	2026-08-07 19:12:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3035	3035	1027	2	2026-08-14 16:15:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3037	3037	1009	2	2026-08-24 17:01:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3038	3038	1022	2	2026-08-31 17:24:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3039	3039	1045	2	2026-09-07 17:47:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3040	3040	1035	2	2026-09-10 17:20:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3041	3041	1006	2	2026-09-17 17:43:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3043	3043	1006	2	2026-10-01 18:29:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
3044	3044	1007	2	2026-10-04 18:52:00-06	Traslado a sala de recuperación.	vivo	f	\N	\N	f
\.


--
-- Data for Name: egreso_diagnostico; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.egreso_diagnostico (id_egreso, id_diagnostico) FROM stdin;
1	5
1	4
1005	14
1010	10
1015	6
1020	2
1025	17
1030	13
1040	5
1045	1
1050	16
1055	12
1060	8
1065	4
1080	11
1085	7
1090	3
1095	18
1100	14
1110	6
1115	2
1120	17
1125	13
1130	9
1135	5
1145	16
1150	12
1155	8
2005	12
2010	8
2015	4
2020	19
2025	15
2030	11
2035	7
2045	18
2050	14
2060	6
\.


--
-- Data for Name: encargado; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.encargado (id_encargado, nombres, apellidos, dpi, telefono, id_municipio, area) FROM stdin;
301	Isabel	Cruz López	8881123450101	5551-3001	1	Urbana
302	Roberto	Méndez Rodríguez	8881123450102	5551-3002	1	Urbana
303	Karla	Paz Veliz	8881123450103	5551-3003	6	Urbana
304	Elsa	Ruiz Rojas	4200000000004	5614-2164	11	Rural
305	Pedro	Castillo García	4200000000005	5615-2205	1	Urbana
306	Olga	Lima Tzul	4200000000006	5616-2246	6	Urbana
307	Mynor	Coyoy Paz	4200000000007	5617-2287	8	Urbana
308	Silvia	Sosa Chan	4200000000008	5618-2328	9	Rural
309	Erick	Fuentes Rojas	4200000000009	5619-2369	11	Urbana
310	Marta	Pérez García	4200000000010	5620-2410	1	Urbana
311	Juan	Batz Tzul	4200000000011	5621-2451	6	Urbana
312	Lidia	Ixcot Paz	4200000000012	5622-2492	8	Rural
313	Rodrigo	Morales Chan	4200000000013	5623-2533	9	Urbana
314	Elsa	Ruiz Rojas	4200000000014	5624-2574	11	Urbana
315	Pedro	Castillo García	4200000000015	5625-2615	1	Urbana
316	Olga	Lima Tzul	4200000000016	5626-2656	6	Rural
317	Mynor	Coyoy Paz	4200000000017	5627-2697	8	Urbana
318	Silvia	Sosa Chan	4200000000018	5628-2738	9	Urbana
319	Erick	Fuentes Rojas	4200000000019	5629-2779	11	Urbana
320	Marta	Pérez García	4200000000020	5630-2820	1	Rural
321	Juan	Batz Tzul	4200000000021	5631-2861	6	Urbana
322	Lidia	Ixcot Paz	4200000000022	5632-2902	8	Urbana
323	Rodrigo	Morales Chan	4200000000023	5633-2943	9	Urbana
\.


--
-- Data for Name: enfermero; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.enfermero (id_enfermero, nombres, apellidos, dpi, telefono, id_hospital, tipo, tipo_personal) FROM stdin;
2001	Luis	Hernández Solís	2001123450201	5552-2001	1	registrado	enfermero
2002	Marta	Recinos Alvarado	2001123450202	5552-2002	1	registrado	enfermero
2003	Carlos	García Méndez	2001123450203	5552-2003	1	practicante	enfermero
2004	Ana	López Pérez	2001123450204	5552-2004	1	registrado	enfermero
2005	Pedro	Ramírez Soto	2001123450205	5552-2005	1	registrado	enfermero
2006	Rosa	Xicará Pop	2001123450206	5552-2006	1	registrado	enfermero
2007	Julio	Chay Tum	2001123450207	5552-2007	1	practicante	enfermero
2008	Mirna	Ochoa Bravo	2001123450208	5552-2008	2	registrado	enfermero
2009	Wilson	Escobar Ruiz	2001123450209	5552-2009	2	registrado	enfermero
2010	Yesenia	Cardona Aguilar	2001123450210	5552-2010	2	practicante	enfermero
2011	Ronaldo	Pineda Sosa	2001123450211	5552-2011	3	registrado	enfermero
2012	Ingrid	Toc Chan	2001123450212	5552-2012	3	registrado	enfermero
2013	Elmer	Yac Sontay	2001123450213	5552-2013	3	practicante	enfermero
2014	Dora	Matías Gaspar	2001123450214	5552-2014	4	registrado	enfermero
2015	Fredy	Mendoza Hidalgo	2001123450215	5552-2015	4	registrado	enfermero
2016	Sonia	Jiménez Sales	2001123450216	5552-2016	4	practicante	enfermero
2017	Pablo	Sicajau Tzep	2001123450217	5552-2017	5	registrado	enfermero
2018	Claudia	Batz Sequén	2001123450218	5552-2018	5	registrado	enfermero
2019	Edwin	Coj Lacán	2001123450219	5552-2019	5	practicante	enfermero
2020	Vilma	Ixcoy Boj	2001123450220	5552-2020	1	registrado	enfermero
\.


--
-- Data for Name: equipo; Type: TABLE DATA; Schema: public; Owner: admin
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
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: admin
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
-- Data for Name: estado_civil; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.estado_civil (id_estado_civil, nombre) FROM stdin;
1	Soltero(a)
2	Casado(a)
3	Unido(a)
4	Divorciado(a)
5	Viudo(a)
\.


--
-- Data for Name: factura; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.factura (id_factura, id_cita, id_ingreso, id_cirugia, fecha_emision, descripcion, total, numero_cuotas) FROM stdin;
1	1	\N	\N	2026-08-10 11:30:00-06	Consulta de cardiología; reconsulta (75%).	165.00	1
2	\N	1	\N	2026-08-12 10:30:00-06	Atención de emergencia por politraumatismo.	1800.00	3
3	\N	3	\N	2026-08-18 09:45:00-06	Hospitalización 4 días: medicina interna + insumos médicos.	4390.00	4
4	\N	\N	1	2026-08-12 08:00:00-06	Cirugía: apendicectomía (cirugía general) + insumos utilizados.	9235.00	6
5	\N	5	\N	2026-08-14 12:00:00-06	Hospitalización postoperatoria: 3 días en cuidados intermedios + insumos.	3870.00	3
6	101	\N	\N	2026-01-18 09:30:00-06	Consulta externa de dermatología.	180.00	1
7	102	\N	\N	2026-01-31 10:00:00-06	Consulta externa de odontología general.	130.00	1
8	103	\N	\N	2026-02-13 10:30:00-06	Consulta externa de medicina general.	127.50	1
9	104	\N	\N	2026-02-26 11:00:00-06	Consulta externa de medicina general.	150.00	1
10	106	\N	\N	2026-03-24 10:30:00-06	Consulta externa de psicología.	120.00	1
11	107	\N	\N	2026-04-06 10:00:00-06	Consulta externa de medicina general.	144.00	1
12	108	\N	\N	2026-04-19 10:30:00-06	Consulta externa de nutrición y dietética.	150.00	1
13	109	\N	\N	2026-05-02 11:00:00-06	Consulta externa de urología.	142.50	1
14	111	\N	\N	2026-05-28 09:30:00-06	Consulta externa de medicina general.	150.00	1
15	112	\N	\N	2026-06-10 10:00:00-06	Consulta externa de pediatría.	150.00	1
16	113	\N	\N	2026-06-23 10:30:00-06	Consulta externa de pediatría.	180.00	1
17	114	\N	\N	2026-07-06 12:00:00-06	Consulta externa de medicina física y rehabilitación.	140.00	1
18	116	\N	\N	2026-08-01 09:30:00-06	Consulta externa de pediatría.	190.00	1
19	117	\N	\N	2026-08-14 10:00:00-06	Consulta externa de medicina general.	160.00	1
20	118	\N	\N	2026-08-27 10:30:00-06	Consulta externa de medicina general.	108.75	1
21	119	\N	\N	2026-09-09 12:00:00-06	Consulta externa de fisioterapia.	160.00	1
22	121	\N	\N	2026-10-05 10:30:00-06	Consulta externa de psicología.	123.75	1
23	122	\N	\N	2026-10-18 10:00:00-06	Consulta externa de cardiología.	230.00	1
24	123	\N	\N	2026-01-14 11:30:00-06	Consulta externa de dermatología.	175.00	1
25	124	\N	\N	2026-01-27 11:00:00-06	Consulta externa de medicina general.	112.50	1
26	126	\N	\N	2026-02-22 10:30:00-06	Consulta externa de ginecología oncológica.	210.00	1
27	127	\N	\N	2026-03-07 10:00:00-06	Consulta externa de oftalmología.	138.75	1
28	128	\N	\N	2026-03-20 10:30:00-06	Consulta externa de medicina general.	128.00	1
29	129	\N	\N	2026-04-02 11:00:00-06	Consulta externa de pediatría.	210.00	1
30	131	\N	\N	2026-04-28 09:30:00-06	Consulta externa de medicina general.	200.00	1
31	132	\N	\N	2026-05-11 10:00:00-06	Consulta externa de dermatología.	180.00	1
32	133	\N	\N	2026-05-24 10:30:00-06	Consulta externa de odontología general.	97.50	1
33	134	\N	\N	2026-06-06 11:00:00-06	Consulta externa de medicina general.	170.00	1
34	136	\N	\N	2026-07-02 09:30:00-06	Consulta externa de cardiología.	161.25	1
35	137	\N	\N	2026-07-15 11:00:00-06	Consulta externa de psicología.	160.00	1
36	138	\N	\N	2026-07-28 10:30:00-06	Consulta externa de medicina general.	180.00	1
37	139	\N	\N	2026-08-10 11:00:00-06	Consulta externa de nutrición y dietética.	112.50	1
38	141	\N	\N	2026-09-05 09:30:00-06	Consulta externa de medicina general.	165.00	1
39	142	\N	\N	2026-09-18 10:00:00-06	Consulta externa de medicina general.	112.50	1
40	143	\N	\N	2026-10-01 10:30:00-06	Consulta externa de pediatría.	200.00	1
41	144	\N	\N	2026-10-14 11:00:00-06	Consulta externa de pediatría.	180.00	1
42	146	\N	\N	2026-01-23 09:30:00-06	Consulta externa de terapia del lenguaje.	140.00	1
43	147	\N	\N	2026-02-05 10:00:00-06	Consulta externa de pediatría.	190.00	1
44	148	\N	\N	2026-02-18 10:30:00-06	Consulta externa de medicina general.	120.00	1
45	149	\N	\N	2026-03-03 11:00:00-06	Consulta externa de medicina general.	116.00	1
46	151	\N	\N	2026-03-29 09:30:00-06	Consulta externa de hematología.	146.25	1
47	152	\N	\N	2026-04-11 11:00:00-06	Consulta externa de psicología.	165.00	1
48	153	\N	\N	2026-04-24 10:30:00-06	Consulta externa de cardiología.	230.00	1
49	154	\N	\N	2026-05-07 12:00:00-06	Consulta externa de dermatología.	131.25	1
50	156	\N	\N	2026-06-02 09:30:00-06	Consulta externa de cardiología.	176.00	1
51	157	\N	\N	2026-06-15 11:00:00-06	Consulta externa de ginecología oncológica.	157.50	1
52	158	\N	\N	2026-06-28 10:30:00-06	Consulta externa de oftalmología.	185.00	1
53	159	\N	\N	2026-07-11 11:00:00-06	Consulta externa de medicina general.	160.00	1
54	161	\N	\N	2026-08-06 10:30:00-06	Consulta externa de ginecología oncológica.	205.00	1
55	162	\N	\N	2026-08-19 10:00:00-06	Consulta externa de medicina general.	200.00	1
56	163	\N	\N	2026-09-01 10:30:00-06	Consulta externa de dermatología.	135.00	1
57	164	\N	\N	2026-09-14 11:00:00-06	Consulta externa de odontología general.	130.00	1
58	166	\N	\N	2026-10-10 09:30:00-06	Consulta externa de medicina general.	112.50	1
59	167	\N	\N	2026-01-06 10:00:00-06	Consulta externa de cardiología.	215.00	1
60	168	\N	\N	2026-01-19 11:30:00-06	Consulta externa de psicología.	160.00	1
61	169	\N	\N	2026-02-01 11:00:00-06	Consulta externa de medicina general.	135.00	1
62	171	\N	\N	2026-02-27 09:30:00-06	Consulta externa de urología.	190.00	1
63	172	\N	\N	2026-03-12 10:00:00-06	Consulta externa de medicina general.	123.75	1
64	173	\N	\N	2026-03-25 10:30:00-06	Consulta externa de medicina general.	150.00	1
65	174	\N	\N	2026-04-07 11:00:00-06	Consulta externa de pediatría.	200.00	1
66	176	\N	\N	2026-05-03 10:30:00-06	Consulta externa de medicina física y rehabilitación.	175.00	1
67	177	\N	\N	2026-05-16 10:00:00-06	Consulta externa de terapia del lenguaje.	112.00	1
68	178	\N	\N	2026-05-29 10:30:00-06	Consulta externa de pediatría.	142.50	1
69	179	\N	\N	2026-06-11 11:00:00-06	Consulta externa de medicina general.	160.00	1
70	181	\N	\N	2026-07-07 10:30:00-06	Consulta externa de fisioterapia.	120.00	1
71	182	\N	\N	2026-07-20 10:00:00-06	Consulta externa de hematología.	195.00	1
72	183	\N	\N	2026-08-02 11:30:00-06	Consulta externa de psicología.	165.00	1
73	184	\N	\N	2026-08-15 11:00:00-06	Consulta externa de cardiología.	172.50	1
74	186	\N	\N	2026-09-10 09:30:00-06	Consulta externa de medicina general.	150.00	1
75	187	\N	\N	2026-09-23 10:00:00-06	Consulta externa de cardiología.	165.00	1
76	188	\N	\N	2026-10-06 11:30:00-06	Consulta externa de ginecología oncológica.	210.00	1
77	189	\N	\N	2026-10-19 11:00:00-06	Consulta externa de oftalmología.	185.00	1
78	191	\N	\N	2026-01-28 09:30:00-06	Consulta externa de pediatría.	168.00	1
79	192	\N	\N	2026-02-10 11:00:00-06	Consulta externa de ginecología oncológica.	205.00	1
80	193	\N	\N	2026-02-23 10:30:00-06	Consulta externa de medicina general.	150.00	1
81	194	\N	\N	2026-03-08 11:00:00-06	Consulta externa de dermatología.	180.00	1
82	196	\N	\N	2026-04-03 09:30:00-06	Consulta externa de medicina general.	127.50	1
83	197	\N	\N	2026-04-16 10:00:00-06	Consulta externa de medicina general.	150.00	1
84	198	\N	\N	2026-04-29 10:30:00-06	Consulta externa de cardiología.	172.00	1
85	199	\N	\N	2026-05-12 12:00:00-06	Consulta externa de psicología.	120.00	1
86	201	\N	\N	2026-06-07 09:30:00-06	Consulta externa de nutrición y dietética.	150.00	1
87	202	\N	\N	2026-06-20 10:00:00-06	Consulta externa de urología.	142.50	1
88	203	\N	\N	2026-07-03 10:30:00-06	Consulta externa de medicina general.	165.00	1
89	204	\N	\N	2026-07-16 11:00:00-06	Consulta externa de medicina general.	150.00	1
90	206	\N	\N	2026-08-11 09:30:00-06	Consulta externa de pediatría.	180.00	1
91	207	\N	\N	2026-08-24 11:00:00-06	Consulta externa de medicina física y rehabilitación.	175.00	1
92	208	\N	\N	2026-09-06 10:30:00-06	Consulta externa de terapia del lenguaje.	105.00	1
93	209	\N	\N	2026-09-19 11:00:00-06	Consulta externa de pediatría.	190.00	1
94	211	\N	\N	2026-10-15 09:30:00-06	Consulta externa de medicina general.	108.75	1
95	212	\N	\N	2026-01-11 11:00:00-06	Consulta externa de fisioterapia.	128.00	1
96	213	\N	\N	2026-01-24 10:30:00-06	Consulta externa de hematología.	195.00	1
97	214	\N	\N	2026-02-06 12:00:00-06	Consulta externa de psicología.	123.75	1
98	216	\N	\N	2026-03-04 10:30:00-06	Consulta externa de dermatología.	175.00	1
99	217	\N	\N	2026-03-17 10:00:00-06	Consulta externa de medicina general.	112.50	1
100	218	\N	\N	2026-03-30 10:30:00-06	Consulta externa de cardiología.	220.00	1
101	219	\N	\N	2026-04-12 12:00:00-06	Consulta externa de ginecología oncológica.	168.00	1
102	221	\N	\N	2026-05-08 09:30:00-06	Consulta externa de medicina general.	160.00	1
103	222	\N	\N	2026-05-21 10:00:00-06	Consulta externa de pediatría.	210.00	1
104	223	\N	\N	2026-06-03 11:30:00-06	Consulta externa de ginecología oncológica.	153.75	1
105	224	\N	\N	2026-06-16 11:00:00-06	Consulta externa de medicina general.	200.00	1
106	226	\N	\N	2026-07-12 09:30:00-06	Consulta externa de odontología general.	97.50	1
107	227	\N	\N	2026-07-25 10:00:00-06	Consulta externa de medicina general.	170.00	1
108	228	\N	\N	2026-08-07 10:30:00-06	Consulta externa de medicina general.	150.00	1
109	229	\N	\N	2026-08-20 11:00:00-06	Consulta externa de cardiología.	161.25	1
110	231	\N	\N	2026-09-15 09:30:00-06	Consulta externa de medicina general.	180.00	1
111	232	\N	\N	2026-09-28 10:00:00-06	Consulta externa de nutrición y dietética.	112.50	1
112	233	\N	\N	2026-10-11 10:30:00-06	Consulta externa de urología.	152.00	1
113	234	\N	\N	2026-01-07 11:00:00-06	Consulta externa de medicina general.	165.00	1
114	236	\N	\N	2026-02-02 09:30:00-06	Consulta externa de pediatría.	200.00	1
115	237	\N	\N	2026-02-15 10:00:00-06	Consulta externa de pediatría.	180.00	1
116	238	\N	\N	2026-02-28 11:30:00-06	Consulta externa de medicina física y rehabilitación.	131.25	1
117	239	\N	\N	2026-03-13 11:00:00-06	Consulta externa de terapia del lenguaje.	140.00	1
118	241	\N	\N	2026-04-08 09:30:00-06	Consulta externa de medicina general.	120.00	1
119	242	\N	\N	2026-04-21 10:00:00-06	Consulta externa de medicina general.	145.00	1
120	243	\N	\N	2026-05-04 11:30:00-06	Consulta externa de fisioterapia.	160.00	1
121	244	\N	\N	2026-05-17 11:00:00-06	Consulta externa de hematología.	146.25	1
122	246	\N	\N	2026-06-12 09:30:00-06	Consulta externa de cardiología.	230.00	1
123	247	\N	\N	2026-06-25 11:00:00-06	Consulta externa de dermatología.	131.25	1
124	248	\N	\N	2026-07-08 10:30:00-06	Consulta externa de medicina general.	150.00	1
125	249	\N	\N	2026-07-21 11:00:00-06	Consulta externa de cardiología.	220.00	1
126	251	\N	\N	2026-08-16 09:30:00-06	Consulta externa de oftalmología.	185.00	1
127	252	\N	\N	2026-08-29 10:00:00-06	Consulta externa de medicina general.	160.00	1
128	253	\N	\N	2026-09-11 10:30:00-06	Consulta externa de pediatría.	157.50	1
129	254	\N	\N	2026-09-24 12:00:00-06	Consulta externa de ginecología oncológica.	164.00	1
130	256	\N	\N	2026-10-20 09:30:00-06	Consulta externa de dermatología.	135.00	1
131	257	\N	\N	2026-01-16 10:00:00-06	Consulta externa de odontología general.	130.00	1
132	258	\N	\N	2026-01-29 10:30:00-06	Consulta externa de medicina general.	170.00	1
133	259	\N	\N	2026-02-11 11:00:00-06	Consulta externa de medicina general.	112.50	1
134	261	\N	\N	2026-03-09 10:30:00-06	Consulta externa de psicología.	128.00	1
135	262	\N	\N	2026-03-22 10:00:00-06	Consulta externa de medicina general.	135.00	1
136	263	\N	\N	2026-04-04 10:30:00-06	Consulta externa de nutrición y dietética.	150.00	1
137	264	\N	\N	2026-04-17 11:00:00-06	Consulta externa de urología.	190.00	1
138	266	\N	\N	2026-05-13 09:30:00-06	Consulta externa de medicina general.	150.00	1
139	267	\N	\N	2026-05-26 10:00:00-06	Consulta externa de pediatría.	200.00	1
140	268	\N	\N	2026-06-08 10:30:00-06	Consulta externa de pediatría.	135.00	1
141	269	\N	\N	2026-06-21 12:00:00-06	Consulta externa de medicina física y rehabilitación.	175.00	1
142	271	\N	\N	2026-07-17 09:30:00-06	Consulta externa de pediatría.	142.50	1
143	272	\N	\N	2026-07-30 10:00:00-06	Consulta externa de medicina general.	160.00	1
144	273	\N	\N	2026-08-12 10:30:00-06	Consulta externa de medicina general.	145.00	1
145	274	\N	\N	2026-08-25 12:00:00-06	Consulta externa de fisioterapia.	120.00	1
146	276	\N	\N	2026-09-20 10:30:00-06	Consulta externa de psicología.	165.00	1
147	277	\N	\N	2026-10-03 10:00:00-06	Consulta externa de cardiología.	172.50	1
148	278	\N	\N	2026-10-16 11:30:00-06	Consulta externa de dermatología.	175.00	1
149	279	\N	\N	2026-01-12 11:00:00-06	Consulta externa de medicina general.	150.00	1
150	281	\N	\N	2026-02-07 10:30:00-06	Consulta externa de ginecología oncológica.	210.00	1
151	282	\N	\N	2026-02-20 10:00:00-06	Consulta externa de oftalmología.	148.00	1
152	283	\N	\N	2026-03-05 10:30:00-06	Consulta externa de medicina general.	120.00	1
153	284	\N	\N	2026-03-18 11:00:00-06	Consulta externa de pediatría.	210.00	1
154	286	\N	\N	2026-04-13 09:30:00-06	Consulta externa de medicina general.	150.00	1
155	287	\N	\N	2026-04-26 10:00:00-06	Consulta externa de dermatología.	180.00	1
156	288	\N	\N	2026-05-09 10:30:00-06	Consulta externa de odontología general.	130.00	1
157	289	\N	\N	2026-05-22 11:00:00-06	Consulta externa de medicina general.	127.50	1
158	291	\N	\N	2026-06-17 09:30:00-06	Consulta externa de cardiología.	215.00	1
159	292	\N	\N	2026-06-30 11:00:00-06	Consulta externa de psicología.	120.00	1
160	293	\N	\N	2026-07-13 10:30:00-06	Consulta externa de medicina general.	180.00	1
161	294	\N	\N	2026-07-26 11:00:00-06	Consulta externa de nutrición y dietética.	150.00	1
162	296	\N	\N	2026-08-21 09:30:00-06	Consulta externa de medicina general.	132.00	1
163	297	\N	\N	2026-09-03 10:00:00-06	Consulta externa de medicina general.	150.00	1
164	298	\N	\N	2026-09-16 10:30:00-06	Consulta externa de pediatría.	150.00	1
165	299	\N	\N	2026-09-29 11:00:00-06	Consulta externa de pediatría.	180.00	1
166	301	\N	\N	2026-01-08 09:30:00-06	Consulta externa de terapia del lenguaje.	105.00	1
167	302	\N	\N	2026-01-21 10:00:00-06	Consulta externa de pediatría.	190.00	1
168	303	\N	\N	2026-02-03 10:30:00-06	Consulta externa de medicina general.	128.00	1
169	304	\N	\N	2026-02-16 11:00:00-06	Consulta externa de medicina general.	108.75	1
170	306	\N	\N	2026-03-14 09:30:00-06	Consulta externa de hematología.	195.00	1
171	307	\N	\N	2026-03-27 11:00:00-06	Consulta externa de psicología.	123.75	1
172	308	\N	\N	2026-04-09 10:30:00-06	Consulta externa de cardiología.	230.00	1
173	309	\N	\N	2026-04-22 12:00:00-06	Consulta externa de dermatología.	175.00	1
174	311	\N	\N	2026-05-18 09:30:00-06	Consulta externa de cardiología.	220.00	1
175	312	\N	\N	2026-05-31 11:00:00-06	Consulta externa de ginecología oncológica.	210.00	1
176	313	\N	\N	2026-06-13 10:30:00-06	Consulta externa de oftalmología.	138.75	1
177	314	\N	\N	2026-06-26 11:00:00-06	Consulta externa de medicina general.	160.00	1
178	316	\N	\N	2026-07-22 10:30:00-06	Consulta externa de ginecología oncológica.	153.75	1
179	317	\N	\N	2026-08-04 10:00:00-06	Consulta externa de medicina general.	160.00	1
180	318	\N	\N	2026-08-17 10:30:00-06	Consulta externa de dermatología.	180.00	1
181	319	\N	\N	2026-08-30 11:00:00-06	Consulta externa de odontología general.	97.50	1
182	\N	1001	\N	2026-01-27 01:07:00-06	Atención de emergencia: control cardiocirculatorio.	1190.00	2
183	\N	1002	\N	2026-02-16 14:44:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1620.00	3
184	\N	1003	\N	2026-03-10 04:21:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	720.00	4
185	\N	1004	\N	2026-03-30 17:58:00-06	Atención de emergencia: procedimientos de control y observación.	525.00	1
186	\N	1005	\N	2026-04-21 07:35:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	1100.00	2
187	\N	1006	\N	2026-05-11 21:12:00-06	Atención de emergencia: procedimientos diagnósticos.	680.00	3
188	\N	1008	\N	2026-06-23 00:26:00-06	Atención de emergencia: control cardiocirculatorio.	1120.00	1
189	\N	1009	\N	2026-07-14 14:03:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1350.00	2
190	\N	1010	\N	2026-08-04 03:40:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	900.00	3
191	\N	1011	\N	2026-08-25 17:17:00-06	Atención de emergencia: procedimientos de control y observación.	595.00	4
192	\N	1012	\N	2026-09-15 06:54:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	990.00	1
193	\N	1013	\N	2026-10-06 20:31:00-06	Atención de emergencia: procedimientos diagnósticos.	640.00	2
194	\N	1015	\N	2026-02-05 23:45:00-06	Atención de emergencia: control cardiocirculatorio.	1400.00	4
195	\N	1016	\N	2026-02-26 13:22:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1530.00	1
196	\N	1017	\N	2026-03-20 02:59:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	810.00	2
197	\N	1018	\N	2026-04-09 16:36:00-06	Atención de emergencia: procedimientos de control y observación.	560.00	3
198	\N	1019	\N	2026-04-30 18:33:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	825.00	4
199	\N	1020	\N	2026-05-21 08:10:00-06	Atención de emergencia: procedimientos diagnósticos.	800.00	1
200	\N	1022	\N	2026-07-02 11:24:00-06	Atención de emergencia: control cardiocirculatorio.	1260.00	3
201	\N	1023	\N	2026-07-24 01:01:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1440.00	4
202	\N	1024	\N	2026-08-13 14:38:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	675.00	1
203	\N	1025	\N	2026-09-04 04:15:00-06	Atención de emergencia: procedimientos de control y observación.	700.00	2
204	\N	1026	\N	2026-09-24 17:52:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	935.00	3
205	\N	1027	\N	2026-10-16 07:29:00-06	Atención de emergencia: procedimientos diagnósticos.	720.00	4
206	\N	1029	\N	2026-02-15 10:43:00-06	Atención de emergencia: control cardiocirculatorio.	1050.00	2
207	\N	1030	\N	2026-03-08 00:20:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1800.00	3
208	\N	1031	\N	2026-03-29 13:57:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	765.00	4
209	\N	1032	\N	2026-04-19 03:34:00-06	Atención de emergencia: procedimientos de control y observación.	630.00	1
210	\N	1033	\N	2026-05-10 17:11:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	880.00	2
211	\N	1034	\N	2026-05-31 06:48:00-06	Atención de emergencia: procedimientos diagnósticos.	600.00	3
212	\N	1036	\N	2026-07-12 10:02:00-06	Atención de emergencia: control cardiocirculatorio.	1190.00	1
213	\N	1037	\N	2026-08-02 23:39:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1620.00	2
214	\N	1038	\N	2026-08-23 01:36:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	720.00	3
215	\N	1039	\N	2026-09-13 15:13:00-06	Atención de emergencia: procedimientos de control y observación.	525.00	4
216	\N	1040	\N	2026-10-02 12:50:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	1100.00	1
217	\N	1041	\N	2026-01-12 02:27:00-06	Atención de emergencia: procedimientos diagnósticos.	680.00	2
218	\N	1043	\N	2026-02-23 05:41:00-06	Atención de emergencia: control cardiocirculatorio.	1120.00	4
219	\N	1044	\N	2026-03-15 19:18:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1350.00	1
220	\N	1045	\N	2026-04-06 08:55:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	900.00	2
221	\N	1046	\N	2026-04-26 22:32:00-06	Atención de emergencia: procedimientos de control y observación.	595.00	3
222	\N	1047	\N	2026-05-18 12:09:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	990.00	4
223	\N	1048	\N	2026-06-08 01:46:00-06	Atención de emergencia: procedimientos diagnósticos.	640.00	1
224	\N	1050	\N	2026-07-20 05:00:00-06	Atención de emergencia: control cardiocirculatorio.	1400.00	3
225	\N	1051	\N	2026-08-10 18:37:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1530.00	4
226	\N	1052	\N	2026-08-31 08:14:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	810.00	1
227	\N	1053	\N	2026-09-21 21:51:00-06	Atención de emergencia: procedimientos de control y observación.	560.00	2
228	\N	1054	\N	2026-10-12 11:28:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	825.00	3
229	\N	1055	\N	2026-01-22 01:05:00-06	Atención de emergencia: procedimientos diagnósticos.	800.00	4
230	\N	1057	\N	2026-03-04 16:39:00-06	Atención de emergencia: control cardiocirculatorio.	1260.00	2
231	\N	1058	\N	2026-03-25 06:16:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1440.00	3
232	\N	1059	\N	2026-04-15 19:53:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	675.00	4
233	\N	1060	\N	2026-05-06 09:30:00-06	Atención de emergencia: procedimientos de control y observación.	700.00	1
234	\N	1061	\N	2026-05-27 23:07:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	935.00	2
235	\N	1062	\N	2026-06-17 12:44:00-06	Atención de emergencia: procedimientos diagnósticos.	720.00	3
236	\N	1064	\N	2026-07-29 15:58:00-06	Atención de emergencia: control cardiocirculatorio.	1050.00	1
237	\N	1065	\N	2026-08-20 05:35:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1800.00	2
238	\N	1066	\N	2026-09-09 19:12:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	765.00	3
239	\N	1067	\N	2026-10-01 08:49:00-06	Atención de emergencia: procedimientos de control y observación.	630.00	4
240	\N	1068	\N	2026-01-09 22:26:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	880.00	1
241	\N	1069	\N	2026-01-31 12:03:00-06	Atención de emergencia: procedimientos diagnósticos.	600.00	2
242	\N	1071	\N	2026-03-14 15:17:00-06	Atención de emergencia: control cardiocirculatorio.	1190.00	4
243	\N	1072	\N	2026-04-04 04:54:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1620.00	1
244	\N	1073	\N	2026-04-25 18:31:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	720.00	2
245	\N	1074	\N	2026-05-16 08:08:00-06	Atención de emergencia: procedimientos de control y observación.	525.00	3
246	\N	1075	\N	2026-06-06 21:45:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	1100.00	4
247	\N	1076	\N	2026-06-26 23:42:00-06	Atención de emergencia: procedimientos diagnósticos.	680.00	1
248	\N	1078	\N	2026-08-08 02:56:00-06	Atención de emergencia: control cardiocirculatorio.	1120.00	3
249	\N	1079	\N	2026-08-29 16:33:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1350.00	4
250	\N	1080	\N	2026-09-17 14:10:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	900.00	1
251	\N	1081	\N	2026-10-09 03:47:00-06	Atención de emergencia: procedimientos de control y observación.	595.00	2
252	\N	1082	\N	2026-01-17 17:24:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	990.00	3
253	\N	1083	\N	2026-02-08 07:01:00-06	Atención de emergencia: procedimientos diagnósticos.	640.00	4
254	\N	1085	\N	2026-03-22 10:15:00-06	Atención de emergencia: control cardiocirculatorio.	1400.00	2
255	\N	1086	\N	2026-04-11 23:52:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1530.00	3
256	\N	1087	\N	2026-05-03 13:29:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	810.00	4
257	\N	1088	\N	2026-05-24 03:06:00-06	Atención de emergencia: procedimientos de control y observación.	560.00	1
258	\N	1089	\N	2026-06-14 16:43:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	825.00	2
259	\N	1090	\N	2026-07-05 06:20:00-06	Atención de emergencia: procedimientos diagnósticos.	800.00	3
260	\N	1092	\N	2026-08-16 09:34:00-06	Atención de emergencia: control cardiocirculatorio.	1260.00	1
261	\N	1093	\N	2026-09-06 23:11:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1440.00	2
262	\N	1094	\N	2026-09-27 12:48:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	675.00	3
263	\N	1095	\N	2026-01-06 14:45:00-06	Atención de emergencia: procedimientos de control y observación.	700.00	4
264	\N	1096	\N	2026-01-27 04:22:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	935.00	1
265	\N	1097	\N	2026-02-17 17:59:00-06	Atención de emergencia: procedimientos diagnósticos.	720.00	2
266	\N	1099	\N	2026-03-31 21:13:00-06	Atención de emergencia: control cardiocirculatorio.	1050.00	4
267	\N	1100	\N	2026-04-21 10:50:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1800.00	1
268	\N	1101	\N	2026-05-13 00:27:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	765.00	2
269	\N	1102	\N	2026-06-02 14:04:00-06	Atención de emergencia: procedimientos de control y observación.	630.00	3
270	\N	1103	\N	2026-06-24 03:41:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	880.00	4
271	\N	1104	\N	2026-07-14 17:18:00-06	Atención de emergencia: procedimientos diagnósticos.	600.00	1
272	\N	1106	\N	2026-08-25 20:32:00-06	Atención de emergencia: control cardiocirculatorio.	1190.00	3
273	\N	1107	\N	2026-09-16 10:09:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1620.00	4
274	\N	1108	\N	2026-10-06 23:46:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	720.00	1
275	\N	1109	\N	2026-01-16 13:23:00-06	Atención de emergencia: procedimientos de control y observación.	525.00	2
276	\N	1110	\N	2026-02-06 03:00:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	1100.00	3
277	\N	1111	\N	2026-02-27 16:37:00-06	Atención de emergencia: procedimientos diagnósticos.	680.00	4
278	\N	1113	\N	2026-04-10 19:51:00-06	Atención de emergencia: control cardiocirculatorio.	1120.00	2
279	\N	1114	\N	2026-04-30 21:48:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1350.00	3
280	\N	1115	\N	2026-05-22 11:25:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	900.00	4
281	\N	1116	\N	2026-06-12 01:02:00-06	Atención de emergencia: procedimientos de control y observación.	595.00	1
282	\N	1117	\N	2026-07-03 14:39:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	990.00	2
283	\N	1118	\N	2026-07-24 04:16:00-06	Atención de emergencia: procedimientos diagnósticos.	640.00	3
284	\N	1120	\N	2026-09-02 15:30:00-06	Atención de emergencia: control cardiocirculatorio.	1400.00	1
285	\N	1121	\N	2026-09-24 05:07:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1530.00	2
286	\N	1122	\N	2026-10-14 18:44:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	810.00	3
287	\N	1123	\N	2026-01-24 08:21:00-06	Atención de emergencia: procedimientos de control y observación.	560.00	4
288	\N	1124	\N	2026-02-13 21:58:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	825.00	1
289	\N	1125	\N	2026-03-07 11:35:00-06	Atención de emergencia: procedimientos diagnósticos.	800.00	2
290	\N	1127	\N	2026-04-18 14:49:00-06	Atención de emergencia: control cardiocirculatorio.	1260.00	4
291	\N	1128	\N	2026-05-09 04:26:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1440.00	1
292	\N	1129	\N	2026-05-30 18:03:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	675.00	2
293	\N	1130	\N	2026-06-20 07:40:00-06	Atención de emergencia: procedimientos de control y observación.	700.00	3
294	\N	1131	\N	2026-07-11 21:17:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	935.00	4
295	\N	1132	\N	2026-08-01 10:54:00-06	Atención de emergencia: procedimientos diagnósticos.	720.00	1
296	\N	1134	\N	2026-09-12 02:28:00-06	Atención de emergencia: control cardiocirculatorio.	1050.00	3
297	\N	1135	\N	2026-10-03 16:05:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1800.00	4
298	\N	1136	\N	2026-01-12 05:42:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	765.00	1
299	\N	1137	\N	2026-02-02 19:19:00-06	Atención de emergencia: procedimientos de control y observación.	630.00	2
300	\N	1138	\N	2026-02-23 08:56:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	880.00	3
301	\N	1139	\N	2026-03-16 22:33:00-06	Atención de emergencia: procedimientos diagnósticos.	600.00	4
302	\N	1141	\N	2026-04-28 01:47:00-06	Atención de emergencia: control cardiocirculatorio.	1190.00	2
303	\N	1142	\N	2026-05-18 15:24:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1620.00	3
304	\N	1143	\N	2026-06-09 05:01:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	720.00	4
305	\N	1144	\N	2026-06-29 18:38:00-06	Atención de emergencia: procedimientos de control y observación.	525.00	1
306	\N	1145	\N	2026-07-21 08:15:00-06	Atención de emergencia: procedimientos terapéuticos/diagnósticos.	1100.00	2
307	\N	1146	\N	2026-08-10 21:52:00-06	Atención de emergencia: procedimientos diagnósticos.	680.00	3
308	\N	1148	\N	2026-09-22 01:06:00-06	Atención de emergencia: control cardiocirculatorio.	1120.00	1
309	\N	1149	\N	2026-10-13 14:43:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1350.00	2
310	\N	1150	\N	2026-01-22 04:20:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	900.00	3
311	\N	1151	\N	2026-06-14 02:40:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1800.00	4
312	\N	1152	\N	2026-06-14 06:15:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1800.00	1
313	\N	1153	\N	2026-06-15 10:30:00-06	Atención de emergencia: atención de pacientes politraumatizados.	1800.00	2
314	\N	1154	\N	2026-03-21 15:00:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	765.00	3
315	\N	1155	\N	2026-03-21 18:35:00-06	Atención de emergencia: manejo, control y administración de drogas protocolizadas.	765.00	4
316	\N	2001	\N	2026-01-15 14:00:00-06	Hospitalización 2 días: medicina interna + insumos.	2511.00	10
317	\N	2002	\N	2026-01-21 15:00:00-06	Hospitalización 3 días: neumología + insumos.	2778.00	11
318	\N	2003	\N	2026-01-27 16:00:00-06	Hospitalización 4 días: neurología + insumos.	3079.50	12
319	\N	2004	\N	2026-02-02 17:00:00-06	Hospitalización 5 días: oncología + insumos.	4945.00	1
320	\N	2005	\N	2026-02-08 18:00:00-06	Hospitalización 6 días: ortopedia + insumos.	5126.00	2
321	\N	2006	\N	2026-02-14 19:00:00-06	Hospitalización 7 días: pediatría + insumos.	4950.00	3
322	\N	2007	\N	2026-02-20 20:00:00-06	Hospitalización 8 días: unidad de cuidados intermedios + insumos.	5547.00	4
323	\N	2009	\N	2026-02-23 14:00:00-06	Hospitalización 1 días: hematología + insumos.	2092.50	6
324	\N	2010	\N	2026-03-01 15:00:00-06	Hospitalización 2 días: medicina interna + insumos.	2905.00	7
325	\N	2011	\N	2026-03-07 16:00:00-06	Hospitalización 3 días: neumología + insumos.	3081.00	8
326	\N	2012	\N	2026-03-13 17:00:00-06	Hospitalización 4 días: neurología + insumos.	3422.00	9
327	\N	2013	\N	2026-03-19 18:00:00-06	Hospitalización 5 días: oncología + insumos.	3739.50	10
328	\N	2014	\N	2026-03-25 19:00:00-06	Hospitalización 6 días: ortopedia + insumos.	5015.00	11
329	\N	2015	\N	2026-03-31 20:00:00-06	Hospitalización 7 días: pediatría + insumos.	5942.00	12
330	\N	2017	\N	2026-04-12 14:00:00-06	Hospitalización 9 días: unidad de cuidado crítico de adultos + insumos.	6484.00	2
331	\N	2018	\N	2026-04-09 15:00:00-06	Hospitalización 1 días: hematología + insumos.	1823.00	3
332	\N	2019	\N	2026-04-15 16:00:00-06	Hospitalización 2 días: medicina interna + insumos.	2842.50	4
333	\N	2020	\N	2026-04-21 17:00:00-06	Hospitalización 3 días: neumología + insumos.	3435.00	5
334	\N	2021	\N	2026-04-27 18:00:00-06	Hospitalización 4 días: neurología + insumos.	3891.00	6
335	\N	2022	\N	2026-05-03 19:00:00-06	Hospitalización 5 días: oncología + insumos.	4151.00	7
336	\N	2023	\N	2026-05-09 20:00:00-06	Hospitalización 6 días: ortopedia + insumos.	3724.50	8
337	\N	2025	\N	2026-05-21 14:00:00-06	Hospitalización 8 días: unidad de cuidados intermedios + insumos.	6694.00	10
338	\N	2026	\N	2026-05-27 15:00:00-06	Hospitalización 9 días: unidad de cuidado crítico de adultos + insumos.	6490.00	11
339	\N	2027	\N	2026-05-24 16:00:00-06	Hospitalización 1 días: hematología + insumos.	2070.00	12
340	\N	2028	\N	2026-05-30 17:00:00-06	Hospitalización 2 días: medicina interna + insumos.	2438.00	1
341	\N	2029	\N	2026-06-05 18:00:00-06	Hospitalización 3 días: neumología + insumos.	3412.50	2
342	\N	2030	\N	2026-06-11 19:00:00-06	Hospitalización 4 días: neurología + insumos.	4265.00	3
343	\N	2031	\N	2026-06-17 20:00:00-06	Hospitalización 5 días: oncología + insumos.	4781.00	4
344	\N	2033	\N	2026-06-29 14:00:00-06	Hospitalización 7 días: pediatría + insumos.	4289.50	6
345	\N	2034	\N	2026-07-05 15:00:00-06	Hospitalización 8 días: unidad de cuidados intermedios + insumos.	6235.00	7
346	\N	2035	\N	2026-07-11 16:00:00-06	Hospitalización 9 días: unidad de cuidado crítico de adultos + insumos.	8010.00	8
347	\N	2036	\N	2026-07-08 17:00:00-06	Hospitalización 1 días: hematología + insumos.	1920.00	9
348	\N	2037	\N	2026-07-14 18:00:00-06	Hospitalización 2 días: medicina interna + insumos.	2641.00	10
349	\N	2038	\N	2026-07-20 19:00:00-06	Hospitalización 3 días: neumología + insumos.	2903.00	11
350	\N	2039	\N	2026-07-26 20:00:00-06	Hospitalización 4 días: neurología + insumos.	4252.50	12
351	\N	2041	\N	2026-08-07 14:00:00-06	Hospitalización 6 días: ortopedia + insumos.	4271.00	2
352	\N	2042	\N	2026-08-13 15:00:00-06	Hospitalización 7 días: pediatría + insumos.	4663.00	3
353	\N	2043	\N	2026-08-19 16:00:00-06	Hospitalización 8 días: unidad de cuidados intermedios + insumos.	4874.50	4
354	\N	2044	\N	2026-08-25 17:00:00-06	Hospitalización 9 días: unidad de cuidado crítico de adultos + insumos.	7475.00	5
355	\N	2045	\N	2026-08-22 18:00:00-06	Hospitalización 1 días: hematología + insumos.	2226.00	6
356	\N	2046	\N	2026-08-28 19:00:00-06	Hospitalización 2 días: medicina interna + insumos.	2550.00	7
357	\N	2047	\N	2026-09-03 20:00:00-06	Hospitalización 3 días: neumología + insumos.	3042.00	8
358	\N	2049	\N	2026-09-15 14:00:00-06	Hospitalización 5 días: oncología + insumos.	4622.50	10
359	\N	2050	\N	2026-09-21 15:00:00-06	Hospitalización 6 días: ortopedia + insumos.	5105.00	11
360	\N	2051	\N	2026-09-27 16:00:00-06	Hospitalización 7 días: pediatría + insumos.	5081.00	12
361	\N	2052	\N	2026-10-03 17:00:00-06	Hospitalización 8 días: unidad de cuidados intermedios + insumos.	5307.00	1
362	\N	2053	\N	2026-10-09 18:00:00-06	Hospitalización 9 días: unidad de cuidado crítico de adultos + insumos.	5834.50	2
363	\N	2054	\N	2026-10-06 19:00:00-06	Hospitalización 1 días: hematología + insumos.	2505.00	3
364	\N	2055	\N	2026-10-12 20:00:00-06	Hospitalización 2 días: medicina interna + insumos.	2942.00	4
365	\N	2057	\N	2026-01-17 14:00:00-06	Hospitalización 4 días: neurología + insumos.	3554.00	6
366	\N	2058	\N	2026-01-23 15:00:00-06	Hospitalización 5 días: oncología + insumos.	3918.00	7
367	\N	2059	\N	2026-01-29 16:00:00-06	Hospitalización 6 días: ortopedia + insumos.	4742.50	8
368	\N	2060	\N	2026-02-04 17:00:00-06	Hospitalización 7 días: pediatría + insumos.	5935.00	9
369	\N	\N	101	2026-01-20 18:03:00-06	Cirugía: reparación de tendones flexores de la mano + insumos utilizados.	9156.50	6
370	\N	\N	102	2026-01-27 18:26:00-06	Cirugía: colecistectomía laparoscópica + insumos utilizados.	7459.00	7
371	\N	\N	103	2026-02-03 18:49:00-06	Cirugía: rinoplastia reconstructiva + insumos utilizados.	7883.50	8
372	\N	\N	104	2026-02-06 19:12:00-06	Cirugía: resección oncológica de colon + insumos utilizados.	11130.00	9
373	\N	\N	105	2026-02-13 18:45:00-06	Cirugía: craneotomía para drenaje de hematoma + insumos utilizados.	8813.00	10
374	\N	\N	107	2026-02-27 19:31:00-06	Cirugía: hernioplastia inguinal + insumos utilizados.	8843.50	12
375	\N	\N	108	2026-03-02 19:54:00-06	Cirugía: apendicectomía abierta + insumos utilizados.	7060.00	1
376	\N	\N	110	2026-03-16 19:50:00-06	Cirugía: herniorrafia umbilical pediátrica + insumos utilizados.	7426.00	3
377	\N	\N	111	2026-03-23 20:13:00-06	Cirugía: hernioplastia inguinal + insumos utilizados.	7281.50	4
378	\N	\N	113	2026-04-02 18:29:00-06	Cirugía: cesárea + insumos utilizados.	7901.50	6
379	\N	\N	114	2026-04-09 18:52:00-06	Cirugía: apendicectomía abierta + insumos utilizados.	6970.00	7
380	\N	\N	115	2026-04-16 18:25:00-06	Cirugía: hernioplastia inguinal + insumos utilizados.	7540.00	8
381	\N	\N	116	2026-04-19 18:48:00-06	Cirugía: apendicectomía abierta + insumos utilizados.	8841.00	9
382	\N	\N	117	2026-04-26 19:11:00-06	Cirugía: reducción de fractura + insumos utilizados.	7817.50	10
383	\N	\N	119	2026-05-10 19:57:00-06	Cirugía: reemplazo de válvula aórtica + insumos utilizados.	13519.00	12
384	\N	\N	120	2026-05-13 19:30:00-06	Cirugía: lobectomía pulmonar + insumos utilizados.	8647.00	1
385	\N	\N	121	2026-05-20 19:53:00-06	Cirugía: prostatectomía + insumos utilizados.	7539.00	2
386	\N	\N	122	2026-05-27 20:16:00-06	Cirugía: reducción de fractura + insumos utilizados.	6723.00	3
387	\N	\N	123	2026-06-03 20:39:00-06	Cirugía: reducción de fractura + insumos utilizados.	6605.50	4
388	\N	\N	125	2026-06-13 18:05:00-06	Cirugía: hernioplastia inguinal + insumos utilizados.	8865.00	6
389	\N	\N	126	2026-06-20 18:28:00-06	Cirugía: reparación de tendones flexores de la mano + insumos utilizados.	8661.00	7
390	\N	\N	128	2026-06-30 19:14:00-06	Cirugía: rinoplastia reconstructiva + insumos utilizados.	8050.00	9
391	\N	\N	129	2026-07-07 19:37:00-06	Cirugía: mastectomía + insumos utilizados.	11259.00	10
392	\N	\N	131	2026-07-21 19:33:00-06	Cirugía: herniorrafia umbilical pediátrica + insumos utilizados.	8306.50	12
393	\N	\N	132	2026-07-24 19:56:00-06	Cirugía: apendicectomía abierta + insumos utilizados.	8734.00	1
394	\N	\N	133	2026-07-31 20:19:00-06	Cirugía: hernioplastia inguinal + insumos utilizados.	7033.50	2
395	\N	\N	134	2026-08-07 20:42:00-06	Cirugía: amigdalectomía + insumos utilizados.	8830.00	3
396	\N	\N	135	2026-08-14 17:45:00-06	Cirugía: herniorrafia umbilical pediátrica + insumos utilizados.	7538.00	4
397	\N	\N	137	2026-08-24 18:31:00-06	Cirugía: mastectomía + insumos utilizados.	11143.50	6
398	\N	\N	138	2026-08-31 18:54:00-06	Cirugía: cesárea + insumos utilizados.	7910.00	7
399	\N	\N	139	2026-09-07 19:17:00-06	Cirugía: hernioplastia inguinal + insumos utilizados.	7204.00	8
400	\N	\N	140	2026-09-10 18:50:00-06	Cirugía: apendicectomía abierta + insumos utilizados.	7426.00	9
401	\N	\N	141	2026-09-17 19:13:00-06	Cirugía: hernioplastia inguinal + insumos utilizados.	8981.50	10
402	\N	\N	143	2026-10-01 19:59:00-06	Cirugía: hernioplastia inguinal + insumos utilizados.	8751.50	12
403	\N	\N	144	2026-10-04 20:22:00-06	Cirugía: revascularización miocárdica + insumos utilizados.	12920.00	1
\.


--
-- Data for Name: historia_clinica; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.historia_clinica (id_historia_clinica, id_agendamiento, id_medico, fecha, fuente_interrogatorio, religion, ocupacion, lugar_nacimiento, lugar_residencia, antecedentes_heredofamiliares, antecedentes_personales_no_patologicos, antecedentes_patologicos, padecimiento_actual, interrogatorio_aparatos_sistemas, sintomas_generales_terapeutica, estudios_previos, signos_vitales, exploracion_general, exploracion_sistematizada) FROM stdin;
1	1	1006	2026-08-11	directo	Católica	Comerciante	Olintepeque, Quetzaltenango	Olintepeque, Quetzaltenango	Cardiopatía isquémica en padre; hipertensión en madre.	No fumador; consumo de alcohol ocasional; alimentación sin restricciones.	Ninguno conocido.	Dolor abdominal en fosa ilíaca derecha desde hace 8 horas, con náuseas.	Dolor intenso localizado, sin irradiación.	Paciente no había iniciado antibióticos previo a consulta.	Ecografía abdominal: líquido libre y engrosamiento apendicular.	TA 120/80, FC 92, T° 37.8.	Abdomen blando, doloroso a palpación en fosa ilíaca derecha.	Cabeza y cuello sin alteraciones; tórax y abdomen según lo referido; extremidades sin déficit motor.
101	101	1020	2026-01-18	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
102	102	1021	2026-01-24	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
103	103	1028	2026-01-30	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
104	104	1009	2026-02-05	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
105	105	1023	2026-02-11	indirecto	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
106	106	1040	2026-02-17	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
107	107	1006	2026-02-23	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
108	108	1045	2026-03-01	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
109	109	1026	2026-03-07	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
110	110	1027	2026-03-13	indirecto	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
111	111	1045	2026-03-19	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
112	112	1009	2026-03-25	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
113	113	1022	2026-03-31	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
114	114	1045	2026-04-06	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
115	115	1035	2026-04-12	indirecto	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
116	116	1006	2026-04-18	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
117	117	1025	2026-04-24	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
118	118	1006	2026-04-30	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
119	119	1007	2026-05-06	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
120	120	1029	2026-05-12	indirecto	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
121	121	1030	2026-05-18	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
122	122	1050	2026-05-24	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
123	123	1050	2026-05-30	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
124	124	1024	2026-06-05	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
125	125	1006	2026-06-11	indirecto	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
126	126	1020	2026-06-17	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
127	127	1021	2026-06-23	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
128	128	1028	2026-06-29	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
129	129	1009	2026-07-05	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
130	130	1023	2026-07-11	indirecto	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
131	131	1040	2026-07-17	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
132	132	1006	2026-07-23	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
133	133	1045	2026-07-29	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
134	134	1026	2026-08-04	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
135	135	1027	2026-08-10	indirecto	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
136	136	1045	2026-08-16	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
137	137	1009	2026-08-22	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
138	138	1022	2026-08-28	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
139	139	1045	2026-09-03	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
140	140	1035	2026-09-09	indirecto	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
141	141	1006	2026-09-15	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
142	142	1025	2026-09-21	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
143	143	1006	2026-09-27	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
144	144	1007	2026-10-03	directo	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Hipertensión arterial controlada.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
145	145	1029	2026-01-12	indirecto	\N	\N	\N	\N	Sin antecedentes heredofamiliares de importancia.	No fuma; alimentación balanceada.	Ninguno conocido.	Padecimiento que motiva la cirugía, según valoración del cirujano.	\N	\N	\N	TA 120/80, FC 78, T° 36.8.	Paciente consciente y orientado.	\N
\.


--
-- Data for Name: hospital; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.hospital (id_hospital, nombre, informacion_especifica, direccion, id_municipio) FROM stdin;
1	Hospital General de Occidente	Hospital general de tercer nivel; 4 quirófanos y 24 camillas de hospitalización.	15 Av. 6-45, zona 3	1
2	Hospital Regional de San Marcos	Hospital de referencia regional para el departamento de San Marcos.	7a. calle 4-10, zona 2	6
3	Hospital Infantil de Retalhuleu	Hospital especializado en atención pediátrica.	Boulevard El Malecón, zona 1	8
4	Hospital de Occidente Huehuetenango	Hospital general de segundo nivel con énfasis en atención materno-infantil.	5a. avenida 3-20, zona 1	9
5	Hospital de Occidente Sololá	Hospital general de segundo nivel para la región del lago.	Calle principal 7-15, zona 2	11
\.


--
-- Data for Name: hospitalizacion_insumo; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.hospitalizacion_insumo (id_ingreso, id_insumo, cantidad, costo_unitario) FROM stdin;
3	1	8	30.00
3	8	10	15.00
5	1	6	30.00
5	8	6	15.00
2060	1	6	15.00
2056	1	2	15.00
2050	1	4	15.00
2046	1	2	15.00
2040	1	2	15.00
2036	1	2	15.00
2030	1	8	15.00
2026	1	2	15.00
2020	1	6	15.00
2016	1	2	15.00
2010	1	4	15.00
2006	1	2	15.00
2057	2	3	85.00
2051	2	5	85.00
2047	2	3	85.00
2041	2	3	85.00
2037	2	3	85.00
2031	2	9	85.00
2027	2	3	85.00
2021	2	7	85.00
2017	2	3	85.00
2011	2	5	85.00
2007	2	3	85.00
2001	2	3	85.00
2058	3	4	12.00
2052	3	6	12.00
2048	3	4	12.00
2042	3	4	12.00
2038	3	4	12.00
2032	3	2	12.00
2028	3	4	12.00
2022	3	8	12.00
2018	3	4	12.00
2012	3	6	12.00
2008	3	4	12.00
2002	3	4	12.00
2059	4	5	2.50
2053	4	7	2.50
2049	4	5	2.50
2043	4	5	2.50
2039	4	5	2.50
2033	4	3	2.50
2029	4	5	2.50
2023	4	9	2.50
2019	4	5	2.50
2013	4	7	2.50
2009	4	5	2.50
2003	4	5	2.50
2060	5	1	45.00
2054	5	8	45.00
2050	5	1	45.00
2044	5	6	45.00
2040	5	1	45.00
2034	5	4	45.00
2030	5	1	45.00
2024	5	2	45.00
2020	5	1	45.00
2014	5	8	45.00
2010	5	1	45.00
2004	5	6	45.00
2055	6	9	8.00
2051	6	2	8.00
2045	6	7	8.00
2041	6	2	8.00
2035	6	5	8.00
2031	6	2	8.00
2025	6	3	8.00
2021	6	2	8.00
2015	6	9	8.00
2011	6	2	8.00
2005	6	7	8.00
2001	6	2	8.00
2056	7	2	35.00
2052	7	3	35.00
2046	7	8	35.00
2042	7	3	35.00
2036	7	6	35.00
2032	7	3	35.00
2026	7	4	35.00
2022	7	3	35.00
2016	7	2	35.00
2012	7	3	35.00
2006	7	8	35.00
2002	7	3	35.00
2057	8	3	18.00
2053	8	4	18.00
2047	8	9	18.00
2043	8	4	18.00
2037	8	7	18.00
2033	8	4	18.00
2027	8	5	18.00
2023	8	4	18.00
2017	8	3	18.00
2013	8	4	18.00
2007	8	9	18.00
2003	8	4	18.00
2058	9	4	55.00
2054	9	5	55.00
2048	9	2	55.00
2044	9	5	55.00
2038	9	8	55.00
2034	9	5	55.00
2028	9	6	55.00
2024	9	5	55.00
2018	9	4	55.00
2014	9	5	55.00
2008	9	2	55.00
2004	9	5	55.00
2059	10	5	70.00
2055	10	1	70.00
2049	10	3	70.00
2045	10	1	70.00
2039	10	9	70.00
2035	10	1	70.00
2029	10	7	70.00
2025	10	1	70.00
2019	10	5	70.00
2015	10	1	70.00
2009	10	3	70.00
2005	10	1	70.00
\.


--
-- Data for Name: ingreso; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.ingreso (id_ingreso, id_paciente, id_unidad, id_servicio, id_medico_encargado, id_camilla, id_quirofano, id_turno, fecha_hora_ingreso, motivo_ingreso, diagnostico_presuntivo, prioridad_triage, turnos_espera) FROM stdin;
1	3	12	3	1001	25	\N	1	2026-08-09 22:10:00-06	Politraumatismo por accidente de tránsito.	Traumatismo craneoencefálico leve; fractura de brazo derecho.	2	0
2	4	12	5	1005	26	\N	2	2026-08-20 14:05:00-06	Fiebre alta persistente y deshidratación.	Cuadro febril viral en observación.	3	1
3	2	14	9	1005	3	\N	\N	2026-08-14 11:00:00-06	Hipertensión arterial descompensada.	Crisis hipertensiva en estudio.	\N	\N
4	5	13	17	1006	\N	2	\N	2026-08-11 18:35:00-06	Ingreso a quirófano para apendicectomía de urgencia.	Apendicitis aguda.	\N	\N
5	5	14	15	1006	4	\N	\N	2026-08-11 21:00:00-06	Sala de recuperación postquirúrgica tras apendicectomía.	Postoperatorio de apendicectomía.	\N	\N
3044	12	23	118	1007	\N	5	\N	2026-10-04 14:40:00-06	Ingreso a quirófano: Revascularización miocárdica.	Indicación quirúrgica.	\N	\N
3019	56	23	118	1007	\N	8	\N	2026-05-10 14:40:00-06	Ingreso a quirófano: Reemplazo de válvula aórtica.	Indicación quirúrgica.	\N	\N
3026	41	13	17	1020	\N	3	\N	2026-06-20 14:40:00-06	Ingreso a quirófano: Reparación de tendones flexores de la mano.	Indicación quirúrgica.	\N	\N
3001	18	13	17	1020	\N	2	\N	2026-01-20 14:40:00-06	Ingreso a quirófano: Reparación de tendones flexores de la mano.	Indicación quirúrgica.	\N	\N
3002	35	23	117	1021	\N	7	\N	2026-01-27 14:40:00-06	Ingreso a quirófano: Colecistectomía laparoscópica.	Indicación quirúrgica.	\N	\N
3038	44	33	217	1022	\N	11	\N	2026-08-31 14:40:00-06	Ingreso a quirófano: Cesárea.	Indicación quirúrgica.	\N	\N
3013	21	33	217	1022	\N	10	\N	2026-04-02 14:40:00-06	Ingreso a quirófano: Cesárea.	Indicación quirúrgica.	\N	\N
3005	19	13	17	1023	\N	2	\N	2026-02-13 14:40:00-06	Ingreso a quirófano: Craneotomía para drenaje de hematoma.	Indicación quirúrgica.	\N	\N
3017	22	33	217	1025	\N	10	\N	2026-04-26 14:40:00-06	Ingreso a quirófano: Reducción de fractura.	Indicación quirúrgica.	\N	\N
3034	43	13	17	1026	\N	3	\N	2026-08-07 14:40:00-06	Ingreso a quirófano: Amigdalectomía.	Indicación quirúrgica.	\N	\N
3035	60	23	117	1027	\N	8	\N	2026-08-14 14:40:00-06	Ingreso a quirófano: Herniorrafia umbilical pediátrica.	Indicación quirúrgica.	\N	\N
3010	37	23	117	1027	\N	7	\N	2026-03-16 14:40:00-06	Ingreso a quirófano: Herniorrafia umbilical pediátrica.	Indicación quirúrgica.	\N	\N
3028	8	33	217	1028	\N	9	\N	2026-06-30 14:40:00-06	Ingreso a quirófano: Rinoplastia reconstructiva.	Indicación quirúrgica.	\N	\N
3003	52	33	217	1028	\N	12	\N	2026-02-03 14:40:00-06	Ingreso a quirófano: Rinoplastia reconstructiva.	Indicación quirúrgica.	\N	\N
3020	6	13	17	1029	\N	1	\N	2026-05-13 14:40:00-06	Ingreso a quirófano: Lobectomía pulmonar.	Indicación quirúrgica.	\N	\N
3021	23	23	117	1030	\N	6	\N	2026-05-20 14:40:00-06	Ingreso a quirófano: Prostatectomía.	Indicación quirúrgica.	\N	\N
3043	62	13	17	1006	\N	4	\N	2026-10-01 14:40:00-06	Ingreso a quirófano: Hernioplastia inguinal.	Indicación quirúrgica.	\N	\N
3041	28	13	17	1006	\N	2	\N	2026-09-17 14:40:00-06	Ingreso a quirófano: Hernioplastia inguinal.	Indicación quirúrgica.	\N	\N
3032	9	13	17	1006	\N	1	\N	2026-07-24 14:40:00-06	Ingreso a quirófano: Apendicectomía abierta.	Indicación quirúrgica.	\N	\N
3025	24	13	17	1006	\N	2	\N	2026-06-13 14:40:00-06	Ingreso a quirófano: Hernioplastia inguinal.	Indicación quirúrgica.	\N	\N
3016	5	13	17	1006	\N	1	\N	2026-04-19 14:40:00-06	Ingreso a quirófano: Apendicectomía abierta.	Indicación quirúrgica.	\N	\N
3007	53	13	17	1006	\N	4	\N	2026-02-27 14:40:00-06	Ingreso a quirófano: Hernioplastia inguinal.	Indicación quirúrgica.	\N	\N
3040	11	23	117	1035	\N	5	\N	2026-09-10 14:40:00-06	Ingreso a quirófano: Apendicectomía abierta.	Indicación quirúrgica.	\N	\N
3015	55	23	117	1035	\N	8	\N	2026-04-16 14:40:00-06	Ingreso a quirófano: Hernioplastia inguinal.	Indicación quirúrgica.	\N	\N
3031	59	33	217	1040	\N	12	\N	2026-07-21 14:40:00-06	Ingreso a quirófano: Herniorrafia umbilical pediátrica.	Indicación quirúrgica.	\N	\N
3037	27	33	219	1009	\N	10	\N	2026-08-24 14:40:00-06	Ingreso a quirófano: Mastectomía.	Indicación quirúrgica.	\N	\N
3029	25	33	219	1009	\N	10	\N	2026-07-07 14:40:00-06	Ingreso a quirófano: Mastectomía.	Indicación quirúrgica.	\N	\N
3004	2	33	219	1009	\N	9	\N	2026-02-06 14:40:00-06	Ingreso a quirófano: Resección oncológica de colon.	Indicación quirúrgica.	\N	\N
3039	61	43	317	1045	\N	16	\N	2026-09-07 14:40:00-06	Ingreso a quirófano: Hernioplastia inguinal.	Indicación quirúrgica.	\N	\N
3033	26	43	317	1045	\N	14	\N	2026-07-31 14:40:00-06	Ingreso a quirófano: Hernioplastia inguinal.	Indicación quirúrgica.	\N	\N
3014	38	43	317	1045	\N	15	\N	2026-04-09 14:40:00-06	Ingreso a quirófano: Apendicectomía abierta.	Indicación quirúrgica.	\N	\N
3011	54	43	317	1045	\N	16	\N	2026-03-23 14:40:00-06	Ingreso a quirófano: Hernioplastia inguinal.	Indicación quirúrgica.	\N	\N
3008	3	43	317	1045	\N	13	\N	2026-03-02 14:40:00-06	Ingreso a quirófano: Apendicectomía abierta.	Indicación quirúrgica.	\N	\N
3023	57	53	417	1050	\N	20	\N	2026-06-03 14:40:00-06	Ingreso a quirófano: Reducción de fractura.	Indicación quirúrgica.	\N	\N
3022	40	53	417	1050	\N	19	\N	2026-05-27 14:40:00-06	Ingreso a quirófano: Reducción de fractura.	Indicación quirúrgica.	\N	\N
2029	48	34	210	1016	206	\N	\N	2026-06-02 15:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2030	61	14	11	1005	7	\N	\N	2026-06-07 16:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2031	7	44	312	1042	307	\N	\N	2026-06-12 17:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2032	20	24	113	1012	107	\N	\N	2026-06-17 10:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2033	33	54	414	1050	407	\N	\N	2026-06-22 11:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2034	46	34	215	1040	207	\N	\N	2026-06-27 12:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2035	59	14	16	1013	8	\N	\N	2026-07-02 13:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2036	5	44	308	1041	308	\N	\N	2026-07-07 14:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2037	18	24	109	1033	108	\N	\N	2026-07-12 15:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2038	31	54	410	1050	408	\N	\N	2026-07-17 16:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2039	44	34	211	1038	208	\N	\N	2026-07-22 17:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2040	57	14	12	1002	9	\N	\N	2026-07-27 10:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2041	3	44	313	1046	309	\N	\N	2026-08-01 11:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2042	16	24	114	1019	109	\N	\N	2026-08-06 12:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2043	29	54	415	1050	409	\N	\N	2026-08-11 13:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2044	42	34	216	1036	209	\N	\N	2026-08-16 14:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2045	55	14	8	1008	10	\N	\N	2026-08-21 15:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2046	1	44	309	1045	310	\N	\N	2026-08-26 16:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2047	14	24	110	1035	110	\N	\N	2026-08-31 17:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2048	27	54	411	1050	410	\N	\N	2026-09-05 10:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2049	40	34	212	1009	210	\N	\N	2026-09-10 11:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2050	53	14	13	1017	11	\N	\N	2026-09-15 12:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2051	66	44	314	1044	311	\N	\N	2026-09-20 13:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2052	12	24	115	1032	111	\N	\N	2026-09-25 14:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2053	25	54	416	1050	401	\N	\N	2026-09-30 15:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2054	38	34	208	1039	201	\N	\N	2026-10-05 16:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2055	51	14	9	1004	12	\N	\N	2026-10-10 17:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2056	64	44	310	1043	312	\N	\N	2026-01-08 10:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2057	10	24	111	1014	112	\N	\N	2026-01-13 11:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2058	23	54	412	1050	402	\N	\N	2026-01-18 12:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2059	36	34	213	1037	202	\N	\N	2026-01-23 13:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2060	49	14	14	1011	13	\N	\N	2026-01-28 14:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2001	19	44	309	1042	301	\N	\N	2026-01-13 11:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
1151	20	12	3	1001	25	\N	1531	2026-06-13 21:30:00-06	Politraumatismo por accidente de bus.	Trauma craneoencefálico severo.	1	0
1152	33	12	3	1005	26	\N	1531	2026-06-13 21:40:00-06	Politraumatismo por accidente de bus.	Trauma torácico severo.	1	0
1153	46	12	3	1001	27	\N	1531	2026-06-13 21:50:00-06	Politraumatismo por accidente de bus.	Fractura de fémur.	2	0
1154	41	22	104	1031	113	\N	1252	2026-03-21 09:15:00-06	Intoxicación por plaguicida.	Intoxicación por organofosforados.	1	0
1155	54	22	104	1031	114	\N	1252	2026-03-21 09:20:00-06	Intoxicación por plaguicida.	Intoxicación por organofosforados.	1	1
1121	59	22	103	1032	114	\N	1873	2026-09-23 23:37:00-06	Traumatismo por caída.	Contusión.	4	1
2002	32	24	110	1019	101	\N	\N	2026-01-18 12:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2003	45	54	411	1050	401	\N	\N	2026-01-23 13:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2004	58	34	212	1038	201	\N	\N	2026-01-28 14:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2005	4	14	13	1006	2	\N	\N	2026-02-02 15:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2006	17	44	314	1041	302	\N	\N	2026-02-07 16:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2007	30	24	115	1035	102	\N	\N	2026-02-12 17:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2008	43	54	416	1050	402	\N	\N	2026-02-17 10:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2009	56	34	208	1036	202	\N	\N	2026-02-22 11:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2010	2	14	9	1015	3	\N	\N	2026-02-27 12:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2011	15	44	310	1046	303	\N	\N	2026-03-04 13:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2012	28	24	111	1032	103	\N	\N	2026-03-09 14:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2013	41	54	412	1050	403	\N	\N	2026-03-14 15:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2014	54	34	213	1009	203	\N	\N	2026-03-19 16:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2015	67	14	14	1003	4	\N	\N	2026-03-24 17:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2016	13	44	315	1045	304	\N	\N	2026-03-29 10:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2017	26	24	116	1014	104	\N	\N	2026-04-03 11:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2018	39	54	408	1050	404	\N	\N	2026-04-08 12:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2019	52	34	209	1039	204	\N	\N	2026-04-13 13:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2020	65	14	10	1010	5	\N	\N	2026-04-18 14:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2021	11	44	311	1044	305	\N	\N	2026-04-23 15:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2022	24	24	112	1034	105	\N	\N	2026-04-28 16:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2023	37	54	413	1050	405	\N	\N	2026-05-03 17:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
2024	50	34	214	1037	205	\N	\N	2026-05-08 10:00:00-06	Tratamiento de infección urinaria complicada.	Pielonefritis.	\N	\N
2025	63	14	15	1018	6	\N	\N	2026-05-13 11:00:00-06	Neumonía que requiere oxígeno.	Neumonía.	\N	\N
2026	9	44	316	1043	306	\N	\N	2026-05-18 12:00:00-06	Control de diabetes descompensada.	Diabetes descompensada.	\N	\N
2027	22	24	108	1031	106	\N	\N	2026-05-23 13:00:00-06	Recuperación postquirúrgica.	Postoperatorio.	\N	\N
2028	35	54	409	1050	406	\N	\N	2026-05-28 14:00:00-06	Observación por trauma craneal.	Trauma craneal leve.	\N	\N
1001	12	22	102	1035	114	\N	1073	2026-01-26 19:37:00-06	Fiebre alta y deshidratación.	Cuadro viral.	4	0
1002	23	32	203	1036	213	\N	1144	2026-02-16 08:14:00-06	Traumatismo por caída.	Contusión.	2	0
1003	34	42	304	1042	318	\N	1217	2026-03-09 20:51:00-06	Dificultad respiratoria.	Crisis asmática.	5	0
1004	45	52	405	1047	411	\N	1288	2026-03-30 09:28:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	3	0
1005	56	12	6	1006	30	\N	1351	2026-04-20 22:05:00-06	Herida cortante en extremidad.	Herida superficial.	1	0
1006	67	22	107	1032	115	\N	1422	2026-05-11 10:42:00-06	Crisis hipertensiva.	Hipertensión descompensada.	4	2
1007	11	32	201	1037	214	\N	1495	2026-06-01 23:19:00-06	Dolor torácico.	Síndrome coronario en estudio.	2	2
1008	22	42	302	1041	318	\N	1566	2026-06-22 11:56:00-06	Fiebre alta y deshidratación.	Cuadro viral.	5	2
1009	33	52	403	1048	412	\N	1639	2026-07-14 00:33:00-06	Traumatismo por caída.	Contusión.	3	2
1010	44	12	4	1001	29	\N	1700	2026-08-03 13:10:00-06	Dificultad respiratoria.	Crisis asmática.	1	0
1011	55	22	105	1035	116	\N	1773	2026-08-25 01:47:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	4	0
1012	66	32	206	1036	211	\N	1844	2026-09-14 14:24:00-06	Herida cortante en extremidad.	Herida superficial.	2	0
1013	10	42	307	1046	318	\N	1917	2026-10-06 03:01:00-06	Crisis hipertensiva.	Hipertensión descompensada.	5	3
1014	21	52	401	1047	413	\N	1038	2026-01-14 15:38:00-06	Dolor torácico.	Síndrome coronario en estudio.	3	0
1015	32	12	2	1005	28	\N	1101	2026-02-05 04:15:00-06	Fiebre alta y deshidratación.	Cuadro viral.	1	0
1016	43	22	103	1031	113	\N	1172	2026-02-25 16:52:00-06	Traumatismo por caída.	Contusión.	4	0
1017	54	32	204	1037	212	\N	1245	2026-03-19 05:29:00-06	Dificultad respiratoria.	Crisis asmática.	2	0
1018	65	42	305	1041	318	\N	1316	2026-04-08 18:06:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	5	0
1019	9	52	406	1048	414	\N	1389	2026-04-29 19:03:00-06	Herida cortante en extremidad.	Herida superficial.	3	0
1020	20	12	7	1001	27	\N	1450	2026-05-20 07:40:00-06	Crisis hipertensiva.	Hipertensión descompensada.	1	2
1021	31	22	101	1032	114	\N	1523	2026-06-10 20:17:00-06	Dolor torácico.	Síndrome coronario en estudio.	4	2
1022	42	32	202	1036	213	\N	1594	2026-07-01 08:54:00-06	Fiebre alta y deshidratación.	Cuadro viral.	2	2
1023	53	42	303	1046	318	\N	1667	2026-07-22 21:31:00-06	Traumatismo por caída.	Contusión.	5	2
1024	64	52	404	1047	411	\N	1738	2026-08-12 10:08:00-06	Dificultad respiratoria.	Crisis asmática.	3	2
1025	8	12	5	1005	26	\N	1801	2026-09-02 22:45:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	1	0
1026	19	22	106	1031	115	\N	1872	2026-09-23 11:22:00-06	Herida cortante en extremidad.	Herida superficial.	4	3
1027	30	32	207	1037	214	\N	1945	2026-10-14 23:59:00-06	Crisis hipertensiva.	Hipertensión descompensada.	2	0
1028	41	42	301	1042	318	\N	1066	2026-01-23 12:36:00-06	Dolor torácico.	Síndrome coronario en estudio.	5	3
1029	52	52	402	1048	412	\N	1139	2026-02-14 01:13:00-06	Fiebre alta y deshidratación.	Cuadro viral.	3	0
1030	63	12	3	1001	25	\N	1200	2026-03-06 13:50:00-06	Traumatismo por caída.	Contusión.	1	0
1031	7	22	104	1032	116	\N	1273	2026-03-28 02:27:00-06	Dificultad respiratoria.	Crisis asmática.	4	0
1032	18	32	205	1036	211	\N	1344	2026-04-17 15:04:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	2	0
1033	29	42	306	1046	318	\N	1417	2026-05-09 03:41:00-06	Herida cortante en extremidad.	Herida superficial.	5	0
1034	40	52	407	1047	413	\N	1488	2026-05-29 16:18:00-06	Crisis hipertensiva.	Hipertensión descompensada.	3	0
1035	51	12	1	1006	30	\N	1551	2026-06-20 04:55:00-06	Dolor torácico.	Síndrome coronario en estudio.	1	2
1036	62	22	102	1031	113	\N	1622	2026-07-10 17:32:00-06	Fiebre alta y deshidratación.	Cuadro viral.	4	2
1037	6	32	203	1037	212	\N	1695	2026-08-01 06:09:00-06	Traumatismo por caída.	Contusión.	2	2
1038	17	42	304	1041	318	\N	1766	2026-08-21 07:06:00-06	Dificultad respiratoria.	Crisis asmática.	5	2
1039	28	52	405	1048	414	\N	1839	2026-09-11 19:43:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	3	2
1040	39	12	6	1005	29	\N	1900	2026-10-02 08:20:00-06	Herida cortante en extremidad.	Herida superficial.	1	0
1041	50	22	107	1032	114	\N	1023	2026-01-11 20:57:00-06	Crisis hipertensiva.	Hipertensión descompensada.	4	3
1042	61	32	201	1036	213	\N	1094	2026-02-01 09:34:00-06	Dolor torácico.	Síndrome coronario en estudio.	2	0
1043	5	42	302	1042	318	\N	1167	2026-02-22 22:11:00-06	Fiebre alta y deshidratación.	Cuadro viral.	5	3
1044	16	52	403	1047	411	\N	1238	2026-03-15 10:48:00-06	Traumatismo por caída.	Contusión.	3	3
1045	27	12	4	1006	28	\N	1301	2026-04-05 23:25:00-06	Dificultad respiratoria.	Crisis asmática.	1	0
1046	38	22	105	1031	115	\N	1372	2026-04-26 12:02:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	4	0
1047	49	32	206	1037	214	\N	1445	2026-05-18 00:39:00-06	Herida cortante en extremidad.	Herida superficial.	2	0
1048	60	42	307	1041	318	\N	1516	2026-06-07 13:16:00-06	Crisis hipertensiva.	Hipertensión descompensada.	5	0
1049	4	52	401	1048	412	\N	1589	2026-06-29 01:53:00-06	Dolor torácico.	Síndrome coronario en estudio.	3	0
1050	15	12	2	1001	27	\N	1650	2026-07-19 14:30:00-06	Fiebre alta y deshidratación.	Cuadro viral.	1	0
1051	26	22	103	1035	116	\N	1723	2026-08-10 03:07:00-06	Traumatismo por caída.	Contusión.	4	0
1052	37	32	204	1036	211	\N	1794	2026-08-30 15:44:00-06	Dificultad respiratoria.	Crisis asmática.	2	0
1053	48	42	305	1042	318	\N	1867	2026-09-21 04:21:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	5	0
1054	59	52	406	1047	413	\N	1938	2026-10-11 16:58:00-06	Herida cortante en extremidad.	Herida superficial.	3	0
1055	3	12	7	1006	26	\N	1051	2026-01-21 05:35:00-06	Crisis hipertensiva.	Hipertensión descompensada.	1	0
1056	14	22	101	1032	113	\N	1122	2026-02-10 18:12:00-06	Dolor torácico.	Síndrome coronario en estudio.	4	3
1057	25	32	202	1037	212	\N	1195	2026-03-03 19:09:00-06	Fiebre alta y deshidratación.	Cuadro viral.	2	3
1058	36	42	303	1041	318	\N	1266	2026-03-24 07:46:00-06	Traumatismo por caída.	Contusión.	5	3
1059	47	52	404	1048	414	\N	1339	2026-04-14 20:23:00-06	Dificultad respiratoria.	Crisis asmática.	3	3
1060	58	12	5	1001	25	\N	1400	2026-05-05 09:00:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	1	0
1061	2	22	106	1035	114	\N	1473	2026-05-26 21:37:00-06	Herida cortante en extremidad.	Herida superficial.	4	0
1062	13	32	207	1036	213	\N	1544	2026-06-16 10:14:00-06	Crisis hipertensiva.	Hipertensión descompensada.	2	0
1063	24	42	301	1046	318	\N	1617	2026-07-07 22:51:00-06	Dolor torácico.	Síndrome coronario en estudio.	5	1
1064	35	52	402	1047	411	\N	1688	2026-07-28 11:28:00-06	Fiebre alta y deshidratación.	Cuadro viral.	3	0
1065	46	12	3	1005	30	\N	1751	2026-08-19 00:05:00-06	Traumatismo por caída.	Contusión.	1	0
1066	57	22	104	1031	115	\N	1822	2026-09-08 12:42:00-06	Dificultad respiratoria.	Crisis asmática.	4	0
1067	1	32	205	1037	214	\N	1895	2026-09-30 01:19:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	2	0
1068	12	42	306	1041	318	\N	1016	2026-01-08 13:56:00-06	Herida cortante en extremidad.	Herida superficial.	5	0
1069	23	52	407	1048	412	\N	1089	2026-01-30 02:33:00-06	Crisis hipertensiva.	Hipertensión descompensada.	3	0
1070	34	12	1	1001	29	\N	1150	2026-02-19 15:10:00-06	Dolor torácico.	Síndrome coronario en estudio.	1	3
1071	45	22	102	1032	116	\N	1223	2026-03-13 03:47:00-06	Fiebre alta y deshidratación.	Cuadro viral.	4	3
1072	56	32	203	1036	211	\N	1294	2026-04-02 16:24:00-06	Traumatismo por caída.	Contusión.	2	3
1073	67	42	304	1046	318	\N	1367	2026-04-24 05:01:00-06	Dificultad respiratoria.	Crisis asmática.	5	3
1074	11	52	405	1047	413	\N	1438	2026-05-14 17:38:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	3	3
1075	22	12	6	1005	28	\N	1501	2026-06-05 06:15:00-06	Herida cortante en extremidad.	Herida superficial.	1	0
1076	33	22	107	1031	113	\N	1572	2026-06-25 07:12:00-06	Crisis hipertensiva.	Hipertensión descompensada.	4	1
1077	44	32	201	1037	212	\N	1645	2026-07-16 19:49:00-06	Dolor torácico.	Síndrome coronario en estudio.	2	0
1078	55	42	302	1041	318	\N	1716	2026-08-06 08:26:00-06	Fiebre alta y deshidratación.	Cuadro viral.	5	1
1079	66	52	403	1048	414	\N	1789	2026-08-27 21:03:00-06	Traumatismo por caída.	Contusión.	3	0
1080	10	12	4	1001	27	\N	1850	2026-09-17 09:40:00-06	Dificultad respiratoria.	Crisis asmática.	1	0
1081	21	22	105	1032	114	\N	1923	2026-10-08 22:17:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	4	0
1082	32	32	206	1036	213	\N	1044	2026-01-17 10:54:00-06	Herida cortante en extremidad.	Herida superficial.	2	0
1083	43	42	307	1046	318	\N	1117	2026-02-07 23:31:00-06	Crisis hipertensiva.	Hipertensión descompensada.	5	0
1084	54	52	401	1047	411	\N	1188	2026-02-28 12:08:00-06	Dolor torácico.	Síndrome coronario en estudio.	3	0
1085	65	12	2	1006	26	\N	1251	2026-03-22 00:45:00-06	Fiebre alta y deshidratación.	Cuadro viral.	1	3
1086	9	22	103	1031	115	\N	1322	2026-04-11 13:22:00-06	Traumatismo por caída.	Contusión.	4	3
1087	20	32	204	1037	214	\N	1395	2026-05-03 01:59:00-06	Dificultad respiratoria.	Crisis asmática.	2	3
1088	31	42	305	1041	318	\N	1466	2026-05-23 14:36:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	5	3
1089	42	52	406	1048	412	\N	1539	2026-06-14 03:13:00-06	Herida cortante en extremidad.	Herida superficial.	3	3
1090	53	12	7	1005	25	\N	1600	2026-07-04 15:50:00-06	Crisis hipertensiva.	Hipertensión descompensada.	1	0
1091	64	22	101	1035	116	\N	1673	2026-07-26 04:27:00-06	Dolor torácico.	Síndrome coronario en estudio.	4	1
1092	8	32	202	1036	211	\N	1744	2026-08-15 17:04:00-06	Fiebre alta y deshidratación.	Cuadro viral.	2	0
1093	19	42	303	1042	318	\N	1817	2026-09-06 05:41:00-06	Traumatismo por caída.	Contusión.	5	1
1094	30	52	404	1047	413	\N	1888	2026-09-26 18:18:00-06	Dificultad respiratoria.	Crisis asmática.	3	1
1095	41	12	5	1006	30	\N	1001	2026-01-05 19:15:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	1	0
1096	52	22	106	1031	113	\N	1072	2026-01-26 07:52:00-06	Herida cortante en extremidad.	Herida superficial.	4	0
1097	63	32	207	1037	212	\N	1145	2026-02-16 20:29:00-06	Crisis hipertensiva.	Hipertensión descompensada.	2	0
1098	7	42	301	1041	318	\N	1216	2026-03-09 09:06:00-06	Dolor torácico.	Síndrome coronario en estudio.	5	0
1099	18	52	402	1048	414	\N	1289	2026-03-30 21:43:00-06	Fiebre alta y deshidratación.	Cuadro viral.	3	0
1100	29	12	3	1001	29	\N	1350	2026-04-20 10:20:00-06	Traumatismo por caída.	Contusión.	1	0
1101	40	22	104	1035	114	\N	1423	2026-05-11 22:57:00-06	Dificultad respiratoria.	Crisis asmática.	4	0
1102	51	32	205	1036	213	\N	1494	2026-06-01 11:34:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	2	0
1103	62	42	306	1042	318	\N	1567	2026-06-23 00:11:00-06	Herida cortante en extremidad.	Herida superficial.	5	0
1104	6	52	407	1047	411	\N	1638	2026-07-13 12:48:00-06	Crisis hipertensiva.	Hipertensión descompensada.	3	0
1105	17	12	1	1005	28	\N	1701	2026-08-04 01:25:00-06	Dolor torácico.	Síndrome coronario en estudio.	1	0
1106	28	22	102	1031	115	\N	1772	2026-08-24 14:02:00-06	Fiebre alta y deshidratación.	Cuadro viral.	4	1
1107	39	32	203	1037	214	\N	1845	2026-09-15 02:39:00-06	Traumatismo por caída.	Contusión.	2	1
1108	50	42	304	1041	318	\N	1916	2026-10-05 15:16:00-06	Dificultad respiratoria.	Crisis asmática.	5	1
1109	61	52	405	1048	412	\N	1039	2026-01-15 03:53:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	3	1
1110	5	12	6	1001	27	\N	1100	2026-02-04 16:30:00-06	Herida cortante en extremidad.	Herida superficial.	1	0
1111	16	22	107	1035	116	\N	1173	2026-02-26 05:07:00-06	Crisis hipertensiva.	Hipertensión descompensada.	4	0
1112	27	32	201	1036	211	\N	1244	2026-03-18 17:44:00-06	Dolor torácico.	Síndrome coronario en estudio.	2	0
1113	38	42	302	1046	318	\N	1317	2026-04-09 06:21:00-06	Fiebre alta y deshidratación.	Cuadro viral.	5	2
1114	49	52	403	1047	413	\N	1388	2026-04-29 07:18:00-06	Traumatismo por caída.	Contusión.	3	0
1115	60	12	4	1005	26	\N	1451	2026-05-20 19:55:00-06	Dificultad respiratoria.	Crisis asmática.	1	0
1116	4	22	105	1031	113	\N	1522	2026-06-10 08:32:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	4	0
1117	15	32	206	1037	212	\N	1595	2026-07-01 21:09:00-06	Herida cortante en extremidad.	Herida superficial.	2	0
1118	26	42	307	1042	318	\N	1666	2026-07-22 09:46:00-06	Crisis hipertensiva.	Hipertensión descompensada.	5	0
1119	37	52	401	1048	414	\N	1739	2026-08-12 22:23:00-06	Dolor torácico.	Síndrome coronario en estudio.	3	0
1120	48	12	2	1001	25	\N	1800	2026-09-02 11:00:00-06	Fiebre alta y deshidratación.	Cuadro viral.	1	1
1122	3	32	204	1036	213	\N	1944	2026-10-14 12:14:00-06	Dificultad respiratoria.	Crisis asmática.	2	1
1123	14	42	305	1046	318	\N	1067	2026-01-24 00:51:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	5	1
1124	25	52	406	1047	411	\N	1138	2026-02-13 13:28:00-06	Herida cortante en extremidad.	Herida superficial.	3	1
1125	36	12	7	1005	30	\N	1201	2026-03-07 02:05:00-06	Crisis hipertensiva.	Hipertensión descompensada.	1	0
1126	47	22	101	1031	115	\N	1272	2026-03-27 14:42:00-06	Dolor torácico.	Síndrome coronario en estudio.	4	2
1127	58	32	202	1037	214	\N	1345	2026-04-18 03:19:00-06	Fiebre alta y deshidratación.	Cuadro viral.	2	0
1128	2	42	303	1041	318	\N	1416	2026-05-08 15:56:00-06	Traumatismo por caída.	Contusión.	5	2
1129	13	52	404	1048	412	\N	1489	2026-05-30 04:33:00-06	Dificultad respiratoria.	Crisis asmática.	3	0
1130	24	12	5	1001	29	\N	1550	2026-06-19 17:10:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	1	0
1131	35	22	106	1032	116	\N	1623	2026-07-11 05:47:00-06	Herida cortante en extremidad.	Herida superficial.	4	0
1132	46	32	207	1036	211	\N	1694	2026-07-31 18:24:00-06	Crisis hipertensiva.	Hipertensión descompensada.	2	0
1133	57	42	301	1042	318	\N	1767	2026-08-21 19:21:00-06	Dolor torácico.	Síndrome coronario en estudio.	5	0
1134	1	52	402	1047	413	\N	1838	2026-09-11 07:58:00-06	Fiebre alta y deshidratación.	Cuadro viral.	3	0
1135	12	12	3	1006	28	\N	1901	2026-10-02 20:35:00-06	Traumatismo por caída.	Contusión.	1	1
1136	23	22	104	1031	113	\N	1022	2026-01-11 09:12:00-06	Dificultad respiratoria.	Crisis asmática.	4	1
1137	34	32	205	1037	212	\N	1095	2026-02-01 21:49:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	2	1
1138	45	42	306	1041	318	\N	1166	2026-02-22 10:26:00-06	Herida cortante en extremidad.	Herida superficial.	5	1
1139	56	52	407	1048	414	\N	1239	2026-03-15 23:03:00-06	Crisis hipertensiva.	Hipertensión descompensada.	3	1
1140	67	12	1	1005	27	\N	1300	2026-04-05 11:40:00-06	Dolor torácico.	Síndrome coronario en estudio.	1	0
1141	11	22	102	1035	114	\N	1373	2026-04-27 00:17:00-06	Fiebre alta y deshidratación.	Cuadro viral.	4	2
1142	22	32	203	1036	213	\N	1444	2026-05-17 12:54:00-06	Traumatismo por caída.	Contusión.	2	0
1143	33	42	304	1042	318	\N	1517	2026-06-08 01:31:00-06	Dificultad respiratoria.	Crisis asmática.	5	2
1144	44	52	405	1047	411	\N	1588	2026-06-28 14:08:00-06	Dolor abdominal agudo.	Abdomen agudo en estudio.	3	2
1145	55	12	6	1006	26	\N	1651	2026-07-20 02:45:00-06	Herida cortante en extremidad.	Herida superficial.	1	0
1146	66	22	107	1032	115	\N	1722	2026-08-09 15:22:00-06	Crisis hipertensiva.	Hipertensión descompensada.	4	0
1147	10	32	201	1037	214	\N	1795	2026-08-31 03:59:00-06	Dolor torácico.	Síndrome coronario en estudio.	2	0
1148	21	42	302	1041	318	\N	1866	2026-09-20 16:36:00-06	Fiebre alta y deshidratación.	Cuadro viral.	5	0
1149	32	52	403	1048	412	\N	1939	2026-10-12 05:13:00-06	Traumatismo por caída.	Contusión.	3	0
1150	43	12	4	1001	25	\N	1050	2026-01-20 17:50:00-06	Dificultad respiratoria.	Crisis asmática.	1	0
\.


--
-- Data for Name: institucion_externa; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.institucion_externa (id_institucion, nombre, direccion, id_municipio) FROM stdin;
1	Sanatorio Privado Los Cipreses	4a. calle 12-30, zona 1	1
2	Centro Médico Costa Sur	Km 198 carretera al Pacífico	2
\.


--
-- Data for Name: instrumento; Type: TABLE DATA; Schema: public; Owner: admin
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
-- Data for Name: insumo; Type: TABLE DATA; Schema: public; Owner: admin
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
-- Data for Name: medicamento; Type: TABLE DATA; Schema: public; Owner: admin
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
-- Data for Name: medico; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.medico (id_medico, nombres, apellidos, dpi, telefono, id_hospital, id_municipio, area, id_especialidad, tipo_medico, costo_primera_consulta, horario_inicio, horario_fin, tipo_personal, cargo, id_medico_superior) FROM stdin;
1007	Hilda	Cifuentes Rojas	2001123450107	5551-2007	2	6	Urbana	316	externo	\N	\N	\N	medico	medico	\N
1020	René	Iguarán Solís	2001123450120	5551-2020	1	1	Urbana	319	externo	\N	\N	\N	medico	medico	\N
1021	Wilfredo	Chávez Orozco	2001123450121	5551-2021	2	6	Urbana	320	externo	\N	\N	\N	medico	medico	\N
1022	Ana	Lucero Fuentes	2001123450122	5551-2022	3	1	Urbana	321	externo	\N	\N	\N	medico	medico	\N
1023	Héctor	Quirós Barrios	2001123450123	5551-2023	1	3	Urbana	322	externo	\N	\N	\N	medico	medico	\N
1024	Verónica	Aranda Cruz	2001123450124	5551-2024	2	1	Urbana	323	externo	\N	\N	\N	medico	medico	\N
1025	Gustavo	Rivas Monzón	2001123450125	5551-2025	3	7	Urbana	324	externo	\N	\N	\N	medico	medico	\N
1026	Mónica	Figueroa Lam	2001123450126	5551-2026	1	1	Urbana	325	externo	\N	\N	\N	medico	medico	\N
1027	Pablo	Tzoc Ajcá	2001123450127	5551-2027	2	6	Urbana	326	externo	\N	\N	\N	medico	medico	\N
1028	Isabel	Contreras Mejía	2001123450128	5551-2028	3	1	Urbana	327	externo	\N	\N	\N	medico	medico	\N
1029	Carlos	Menéndez Ralda	2001123450129	5551-2029	1	3	Urbana	328	externo	\N	\N	\N	medico	medico	\N
1030	Luis	Zambrano Sic	2001123450130	5551-2030	2	6	Urbana	329	externo	\N	\N	\N	medico	medico	\N
1001	Carmen	Ruiz Palacios	2001123450101	5551-2001	1	1	Urbana	307	general	200.00	08:00:00	12:00:00	medico	medico	1005
1015	Andrés	Chinchilla Paz	2001123450115	5551-2015	1	1	Urbana	307	general	130.00	08:00:00	12:00:00	medico	medico	1011
1004	Julia	Paredes Ovalle	2001123450104	5551-2004	1	1	Urbana	312	especialista	180.00	08:00:00	12:00:00	medico	medico	1011
1002	Roberto	Castillo Méndez	2001123450102	5551-2002	1	3	Urbana	301	especialista	220.00	08:00:00	11:30:00	medico	director_medico	\N
1006	Alejandro	Ramírez Lemus	2001123450106	5551-2006	1	1	Urbana	315	residente	\N	\N	\N	medico	medico	1005
1008	Daniel	Morales Peña	2001123450108	5551-2008	1	1	Urbana	318	interno	\N	\N	\N	medico	medico	1006
1003	Andrea	Soto Fuentes	2001123450103	5551-2003	1	6	Rural	303	especialista	160.00	09:00:00	12:00:00	medico	medico	1011
1010	Elena	Vásquez Sotelo	2001123450110	5551-2010	1	1	Urbana	302	especialista	180.00	08:00:00	12:00:00	medico	medico	1011
1013	Fernando	López Arriaga	2001123450113	5551-2013	1	3	Urbana	306	especialista	175.00	09:00:00	12:00:00	medico	medico	1011
1017	Ricardo	Batz Coyoy	2001123450117	5551-2017	1	1	Urbana	311	especialista	165.00	09:00:00	12:00:00	medico	medico	1011
1018	Silvia	Gómez Tuch	2001123450118	5551-2018	1	3	Urbana	314	especialista	140.00	08:00:00	12:00:00	medico	medico	1017
1032	Esteban	Orozco Bámaca	2001123450132	5551-2032	2	6	Rural	307	general	160.00	08:00:00	12:00:00	medico	medico	1031
1035	Marisol	Ajanel Pérez	2001123450135	5551-2035	2	6	Urbana	315	residente	\N	\N	\N	medico	medico	1031
1014	Claudia	Recinos Toj	2001123450114	5551-2014	2	6	Urbana	308	especialista	150.00	08:00:00	12:00:00	medico	medico	1012
1019	Julio	Estrada Mazariegos	2001123450119	5551-2019	2	6	Urbana	313	especialista	190.00	08:00:00	12:00:00	medico	medico	1012
1034	Iván	Coyoy Tzul	2001123450134	5551-2034	2	13	Urbana	312	especialista	190.00	08:00:00	12:00:00	medico	medico	1012
1037	Brenda	Sic Ixcot	2001123450137	5551-2037	3	14	Rural	307	general	150.00	08:00:00	12:00:00	medico	medico	1036
1040	Samuel	Barrios Juárez	2001123450140	5551-2040	3	8	Urbana	326	especialista	\N	\N	\N	medico	medico	1036
1016	Paola	Sandoval Itzep	2001123450116	5551-2016	3	7	Urbana	310	especialista	185.00	08:00:00	12:00:00	medico	medico	1009
1039	Gloria	Tax Chiquitó	2001123450139	5551-2039	3	8	Urbana	302	especialista	175.00	09:00:00	12:00:00	medico	medico	1009
1042	Héctor Manuel	Gómez Ordóñez	2001123450142	5551-2042	4	10	Rural	307	general	150.00	08:00:00	12:00:00	medico	medico	1041
1046	Kevin	Domingo Pascual	2001123450146	5551-2046	4	10	Rural	318	interno	\N	\N	\N	medico	medico	1042
1044	Jorge Mario	Alvarado Castillo	2001123450144	5551-2044	4	9	Urbana	304	especialista	205.00	09:00:00	12:00:00	medico	medico	1045
1048	Diego	Yaxón Bocel	2001123450148	5551-2048	5	11	Rural	307	general	145.00	08:00:00	12:00:00	medico	medico	1047
1051	Mónica	Pirir Cutzal	2001123450151	5551-2051	5	12	Urbana	311	especialista	160.00	09:00:00	12:00:00	medico	medico	1050
1005	Miguel	Barrios Donis	2001123450105	5551-2005	1	2	Rural	307	general	180.00	08:00:00	12:00:00	medico	jefe_servicio	1002
1009	Silvia	Vásquez Cotero	2001123450109	5551-2009	3	7	Urbana	317	especialista	\N	\N	\N	medico	jefe_servicio	1038
1011	Marcos	Aguilar Salazar	2001123450111	5551-2011	1	1	Urbana	304	especialista	210.00	09:00:00	12:00:00	medico	jefe_servicio	1002
1012	Gabriela	Nájera Ruiz	2001123450112	5551-2012	2	6	Urbana	305	especialista	195.00	08:00:00	11:30:00	medico	jefe_servicio	1033
1031	Rosa María	Fuentes Galindo	2001123450131	5551-2031	2	6	Urbana	307	general	170.00	08:00:00	12:00:00	medico	jefe_servicio	1033
1033	Leticia	Morales Chávez	2001123450133	5551-2033	2	6	Urbana	301	especialista	230.00	08:00:00	11:30:00	medico	director_medico	\N
1036	Otto René	Velásquez Lima	2001123450136	5551-2036	3	8	Urbana	307	general	165.00	08:00:00	12:00:00	medico	jefe_servicio	1038
1038	Mario	Cabrera Monterroso	2001123450138	5551-2038	3	8	Urbana	312	especialista	210.00	08:00:00	12:00:00	medico	director_medico	\N
1041	Ana Gabriela	Recinos Mérida	2001123450141	5551-2041	4	9	Urbana	307	general	160.00	08:00:00	12:00:00	medico	jefe_servicio	1043
1043	Carolina	Herrera Villatoro	2001123450143	5551-2043	4	9	Urbana	301	especialista	215.00	08:00:00	11:30:00	medico	director_medico	\N
1045	Patricia	López Mazariegos	2001123450145	5551-2045	4	9	Urbana	315	especialista	\N	\N	\N	medico	jefe_servicio	1043
1047	Lucía	Cumes Xajil	2001123450147	5551-2047	5	12	Urbana	307	general	150.00	08:00:00	12:00:00	medico	jefe_servicio	1049
1049	Sandra	Tuy Guarcax	2001123450149	5551-2049	5	11	Urbana	312	especialista	200.00	08:00:00	12:00:00	medico	director_medico	\N
1050	Alberto	Ramos Sajquiy	2001123450150	5551-2050	5	11	Urbana	324	especialista	\N	\N	\N	medico	jefe_servicio	1049
\.


--
-- Data for Name: metodo_pago; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.metodo_pago (id_metodo_pago, nombre) FROM stdin;
1	Efectivo
2	Tarjeta de crédito
3	Tarjeta de débito
4	Transferencia bancaria
\.


--
-- Data for Name: municipio; Type: TABLE DATA; Schema: public; Owner: admin
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
9	8	Huehuetenango
10	8	Chiantla
11	19	Sololá
12	19	Panajachel
13	17	Malacatán
14	15	San Sebastián
\.


--
-- Data for Name: paciente; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.paciente (id_paciente, numero_expediente, nombres, apellidos, fecha_nacimiento, sexo, dpi, telefono, id_municipio, area, id_estado_civil, numero_seguro_social) FROM stdin;
1	HG1-0001	María Fernanda	López García	1988-04-12	Femenino	2220123450123	5551-1001	1	Urbana	2	IGSS-88432
2	HG1-0002	Jorge Luis	Ramírez Sosa	1990-11-03	Masculino	3330123450456	5551-1002	6	Rural	1	\N
3	HG1-0003	Pedro	Gómez Aguilar	1975-07-22	Masculino	4440123450789	5551-1003	5	Rural	2	\N
4	HG1-0004	Ana Lucía	Méndez Cruz	2015-05-30	Femenino	\N	5551-1004	1	Urbana	1	IGSS-22150
5	HG1-0005	Carlos	De León Ortiz	1982-09-15	Masculino	6660123450123	5551-1005	3	Urbana	2	\N
6	HG2-0001	Sofía	Rivera Paz	2001-02-25	Femenino	7770123450650	5551-1006	6	Urbana	1	\N
7	HG1-0006	Luis Miguel	Castillo Fuentes	1968-01-19	Masculino	8880123450901	5551-1007	4	Rural	5	\N
8	HG4-0008	Paola	Méndez Soto	1955-08-06	Femenino	4100000000008	5518-1296	14	Urbana	4	IGSS-50904
9	HG5-0009	Andrés	Cruz Sic	1967-12-18	Masculino	4100000000009	5519-1333	9	Rural	5	\N
10	HG1-0010	Marta	Ortiz Tum	1980-04-30	Femenino	4100000000010	5520-1370	10	Urbana	1	\N
11	HG2-0011	Héctor	Fuentes Chávez	1992-09-11	Masculino	4100000000011	5521-1407	11	Urbana	2	\N
12	HG3-0012	Claudia	Vásquez Paz	2005-01-23	Femenino	4100000000012	5522-1444	12	Rural	3	IGSS-51356
13	HG4-0013	Rafael	Juárez Lima	2017-06-06	Masculino	\N	5523-1481	1	Urbana	1	\N
14	HG5-0014	Elena	Sosa Ixcot	1946-04-17	Femenino	4100000000014	5524-1518	2	Urbana	5	\N
15	HG1-0015	José Luis	Tzul Pop	1958-08-29	Masculino	4100000000015	5525-1555	3	Rural	1	\N
16	HG2-0016	Ana Belén	Coyoy Barrios	1971-01-10	Femenino	4100000000016	5526-1592	4	Urbana	2	IGSS-51808
17	HG3-0017	Miguel	Ajcá Chan	1983-05-24	Masculino	4100000000017	5527-1629	5	Urbana	3	\N
18	HG4-0018	Carmen	Xicará Ruiz	1995-10-05	Femenino	4100000000018	5528-1666	6	Rural	4	\N
19	HG5-0019	Luis Fernando	Batz Rojas	2008-02-16	Masculino	4100000000019	5529-1703	13	Urbana	5	\N
20	HG1-0020	Andrea	García Soto	2020-06-29	Femenino	\N	5530-1740	8	Urbana	1	IGSS-52260
21	HG2-0021	Mario	López Sic	1949-05-10	Masculino	4100000000021	5531-1777	14	Rural	2	\N
22	HG3-0022	Gabriela	Pérez Tum	1961-09-21	Femenino	4100000000022	5532-1814	9	Urbana	3	\N
23	HG4-0023	Pedro	Morales Chávez	1974-02-02	Masculino	4100000000023	5533-1851	10	Urbana	4	\N
24	HG5-0024	Verónica	Hernández Paz	1986-06-16	Femenino	4100000000024	5534-1888	11	Rural	5	IGSS-52712
25	HG1-0025	Ricardo	Castillo Lima	1998-10-28	Masculino	4100000000025	5535-1925	12	Urbana	1	\N
26	HG2-0026	Julia	Ramírez Ixcot	2011-03-11	Femenino	\N	5536-1962	1	Urbana	1	\N
27	HG3-0027	Fernando	Gómez Pop	2023-07-23	Masculino	\N	5537-1999	2	Rural	1	\N
28	HG4-0028	Daniela	Méndez Barrios	1952-06-02	Femenino	4100000000028	5538-2036	3	Urbana	4	IGSS-53164
29	HG5-0029	Óscar	Cruz Chan	1964-10-14	Masculino	4100000000029	5539-2073	4	Urbana	5	\N
30	HG1-0030	María José	Ortiz Ruiz	1977-02-25	Femenino	4100000000030	5540-2110	5	Rural	1	\N
31	HG2-0031	Carlos	Fuentes Rojas	1989-07-09	Masculino	4100000000031	5541-2147	6	Urbana	2	\N
32	HG3-0032	Lucía	Vásquez Soto	2001-11-20	Femenino	4100000000032	5542-2184	13	Urbana	3	IGSS-53616
33	HG4-0033	Juan Pablo	Juárez Sic	2014-04-03	Masculino	\N	5543-2221	8	Rural	1	\N
34	HG5-0034	Rosa Elena	Sosa Tum	1943-02-12	Femenino	4100000000034	5544-2258	14	Urbana	5	\N
35	HG1-0035	Diego	Tzul Chávez	1955-06-26	Masculino	4100000000035	5545-2295	9	Urbana	1	\N
36	HG2-0036	Sofía	Coyoy Paz	1967-11-07	Femenino	4100000000036	5546-2332	10	Rural	2	IGSS-54068
37	HG3-0037	Jorge	Ajcá Lima	1980-03-20	Masculino	4100000000037	5547-2369	11	Urbana	3	\N
38	HG4-0038	Paola	Xicará Ixcot	1992-08-01	Femenino	4100000000038	5548-2406	12	Urbana	4	\N
39	HG5-0039	Andrés	Batz Pop	2004-12-13	Masculino	4100000000039	5549-2443	1	Rural	5	\N
40	HG1-0040	Marta	García Barrios	2017-04-26	Femenino	\N	5550-2480	2	Urbana	1	IGSS-54520
41	HG2-0041	Héctor	López Chan	1946-03-07	Masculino	4100000000041	5551-2517	3	Urbana	2	\N
42	HG3-0042	Claudia	Pérez Ruiz	1958-07-19	Femenino	4100000000042	5552-2554	4	Rural	3	\N
43	HG4-0043	Rafael	Morales Rojas	1970-11-30	Masculino	4100000000043	5553-2591	5	Urbana	4	\N
44	HG5-0044	Elena	Hernández Soto	1983-04-13	Femenino	4100000000044	5554-2628	6	Urbana	5	IGSS-54972
45	HG1-0045	José Luis	Castillo Sic	1995-08-25	Masculino	4100000000045	5555-2665	13	Rural	1	\N
46	HG2-0046	Ana Belén	Ramírez Tum	2008-01-06	Femenino	4100000000046	5556-2702	8	Urbana	2	\N
47	HG3-0047	Miguel	Gómez Chávez	2020-05-19	Masculino	\N	5557-2739	14	Urbana	1	\N
48	HG4-0048	Carmen	Méndez Paz	1949-03-30	Femenino	4100000000048	5558-2776	9	Rural	4	IGSS-55424
49	HG5-0049	Luis Fernando	Cruz Lima	1961-08-11	Masculino	4100000000049	5559-2813	10	Urbana	5	\N
50	HG1-0050	Andrea	Ortiz Ixcot	1973-12-23	Femenino	4100000000050	5560-2850	11	Urbana	1	\N
51	HG2-0051	Mario	Fuentes Pop	1986-05-06	Masculino	4100000000051	5561-2887	12	Rural	2	\N
52	HG3-0052	Gabriela	Vásquez Barrios	1998-09-17	Femenino	4100000000052	5562-2924	1	Urbana	3	IGSS-55876
53	HG4-0053	Pedro	Juárez Chan	2011-01-29	Masculino	\N	5563-2961	2	Urbana	1	\N
54	HG5-0054	Verónica	Sosa Ruiz	2023-06-12	Femenino	\N	5564-2998	3	Rural	1	\N
55	HG1-0055	Ricardo	Tzul Rojas	1952-04-22	Masculino	4100000000055	5565-3035	4	Urbana	1	\N
56	HG2-0056	Julia	Coyoy Soto	1964-09-03	Femenino	4100000000056	5566-3072	5	Urbana	2	IGSS-56328
57	HG3-0057	Fernando	Ajcá Sic	1977-01-15	Masculino	4100000000057	5567-3109	6	Rural	3	\N
58	HG4-0058	Daniela	Xicará Tum	1989-05-29	Femenino	4100000000058	5568-3146	13	Urbana	4	\N
59	HG5-0059	Óscar	Batz Chávez	2001-10-10	Masculino	4100000000059	5569-3183	8	Urbana	5	\N
60	HG1-0060	María José	García Paz	2014-02-21	Femenino	\N	5570-3220	14	Rural	1	IGSS-56780
61	HG2-0061	Carlos	López Lima	1943-01-02	Masculino	4100000000061	5571-3257	9	Urbana	2	\N
62	HG3-0062	Lucía	Pérez Ixcot	1955-05-16	Femenino	4100000000062	5572-3294	10	Urbana	3	\N
63	HG4-0063	Juan Pablo	Morales Pop	1967-09-27	Masculino	4100000000063	5573-3331	11	Rural	4	\N
64	HG5-0064	Rosa Elena	Hernández Barrios	1980-02-08	Femenino	4100000000064	5574-3368	12	Urbana	5	IGSS-57232
65	HG1-0065	Diego	Castillo Chan	1992-06-21	Masculino	4100000000065	5575-3405	1	Urbana	1	\N
66	HG2-0066	Sofía	Ramírez Ruiz	2004-11-02	Femenino	4100000000066	5576-3442	2	Rural	2	\N
67	HG3-0067	Jorge	Gómez Rojas	2017-03-16	Masculino	\N	5577-3479	3	Urbana	1	\N
\.


--
-- Data for Name: paciente_encargado; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.paciente_encargado (id_paciente, id_encargado, id_parentesco) FROM stdin;
4	301	1
4	302	2
6	303	3
13	317	2
20	304	1
26	310	1
27	311	2
33	317	2
40	304	1
47	311	2
53	317	2
54	318	1
60	304	1
67	311	2
13	304	1
20	311	2
27	318	1
40	311	2
47	318	1
54	305	2
67	318	1
8	315	3
14	321	3
15	322	3
21	308	3
22	309	3
28	315	3
34	321	3
35	322	3
41	308	3
42	309	3
48	315	3
49	316	3
55	322	3
61	308	3
62	309	3
\.


--
-- Data for Name: pago; Type: TABLE DATA; Schema: public; Owner: admin
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
9	6	1	180.00	2026-01-18	2
10	7	1	130.00	2026-01-31	3
11	8	1	127.50	2026-02-13	1
12	9	1	150.00	2026-02-26	2
13	10	1	120.00	2026-03-24	3
14	11	1	144.00	2026-04-06	4
15	12	1	150.00	2026-04-19	2
16	13	1	142.50	2026-05-02	3
17	14	1	150.00	2026-05-28	1
18	15	1	150.00	2026-06-10	2
19	16	1	180.00	2026-06-23	3
20	17	1	140.00	2026-07-06	1
21	18	1	190.00	2026-08-01	2
22	19	1	160.00	2026-08-14	3
23	20	1	108.75	2026-08-27	1
24	21	1	160.00	2026-09-09	2
25	22	1	123.75	2026-10-05	4
26	23	1	230.00	2026-10-18	1
27	24	1	175.00	2026-01-14	2
28	25	1	112.50	2026-01-27	3
29	26	1	210.00	2026-02-22	1
30	27	1	138.75	2026-03-07	2
31	28	1	128.00	2026-03-20	3
32	29	1	210.00	2026-04-02	1
33	30	1	200.00	2026-04-28	2
34	31	1	180.00	2026-05-11	3
35	32	1	97.50	2026-05-24	1
36	33	1	170.00	2026-06-06	4
37	34	1	161.25	2026-07-02	3
38	35	1	160.00	2026-07-15	1
39	36	1	180.00	2026-07-28	2
40	37	1	112.50	2026-08-10	3
41	38	1	165.00	2026-09-05	1
42	39	1	112.50	2026-09-18	2
43	40	1	200.00	2026-10-01	3
44	41	1	180.00	2026-10-14	1
45	42	1	140.00	2026-01-23	2
46	43	1	190.00	2026-02-05	3
47	44	1	120.00	2026-02-18	4
48	45	1	116.00	2026-03-03	2
49	46	1	146.25	2026-03-29	3
50	47	1	165.00	2026-04-11	1
51	48	1	230.00	2026-04-24	2
52	49	1	131.25	2026-05-07	3
53	50	1	176.00	2026-06-02	1
54	51	1	157.50	2026-06-15	2
55	52	1	185.00	2026-06-28	3
56	53	1	160.00	2026-07-11	1
57	54	1	205.00	2026-08-06	2
58	55	1	200.00	2026-08-19	4
59	56	1	135.00	2026-09-01	1
60	57	1	130.00	2026-09-14	2
61	58	1	112.50	2026-10-10	3
62	59	1	215.00	2026-01-06	1
63	60	1	160.00	2026-01-19	2
64	61	1	135.00	2026-02-01	3
65	62	1	190.00	2026-02-27	1
66	63	1	123.75	2026-03-12	2
67	64	1	150.00	2026-03-25	3
68	65	1	200.00	2026-04-07	1
69	66	1	175.00	2026-05-03	4
70	67	1	112.00	2026-05-16	3
71	68	1	142.50	2026-05-29	1
72	69	1	160.00	2026-06-11	2
73	70	1	120.00	2026-07-07	3
74	71	1	195.00	2026-07-20	1
75	72	1	165.00	2026-08-02	2
76	73	1	172.50	2026-08-15	3
77	74	1	150.00	2026-09-10	1
78	75	1	165.00	2026-09-23	2
79	76	1	210.00	2026-10-06	3
80	77	1	185.00	2026-10-19	4
81	78	1	168.00	2026-01-28	2
82	79	1	205.00	2026-02-10	3
83	80	1	150.00	2026-02-23	1
84	81	1	180.00	2026-03-08	2
85	82	1	127.50	2026-04-03	3
86	83	1	150.00	2026-04-16	1
87	84	1	172.00	2026-04-29	2
88	85	1	120.00	2026-05-12	3
89	86	1	150.00	2026-06-07	1
90	87	1	142.50	2026-06-20	2
91	88	1	165.00	2026-07-03	4
92	89	1	150.00	2026-07-16	1
93	90	1	180.00	2026-08-11	2
94	91	1	175.00	2026-08-24	3
95	92	1	105.00	2026-09-06	1
96	93	1	190.00	2026-09-19	2
97	94	1	108.75	2026-10-15	3
98	95	1	128.00	2026-01-11	1
99	96	1	195.00	2026-01-24	2
100	97	1	123.75	2026-02-06	3
101	98	1	175.00	2026-03-04	1
102	99	1	112.50	2026-03-17	4
103	100	1	220.00	2026-03-30	3
104	101	1	168.00	2026-04-12	1
105	102	1	160.00	2026-05-08	2
106	103	1	210.00	2026-05-21	3
107	104	1	153.75	2026-06-03	1
108	105	1	200.00	2026-06-16	2
109	106	1	97.50	2026-07-12	3
110	107	1	170.00	2026-07-25	1
111	108	1	150.00	2026-08-07	2
112	109	1	161.25	2026-08-20	3
113	110	1	180.00	2026-09-15	4
114	111	1	112.50	2026-09-28	2
115	112	1	152.00	2026-10-11	3
116	113	1	165.00	2026-01-07	1
117	114	1	200.00	2026-02-02	2
118	115	1	180.00	2026-02-15	3
119	116	1	131.25	2026-02-28	1
120	117	1	140.00	2026-03-13	2
121	118	1	120.00	2026-04-08	3
122	119	1	145.00	2026-04-21	1
123	120	1	160.00	2026-05-04	2
124	121	1	146.25	2026-05-17	4
125	122	1	230.00	2026-06-12	1
126	123	1	131.25	2026-06-25	2
127	124	1	150.00	2026-07-08	3
128	125	1	220.00	2026-07-21	1
129	126	1	185.00	2026-08-16	2
130	127	1	160.00	2026-08-29	3
131	128	1	157.50	2026-09-11	1
132	129	1	164.00	2026-09-24	2
133	130	1	135.00	2026-10-20	3
134	131	1	130.00	2026-01-16	1
135	132	1	170.00	2026-01-29	4
136	133	1	112.50	2026-02-11	3
137	134	1	128.00	2026-03-09	1
138	135	1	135.00	2026-03-22	2
139	136	1	150.00	2026-04-04	3
140	137	1	190.00	2026-04-17	1
141	138	1	150.00	2026-05-13	2
142	139	1	200.00	2026-05-26	3
143	140	1	135.00	2026-06-08	1
144	141	1	175.00	2026-06-21	2
145	142	1	142.50	2026-07-17	3
146	143	1	160.00	2026-07-30	4
147	144	1	145.00	2026-08-12	2
148	145	1	120.00	2026-08-25	3
149	146	1	165.00	2026-09-20	1
150	147	1	172.50	2026-10-03	2
151	148	1	175.00	2026-10-16	3
152	149	1	150.00	2026-01-12	1
153	150	1	210.00	2026-02-07	2
154	151	1	148.00	2026-02-20	3
155	152	1	120.00	2026-03-05	1
156	153	1	210.00	2026-03-18	2
157	154	1	150.00	2026-04-13	4
158	155	1	180.00	2026-04-26	1
159	156	1	130.00	2026-05-09	2
160	157	1	127.50	2026-05-22	3
161	158	1	215.00	2026-06-17	1
162	159	1	120.00	2026-06-30	2
163	160	1	180.00	2026-07-13	3
164	161	1	150.00	2026-07-26	1
165	162	1	132.00	2026-08-21	2
166	163	1	150.00	2026-09-03	3
167	164	1	150.00	2026-09-16	1
168	165	1	180.00	2026-09-29	4
169	166	1	105.00	2026-01-08	3
170	167	1	190.00	2026-01-21	1
171	168	1	128.00	2026-02-03	2
172	169	1	108.75	2026-02-16	3
173	170	1	195.00	2026-03-14	1
174	171	1	123.75	2026-03-27	2
175	172	1	230.00	2026-04-09	3
176	173	1	175.00	2026-04-22	1
177	174	1	220.00	2026-05-18	2
178	175	1	210.00	2026-05-31	3
179	176	1	138.75	2026-06-13	4
180	177	1	160.00	2026-06-26	2
181	178	1	153.75	2026-07-22	3
182	179	1	160.00	2026-08-04	1
183	180	1	180.00	2026-08-17	2
184	181	1	97.50	2026-08-30	3
185	182	1	595.00	2026-01-27	1
186	182	2	595.00	2026-02-27	2
187	183	1	540.00	2026-02-16	2
188	183	2	540.00	2026-03-16	3
189	183	3	540.00	2026-04-16	1
190	184	1	180.00	2026-03-10	3
191	184	2	180.00	2026-04-10	1
192	184	3	180.00	2026-05-10	2
193	184	4	180.00	2026-06-10	3
194	185	1	525.00	2026-03-30	1
195	186	1	550.00	2026-04-21	2
196	186	2	550.00	2026-05-21	3
197	187	1	226.67	2026-05-11	4
198	187	2	226.67	2026-06-11	4
199	187	3	226.66	2026-07-11	4
200	188	1	1120.00	2026-06-23	1
201	189	1	675.00	2026-07-14	2
202	189	2	675.00	2026-08-14	3
203	190	1	300.00	2026-08-04	3
204	190	2	300.00	2026-09-04	1
205	190	3	300.00	2026-10-04	2
206	191	1	148.75	2026-08-25	1
207	191	2	148.75	2026-09-25	2
208	192	1	990.00	2026-09-15	2
209	193	1	320.00	2026-10-06	3
210	194	1	350.00	2026-02-05	1
211	194	2	350.00	2026-03-05	2
212	194	3	350.00	2026-04-05	3
213	194	4	350.00	2026-05-05	1
214	195	1	1530.00	2026-02-26	2
215	196	1	405.00	2026-03-20	3
216	196	2	405.00	2026-04-20	1
217	197	1	186.67	2026-04-09	1
218	197	2	186.67	2026-05-09	2
219	197	3	186.66	2026-06-09	3
220	198	1	206.25	2026-04-30	4
221	198	2	206.25	2026-05-30	4
222	198	3	206.25	2026-06-30	4
223	198	4	206.25	2026-07-30	4
224	199	1	800.00	2026-05-21	3
225	200	1	420.00	2026-07-02	1
226	200	2	420.00	2026-08-02	2
227	200	3	420.00	2026-09-02	3
228	201	1	360.00	2026-07-24	2
229	201	2	360.00	2026-08-24	3
230	201	3	360.00	2026-09-24	1
231	202	1	675.00	2026-08-13	3
232	203	1	350.00	2026-09-04	1
233	203	2	350.00	2026-10-04	2
234	204	1	311.67	2026-09-24	2
235	205	1	180.00	2026-10-16	3
236	206	1	525.00	2026-02-15	1
237	206	2	525.00	2026-03-15	2
238	207	1	600.00	2026-03-08	2
239	207	2	600.00	2026-04-08	3
240	207	3	600.00	2026-05-08	1
241	208	1	191.25	2026-03-29	3
242	208	2	191.25	2026-04-29	1
243	208	3	191.25	2026-05-29	2
244	208	4	191.25	2026-06-29	3
245	209	1	630.00	2026-04-19	4
246	210	1	440.00	2026-05-10	2
247	210	2	440.00	2026-06-10	3
248	211	1	200.00	2026-05-31	3
249	211	2	200.00	2026-06-30	1
250	211	3	200.00	2026-07-31	2
251	212	1	1190.00	2026-07-12	1
252	213	1	810.00	2026-08-02	2
253	213	2	810.00	2026-09-02	3
254	214	1	240.00	2026-08-23	3
255	214	2	240.00	2026-09-23	1
256	215	1	131.25	2026-09-13	1
257	215	2	131.25	2026-10-13	2
258	216	1	1100.00	2026-10-02	2
259	217	1	340.00	2026-01-12	3
260	217	2	340.00	2026-02-12	1
261	218	1	280.00	2026-02-23	1
262	218	2	280.00	2026-03-23	2
263	218	3	280.00	2026-04-23	3
264	218	4	280.00	2026-05-23	1
265	219	1	1350.00	2026-03-15	2
266	220	1	450.00	2026-04-06	4
267	220	2	450.00	2026-05-06	4
268	221	1	198.33	2026-04-26	1
269	221	2	198.33	2026-05-26	2
270	221	3	198.34	2026-06-26	3
271	222	1	247.50	2026-05-18	2
272	222	2	247.50	2026-06-18	3
273	222	3	247.50	2026-07-18	1
274	222	4	247.50	2026-08-18	2
275	223	1	640.00	2026-06-08	3
276	224	1	466.67	2026-07-20	1
277	224	2	466.67	2026-08-20	2
278	224	3	466.66	2026-09-20	3
279	225	1	382.50	2026-08-10	2
280	225	2	382.50	2026-09-10	3
281	225	3	382.50	2026-10-10	1
282	226	1	810.00	2026-08-31	3
283	227	1	280.00	2026-09-21	1
284	228	1	275.00	2026-10-12	2
285	229	1	200.00	2026-01-22	3
286	229	2	200.00	2026-02-22	1
287	229	3	200.00	2026-03-22	2
288	229	4	200.00	2026-04-22	3
289	230	1	630.00	2026-03-04	1
290	230	2	630.00	2026-04-04	2
291	231	1	480.00	2026-03-25	4
292	231	2	480.00	2026-04-25	4
293	231	3	480.00	2026-05-25	4
294	232	1	168.75	2026-04-15	3
295	232	2	168.75	2026-05-15	1
296	232	3	168.75	2026-06-15	2
297	232	4	168.75	2026-07-15	3
298	233	1	700.00	2026-05-06	1
299	234	1	467.50	2026-05-27	2
300	234	2	467.50	2026-06-27	3
301	235	1	240.00	2026-06-17	3
302	235	2	240.00	2026-07-17	1
303	235	3	240.00	2026-08-17	2
304	236	1	1050.00	2026-07-29	1
305	237	1	900.00	2026-08-20	2
306	237	2	900.00	2026-09-20	3
307	238	1	255.00	2026-09-09	3
308	238	2	255.00	2026-10-09	1
309	239	1	157.50	2026-10-01	1
310	240	1	880.00	2026-01-09	2
311	241	1	300.00	2026-01-31	3
312	241	2	300.00	2026-02-28	1
313	242	1	297.50	2026-03-14	4
314	242	2	297.50	2026-04-14	4
315	242	3	297.50	2026-05-14	4
316	242	4	297.50	2026-06-14	4
317	243	1	1620.00	2026-04-04	2
318	244	1	360.00	2026-04-25	3
319	244	2	360.00	2026-05-25	1
320	245	1	175.00	2026-05-16	1
321	245	2	175.00	2026-06-16	2
322	245	3	175.00	2026-07-16	3
323	246	1	275.00	2026-06-06	2
324	246	2	275.00	2026-07-06	3
325	246	3	275.00	2026-08-06	1
326	246	4	275.00	2026-09-06	2
327	247	1	680.00	2026-06-26	3
328	248	1	373.33	2026-08-08	1
329	248	2	373.33	2026-09-08	2
330	248	3	373.34	2026-10-08	3
331	249	1	337.50	2026-08-29	2
332	249	2	337.50	2026-09-29	3
333	250	1	900.00	2026-09-17	3
334	251	1	297.50	2026-10-09	1
335	252	1	330.00	2026-01-17	2
336	252	2	330.00	2026-02-17	3
337	252	3	330.00	2026-03-17	1
338	253	1	160.00	2026-02-08	4
339	253	2	160.00	2026-03-08	4
340	253	3	160.00	2026-04-08	4
341	253	4	160.00	2026-05-08	4
342	254	1	700.00	2026-03-22	1
343	254	2	700.00	2026-04-22	2
344	255	1	510.00	2026-04-11	2
345	255	2	510.00	2026-05-11	3
346	255	3	510.00	2026-06-11	1
347	256	1	202.50	2026-05-03	3
348	256	2	202.50	2026-06-03	1
349	256	3	202.50	2026-07-03	2
350	256	4	202.50	2026-08-03	3
351	257	1	560.00	2026-05-24	1
352	258	1	412.50	2026-06-14	2
353	258	2	412.50	2026-07-14	3
354	259	1	266.67	2026-07-05	3
355	259	2	266.67	2026-08-05	1
356	259	3	266.66	2026-09-05	2
357	260	1	1260.00	2026-08-16	1
358	261	1	720.00	2026-09-06	2
359	261	2	720.00	2026-10-06	3
360	262	1	225.00	2026-09-27	3
361	263	1	175.00	2026-01-06	1
362	263	2	175.00	2026-02-06	2
363	263	3	175.00	2026-03-06	3
364	263	4	175.00	2026-04-06	1
365	264	1	935.00	2026-01-27	4
366	265	1	360.00	2026-02-17	3
367	265	2	360.00	2026-03-17	1
368	266	1	262.50	2026-03-31	1
369	266	2	262.50	2026-04-30	2
370	266	3	262.50	2026-05-31	3
371	266	4	262.50	2026-06-30	1
372	267	1	1800.00	2026-04-21	2
373	268	1	382.50	2026-05-13	3
374	268	2	382.50	2026-06-13	1
375	269	1	210.00	2026-06-02	1
376	269	2	210.00	2026-07-02	2
377	269	3	210.00	2026-08-02	3
378	270	1	220.00	2026-06-24	2
379	270	2	220.00	2026-07-24	3
380	270	3	220.00	2026-08-24	1
381	270	4	220.00	2026-09-24	2
382	271	1	600.00	2026-07-14	3
383	272	1	396.67	2026-08-25	1
384	272	2	396.67	2026-09-25	2
385	273	1	405.00	2026-09-16	2
386	273	2	405.00	2026-10-16	3
387	274	1	720.00	2026-10-06	3
388	275	1	262.50	2026-01-16	4
389	275	2	262.50	2026-02-16	4
390	276	1	366.67	2026-02-06	2
391	276	2	366.67	2026-03-06	3
392	276	3	366.66	2026-04-06	1
393	277	1	170.00	2026-02-27	3
394	277	2	170.00	2026-03-27	1
395	277	3	170.00	2026-04-27	2
396	277	4	170.00	2026-05-27	3
397	278	1	560.00	2026-04-10	1
398	278	2	560.00	2026-05-10	2
399	279	1	450.00	2026-04-30	2
400	279	2	450.00	2026-05-30	3
401	279	3	450.00	2026-06-30	1
402	280	1	225.00	2026-05-22	3
403	280	2	225.00	2026-06-22	1
404	280	3	225.00	2026-07-22	2
405	280	4	225.00	2026-08-22	3
406	281	1	595.00	2026-06-12	1
407	282	1	495.00	2026-07-03	2
408	282	2	495.00	2026-08-03	3
409	283	1	213.33	2026-07-24	3
410	283	2	213.33	2026-08-24	1
411	283	3	213.34	2026-09-24	2
412	284	1	1400.00	2026-09-02	1
413	285	1	765.00	2026-09-24	2
414	286	1	270.00	2026-10-14	4
415	287	1	140.00	2026-01-24	1
416	287	2	140.00	2026-02-24	2
417	287	3	140.00	2026-03-24	3
418	287	4	140.00	2026-04-24	1
419	288	1	825.00	2026-02-13	2
420	289	1	400.00	2026-03-07	3
421	289	2	400.00	2026-04-07	1
422	290	1	315.00	2026-04-18	1
423	290	2	315.00	2026-05-18	2
424	290	3	315.00	2026-06-18	3
425	290	4	315.00	2026-07-18	1
426	291	1	1440.00	2026-05-09	2
427	292	1	337.50	2026-05-30	3
428	292	2	337.50	2026-06-30	1
429	293	1	233.33	2026-06-20	1
430	293	2	233.33	2026-07-20	2
431	293	3	233.34	2026-08-20	3
432	294	1	233.75	2026-07-11	2
433	294	2	233.75	2026-08-11	3
434	294	3	233.75	2026-09-11	1
435	294	4	233.75	2026-10-11	2
436	295	1	720.00	2026-08-01	3
437	296	1	350.00	2026-09-12	1
438	296	2	350.00	2026-10-12	2
439	297	1	450.00	2026-10-03	4
440	298	1	765.00	2026-01-12	3
441	299	1	315.00	2026-02-02	1
442	299	2	315.00	2026-03-02	2
443	300	1	293.33	2026-02-23	2
444	300	2	293.33	2026-03-23	3
445	300	3	293.34	2026-04-23	1
446	301	1	150.00	2026-03-16	3
447	301	2	150.00	2026-04-16	1
448	301	3	150.00	2026-05-16	2
449	301	4	150.00	2026-06-16	3
450	302	1	595.00	2026-04-28	1
451	302	2	595.00	2026-05-28	2
452	303	1	540.00	2026-05-18	2
453	303	2	540.00	2026-06-18	3
454	303	3	540.00	2026-07-18	1
455	304	1	180.00	2026-06-09	3
456	304	2	180.00	2026-07-09	1
457	304	3	180.00	2026-08-09	2
458	304	4	180.00	2026-09-09	3
459	305	1	525.00	2026-06-29	1
460	306	1	550.00	2026-07-21	2
461	306	2	550.00	2026-08-21	3
462	307	1	226.67	2026-08-10	3
463	307	2	226.67	2026-09-10	1
464	307	3	226.66	2026-10-10	2
465	308	1	1120.00	2026-09-22	4
466	309	1	675.00	2026-10-13	2
467	310	1	300.00	2026-01-22	3
468	310	2	300.00	2026-02-22	1
469	310	3	300.00	2026-03-22	2
470	311	1	450.00	2026-06-14	1
471	311	2	450.00	2026-07-14	2
472	311	3	450.00	2026-08-14	3
473	311	4	450.00	2026-09-14	1
474	312	1	1800.00	2026-06-14	2
475	313	1	900.00	2026-06-15	3
476	313	2	900.00	2026-07-15	1
477	314	1	255.00	2026-03-21	1
478	314	2	255.00	2026-04-21	2
479	314	3	255.00	2026-05-21	3
480	315	1	191.25	2026-03-21	2
481	315	2	191.25	2026-04-21	3
482	315	3	191.25	2026-05-21	1
483	315	4	191.25	2026-06-21	2
484	316	1	251.10	2026-01-15	3
485	316	2	251.10	2026-02-15	1
486	316	3	251.10	2026-03-15	2
487	316	4	251.10	2026-04-15	3
488	316	5	251.10	2026-05-15	1
489	316	6	251.10	2026-06-15	2
490	316	7	251.10	2026-07-15	3
491	316	8	251.10	2026-08-15	1
492	316	9	251.10	2026-09-15	2
493	316	10	251.10	2026-10-15	3
494	317	1	252.55	2026-01-21	1
495	317	2	252.55	2026-02-21	2
496	317	3	252.55	2026-03-21	3
497	317	4	252.55	2026-04-21	1
498	317	5	252.55	2026-05-21	2
499	317	6	252.55	2026-06-21	3
500	317	7	252.55	2026-07-21	1
501	317	8	252.55	2026-08-21	2
502	317	9	252.55	2026-09-21	3
503	318	1	256.63	2026-01-27	2
504	318	2	256.63	2026-02-27	3
505	318	3	256.63	2026-03-27	1
506	318	4	256.63	2026-04-27	2
507	318	5	256.63	2026-05-27	3
508	318	6	256.63	2026-06-27	1
509	318	7	256.63	2026-07-27	2
510	318	8	256.63	2026-08-27	3
511	318	9	256.63	2026-09-27	1
512	319	1	4945.00	2026-02-02	4
513	320	1	2563.00	2026-02-08	1
514	320	2	2563.00	2026-03-08	2
515	321	1	1650.00	2026-02-14	2
516	321	2	1650.00	2026-03-14	3
517	321	3	1650.00	2026-04-14	1
518	322	1	1386.75	2026-02-20	3
519	322	2	1386.75	2026-03-20	1
520	322	3	1386.75	2026-04-20	2
521	322	4	1386.75	2026-05-20	3
522	323	1	348.75	2026-02-23	1
523	323	2	348.75	2026-03-23	2
524	323	3	348.75	2026-04-23	3
525	323	4	348.75	2026-05-23	1
526	323	5	348.75	2026-06-23	2
527	323	6	348.75	2026-07-23	3
528	324	1	415.00	2026-03-01	2
529	324	2	415.00	2026-04-01	3
530	324	3	415.00	2026-05-01	1
531	324	4	415.00	2026-06-01	2
532	324	5	415.00	2026-07-01	3
533	324	6	415.00	2026-08-01	1
534	324	7	415.00	2026-09-01	2
535	325	1	385.13	2026-03-07	3
536	325	2	385.13	2026-04-07	1
537	325	3	385.13	2026-05-07	2
538	325	4	385.13	2026-06-07	3
539	325	5	385.13	2026-07-07	1
540	325	6	385.13	2026-08-07	2
541	325	7	385.13	2026-09-07	3
542	325	8	385.09	2026-10-07	1
543	326	1	380.22	2026-03-13	1
544	326	2	380.22	2026-04-13	2
545	326	3	380.22	2026-05-13	3
546	326	4	380.22	2026-06-13	1
547	326	5	380.22	2026-07-13	2
548	326	6	380.22	2026-08-13	3
549	326	7	380.22	2026-09-13	1
550	326	8	380.22	2026-10-13	2
551	327	1	373.95	2026-03-19	2
552	327	2	373.95	2026-04-19	3
553	327	3	373.95	2026-05-19	1
554	327	4	373.95	2026-06-19	2
555	327	5	373.95	2026-07-19	3
556	327	6	373.95	2026-08-19	1
557	327	7	373.95	2026-09-19	2
558	327	8	373.95	2026-10-19	3
559	328	1	455.91	2026-03-25	3
560	328	2	455.91	2026-04-25	1
561	328	3	455.91	2026-05-25	2
562	328	4	455.91	2026-06-25	3
563	328	5	455.91	2026-07-25	1
564	328	6	455.91	2026-08-25	2
565	328	7	455.91	2026-09-25	3
566	329	1	495.17	2026-03-31	1
567	329	2	495.17	2026-04-30	2
568	329	3	495.17	2026-05-31	3
569	329	4	495.17	2026-06-30	1
570	329	5	495.17	2026-07-31	2
571	329	6	495.17	2026-08-31	3
572	329	7	495.17	2026-09-30	1
573	330	1	3242.00	2026-04-12	4
574	330	2	3242.00	2026-05-12	4
575	331	1	607.67	2026-04-09	3
576	331	2	607.67	2026-05-09	1
577	331	3	607.66	2026-06-09	2
578	332	1	710.63	2026-04-15	1
579	332	2	710.63	2026-05-15	2
580	332	3	710.63	2026-06-15	3
581	332	4	710.61	2026-07-15	1
582	333	1	687.00	2026-04-21	2
583	333	2	687.00	2026-05-21	3
584	333	3	687.00	2026-06-21	1
585	333	4	687.00	2026-07-21	2
586	333	5	687.00	2026-08-21	3
587	334	1	648.50	2026-04-27	3
588	334	2	648.50	2026-05-27	1
589	334	3	648.50	2026-06-27	2
590	334	4	648.50	2026-07-27	3
591	334	5	648.50	2026-08-27	1
592	334	6	648.50	2026-09-27	2
593	335	1	593.00	2026-05-03	1
594	335	2	593.00	2026-06-03	2
595	335	3	593.00	2026-07-03	3
596	335	4	593.00	2026-08-03	1
597	335	5	593.00	2026-09-03	2
598	335	6	593.00	2026-10-03	3
599	336	1	465.56	2026-05-09	2
600	336	2	465.56	2026-06-09	3
601	336	3	465.56	2026-07-09	1
602	336	4	465.56	2026-08-09	2
603	336	5	465.56	2026-09-09	3
604	336	6	465.56	2026-10-09	1
605	337	1	669.40	2026-05-21	3
606	337	2	669.40	2026-06-21	1
607	337	3	669.40	2026-07-21	2
608	337	4	669.40	2026-08-21	3
609	337	5	669.40	2026-09-21	1
610	338	1	590.00	2026-05-27	1
611	338	2	590.00	2026-06-27	2
612	338	3	590.00	2026-07-27	3
613	338	4	590.00	2026-08-27	1
614	338	5	590.00	2026-09-27	2
615	339	1	172.50	2026-05-24	2
616	339	2	172.50	2026-06-24	3
617	339	3	172.50	2026-07-24	1
618	339	4	172.50	2026-08-24	2
619	339	5	172.50	2026-09-24	3
620	340	1	2438.00	2026-05-30	3
621	341	1	1706.25	2026-06-05	4
622	341	2	1706.25	2026-07-05	4
623	342	1	1421.67	2026-06-11	2
624	342	2	1421.67	2026-07-11	3
625	342	3	1421.66	2026-08-11	1
626	343	1	1195.25	2026-06-17	3
627	343	2	1195.25	2026-07-17	1
628	343	3	1195.25	2026-08-17	2
629	343	4	1195.25	2026-09-17	3
630	344	1	714.92	2026-06-29	1
631	344	2	714.92	2026-07-29	2
632	344	3	714.92	2026-08-29	3
633	344	4	714.92	2026-09-29	1
634	345	1	890.71	2026-07-05	2
635	345	2	890.71	2026-08-05	3
636	345	3	890.71	2026-09-05	1
637	345	4	890.71	2026-10-05	2
638	346	1	1001.25	2026-07-11	3
639	346	2	1001.25	2026-08-11	1
640	346	3	1001.25	2026-09-11	2
641	346	4	1001.25	2026-10-11	3
642	347	1	213.33	2026-07-08	1
643	347	2	213.33	2026-08-08	2
644	347	3	213.33	2026-09-08	3
645	347	4	213.33	2026-10-08	1
646	348	1	264.10	2026-07-14	2
647	348	2	264.10	2026-08-14	3
648	348	3	264.10	2026-09-14	1
649	348	4	264.10	2026-10-14	2
650	349	1	263.91	2026-07-20	3
651	349	2	263.91	2026-08-20	1
652	349	3	263.91	2026-09-20	2
653	349	4	263.91	2026-10-20	3
654	350	1	354.38	2026-07-26	1
655	350	2	354.38	2026-08-26	2
656	350	3	354.38	2026-09-26	3
657	351	1	2135.50	2026-08-07	2
658	351	2	2135.50	2026-09-07	3
659	352	1	1554.33	2026-08-13	4
660	352	2	1554.33	2026-09-13	4
661	352	3	1554.34	2026-10-13	4
662	353	1	1218.63	2026-08-19	1
663	353	2	1218.63	2026-09-19	2
664	353	3	1218.63	2026-10-19	3
665	354	1	1495.00	2026-08-25	2
666	354	2	1495.00	2026-09-25	3
667	355	1	371.00	2026-08-22	3
668	355	2	371.00	2026-09-22	1
669	356	1	364.29	2026-08-28	1
670	356	2	364.29	2026-09-28	2
671	357	1	380.25	2026-09-03	2
672	357	2	380.25	2026-10-03	3
673	358	1	462.25	2026-09-15	3
674	358	2	462.25	2026-10-15	1
675	359	1	464.09	2026-09-21	1
676	360	1	423.42	2026-09-27	2
677	361	1	5307.00	2026-10-03	3
678	362	1	2917.25	2026-10-09	1
679	363	1	835.00	2026-10-06	4
680	364	1	735.50	2026-10-12	3
681	365	1	592.33	2026-01-17	1
682	365	2	592.33	2026-02-17	2
683	365	3	592.33	2026-03-17	3
684	365	4	592.33	2026-04-17	1
685	365	5	592.33	2026-05-17	2
686	365	6	592.35	2026-06-17	3
687	366	1	559.71	2026-01-23	2
688	366	2	559.71	2026-02-23	3
689	366	3	559.71	2026-03-23	1
690	366	4	559.71	2026-04-23	2
691	366	5	559.71	2026-05-23	3
692	366	6	559.71	2026-06-23	1
693	366	7	559.74	2026-07-23	2
694	367	1	592.81	2026-01-29	3
695	367	2	592.81	2026-02-28	1
696	367	3	592.81	2026-03-29	2
697	367	4	592.81	2026-04-29	3
698	367	5	592.81	2026-05-29	1
699	367	6	592.81	2026-06-29	2
700	367	7	592.81	2026-07-29	3
701	367	8	592.83	2026-08-29	1
702	368	1	659.44	2026-02-04	1
703	368	2	659.44	2026-03-04	2
704	368	3	659.44	2026-04-04	3
705	368	4	659.44	2026-05-04	1
706	368	5	659.44	2026-06-04	2
707	368	6	659.44	2026-07-04	3
708	368	7	659.44	2026-08-04	1
709	368	8	659.44	2026-09-04	2
710	368	9	659.48	2026-10-04	3
711	369	1	1526.08	2026-01-20	2
712	369	2	1526.08	2026-02-20	3
713	369	3	1526.08	2026-03-20	1
714	369	4	1526.08	2026-04-20	2
715	369	5	1526.08	2026-05-20	3
716	369	6	1526.10	2026-06-20	1
717	370	1	1065.57	2026-01-27	3
718	370	2	1065.57	2026-02-27	1
719	370	3	1065.57	2026-03-27	2
720	370	4	1065.57	2026-04-27	3
721	370	5	1065.57	2026-05-27	1
722	370	6	1065.57	2026-06-27	2
723	370	7	1065.58	2026-07-27	3
724	371	1	985.44	2026-02-03	1
725	371	2	985.44	2026-03-03	2
726	371	3	985.44	2026-04-03	3
727	371	4	985.44	2026-05-03	1
728	371	5	985.44	2026-06-03	2
729	371	6	985.44	2026-07-03	3
730	371	7	985.44	2026-08-03	1
731	371	8	985.42	2026-09-03	2
732	372	1	1236.67	2026-02-06	2
733	372	2	1236.67	2026-03-06	3
734	372	3	1236.67	2026-04-06	1
735	372	4	1236.67	2026-05-06	2
736	372	5	1236.67	2026-06-06	3
737	372	6	1236.67	2026-07-06	1
738	372	7	1236.67	2026-08-06	2
739	372	8	1236.67	2026-09-06	3
740	372	9	1236.64	2026-10-06	1
741	373	1	881.30	2026-02-13	3
742	373	2	881.30	2026-03-13	1
743	373	3	881.30	2026-04-13	2
744	373	4	881.30	2026-05-13	3
745	373	5	881.30	2026-06-13	1
746	373	6	881.30	2026-07-13	2
747	373	7	881.30	2026-08-13	3
748	373	8	881.30	2026-09-13	1
749	373	9	881.30	2026-10-13	2
750	374	1	736.96	2026-02-27	4
751	374	2	736.96	2026-03-27	4
752	374	3	736.96	2026-04-27	4
753	374	4	736.96	2026-05-27	4
754	374	5	736.96	2026-06-27	4
755	374	6	736.96	2026-07-27	4
756	374	7	736.96	2026-08-27	4
757	374	8	736.96	2026-09-27	4
758	375	1	7060.00	2026-03-02	2
759	376	1	2475.33	2026-03-16	3
760	376	2	2475.33	2026-04-16	1
761	376	3	2475.34	2026-05-16	2
762	377	1	1820.38	2026-03-23	1
763	377	2	1820.38	2026-04-23	2
764	377	3	1820.38	2026-05-23	3
765	377	4	1820.36	2026-06-23	1
766	378	1	1316.92	2026-04-02	2
767	378	2	1316.92	2026-05-02	3
768	378	3	1316.92	2026-06-02	1
769	378	4	1316.92	2026-07-02	2
770	378	5	1316.92	2026-08-02	3
771	378	6	1316.90	2026-09-02	1
772	379	1	995.71	2026-04-09	3
773	379	2	995.71	2026-05-09	1
774	379	3	995.71	2026-06-09	2
775	379	4	995.71	2026-07-09	3
776	379	5	995.71	2026-08-09	1
777	379	6	995.71	2026-09-09	2
778	379	7	995.74	2026-10-09	3
779	380	1	942.50	2026-04-16	1
780	380	2	942.50	2026-05-16	2
781	380	3	942.50	2026-06-16	3
782	380	4	942.50	2026-07-16	1
783	380	5	942.50	2026-08-16	2
784	380	6	942.50	2026-09-16	3
785	380	7	942.50	2026-10-16	1
786	381	1	982.33	2026-04-19	2
787	381	2	982.33	2026-05-19	3
788	381	3	982.33	2026-06-19	1
789	381	4	982.33	2026-07-19	2
790	381	5	982.33	2026-08-19	3
791	381	6	982.33	2026-09-19	1
792	381	7	982.33	2026-10-19	2
793	382	1	781.75	2026-04-26	3
794	382	2	781.75	2026-05-26	1
795	382	3	781.75	2026-06-26	2
796	382	4	781.75	2026-07-26	3
797	382	5	781.75	2026-08-26	1
798	382	6	781.75	2026-09-26	2
799	383	1	1126.58	2026-05-10	1
800	383	2	1126.58	2026-06-10	2
801	383	3	1126.58	2026-07-10	3
802	383	4	1126.58	2026-08-10	1
803	383	5	1126.58	2026-09-10	2
804	383	6	1126.58	2026-10-10	3
805	384	1	8647.00	2026-05-13	2
806	385	1	3769.50	2026-05-20	4
807	385	2	3769.50	2026-06-20	4
808	386	1	2241.00	2026-05-27	1
809	386	2	2241.00	2026-06-27	2
810	386	3	2241.00	2026-07-27	3
811	387	1	1651.38	2026-06-03	2
812	387	2	1651.38	2026-07-03	3
813	387	3	1651.38	2026-08-03	1
814	387	4	1651.36	2026-09-03	2
815	388	1	1477.50	2026-06-13	3
816	388	2	1477.50	2026-07-13	1
817	388	3	1477.50	2026-08-13	2
818	388	4	1477.50	2026-09-13	3
819	388	5	1477.50	2026-10-13	1
820	389	1	1237.29	2026-06-20	1
821	389	2	1237.29	2026-07-20	2
822	389	3	1237.29	2026-08-20	3
823	389	4	1237.29	2026-09-20	1
824	389	5	1237.29	2026-10-20	2
825	390	1	894.44	2026-06-30	2
826	390	2	894.44	2026-07-30	3
827	390	3	894.44	2026-08-30	1
828	390	4	894.44	2026-09-30	2
829	391	1	1125.90	2026-07-07	3
830	391	2	1125.90	2026-08-07	1
831	391	3	1125.90	2026-09-07	2
832	391	4	1125.90	2026-10-07	3
833	392	1	692.21	2026-07-21	1
834	392	2	692.21	2026-08-21	2
835	392	3	692.21	2026-09-21	3
836	393	1	8734.00	2026-07-24	2
837	394	1	3516.75	2026-07-31	3
838	394	2	3516.75	2026-08-31	1
839	395	1	2943.33	2026-08-07	1
840	395	2	2943.33	2026-09-07	2
841	395	3	2943.34	2026-10-07	3
842	396	1	1884.50	2026-08-14	4
843	396	2	1884.50	2026-09-14	4
844	396	3	1884.50	2026-10-14	4
845	397	1	1857.25	2026-08-24	3
846	397	2	1857.25	2026-09-24	1
847	398	1	1130.00	2026-08-31	1
848	398	2	1130.00	2026-09-30	2
849	399	1	900.50	2026-09-07	2
850	399	2	900.50	2026-10-07	3
851	400	1	825.11	2026-09-10	3
852	400	2	825.11	2026-10-10	1
853	401	1	898.15	2026-09-17	1
854	401	2	898.15	2026-10-17	2
855	402	1	729.29	2026-10-01	2
856	403	1	12920.00	2026-10-04	3
\.


--
-- Data for Name: parentesco; Type: TABLE DATA; Schema: public; Owner: admin
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
-- Data for Name: personal; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.personal (id_personal, tipo_personal, nombres, apellidos, dpi, telefono, direccion, id_municipio, area, id_hospital, fecha_contratacion, salario, nivel_acceso) FROM stdin;
1003	medico	Andrea	Soto Fuentes	2001123450103	5551-2003	14 calle 14-53, zona 3	6	Rural	1	2015-07-23	18500.00	operativo
1006	medico	Alejandro	Ramírez Lemus	2001123450106	5551-2006	2 calle 17-56, zona 6	1	Urbana	1	2016-05-09	9500.00	operativo
1008	medico	Daniel	Morales Peña	2001123450108	5551-2008	4 calle 19-58, zona 8	1	Urbana	1	2016-11-19	6500.00	operativo
1010	medico	Elena	Vásquez Sotelo	2001123450110	5551-2010	6 calle 21-60, zona 10	1	Urbana	1	2017-06-01	18500.00	operativo
1013	medico	Fernando	López Arriaga	2001123450113	5551-2013	9 calle 24-63, zona 2	3	Urbana	1	2018-03-19	18500.00	operativo
1014	medico	Claudia	Recinos Toj	2001123450114	5551-2014	10 calle 25-64, zona 3	6	Urbana	2	2018-06-24	18500.00	operativo
1015	medico	Andrés	Chinchilla Paz	2001123450115	5551-2015	11 calle 26-65, zona 4	1	Urbana	1	2018-09-29	13000.00	operativo
1016	medico	Paola	Sandoval Itzep	2001123450116	5551-2016	12 calle 27-66, zona 5	7	Urbana	3	2019-01-04	18500.00	operativo
1017	medico	Ricardo	Batz Coyoy	2001123450117	5551-2017	13 calle 28-67, zona 6	1	Urbana	1	2019-04-11	18500.00	operativo
1018	medico	Silvia	Gómez Tuch	2001123450118	5551-2018	14 calle 29-68, zona 7	3	Urbana	1	2019-07-17	18500.00	operativo
1019	medico	Julio	Estrada Mazariegos	2001123450119	5551-2019	15 calle 30-69, zona 8	6	Urbana	2	2019-10-22	18500.00	operativo
1007	medico	Hilda	Cifuentes Rojas	2001123450107	5551-2007	3 calle 18-57, zona 7	6	Urbana	2	\N	\N	consulta
1020	medico	René	Iguarán Solís	2001123450120	5551-2020	1 calle 1-70, zona 9	1	Urbana	1	\N	\N	consulta
1021	medico	Wilfredo	Chávez Orozco	2001123450121	5551-2021	2 calle 2-71, zona 10	6	Urbana	2	\N	\N	consulta
1022	medico	Ana	Lucero Fuentes	2001123450122	5551-2022	3 calle 3-72, zona 11	1	Urbana	3	\N	\N	consulta
1023	medico	Héctor	Quirós Barrios	2001123450123	5551-2023	4 calle 4-73, zona 1	3	Urbana	1	\N	\N	consulta
1024	medico	Verónica	Aranda Cruz	2001123450124	5551-2024	5 calle 5-74, zona 2	1	Urbana	2	\N	\N	consulta
1025	medico	Gustavo	Rivas Monzón	2001123450125	5551-2025	6 calle 6-75, zona 3	7	Urbana	3	\N	\N	consulta
1026	medico	Mónica	Figueroa Lam	2001123450126	5551-2026	7 calle 7-76, zona 4	1	Urbana	1	\N	\N	consulta
1027	medico	Pablo	Tzoc Ajcá	2001123450127	5551-2027	8 calle 8-77, zona 5	6	Urbana	2	\N	\N	consulta
1028	medico	Isabel	Contreras Mejía	2001123450128	5551-2028	9 calle 9-78, zona 6	1	Urbana	3	\N	\N	consulta
1029	medico	Carlos	Menéndez Ralda	2001123450129	5551-2029	10 calle 10-79, zona 7	3	Urbana	1	\N	\N	consulta
1030	medico	Luis	Zambrano Sic	2001123450130	5551-2030	11 calle 11-80, zona 8	6	Urbana	2	\N	\N	consulta
2001	enfermero	Luis	Hernández Solís	2001123450201	5552-2001	10 avenida 2-51, zona 4	1	Urbana	1	2018-01-18	7200.00	operativo
2002	enfermero	Marta	Recinos Alvarado	2001123450202	5552-2002	11 avenida 3-52, zona 5	1	Urbana	1	2018-03-12	7200.00	operativo
2003	enfermero	Carlos	García Méndez	2001123450203	5552-2003	12 avenida 4-53, zona 6	1	Urbana	1	2018-05-04	3800.00	operativo
2004	enfermero	Ana	López Pérez	2001123450204	5552-2004	1 avenida 5-54, zona 7	1	Urbana	1	2018-06-26	7200.00	operativo
2005	enfermero	Pedro	Ramírez Soto	2001123450205	5552-2005	2 avenida 6-55, zona 8	1	Urbana	1	2018-08-18	7200.00	operativo
1032	medico	Esteban	Orozco Bámaca	2001123450132	5551-2032	8 avenida 2-40, zona 3	6	Rural	2	2019-07-15	13000.00	operativo
1034	medico	Iván	Coyoy Tzul	2001123450134	5551-2034	6 calle 1-77, zona 4	13	Urbana	2	2020-01-20	18500.00	operativo
1035	medico	Marisol	Ajanel Pérez	2001123450135	5551-2035	2 avenida 6-18, zona 1	6	Urbana	2	2023-08-01	9500.00	operativo
1037	medico	Brenda	Sic Ixcot	2001123450137	5551-2037	Lotificación El Recreo, casa 14	14	Rural	3	2021-11-02	13000.00	operativo
1039	medico	Gloria	Tax Chiquitó	2001123450139	5551-2039	5 calle 8-21, zona 2	8	Urbana	3	2018-04-23	18500.00	operativo
1040	medico	Samuel	Barrios Juárez	2001123450140	5551-2040	10 calle 2-09, zona 3	8	Urbana	3	2017-06-12	18500.00	operativo
1042	medico	Héctor Manuel	Gómez Ordóñez	2001123450142	5551-2042	Aldea Las Lagunas, casa 3	10	Rural	4	2022-02-14	13000.00	operativo
1044	medico	Jorge Mario	Alvarado Castillo	2001123450144	5551-2044	3 avenida 7-02, zona 5	9	Urbana	4	2016-08-08	18500.00	operativo
1046	medico	Kevin	Domingo Pascual	2001123450146	5551-2046	1 avenida 2-08, zona 2	10	Rural	4	2025-01-06	6500.00	operativo
1048	medico	Diego	Yaxón Bocel	2001123450148	5551-2048	Cantón Pujujil, casa 8	11	Rural	5	2020-09-28	13000.00	operativo
1001	medico	Carmen	Ruiz Palacios	2001123450101	5551-2001	12 calle 12-51, zona 1	1	Urbana	1	2015-01-10	14500.00	operativo
1004	medico	Julia	Paredes Ovalle	2001123450104	5551-2004	15 calle 15-54, zona 4	1	Urbana	1	2015-10-28	22000.00	supervisor
1051	medico	Mónica	Pirir Cutzal	2001123450151	5551-2051	Calle del Lago 1-09	12	Urbana	5	2019-05-13	18500.00	operativo
2006	enfermero	Rosa	Xicará Pop	2001123450206	5552-2006	2 calle 3-10, zona 1	1	Urbana	1	2017-04-03	7200.00	operativo
2007	enfermero	Julio	Chay Tum	2001123450207	5552-2007	Aldea Chichimecas, casa 2	5	Rural	1	2024-06-17	3800.00	operativo
2008	enfermero	Mirna	Ochoa Bravo	2001123450208	5552-2008	5 avenida 1-22, zona 3	6	Urbana	2	2016-10-10	7200.00	operativo
2009	enfermero	Wilson	Escobar Ruiz	2001123450209	5552-2009	4 calle 6-07, zona 2	13	Rural	2	2021-03-01	7200.00	operativo
2010	enfermero	Yesenia	Cardona Aguilar	2001123450210	5552-2010	1 calle 2-80, zona 1	6	Urbana	2	2025-02-03	3800.00	operativo
2011	enfermero	Ronaldo	Pineda Sosa	2001123450211	5552-2011	6 calle 4-15, zona 1	8	Urbana	3	2015-08-24	7200.00	operativo
2012	enfermero	Ingrid	Toc Chan	2001123450212	5552-2012	Colonia Las Flores, casa 9	14	Rural	3	2019-01-14	7200.00	operativo
2013	enfermero	Elmer	Yac Sontay	2001123450213	5552-2013	3 avenida 8-30, zona 2	8	Urbana	3	2024-09-09	3800.00	operativo
2014	enfermero	Dora	Matías Gaspar	2001123450214	5552-2014	4 calle 1-40, zona 1	9	Urbana	4	2014-11-17	7200.00	operativo
2015	enfermero	Fredy	Mendoza Hidalgo	2001123450215	5552-2015	Caserío El Calvario, casa 5	10	Rural	4	2020-05-04	7200.00	operativo
2016	enfermero	Sonia	Jiménez Sales	2001123450216	5552-2016	2 avenida 3-03, zona 4	9	Urbana	4	2025-03-10	3800.00	operativo
2017	enfermero	Pablo	Sicajau Tzep	2001123450217	5552-2017	Calle Rancho Grande 2-14	12	Urbana	5	2016-06-06	7200.00	operativo
2018	enfermero	Claudia	Batz Sequén	2001123450218	5552-2018	Cantón Xajaxac, casa 1	11	Rural	5	2018-08-20	7200.00	operativo
2019	enfermero	Edwin	Coj Lacán	2001123450219	5552-2019	1 calle 5-25, zona 1	11	Urbana	5	2024-10-07	3800.00	operativo
2020	enfermero	Vilma	Ixcoy Boj	2001123450220	5552-2020	9 avenida 4-12, zona 2	1	Urbana	1	2018-02-26	7200.00	operativo
1005	medico	Miguel	Barrios Donis	2001123450105	5551-2005	1 calle 16-55, zona 5	2	Rural	1	2016-02-02	22000.00	supervisor
1009	medico	Silvia	Vásquez Cotero	2001123450109	5551-2009	5 calle 20-59, zona 9	7	Urbana	3	2017-02-24	22000.00	supervisor
1011	medico	Marcos	Aguilar Salazar	2001123450111	5551-2011	7 calle 22-61, zona 11	1	Urbana	1	2017-09-06	22000.00	supervisor
1012	medico	Gabriela	Nájera Ruiz	2001123450112	5551-2012	8 calle 23-62, zona 1	6	Urbana	2	2017-12-12	22000.00	supervisor
1031	medico	Rosa María	Fuentes Galindo	2001123450131	5551-2031	3 calle 5-12, zona 1	6	Urbana	2	2016-02-01	22000.00	supervisor
1033	medico	Leticia	Morales Chávez	2001123450133	5551-2033	1 calle 9-03, zona 2	6	Urbana	2	2011-03-10	28000.00	administrador
1036	medico	Otto René	Velásquez Lima	2001123450136	5551-2036	4 calle 3-30, zona 1	8	Urbana	3	2014-05-05	22000.00	supervisor
1038	medico	Mario	Cabrera Monterroso	2001123450138	5551-2038	7 avenida 0-55, zona 1	8	Urbana	3	2010-09-13	28000.00	administrador
1041	medico	Ana Gabriela	Recinos Mérida	2001123450141	5551-2041	2 calle 4-50, zona 1	9	Urbana	4	2015-01-12	22000.00	supervisor
1043	medico	Carolina	Herrera Villatoro	2001123450143	5551-2043	6 avenida 1-15, zona 1	9	Urbana	4	2009-10-01	28000.00	administrador
1045	medico	Patricia	López Mazariegos	2001123450145	5551-2045	9 calle 3-44, zona 1	9	Urbana	4	2013-03-18	22000.00	supervisor
1047	medico	Lucía	Cumes Xajil	2001123450147	5551-2047	Calle Santander 4-11	12	Urbana	5	2014-07-21	22000.00	supervisor
1049	medico	Sandra	Tuy Guarcax	2001123450149	5551-2049	7 calle 2-33, zona 1	11	Urbana	5	2008-02-04	28000.00	administrador
1050	medico	Alberto	Ramos Sajquiy	2001123450150	5551-2050	3 avenida 5-60, zona 2	11	Urbana	5	2012-12-03	22000.00	supervisor
1002	medico	Roberto	Castillo Méndez	2001123450102	5551-2002	13 calle 13-52, zona 2	3	Urbana	1	2015-04-17	28000.00	administrador
\.


--
-- Data for Name: quirofano; Type: TABLE DATA; Schema: public; Owner: admin
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
13	43	1	disponible
14	43	2	disponible
15	43	3	disponible
16	43	4	disponible
17	53	1	disponible
18	53	2	disponible
19	53	3	disponible
20	53	4	disponible
\.


--
-- Data for Name: receta; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.receta (id_receta, id_consulta, fecha_proxima_cita) FROM stdin;
1	1	2026-09-10
2	2	\N
101	101	\N
102	102	2026-03-02
103	103	\N
104	104	2026-03-28
106	106	2026-04-23
107	107	\N
108	108	2026-05-19
109	109	\N
111	111	\N
113	113	\N
114	114	2026-08-05
116	116	2026-08-31
117	117	\N
118	118	2026-09-26
121	121	\N
122	122	2026-11-17
123	123	\N
124	124	2026-02-26
127	127	\N
128	128	2026-04-19
129	129	\N
131	131	\N
132	132	2026-06-10
134	134	2026-07-06
136	136	2026-08-01
137	137	\N
138	138	2026-08-27
139	139	\N
141	141	\N
142	142	2026-10-18
143	143	\N
144	144	2026-11-13
146	146	2026-02-22
148	148	2026-03-20
149	149	\N
151	151	\N
152	152	2026-05-11
153	153	\N
156	156	2026-07-02
157	157	\N
158	158	2026-07-28
159	159	\N
162	162	2026-09-18
163	163	\N
164	164	2026-10-14
166	166	2026-11-09
167	167	\N
169	169	\N
171	171	\N
172	172	2026-04-11
173	173	\N
174	174	2026-05-07
176	176	2026-06-02
177	177	\N
178	178	2026-06-28
179	179	\N
181	181	\N
183	183	\N
184	184	2026-09-14
186	186	2026-10-10
187	187	\N
188	188	2026-11-05
191	191	\N
192	192	2026-03-12
193	193	\N
194	194	2026-04-07
197	197	\N
198	198	2026-05-29
199	199	\N
201	201	\N
202	202	2026-07-20
204	204	2026-08-15
206	206	2026-09-10
207	207	\N
208	208	2026-10-06
209	209	\N
211	211	\N
212	212	2026-02-10
213	213	\N
214	214	2026-03-08
216	216	2026-04-03
218	218	2026-04-29
219	219	\N
221	221	\N
222	222	2026-06-20
223	223	\N
226	226	2026-08-11
227	227	\N
228	228	2026-09-06
229	229	\N
232	232	2026-10-28
233	233	\N
234	234	2026-02-06
236	236	2026-03-04
237	237	\N
239	239	\N
241	241	\N
242	242	2026-05-21
243	243	\N
244	244	2026-06-16
246	246	2026-07-12
247	247	\N
248	248	2026-08-07
249	249	\N
251	251	\N
253	253	\N
254	254	2026-10-24
256	256	2026-11-19
257	257	\N
258	258	2026-02-28
261	261	\N
262	262	2026-04-21
263	263	\N
264	264	2026-05-17
267	267	\N
268	268	2026-07-08
269	269	\N
271	271	\N
272	272	2026-08-29
274	274	2026-09-24
276	276	2026-10-20
277	277	\N
278	278	2026-11-15
279	279	\N
281	281	\N
282	282	2026-03-22
283	283	\N
284	284	2026-04-17
286	286	2026-05-13
288	288	2026-06-08
289	289	\N
291	291	\N
292	292	2026-07-30
293	293	\N
296	296	2026-09-20
297	297	\N
298	298	2026-10-16
299	299	\N
302	302	2026-02-20
303	303	\N
304	304	2026-03-18
306	306	2026-04-13
307	307	\N
309	309	\N
311	311	\N
312	312	2026-06-30
313	313	\N
314	314	2026-07-26
316	316	2026-08-21
317	317	\N
318	318	2026-09-16
319	319	\N
\.


--
-- Data for Name: receta_medicamento; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.receta_medicamento (id_receta, id_medicamento, dosis, duracion) FROM stdin;
1	1	1 tableta cada 12 horas	30 días
1	2	1 tableta en la mañana	30 días
2	3	1 tableta hasta cada 8 horas según dolor	5 días
101	2	1 cada 12 horas	14 días
102	3	1 cada 12 horas	21 días
103	4	1 cada 12 horas	28 días
104	5	1 cada 12 horas	7 días
106	7	1 cada 12 horas	21 días
107	8	1 cada 12 horas	28 días
108	9	1 cada 12 horas	7 días
109	10	1 cada 12 horas	14 días
111	2	1 cada 12 horas	28 días
113	4	1 cada 12 horas	14 días
114	5	1 cada 12 horas	21 días
116	7	1 cada 12 horas	7 días
117	8	1 cada 12 horas	14 días
118	9	1 cada 12 horas	21 días
121	2	1 cada 12 horas	14 días
122	3	1 cada 12 horas	21 días
123	4	1 cada 12 horas	28 días
124	5	1 cada 12 horas	7 días
127	8	1 cada 12 horas	28 días
128	9	1 cada 12 horas	7 días
129	10	1 cada 12 horas	14 días
131	2	1 cada 12 horas	28 días
132	3	1 cada 12 horas	7 días
134	5	1 cada 12 horas	21 días
136	7	1 cada 12 horas	7 días
137	8	1 cada 12 horas	14 días
138	9	1 cada 12 horas	21 días
139	10	1 cada 12 horas	28 días
141	2	1 cada 12 horas	14 días
142	3	1 cada 12 horas	21 días
143	4	1 cada 12 horas	28 días
144	5	1 cada 12 horas	7 días
146	7	1 cada 12 horas	21 días
148	9	1 cada 12 horas	7 días
149	10	1 cada 12 horas	14 días
151	2	1 cada 12 horas	28 días
152	3	1 cada 12 horas	7 días
153	4	1 cada 12 horas	14 días
156	7	1 cada 12 horas	7 días
157	8	1 cada 12 horas	14 días
158	9	1 cada 12 horas	21 días
159	10	1 cada 12 horas	28 días
162	3	1 cada 12 horas	21 días
163	4	1 cada 12 horas	28 días
164	5	1 cada 12 horas	7 días
166	7	1 cada 12 horas	21 días
167	8	1 cada 12 horas	28 días
169	10	1 cada 12 horas	14 días
171	2	1 cada 12 horas	28 días
172	3	1 cada 12 horas	7 días
173	4	1 cada 12 horas	14 días
174	5	1 cada 12 horas	21 días
176	7	1 cada 12 horas	7 días
177	8	1 cada 12 horas	14 días
178	9	1 cada 12 horas	21 días
179	10	1 cada 12 horas	28 días
181	2	1 cada 12 horas	14 días
183	4	1 cada 12 horas	28 días
184	5	1 cada 12 horas	7 días
186	7	1 cada 12 horas	21 días
187	8	1 cada 12 horas	28 días
188	9	1 cada 12 horas	7 días
191	2	1 cada 12 horas	28 días
192	3	1 cada 12 horas	7 días
193	4	1 cada 12 horas	14 días
194	5	1 cada 12 horas	21 días
197	8	1 cada 12 horas	14 días
198	9	1 cada 12 horas	21 días
199	10	1 cada 12 horas	28 días
201	2	1 cada 12 horas	14 días
202	3	1 cada 12 horas	21 días
204	5	1 cada 12 horas	7 días
206	7	1 cada 12 horas	21 días
207	8	1 cada 12 horas	28 días
208	9	1 cada 12 horas	7 días
209	10	1 cada 12 horas	14 días
211	2	1 cada 12 horas	28 días
212	3	1 cada 12 horas	7 días
213	4	1 cada 12 horas	14 días
214	5	1 cada 12 horas	21 días
216	7	1 cada 12 horas	7 días
218	9	1 cada 12 horas	21 días
219	10	1 cada 12 horas	28 días
221	2	1 cada 12 horas	14 días
222	3	1 cada 12 horas	21 días
223	4	1 cada 12 horas	28 días
226	7	1 cada 12 horas	21 días
227	8	1 cada 12 horas	28 días
228	9	1 cada 12 horas	7 días
229	10	1 cada 12 horas	14 días
232	3	1 cada 12 horas	7 días
233	4	1 cada 12 horas	14 días
234	5	1 cada 12 horas	21 días
236	7	1 cada 12 horas	7 días
237	8	1 cada 12 horas	14 días
239	10	1 cada 12 horas	28 días
241	2	1 cada 12 horas	14 días
242	3	1 cada 12 horas	21 días
243	4	1 cada 12 horas	28 días
244	5	1 cada 12 horas	7 días
246	7	1 cada 12 horas	21 días
247	8	1 cada 12 horas	28 días
248	9	1 cada 12 horas	7 días
249	10	1 cada 12 horas	14 días
251	2	1 cada 12 horas	28 días
253	4	1 cada 12 horas	14 días
254	5	1 cada 12 horas	21 días
256	7	1 cada 12 horas	7 días
257	8	1 cada 12 horas	14 días
258	9	1 cada 12 horas	21 días
261	2	1 cada 12 horas	14 días
262	3	1 cada 12 horas	21 días
263	4	1 cada 12 horas	28 días
264	5	1 cada 12 horas	7 días
267	8	1 cada 12 horas	28 días
268	9	1 cada 12 horas	7 días
269	10	1 cada 12 horas	14 días
271	2	1 cada 12 horas	28 días
272	3	1 cada 12 horas	7 días
274	5	1 cada 12 horas	21 días
276	7	1 cada 12 horas	7 días
277	8	1 cada 12 horas	14 días
278	9	1 cada 12 horas	21 días
279	10	1 cada 12 horas	28 días
281	2	1 cada 12 horas	14 días
282	3	1 cada 12 horas	21 días
283	4	1 cada 12 horas	28 días
284	5	1 cada 12 horas	7 días
286	7	1 cada 12 horas	21 días
288	9	1 cada 12 horas	7 días
289	10	1 cada 12 horas	14 días
291	2	1 cada 12 horas	28 días
292	3	1 cada 12 horas	7 días
293	4	1 cada 12 horas	14 días
296	7	1 cada 12 horas	7 días
297	8	1 cada 12 horas	14 días
298	9	1 cada 12 horas	21 días
299	10	1 cada 12 horas	28 días
302	3	1 cada 12 horas	21 días
303	4	1 cada 12 horas	28 días
304	5	1 cada 12 horas	7 días
306	7	1 cada 12 horas	21 días
307	8	1 cada 12 horas	28 días
309	10	1 cada 12 horas	14 días
311	2	1 cada 12 horas	28 días
312	3	1 cada 12 horas	7 días
313	4	1 cada 12 horas	14 días
314	5	1 cada 12 horas	21 días
316	7	1 cada 12 horas	7 días
317	8	1 cada 12 horas	14 días
318	9	1 cada 12 horas	21 días
319	10	1 cada 12 horas	28 días
102	6	1 cada 8 horas si hay dolor	5 días
108	2	1 cada 8 horas si hay dolor	5 días
111	5	1 cada 8 horas si hay dolor	5 días
114	8	1 cada 8 horas si hay dolor	5 días
117	1	1 cada 8 horas si hay dolor	5 días
123	7	1 cada 8 horas si hay dolor	5 días
129	3	1 cada 8 horas si hay dolor	5 días
132	6	1 cada 8 horas si hay dolor	5 días
138	2	1 cada 8 horas si hay dolor	5 días
141	5	1 cada 8 horas si hay dolor	5 días
144	8	1 cada 8 horas si hay dolor	5 días
153	7	1 cada 8 horas si hay dolor	5 días
156	10	1 cada 8 horas si hay dolor	5 días
159	3	1 cada 8 horas si hay dolor	5 días
162	6	1 cada 8 horas si hay dolor	5 días
171	5	1 cada 8 horas si hay dolor	5 días
174	8	1 cada 8 horas si hay dolor	5 días
177	1	1 cada 8 horas si hay dolor	5 días
183	7	1 cada 8 horas si hay dolor	5 días
186	10	1 cada 8 horas si hay dolor	5 días
192	6	1 cada 8 horas si hay dolor	5 días
198	2	1 cada 8 horas si hay dolor	5 días
201	5	1 cada 8 horas si hay dolor	5 días
204	8	1 cada 8 horas si hay dolor	5 días
207	1	1 cada 8 horas si hay dolor	5 días
213	7	1 cada 8 horas si hay dolor	5 días
216	10	1 cada 8 horas si hay dolor	5 días
219	3	1 cada 8 horas si hay dolor	5 días
222	6	1 cada 8 horas si hay dolor	5 días
228	2	1 cada 8 horas si hay dolor	5 días
234	8	1 cada 8 horas si hay dolor	5 días
237	1	1 cada 8 horas si hay dolor	5 días
243	7	1 cada 8 horas si hay dolor	5 días
246	10	1 cada 8 horas si hay dolor	5 días
249	3	1 cada 8 horas si hay dolor	5 días
258	2	1 cada 8 horas si hay dolor	5 días
261	5	1 cada 8 horas si hay dolor	5 días
264	8	1 cada 8 horas si hay dolor	5 días
267	1	1 cada 8 horas si hay dolor	5 días
276	10	1 cada 8 horas si hay dolor	5 días
279	3	1 cada 8 horas si hay dolor	5 días
282	6	1 cada 8 horas si hay dolor	5 días
288	2	1 cada 8 horas si hay dolor	5 días
291	5	1 cada 8 horas si hay dolor	5 días
297	1	1 cada 8 horas si hay dolor	5 días
303	7	1 cada 8 horas si hay dolor	5 días
306	10	1 cada 8 horas si hay dolor	5 días
309	3	1 cada 8 horas si hay dolor	5 días
312	6	1 cada 8 horas si hay dolor	5 días
318	2	1 cada 8 horas si hay dolor	5 días
\.


--
-- Data for Name: registro_procedimiento; Type: TABLE DATA; Schema: public; Owner: admin
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
9	101	1	exito	\N	2026-01-20 14:21:00-06	2004
10	101	2	exito	\N	2026-01-20 14:22:00-06	2004
11	101	3	exito	\N	2026-01-20 14:23:00-06	2004
12	101	4	exito	\N	2026-01-20 14:24:00-06	2004
13	101	5	exito	\N	2026-01-20 14:25:00-06	2004
14	101	6	exito	\N	2026-01-20 14:26:00-06	2004
15	101	7	exito	\N	2026-01-20 14:27:00-06	2004
16	101	8	exito	\N	2026-01-20 15:08:00-06	2004
17	101	9	exito	\N	2026-01-20 15:09:00-06	2004
18	101	10	exito	\N	2026-01-20 15:10:00-06	2004
19	101	11	exito	\N	2026-01-20 15:11:00-06	2004
20	101	12	exito	\N	2026-01-20 15:12:00-06	2004
21	101	13	exito	\N	2026-01-20 15:13:00-06	2004
22	101	14	exito	\N	2026-01-20 15:14:00-06	2004
23	101	15	exito	\N	2026-01-20 15:15:00-06	2004
24	101	16	exito	\N	2026-01-20 15:16:00-06	2004
25	101	17	exito	\N	2026-01-20 15:17:00-06	2004
26	101	18	exito	\N	2026-01-20 15:18:00-06	2004
27	101	19	no_aceptable	\N	2026-01-20 15:19:00-06	2004
28	101	20	medianamente_aceptable	\N	2026-01-20 15:20:00-06	2004
29	101	21	medianamente_aceptable	\N	2026-01-20 15:21:00-06	2004
30	101	22	exito	\N	2026-01-20 15:22:00-06	2004
31	101	23	exito	\N	2026-01-20 15:23:00-06	2004
32	101	24	exito	\N	2026-01-20 15:24:00-06	2004
33	101	25	exito	\N	2026-01-20 15:25:00-06	2004
34	101	26	exito	\N	2026-01-20 16:29:00-06	2004
35	101	27	exito	\N	2026-01-20 16:30:00-06	2004
36	101	28	exito	\N	2026-01-20 16:31:00-06	2004
37	101	29	falla	\N	2026-01-20 16:32:00-06	2004
38	101	30	exito	\N	2026-01-20 16:33:00-06	2004
39	101	31	exito	\N	2026-01-20 16:34:00-06	2004
40	101	32	exito	\N	2026-01-20 16:35:00-06	2004
41	101	33	exito	\N	2026-01-20 16:36:00-06	2004
42	101	34	exito	\N	2026-01-20 16:37:00-06	2004
43	101	35	exito	\N	2026-01-20 16:38:00-06	2004
44	101	36	exito	\N	2026-01-20 16:39:00-06	2004
45	101	37	exito	\N	2026-01-20 16:40:00-06	2004
46	101	38	exito	\N	2026-01-20 16:41:00-06	2004
47	102	1	exito	\N	2026-01-27 14:21:00-06	2008
48	102	2	exito	\N	2026-01-27 14:22:00-06	2008
49	102	3	exito	\N	2026-01-27 14:23:00-06	2008
50	102	4	exito	\N	2026-01-27 14:24:00-06	2008
51	102	5	exito	\N	2026-01-27 14:25:00-06	2008
52	102	6	exito	\N	2026-01-27 14:26:00-06	2008
53	102	7	exito	\N	2026-01-27 14:27:00-06	2008
54	102	8	exito	\N	2026-01-27 15:08:00-06	2008
55	102	9	exito	\N	2026-01-27 15:09:00-06	2008
56	102	10	exito	\N	2026-01-27 15:10:00-06	2008
57	102	11	exito	\N	2026-01-27 15:11:00-06	2008
58	102	12	exito	\N	2026-01-27 15:12:00-06	2008
59	102	13	exito	\N	2026-01-27 15:13:00-06	2008
60	102	14	exito	\N	2026-01-27 15:14:00-06	2008
61	102	15	exito	\N	2026-01-27 15:15:00-06	2008
62	102	16	exito	\N	2026-01-27 15:16:00-06	2008
63	102	17	exito	\N	2026-01-27 15:17:00-06	2008
64	102	18	exito	\N	2026-01-27 15:18:00-06	2008
65	102	19	medianamente_aceptable	\N	2026-01-27 15:19:00-06	2008
66	102	20	medianamente_aceptable	\N	2026-01-27 15:20:00-06	2008
67	102	21	aceptable	\N	2026-01-27 15:21:00-06	2008
68	102	22	exito	\N	2026-01-27 15:22:00-06	2008
69	102	23	exito	\N	2026-01-27 15:23:00-06	2008
70	102	24	exito	\N	2026-01-27 15:24:00-06	2008
71	102	25	exito	\N	2026-01-27 15:25:00-06	2008
72	102	26	exito	\N	2026-01-27 16:52:00-06	2008
73	102	27	exito	\N	2026-01-27 16:53:00-06	2008
74	102	28	exito	\N	2026-01-27 16:54:00-06	2008
75	102	29	falla	\N	2026-01-27 16:55:00-06	2008
76	102	30	exito	\N	2026-01-27 16:56:00-06	2008
77	102	31	exito	\N	2026-01-27 16:57:00-06	2008
78	102	32	exito	\N	2026-01-27 16:58:00-06	2008
79	102	33	exito	\N	2026-01-27 16:59:00-06	2008
80	102	34	exito	\N	2026-01-27 17:00:00-06	2008
81	102	35	exito	\N	2026-01-27 17:01:00-06	2008
82	102	36	exito	\N	2026-01-27 17:02:00-06	2008
83	102	37	exito	\N	2026-01-27 17:03:00-06	2008
84	102	38	exito	\N	2026-01-27 17:04:00-06	2008
85	103	1	exito	\N	2026-02-03 14:21:00-06	2012
86	103	2	exito	\N	2026-02-03 14:22:00-06	2012
87	103	3	exito	\N	2026-02-03 14:23:00-06	2012
88	103	4	exito	\N	2026-02-03 14:24:00-06	2012
89	103	5	exito	\N	2026-02-03 14:25:00-06	2012
90	103	6	exito	\N	2026-02-03 14:26:00-06	2012
91	103	7	exito	\N	2026-02-03 14:27:00-06	2012
92	103	8	exito	\N	2026-02-03 15:08:00-06	2012
93	103	9	exito	\N	2026-02-03 15:09:00-06	2012
94	103	10	exito	\N	2026-02-03 15:10:00-06	2012
95	103	11	exito	\N	2026-02-03 15:11:00-06	2012
96	103	12	exito	\N	2026-02-03 15:12:00-06	2012
97	103	13	exito	\N	2026-02-03 15:13:00-06	2012
98	103	14	exito	\N	2026-02-03 15:14:00-06	2012
99	103	15	exito	\N	2026-02-03 15:15:00-06	2012
100	103	16	exito	\N	2026-02-03 15:16:00-06	2012
101	103	17	exito	\N	2026-02-03 15:17:00-06	2012
102	103	18	exito	\N	2026-02-03 15:18:00-06	2012
103	103	19	medianamente_aceptable	\N	2026-02-03 15:19:00-06	2012
104	103	20	aceptable	\N	2026-02-03 15:20:00-06	2012
105	103	21	aceptable	\N	2026-02-03 15:21:00-06	2012
106	103	22	exito	\N	2026-02-03 15:22:00-06	2012
107	103	23	exito	\N	2026-02-03 15:23:00-06	2012
108	103	24	exito	\N	2026-02-03 15:24:00-06	2012
109	103	25	exito	\N	2026-02-03 15:25:00-06	2012
110	103	26	exito	\N	2026-02-03 17:15:00-06	2012
111	103	27	exito	\N	2026-02-03 17:16:00-06	2012
112	103	28	exito	\N	2026-02-03 17:17:00-06	2012
113	103	29	falla	\N	2026-02-03 17:18:00-06	2012
114	103	30	exito	\N	2026-02-03 17:19:00-06	2012
115	103	31	exito	\N	2026-02-03 17:20:00-06	2012
116	103	32	exito	\N	2026-02-03 17:21:00-06	2012
117	103	33	exito	\N	2026-02-03 17:22:00-06	2012
118	103	34	exito	\N	2026-02-03 17:23:00-06	2012
119	103	35	exito	\N	2026-02-03 17:24:00-06	2012
120	103	36	exito	\N	2026-02-03 17:25:00-06	2012
121	103	37	exito	\N	2026-02-03 17:26:00-06	2012
122	103	38	exito	\N	2026-02-03 17:27:00-06	2012
123	104	1	exito	\N	2026-02-06 14:21:00-06	2011
124	104	2	exito	\N	2026-02-06 14:22:00-06	2011
125	104	3	exito	\N	2026-02-06 14:23:00-06	2011
126	104	4	exito	\N	2026-02-06 14:24:00-06	2011
127	104	5	exito	\N	2026-02-06 14:25:00-06	2011
128	104	6	exito	\N	2026-02-06 14:26:00-06	2011
129	104	7	exito	\N	2026-02-06 14:27:00-06	2011
130	104	8	exito	\N	2026-02-06 15:08:00-06	2011
131	104	9	exito	\N	2026-02-06 15:09:00-06	2011
132	104	10	exito	\N	2026-02-06 15:10:00-06	2011
133	104	11	exito	\N	2026-02-06 15:11:00-06	2011
134	104	12	exito	\N	2026-02-06 15:12:00-06	2011
135	104	13	exito	\N	2026-02-06 15:13:00-06	2011
136	104	14	exito	\N	2026-02-06 15:14:00-06	2011
137	104	15	exito	\N	2026-02-06 15:15:00-06	2011
138	104	16	exito	\N	2026-02-06 15:16:00-06	2011
139	104	17	exito	\N	2026-02-06 15:17:00-06	2011
140	104	18	exito	\N	2026-02-06 15:18:00-06	2011
141	104	19	aceptable	\N	2026-02-06 15:19:00-06	2011
142	104	20	aceptable	\N	2026-02-06 15:20:00-06	2011
143	104	21	aceptable	\N	2026-02-06 15:21:00-06	2011
144	104	22	exito	\N	2026-02-06 15:22:00-06	2011
145	104	23	exito	\N	2026-02-06 15:23:00-06	2011
146	104	24	exito	\N	2026-02-06 15:24:00-06	2011
147	104	25	exito	\N	2026-02-06 15:25:00-06	2011
148	104	26	exito	\N	2026-02-06 17:38:00-06	2011
149	104	27	exito	\N	2026-02-06 17:39:00-06	2011
150	104	28	exito	\N	2026-02-06 17:40:00-06	2011
151	104	29	falla	\N	2026-02-06 17:41:00-06	2011
152	104	30	exito	\N	2026-02-06 17:42:00-06	2011
153	104	31	exito	\N	2026-02-06 17:43:00-06	2011
154	104	32	exito	\N	2026-02-06 17:44:00-06	2011
155	104	33	exito	\N	2026-02-06 17:45:00-06	2011
156	104	34	exito	\N	2026-02-06 17:46:00-06	2011
157	104	35	exito	\N	2026-02-06 17:47:00-06	2011
158	104	36	exito	\N	2026-02-06 17:48:00-06	2011
159	104	37	exito	\N	2026-02-06 17:49:00-06	2011
160	104	38	exito	\N	2026-02-06 17:50:00-06	2011
161	105	1	exito	\N	2026-02-13 14:21:00-06	2001
162	105	2	exito	\N	2026-02-13 14:22:00-06	2001
163	105	3	exito	\N	2026-02-13 14:23:00-06	2001
164	105	4	exito	\N	2026-02-13 14:24:00-06	2001
165	105	5	exito	\N	2026-02-13 14:25:00-06	2001
166	105	6	exito	\N	2026-02-13 14:26:00-06	2001
167	105	7	exito	\N	2026-02-13 14:27:00-06	2001
168	105	8	exito	\N	2026-02-13 15:08:00-06	2001
169	105	9	exito	\N	2026-02-13 15:09:00-06	2001
170	105	10	exito	\N	2026-02-13 15:10:00-06	2001
171	105	11	exito	\N	2026-02-13 15:11:00-06	2001
172	105	12	exito	\N	2026-02-13 15:12:00-06	2001
173	105	13	exito	\N	2026-02-13 15:13:00-06	2001
174	105	14	exito	\N	2026-02-13 15:14:00-06	2001
175	105	15	exito	\N	2026-02-13 15:15:00-06	2001
176	105	16	exito	\N	2026-02-13 15:16:00-06	2001
177	105	17	exito	\N	2026-02-13 15:17:00-06	2001
178	105	18	exito	\N	2026-02-13 15:18:00-06	2001
179	105	19	aceptable	\N	2026-02-13 15:19:00-06	2001
180	105	20	aceptable	\N	2026-02-13 15:20:00-06	2001
181	105	21	aceptable	\N	2026-02-13 15:21:00-06	2001
182	105	22	exito	\N	2026-02-13 15:22:00-06	2001
183	105	23	exito	\N	2026-02-13 15:23:00-06	2001
184	105	24	exito	\N	2026-02-13 15:24:00-06	2001
185	105	25	exito	\N	2026-02-13 15:25:00-06	2001
186	105	26	exito	\N	2026-02-13 17:11:00-06	2001
187	105	27	exito	\N	2026-02-13 17:12:00-06	2001
188	105	28	exito	\N	2026-02-13 17:13:00-06	2001
189	105	29	falla	\N	2026-02-13 17:14:00-06	2001
190	105	30	exito	\N	2026-02-13 17:15:00-06	2001
191	105	31	exito	\N	2026-02-13 17:16:00-06	2001
192	105	32	exito	\N	2026-02-13 17:17:00-06	2001
193	105	33	exito	\N	2026-02-13 17:18:00-06	2001
194	105	34	exito	\N	2026-02-13 17:19:00-06	2001
195	105	35	exito	\N	2026-02-13 17:20:00-06	2001
196	105	36	exito	\N	2026-02-13 17:21:00-06	2001
197	105	37	exito	\N	2026-02-13 17:22:00-06	2001
198	105	38	exito	\N	2026-02-13 17:23:00-06	2001
199	107	1	exito	\N	2026-02-27 14:21:00-06	2003
200	107	2	exito	\N	2026-02-27 14:22:00-06	2003
201	107	3	exito	\N	2026-02-27 14:23:00-06	2003
202	107	4	exito	\N	2026-02-27 14:24:00-06	2003
203	107	5	exito	\N	2026-02-27 14:25:00-06	2003
204	107	6	exito	\N	2026-02-27 14:26:00-06	2003
205	107	7	exito	\N	2026-02-27 14:27:00-06	2003
206	107	8	exito	\N	2026-02-27 15:08:00-06	2003
207	107	9	exito	\N	2026-02-27 15:09:00-06	2003
208	107	10	exito	\N	2026-02-27 15:10:00-06	2003
209	107	11	exito	\N	2026-02-27 15:11:00-06	2003
210	107	12	exito	\N	2026-02-27 15:12:00-06	2003
211	107	13	exito	\N	2026-02-27 15:13:00-06	2003
212	107	14	exito	\N	2026-02-27 15:14:00-06	2003
213	107	15	exito	\N	2026-02-27 15:15:00-06	2003
214	107	16	exito	\N	2026-02-27 15:16:00-06	2003
215	107	17	exito	\N	2026-02-27 15:17:00-06	2003
216	107	18	exito	\N	2026-02-27 15:18:00-06	2003
217	107	19	aceptable	\N	2026-02-27 15:19:00-06	2003
218	107	20	aceptable	\N	2026-02-27 15:20:00-06	2003
219	107	21	aceptable	\N	2026-02-27 15:21:00-06	2003
220	107	22	exito	\N	2026-02-27 15:22:00-06	2003
221	107	23	exito	\N	2026-02-27 15:23:00-06	2003
222	107	24	exito	\N	2026-02-27 15:24:00-06	2003
223	107	25	exito	\N	2026-02-27 15:25:00-06	2003
224	107	26	exito	\N	2026-02-27 17:57:00-06	2003
225	107	27	exito	\N	2026-02-27 17:58:00-06	2003
226	107	28	exito	\N	2026-02-27 17:59:00-06	2003
227	107	29	falla	\N	2026-02-27 18:00:00-06	2003
228	107	30	exito	\N	2026-02-27 18:01:00-06	2003
229	107	31	exito	\N	2026-02-27 18:02:00-06	2003
230	107	32	exito	\N	2026-02-27 18:03:00-06	2003
231	107	33	exito	\N	2026-02-27 18:04:00-06	2003
232	107	34	exito	\N	2026-02-27 18:05:00-06	2003
233	107	35	exito	\N	2026-02-27 18:06:00-06	2003
234	107	36	exito	\N	2026-02-27 18:07:00-06	2003
235	107	37	exito	\N	2026-02-27 18:08:00-06	2003
236	107	38	exito	\N	2026-02-27 18:09:00-06	2003
237	108	1	exito	\N	2026-03-02 14:21:00-06	2014
238	108	2	exito	\N	2026-03-02 14:22:00-06	2014
239	108	3	exito	\N	2026-03-02 14:23:00-06	2014
240	108	4	exito	\N	2026-03-02 14:24:00-06	2014
241	108	5	exito	\N	2026-03-02 14:25:00-06	2014
242	108	6	exito	\N	2026-03-02 14:26:00-06	2014
243	108	7	exito	\N	2026-03-02 14:27:00-06	2014
244	108	8	exito	\N	2026-03-02 15:08:00-06	2014
245	108	9	exito	\N	2026-03-02 15:09:00-06	2014
246	108	10	exito	\N	2026-03-02 15:10:00-06	2014
247	108	11	exito	\N	2026-03-02 15:11:00-06	2014
248	108	12	exito	\N	2026-03-02 15:12:00-06	2014
249	108	13	exito	\N	2026-03-02 15:13:00-06	2014
250	108	14	exito	\N	2026-03-02 15:14:00-06	2014
251	108	15	exito	\N	2026-03-02 15:15:00-06	2014
252	108	16	exito	\N	2026-03-02 15:16:00-06	2014
253	108	17	exito	\N	2026-03-02 15:17:00-06	2014
254	108	18	exito	\N	2026-03-02 15:18:00-06	2014
255	108	19	aceptable	\N	2026-03-02 15:19:00-06	2014
256	108	20	aceptable	\N	2026-03-02 15:20:00-06	2014
257	108	21	aceptable	\N	2026-03-02 15:21:00-06	2014
258	108	22	exito	\N	2026-03-02 15:22:00-06	2014
259	108	23	exito	\N	2026-03-02 15:23:00-06	2014
260	108	24	exito	\N	2026-03-02 15:24:00-06	2014
261	108	25	exito	\N	2026-03-02 15:25:00-06	2014
262	108	26	exito	\N	2026-03-02 18:20:00-06	2014
263	108	27	exito	\N	2026-03-02 18:21:00-06	2014
264	108	28	exito	\N	2026-03-02 18:22:00-06	2014
265	108	29	falla	\N	2026-03-02 18:23:00-06	2014
266	108	30	exito	\N	2026-03-02 18:24:00-06	2014
267	108	31	exito	\N	2026-03-02 18:25:00-06	2014
268	108	32	exito	\N	2026-03-02 18:26:00-06	2014
269	108	33	exito	\N	2026-03-02 18:27:00-06	2014
270	108	34	exito	\N	2026-03-02 18:28:00-06	2014
271	108	35	exito	\N	2026-03-02 18:29:00-06	2014
272	108	36	exito	\N	2026-03-02 18:30:00-06	2014
273	108	37	exito	\N	2026-03-02 18:31:00-06	2014
274	108	38	exito	\N	2026-03-02 18:32:00-06	2014
275	110	1	exito	\N	2026-03-16 14:21:00-06	2008
276	110	2	exito	\N	2026-03-16 14:22:00-06	2008
277	110	3	exito	\N	2026-03-16 14:23:00-06	2008
278	110	4	exito	\N	2026-03-16 14:24:00-06	2008
279	110	5	exito	\N	2026-03-16 14:25:00-06	2008
280	110	6	exito	\N	2026-03-16 14:26:00-06	2008
281	110	7	exito	\N	2026-03-16 14:27:00-06	2008
282	110	8	exito	\N	2026-03-16 15:08:00-06	2008
283	110	9	exito	\N	2026-03-16 15:09:00-06	2008
284	110	10	exito	\N	2026-03-16 15:10:00-06	2008
285	110	11	exito	\N	2026-03-16 15:11:00-06	2008
286	110	12	exito	\N	2026-03-16 15:12:00-06	2008
287	110	13	exito	\N	2026-03-16 15:13:00-06	2008
288	110	14	exito	\N	2026-03-16 15:14:00-06	2008
289	110	15	exito	\N	2026-03-16 15:15:00-06	2008
290	110	16	exito	\N	2026-03-16 15:16:00-06	2008
291	110	17	exito	\N	2026-03-16 15:17:00-06	2008
292	110	18	exito	\N	2026-03-16 15:18:00-06	2008
293	110	19	aceptable	\N	2026-03-16 15:19:00-06	2008
294	110	20	no_aceptable	\N	2026-03-16 15:20:00-06	2008
295	110	21	medianamente_aceptable	\N	2026-03-16 15:21:00-06	2008
296	110	22	exito	\N	2026-03-16 15:22:00-06	2008
297	110	23	exito	\N	2026-03-16 15:23:00-06	2008
298	110	24	exito	\N	2026-03-16 15:24:00-06	2008
299	110	25	exito	\N	2026-03-16 15:25:00-06	2008
300	110	26	exito	\N	2026-03-16 18:16:00-06	2008
301	110	27	exito	\N	2026-03-16 18:17:00-06	2008
302	110	28	exito	\N	2026-03-16 18:18:00-06	2008
303	110	29	falla	\N	2026-03-16 18:19:00-06	2008
304	110	30	exito	\N	2026-03-16 18:20:00-06	2008
305	110	31	exito	\N	2026-03-16 18:21:00-06	2008
306	110	32	exito	\N	2026-03-16 18:22:00-06	2008
307	110	33	exito	\N	2026-03-16 18:23:00-06	2008
308	110	34	exito	\N	2026-03-16 18:24:00-06	2008
309	110	35	exito	\N	2026-03-16 18:25:00-06	2008
310	110	36	exito	\N	2026-03-16 18:26:00-06	2008
311	110	37	exito	\N	2026-03-16 18:27:00-06	2008
312	110	38	exito	\N	2026-03-16 18:28:00-06	2008
313	111	1	exito	\N	2026-03-23 14:21:00-06	2015
314	111	2	exito	\N	2026-03-23 14:22:00-06	2015
315	111	3	exito	\N	2026-03-23 14:23:00-06	2015
316	111	4	exito	\N	2026-03-23 14:24:00-06	2015
317	111	5	exito	\N	2026-03-23 14:25:00-06	2015
318	111	6	exito	\N	2026-03-23 14:26:00-06	2015
319	111	7	exito	\N	2026-03-23 14:27:00-06	2015
320	111	8	exito	\N	2026-03-23 15:08:00-06	2015
321	111	9	exito	\N	2026-03-23 15:09:00-06	2015
322	111	10	exito	\N	2026-03-23 15:10:00-06	2015
323	111	11	exito	\N	2026-03-23 15:11:00-06	2015
324	111	12	exito	\N	2026-03-23 15:12:00-06	2015
325	111	13	exito	\N	2026-03-23 15:13:00-06	2015
326	111	14	exito	\N	2026-03-23 15:14:00-06	2015
327	111	15	exito	\N	2026-03-23 15:15:00-06	2015
328	111	16	exito	\N	2026-03-23 15:16:00-06	2015
329	111	17	exito	\N	2026-03-23 15:17:00-06	2015
330	111	18	exito	\N	2026-03-23 15:18:00-06	2015
331	111	19	no_aceptable	\N	2026-03-23 15:19:00-06	2015
332	111	20	medianamente_aceptable	\N	2026-03-23 15:20:00-06	2015
333	111	21	medianamente_aceptable	\N	2026-03-23 15:21:00-06	2015
334	111	22	exito	\N	2026-03-23 15:22:00-06	2015
335	111	23	exito	\N	2026-03-23 15:23:00-06	2015
336	111	24	exito	\N	2026-03-23 15:24:00-06	2015
337	111	25	exito	\N	2026-03-23 15:25:00-06	2015
338	111	26	exito	\N	2026-03-23 18:39:00-06	2015
339	111	27	exito	\N	2026-03-23 18:40:00-06	2015
340	111	28	exito	\N	2026-03-23 18:41:00-06	2015
341	111	29	falla	\N	2026-03-23 18:42:00-06	2015
342	111	30	exito	\N	2026-03-23 18:43:00-06	2015
343	111	31	exito	\N	2026-03-23 18:44:00-06	2015
344	111	32	exito	\N	2026-03-23 18:45:00-06	2015
345	111	33	exito	\N	2026-03-23 18:46:00-06	2015
346	111	34	exito	\N	2026-03-23 18:47:00-06	2015
347	111	35	exito	\N	2026-03-23 18:48:00-06	2015
348	111	36	exito	\N	2026-03-23 18:49:00-06	2015
349	111	37	exito	\N	2026-03-23 18:50:00-06	2015
350	111	38	exito	\N	2026-03-23 18:51:00-06	2015
351	113	1	exito	\N	2026-04-02 14:21:00-06	2012
352	113	2	exito	\N	2026-04-02 14:22:00-06	2012
353	113	3	exito	\N	2026-04-02 14:23:00-06	2012
354	113	4	exito	\N	2026-04-02 14:24:00-06	2012
355	113	5	exito	\N	2026-04-02 14:25:00-06	2012
356	113	6	exito	\N	2026-04-02 14:26:00-06	2012
357	113	7	exito	\N	2026-04-02 14:27:00-06	2012
358	113	8	exito	\N	2026-04-02 15:08:00-06	2012
359	113	9	exito	\N	2026-04-02 15:09:00-06	2012
360	113	10	exito	\N	2026-04-02 15:10:00-06	2012
361	113	11	exito	\N	2026-04-02 15:11:00-06	2012
362	113	12	exito	\N	2026-04-02 15:12:00-06	2012
363	113	13	exito	\N	2026-04-02 15:13:00-06	2012
364	113	14	exito	\N	2026-04-02 15:14:00-06	2012
365	113	15	exito	\N	2026-04-02 15:15:00-06	2012
366	113	16	exito	\N	2026-04-02 15:16:00-06	2012
367	113	17	exito	\N	2026-04-02 15:17:00-06	2012
368	113	18	exito	\N	2026-04-02 15:18:00-06	2012
369	113	19	medianamente_aceptable	\N	2026-04-02 15:19:00-06	2012
370	113	20	aceptable	\N	2026-04-02 15:20:00-06	2012
371	113	21	aceptable	\N	2026-04-02 15:21:00-06	2012
372	113	22	exito	\N	2026-04-02 15:22:00-06	2012
373	113	23	exito	\N	2026-04-02 15:23:00-06	2012
374	113	24	exito	\N	2026-04-02 15:24:00-06	2012
375	113	25	exito	\N	2026-04-02 15:25:00-06	2012
376	113	26	exito	\N	2026-04-02 16:55:00-06	2012
377	113	27	exito	\N	2026-04-02 16:56:00-06	2012
378	113	28	exito	\N	2026-04-02 16:57:00-06	2012
379	113	29	falla	\N	2026-04-02 16:58:00-06	2012
380	113	30	exito	\N	2026-04-02 16:59:00-06	2012
381	113	31	exito	\N	2026-04-02 17:00:00-06	2012
382	113	32	exito	\N	2026-04-02 17:01:00-06	2012
383	113	33	exito	\N	2026-04-02 17:02:00-06	2012
384	113	34	exito	\N	2026-04-02 17:03:00-06	2012
385	113	35	exito	\N	2026-04-02 17:04:00-06	2012
386	113	36	exito	\N	2026-04-02 17:05:00-06	2012
387	113	37	exito	\N	2026-04-02 17:06:00-06	2012
388	113	38	exito	\N	2026-04-02 17:07:00-06	2012
389	114	1	exito	\N	2026-04-09 14:21:00-06	2014
390	114	2	exito	\N	2026-04-09 14:22:00-06	2014
391	114	3	exito	\N	2026-04-09 14:23:00-06	2014
392	114	4	exito	\N	2026-04-09 14:24:00-06	2014
393	114	5	exito	\N	2026-04-09 14:25:00-06	2014
394	114	6	exito	\N	2026-04-09 14:26:00-06	2014
395	114	7	exito	\N	2026-04-09 14:27:00-06	2014
396	114	8	exito	\N	2026-04-09 15:08:00-06	2014
397	114	9	exito	\N	2026-04-09 15:09:00-06	2014
398	114	10	exito	\N	2026-04-09 15:10:00-06	2014
399	114	11	exito	\N	2026-04-09 15:11:00-06	2014
400	114	12	exito	\N	2026-04-09 15:12:00-06	2014
401	114	13	exito	\N	2026-04-09 15:13:00-06	2014
402	114	14	exito	\N	2026-04-09 15:14:00-06	2014
403	114	15	exito	\N	2026-04-09 15:15:00-06	2014
404	114	16	exito	\N	2026-04-09 15:16:00-06	2014
405	114	17	exito	\N	2026-04-09 15:17:00-06	2014
406	114	18	exito	\N	2026-04-09 15:18:00-06	2014
407	114	19	aceptable	\N	2026-04-09 15:19:00-06	2014
408	114	20	aceptable	\N	2026-04-09 15:20:00-06	2014
409	114	21	aceptable	\N	2026-04-09 15:21:00-06	2014
410	114	22	exito	\N	2026-04-09 15:22:00-06	2014
411	114	23	exito	\N	2026-04-09 15:23:00-06	2014
412	114	24	exito	\N	2026-04-09 15:24:00-06	2014
413	114	25	exito	\N	2026-04-09 15:25:00-06	2014
414	114	26	exito	\N	2026-04-09 17:18:00-06	2014
415	114	27	exito	\N	2026-04-09 17:19:00-06	2014
416	114	28	exito	\N	2026-04-09 17:20:00-06	2014
417	114	29	falla	\N	2026-04-09 17:21:00-06	2014
418	114	30	exito	\N	2026-04-09 17:22:00-06	2014
419	114	31	exito	\N	2026-04-09 17:23:00-06	2014
420	114	32	exito	\N	2026-04-09 17:24:00-06	2014
421	114	33	exito	\N	2026-04-09 17:25:00-06	2014
422	114	34	exito	\N	2026-04-09 17:26:00-06	2014
423	114	35	exito	\N	2026-04-09 17:27:00-06	2014
424	114	36	exito	\N	2026-04-09 17:28:00-06	2014
425	114	37	exito	\N	2026-04-09 17:29:00-06	2014
426	114	38	exito	\N	2026-04-09 17:30:00-06	2014
427	115	1	exito	\N	2026-04-16 14:21:00-06	2009
428	115	2	exito	\N	2026-04-16 14:22:00-06	2009
429	115	3	exito	\N	2026-04-16 14:23:00-06	2009
430	115	4	exito	\N	2026-04-16 14:24:00-06	2009
431	115	5	exito	\N	2026-04-16 14:25:00-06	2009
432	115	6	exito	\N	2026-04-16 14:26:00-06	2009
433	115	7	exito	\N	2026-04-16 14:27:00-06	2009
434	115	8	exito	\N	2026-04-16 15:08:00-06	2009
435	115	9	exito	\N	2026-04-16 15:09:00-06	2009
436	115	10	exito	\N	2026-04-16 15:10:00-06	2009
437	115	11	exito	\N	2026-04-16 15:11:00-06	2009
438	115	12	exito	\N	2026-04-16 15:12:00-06	2009
439	115	13	exito	\N	2026-04-16 15:13:00-06	2009
440	115	14	exito	\N	2026-04-16 15:14:00-06	2009
441	115	15	exito	\N	2026-04-16 15:15:00-06	2009
442	115	16	exito	\N	2026-04-16 15:16:00-06	2009
443	115	17	exito	\N	2026-04-16 15:17:00-06	2009
444	115	18	exito	\N	2026-04-16 15:18:00-06	2009
445	115	19	aceptable	\N	2026-04-16 15:19:00-06	2009
446	115	20	aceptable	\N	2026-04-16 15:20:00-06	2009
447	115	21	aceptable	\N	2026-04-16 15:21:00-06	2009
448	115	22	exito	\N	2026-04-16 15:22:00-06	2009
449	115	23	exito	\N	2026-04-16 15:23:00-06	2009
450	115	24	exito	\N	2026-04-16 15:24:00-06	2009
451	115	25	exito	\N	2026-04-16 15:25:00-06	2009
452	115	26	exito	\N	2026-04-16 16:51:00-06	2009
453	115	27	exito	\N	2026-04-16 16:52:00-06	2009
454	115	28	exito	\N	2026-04-16 16:53:00-06	2009
455	115	29	falla	\N	2026-04-16 16:54:00-06	2009
456	115	30	exito	\N	2026-04-16 16:55:00-06	2009
457	115	31	exito	\N	2026-04-16 16:56:00-06	2009
458	115	32	exito	\N	2026-04-16 16:57:00-06	2009
459	115	33	exito	\N	2026-04-16 16:58:00-06	2009
460	115	34	exito	\N	2026-04-16 16:59:00-06	2009
461	115	35	exito	\N	2026-04-16 17:00:00-06	2009
462	115	36	exito	\N	2026-04-16 17:01:00-06	2009
463	115	37	exito	\N	2026-04-16 17:02:00-06	2009
464	115	38	exito	\N	2026-04-16 17:03:00-06	2009
465	116	1	falla	\N	2026-04-19 14:21:00-06	2005
466	116	2	falla	\N	2026-04-19 14:22:00-06	2005
467	116	3	falla	\N	2026-04-19 14:23:00-06	2005
468	116	4	falla	\N	2026-04-19 14:24:00-06	2005
469	116	5	falla	\N	2026-04-19 14:25:00-06	2005
470	116	6	falla	\N	2026-04-19 14:26:00-06	2005
471	116	7	falla	\N	2026-04-19 14:27:00-06	2005
472	116	8	falla	\N	2026-04-19 15:08:00-06	2005
473	116	9	falla	\N	2026-04-19 15:09:00-06	2005
474	116	10	falla	\N	2026-04-19 15:10:00-06	2005
475	116	11	falla	\N	2026-04-19 15:11:00-06	2005
476	116	12	falla	\N	2026-04-19 15:12:00-06	2005
477	116	13	falla	\N	2026-04-19 15:13:00-06	2005
478	116	14	falla	\N	2026-04-19 15:14:00-06	2005
479	116	15	falla	\N	2026-04-19 15:15:00-06	2005
480	116	16	falla	\N	2026-04-19 15:16:00-06	2005
481	116	17	falla	\N	2026-04-19 15:17:00-06	2005
482	116	18	falla	\N	2026-04-19 15:18:00-06	2005
483	116	19	aceptable	\N	2026-04-19 15:19:00-06	2005
484	116	20	aceptable	\N	2026-04-19 15:20:00-06	2005
485	116	21	aceptable	\N	2026-04-19 15:21:00-06	2005
486	116	22	falla	\N	2026-04-19 15:22:00-06	2005
487	116	23	falla	\N	2026-04-19 15:23:00-06	2005
488	116	24	falla	\N	2026-04-19 15:24:00-06	2005
489	116	25	falla	\N	2026-04-19 15:25:00-06	2005
490	116	26	falla	\N	2026-04-19 17:14:00-06	2005
491	116	27	falla	\N	2026-04-19 17:15:00-06	2005
492	116	28	falla	\N	2026-04-19 17:16:00-06	2005
493	116	29	falla	\N	2026-04-19 17:17:00-06	2005
494	116	30	falla	\N	2026-04-19 17:18:00-06	2005
495	116	31	falla	\N	2026-04-19 17:19:00-06	2005
496	116	32	falla	\N	2026-04-19 17:20:00-06	2005
497	116	33	falla	\N	2026-04-19 17:21:00-06	2005
498	116	34	falla	\N	2026-04-19 17:22:00-06	2005
499	116	35	falla	\N	2026-04-19 17:23:00-06	2005
500	116	36	falla	\N	2026-04-19 17:24:00-06	2005
501	116	37	falla	\N	2026-04-19 17:25:00-06	2005
502	116	38	falla	\N	2026-04-19 17:26:00-06	2005
503	117	1	exito	\N	2026-04-26 14:21:00-06	2012
504	117	2	exito	\N	2026-04-26 14:22:00-06	2012
505	117	3	exito	\N	2026-04-26 14:23:00-06	2012
506	117	4	exito	\N	2026-04-26 14:24:00-06	2012
507	117	5	exito	\N	2026-04-26 14:25:00-06	2012
508	117	6	exito	\N	2026-04-26 14:26:00-06	2012
509	117	7	exito	\N	2026-04-26 14:27:00-06	2012
510	117	8	exito	\N	2026-04-26 15:08:00-06	2012
511	117	9	exito	\N	2026-04-26 15:09:00-06	2012
512	117	10	exito	\N	2026-04-26 15:10:00-06	2012
513	117	11	exito	\N	2026-04-26 15:11:00-06	2012
514	117	12	exito	\N	2026-04-26 15:12:00-06	2012
515	117	13	exito	\N	2026-04-26 15:13:00-06	2012
516	117	14	exito	\N	2026-04-26 15:14:00-06	2012
517	117	15	exito	\N	2026-04-26 15:15:00-06	2012
518	117	16	exito	\N	2026-04-26 15:16:00-06	2012
519	117	17	exito	\N	2026-04-26 15:17:00-06	2012
520	117	18	exito	\N	2026-04-26 15:18:00-06	2012
521	117	19	aceptable	\N	2026-04-26 15:19:00-06	2012
522	117	20	aceptable	\N	2026-04-26 15:20:00-06	2012
523	117	21	aceptable	\N	2026-04-26 15:21:00-06	2012
524	117	22	exito	\N	2026-04-26 15:22:00-06	2012
525	117	23	exito	\N	2026-04-26 15:23:00-06	2012
526	117	24	exito	\N	2026-04-26 15:24:00-06	2012
527	117	25	exito	\N	2026-04-26 15:25:00-06	2012
528	117	26	exito	\N	2026-04-26 17:37:00-06	2012
529	117	27	exito	\N	2026-04-26 17:38:00-06	2012
530	117	28	exito	\N	2026-04-26 17:39:00-06	2012
531	117	29	falla	\N	2026-04-26 17:40:00-06	2012
532	117	30	exito	\N	2026-04-26 17:41:00-06	2012
533	117	31	exito	\N	2026-04-26 17:42:00-06	2012
534	117	32	exito	\N	2026-04-26 17:43:00-06	2012
535	117	33	exito	\N	2026-04-26 17:44:00-06	2012
536	117	34	exito	\N	2026-04-26 17:45:00-06	2012
537	117	35	exito	\N	2026-04-26 17:46:00-06	2012
538	117	36	exito	\N	2026-04-26 17:47:00-06	2012
539	117	37	exito	\N	2026-04-26 17:48:00-06	2012
540	117	38	exito	\N	2026-04-26 17:49:00-06	2012
541	119	1	exito	\N	2026-05-10 14:21:00-06	2009
542	119	2	exito	\N	2026-05-10 14:22:00-06	2009
543	119	3	exito	\N	2026-05-10 14:23:00-06	2009
544	119	4	exito	\N	2026-05-10 14:24:00-06	2009
545	119	5	exito	\N	2026-05-10 14:25:00-06	2009
546	119	6	exito	\N	2026-05-10 14:26:00-06	2009
547	119	7	exito	\N	2026-05-10 14:27:00-06	2009
548	119	8	exito	\N	2026-05-10 15:08:00-06	2009
549	119	9	exito	\N	2026-05-10 15:09:00-06	2009
550	119	10	exito	\N	2026-05-10 15:10:00-06	2009
551	119	11	exito	\N	2026-05-10 15:11:00-06	2009
552	119	12	exito	\N	2026-05-10 15:12:00-06	2009
553	119	13	exito	\N	2026-05-10 15:13:00-06	2009
554	119	14	exito	\N	2026-05-10 15:14:00-06	2009
555	119	15	exito	\N	2026-05-10 15:15:00-06	2009
556	119	16	exito	\N	2026-05-10 15:16:00-06	2009
557	119	17	exito	\N	2026-05-10 15:17:00-06	2009
558	119	18	exito	\N	2026-05-10 15:18:00-06	2009
559	119	19	aceptable	\N	2026-05-10 15:19:00-06	2009
560	119	20	aceptable	\N	2026-05-10 15:20:00-06	2009
561	119	21	no_aceptable	\N	2026-05-10 15:21:00-06	2009
562	119	22	exito	\N	2026-05-10 15:22:00-06	2009
563	119	23	exito	\N	2026-05-10 15:23:00-06	2009
564	119	24	exito	\N	2026-05-10 15:24:00-06	2009
565	119	25	exito	\N	2026-05-10 15:25:00-06	2009
566	119	26	exito	\N	2026-05-10 18:23:00-06	2009
567	119	27	exito	\N	2026-05-10 18:24:00-06	2009
568	119	28	exito	\N	2026-05-10 18:25:00-06	2009
569	119	29	falla	\N	2026-05-10 18:26:00-06	2009
570	119	30	exito	\N	2026-05-10 18:27:00-06	2009
571	119	31	exito	\N	2026-05-10 18:28:00-06	2009
572	119	32	exito	\N	2026-05-10 18:29:00-06	2009
573	119	33	exito	\N	2026-05-10 18:30:00-06	2009
574	119	34	exito	\N	2026-05-10 18:31:00-06	2009
575	119	35	exito	\N	2026-05-10 18:32:00-06	2009
576	119	36	exito	\N	2026-05-10 18:33:00-06	2009
577	119	37	exito	\N	2026-05-10 18:34:00-06	2009
578	119	38	exito	\N	2026-05-10 18:35:00-06	2009
579	120	1	exito	\N	2026-05-13 14:21:00-06	2002
580	120	2	exito	\N	2026-05-13 14:22:00-06	2002
581	120	3	exito	\N	2026-05-13 14:23:00-06	2002
582	120	4	exito	\N	2026-05-13 14:24:00-06	2002
583	120	5	exito	\N	2026-05-13 14:25:00-06	2002
584	120	6	exito	\N	2026-05-13 14:26:00-06	2002
585	120	7	exito	\N	2026-05-13 14:27:00-06	2002
586	120	8	exito	\N	2026-05-13 15:08:00-06	2002
587	120	9	exito	\N	2026-05-13 15:09:00-06	2002
588	120	10	exito	\N	2026-05-13 15:10:00-06	2002
589	120	11	exito	\N	2026-05-13 15:11:00-06	2002
590	120	12	exito	\N	2026-05-13 15:12:00-06	2002
591	120	13	exito	\N	2026-05-13 15:13:00-06	2002
592	120	14	exito	\N	2026-05-13 15:14:00-06	2002
593	120	15	exito	\N	2026-05-13 15:15:00-06	2002
594	120	16	exito	\N	2026-05-13 15:16:00-06	2002
595	120	17	exito	\N	2026-05-13 15:17:00-06	2002
596	120	18	exito	\N	2026-05-13 15:18:00-06	2002
597	120	19	aceptable	\N	2026-05-13 15:19:00-06	2002
598	120	20	no_aceptable	\N	2026-05-13 15:20:00-06	2002
599	120	21	medianamente_aceptable	\N	2026-05-13 15:21:00-06	2002
600	120	22	exito	\N	2026-05-13 15:22:00-06	2002
601	120	23	exito	\N	2026-05-13 15:23:00-06	2002
602	120	24	exito	\N	2026-05-13 15:24:00-06	2002
603	120	25	exito	\N	2026-05-13 15:25:00-06	2002
604	120	26	exito	\N	2026-05-13 17:56:00-06	2002
605	120	27	exito	\N	2026-05-13 17:57:00-06	2002
606	120	28	exito	\N	2026-05-13 17:58:00-06	2002
607	120	29	falla	\N	2026-05-13 17:59:00-06	2002
608	120	30	exito	\N	2026-05-13 18:00:00-06	2002
609	120	31	exito	\N	2026-05-13 18:01:00-06	2002
610	120	32	exito	\N	2026-05-13 18:02:00-06	2002
611	120	33	exito	\N	2026-05-13 18:03:00-06	2002
612	120	34	exito	\N	2026-05-13 18:04:00-06	2002
613	120	35	exito	\N	2026-05-13 18:05:00-06	2002
614	120	36	exito	\N	2026-05-13 18:06:00-06	2002
615	120	37	exito	\N	2026-05-13 18:07:00-06	2002
616	120	38	exito	\N	2026-05-13 18:08:00-06	2002
617	121	1	exito	\N	2026-05-20 14:21:00-06	2009
618	121	2	exito	\N	2026-05-20 14:22:00-06	2009
619	121	3	exito	\N	2026-05-20 14:23:00-06	2009
620	121	4	exito	\N	2026-05-20 14:24:00-06	2009
621	121	5	exito	\N	2026-05-20 14:25:00-06	2009
622	121	6	exito	\N	2026-05-20 14:26:00-06	2009
623	121	7	exito	\N	2026-05-20 14:27:00-06	2009
624	121	8	exito	\N	2026-05-20 15:08:00-06	2009
625	121	9	exito	\N	2026-05-20 15:09:00-06	2009
626	121	10	exito	\N	2026-05-20 15:10:00-06	2009
627	121	11	exito	\N	2026-05-20 15:11:00-06	2009
628	121	12	exito	\N	2026-05-20 15:12:00-06	2009
629	121	13	exito	\N	2026-05-20 15:13:00-06	2009
630	121	14	exito	\N	2026-05-20 15:14:00-06	2009
631	121	15	exito	\N	2026-05-20 15:15:00-06	2009
632	121	16	exito	\N	2026-05-20 15:16:00-06	2009
633	121	17	exito	\N	2026-05-20 15:17:00-06	2009
634	121	18	exito	\N	2026-05-20 15:18:00-06	2009
635	121	19	no_aceptable	\N	2026-05-20 15:19:00-06	2009
636	121	20	medianamente_aceptable	\N	2026-05-20 15:20:00-06	2009
637	121	21	medianamente_aceptable	\N	2026-05-20 15:21:00-06	2009
638	121	22	exito	\N	2026-05-20 15:22:00-06	2009
639	121	23	exito	\N	2026-05-20 15:23:00-06	2009
640	121	24	exito	\N	2026-05-20 15:24:00-06	2009
641	121	25	exito	\N	2026-05-20 15:25:00-06	2009
642	121	26	exito	\N	2026-05-20 18:19:00-06	2009
643	121	27	exito	\N	2026-05-20 18:20:00-06	2009
644	121	28	exito	\N	2026-05-20 18:21:00-06	2009
645	121	29	falla	\N	2026-05-20 18:22:00-06	2009
646	121	30	exito	\N	2026-05-20 18:23:00-06	2009
647	121	31	exito	\N	2026-05-20 18:24:00-06	2009
648	121	32	exito	\N	2026-05-20 18:25:00-06	2009
649	121	33	exito	\N	2026-05-20 18:26:00-06	2009
650	121	34	exito	\N	2026-05-20 18:27:00-06	2009
651	121	35	exito	\N	2026-05-20 18:28:00-06	2009
652	121	36	exito	\N	2026-05-20 18:29:00-06	2009
653	121	37	exito	\N	2026-05-20 18:30:00-06	2009
654	121	38	exito	\N	2026-05-20 18:31:00-06	2009
655	122	1	exito	\N	2026-05-27 14:21:00-06	2017
656	122	2	exito	\N	2026-05-27 14:22:00-06	2017
657	122	3	exito	\N	2026-05-27 14:23:00-06	2017
658	122	4	exito	\N	2026-05-27 14:24:00-06	2017
659	122	5	exito	\N	2026-05-27 14:25:00-06	2017
660	122	6	exito	\N	2026-05-27 14:26:00-06	2017
661	122	7	exito	\N	2026-05-27 14:27:00-06	2017
662	122	8	exito	\N	2026-05-27 15:08:00-06	2017
663	122	9	exito	\N	2026-05-27 15:09:00-06	2017
664	122	10	exito	\N	2026-05-27 15:10:00-06	2017
665	122	11	exito	\N	2026-05-27 15:11:00-06	2017
666	122	12	exito	\N	2026-05-27 15:12:00-06	2017
667	122	13	exito	\N	2026-05-27 15:13:00-06	2017
668	122	14	exito	\N	2026-05-27 15:14:00-06	2017
669	122	15	exito	\N	2026-05-27 15:15:00-06	2017
670	122	16	exito	\N	2026-05-27 15:16:00-06	2017
671	122	17	exito	\N	2026-05-27 15:17:00-06	2017
672	122	18	exito	\N	2026-05-27 15:18:00-06	2017
673	122	19	medianamente_aceptable	\N	2026-05-27 15:19:00-06	2017
674	122	20	medianamente_aceptable	\N	2026-05-27 15:20:00-06	2017
675	122	21	aceptable	\N	2026-05-27 15:21:00-06	2017
676	122	22	exito	\N	2026-05-27 15:22:00-06	2017
677	122	23	exito	\N	2026-05-27 15:23:00-06	2017
678	122	24	exito	\N	2026-05-27 15:24:00-06	2017
679	122	25	exito	\N	2026-05-27 15:25:00-06	2017
680	122	26	exito	\N	2026-05-27 18:42:00-06	2017
681	122	27	exito	\N	2026-05-27 18:43:00-06	2017
682	122	28	exito	\N	2026-05-27 18:44:00-06	2017
683	122	29	falla	\N	2026-05-27 18:45:00-06	2017
684	122	30	exito	\N	2026-05-27 18:46:00-06	2017
685	122	31	exito	\N	2026-05-27 18:47:00-06	2017
686	122	32	exito	\N	2026-05-27 18:48:00-06	2017
687	122	33	exito	\N	2026-05-27 18:49:00-06	2017
688	122	34	exito	\N	2026-05-27 18:50:00-06	2017
689	122	35	exito	\N	2026-05-27 18:51:00-06	2017
690	122	36	exito	\N	2026-05-27 18:52:00-06	2017
691	122	37	exito	\N	2026-05-27 18:53:00-06	2017
692	122	38	exito	\N	2026-05-27 18:54:00-06	2017
693	123	1	exito	\N	2026-06-03 14:21:00-06	2018
694	123	2	exito	\N	2026-06-03 14:22:00-06	2018
695	123	3	exito	\N	2026-06-03 14:23:00-06	2018
696	123	4	exito	\N	2026-06-03 14:24:00-06	2018
697	123	5	exito	\N	2026-06-03 14:25:00-06	2018
698	123	6	exito	\N	2026-06-03 14:26:00-06	2018
699	123	7	exito	\N	2026-06-03 14:27:00-06	2018
700	123	8	exito	\N	2026-06-03 15:08:00-06	2018
701	123	9	exito	\N	2026-06-03 15:09:00-06	2018
702	123	10	exito	\N	2026-06-03 15:10:00-06	2018
703	123	11	exito	\N	2026-06-03 15:11:00-06	2018
704	123	12	exito	\N	2026-06-03 15:12:00-06	2018
705	123	13	exito	\N	2026-06-03 15:13:00-06	2018
706	123	14	exito	\N	2026-06-03 15:14:00-06	2018
707	123	15	exito	\N	2026-06-03 15:15:00-06	2018
708	123	16	exito	\N	2026-06-03 15:16:00-06	2018
709	123	17	exito	\N	2026-06-03 15:17:00-06	2018
710	123	18	exito	\N	2026-06-03 15:18:00-06	2018
711	123	19	medianamente_aceptable	\N	2026-06-03 15:19:00-06	2018
712	123	20	aceptable	\N	2026-06-03 15:20:00-06	2018
713	123	21	aceptable	\N	2026-06-03 15:21:00-06	2018
714	123	22	exito	\N	2026-06-03 15:22:00-06	2018
715	123	23	exito	\N	2026-06-03 15:23:00-06	2018
716	123	24	exito	\N	2026-06-03 15:24:00-06	2018
717	123	25	exito	\N	2026-06-03 15:25:00-06	2018
718	123	26	exito	\N	2026-06-03 19:05:00-06	2018
719	123	27	exito	\N	2026-06-03 19:06:00-06	2018
720	123	28	exito	\N	2026-06-03 19:07:00-06	2018
721	123	29	falla	\N	2026-06-03 19:08:00-06	2018
722	123	30	exito	\N	2026-06-03 19:09:00-06	2018
723	123	31	exito	\N	2026-06-03 19:10:00-06	2018
724	123	32	exito	\N	2026-06-03 19:11:00-06	2018
725	123	33	exito	\N	2026-06-03 19:12:00-06	2018
726	123	34	exito	\N	2026-06-03 19:13:00-06	2018
727	123	35	exito	\N	2026-06-03 19:14:00-06	2018
728	123	36	exito	\N	2026-06-03 19:15:00-06	2018
729	123	37	exito	\N	2026-06-03 19:16:00-06	2018
730	123	38	exito	\N	2026-06-03 19:17:00-06	2018
731	125	1	exito	\N	2026-06-13 14:21:00-06	2007
732	125	2	exito	\N	2026-06-13 14:22:00-06	2007
733	125	3	exito	\N	2026-06-13 14:23:00-06	2007
734	125	4	exito	\N	2026-06-13 14:24:00-06	2007
735	125	5	exito	\N	2026-06-13 14:25:00-06	2007
736	125	6	exito	\N	2026-06-13 14:26:00-06	2007
737	125	7	exito	\N	2026-06-13 14:27:00-06	2007
738	125	8	exito	\N	2026-06-13 15:08:00-06	2007
739	125	9	exito	\N	2026-06-13 15:09:00-06	2007
740	125	10	exito	\N	2026-06-13 15:10:00-06	2007
741	125	11	exito	\N	2026-06-13 15:11:00-06	2007
742	125	12	exito	\N	2026-06-13 15:12:00-06	2007
743	125	13	exito	\N	2026-06-13 15:13:00-06	2007
744	125	14	exito	\N	2026-06-13 15:14:00-06	2007
745	125	15	exito	\N	2026-06-13 15:15:00-06	2007
746	125	16	exito	\N	2026-06-13 15:16:00-06	2007
747	125	17	exito	\N	2026-06-13 15:17:00-06	2007
748	125	18	exito	\N	2026-06-13 15:18:00-06	2007
749	125	19	aceptable	\N	2026-06-13 15:19:00-06	2007
750	125	20	aceptable	\N	2026-06-13 15:20:00-06	2007
751	125	21	aceptable	\N	2026-06-13 15:21:00-06	2007
752	125	22	exito	\N	2026-06-13 15:22:00-06	2007
753	125	23	exito	\N	2026-06-13 15:23:00-06	2007
754	125	24	exito	\N	2026-06-13 15:24:00-06	2007
755	125	25	exito	\N	2026-06-13 15:25:00-06	2007
756	125	26	exito	\N	2026-06-13 16:31:00-06	2007
757	125	27	exito	\N	2026-06-13 16:32:00-06	2007
758	125	28	exito	\N	2026-06-13 16:33:00-06	2007
759	125	29	falla	\N	2026-06-13 16:34:00-06	2007
760	125	30	exito	\N	2026-06-13 16:35:00-06	2007
761	125	31	exito	\N	2026-06-13 16:36:00-06	2007
762	125	32	exito	\N	2026-06-13 16:37:00-06	2007
763	125	33	exito	\N	2026-06-13 16:38:00-06	2007
764	125	34	exito	\N	2026-06-13 16:39:00-06	2007
765	125	35	exito	\N	2026-06-13 16:40:00-06	2007
766	125	36	exito	\N	2026-06-13 16:41:00-06	2007
767	125	37	exito	\N	2026-06-13 16:42:00-06	2007
768	125	38	exito	\N	2026-06-13 16:43:00-06	2007
769	126	1	exito	\N	2026-06-20 14:21:00-06	2001
770	126	2	exito	\N	2026-06-20 14:22:00-06	2001
771	126	3	exito	\N	2026-06-20 14:23:00-06	2001
772	126	4	exito	\N	2026-06-20 14:24:00-06	2001
773	126	5	exito	\N	2026-06-20 14:25:00-06	2001
774	126	6	exito	\N	2026-06-20 14:26:00-06	2001
775	126	7	exito	\N	2026-06-20 14:27:00-06	2001
776	126	8	exito	\N	2026-06-20 15:08:00-06	2001
777	126	9	exito	\N	2026-06-20 15:09:00-06	2001
778	126	10	exito	\N	2026-06-20 15:10:00-06	2001
779	126	11	exito	\N	2026-06-20 15:11:00-06	2001
780	126	12	exito	\N	2026-06-20 15:12:00-06	2001
781	126	13	exito	\N	2026-06-20 15:13:00-06	2001
782	126	14	exito	\N	2026-06-20 15:14:00-06	2001
783	126	15	exito	\N	2026-06-20 15:15:00-06	2001
784	126	16	exito	\N	2026-06-20 15:16:00-06	2001
785	126	17	exito	\N	2026-06-20 15:17:00-06	2001
786	126	18	exito	\N	2026-06-20 15:18:00-06	2001
787	126	19	aceptable	\N	2026-06-20 15:19:00-06	2001
788	126	20	aceptable	\N	2026-06-20 15:20:00-06	2001
789	126	21	aceptable	\N	2026-06-20 15:21:00-06	2001
790	126	22	exito	\N	2026-06-20 15:22:00-06	2001
791	126	23	exito	\N	2026-06-20 15:23:00-06	2001
792	126	24	exito	\N	2026-06-20 15:24:00-06	2001
793	126	25	exito	\N	2026-06-20 15:25:00-06	2001
794	126	26	exito	\N	2026-06-20 16:54:00-06	2001
795	126	27	exito	\N	2026-06-20 16:55:00-06	2001
796	126	28	exito	\N	2026-06-20 16:56:00-06	2001
797	126	29	falla	\N	2026-06-20 16:57:00-06	2001
798	126	30	exito	\N	2026-06-20 16:58:00-06	2001
799	126	31	exito	\N	2026-06-20 16:59:00-06	2001
800	126	32	exito	\N	2026-06-20 17:00:00-06	2001
801	126	33	exito	\N	2026-06-20 17:01:00-06	2001
802	126	34	exito	\N	2026-06-20 17:02:00-06	2001
803	126	35	exito	\N	2026-06-20 17:03:00-06	2001
804	126	36	exito	\N	2026-06-20 17:04:00-06	2001
805	126	37	exito	\N	2026-06-20 17:05:00-06	2001
806	126	38	exito	\N	2026-06-20 17:06:00-06	2001
807	128	1	exito	\N	2026-06-30 14:21:00-06	2011
808	128	2	exito	\N	2026-06-30 14:22:00-06	2011
809	128	3	exito	\N	2026-06-30 14:23:00-06	2011
810	128	4	exito	\N	2026-06-30 14:24:00-06	2011
811	128	5	exito	\N	2026-06-30 14:25:00-06	2011
812	128	6	exito	\N	2026-06-30 14:26:00-06	2011
813	128	7	exito	\N	2026-06-30 14:27:00-06	2011
814	128	8	exito	\N	2026-06-30 15:08:00-06	2011
815	128	9	exito	\N	2026-06-30 15:09:00-06	2011
816	128	10	exito	\N	2026-06-30 15:10:00-06	2011
817	128	11	exito	\N	2026-06-30 15:11:00-06	2011
818	128	12	exito	\N	2026-06-30 15:12:00-06	2011
819	128	13	exito	\N	2026-06-30 15:13:00-06	2011
820	128	14	exito	\N	2026-06-30 15:14:00-06	2011
821	128	15	exito	\N	2026-06-30 15:15:00-06	2011
822	128	16	exito	\N	2026-06-30 15:16:00-06	2011
823	128	17	exito	\N	2026-06-30 15:17:00-06	2011
824	128	18	exito	\N	2026-06-30 15:18:00-06	2011
825	128	19	aceptable	\N	2026-06-30 15:19:00-06	2011
826	128	20	aceptable	\N	2026-06-30 15:20:00-06	2011
827	128	21	aceptable	\N	2026-06-30 15:21:00-06	2011
828	128	22	exito	\N	2026-06-30 15:22:00-06	2011
829	128	23	exito	\N	2026-06-30 15:23:00-06	2011
830	128	24	exito	\N	2026-06-30 15:24:00-06	2011
831	128	25	exito	\N	2026-06-30 15:25:00-06	2011
832	128	26	exito	\N	2026-06-30 17:40:00-06	2011
833	128	27	exito	\N	2026-06-30 17:41:00-06	2011
834	128	28	exito	\N	2026-06-30 17:42:00-06	2011
835	128	29	falla	\N	2026-06-30 17:43:00-06	2011
836	128	30	exito	\N	2026-06-30 17:44:00-06	2011
837	128	31	exito	\N	2026-06-30 17:45:00-06	2011
838	128	32	exito	\N	2026-06-30 17:46:00-06	2011
839	128	33	exito	\N	2026-06-30 17:47:00-06	2011
840	128	34	exito	\N	2026-06-30 17:48:00-06	2011
841	128	35	exito	\N	2026-06-30 17:49:00-06	2011
842	128	36	exito	\N	2026-06-30 17:50:00-06	2011
843	128	37	exito	\N	2026-06-30 17:51:00-06	2011
844	128	38	exito	\N	2026-06-30 17:52:00-06	2011
845	129	1	exito	\N	2026-07-07 14:21:00-06	2012
846	129	2	exito	\N	2026-07-07 14:22:00-06	2012
847	129	3	exito	\N	2026-07-07 14:23:00-06	2012
848	129	4	exito	\N	2026-07-07 14:24:00-06	2012
849	129	5	exito	\N	2026-07-07 14:25:00-06	2012
850	129	6	exito	\N	2026-07-07 14:26:00-06	2012
851	129	7	exito	\N	2026-07-07 14:27:00-06	2012
852	129	8	exito	\N	2026-07-07 15:08:00-06	2012
853	129	9	exito	\N	2026-07-07 15:09:00-06	2012
854	129	10	exito	\N	2026-07-07 15:10:00-06	2012
855	129	11	exito	\N	2026-07-07 15:11:00-06	2012
856	129	12	exito	\N	2026-07-07 15:12:00-06	2012
857	129	13	exito	\N	2026-07-07 15:13:00-06	2012
858	129	14	exito	\N	2026-07-07 15:14:00-06	2012
859	129	15	exito	\N	2026-07-07 15:15:00-06	2012
860	129	16	exito	\N	2026-07-07 15:16:00-06	2012
861	129	17	exito	\N	2026-07-07 15:17:00-06	2012
862	129	18	exito	\N	2026-07-07 15:18:00-06	2012
863	129	19	aceptable	\N	2026-07-07 15:19:00-06	2012
864	129	20	aceptable	\N	2026-07-07 15:20:00-06	2012
865	129	21	no_aceptable	\N	2026-07-07 15:21:00-06	2012
866	129	22	exito	\N	2026-07-07 15:22:00-06	2012
867	129	23	exito	\N	2026-07-07 15:23:00-06	2012
868	129	24	exito	\N	2026-07-07 15:24:00-06	2012
869	129	25	exito	\N	2026-07-07 15:25:00-06	2012
870	129	26	exito	\N	2026-07-07 18:03:00-06	2012
871	129	27	exito	\N	2026-07-07 18:04:00-06	2012
872	129	28	exito	\N	2026-07-07 18:05:00-06	2012
873	129	29	falla	\N	2026-07-07 18:06:00-06	2012
874	129	30	exito	\N	2026-07-07 18:07:00-06	2012
875	129	31	exito	\N	2026-07-07 18:08:00-06	2012
876	129	32	exito	\N	2026-07-07 18:09:00-06	2012
877	129	33	exito	\N	2026-07-07 18:10:00-06	2012
878	129	34	exito	\N	2026-07-07 18:11:00-06	2012
879	129	35	exito	\N	2026-07-07 18:12:00-06	2012
880	129	36	exito	\N	2026-07-07 18:13:00-06	2012
881	129	37	exito	\N	2026-07-07 18:14:00-06	2012
882	129	38	exito	\N	2026-07-07 18:15:00-06	2012
883	131	1	exito	\N	2026-07-21 14:21:00-06	2012
884	131	2	exito	\N	2026-07-21 14:22:00-06	2012
885	131	3	exito	\N	2026-07-21 14:23:00-06	2012
886	131	4	exito	\N	2026-07-21 14:24:00-06	2012
887	131	5	exito	\N	2026-07-21 14:25:00-06	2012
888	131	6	exito	\N	2026-07-21 14:26:00-06	2012
889	131	7	exito	\N	2026-07-21 14:27:00-06	2012
890	131	8	exito	\N	2026-07-21 15:08:00-06	2012
891	131	9	exito	\N	2026-07-21 15:09:00-06	2012
892	131	10	exito	\N	2026-07-21 15:10:00-06	2012
893	131	11	exito	\N	2026-07-21 15:11:00-06	2012
894	131	12	exito	\N	2026-07-21 15:12:00-06	2012
895	131	13	exito	\N	2026-07-21 15:13:00-06	2012
896	131	14	exito	\N	2026-07-21 15:14:00-06	2012
897	131	15	exito	\N	2026-07-21 15:15:00-06	2012
898	131	16	exito	\N	2026-07-21 15:16:00-06	2012
899	131	17	exito	\N	2026-07-21 15:17:00-06	2012
900	131	18	exito	\N	2026-07-21 15:18:00-06	2012
901	131	19	no_aceptable	\N	2026-07-21 15:19:00-06	2012
902	131	20	medianamente_aceptable	\N	2026-07-21 15:20:00-06	2012
903	131	21	medianamente_aceptable	\N	2026-07-21 15:21:00-06	2012
904	131	22	exito	\N	2026-07-21 15:22:00-06	2012
905	131	23	exito	\N	2026-07-21 15:23:00-06	2012
906	131	24	exito	\N	2026-07-21 15:24:00-06	2012
907	131	25	exito	\N	2026-07-21 15:25:00-06	2012
908	131	26	exito	\N	2026-07-21 17:59:00-06	2012
909	131	27	exito	\N	2026-07-21 18:00:00-06	2012
910	131	28	exito	\N	2026-07-21 18:01:00-06	2012
911	131	29	falla	\N	2026-07-21 18:02:00-06	2012
912	131	30	exito	\N	2026-07-21 18:03:00-06	2012
913	131	31	exito	\N	2026-07-21 18:04:00-06	2012
914	131	32	exito	\N	2026-07-21 18:05:00-06	2012
915	131	33	exito	\N	2026-07-21 18:06:00-06	2012
916	131	34	exito	\N	2026-07-21 18:07:00-06	2012
917	131	35	exito	\N	2026-07-21 18:08:00-06	2012
918	131	36	exito	\N	2026-07-21 18:09:00-06	2012
919	131	37	exito	\N	2026-07-21 18:10:00-06	2012
920	131	38	exito	\N	2026-07-21 18:11:00-06	2012
921	132	1	exito	\N	2026-07-24 14:21:00-06	2007
922	132	2	exito	\N	2026-07-24 14:22:00-06	2007
923	132	3	exito	\N	2026-07-24 14:23:00-06	2007
924	132	4	exito	\N	2026-07-24 14:24:00-06	2007
925	132	5	exito	\N	2026-07-24 14:25:00-06	2007
926	132	6	exito	\N	2026-07-24 14:26:00-06	2007
927	132	7	exito	\N	2026-07-24 14:27:00-06	2007
928	132	8	exito	\N	2026-07-24 15:08:00-06	2007
929	132	9	exito	\N	2026-07-24 15:09:00-06	2007
930	132	10	exito	\N	2026-07-24 15:10:00-06	2007
931	132	11	exito	\N	2026-07-24 15:11:00-06	2007
932	132	12	exito	\N	2026-07-24 15:12:00-06	2007
933	132	13	exito	\N	2026-07-24 15:13:00-06	2007
934	132	14	exito	\N	2026-07-24 15:14:00-06	2007
935	132	15	exito	\N	2026-07-24 15:15:00-06	2007
936	132	16	exito	\N	2026-07-24 15:16:00-06	2007
937	132	17	exito	\N	2026-07-24 15:17:00-06	2007
938	132	18	exito	\N	2026-07-24 15:18:00-06	2007
939	132	19	medianamente_aceptable	\N	2026-07-24 15:19:00-06	2007
940	132	20	medianamente_aceptable	\N	2026-07-24 15:20:00-06	2007
941	132	21	aceptable	\N	2026-07-24 15:21:00-06	2007
942	132	22	exito	\N	2026-07-24 15:22:00-06	2007
943	132	23	exito	\N	2026-07-24 15:23:00-06	2007
944	132	24	exito	\N	2026-07-24 15:24:00-06	2007
945	132	25	exito	\N	2026-07-24 15:25:00-06	2007
946	132	26	exito	\N	2026-07-24 18:22:00-06	2007
947	132	27	exito	\N	2026-07-24 18:23:00-06	2007
948	132	28	exito	\N	2026-07-24 18:24:00-06	2007
949	132	29	falla	\N	2026-07-24 18:25:00-06	2007
950	132	30	exito	\N	2026-07-24 18:26:00-06	2007
951	132	31	exito	\N	2026-07-24 18:27:00-06	2007
952	132	32	exito	\N	2026-07-24 18:28:00-06	2007
953	132	33	exito	\N	2026-07-24 18:29:00-06	2007
954	132	34	exito	\N	2026-07-24 18:30:00-06	2007
955	132	35	exito	\N	2026-07-24 18:31:00-06	2007
956	132	36	exito	\N	2026-07-24 18:32:00-06	2007
957	132	37	exito	\N	2026-07-24 18:33:00-06	2007
958	132	38	exito	\N	2026-07-24 18:34:00-06	2007
959	133	1	exito	\N	2026-07-31 14:21:00-06	2015
960	133	2	exito	\N	2026-07-31 14:22:00-06	2015
961	133	3	exito	\N	2026-07-31 14:23:00-06	2015
962	133	4	exito	\N	2026-07-31 14:24:00-06	2015
963	133	5	exito	\N	2026-07-31 14:25:00-06	2015
964	133	6	exito	\N	2026-07-31 14:26:00-06	2015
965	133	7	exito	\N	2026-07-31 14:27:00-06	2015
966	133	8	exito	\N	2026-07-31 15:08:00-06	2015
967	133	9	exito	\N	2026-07-31 15:09:00-06	2015
968	133	10	exito	\N	2026-07-31 15:10:00-06	2015
969	133	11	exito	\N	2026-07-31 15:11:00-06	2015
970	133	12	exito	\N	2026-07-31 15:12:00-06	2015
971	133	13	exito	\N	2026-07-31 15:13:00-06	2015
972	133	14	exito	\N	2026-07-31 15:14:00-06	2015
973	133	15	exito	\N	2026-07-31 15:15:00-06	2015
974	133	16	exito	\N	2026-07-31 15:16:00-06	2015
975	133	17	exito	\N	2026-07-31 15:17:00-06	2015
976	133	18	exito	\N	2026-07-31 15:18:00-06	2015
977	133	19	medianamente_aceptable	\N	2026-07-31 15:19:00-06	2015
978	133	20	aceptable	\N	2026-07-31 15:20:00-06	2015
979	133	21	aceptable	\N	2026-07-31 15:21:00-06	2015
980	133	22	exito	\N	2026-07-31 15:22:00-06	2015
981	133	23	exito	\N	2026-07-31 15:23:00-06	2015
982	133	24	exito	\N	2026-07-31 15:24:00-06	2015
983	133	25	exito	\N	2026-07-31 15:25:00-06	2015
984	133	26	exito	\N	2026-07-31 18:45:00-06	2015
985	133	27	exito	\N	2026-07-31 18:46:00-06	2015
986	133	28	exito	\N	2026-07-31 18:47:00-06	2015
987	133	29	falla	\N	2026-07-31 18:48:00-06	2015
988	133	30	exito	\N	2026-07-31 18:49:00-06	2015
989	133	31	exito	\N	2026-07-31 18:50:00-06	2015
990	133	32	exito	\N	2026-07-31 18:51:00-06	2015
991	133	33	exito	\N	2026-07-31 18:52:00-06	2015
992	133	34	exito	\N	2026-07-31 18:53:00-06	2015
993	133	35	exito	\N	2026-07-31 18:54:00-06	2015
994	133	36	exito	\N	2026-07-31 18:55:00-06	2015
995	133	37	exito	\N	2026-07-31 18:56:00-06	2015
996	133	38	exito	\N	2026-07-31 18:57:00-06	2015
997	134	1	exito	\N	2026-08-07 14:21:00-06	2002
998	134	2	exito	\N	2026-08-07 14:22:00-06	2002
999	134	3	exito	\N	2026-08-07 14:23:00-06	2002
1000	134	4	exito	\N	2026-08-07 14:24:00-06	2002
1001	134	5	exito	\N	2026-08-07 14:25:00-06	2002
1002	134	6	exito	\N	2026-08-07 14:26:00-06	2002
1003	134	7	exito	\N	2026-08-07 14:27:00-06	2002
1004	134	8	exito	\N	2026-08-07 15:08:00-06	2002
1005	134	9	exito	\N	2026-08-07 15:09:00-06	2002
1006	134	10	exito	\N	2026-08-07 15:10:00-06	2002
1007	134	11	exito	\N	2026-08-07 15:11:00-06	2002
1008	134	12	exito	\N	2026-08-07 15:12:00-06	2002
1009	134	13	exito	\N	2026-08-07 15:13:00-06	2002
1010	134	14	exito	\N	2026-08-07 15:14:00-06	2002
1011	134	15	exito	\N	2026-08-07 15:15:00-06	2002
1012	134	16	exito	\N	2026-08-07 15:16:00-06	2002
1013	134	17	exito	\N	2026-08-07 15:17:00-06	2002
1014	134	18	exito	\N	2026-08-07 15:18:00-06	2002
1015	134	19	aceptable	\N	2026-08-07 15:19:00-06	2002
1016	134	20	aceptable	\N	2026-08-07 15:20:00-06	2002
1017	134	21	aceptable	\N	2026-08-07 15:21:00-06	2002
1018	134	22	exito	\N	2026-08-07 15:22:00-06	2002
1019	134	23	exito	\N	2026-08-07 15:23:00-06	2002
1020	134	24	exito	\N	2026-08-07 15:24:00-06	2002
1021	134	25	exito	\N	2026-08-07 15:25:00-06	2002
1022	134	26	exito	\N	2026-08-07 19:08:00-06	2002
1023	134	27	exito	\N	2026-08-07 19:09:00-06	2002
1024	134	28	exito	\N	2026-08-07 19:10:00-06	2002
1025	134	29	falla	\N	2026-08-07 19:11:00-06	2002
1026	134	30	exito	\N	2026-08-07 19:12:00-06	2002
1027	134	31	exito	\N	2026-08-07 19:13:00-06	2002
1028	134	32	exito	\N	2026-08-07 19:14:00-06	2002
1029	134	33	exito	\N	2026-08-07 19:15:00-06	2002
1030	134	34	exito	\N	2026-08-07 19:16:00-06	2002
1031	134	35	exito	\N	2026-08-07 19:17:00-06	2002
1032	134	36	exito	\N	2026-08-07 19:18:00-06	2002
1033	134	37	exito	\N	2026-08-07 19:19:00-06	2002
1034	134	38	exito	\N	2026-08-07 19:20:00-06	2002
1035	135	1	exito	\N	2026-08-14 14:21:00-06	2009
1036	135	2	exito	\N	2026-08-14 14:22:00-06	2009
1037	135	3	exito	\N	2026-08-14 14:23:00-06	2009
1038	135	4	exito	\N	2026-08-14 14:24:00-06	2009
1039	135	5	exito	\N	2026-08-14 14:25:00-06	2009
1040	135	6	exito	\N	2026-08-14 14:26:00-06	2009
1041	135	7	exito	\N	2026-08-14 14:27:00-06	2009
1042	135	8	exito	\N	2026-08-14 15:08:00-06	2009
1043	135	9	exito	\N	2026-08-14 15:09:00-06	2009
1044	135	10	exito	\N	2026-08-14 15:10:00-06	2009
1045	135	11	exito	\N	2026-08-14 15:11:00-06	2009
1046	135	12	exito	\N	2026-08-14 15:12:00-06	2009
1047	135	13	exito	\N	2026-08-14 15:13:00-06	2009
1048	135	14	exito	\N	2026-08-14 15:14:00-06	2009
1049	135	15	exito	\N	2026-08-14 15:15:00-06	2009
1050	135	16	exito	\N	2026-08-14 15:16:00-06	2009
1051	135	17	exito	\N	2026-08-14 15:17:00-06	2009
1052	135	18	exito	\N	2026-08-14 15:18:00-06	2009
1053	135	19	aceptable	\N	2026-08-14 15:19:00-06	2009
1054	135	20	aceptable	\N	2026-08-14 15:20:00-06	2009
1055	135	21	aceptable	\N	2026-08-14 15:21:00-06	2009
1056	135	22	exito	\N	2026-08-14 15:22:00-06	2009
1057	135	23	exito	\N	2026-08-14 15:23:00-06	2009
1058	135	24	exito	\N	2026-08-14 15:24:00-06	2009
1059	135	25	exito	\N	2026-08-14 15:25:00-06	2009
1060	135	26	exito	\N	2026-08-14 16:11:00-06	2009
1061	135	27	exito	\N	2026-08-14 16:12:00-06	2009
1062	135	28	exito	\N	2026-08-14 16:13:00-06	2009
1063	135	29	falla	\N	2026-08-14 16:14:00-06	2009
1064	135	30	exito	\N	2026-08-14 16:15:00-06	2009
1065	135	31	exito	\N	2026-08-14 16:16:00-06	2009
1066	135	32	exito	\N	2026-08-14 16:17:00-06	2009
1067	135	33	exito	\N	2026-08-14 16:18:00-06	2009
1068	135	34	exito	\N	2026-08-14 16:19:00-06	2009
1069	135	35	exito	\N	2026-08-14 16:20:00-06	2009
1070	135	36	exito	\N	2026-08-14 16:21:00-06	2009
1071	135	37	exito	\N	2026-08-14 16:22:00-06	2009
1072	135	38	exito	\N	2026-08-14 16:23:00-06	2009
1073	137	1	exito	\N	2026-08-24 14:21:00-06	2012
1074	137	2	exito	\N	2026-08-24 14:22:00-06	2012
1075	137	3	exito	\N	2026-08-24 14:23:00-06	2012
1076	137	4	exito	\N	2026-08-24 14:24:00-06	2012
1077	137	5	exito	\N	2026-08-24 14:25:00-06	2012
1078	137	6	exito	\N	2026-08-24 14:26:00-06	2012
1079	137	7	exito	\N	2026-08-24 14:27:00-06	2012
1080	137	8	exito	\N	2026-08-24 15:08:00-06	2012
1081	137	9	exito	\N	2026-08-24 15:09:00-06	2012
1082	137	10	exito	\N	2026-08-24 15:10:00-06	2012
1083	137	11	exito	\N	2026-08-24 15:11:00-06	2012
1084	137	12	exito	\N	2026-08-24 15:12:00-06	2012
1085	137	13	exito	\N	2026-08-24 15:13:00-06	2012
1086	137	14	exito	\N	2026-08-24 15:14:00-06	2012
1087	137	15	exito	\N	2026-08-24 15:15:00-06	2012
1088	137	16	exito	\N	2026-08-24 15:16:00-06	2012
1089	137	17	exito	\N	2026-08-24 15:17:00-06	2012
1090	137	18	exito	\N	2026-08-24 15:18:00-06	2012
1091	137	19	aceptable	\N	2026-08-24 15:19:00-06	2012
1092	137	20	aceptable	\N	2026-08-24 15:20:00-06	2012
1093	137	21	aceptable	\N	2026-08-24 15:21:00-06	2012
1094	137	22	exito	\N	2026-08-24 15:22:00-06	2012
1095	137	23	exito	\N	2026-08-24 15:23:00-06	2012
1096	137	24	exito	\N	2026-08-24 15:24:00-06	2012
1097	137	25	exito	\N	2026-08-24 15:25:00-06	2012
1098	137	26	exito	\N	2026-08-24 16:57:00-06	2012
1099	137	27	exito	\N	2026-08-24 16:58:00-06	2012
1100	137	28	exito	\N	2026-08-24 16:59:00-06	2012
1101	137	29	falla	\N	2026-08-24 17:00:00-06	2012
1102	137	30	exito	\N	2026-08-24 17:01:00-06	2012
1103	137	31	exito	\N	2026-08-24 17:02:00-06	2012
1104	137	32	exito	\N	2026-08-24 17:03:00-06	2012
1105	137	33	exito	\N	2026-08-24 17:04:00-06	2012
1106	137	34	exito	\N	2026-08-24 17:05:00-06	2012
1107	137	35	exito	\N	2026-08-24 17:06:00-06	2012
1108	137	36	exito	\N	2026-08-24 17:07:00-06	2012
1109	137	37	exito	\N	2026-08-24 17:08:00-06	2012
1110	137	38	exito	\N	2026-08-24 17:09:00-06	2012
1111	138	1	exito	\N	2026-08-31 14:21:00-06	2011
1112	138	2	exito	\N	2026-08-31 14:22:00-06	2011
1113	138	3	exito	\N	2026-08-31 14:23:00-06	2011
1114	138	4	exito	\N	2026-08-31 14:24:00-06	2011
1115	138	5	exito	\N	2026-08-31 14:25:00-06	2011
1116	138	6	exito	\N	2026-08-31 14:26:00-06	2011
1117	138	7	exito	\N	2026-08-31 14:27:00-06	2011
1118	138	8	exito	\N	2026-08-31 15:08:00-06	2011
1119	138	9	exito	\N	2026-08-31 15:09:00-06	2011
1120	138	10	exito	\N	2026-08-31 15:10:00-06	2011
1121	138	11	exito	\N	2026-08-31 15:11:00-06	2011
1122	138	12	exito	\N	2026-08-31 15:12:00-06	2011
1123	138	13	exito	\N	2026-08-31 15:13:00-06	2011
1124	138	14	exito	\N	2026-08-31 15:14:00-06	2011
1125	138	15	exito	\N	2026-08-31 15:15:00-06	2011
1126	138	16	exito	\N	2026-08-31 15:16:00-06	2011
1127	138	17	exito	\N	2026-08-31 15:17:00-06	2011
1128	138	18	exito	\N	2026-08-31 15:18:00-06	2011
1129	138	19	aceptable	\N	2026-08-31 15:19:00-06	2011
1130	138	20	aceptable	\N	2026-08-31 15:20:00-06	2011
1131	138	21	aceptable	\N	2026-08-31 15:21:00-06	2011
1132	138	22	exito	\N	2026-08-31 15:22:00-06	2011
1133	138	23	exito	\N	2026-08-31 15:23:00-06	2011
1134	138	24	exito	\N	2026-08-31 15:24:00-06	2011
1135	138	25	exito	\N	2026-08-31 15:25:00-06	2011
1136	138	26	exito	\N	2026-08-31 17:20:00-06	2011
1137	138	27	exito	\N	2026-08-31 17:21:00-06	2011
1138	138	28	exito	\N	2026-08-31 17:22:00-06	2011
1139	138	29	falla	\N	2026-08-31 17:23:00-06	2011
1140	138	30	exito	\N	2026-08-31 17:24:00-06	2011
1141	138	31	exito	\N	2026-08-31 17:25:00-06	2011
1142	138	32	exito	\N	2026-08-31 17:26:00-06	2011
1143	138	33	exito	\N	2026-08-31 17:27:00-06	2011
1144	138	34	exito	\N	2026-08-31 17:28:00-06	2011
1145	138	35	exito	\N	2026-08-31 17:29:00-06	2011
1146	138	36	exito	\N	2026-08-31 17:30:00-06	2011
1147	138	37	exito	\N	2026-08-31 17:31:00-06	2011
1148	138	38	exito	\N	2026-08-31 17:32:00-06	2011
1149	139	1	exito	\N	2026-09-07 14:21:00-06	2015
1150	139	2	exito	\N	2026-09-07 14:22:00-06	2015
1151	139	3	exito	\N	2026-09-07 14:23:00-06	2015
1152	139	4	exito	\N	2026-09-07 14:24:00-06	2015
1153	139	5	exito	\N	2026-09-07 14:25:00-06	2015
1154	139	6	exito	\N	2026-09-07 14:26:00-06	2015
1155	139	7	exito	\N	2026-09-07 14:27:00-06	2015
1156	139	8	exito	\N	2026-09-07 15:08:00-06	2015
1157	139	9	exito	\N	2026-09-07 15:09:00-06	2015
1158	139	10	exito	\N	2026-09-07 15:10:00-06	2015
1159	139	11	exito	\N	2026-09-07 15:11:00-06	2015
1160	139	12	exito	\N	2026-09-07 15:12:00-06	2015
1161	139	13	exito	\N	2026-09-07 15:13:00-06	2015
1162	139	14	exito	\N	2026-09-07 15:14:00-06	2015
1163	139	15	exito	\N	2026-09-07 15:15:00-06	2015
1164	139	16	exito	\N	2026-09-07 15:16:00-06	2015
1165	139	17	exito	\N	2026-09-07 15:17:00-06	2015
1166	139	18	exito	\N	2026-09-07 15:18:00-06	2015
1167	139	19	aceptable	\N	2026-09-07 15:19:00-06	2015
1168	139	20	aceptable	\N	2026-09-07 15:20:00-06	2015
1169	139	21	no_aceptable	\N	2026-09-07 15:21:00-06	2015
1170	139	22	exito	\N	2026-09-07 15:22:00-06	2015
1171	139	23	exito	\N	2026-09-07 15:23:00-06	2015
1172	139	24	exito	\N	2026-09-07 15:24:00-06	2015
1173	139	25	exito	\N	2026-09-07 15:25:00-06	2015
1174	139	26	exito	\N	2026-09-07 17:43:00-06	2015
1175	139	27	exito	\N	2026-09-07 17:44:00-06	2015
1176	139	28	exito	\N	2026-09-07 17:45:00-06	2015
1177	139	29	falla	\N	2026-09-07 17:46:00-06	2015
1178	139	30	exito	\N	2026-09-07 17:47:00-06	2015
1179	139	31	exito	\N	2026-09-07 17:48:00-06	2015
1180	139	32	exito	\N	2026-09-07 17:49:00-06	2015
1181	139	33	exito	\N	2026-09-07 17:50:00-06	2015
1182	139	34	exito	\N	2026-09-07 17:51:00-06	2015
1183	139	35	exito	\N	2026-09-07 17:52:00-06	2015
1184	139	36	exito	\N	2026-09-07 17:53:00-06	2015
1185	139	37	exito	\N	2026-09-07 17:54:00-06	2015
1186	139	38	exito	\N	2026-09-07 17:55:00-06	2015
1187	140	1	exito	\N	2026-09-10 14:21:00-06	2008
1188	140	2	exito	\N	2026-09-10 14:22:00-06	2008
1189	140	3	exito	\N	2026-09-10 14:23:00-06	2008
1190	140	4	exito	\N	2026-09-10 14:24:00-06	2008
1191	140	5	exito	\N	2026-09-10 14:25:00-06	2008
1192	140	6	exito	\N	2026-09-10 14:26:00-06	2008
1193	140	7	exito	\N	2026-09-10 14:27:00-06	2008
1194	140	8	exito	\N	2026-09-10 15:08:00-06	2008
1195	140	9	exito	\N	2026-09-10 15:09:00-06	2008
1196	140	10	exito	\N	2026-09-10 15:10:00-06	2008
1197	140	11	exito	\N	2026-09-10 15:11:00-06	2008
1198	140	12	exito	\N	2026-09-10 15:12:00-06	2008
1199	140	13	exito	\N	2026-09-10 15:13:00-06	2008
1200	140	14	exito	\N	2026-09-10 15:14:00-06	2008
1201	140	15	exito	\N	2026-09-10 15:15:00-06	2008
1202	140	16	exito	\N	2026-09-10 15:16:00-06	2008
1203	140	17	exito	\N	2026-09-10 15:17:00-06	2008
1204	140	18	exito	\N	2026-09-10 15:18:00-06	2008
1205	140	19	aceptable	\N	2026-09-10 15:19:00-06	2008
1206	140	20	no_aceptable	\N	2026-09-10 15:20:00-06	2008
1207	140	21	medianamente_aceptable	\N	2026-09-10 15:21:00-06	2008
1208	140	22	exito	\N	2026-09-10 15:22:00-06	2008
1209	140	23	exito	\N	2026-09-10 15:23:00-06	2008
1210	140	24	exito	\N	2026-09-10 15:24:00-06	2008
1211	140	25	exito	\N	2026-09-10 15:25:00-06	2008
1212	140	26	exito	\N	2026-09-10 17:16:00-06	2008
1213	140	27	exito	\N	2026-09-10 17:17:00-06	2008
1214	140	28	exito	\N	2026-09-10 17:18:00-06	2008
1215	140	29	falla	\N	2026-09-10 17:19:00-06	2008
1216	140	30	exito	\N	2026-09-10 17:20:00-06	2008
1217	140	31	exito	\N	2026-09-10 17:21:00-06	2008
1218	140	32	exito	\N	2026-09-10 17:22:00-06	2008
1219	140	33	exito	\N	2026-09-10 17:23:00-06	2008
1220	140	34	exito	\N	2026-09-10 17:24:00-06	2008
1221	140	35	exito	\N	2026-09-10 17:25:00-06	2008
1222	140	36	exito	\N	2026-09-10 17:26:00-06	2008
1223	140	37	exito	\N	2026-09-10 17:27:00-06	2008
1224	140	38	exito	\N	2026-09-10 17:28:00-06	2008
1225	141	1	exito	\N	2026-09-17 14:21:00-06	2002
1226	141	2	exito	\N	2026-09-17 14:22:00-06	2002
1227	141	3	exito	\N	2026-09-17 14:23:00-06	2002
1228	141	4	exito	\N	2026-09-17 14:24:00-06	2002
1229	141	5	exito	\N	2026-09-17 14:25:00-06	2002
1230	141	6	exito	\N	2026-09-17 14:26:00-06	2002
1231	141	7	exito	\N	2026-09-17 14:27:00-06	2002
1232	141	8	exito	\N	2026-09-17 15:08:00-06	2002
1233	141	9	exito	\N	2026-09-17 15:09:00-06	2002
1234	141	10	exito	\N	2026-09-17 15:10:00-06	2002
1235	141	11	exito	\N	2026-09-17 15:11:00-06	2002
1236	141	12	exito	\N	2026-09-17 15:12:00-06	2002
1237	141	13	exito	\N	2026-09-17 15:13:00-06	2002
1238	141	14	exito	\N	2026-09-17 15:14:00-06	2002
1239	141	15	exito	\N	2026-09-17 15:15:00-06	2002
1240	141	16	exito	\N	2026-09-17 15:16:00-06	2002
1241	141	17	exito	\N	2026-09-17 15:17:00-06	2002
1242	141	18	exito	\N	2026-09-17 15:18:00-06	2002
1243	141	19	no_aceptable	\N	2026-09-17 15:19:00-06	2002
1244	141	20	medianamente_aceptable	\N	2026-09-17 15:20:00-06	2002
1245	141	21	medianamente_aceptable	\N	2026-09-17 15:21:00-06	2002
1246	141	22	exito	\N	2026-09-17 15:22:00-06	2002
1247	141	23	exito	\N	2026-09-17 15:23:00-06	2002
1248	141	24	exito	\N	2026-09-17 15:24:00-06	2002
1249	141	25	exito	\N	2026-09-17 15:25:00-06	2002
1250	141	26	exito	\N	2026-09-17 17:39:00-06	2002
1251	141	27	exito	\N	2026-09-17 17:40:00-06	2002
1252	141	28	exito	\N	2026-09-17 17:41:00-06	2002
1253	141	29	falla	\N	2026-09-17 17:42:00-06	2002
1254	141	30	exito	\N	2026-09-17 17:43:00-06	2002
1255	141	31	exito	\N	2026-09-17 17:44:00-06	2002
1256	141	32	exito	\N	2026-09-17 17:45:00-06	2002
1257	141	33	exito	\N	2026-09-17 17:46:00-06	2002
1258	141	34	exito	\N	2026-09-17 17:47:00-06	2002
1259	141	35	exito	\N	2026-09-17 17:48:00-06	2002
1260	141	36	exito	\N	2026-09-17 17:49:00-06	2002
1261	141	37	exito	\N	2026-09-17 17:50:00-06	2002
1262	141	38	exito	\N	2026-09-17 17:51:00-06	2002
1263	143	1	exito	\N	2026-10-01 14:21:00-06	2004
1264	143	2	exito	\N	2026-10-01 14:22:00-06	2004
1265	143	3	exito	\N	2026-10-01 14:23:00-06	2004
1266	143	4	exito	\N	2026-10-01 14:24:00-06	2004
1267	143	5	exito	\N	2026-10-01 14:25:00-06	2004
1268	143	6	exito	\N	2026-10-01 14:26:00-06	2004
1269	143	7	exito	\N	2026-10-01 14:27:00-06	2004
1270	143	8	exito	\N	2026-10-01 15:08:00-06	2004
1271	143	9	exito	\N	2026-10-01 15:09:00-06	2004
1272	143	10	exito	\N	2026-10-01 15:10:00-06	2004
1273	143	11	exito	\N	2026-10-01 15:11:00-06	2004
1274	143	12	exito	\N	2026-10-01 15:12:00-06	2004
1275	143	13	exito	\N	2026-10-01 15:13:00-06	2004
1276	143	14	exito	\N	2026-10-01 15:14:00-06	2004
1277	143	15	exito	\N	2026-10-01 15:15:00-06	2004
1278	143	16	exito	\N	2026-10-01 15:16:00-06	2004
1279	143	17	exito	\N	2026-10-01 15:17:00-06	2004
1280	143	18	exito	\N	2026-10-01 15:18:00-06	2004
1281	143	19	medianamente_aceptable	\N	2026-10-01 15:19:00-06	2004
1282	143	20	aceptable	\N	2026-10-01 15:20:00-06	2004
1283	143	21	aceptable	\N	2026-10-01 15:21:00-06	2004
1284	143	22	exito	\N	2026-10-01 15:22:00-06	2004
1285	143	23	exito	\N	2026-10-01 15:23:00-06	2004
1286	143	24	exito	\N	2026-10-01 15:24:00-06	2004
1287	143	25	exito	\N	2026-10-01 15:25:00-06	2004
1288	143	26	exito	\N	2026-10-01 18:25:00-06	2004
1289	143	27	exito	\N	2026-10-01 18:26:00-06	2004
1290	143	28	exito	\N	2026-10-01 18:27:00-06	2004
1291	143	29	falla	\N	2026-10-01 18:28:00-06	2004
1292	143	30	exito	\N	2026-10-01 18:29:00-06	2004
1293	143	31	exito	\N	2026-10-01 18:30:00-06	2004
1294	143	32	exito	\N	2026-10-01 18:31:00-06	2004
1295	143	33	exito	\N	2026-10-01 18:32:00-06	2004
1296	143	34	exito	\N	2026-10-01 18:33:00-06	2004
1297	143	35	exito	\N	2026-10-01 18:34:00-06	2004
1298	143	36	exito	\N	2026-10-01 18:35:00-06	2004
1299	143	37	exito	\N	2026-10-01 18:36:00-06	2004
1300	143	38	exito	\N	2026-10-01 18:37:00-06	2004
1301	144	1	exito	\N	2026-10-04 14:21:00-06	2008
1302	144	2	exito	\N	2026-10-04 14:22:00-06	2008
1303	144	3	exito	\N	2026-10-04 14:23:00-06	2008
1304	144	4	exito	\N	2026-10-04 14:24:00-06	2008
1305	144	5	exito	\N	2026-10-04 14:25:00-06	2008
1306	144	6	exito	\N	2026-10-04 14:26:00-06	2008
1307	144	7	exito	\N	2026-10-04 14:27:00-06	2008
1308	144	8	exito	\N	2026-10-04 15:08:00-06	2008
1309	144	9	exito	\N	2026-10-04 15:09:00-06	2008
1310	144	10	exito	\N	2026-10-04 15:10:00-06	2008
1311	144	11	exito	\N	2026-10-04 15:11:00-06	2008
1312	144	12	exito	\N	2026-10-04 15:12:00-06	2008
1313	144	13	exito	\N	2026-10-04 15:13:00-06	2008
1314	144	14	exito	\N	2026-10-04 15:14:00-06	2008
1315	144	15	exito	\N	2026-10-04 15:15:00-06	2008
1316	144	16	exito	\N	2026-10-04 15:16:00-06	2008
1317	144	17	exito	\N	2026-10-04 15:17:00-06	2008
1318	144	18	exito	\N	2026-10-04 15:18:00-06	2008
1319	144	19	aceptable	\N	2026-10-04 15:19:00-06	2008
1320	144	20	aceptable	\N	2026-10-04 15:20:00-06	2008
1321	144	21	aceptable	\N	2026-10-04 15:21:00-06	2008
1322	144	22	exito	\N	2026-10-04 15:22:00-06	2008
1323	144	23	exito	\N	2026-10-04 15:23:00-06	2008
1324	144	24	exito	\N	2026-10-04 15:24:00-06	2008
1325	144	25	exito	\N	2026-10-04 15:25:00-06	2008
1326	144	26	exito	\N	2026-10-04 18:48:00-06	2008
1327	144	27	exito	\N	2026-10-04 18:49:00-06	2008
1328	144	28	exito	\N	2026-10-04 18:50:00-06	2008
1329	144	29	falla	\N	2026-10-04 18:51:00-06	2008
1330	144	30	exito	\N	2026-10-04 18:52:00-06	2008
1331	144	31	exito	\N	2026-10-04 18:53:00-06	2008
1332	144	32	exito	\N	2026-10-04 18:54:00-06	2008
1333	144	33	exito	\N	2026-10-04 18:55:00-06	2008
1334	144	34	exito	\N	2026-10-04 18:56:00-06	2008
1335	144	35	exito	\N	2026-10-04 18:57:00-06	2008
1336	144	36	exito	\N	2026-10-04 18:58:00-06	2008
1337	144	37	exito	\N	2026-10-04 18:59:00-06	2008
1338	144	38	exito	\N	2026-10-04 19:00:00-06	2008
\.


--
-- Data for Name: requerimiento_equipo; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.requerimiento_equipo (id_agendamiento, id_equipo, cantidad) FROM stdin;
1	1	1
2	3	1
101	6	1
102	7	1
103	8	1
104	1	1
105	2	2
106	3	1
107	4	2
108	5	1
109	6	2
110	7	2
111	8	1
112	1	1
113	2	2
114	3	1
115	4	2
116	5	2
117	6	1
118	7	2
119	8	2
120	1	1
121	2	2
122	3	2
123	4	2
124	5	1
125	6	2
126	7	1
127	8	1
128	1	1
129	2	1
130	3	2
131	4	1
132	5	2
133	6	1
134	7	2
135	8	2
136	1	1
137	2	1
138	3	2
139	4	1
140	5	2
141	6	2
142	7	1
143	8	2
144	1	2
145	2	1
\.


--
-- Data for Name: requerimiento_instrumento; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.requerimiento_instrumento (id_agendamiento, id_instrumento, cantidad) FROM stdin;
1	1	1
2	3	4
101	3	1
101	6	2
102	4	2
102	7	1
103	5	1
103	8	2
104	6	2
104	9	1
105	7	4
105	1	2
106	8	1
106	2	1
107	9	3
107	3	2
108	1	2
108	4	1
109	2	3
109	5	2
110	3	4
110	6	1
111	4	2
111	7	2
112	5	2
112	8	1
113	6	3
113	9	2
114	7	2
114	1	1
115	8	4
115	2	2
116	9	3
116	3	1
117	1	2
117	4	2
118	2	3
118	5	1
119	3	4
119	6	2
120	4	2
120	7	1
121	5	3
121	8	2
122	6	3
122	9	1
123	7	3
123	1	2
124	8	1
124	2	1
125	9	3
125	3	2
126	1	1
126	4	1
127	2	2
127	5	2
128	3	1
128	6	1
129	4	2
129	7	2
130	5	4
130	8	1
131	6	1
131	9	2
132	7	3
132	1	1
133	8	2
133	2	2
134	9	3
134	3	1
135	1	4
135	4	2
136	2	2
136	5	1
137	3	2
137	6	2
138	4	3
138	7	1
139	5	2
139	8	2
140	6	4
140	9	1
141	7	3
141	1	2
142	8	2
142	2	1
143	9	3
143	3	2
144	1	4
144	4	1
145	2	2
145	5	2
\.


--
-- Data for Name: requerimiento_insumo; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.requerimiento_insumo (id_agendamiento, id_insumo, cantidad) FROM stdin;
1	6	2
101	2	4
101	7	1
102	3	4
102	8	2
103	4	3
103	9	1
104	5	6
104	10	2
105	6	8
105	1	4
106	7	3
106	2	1
107	8	8
107	3	3
108	9	4
108	4	2
109	10	7
109	5	3
110	1	10
110	6	4
111	2	4
111	7	2
112	3	5
112	8	2
113	4	8
113	9	3
114	5	4
114	10	2
115	6	9
115	1	4
116	7	8
116	2	3
117	8	4
117	3	2
118	9	7
118	4	3
119	10	10
119	5	4
120	1	4
120	6	2
121	2	7
121	7	3
122	3	8
122	8	3
123	4	6
123	9	3
124	5	3
124	10	1
125	6	8
125	1	3
126	7	2
126	2	1
127	8	5
127	3	2
128	9	4
128	4	1
129	10	4
129	5	2
130	1	9
130	6	4
131	2	4
131	7	1
132	3	6
132	8	3
133	4	5
133	9	2
134	5	8
134	10	3
135	6	8
135	1	4
136	7	5
136	2	2
137	8	6
137	3	2
138	9	6
138	4	3
139	10	5
139	5	2
140	1	10
140	6	4
141	2	6
141	7	3
142	3	5
142	8	2
143	4	8
143	9	3
144	5	8
144	10	4
145	6	5
145	1	2
\.


--
-- Data for Name: rol_quirurgico; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.rol_quirurgico (id_rol, nombre, tipo_personal) FROM stdin;
1	Cirujano	medico
2	Cirujano ayudante	medico
3	Anestesiólogo	medico
4	Enfermero instrumentista	enfermero
5	Enfermero circulante	enfermero
\.


--
-- Data for Name: servicio_atencion; Type: TABLE DATA; Schema: public; Owner: admin
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
301	42	Aislamiento y control de vía aérea y ventilación	960.00
401	52	Aislamiento y control de vía aérea y ventilación	900.00
302	42	Control cardiocirculatorio	1120.00
402	52	Control cardiocirculatorio	1050.00
303	42	Atención de pacientes politraumatizados	1440.00
403	52	Atención de pacientes politraumatizados	1350.00
304	42	Manejo, control y administración de drogas protocolizadas	720.00
404	52	Manejo, control y administración de drogas protocolizadas	675.00
305	42	Procedimientos de control y observación	560.00
405	52	Procedimientos de control y observación	525.00
306	42	Procedimientos terapéuticos/diagnósticos	880.00
406	52	Procedimientos terapéuticos/diagnósticos	825.00
307	42	Procedimientos diagnósticos	640.00
407	52	Procedimientos diagnósticos	600.00
308	44	Hematología	1200.00
408	54	Hematología	1125.00
309	44	Medicina interna	1280.00
409	54	Medicina interna	1200.00
310	44	Neumología	1200.00
410	54	Neumología	1125.00
311	44	Neurología	1360.00
411	54	Neurología	1275.00
312	44	Oncología	1600.00
412	54	Oncología	1500.00
313	44	Ortopedia	1120.00
413	54	Ortopedia	1050.00
314	44	Pediatría	1280.00
414	54	Pediatría	1200.00
315	44	Unidad de cuidados intermedios	1440.00
415	54	Unidad de cuidados intermedios	1350.00
316	44	Unidad de cuidado crítico de adultos	2000.00
416	54	Unidad de cuidado crítico de adultos	1875.00
317	43	Cirugía General	6800.00
417	53	Cirugía General	6375.00
318	43	Cirugía Cardiovascular	12000.00
418	53	Cirugía Cardiovascular	11250.00
319	43	Cirugía Oncológica	9600.00
419	53	Cirugía Oncológica	9000.00
\.


--
-- Data for Name: tipo_anestesia; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.tipo_anestesia (id_tipo_anestesia, nombre) FROM stdin;
1	General
2	Regional raquídea
3	Regional epidural
4	Local
5	Sedación
\.


--
-- Data for Name: tipo_cirugia; Type: TABLE DATA; Schema: public; Owner: admin
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
11	Reparación de tendones flexores de la mano	319
12	Craneotomía para drenaje de hematoma	322
13	Amigdalectomía	325
14	Herniorrafia umbilical pediátrica	326
15	Rinoplastia reconstructiva	327
16	Lobectomía pulmonar	328
17	Prostatectomía	329
\.


--
-- Data for Name: traslado; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.traslado (id_traslado, fecha_hora, id_medico_indica, id_consulta, id_ingreso, id_unidad_origen, tipo_traslado, id_unidad_destino, id_institucion_destino) FROM stdin;
1	2026-08-11 10:00:00-06	1005	2	\N	11	interno	13	\N
2	2026-08-11 21:30:00-06	1006	\N	4	13	interno	14	\N
3	2026-08-21 08:00:00-06	1005	\N	2	12	interno	22	\N
1009	2026-07-14 13:18:00-06	1048	\N	1009	52	interno	54	\N
1018	2026-04-09 15:51:00-06	1041	\N	1018	42	interno	44	\N
1027	2026-10-16 06:44:00-06	1037	\N	1027	32	interno	34	\N
1036	2026-07-12 09:17:00-06	1031	\N	1036	22	interno	24	\N
1045	2026-04-06 08:10:00-06	1006	\N	1045	12	interno	14	\N
1054	2026-10-12 10:43:00-06	1047	\N	1054	52	interno	54	\N
1072	2026-04-04 04:09:00-06	1036	\N	1072	32	interno	34	\N
1081	2026-10-09 03:02:00-06	1032	\N	1081	22	interno	24	\N
1090	2026-07-05 05:35:00-06	1005	\N	1090	12	interno	14	\N
1099	2026-03-31 20:28:00-06	1048	\N	1099	52	interno	54	\N
1108	2026-10-06 23:01:00-06	1041	\N	1108	42	interno	44	\N
1117	2026-07-03 13:54:00-06	1037	\N	1117	32	interno	34	\N
1135	2026-10-03 15:20:00-06	1006	\N	1135	12	interno	14	\N
1144	2026-06-29 17:53:00-06	1047	\N	1144	52	interno	54	\N
3001	2026-01-20 16:23:00-06	1020	\N	3001	13	interno	14	\N
3002	2026-01-27 16:46:00-06	1021	\N	3002	23	interno	24	\N
3003	2026-02-03 17:09:00-06	1028	\N	3003	33	interno	34	\N
3004	2026-02-06 17:32:00-06	1009	\N	3004	33	interno	34	\N
3005	2026-02-13 17:05:00-06	1023	\N	3005	13	interno	14	\N
3007	2026-02-27 17:51:00-06	1006	\N	3007	13	interno	14	\N
3008	2026-03-02 18:14:00-06	1045	\N	3008	43	interno	44	\N
3011	2026-03-23 18:33:00-06	1045	\N	3011	43	interno	44	\N
3013	2026-04-02 16:49:00-06	1022	\N	3013	33	interno	34	\N
3014	2026-04-09 17:12:00-06	1045	\N	3014	43	interno	44	\N
3015	2026-04-16 16:45:00-06	1035	\N	3015	23	interno	24	\N
3016	2026-04-19 17:08:00-06	1006	\N	3016	13	interno	14	\N
3017	2026-04-26 17:31:00-06	1025	\N	3017	33	interno	34	\N
3019	2026-05-10 18:17:00-06	1007	\N	3019	23	interno	24	\N
3020	2026-05-13 17:50:00-06	1029	\N	3020	13	interno	14	\N
3021	2026-05-20 18:13:00-06	1030	\N	3021	23	interno	24	\N
3022	2026-05-27 18:36:00-06	1050	\N	3022	53	interno	54	\N
3023	2026-06-03 18:59:00-06	1050	\N	3023	53	interno	54	\N
3025	2026-06-13 16:25:00-06	1006	\N	3025	13	interno	14	\N
3026	2026-06-20 16:48:00-06	1020	\N	3026	13	interno	14	\N
3028	2026-06-30 17:34:00-06	1028	\N	3028	33	interno	34	\N
3029	2026-07-07 17:57:00-06	1009	\N	3029	33	interno	34	\N
3031	2026-07-21 17:53:00-06	1040	\N	3031	33	interno	34	\N
3033	2026-07-31 18:39:00-06	1045	\N	3033	43	interno	44	\N
3034	2026-08-07 19:02:00-06	1026	\N	3034	13	interno	14	\N
3035	2026-08-14 16:05:00-06	1027	\N	3035	23	interno	24	\N
3037	2026-08-24 16:51:00-06	1009	\N	3037	33	interno	34	\N
3038	2026-08-31 17:14:00-06	1022	\N	3038	33	interno	34	\N
3039	2026-09-07 17:37:00-06	1045	\N	3039	43	interno	44	\N
3040	2026-09-10 17:10:00-06	1035	\N	3040	23	interno	24	\N
3041	2026-09-17 17:33:00-06	1006	\N	3041	13	interno	14	\N
3043	2026-10-01 18:19:00-06	1006	\N	3043	13	interno	14	\N
3044	2026-10-04 18:42:00-06	1007	\N	3044	23	interno	24	\N
\.


--
-- Data for Name: turno_emergencia; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.turno_emergencia (id_turno, id_unidad, fecha, jornada) FROM stdin;
1	12	2026-08-09	nocturno
2	12	2026-08-20	diurno
1542	22	2026-06-16	diurno
1045	32	2026-01-17	nocturno
1406	42	2026-05-05	diurno
1937	42	2026-10-11	nocturno
1778	52	2026-08-24	diurno
1160	12	2026-02-22	diurno
1855	32	2026-09-17	nocturno
1233	22	2026-03-15	nocturno
1910	12	2026-10-05	diurno
1800	12	2026-09-02	diurno
1676	42	2026-07-25	diurno
1332	22	2026-04-14	diurno
1653	22	2026-07-19	nocturno
1508	52	2026-06-04	diurno
1164	32	2026-02-22	diurno
1851	12	2026-09-17	nocturno
1914	32	2026-10-05	diurno
1876	42	2026-09-23	diurno
1804	32	2026-09-02	diurno
1638	52	2026-07-13	diurno
1041	12	2026-01-17	nocturno
1926	42	2026-10-08	diurno
1703	22	2026-08-03	nocturno
1670	12	2026-07-25	diurno
1469	52	2026-05-23	nocturno
1712	22	2026-08-06	diurno
1288	52	2026-03-30	diurno
1857	42	2026-09-17	nocturno
1870	12	2026-09-23	diurno
1323	22	2026-04-11	nocturno
1119	52	2026-02-07	nocturno
1047	42	2026-01-17	nocturno
1889	52	2026-09-26	nocturno
1404	32	2026-05-05	diurno
1935	32	2026-10-11	nocturno
1920	12	2026-10-08	diurno
1733	22	2026-08-12	nocturno
1924	32	2026-10-08	diurno
1559	52	2026-06-19	nocturno
1519	52	2026-06-07	nocturno
1563	22	2026-06-22	nocturno
1479	52	2026-05-26	nocturno
1400	12	2026-05-05	diurno
1038	52	2026-01-14	diurno
1931	12	2026-10-11	nocturno
1819	52	2026-09-05	nocturno
1832	22	2026-09-11	diurno
1166	42	2026-02-22	diurno
1942	22	2026-10-14	diurno
1916	42	2026-10-05	diurno
1874	32	2026-09-23	diurno
1806	42	2026-09-02	diurno
1382	22	2026-04-29	diurno
1398	52	2026-05-02	diurno
1674	32	2026-07-25	diurno
1352	22	2026-04-20	diurno
1453	22	2026-05-20	nocturno
1307	42	2026-04-05	nocturno
1216	42	2026-03-09	diurno
1197	42	2026-03-03	nocturno
1727	42	2026-08-09	nocturno
1274	32	2026-03-27	diurno
1447	42	2026-05-17	nocturno
1070	12	2026-01-26	diurno
1757	42	2026-08-18	nocturno
1827	42	2026-09-08	nocturno
1488	52	2026-05-29	diurno
1220	12	2026-03-12	diurno
1897	42	2026-09-29	nocturno
1583	22	2026-06-28	nocturno
1185	32	2026-02-28	nocturno
1181	12	2026-02-28	nocturno
1522	22	2026-06-10	diurno
1312	22	2026-04-08	diurno
1428	52	2026-05-11	diurno
1224	32	2026-03-12	diurno
1029	52	2026-01-11	nocturno
1299	52	2026-04-02	nocturno
1266	42	2026-03-24	diurno
1074	32	2026-01-26	diurno
1377	42	2026-04-26	nocturno
1493	22	2026-06-01	nocturno
1270	12	2026-03-27	diurno
1895	32	2026-09-29	nocturno
1003	22	2026-01-05	nocturno
1538	52	2026-06-13	diurno
1187	42	2026-02-28	nocturno
1755	32	2026-08-18	nocturno
1348	52	2026-04-17	diurno
1843	22	2026-09-14	nocturno
1062	22	2026-01-23	diurno
1908	52	2026-10-02	diurno
1825	32	2026-09-08	nocturno
1433	22	2026-05-14	nocturno
1445	32	2026-05-17	nocturno
1260	12	2026-03-24	diurno
1153	22	2026-02-19	nocturno
1371	12	2026-04-26	nocturno
1305	32	2026-04-05	nocturno
1214	32	2026-03-09	diurno
1195	32	2026-03-03	nocturno
1725	32	2026-08-09	nocturno
1276	42	2026-03-27	diurno
1301	12	2026-04-05	nocturno
1210	12	2026-03-09	diurno
1191	12	2026-03-03	nocturno
1441	12	2026-05-17	nocturno
1699	52	2026-07-31	nocturno
1264	32	2026-03-24	diurno
1076	42	2026-01-26	diurno
1869	52	2026-09-20	nocturno
1375	32	2026-04-26	nocturno
1751	12	2026-08-18	nocturno
1821	12	2026-09-08	nocturno
1226	42	2026-03-12	diurno
1052	22	2026-01-20	diurno
1891	12	2026-09-29	nocturno
1683	22	2026-07-28	nocturno
1599	52	2026-07-01	nocturno
1564	32	2026-06-22	diurno
1923	22	2026-10-08	nocturno
1730	12	2026-08-12	diurno
1748	52	2026-08-15	diurno
1711	12	2026-08-06	nocturno
1656	42	2026-07-19	diurno
1355	32	2026-04-20	nocturno
1454	32	2026-05-20	diurno
1700	12	2026-08-03	diurno
1673	22	2026-07-25	nocturno
1249	52	2026-03-18	nocturno
1337	42	2026-04-14	nocturno
1873	22	2026-09-23	nocturno
1385	32	2026-04-29	nocturno
1320	12	2026-04-11	diurno
1835	32	2026-09-11	nocturno
1945	32	2026-10-14	nocturno
1618	52	2026-07-07	diurno
1381	12	2026-04-29	nocturno
1324	32	2026-04-11	diurno
1208	52	2026-03-06	diurno
1831	12	2026-09-11	nocturno
1941	12	2026-10-14	nocturno
1236	42	2026-03-15	diurno
1715	32	2026-08-06	nocturno
1351	12	2026-04-20	nocturno
1450	12	2026-05-20	diurno
1704	32	2026-08-03	diurno
1734	32	2026-08-12	diurno
1648	52	2026-07-16	diurno
1403	22	2026-05-05	nocturno
1932	22	2026-10-11	diurno
1547	42	2026-06-16	nocturno
1560	12	2026-06-22	diurno
1913	22	2026-10-05	nocturno
1803	22	2026-09-02	nocturno
1387	42	2026-04-29	nocturno
1837	42	2026-09-11	nocturno
1163	22	2026-02-22	nocturno
1947	42	2026-10-14	nocturno
1230	12	2026-03-15	diurno
1654	32	2026-07-19	diurno
1357	42	2026-04-20	nocturno
1098	52	2026-02-01	diurno
1456	42	2026-05-20	diurno
1258	52	2026-03-21	diurno
1335	32	2026-04-14	nocturno
1768	52	2026-08-21	diurno
1541	12	2026-06-16	nocturno
1566	42	2026-06-22	diurno
1545	32	2026-06-16	nocturno
1042	22	2026-01-17	diurno
1736	42	2026-08-12	diurno
1149	52	2026-02-16	nocturno
1717	42	2026-08-06	nocturno
1650	12	2026-07-19	diurno
1706	42	2026-08-03	diurno
1331	12	2026-04-14	nocturno
1326	42	2026-04-11	diurno
1799	52	2026-08-30	nocturno
1852	22	2026-09-17	diurno
1234	32	2026-03-15	diurno
1372	22	2026-04-26	diurno
1263	22	2026-03-24	nocturno
1150	12	2026-02-19	diurno
1496	42	2026-06-01	diurno
1139	52	2026-02-13	nocturno
1000	12	2026-01-05	diurno
1684	32	2026-07-28	diurno
1055	32	2026-01-20	nocturno
1430	12	2026-05-14	diurno
1527	42	2026-06-10	nocturno
1317	42	2026-04-08	nocturno
1840	12	2026-09-14	diurno
1368	52	2026-04-23	diurno
1061	12	2026-01-23	nocturno
1822	22	2026-09-08	diurno
1578	52	2026-06-25	diurno
1051	12	2026-01-20	nocturno
1019	52	2026-01-08	nocturno
1434	32	2026-05-14	diurno
1752	22	2026-08-18	diurno
1844	32	2026-09-14	diurno
1608	52	2026-07-04	diurno
1065	32	2026-01-23	nocturno
1892	22	2026-09-29	diurno
1586	42	2026-06-28	diurno
1004	32	2026-01-05	diurno
1680	12	2026-07-28	diurno
1213	22	2026-03-09	nocturno
1192	22	2026-03-03	diurno
1722	22	2026-08-09	diurno
1302	22	2026-04-05	diurno
1089	52	2026-01-29	nocturno
1109	52	2026-02-04	nocturno
1442	22	2026-05-17	diurno
1154	32	2026-02-19	diurno
1223	22	2026-03-12	nocturno
1057	42	2026-01-20	nocturno
1525	32	2026-06-10	nocturno
1315	32	2026-04-08	nocturno
1129	52	2026-02-10	nocturno
1629	52	2026-07-10	nocturno
1580	12	2026-06-28	diurno
1686	42	2026-07-28	diurno
1494	32	2026-06-01	diurno
1789	52	2026-08-27	nocturno
1668	52	2026-07-22	diurno
1073	22	2026-01-26	nocturno
1156	42	2026-02-19	diurno
1490	12	2026-06-01	diurno
1273	22	2026-03-27	nocturno
1418	52	2026-05-08	diurno
1182	22	2026-02-28	diurno
1584	32	2026-06-28	diurno
1179	52	2026-02-25	nocturno
1006	42	2026-01-05	diurno
1436	42	2026-05-14	diurno
1521	12	2026-06-10	nocturno
1311	12	2026-04-08	nocturno
1846	42	2026-09-14	diurno
1067	42	2026-01-23	nocturno
1137	42	2026-02-13	nocturno
1625	32	2026-07-10	nocturno
1171	12	2026-02-25	nocturno
1022	22	2026-01-11	diurno
1423	22	2026-05-11	nocturno
1366	42	2026-04-23	diurno
1529	52	2026-06-10	nocturno
1319	52	2026-04-08	nocturno
1125	32	2026-02-10	nocturno
1664	32	2026-07-22	diurno
1292	22	2026-04-02	diurno
1498	52	2026-06-01	diurno
1785	32	2026-08-27	nocturno
1410	12	2026-05-08	diurno
1781	12	2026-08-27	nocturno
1414	32	2026-05-08	diurno
1087	42	2026-01-29	nocturno
1660	12	2026-07-22	diurno
1107	42	2026-02-04	nocturno
1576	42	2026-06-25	diurno
1483	22	2026-05-29	nocturno
1017	42	2026-01-08	nocturno
1606	42	2026-07-04	diurno
1121	12	2026-02-10	nocturno
1621	12	2026-07-10	nocturno
1588	52	2026-06-28	diurno
1175	32	2026-02-25	nocturno
1787	42	2026-08-27	nocturno
1081	12	2026-01-29	nocturno
1666	42	2026-07-22	diurno
1862	22	2026-09-20	diurno
1101	12	2026-02-04	nocturno
1692	22	2026-07-31	diurno
1570	12	2026-06-25	diurno
1059	52	2026-01-20	nocturno
1011	12	2026-01-08	nocturno
1600	12	2026-07-04	diurno
1364	32	2026-04-23	diurno
1127	42	2026-02-10	nocturno
1135	32	2026-02-13	nocturno
1688	52	2026-07-28	diurno
1627	42	2026-07-10	nocturno
1533	22	2026-06-13	nocturno
1131	12	2026-02-13	nocturno
1177	42	2026-02-25	nocturno
1008	52	2026-01-05	diurno
1438	52	2026-05-14	diurno
1903	22	2026-10-02	nocturno
1574	32	2026-06-25	diurno
1015	32	2026-01-08	nocturno
1848	52	2026-09-14	diurno
1604	32	2026-07-04	diurno
1360	12	2026-04-23	diurno
1069	52	2026-01-23	nocturno
1343	22	2026-04-17	nocturno
1105	32	2026-02-04	nocturno
1158	52	2026-02-19	diurno
1416	42	2026-05-08	diurno
1085	32	2026-01-29	nocturno
1254	32	2026-03-21	diurno
1746	42	2026-08-15	diurno
1658	52	2026-07-19	diurno
1094	32	2026-02-01	diurno
1339	52	2026-04-14	nocturno
1247	42	2026-03-18	nocturno
1633	22	2026-07-13	nocturno
1791	12	2026-08-30	nocturno
1503	22	2026-06-04	nocturno
1597	42	2026-07-01	nocturno
1764	32	2026-08-21	diurno
1141	12	2026-02-16	nocturno
1646	42	2026-07-16	diurno
1760	12	2026-08-21	diurno
1145	32	2026-02-16	nocturno
1773	22	2026-08-24	nocturno
1549	52	2026-06-16	nocturno
1206	42	2026-03-06	diurno
1616	42	2026-07-07	diurno
1238	52	2026-03-15	diurno
1795	32	2026-08-30	nocturno
1250	12	2026-03-21	diurno
1090	12	2026-02-01	diurno
1640	12	2026-07-16	diurno
1512	22	2026-06-07	diurno
1766	42	2026-08-21	diurno
1552	22	2026-06-19	diurno
1812	22	2026-09-05	diurno
1472	22	2026-05-26	diurno
1033	22	2026-01-14	nocturno
1595	32	2026-07-01	nocturno
1568	52	2026-06-22	diurno
1393	22	2026-05-02	nocturno
1200	12	2026-03-06	diurno
1610	12	2026-07-07	diurno
1389	52	2026-04-29	nocturno
1949	52	2026-10-14	nocturno
1839	52	2026-09-11	nocturno
1458	52	2026-05-20	diurno
1256	42	2026-03-21	diurno
1744	32	2026-08-15	diurno
1359	52	2026-04-20	nocturno
1096	42	2026-02-01	diurno
1245	32	2026-03-18	nocturno
1740	12	2026-08-15	diurno
1719	52	2026-08-06	nocturno
1283	22	2026-03-30	nocturno
1462	22	2026-05-23	diurno
1708	52	2026-08-03	diurno
1241	12	2026-03-18	nocturno
1328	52	2026-04-11	diurno
1204	32	2026-03-06	diurno
1112	22	2026-02-07	diurno
1614	32	2026-07-07	diurno
1797	42	2026-08-30	nocturno
1882	22	2026-09-26	diurno
1591	12	2026-07-01	nocturno
1644	32	2026-07-16	diurno
1738	52	2026-08-12	diurno
1147	42	2026-02-16	nocturno
1603	22	2026-07-04	nocturno
1759	52	2026-08-18	nocturno
1344	32	2026-04-17	diurno
1904	32	2026-10-02	diurno
1829	52	2026-09-08	nocturno
1573	22	2026-06-25	nocturno
1486	42	2026-05-29	diurno
1012	22	2026-01-08	diurno
1899	52	2026-09-29	nocturno
1534	32	2026-06-13	diurno
1309	52	2026-04-05	nocturno
1082	22	2026-01-29	diurno
1729	52	2026-08-09	nocturno
1218	52	2026-03-09	diurno
1199	52	2026-03-03	nocturno
1691	12	2026-07-31	nocturno
1449	52	2026-05-17	nocturno
1861	12	2026-09-20	nocturno
1102	22	2026-02-04	diurno
1695	32	2026-07-31	nocturno
1297	42	2026-04-02	nocturno
1268	52	2026-03-24	diurno
1865	32	2026-09-20	nocturno
1379	52	2026-04-26	nocturno
1530	12	2026-06-13	diurno
1132	22	2026-02-13	diurno
1363	22	2026-04-23	nocturno
1340	12	2026-04-17	diurno
1027	42	2026-01-11	nocturno
1900	12	2026-10-02	diurno
1426	42	2026-05-11	diurno
1291	12	2026-04-02	nocturno
1413	22	2026-05-08	nocturno
1278	52	2026-03-27	diurno
1172	22	2026-02-25	diurno
1536	42	2026-06-13	diurno
1189	52	2026-02-28	nocturno
1346	42	2026-04-17	diurno
1021	12	2026-01-11	nocturno
1906	42	2026-10-02	diurno
1484	32	2026-05-29	diurno
1420	12	2026-05-11	diurno
1122	22	2026-02-10	diurno
1025	32	2026-01-11	nocturno
1480	12	2026-05-29	diurno
1424	32	2026-05-11	diurno
1228	52	2026-03-12	diurno
1622	22	2026-07-10	diurno
1782	22	2026-08-27	diurno
1697	42	2026-07-31	nocturno
1295	32	2026-04-02	nocturno
1078	52	2026-01-26	diurno
1663	22	2026-07-22	nocturno
1867	42	2026-09-20	nocturno
1390	12	2026-05-02	diurno
1203	22	2026-03-06	nocturno
1115	32	2026-02-07	nocturno
1613	22	2026-07-07	nocturno
1465	32	2026-05-23	nocturno
1284	32	2026-03-30	diurno
1643	22	2026-07-16	nocturno
1511	12	2026-06-07	nocturno
1551	12	2026-06-19	nocturno
1939	52	2026-10-11	nocturno
1811	12	2026-09-05	nocturno
1776	42	2026-08-24	diurno
1885	32	2026-09-26	nocturno
1471	12	2026-05-26	nocturno
1408	52	2026-05-05	diurno
1030	12	2026-01-14	diurno
1592	22	2026-07-01	diurno
1815	32	2026-09-05	nocturno
1881	12	2026-09-26	nocturno
1475	32	2026-05-26	nocturno
1034	32	2026-01-14	diurno
1515	32	2026-06-07	nocturno
1928	52	2026-10-08	diurno
1555	32	2026-06-19	nocturno
1461	12	2026-05-23	nocturno
1678	52	2026-07-25	diurno
1242	22	2026-03-18	diurno
1743	22	2026-08-15	nocturno
1280	12	2026-03-30	diurno
1506	42	2026-06-04	diurno
1636	42	2026-07-13	diurno
1394	32	2026-05-02	diurno
1111	12	2026-02-07	nocturno
1878	52	2026-09-23	diurno
1049	52	2026-01-17	nocturno
1774	32	2026-08-24	diurno
1887	42	2026-09-26	nocturno
1142	22	2026-02-16	diurno
1467	42	2026-05-23	nocturno
1286	42	2026-03-30	diurno
1859	52	2026-09-17	nocturno
1792	22	2026-08-30	diurno
1500	12	2026-06-04	diurno
1630	12	2026-07-13	diurno
1117	42	2026-02-07	nocturno
1504	32	2026-06-04	diurno
1168	52	2026-02-22	diurno
1634	32	2026-07-13	diurno
1396	42	2026-05-02	diurno
1918	52	2026-10-05	diurno
1808	52	2026-09-02	diurno
1253	22	2026-03-21	nocturno
1093	22	2026-02-01	nocturno
1517	42	2026-06-07	nocturno
1763	22	2026-08-21	nocturno
1557	42	2026-06-19	nocturno
1817	42	2026-09-05	nocturno
1770	12	2026-08-24	diurno
1477	42	2026-05-26	nocturno
1036	42	2026-01-14	diurno
1526	42	2026-06-10	diurno
1316	42	2026-04-08	diurno
1841	12	2026-09-14	nocturno
1369	52	2026-04-23	nocturno
1060	12	2026-01-23	diurno
1054	32	2026-01-20	diurno
1431	12	2026-05-14	nocturno
1001	12	2026-01-05	nocturno
1685	32	2026-07-28	nocturno
1138	52	2026-02-13	diurno
1497	42	2026-06-01	nocturno
1262	22	2026-03-24	diurno
1151	12	2026-02-19	nocturno
1373	22	2026-04-26	nocturno
1443	22	2026-05-17	nocturno
1155	32	2026-02-19	nocturno
1108	52	2026-02-04	diurno
1303	22	2026-04-05	nocturno
1088	52	2026-01-29	diurno
1212	22	2026-03-09	diurno
1193	22	2026-03-03	nocturno
1723	22	2026-08-09	nocturno
1893	22	2026-09-29	nocturno
1587	42	2026-06-28	nocturno
1005	32	2026-01-05	nocturno
1681	12	2026-07-28	nocturno
1753	22	2026-08-18	nocturno
1845	32	2026-09-14	nocturno
1609	52	2026-07-04	nocturno
1064	32	2026-01-23	diurno
1823	22	2026-09-08	nocturno
1579	52	2026-06-25	nocturno
1050	12	2026-01-20	diurno
1018	52	2026-01-08	diurno
1435	32	2026-05-14	nocturno
1072	22	2026-01-26	diurno
1669	52	2026-07-22	nocturno
1788	52	2026-08-27	diurno
1495	32	2026-06-01	nocturno
1628	52	2026-07-10	diurno
1581	12	2026-06-28	nocturno
1687	42	2026-07-28	nocturno
1524	32	2026-06-10	diurno
1314	32	2026-04-08	diurno
1128	52	2026-02-10	diurno
1222	22	2026-03-12	diurno
1056	42	2026-01-20	diurno
1520	12	2026-06-10	diurno
1310	12	2026-04-08	diurno
1847	42	2026-09-14	nocturno
1066	42	2026-01-23	diurno
1437	42	2026-05-14	nocturno
1585	32	2026-06-28	nocturno
1178	52	2026-02-25	diurno
1007	42	2026-01-05	nocturno
1183	22	2026-02-28	nocturno
1419	52	2026-05-08	nocturno
1491	12	2026-06-01	nocturno
1272	22	2026-03-27	diurno
1157	42	2026-02-19	nocturno
1834	32	2026-09-11	diurno
1944	32	2026-10-14	diurno
1872	22	2026-09-23	diurno
1384	32	2026-04-29	diurno
1321	12	2026-04-11	nocturno
1701	12	2026-08-03	nocturno
1672	22	2026-07-25	diurno
1248	52	2026-03-18	diurno
1336	42	2026-04-14	diurno
1749	52	2026-08-15	nocturno
1710	12	2026-08-06	diurno
1657	42	2026-07-19	nocturno
1354	32	2026-04-20	diurno
1455	32	2026-05-20	nocturno
1922	22	2026-10-08	diurno
1731	12	2026-08-12	nocturno
1598	52	2026-07-01	diurno
1565	32	2026-06-22	nocturno
1546	42	2026-06-16	diurno
1561	12	2026-06-22	nocturno
1402	22	2026-05-05	diurno
1933	22	2026-10-11	nocturno
1735	32	2026-08-12	nocturno
1649	52	2026-07-16	nocturno
1705	32	2026-08-03	nocturno
1714	32	2026-08-06	diurno
1350	12	2026-04-20	diurno
1451	12	2026-05-20	nocturno
1830	12	2026-09-11	diurno
1940	12	2026-10-14	diurno
1237	42	2026-03-15	nocturno
1619	52	2026-07-07	nocturno
1380	12	2026-04-29	diurno
1325	32	2026-04-11	nocturno
1209	52	2026-03-06	nocturno
1540	12	2026-06-16	diurno
1567	42	2026-06-22	nocturno
1769	52	2026-08-21	nocturno
1334	32	2026-04-14	diurno
1655	32	2026-07-19	nocturno
1356	42	2026-04-20	diurno
1099	52	2026-02-01	nocturno
1457	42	2026-05-20	nocturno
1259	52	2026-03-21	nocturno
1836	42	2026-09-11	diurno
1162	22	2026-02-22	diurno
1946	42	2026-10-14	diurno
1231	12	2026-03-15	nocturno
1912	22	2026-10-05	diurno
1802	22	2026-09-02	diurno
1386	42	2026-04-29	diurno
1798	52	2026-08-30	diurno
1853	22	2026-09-17	nocturno
1235	32	2026-03-15	nocturno
1327	42	2026-04-11	nocturno
1707	42	2026-08-03	nocturno
1330	12	2026-04-14	diurno
1716	42	2026-08-06	diurno
1651	12	2026-07-19	nocturno
1737	42	2026-08-12	nocturno
1148	52	2026-02-16	diurno
1544	32	2026-06-16	diurno
1043	22	2026-01-17	nocturno
1184	32	2026-02-28	diurno
1896	42	2026-09-29	diurno
1582	22	2026-06-28	diurno
1826	42	2026-09-08	diurno
1489	52	2026-05-29	nocturno
1221	12	2026-03-12	nocturno
1756	42	2026-08-18	diurno
1446	42	2026-05-17	diurno
1071	12	2026-01-26	nocturno
1217	42	2026-03-09	nocturno
1196	42	2026-03-03	diurno
1726	42	2026-08-09	diurno
1275	32	2026-03-27	nocturno
1306	42	2026-04-05	diurno
1492	22	2026-06-01	diurno
1271	12	2026-03-27	nocturno
1376	42	2026-04-26	diurno
1298	52	2026-04-02	diurno
1267	42	2026-03-24	nocturno
1075	32	2026-01-26	nocturno
1429	52	2026-05-11	nocturno
1225	32	2026-03-12	nocturno
1028	52	2026-01-11	diurno
1523	22	2026-06-10	nocturno
1313	22	2026-04-08	nocturno
1180	12	2026-02-28	diurno
1215	32	2026-03-09	nocturno
1194	32	2026-03-03	diurno
1724	32	2026-08-09	diurno
1277	42	2026-03-27	nocturno
1304	32	2026-04-05	diurno
1370	12	2026-04-26	diurno
1444	32	2026-05-17	diurno
1261	12	2026-03-24	nocturno
1152	22	2026-02-19	diurno
1909	52	2026-10-02	nocturno
1824	32	2026-09-08	diurno
1432	22	2026-05-14	diurno
1754	32	2026-08-18	diurno
1349	52	2026-04-17	nocturno
1842	22	2026-09-14	diurno
1063	22	2026-01-23	nocturno
1539	52	2026-06-13	nocturno
1186	42	2026-02-28	diurno
1894	32	2026-09-29	diurno
1002	22	2026-01-05	diurno
1890	12	2026-09-29	diurno
1682	22	2026-07-28	diurno
1820	12	2026-09-08	diurno
1227	42	2026-03-12	nocturno
1053	22	2026-01-20	nocturno
1750	12	2026-08-18	diurno
1868	52	2026-09-20	diurno
1374	32	2026-04-26	diurno
1440	12	2026-05-17	diurno
1698	52	2026-07-31	diurno
1265	32	2026-03-24	nocturno
1077	42	2026-01-26	nocturno
1211	12	2026-03-09	nocturno
1190	12	2026-03-03	diurno
1720	12	2026-08-09	diurno
1300	12	2026-04-05	diurno
1911	12	2026-10-05	nocturno
1801	12	2026-09-02	nocturno
1161	12	2026-02-22	nocturno
1854	32	2026-09-17	diurno
1232	22	2026-03-15	diurno
1407	42	2026-05-05	nocturno
1936	42	2026-10-11	diurno
1779	52	2026-08-24	nocturno
1543	22	2026-06-16	nocturno
1044	32	2026-01-17	diurno
1927	42	2026-10-08	nocturno
1040	12	2026-01-17	diurno
1915	32	2026-10-05	nocturno
1877	42	2026-09-23	nocturno
1805	32	2026-09-02	nocturno
1639	52	2026-07-13	nocturno
1509	52	2026-06-04	nocturno
1165	32	2026-02-22	nocturno
1850	12	2026-09-17	diurno
1652	22	2026-07-19	diurno
1677	42	2026-07-25	nocturno
1333	22	2026-04-14	nocturno
1921	12	2026-10-08	nocturno
1732	22	2026-08-12	diurno
1888	52	2026-09-26	diurno
1405	32	2026-05-05	nocturno
1934	32	2026-10-11	diurno
1046	42	2026-01-17	diurno
1871	12	2026-09-23	nocturno
1322	22	2026-04-11	diurno
1118	52	2026-02-07	diurno
1856	42	2026-09-17	diurno
1713	22	2026-08-06	nocturno
1289	52	2026-03-30	nocturno
1702	22	2026-08-03	diurno
1671	12	2026-07-25	nocturno
1468	52	2026-05-23	diurno
1353	22	2026-04-20	nocturno
1452	22	2026-05-20	diurno
1675	32	2026-07-25	nocturno
1917	42	2026-10-05	nocturno
1875	32	2026-09-23	nocturno
1807	42	2026-09-02	nocturno
1383	22	2026-04-29	nocturno
1399	52	2026-05-02	nocturno
1833	22	2026-09-11	nocturno
1167	42	2026-02-22	nocturno
1943	22	2026-10-14	nocturno
1478	52	2026-05-26	diurno
1401	12	2026-05-05	nocturno
1039	52	2026-01-14	nocturno
1930	12	2026-10-11	diurno
1818	52	2026-09-05	diurno
1562	22	2026-06-22	diurno
1925	32	2026-10-08	nocturno
1558	52	2026-06-19	diurno
1518	52	2026-06-07	diurno
1938	52	2026-10-11	diurno
1810	12	2026-09-05	diurno
1777	42	2026-08-24	nocturno
1884	32	2026-09-26	diurno
1470	12	2026-05-26	diurno
1409	52	2026-05-05	nocturno
1031	12	2026-01-14	nocturno
1642	22	2026-07-16	diurno
1510	12	2026-06-07	diurno
1550	12	2026-06-19	diurno
1285	32	2026-03-30	nocturno
1464	32	2026-05-23	diurno
1391	12	2026-05-02	nocturno
1202	22	2026-03-06	diurno
1114	32	2026-02-07	diurno
1612	22	2026-07-07	diurno
1637	42	2026-07-13	nocturno
1395	32	2026-05-02	nocturno
1110	12	2026-02-07	diurno
1879	52	2026-09-23	nocturno
1507	42	2026-06-04	nocturno
1742	22	2026-08-15	diurno
1281	12	2026-03-30	nocturno
1460	12	2026-05-23	diurno
1679	52	2026-07-25	nocturno
1243	22	2026-03-18	nocturno
1514	32	2026-06-07	diurno
1929	52	2026-10-08	nocturno
1554	32	2026-06-19	diurno
1814	32	2026-09-05	diurno
1880	12	2026-09-26	diurno
1474	32	2026-05-26	diurno
1035	32	2026-01-14	nocturno
1593	22	2026-07-01	nocturno
1631	12	2026-07-13	nocturno
1116	42	2026-02-07	diurno
1858	52	2026-09-17	diurno
1793	22	2026-08-30	nocturno
1501	12	2026-06-04	nocturno
1287	42	2026-03-30	nocturno
1466	42	2026-05-23	diurno
1143	22	2026-02-16	nocturno
1775	32	2026-08-24	nocturno
1886	42	2026-09-26	diurno
1048	52	2026-01-17	diurno
1816	42	2026-09-05	diurno
1771	12	2026-08-24	nocturno
1476	42	2026-05-26	diurno
1037	42	2026-01-14	nocturno
1516	42	2026-06-07	diurno
1762	22	2026-08-21	diurno
1556	42	2026-06-19	diurno
1252	22	2026-03-21	diurno
1092	22	2026-02-01	diurno
1635	32	2026-07-13	nocturno
1397	42	2026-05-02	nocturno
1919	52	2026-10-05	nocturno
1809	52	2026-09-02	nocturno
1505	32	2026-06-04	nocturno
1169	52	2026-02-22	nocturno
1860	12	2026-09-20	diurno
1103	22	2026-02-04	nocturno
1690	12	2026-07-31	diurno
1448	52	2026-05-17	diurno
1728	52	2026-08-09	diurno
1219	52	2026-03-09	nocturno
1198	52	2026-03-03	diurno
1308	52	2026-04-05	diurno
1083	22	2026-01-29	nocturno
1535	32	2026-06-13	nocturno
1898	52	2026-09-29	diurno
1905	32	2026-10-02	nocturno
1828	52	2026-09-08	diurno
1572	22	2026-06-25	diurno
1487	42	2026-05-29	nocturno
1013	22	2026-01-08	nocturno
1602	22	2026-07-04	diurno
1758	52	2026-08-18	diurno
1345	32	2026-04-17	nocturno
1026	42	2026-01-11	diurno
1901	12	2026-10-02	nocturno
1427	42	2026-05-11	nocturno
1362	22	2026-04-23	diurno
1341	12	2026-04-17	nocturno
1531	12	2026-06-13	nocturno
1133	22	2026-02-13	nocturno
1864	32	2026-09-20	diurno
1378	52	2026-04-26	diurno
1694	32	2026-07-31	diurno
1296	42	2026-04-02	diurno
1269	52	2026-03-24	nocturno
1020	12	2026-01-11	diurno
1907	42	2026-10-02	nocturno
1485	32	2026-05-29	nocturno
1421	12	2026-05-11	nocturno
1347	42	2026-04-17	nocturno
1537	42	2026-06-13	nocturno
1188	52	2026-02-28	diurno
1173	22	2026-02-25	nocturno
1279	52	2026-03-27	nocturno
1412	22	2026-05-08	diurno
1290	12	2026-04-02	diurno
1662	22	2026-07-22	diurno
1866	42	2026-09-20	diurno
1696	42	2026-07-31	diurno
1294	32	2026-04-02	diurno
1079	52	2026-01-26	nocturno
1783	22	2026-08-27	nocturno
1623	22	2026-07-10	nocturno
1024	32	2026-01-11	diurno
1481	12	2026-05-29	nocturno
1425	32	2026-05-11	nocturno
1229	52	2026-03-12	nocturno
1123	22	2026-02-10	nocturno
1765	32	2026-08-21	nocturno
1140	12	2026-02-16	diurno
1596	42	2026-07-01	diurno
1790	12	2026-08-30	diurno
1502	22	2026-06-04	diurno
1632	22	2026-07-13	diurno
1338	52	2026-04-14	diurno
1246	42	2026-03-18	diurno
1255	32	2026-03-21	nocturno
1747	42	2026-08-15	nocturno
1659	52	2026-07-19	nocturno
1095	32	2026-02-01	nocturno
1251	12	2026-03-21	nocturno
1091	12	2026-02-01	nocturno
1239	52	2026-03-15	nocturno
1794	32	2026-08-30	diurno
1207	42	2026-03-06	nocturno
1617	42	2026-07-07	nocturno
1548	52	2026-06-16	diurno
1772	22	2026-08-24	diurno
1647	42	2026-07-16	nocturno
1761	12	2026-08-21	nocturno
1144	32	2026-02-16	diurno
1244	32	2026-03-18	diurno
1459	52	2026-05-20	nocturno
1257	42	2026-03-21	nocturno
1745	32	2026-08-15	nocturno
1358	52	2026-04-20	diurno
1097	42	2026-02-01	nocturno
1948	52	2026-10-14	diurno
1838	52	2026-09-11	diurno
1392	22	2026-05-02	diurno
1201	12	2026-03-06	nocturno
1611	12	2026-07-07	nocturno
1388	52	2026-04-29	diurno
1594	32	2026-07-01	diurno
1569	52	2026-06-22	nocturno
1813	22	2026-09-05	nocturno
1473	22	2026-05-26	nocturno
1032	22	2026-01-14	diurno
1641	12	2026-07-16	nocturno
1513	22	2026-06-07	nocturno
1767	42	2026-08-21	nocturno
1553	22	2026-06-19	nocturno
1645	32	2026-07-16	nocturno
1739	52	2026-08-12	nocturno
1146	42	2026-02-16	diurno
1590	12	2026-07-01	diurno
1883	22	2026-09-26	nocturno
1796	42	2026-08-30	diurno
1329	52	2026-04-11	nocturno
1205	32	2026-03-06	nocturno
1113	22	2026-02-07	nocturno
1615	32	2026-07-07	nocturno
1463	22	2026-05-23	nocturno
1709	52	2026-08-03	nocturno
1240	12	2026-03-18	diurno
1741	12	2026-08-15	nocturno
1718	52	2026-08-06	diurno
1282	22	2026-03-30	diurno
1784	32	2026-08-27	diurno
1411	12	2026-05-08	nocturno
1499	52	2026-06-01	nocturno
1293	22	2026-04-02	nocturno
1665	32	2026-07-22	nocturno
1367	42	2026-04-23	nocturno
1528	52	2026-06-10	diurno
1318	52	2026-04-08	diurno
1124	32	2026-02-10	diurno
1023	22	2026-01-11	nocturno
1422	22	2026-05-11	diurno
1624	32	2026-07-10	diurno
1170	12	2026-02-25	diurno
1136	42	2026-02-13	diurno
1620	12	2026-07-10	diurno
1589	52	2026-06-28	nocturno
1174	32	2026-02-25	diurno
1607	42	2026-07-04	nocturno
1120	12	2026-02-10	diurno
1577	42	2026-06-25	nocturno
1482	22	2026-05-29	diurno
1016	42	2026-01-08	diurno
1661	12	2026-07-22	nocturno
1106	42	2026-02-04	diurno
1780	12	2026-08-27	diurno
1415	32	2026-05-08	nocturno
1086	42	2026-01-29	diurno
1689	52	2026-07-28	nocturno
1626	42	2026-07-10	diurno
1134	32	2026-02-13	diurno
1601	12	2026-07-04	nocturno
1365	32	2026-04-23	nocturno
1126	42	2026-02-10	diurno
1571	12	2026-06-25	nocturno
1058	52	2026-01-20	diurno
1010	12	2026-01-08	diurno
1693	22	2026-07-31	nocturno
1667	42	2026-07-22	nocturno
1863	22	2026-09-20	nocturno
1100	12	2026-02-04	diurno
1786	42	2026-08-27	diurno
1080	12	2026-01-29	diurno
1417	42	2026-05-08	nocturno
1084	32	2026-01-29	diurno
1159	52	2026-02-19	nocturno
1104	32	2026-02-04	diurno
1849	52	2026-09-14	nocturno
1605	32	2026-07-04	nocturno
1361	12	2026-04-23	nocturno
1068	52	2026-01-23	diurno
1342	22	2026-04-17	diurno
1439	52	2026-05-14	nocturno
1902	22	2026-10-02	diurno
1575	32	2026-06-25	nocturno
1014	32	2026-01-08	diurno
1176	42	2026-02-25	diurno
1009	52	2026-01-05	nocturno
1532	22	2026-06-13	diurno
1130	12	2026-02-13	diurno
\.


--
-- Data for Name: turno_medico; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.turno_medico (id_turno, id_medico) FROM stdin;
1	1001
1	1005
2	1001
2	1005
1542	1032
1542	1035
1045	1036
1045	1037
1406	1041
1406	1042
1937	1041
1937	1042
1778	1047
1778	1048
1160	1001
1160	1005
1855	1036
1855	1037
1233	1032
1233	1035
1910	1001
1910	1006
1800	1001
1800	1006
1676	1041
1676	1046
1332	1031
1332	1032
1653	1032
1653	1035
1508	1047
1508	1048
1164	1036
1164	1037
1851	1001
1851	1006
1914	1036
1914	1037
1876	1041
1876	1042
1804	1036
1804	1037
1638	1047
1638	1048
1041	1001
1041	1005
1926	1041
1926	1046
1703	1031
1703	1032
1670	1001
1670	1006
1469	1047
1469	1048
1712	1031
1712	1032
1288	1047
1288	1048
1857	1041
1857	1046
1870	1001
1870	1005
1323	1031
1323	1032
1119	1047
1119	1048
1047	1041
1047	1042
1889	1047
1889	1048
1404	1036
1404	1037
1935	1036
1935	1037
1920	1001
1920	1006
1733	1031
1733	1035
1924	1036
1924	1037
1559	1047
1559	1048
1519	1047
1519	1048
1563	1031
1563	1032
1479	1047
1479	1048
1400	1001
1400	1005
1038	1047
1038	1048
1931	1001
1931	1005
1819	1047
1819	1048
1832	1031
1832	1032
1166	1041
1166	1042
1942	1031
1942	1032
1916	1041
1916	1046
1874	1036
1874	1037
1806	1041
1806	1046
1382	1031
1382	1035
1398	1047
1398	1048
1674	1036
1674	1037
1352	1031
1352	1032
1453	1031
1453	1032
1307	1041
1307	1046
1216	1041
1216	1042
1197	1041
1197	1046
1727	1041
1727	1046
1274	1036
1274	1037
1447	1041
1447	1042
1070	1001
1070	1006
1757	1041
1757	1042
1827	1041
1827	1042
1488	1047
1488	1048
1220	1001
1220	1005
1897	1042
1897	1046
1583	1031
1583	1032
1185	1036
1185	1037
1181	1001
1181	1006
1522	1031
1522	1032
1312	1031
1312	1035
1428	1047
1428	1048
1224	1036
1224	1037
1029	1047
1029	1048
1299	1047
1299	1048
1266	1041
1266	1046
1074	1036
1074	1037
1377	1041
1377	1046
1493	1031
1493	1035
1270	1001
1270	1005
1895	1036
1895	1037
1003	1031
1003	1035
1538	1047
1538	1048
1187	1041
1187	1046
1755	1036
1755	1037
1348	1047
1348	1048
1843	1031
1843	1035
1062	1032
1062	1035
1908	1047
1908	1048
1825	1036
1825	1037
1433	1031
1433	1035
1445	1036
1445	1037
1260	1001
1260	1006
1153	1031
1153	1032
1371	1001
1371	1006
1305	1036
1305	1037
1214	1036
1214	1037
1195	1036
1195	1037
1725	1036
1725	1037
1276	1041
1276	1042
1301	1001
1301	1006
1210	1001
1210	1005
1191	1001
1191	1006
1441	1001
1441	1005
1699	1047
1699	1048
1264	1036
1264	1037
1076	1041
1076	1046
1869	1047
1869	1048
1375	1036
1375	1037
1751	1001
1751	1005
1821	1001
1821	1005
1226	1041
1226	1042
1052	1031
1052	1032
1891	1005
1891	1006
1683	1031
1683	1032
1599	1047
1599	1048
1564	1036
1564	1037
1923	1031
1923	1032
1730	1001
1730	1006
1748	1047
1748	1048
1711	1005
1711	1006
1656	1041
1656	1042
1355	1036
1355	1037
1454	1036
1454	1037
1700	1001
1700	1005
1673	1031
1673	1035
1249	1047
1249	1048
1337	1041
1337	1042
1873	1031
1873	1032
1385	1036
1385	1037
1320	1001
1320	1006
1835	1036
1835	1037
1945	1036
1945	1037
1618	1047
1618	1048
1381	1001
1381	1005
1324	1036
1324	1037
1208	1047
1208	1048
1831	1005
1831	1006
1941	1001
1941	1005
1236	1041
1236	1042
1715	1036
1715	1037
1351	1005
1351	1006
1450	1001
1450	1005
1704	1036
1704	1037
1734	1036
1734	1037
1648	1047
1648	1048
1403	1031
1403	1032
1932	1031
1932	1032
1547	1041
1547	1046
1560	1001
1560	1006
1913	1031
1913	1035
1803	1031
1803	1032
1387	1041
1387	1042
1837	1042
1837	1046
1163	1031
1163	1032
1947	1041
1947	1042
1230	1001
1230	1005
1654	1036
1654	1037
1357	1042
1357	1046
1098	1047
1098	1048
1456	1041
1456	1042
1258	1047
1258	1048
1335	1036
1335	1037
1768	1047
1768	1048
1541	1001
1541	1006
1566	1041
1566	1046
1545	1036
1545	1037
1042	1031
1042	1032
1736	1041
1736	1046
1149	1047
1149	1048
1717	1042
1717	1046
1650	1001
1650	1005
1706	1041
1706	1042
1331	1001
1331	1005
1326	1041
1326	1046
1799	1047
1799	1048
1852	1031
1852	1035
1234	1036
1234	1037
1372	1031
1372	1035
1263	1031
1263	1032
1150	1001
1150	1005
1496	1041
1496	1046
1139	1047
1139	1048
1000	1005
1000	1006
1684	1036
1684	1037
1055	1036
1055	1037
1430	1001
1430	1006
1527	1041
1527	1042
1317	1041
1317	1046
1840	1005
1840	1006
1368	1047
1368	1048
1061	1001
1061	1006
1822	1031
1822	1032
1578	1047
1578	1048
1051	1005
1051	1006
1019	1047
1019	1048
1434	1036
1434	1037
1752	1031
1752	1032
1844	1036
1844	1037
1608	1047
1608	1048
1065	1036
1065	1037
1892	1031
1892	1032
1586	1041
1586	1042
1004	1036
1004	1037
1680	1001
1680	1006
1213	1031
1213	1032
1192	1031
1192	1035
1722	1032
1722	1035
1302	1032
1302	1035
1089	1047
1089	1048
1109	1047
1109	1048
1442	1031
1442	1035
1154	1036
1154	1037
1223	1031
1223	1032
1057	1042
1057	1046
1525	1036
1525	1037
1315	1036
1315	1037
1129	1047
1129	1048
1629	1047
1629	1048
1580	1001
1580	1005
1686	1041
1686	1046
1494	1036
1494	1037
1789	1047
1789	1048
1668	1047
1668	1048
1073	1031
1073	1035
1156	1041
1156	1042
1490	1001
1490	1006
1273	1031
1273	1032
1418	1047
1418	1048
1182	1032
1182	1035
1584	1036
1584	1037
1179	1047
1179	1048
1006	1042
1006	1046
1436	1041
1436	1046
1521	1001
1521	1005
1311	1001
1311	1006
1846	1042
1846	1046
1067	1041
1067	1046
1137	1041
1137	1046
1625	1036
1625	1037
1171	1005
1171	1006
1022	1031
1022	1035
1423	1031
1423	1035
1366	1042
1366	1046
1529	1047
1529	1048
1319	1047
1319	1048
1125	1036
1125	1037
1664	1036
1664	1037
1292	1031
1292	1032
1498	1047
1498	1048
1785	1036
1785	1037
1410	1001
1410	1005
1781	1001
1781	1006
1414	1036
1414	1037
1087	1041
1087	1042
1660	1005
1660	1006
1107	1041
1107	1042
1576	1041
1576	1042
1483	1031
1483	1035
1017	1041
1017	1046
1606	1042
1606	1046
1121	1001
1121	1006
1621	1001
1621	1005
1588	1047
1588	1048
1175	1036
1175	1037
1787	1041
1787	1046
1081	1001
1081	1005
1666	1042
1666	1046
1862	1031
1862	1035
1101	1001
1101	1005
1692	1031
1692	1032
1570	1001
1570	1005
1059	1047
1059	1048
1011	1001
1011	1006
1600	1005
1600	1006
1364	1036
1364	1037
1127	1041
1127	1046
1135	1036
1135	1037
1688	1047
1688	1048
1627	1041
1627	1042
1533	1032
1533	1035
1131	1001
1131	1006
1177	1042
1177	1046
1008	1047
1008	1048
1438	1047
1438	1048
1903	1031
1903	1035
1574	1036
1574	1037
1015	1036
1015	1037
1848	1047
1848	1048
1604	1036
1604	1037
1360	1005
1360	1006
1069	1047
1069	1048
1343	1031
1343	1032
1105	1036
1105	1037
1158	1047
1158	1048
1416	1041
1416	1042
1085	1036
1085	1037
1254	1036
1254	1037
1746	1041
1746	1046
1658	1047
1658	1048
1094	1036
1094	1037
1339	1047
1339	1048
1247	1041
1247	1046
1633	1031
1633	1032
1791	1001
1791	1006
1503	1031
1503	1032
1597	1042
1597	1046
1764	1036
1764	1037
1141	1001
1141	1005
1646	1041
1646	1042
1760	1001
1760	1005
1145	1036
1145	1037
1773	1032
1773	1035
1549	1047
1549	1048
1206	1041
1206	1046
1616	1041
1616	1046
1238	1047
1238	1048
1795	1036
1795	1037
1250	1001
1250	1006
1090	1001
1090	1005
1640	1001
1640	1005
1512	1031
1512	1032
1766	1041
1766	1042
1552	1031
1552	1035
1812	1031
1812	1032
1472	1031
1472	1032
1033	1031
1033	1032
1595	1036
1595	1037
1568	1047
1568	1048
1393	1031
1393	1032
1200	1001
1200	1006
1610	1001
1610	1006
1389	1047
1389	1048
1949	1047
1949	1048
1839	1047
1839	1048
1458	1047
1458	1048
1256	1041
1256	1046
1744	1036
1744	1037
1359	1047
1359	1048
1096	1041
1096	1042
1245	1036
1245	1037
1740	1001
1740	1006
1719	1047
1719	1048
1283	1031
1283	1032
1462	1031
1462	1032
1708	1047
1708	1048
1241	1001
1241	1006
1328	1047
1328	1048
1204	1036
1204	1037
1112	1031
1112	1032
1614	1036
1614	1037
1797	1041
1797	1046
1882	1031
1882	1032
1591	1005
1591	1006
1644	1036
1644	1037
1738	1047
1738	1048
1147	1041
1147	1042
1603	1031
1603	1035
1759	1047
1759	1048
1344	1036
1344	1037
1904	1036
1904	1037
1829	1047
1829	1048
1573	1031
1573	1032
1486	1042
1486	1046
1012	1031
1012	1035
1899	1047
1899	1048
1534	1036
1534	1037
1309	1047
1309	1048
1082	1031
1082	1035
1729	1047
1729	1048
1218	1047
1218	1048
1199	1047
1199	1048
1691	1001
1691	1005
1449	1047
1449	1048
1861	1001
1861	1005
1102	1031
1102	1032
1695	1036
1695	1037
1297	1042
1297	1046
1268	1047
1268	1048
1865	1036
1865	1037
1379	1047
1379	1048
1530	1001
1530	1005
1132	1031
1132	1035
1363	1031
1363	1035
1340	1001
1340	1005
1027	1041
1027	1042
1900	1005
1900	1006
1426	1042
1426	1046
1291	1005
1291	1006
1413	1032
1413	1035
1278	1047
1278	1048
1172	1031
1172	1032
1536	1041
1536	1042
1189	1047
1189	1048
1346	1041
1346	1042
1021	1001
1021	1005
1906	1042
1906	1046
1484	1036
1484	1037
1420	1005
1420	1006
1122	1032
1122	1035
1025	1036
1025	1037
1480	1005
1480	1006
1424	1036
1424	1037
1228	1047
1228	1048
1622	1031
1622	1035
1782	1032
1782	1035
1697	1041
1697	1042
1295	1036
1295	1037
1078	1047
1078	1048
1663	1031
1663	1035
1867	1041
1867	1042
1390	1001
1390	1005
1203	1031
1203	1032
1115	1036
1115	1037
1613	1031
1613	1035
1465	1036
1465	1037
1284	1036
1284	1037
1643	1031
1643	1032
1511	1001
1511	1005
1551	1001
1551	1006
1939	1047
1939	1048
1811	1001
1811	1005
1776	1041
1776	1042
1885	1036
1885	1037
1471	1005
1471	1006
1408	1047
1408	1048
1030	1001
1030	1005
1592	1031
1592	1032
1815	1036
1815	1037
1881	1001
1881	1005
1475	1036
1475	1037
1034	1036
1034	1037
1515	1036
1515	1037
1928	1047
1928	1048
1555	1036
1555	1037
1461	1001
1461	1005
1678	1047
1678	1048
1242	1032
1242	1035
1743	1031
1743	1032
1280	1001
1280	1005
1506	1041
1506	1046
1636	1041
1636	1042
1394	1036
1394	1037
1111	1005
1111	1006
1878	1047
1878	1048
1049	1047
1049	1048
1774	1036
1774	1037
1887	1041
1887	1042
1142	1031
1142	1035
1467	1041
1467	1042
1286	1041
1286	1042
1859	1047
1859	1048
1792	1031
1792	1035
1500	1001
1500	1006
1630	1001
1630	1005
1117	1042
1117	1046
1504	1036
1504	1037
1168	1047
1168	1048
1634	1036
1634	1037
1396	1041
1396	1042
1918	1047
1918	1048
1808	1047
1808	1048
1253	1031
1253	1035
1093	1031
1093	1032
1517	1041
1517	1042
1763	1031
1763	1032
1557	1041
1557	1046
1817	1041
1817	1042
1770	1001
1770	1005
1477	1042
1477	1046
1036	1041
1036	1042
1526	1041
1526	1042
1316	1041
1316	1046
1841	1001
1841	1006
1369	1047
1369	1048
1060	1005
1060	1006
1054	1036
1054	1037
1431	1001
1431	1006
1001	1001
1001	1006
1685	1036
1685	1037
1138	1047
1138	1048
1497	1041
1497	1046
1262	1031
1262	1035
1151	1001
1151	1005
1373	1031
1373	1035
1443	1031
1443	1032
1155	1036
1155	1037
1108	1047
1108	1048
1303	1031
1303	1035
1088	1047
1088	1048
1212	1031
1212	1032
1193	1031
1193	1035
1723	1031
1723	1035
1893	1032
1893	1035
1587	1041
1587	1042
1005	1036
1005	1037
1681	1001
1681	1005
1753	1031
1753	1032
1845	1036
1845	1037
1609	1047
1609	1048
1064	1036
1064	1037
1823	1031
1823	1032
1579	1047
1579	1048
1050	1001
1050	1005
1018	1047
1018	1048
1435	1036
1435	1037
1072	1031
1072	1035
1669	1047
1669	1048
1788	1047
1788	1048
1495	1036
1495	1037
1628	1047
1628	1048
1581	1001
1581	1005
1687	1041
1687	1042
1524	1036
1524	1037
1314	1036
1314	1037
1128	1047
1128	1048
1222	1031
1222	1032
1056	1041
1056	1042
1520	1001
1520	1005
1310	1001
1310	1006
1847	1041
1847	1046
1066	1042
1066	1046
1437	1041
1437	1046
1585	1036
1585	1037
1178	1047
1178	1048
1007	1041
1007	1046
1183	1031
1183	1035
1419	1047
1419	1048
1491	1001
1491	1006
1272	1031
1272	1032
1157	1041
1157	1042
1834	1036
1834	1037
1944	1036
1944	1037
1872	1031
1872	1032
1384	1036
1384	1037
1321	1001
1321	1005
1701	1001
1701	1005
1672	1031
1672	1035
1248	1047
1248	1048
1336	1041
1336	1042
1749	1047
1749	1048
1710	1001
1710	1005
1657	1042
1657	1046
1354	1036
1354	1037
1455	1036
1455	1037
1922	1031
1922	1035
1731	1001
1731	1006
1598	1047
1598	1048
1565	1036
1565	1037
1546	1042
1546	1046
1561	1001
1561	1005
1402	1031
1402	1032
1933	1031
1933	1032
1735	1036
1735	1037
1649	1047
1649	1048
1705	1036
1705	1037
1714	1036
1714	1037
1350	1001
1350	1005
1451	1001
1451	1005
1830	1001
1830	1005
1940	1001
1940	1005
1237	1042
1237	1046
1619	1047
1619	1048
1380	1001
1380	1006
1325	1036
1325	1037
1209	1047
1209	1048
1540	1005
1540	1006
1567	1041
1567	1042
1769	1047
1769	1048
1334	1036
1334	1037
1655	1036
1655	1037
1356	1041
1356	1042
1099	1047
1099	1048
1457	1041
1457	1042
1259	1047
1259	1048
1836	1041
1836	1042
1162	1031
1162	1032
1946	1041
1946	1042
1231	1005
1231	1006
1912	1031
1912	1035
1802	1031
1802	1035
1386	1041
1386	1046
1798	1047
1798	1048
1853	1031
1853	1035
1235	1036
1235	1037
1327	1041
1327	1042
1707	1041
1707	1042
1330	1001
1330	1005
1716	1041
1716	1042
1651	1005
1651	1006
1737	1041
1737	1046
1148	1047
1148	1048
1544	1036
1544	1037
1043	1031
1043	1032
1184	1036
1184	1037
1896	1041
1896	1042
1582	1031
1582	1032
1826	1041
1826	1042
1489	1047
1489	1048
1221	1001
1221	1005
1756	1041
1756	1042
1446	1041
1446	1046
1071	1001
1071	1006
1217	1041
1217	1042
1196	1041
1196	1046
1726	1042
1726	1046
1275	1036
1275	1037
1306	1042
1306	1046
1492	1031
1492	1035
1271	1001
1271	1005
1376	1041
1376	1046
1298	1047
1298	1048
1267	1041
1267	1042
1075	1036
1075	1037
1429	1047
1429	1048
1225	1036
1225	1037
1028	1047
1028	1048
1523	1031
1523	1032
1313	1031
1313	1035
1180	1005
1180	1006
1215	1036
1215	1037
1194	1036
1194	1037
1724	1036
1724	1037
1277	1041
1277	1042
1304	1036
1304	1037
1370	1001
1370	1006
1444	1036
1444	1037
1261	1001
1261	1005
1152	1031
1152	1032
1909	1047
1909	1048
1824	1036
1824	1037
1432	1031
1432	1035
1754	1036
1754	1037
1349	1047
1349	1048
1842	1032
1842	1035
1063	1031
1063	1035
1539	1047
1539	1048
1186	1042
1186	1046
1894	1036
1894	1037
1002	1032
1002	1035
1890	1001
1890	1005
1682	1031
1682	1035
1820	1001
1820	1005
1227	1041
1227	1042
1053	1032
1053	1035
1750	1001
1750	1005
1868	1047
1868	1048
1374	1036
1374	1037
1440	1001
1440	1006
1698	1047
1698	1048
1265	1036
1265	1037
1077	1041
1077	1046
1211	1001
1211	1005
1190	1001
1190	1006
1720	1005
1720	1006
1300	1005
1300	1006
1911	1001
1911	1006
1801	1001
1801	1005
1161	1001
1161	1005
1854	1036
1854	1037
1232	1031
1232	1032
1407	1041
1407	1042
1936	1041
1936	1042
1779	1047
1779	1048
1543	1031
1543	1035
1044	1036
1044	1037
1927	1041
1927	1042
1040	1001
1040	1005
1915	1036
1915	1037
1877	1041
1877	1042
1805	1036
1805	1037
1639	1047
1639	1048
1509	1047
1509	1048
1165	1036
1165	1037
1850	1001
1850	1006
1652	1031
1652	1032
1677	1041
1677	1046
1333	1031
1333	1032
1921	1001
1921	1005
1732	1031
1732	1035
1888	1047
1888	1048
1405	1036
1405	1037
1934	1036
1934	1037
1046	1041
1046	1042
1871	1001
1871	1005
1322	1031
1322	1035
1118	1047
1118	1048
1856	1041
1856	1046
1713	1032
1713	1035
1289	1047
1289	1048
1702	1031
1702	1032
1671	1001
1671	1006
1468	1047
1468	1048
1353	1032
1353	1035
1452	1031
1452	1032
1675	1036
1675	1037
1917	1041
1917	1046
1875	1036
1875	1037
1807	1041
1807	1042
1383	1031
1383	1032
1399	1047
1399	1048
1833	1032
1833	1035
1167	1041
1167	1042
1943	1031
1943	1032
1478	1047
1478	1048
1401	1001
1401	1005
1039	1047
1039	1048
1930	1001
1930	1005
1818	1047
1818	1048
1562	1031
1562	1035
1925	1036
1925	1037
1558	1047
1558	1048
1518	1047
1518	1048
1938	1047
1938	1048
1810	1001
1810	1005
1777	1042
1777	1046
1884	1036
1884	1037
1470	1001
1470	1005
1409	1047
1409	1048
1031	1001
1031	1005
1642	1031
1642	1032
1510	1001
1510	1005
1550	1001
1550	1006
1285	1036
1285	1037
1464	1036
1464	1037
1391	1001
1391	1005
1202	1031
1202	1035
1114	1036
1114	1037
1612	1031
1612	1035
1637	1041
1637	1042
1395	1036
1395	1037
1110	1001
1110	1005
1879	1047
1879	1048
1507	1041
1507	1042
1742	1031
1742	1035
1281	1001
1281	1005
1460	1001
1460	1005
1679	1047
1679	1048
1243	1031
1243	1035
1514	1036
1514	1037
1929	1047
1929	1048
1554	1036
1554	1037
1814	1036
1814	1037
1880	1001
1880	1005
1474	1036
1474	1037
1035	1036
1035	1037
1593	1032
1593	1035
1631	1001
1631	1005
1116	1041
1116	1042
1858	1047
1858	1048
1793	1031
1793	1035
1501	1001
1501	1005
1287	1041
1287	1042
1466	1041
1466	1042
1143	1031
1143	1032
1775	1036
1775	1037
1886	1041
1886	1042
1048	1047
1048	1048
1816	1041
1816	1042
1771	1005
1771	1006
1476	1041
1476	1042
1037	1041
1037	1042
1516	1041
1516	1042
1762	1031
1762	1032
1556	1041
1556	1046
1252	1031
1252	1035
1092	1031
1092	1032
1635	1036
1635	1037
1397	1041
1397	1042
1919	1047
1919	1048
1809	1047
1809	1048
1505	1036
1505	1037
1169	1047
1169	1048
1860	1001
1860	1006
1103	1031
1103	1032
1690	1001
1690	1005
1448	1047
1448	1048
1728	1047
1728	1048
1219	1047
1219	1048
1198	1047
1198	1048
1308	1047
1308	1048
1083	1031
1083	1032
1535	1036
1535	1037
1898	1047
1898	1048
1905	1036
1905	1037
1828	1047
1828	1048
1572	1031
1572	1032
1487	1041
1487	1046
1013	1031
1013	1035
1602	1032
1602	1035
1758	1047
1758	1048
1345	1036
1345	1037
1026	1041
1026	1046
1901	1001
1901	1006
1427	1041
1427	1046
1362	1032
1362	1035
1341	1001
1341	1005
1531	1005
1531	1006
1133	1031
1133	1035
1864	1036
1864	1037
1378	1047
1378	1048
1694	1036
1694	1037
1296	1041
1296	1042
1269	1047
1269	1048
1020	1001
1020	1006
1907	1041
1907	1046
1485	1036
1485	1037
1421	1001
1421	1006
1347	1041
1347	1042
1537	1042
1537	1046
1188	1047
1188	1048
1173	1032
1173	1035
1279	1047
1279	1048
1412	1031
1412	1032
1290	1001
1290	1005
1662	1032
1662	1035
1866	1041
1866	1046
1696	1041
1696	1042
1294	1036
1294	1037
1079	1047
1079	1048
1783	1031
1783	1035
1623	1031
1623	1032
1024	1036
1024	1037
1481	1001
1481	1006
1425	1036
1425	1037
1229	1047
1229	1048
1123	1031
1123	1035
1765	1036
1765	1037
1140	1001
1140	1006
1596	1041
1596	1042
1790	1001
1790	1006
1502	1031
1502	1035
1632	1031
1632	1032
1338	1047
1338	1048
1246	1042
1246	1046
1255	1036
1255	1037
1747	1041
1747	1042
1659	1047
1659	1048
1095	1036
1095	1037
1251	1001
1251	1006
1091	1001
1091	1005
1239	1047
1239	1048
1794	1036
1794	1037
1207	1041
1207	1042
1617	1041
1617	1046
1548	1047
1548	1048
1772	1031
1772	1032
1647	1041
1647	1042
1761	1001
1761	1005
1144	1036
1144	1037
1244	1036
1244	1037
1459	1047
1459	1048
1257	1041
1257	1046
1745	1036
1745	1037
1358	1047
1358	1048
1097	1041
1097	1042
1948	1047
1948	1048
1838	1047
1838	1048
1392	1031
1392	1032
1201	1001
1201	1005
1611	1001
1611	1006
1388	1047
1388	1048
1594	1036
1594	1037
1569	1047
1569	1048
1813	1031
1813	1032
1473	1032
1473	1035
1032	1031
1032	1032
1641	1001
1641	1005
1513	1031
1513	1032
1767	1041
1767	1042
1553	1031
1553	1035
1645	1036
1645	1037
1739	1047
1739	1048
1146	1041
1146	1046
1590	1001
1590	1005
1883	1031
1883	1032
1796	1041
1796	1046
1329	1047
1329	1048
1205	1036
1205	1037
1113	1032
1113	1035
1615	1036
1615	1037
1463	1031
1463	1032
1709	1047
1709	1048
1240	1005
1240	1006
1741	1001
1741	1005
1718	1047
1718	1048
1282	1031
1282	1032
1784	1036
1784	1037
1411	1005
1411	1006
1499	1047
1499	1048
1293	1032
1293	1035
1665	1036
1665	1037
1367	1041
1367	1046
1528	1047
1528	1048
1318	1047
1318	1048
1124	1036
1124	1037
1023	1031
1023	1032
1422	1032
1422	1035
1624	1036
1624	1037
1170	1001
1170	1005
1136	1041
1136	1046
1620	1001
1620	1006
1589	1047
1589	1048
1174	1036
1174	1037
1607	1041
1607	1046
1120	1005
1120	1006
1577	1041
1577	1042
1482	1032
1482	1035
1016	1041
1016	1046
1661	1001
1661	1006
1106	1041
1106	1042
1780	1005
1780	1006
1415	1036
1415	1037
1086	1041
1086	1046
1689	1047
1689	1048
1626	1041
1626	1046
1134	1036
1134	1037
1601	1001
1601	1006
1365	1036
1365	1037
1126	1042
1126	1046
1571	1001
1571	1005
1058	1047
1058	1048
1010	1001
1010	1006
1693	1031
1693	1032
1667	1041
1667	1046
1863	1031
1863	1032
1100	1001
1100	1005
1786	1042
1786	1046
1080	1001
1080	1006
1417	1042
1417	1046
1084	1036
1084	1037
1159	1047
1159	1048
1104	1036
1104	1037
1849	1047
1849	1048
1605	1036
1605	1037
1361	1001
1361	1006
1068	1047
1068	1048
1342	1031
1342	1032
1439	1047
1439	1048
1902	1032
1902	1035
1575	1036
1575	1037
1014	1036
1014	1037
1176	1041
1176	1042
1009	1047
1009	1048
1532	1031
1532	1032
1130	1001
1130	1006
\.


--
-- Data for Name: unidad_medica; Type: TABLE DATA; Schema: public; Owner: admin
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
41	4	Consulta Externa	\N
42	4	Emergencias	\N
43	4	Cirugía	\N
44	4	Hospitalización	480.00
51	5	Consulta Externa	\N
52	5	Emergencias	\N
53	5	Cirugía	\N
54	5	Hospitalización	430.00
\.


--
-- Name: cirujano_id_cirujano_seq; Type: SEQUENCE SET; Schema: propuesta_bloque_e; Owner: admin
--

SELECT pg_catalog.setval('propuesta_bloque_e.cirujano_id_cirujano_seq', 2, true);


--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE SET; Schema: propuesta_bloque_e; Owner: admin
--

SELECT pg_catalog.setval('propuesta_bloque_e.especialidad_id_especialidad_seq', 2, true);


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE SET; Schema: propuesta_bloque_e; Owner: admin
--

SELECT pg_catalog.setval('propuesta_bloque_e.insumo_id_insumo_seq', 4, true);


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE SET; Schema: propuesta_bloque_e; Owner: admin
--

SELECT pg_catalog.setval('propuesta_bloque_e.paciente_id_paciente_seq', 4, true);


--
-- Name: agendamiento_quirurgico_id_agendamiento_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.agendamiento_quirurgico_id_agendamiento_seq', 4, false);


--
-- Name: aspecto_quirurgico_id_aspecto_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.aspecto_quirurgico_id_aspecto_seq', 39, false);


--
-- Name: auditoria_personal_id_auditoria_seq; Type: SEQUENCE SET; Schema: public; Owner: dueno_auditoria
--

SELECT pg_catalog.setval('public.auditoria_personal_id_auditoria_seq', 4, true);


--
-- Name: calificacion_id_calificacion_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.calificacion_id_calificacion_seq', 187, true);


--
-- Name: camilla_id_camilla_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.camilla_id_camilla_seq', 215, false);


--
-- Name: chequeo_preanestesico_id_chequeo_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.chequeo_preanestesico_id_chequeo_seq', 2, false);


--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.cirugia_id_cirugia_seq', 2, false);


--
-- Name: cirugia_personal_id_cirugia_personal_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.cirugia_personal_id_cirugia_personal_seq', 125, true);


--
-- Name: cita_id_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.cita_id_cita_seq', 6, false);


--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.consentimiento_informado_id_consentimiento_seq', 2, false);


--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.consulta_id_consulta_seq', 3, false);


--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.departamento_id_departamento_seq', 23, false);


--
-- Name: diagnostico_id_diagnostico_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.diagnostico_id_diagnostico_seq', 12, false);


--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.egreso_id_egreso_seq', 4, false);


--
-- Name: encargado_id_encargado_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.encargado_id_encargado_seq', 323, true);


--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.equipo_id_equipo_seq', 9, false);


--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.especialidad_id_especialidad_seq', 330, false);


--
-- Name: estado_civil_id_estado_civil_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.estado_civil_id_estado_civil_seq', 6, false);


--
-- Name: factura_id_factura_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.factura_id_factura_seq', 403, true);


--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.historia_clinica_id_historia_clinica_seq', 2, false);


--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.hospital_id_hospital_seq', 4, false);


--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.ingreso_id_ingreso_seq', 6, false);


--
-- Name: institucion_externa_id_institucion_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.institucion_externa_id_institucion_seq', 3, false);


--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.instrumento_id_instrumento_seq', 11, false);


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.insumo_id_insumo_seq', 11, false);


--
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.medicamento_id_medicamento_seq', 11, false);


--
-- Name: metodo_pago_id_metodo_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.metodo_pago_id_metodo_pago_seq', 5, false);


--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.municipio_id_municipio_seq', 9, false);


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.paciente_id_paciente_seq', 67, true);


--
-- Name: pago_id_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.pago_id_pago_seq', 856, true);


--
-- Name: parentesco_id_parentesco_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.parentesco_id_parentesco_seq', 10, false);


--
-- Name: personal_id_personal_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.personal_id_personal_seq', 2020, true);


--
-- Name: quirofano_id_quirofano_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.quirofano_id_quirofano_seq', 13, false);


--
-- Name: receta_id_receta_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.receta_id_receta_seq', 3, false);


--
-- Name: registro_procedimiento_id_registro_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.registro_procedimiento_id_registro_seq', 1338, true);


--
-- Name: rol_quirurgico_id_rol_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.rol_quirurgico_id_rol_seq', 6, false);


--
-- Name: servicio_atencion_id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.servicio_atencion_id_servicio_seq', 220, false);


--
-- Name: tipo_anestesia_id_tipo_anestesia_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.tipo_anestesia_id_tipo_anestesia_seq', 6, false);


--
-- Name: tipo_cirugia_id_tipo_cirugia_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.tipo_cirugia_id_tipo_cirugia_seq', 11, false);


--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.traslado_id_traslado_seq', 4, false);


--
-- Name: turno_emergencia_id_turno_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.turno_emergencia_id_turno_seq', 3, false);


--
-- Name: unidad_medica_id_unidad_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.unidad_medica_id_unidad_seq', 35, false);


--
-- Name: cirugia_insumo cirugia_insumo_pkey; Type: CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_pkey PRIMARY KEY (id_cirugia, id_insumo);


--
-- Name: cirugia cirugia_pkey; Type: CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.cirugia
    ADD CONSTRAINT cirugia_pkey PRIMARY KEY (id_cirugia);


--
-- Name: cirujano cirujano_pkey; Type: CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.cirujano
    ADD CONSTRAINT cirujano_pkey PRIMARY KEY (id_cirujano);


--
-- Name: diagnostico diagnostico_pkey; Type: CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.diagnostico
    ADD CONSTRAINT diagnostico_pkey PRIMARY KEY (codigo_cie10);


--
-- Name: especialidad especialidad_pkey; Type: CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: insumo insumo_pkey; Type: CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.insumo
    ADD CONSTRAINT insumo_pkey PRIMARY KEY (id_insumo);


--
-- Name: paciente paciente_pkey; Type: CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id_paciente);


--
-- Name: reporte_cirugia reporte_cirugia_pkey; Type: CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.reporte_cirugia
    ADD CONSTRAINT reporte_cirugia_pkey PRIMARY KEY (id_cirugia);


--
-- Name: especialidad uq_especialidad_nombre; Type: CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.especialidad
    ADD CONSTRAINT uq_especialidad_nombre UNIQUE (nombre);


--
-- Name: insumo uq_insumo_nombre; Type: CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.insumo
    ADD CONSTRAINT uq_insumo_nombre UNIQUE (nombre);


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_pkey PRIMARY KEY (id_agendamiento);


--
-- Name: aspecto_quirurgico aspecto_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aspecto_quirurgico
    ADD CONSTRAINT aspecto_quirurgico_pkey PRIMARY KEY (id_aspecto);


--
-- Name: auditoria_personal auditoria_personal_pkey; Type: CONSTRAINT; Schema: public; Owner: dueno_auditoria
--

ALTER TABLE ONLY public.auditoria_personal
    ADD CONSTRAINT auditoria_personal_pkey PRIMARY KEY (id_auditoria);


--
-- Name: calificacion calificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_pkey PRIMARY KEY (id_calificacion);


--
-- Name: camilla camilla_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_pkey PRIMARY KEY (id_camilla);


--
-- Name: chequeo_preanestesico chequeo_preanestesico_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_pkey PRIMARY KEY (id_chequeo);


--
-- Name: cirugia_insumo cirugia_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_pkey PRIMARY KEY (id_cirugia, id_insumo);


--
-- Name: cirugia_personal cirugia_personal_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_pkey PRIMARY KEY (id_cirugia_personal);


--
-- Name: cirugia cirugia_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_pkey PRIMARY KEY (id_cirugia);


--
-- Name: cita cita_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_pkey PRIMARY KEY (id_cita);


--
-- Name: consentimiento_informado consentimiento_informado_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_pkey PRIMARY KEY (id_consentimiento);


--
-- Name: consulta consulta_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_pkey PRIMARY KEY (id_consulta);


--
-- Name: departamento departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_pkey PRIMARY KEY (id_departamento);


--
-- Name: diagnostico diagnostico_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.diagnostico
    ADD CONSTRAINT diagnostico_pkey PRIMARY KEY (id_diagnostico);


--
-- Name: documentacion_etapa documentacion_etapa_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.documentacion_etapa
    ADD CONSTRAINT documentacion_etapa_pkey PRIMARY KEY (id_cirugia, etapa);


--
-- Name: egreso_diagnostico egreso_diagnostico_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.egreso_diagnostico
    ADD CONSTRAINT egreso_diagnostico_pkey PRIMARY KEY (id_egreso, id_diagnostico);


--
-- Name: egreso egreso_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_pkey PRIMARY KEY (id_egreso);


--
-- Name: encargado encargado_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_pkey PRIMARY KEY (id_encargado);


--
-- Name: enfermero enfermero_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT enfermero_pkey PRIMARY KEY (id_enfermero);


--
-- Name: equipo equipo_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.equipo
    ADD CONSTRAINT equipo_pkey PRIMARY KEY (id_equipo);


--
-- Name: especialidad especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: estado_civil estado_civil_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.estado_civil
    ADD CONSTRAINT estado_civil_pkey PRIMARY KEY (id_estado_civil);


--
-- Name: factura factura_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_pkey PRIMARY KEY (id_factura);


--
-- Name: historia_clinica historia_clinica_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_pkey PRIMARY KEY (id_historia_clinica);


--
-- Name: hospital hospital_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (id_hospital);


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_pkey PRIMARY KEY (id_ingreso, id_insumo);


--
-- Name: ingreso ingreso_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_pkey PRIMARY KEY (id_ingreso);


--
-- Name: institucion_externa institucion_externa_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.institucion_externa
    ADD CONSTRAINT institucion_externa_pkey PRIMARY KEY (id_institucion);


--
-- Name: instrumento instrumento_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.instrumento
    ADD CONSTRAINT instrumento_pkey PRIMARY KEY (id_instrumento);


--
-- Name: insumo insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.insumo
    ADD CONSTRAINT insumo_pkey PRIMARY KEY (id_insumo);


--
-- Name: medicamento medicamento_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.medicamento
    ADD CONSTRAINT medicamento_pkey PRIMARY KEY (id_medicamento);


--
-- Name: medico medico_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_pkey PRIMARY KEY (id_medico);


--
-- Name: metodo_pago metodo_pago_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.metodo_pago
    ADD CONSTRAINT metodo_pago_pkey PRIMARY KEY (id_metodo_pago);


--
-- Name: municipio municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_pkey PRIMARY KEY (id_municipio);


--
-- Name: paciente_encargado paciente_encargado_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_pkey PRIMARY KEY (id_paciente, id_encargado);


--
-- Name: paciente paciente_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id_paciente);


--
-- Name: pago pago_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (id_pago);


--
-- Name: parentesco parentesco_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.parentesco
    ADD CONSTRAINT parentesco_pkey PRIMARY KEY (id_parentesco);


--
-- Name: personal personal_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT personal_pkey PRIMARY KEY (id_personal);


--
-- Name: quirofano quirofano_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_pkey PRIMARY KEY (id_quirofano);


--
-- Name: receta_medicamento receta_medicamento_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_pkey PRIMARY KEY (id_receta, id_medicamento);


--
-- Name: receta receta_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_pkey PRIMARY KEY (id_receta);


--
-- Name: registro_procedimiento registro_procedimiento_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_pkey PRIMARY KEY (id_registro);


--
-- Name: requerimiento_equipo requerimiento_equipo_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.requerimiento_equipo
    ADD CONSTRAINT requerimiento_equipo_pkey PRIMARY KEY (id_agendamiento, id_equipo);


--
-- Name: requerimiento_instrumento requerimiento_instrumento_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.requerimiento_instrumento
    ADD CONSTRAINT requerimiento_instrumento_pkey PRIMARY KEY (id_agendamiento, id_instrumento);


--
-- Name: requerimiento_insumo requerimiento_insumo_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.requerimiento_insumo
    ADD CONSTRAINT requerimiento_insumo_pkey PRIMARY KEY (id_agendamiento, id_insumo);


--
-- Name: rol_quirurgico rol_quirurgico_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.rol_quirurgico
    ADD CONSTRAINT rol_quirurgico_pkey PRIMARY KEY (id_rol);


--
-- Name: servicio_atencion servicio_atencion_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_pkey PRIMARY KEY (id_servicio);


--
-- Name: tipo_anestesia tipo_anestesia_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tipo_anestesia
    ADD CONSTRAINT tipo_anestesia_pkey PRIMARY KEY (id_tipo_anestesia);


--
-- Name: tipo_cirugia tipo_cirugia_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tipo_cirugia
    ADD CONSTRAINT tipo_cirugia_pkey PRIMARY KEY (id_tipo_cirugia);


--
-- Name: traslado traslado_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_pkey PRIMARY KEY (id_traslado);


--
-- Name: turno_emergencia turno_emergencia_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.turno_emergencia
    ADD CONSTRAINT turno_emergencia_pkey PRIMARY KEY (id_turno);


--
-- Name: turno_medico turno_medico_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.turno_medico
    ADD CONSTRAINT turno_medico_pkey PRIMARY KEY (id_turno, id_medico);


--
-- Name: unidad_medica unidad_medica_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_pkey PRIMARY KEY (id_unidad);


--
-- Name: aspecto_quirurgico uq_aspecto_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aspecto_quirurgico
    ADD CONSTRAINT uq_aspecto_nombre UNIQUE (seccion, nombre);


--
-- Name: camilla uq_camilla_numero; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT uq_camilla_numero UNIQUE (id_unidad, numero);


--
-- Name: chequeo_preanestesico uq_chequeo_agendamiento; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT uq_chequeo_agendamiento UNIQUE (id_agendamiento);


--
-- Name: cirugia uq_cirugia_agendamiento; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT uq_cirugia_agendamiento UNIQUE (id_agendamiento);


--
-- Name: cirugia_personal uq_cirugia_enfermero; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT uq_cirugia_enfermero UNIQUE (id_cirugia, id_enfermero);


--
-- Name: cirugia_personal uq_cirugia_medico; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT uq_cirugia_medico UNIQUE (id_cirugia, id_medico);


--
-- Name: consentimiento_informado uq_consentimiento_agendamiento; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT uq_consentimiento_agendamiento UNIQUE (id_agendamiento);


--
-- Name: consulta uq_consulta_cita; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT uq_consulta_cita UNIQUE (id_cita);


--
-- Name: departamento uq_departamento_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT uq_departamento_nombre UNIQUE (nombre);


--
-- Name: diagnostico uq_diagnostico_codigo; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.diagnostico
    ADD CONSTRAINT uq_diagnostico_codigo UNIQUE (codigo_cie10);


--
-- Name: egreso uq_egreso_ingreso; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT uq_egreso_ingreso UNIQUE (id_ingreso);


--
-- Name: encargado uq_encargado_dpi; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT uq_encargado_dpi UNIQUE (dpi);


--
-- Name: enfermero uq_enfermero_dpi; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT uq_enfermero_dpi UNIQUE (dpi);


--
-- Name: equipo uq_equipo_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.equipo
    ADD CONSTRAINT uq_equipo_nombre UNIQUE (nombre);


--
-- Name: especialidad uq_especialidad_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT uq_especialidad_nombre UNIQUE (nombre);


--
-- Name: estado_civil uq_estado_civil_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.estado_civil
    ADD CONSTRAINT uq_estado_civil_nombre UNIQUE (nombre);


--
-- Name: factura uq_factura_cirugia; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT uq_factura_cirugia UNIQUE (id_cirugia);


--
-- Name: factura uq_factura_cita; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT uq_factura_cita UNIQUE (id_cita);


--
-- Name: factura uq_factura_ingreso; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT uq_factura_ingreso UNIQUE (id_ingreso);


--
-- Name: historia_clinica uq_historia_agendamiento; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT uq_historia_agendamiento UNIQUE (id_agendamiento);


--
-- Name: hospital uq_hospital_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT uq_hospital_nombre UNIQUE (nombre);


--
-- Name: institucion_externa uq_institucion_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.institucion_externa
    ADD CONSTRAINT uq_institucion_nombre UNIQUE (nombre);


--
-- Name: instrumento uq_instrumento_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.instrumento
    ADD CONSTRAINT uq_instrumento_nombre UNIQUE (nombre);


--
-- Name: insumo uq_insumo_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.insumo
    ADD CONSTRAINT uq_insumo_nombre UNIQUE (nombre);


--
-- Name: medicamento uq_medicamento; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.medicamento
    ADD CONSTRAINT uq_medicamento UNIQUE (nombre_generico, concentracion, forma_farmaceutica);


--
-- Name: medico uq_medico_dpi; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT uq_medico_dpi UNIQUE (dpi);


--
-- Name: metodo_pago uq_metodo_pago_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.metodo_pago
    ADD CONSTRAINT uq_metodo_pago_nombre UNIQUE (nombre);


--
-- Name: municipio uq_municipio_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT uq_municipio_nombre UNIQUE (id_departamento, nombre);


--
-- Name: paciente uq_paciente_dpi; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT uq_paciente_dpi UNIQUE (dpi);


--
-- Name: paciente uq_paciente_expediente; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT uq_paciente_expediente UNIQUE (numero_expediente);


--
-- Name: pago uq_pago_cuota; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT uq_pago_cuota UNIQUE (id_factura, numero_cuota);


--
-- Name: parentesco uq_parentesco_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.parentesco
    ADD CONSTRAINT uq_parentesco_nombre UNIQUE (nombre);


--
-- Name: personal uq_personal_dpi; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT uq_personal_dpi UNIQUE (dpi);


--
-- Name: personal uq_personal_tipo; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT uq_personal_tipo UNIQUE (id_personal, tipo_personal);


--
-- Name: quirofano uq_quirofano_numero; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT uq_quirofano_numero UNIQUE (id_unidad, numero);


--
-- Name: receta uq_receta_consulta; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT uq_receta_consulta UNIQUE (id_consulta);


--
-- Name: registro_procedimiento uq_registro_aspecto; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT uq_registro_aspecto UNIQUE (id_cirugia, id_aspecto);


--
-- Name: rol_quirurgico uq_rol_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.rol_quirurgico
    ADD CONSTRAINT uq_rol_nombre UNIQUE (nombre);


--
-- Name: servicio_atencion uq_servicio_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT uq_servicio_nombre UNIQUE (id_unidad, nombre);


--
-- Name: tipo_anestesia uq_tipo_anestesia_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tipo_anestesia
    ADD CONSTRAINT uq_tipo_anestesia_nombre UNIQUE (nombre);


--
-- Name: tipo_cirugia uq_tipo_cirugia_nombre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tipo_cirugia
    ADD CONSTRAINT uq_tipo_cirugia_nombre UNIQUE (nombre);


--
-- Name: turno_emergencia uq_turno; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.turno_emergencia
    ADD CONSTRAINT uq_turno UNIQUE (id_unidad, fecha, jornada);


--
-- Name: unidad_medica uq_unidad_tipo; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT uq_unidad_tipo UNIQUE (id_hospital, tipo_unidad);


--
-- Name: ix_agendamiento_quirurgico_id_medico_cirujano; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_agendamiento_quirurgico_id_medico_cirujano ON public.agendamiento_quirurgico USING btree (id_medico_cirujano);


--
-- Name: ix_agendamiento_quirurgico_id_paciente; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_agendamiento_quirurgico_id_paciente ON public.agendamiento_quirurgico USING btree (id_paciente);


--
-- Name: ix_agendamiento_quirurgico_id_quirofano_solicitado; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_agendamiento_quirurgico_id_quirofano_solicitado ON public.agendamiento_quirurgico USING btree (id_quirofano_solicitado);


--
-- Name: ix_agendamiento_quirurgico_id_tipo_anestesia; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_agendamiento_quirurgico_id_tipo_anestesia ON public.agendamiento_quirurgico USING btree (id_tipo_anestesia);


--
-- Name: ix_agendamiento_quirurgico_id_tipo_cirugia; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_agendamiento_quirurgico_id_tipo_cirugia ON public.agendamiento_quirurgico USING btree (id_tipo_cirugia);


--
-- Name: ix_calificacion_id_consulta; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_calificacion_id_consulta ON public.calificacion USING btree (id_consulta);


--
-- Name: ix_calificacion_id_encargado; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_calificacion_id_encargado ON public.calificacion USING btree (id_encargado);


--
-- Name: ix_calificacion_id_enfermero; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_calificacion_id_enfermero ON public.calificacion USING btree (id_enfermero);


--
-- Name: ix_calificacion_id_hospital; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_calificacion_id_hospital ON public.calificacion USING btree (id_hospital);


--
-- Name: ix_calificacion_id_medico; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_calificacion_id_medico ON public.calificacion USING btree (id_medico);


--
-- Name: ix_calificacion_id_paciente; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_calificacion_id_paciente ON public.calificacion USING btree (id_paciente);


--
-- Name: ix_chequeo_preanestesico_id_medico_anestesista; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_chequeo_preanestesico_id_medico_anestesista ON public.chequeo_preanestesico USING btree (id_medico_anestesista);


--
-- Name: ix_chequeo_preanestesico_id_medico_clasifica; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_chequeo_preanestesico_id_medico_clasifica ON public.chequeo_preanestesico USING btree (id_medico_clasifica);


--
-- Name: ix_cirugia_fecha_hora_inicio; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_cirugia_fecha_hora_inicio ON public.cirugia USING btree (fecha_hora_inicio);


--
-- Name: ix_cirugia_id_ingreso; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_cirugia_id_ingreso ON public.cirugia USING btree (id_ingreso);


--
-- Name: ix_cirugia_id_quirofano; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_cirugia_id_quirofano ON public.cirugia USING btree (id_quirofano);


--
-- Name: ix_cirugia_insumo_id_insumo; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_cirugia_insumo_id_insumo ON public.cirugia_insumo USING btree (id_insumo);


--
-- Name: ix_cirugia_personal_id_enfermero; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_cirugia_personal_id_enfermero ON public.cirugia_personal USING btree (id_enfermero);


--
-- Name: ix_cirugia_personal_id_medico; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_cirugia_personal_id_medico ON public.cirugia_personal USING btree (id_medico);


--
-- Name: ix_cirugia_personal_id_rol; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_cirugia_personal_id_rol ON public.cirugia_personal USING btree (id_rol);


--
-- Name: ix_cita_fecha_hora; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_cita_fecha_hora ON public.cita USING btree (fecha_hora);


--
-- Name: ix_cita_id_medico; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_cita_id_medico ON public.cita USING btree (id_medico);


--
-- Name: ix_cita_id_paciente; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_cita_id_paciente ON public.cita USING btree (id_paciente);


--
-- Name: ix_consentimiento_informado_id_medico; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_consentimiento_informado_id_medico ON public.consentimiento_informado USING btree (id_medico);


--
-- Name: ix_consulta_id_diagnostico; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_consulta_id_diagnostico ON public.consulta USING btree (id_diagnostico);


--
-- Name: ix_documentacion_etapa_id_enfermero; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_documentacion_etapa_id_enfermero ON public.documentacion_etapa USING btree (id_enfermero);


--
-- Name: ix_egreso_diagnostico_id_diagnostico; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_egreso_diagnostico_id_diagnostico ON public.egreso_diagnostico USING btree (id_diagnostico);


--
-- Name: ix_egreso_fecha_hora; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_egreso_fecha_hora ON public.egreso USING btree (fecha_hora_egreso);


--
-- Name: ix_egreso_id_diagnostico_principal; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_egreso_id_diagnostico_principal ON public.egreso USING btree (id_diagnostico_principal);


--
-- Name: ix_egreso_id_medico; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_egreso_id_medico ON public.egreso USING btree (id_medico);


--
-- Name: ix_encargado_id_municipio; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_encargado_id_municipio ON public.encargado USING btree (id_municipio);


--
-- Name: ix_enfermero_id_hospital; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_enfermero_id_hospital ON public.enfermero USING btree (id_hospital);


--
-- Name: ix_factura_fecha_emision; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_factura_fecha_emision ON public.factura USING btree (fecha_emision);


--
-- Name: ix_historia_clinica_id_medico; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_historia_clinica_id_medico ON public.historia_clinica USING btree (id_medico);


--
-- Name: ix_hospital_id_municipio; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_hospital_id_municipio ON public.hospital USING btree (id_municipio);


--
-- Name: ix_hospitalizacion_insumo_id_insumo; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_hospitalizacion_insumo_id_insumo ON public.hospitalizacion_insumo USING btree (id_insumo);


--
-- Name: ix_ingreso_fecha_hora; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_ingreso_fecha_hora ON public.ingreso USING btree (fecha_hora_ingreso);


--
-- Name: ix_ingreso_id_camilla; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_ingreso_id_camilla ON public.ingreso USING btree (id_camilla);


--
-- Name: ix_ingreso_id_medico_encargado; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_ingreso_id_medico_encargado ON public.ingreso USING btree (id_medico_encargado);


--
-- Name: ix_ingreso_id_paciente; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_ingreso_id_paciente ON public.ingreso USING btree (id_paciente);


--
-- Name: ix_ingreso_id_quirofano; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_ingreso_id_quirofano ON public.ingreso USING btree (id_quirofano);


--
-- Name: ix_ingreso_id_servicio; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_ingreso_id_servicio ON public.ingreso USING btree (id_servicio);


--
-- Name: ix_ingreso_id_turno; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_ingreso_id_turno ON public.ingreso USING btree (id_turno);


--
-- Name: ix_ingreso_id_unidad; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_ingreso_id_unidad ON public.ingreso USING btree (id_unidad);


--
-- Name: ix_institucion_externa_id_municipio; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_institucion_externa_id_municipio ON public.institucion_externa USING btree (id_municipio);


--
-- Name: ix_medico_id_especialidad; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_medico_id_especialidad ON public.medico USING btree (id_especialidad);


--
-- Name: ix_medico_id_hospital; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_medico_id_hospital ON public.medico USING btree (id_hospital);


--
-- Name: ix_medico_id_medico_superior; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_medico_id_medico_superior ON public.medico USING btree (id_medico_superior);


--
-- Name: ix_medico_id_municipio; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_medico_id_municipio ON public.medico USING btree (id_municipio);


--
-- Name: ix_paciente_encargado_id_encargado; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_paciente_encargado_id_encargado ON public.paciente_encargado USING btree (id_encargado);


--
-- Name: ix_paciente_encargado_id_parentesco; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_paciente_encargado_id_parentesco ON public.paciente_encargado USING btree (id_parentesco);


--
-- Name: ix_paciente_id_estado_civil; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_paciente_id_estado_civil ON public.paciente USING btree (id_estado_civil);


--
-- Name: ix_paciente_id_municipio; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_paciente_id_municipio ON public.paciente USING btree (id_municipio);


--
-- Name: ix_pago_fecha_pago; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_pago_fecha_pago ON public.pago USING btree (fecha_pago);


--
-- Name: ix_pago_id_metodo_pago; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_pago_id_metodo_pago ON public.pago USING btree (id_metodo_pago);


--
-- Name: ix_receta_medicamento_id_medicamento; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_receta_medicamento_id_medicamento ON public.receta_medicamento USING btree (id_medicamento);


--
-- Name: ix_registro_procedimiento_id_aspecto; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_registro_procedimiento_id_aspecto ON public.registro_procedimiento USING btree (id_aspecto);


--
-- Name: ix_registro_procedimiento_id_enfermero; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_registro_procedimiento_id_enfermero ON public.registro_procedimiento USING btree (id_enfermero);


--
-- Name: ix_requerimiento_equipo_id_equipo; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_requerimiento_equipo_id_equipo ON public.requerimiento_equipo USING btree (id_equipo);


--
-- Name: ix_requerimiento_instrumento_id_instrumento; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_requerimiento_instrumento_id_instrumento ON public.requerimiento_instrumento USING btree (id_instrumento);


--
-- Name: ix_requerimiento_insumo_id_insumo; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_requerimiento_insumo_id_insumo ON public.requerimiento_insumo USING btree (id_insumo);


--
-- Name: ix_tipo_cirugia_id_especialidad; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_tipo_cirugia_id_especialidad ON public.tipo_cirugia USING btree (id_especialidad);


--
-- Name: ix_traslado_id_consulta; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_traslado_id_consulta ON public.traslado USING btree (id_consulta);


--
-- Name: ix_traslado_id_ingreso; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_traslado_id_ingreso ON public.traslado USING btree (id_ingreso);


--
-- Name: ix_traslado_id_institucion_destino; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_traslado_id_institucion_destino ON public.traslado USING btree (id_institucion_destino);


--
-- Name: ix_traslado_id_medico_indica; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_traslado_id_medico_indica ON public.traslado USING btree (id_medico_indica);


--
-- Name: ix_traslado_id_unidad_destino; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_traslado_id_unidad_destino ON public.traslado USING btree (id_unidad_destino);


--
-- Name: ix_traslado_id_unidad_origen; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_traslado_id_unidad_origen ON public.traslado USING btree (id_unidad_origen);


--
-- Name: ix_turno_medico_id_medico; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_turno_medico_id_medico ON public.turno_medico USING btree (id_medico);


--
-- Name: uq_medico_director_hospital; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX uq_medico_director_hospital ON public.medico USING btree (id_hospital) WHERE ((cargo)::text = 'director_medico'::text);


--
-- Name: enfermero trg_01_enfermero_desde_personal; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_01_enfermero_desde_personal BEFORE INSERT OR UPDATE ON public.enfermero FOR EACH ROW EXECUTE FUNCTION public.fn_enfermero_desde_personal();


--
-- Name: medico trg_01_medico_desde_personal; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_01_medico_desde_personal BEFORE INSERT OR UPDATE ON public.medico FOR EACH ROW EXECUTE FUNCTION public.fn_medico_desde_personal();


--
-- Name: medico trg_02_medico_jerarquia; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_02_medico_jerarquia BEFORE INSERT OR UPDATE ON public.medico FOR EACH ROW EXECUTE FUNCTION public.fn_medico_jerarquia();


--
-- Name: medico trg_auditar_medico; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_auditar_medico AFTER UPDATE OF id_especialidad ON public.medico FOR EACH ROW WHEN ((new.id_especialidad IS DISTINCT FROM old.id_especialidad)) EXECUTE FUNCTION public.fn_auditar_medico();


--
-- Name: personal trg_auditar_personal; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_auditar_personal AFTER UPDATE OF salario, nivel_acceso ON public.personal FOR EACH ROW EXECUTE FUNCTION public.fn_auditar_personal();


--
-- Name: calificacion trg_calificacion_consulta; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_calificacion_consulta BEFORE INSERT OR UPDATE ON public.calificacion FOR EACH ROW EXECUTE FUNCTION public.fn_calificacion_consulta();


--
-- Name: camilla trg_camilla_unidad; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_camilla_unidad BEFORE INSERT OR UPDATE ON public.camilla FOR EACH ROW EXECUTE FUNCTION public.fn_camilla_unidad();


--
-- Name: chequeo_preanestesico trg_chequeo_aprobado; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_chequeo_aprobado BEFORE INSERT OR UPDATE OF id_agendamiento ON public.chequeo_preanestesico FOR EACH ROW EXECUTE FUNCTION public.fn_agendamiento_aprobado();


--
-- Name: cirugia trg_cirugia_aprobada; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_cirugia_aprobada BEFORE INSERT OR UPDATE OF id_agendamiento ON public.cirugia FOR EACH ROW EXECUTE FUNCTION public.fn_agendamiento_aprobado();


--
-- Name: cirugia_personal trg_cirugia_personal_rol; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_cirugia_personal_rol BEFORE INSERT OR UPDATE ON public.cirugia_personal FOR EACH ROW EXECUTE FUNCTION public.fn_cirugia_personal_rol();


--
-- Name: consentimiento_informado trg_consentimiento_aprobado; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_consentimiento_aprobado BEFORE INSERT OR UPDATE OF id_agendamiento ON public.consentimiento_informado FOR EACH ROW EXECUTE FUNCTION public.fn_agendamiento_aprobado();


--
-- Name: consulta trg_consulta_cita; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_consulta_cita BEFORE INSERT OR UPDATE OF id_cita ON public.consulta FOR EACH ROW EXECUTE FUNCTION public.fn_consulta_cita();


--
-- Name: egreso trg_egreso_fecha; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_egreso_fecha BEFORE INSERT OR UPDATE ON public.egreso FOR EACH ROW EXECUTE FUNCTION public.fn_egreso_fecha();


--
-- Name: hospitalizacion_insumo trg_hosp_insumo_ingreso; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_hosp_insumo_ingreso BEFORE INSERT OR UPDATE ON public.hospitalizacion_insumo FOR EACH ROW EXECUTE FUNCTION public.fn_hosp_insumo_ingreso();


--
-- Name: ingreso trg_ingreso_consistencia; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_ingreso_consistencia BEFORE INSERT OR UPDATE ON public.ingreso FOR EACH ROW EXECUTE FUNCTION public.fn_ingreso_consistencia();


--
-- Name: paciente trg_paciente_nacimiento; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_paciente_nacimiento BEFORE INSERT OR UPDATE OF fecha_nacimiento ON public.paciente FOR EACH ROW EXECUTE FUNCTION public.fn_paciente_nacimiento();


--
-- Name: pago trg_pago_plan; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_pago_plan BEFORE INSERT OR UPDATE ON public.pago FOR EACH ROW EXECUTE FUNCTION public.fn_pago_plan();


--
-- Name: personal trg_personal_a_subtipo; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_personal_a_subtipo AFTER UPDATE ON public.personal FOR EACH ROW EXECUTE FUNCTION public.fn_personal_a_subtipo();


--
-- Name: personal trg_personal_completo; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE CONSTRAINT TRIGGER trg_personal_completo AFTER INSERT ON public.personal DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.fn_personal_completo();


--
-- Name: quirofano trg_quirofano_unidad; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_quirofano_unidad BEFORE INSERT OR UPDATE ON public.quirofano FOR EACH ROW EXECUTE FUNCTION public.fn_quirofano_unidad();


--
-- Name: receta trg_receta_proxima_cita; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_receta_proxima_cita BEFORE INSERT OR UPDATE ON public.receta FOR EACH ROW EXECUTE FUNCTION public.fn_receta_proxima_cita();


--
-- Name: registro_procedimiento trg_registro_resultado; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_registro_resultado BEFORE INSERT OR UPDATE ON public.registro_procedimiento FOR EACH ROW EXECUTE FUNCTION public.fn_registro_resultado();


--
-- Name: traslado trg_traslado_origen; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_traslado_origen BEFORE INSERT OR UPDATE ON public.traslado FOR EACH ROW EXECUTE FUNCTION public.fn_traslado_origen();


--
-- Name: turno_medico trg_turno_medico_hospital; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_turno_medico_hospital BEFORE INSERT OR UPDATE ON public.turno_medico FOR EACH ROW EXECUTE FUNCTION public.fn_turno_medico_hospital();


--
-- Name: turno_emergencia trg_turno_unidad; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_turno_unidad BEFORE INSERT OR UPDATE ON public.turno_emergencia FOR EACH ROW EXECUTE FUNCTION public.fn_turno_unidad();


--
-- Name: cirugia cirugia_codigo_cie10_fkey; Type: FK CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.cirugia
    ADD CONSTRAINT cirugia_codigo_cie10_fkey FOREIGN KEY (codigo_cie10) REFERENCES propuesta_bloque_e.diagnostico(codigo_cie10) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia cirugia_id_cirujano_fkey; Type: FK CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.cirugia
    ADD CONSTRAINT cirugia_id_cirujano_fkey FOREIGN KEY (id_cirujano) REFERENCES propuesta_bloque_e.cirujano(id_cirujano) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia cirugia_id_paciente_fkey; Type: FK CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.cirugia
    ADD CONSTRAINT cirugia_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES propuesta_bloque_e.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_insumo cirugia_insumo_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES propuesta_bloque_e.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_insumo cirugia_insumo_id_insumo_fkey; Type: FK CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_id_insumo_fkey FOREIGN KEY (id_insumo) REFERENCES propuesta_bloque_e.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirujano cirujano_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: propuesta_bloque_e; Owner: admin
--

ALTER TABLE ONLY propuesta_bloque_e.cirujano
    ADD CONSTRAINT cirujano_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES propuesta_bloque_e.especialidad(id_especialidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_id_medico_cirujano_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_id_medico_cirujano_fkey FOREIGN KEY (id_medico_cirujano) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_id_quirofano_solicitado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_id_quirofano_solicitado_fkey FOREIGN KEY (id_quirofano_solicitado) REFERENCES public.quirofano(id_quirofano) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_id_tipo_anestesia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_id_tipo_anestesia_fkey FOREIGN KEY (id_tipo_anestesia) REFERENCES public.tipo_anestesia(id_tipo_anestesia) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: agendamiento_quirurgico agendamiento_quirurgico_id_tipo_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agendamiento_quirurgico
    ADD CONSTRAINT agendamiento_quirurgico_id_tipo_cirugia_fkey FOREIGN KEY (id_tipo_cirugia) REFERENCES public.tipo_cirugia(id_tipo_cirugia) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_consulta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_consulta_fkey FOREIGN KEY (id_consulta) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_encargado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_encargado_fkey FOREIGN KEY (id_encargado) REFERENCES public.encargado(id_encargado) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_enfermero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_enfermero_fkey FOREIGN KEY (id_enfermero) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_hospital_fkey FOREIGN KEY (id_hospital) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion calificacion_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.calificacion
    ADD CONSTRAINT calificacion_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: camilla camilla_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.camilla
    ADD CONSTRAINT camilla_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: chequeo_preanestesico chequeo_preanestesico_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: chequeo_preanestesico chequeo_preanestesico_id_medico_anestesista_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_id_medico_anestesista_fkey FOREIGN KEY (id_medico_anestesista) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: chequeo_preanestesico chequeo_preanestesico_id_medico_clasifica_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.chequeo_preanestesico
    ADD CONSTRAINT chequeo_preanestesico_id_medico_clasifica_fkey FOREIGN KEY (id_medico_clasifica) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia cirugia_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia cirugia_id_ingreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_id_ingreso_fkey FOREIGN KEY (id_ingreso) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia cirugia_id_quirofano_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_id_quirofano_fkey FOREIGN KEY (id_quirofano) REFERENCES public.quirofano(id_quirofano) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_insumo cirugia_insumo_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_insumo cirugia_insumo_id_insumo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia_insumo
    ADD CONSTRAINT cirugia_insumo_id_insumo_fkey FOREIGN KEY (id_insumo) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_personal cirugia_personal_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_personal cirugia_personal_id_enfermero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_id_enfermero_fkey FOREIGN KEY (id_enfermero) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_personal cirugia_personal_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_personal cirugia_personal_id_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cirugia_personal
    ADD CONSTRAINT cirugia_personal_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES public.rol_quirurgico(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cita cita_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cita cita_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consentimiento_informado consentimiento_informado_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consentimiento_informado consentimiento_informado_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.consentimiento_informado
    ADD CONSTRAINT consentimiento_informado_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consulta consulta_id_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_id_cita_fkey FOREIGN KEY (id_cita) REFERENCES public.cita(id_cita) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consulta consulta_id_diagnostico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_id_diagnostico_fkey FOREIGN KEY (id_diagnostico) REFERENCES public.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: documentacion_etapa documentacion_etapa_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.documentacion_etapa
    ADD CONSTRAINT documentacion_etapa_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documentacion_etapa documentacion_etapa_id_enfermero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.documentacion_etapa
    ADD CONSTRAINT documentacion_etapa_id_enfermero_fkey FOREIGN KEY (id_enfermero) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso_diagnostico egreso_diagnostico_id_diagnostico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.egreso_diagnostico
    ADD CONSTRAINT egreso_diagnostico_id_diagnostico_fkey FOREIGN KEY (id_diagnostico) REFERENCES public.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso_diagnostico egreso_diagnostico_id_egreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.egreso_diagnostico
    ADD CONSTRAINT egreso_diagnostico_id_egreso_fkey FOREIGN KEY (id_egreso) REFERENCES public.egreso(id_egreso) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: egreso egreso_id_diagnostico_principal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_id_diagnostico_principal_fkey FOREIGN KEY (id_diagnostico_principal) REFERENCES public.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso egreso_id_ingreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_id_ingreso_fkey FOREIGN KEY (id_ingreso) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso egreso_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.egreso
    ADD CONSTRAINT egreso_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: encargado encargado_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.encargado
    ADD CONSTRAINT encargado_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: enfermero enfermero_id_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT enfermero_id_hospital_fkey FOREIGN KEY (id_hospital) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura factura_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura factura_id_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_cita_fkey FOREIGN KEY (id_cita) REFERENCES public.cita(id_cita) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura factura_id_ingreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_ingreso_fkey FOREIGN KEY (id_ingreso) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: enfermero fk_enfermero_personal; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.enfermero
    ADD CONSTRAINT fk_enfermero_personal FOREIGN KEY (id_enfermero, tipo_personal) REFERENCES public.personal(id_personal, tipo_personal) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: medico fk_medico_personal; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT fk_medico_personal FOREIGN KEY (id_medico, tipo_personal) REFERENCES public.personal(id_personal, tipo_personal) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: historia_clinica historia_clinica_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: historia_clinica historia_clinica_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.historia_clinica
    ADD CONSTRAINT historia_clinica_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: hospital hospital_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_id_ingreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_id_ingreso_fkey FOREIGN KEY (id_ingreso) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hospitalizacion_insumo hospitalizacion_insumo_id_insumo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.hospitalizacion_insumo
    ADD CONSTRAINT hospitalizacion_insumo_id_insumo_fkey FOREIGN KEY (id_insumo) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_camilla_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_camilla_fkey FOREIGN KEY (id_camilla) REFERENCES public.camilla(id_camilla) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_medico_encargado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_medico_encargado_fkey FOREIGN KEY (id_medico_encargado) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_quirofano_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_quirofano_fkey FOREIGN KEY (id_quirofano) REFERENCES public.quirofano(id_quirofano) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES public.servicio_atencion(id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_turno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_turno_fkey FOREIGN KEY (id_turno) REFERENCES public.turno_emergencia(id_turno) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso ingreso_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ingreso
    ADD CONSTRAINT ingreso_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: institucion_externa institucion_externa_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.institucion_externa
    ADD CONSTRAINT institucion_externa_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: medico medico_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: medico medico_id_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_id_hospital_fkey FOREIGN KEY (id_hospital) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: medico medico_id_medico_superior_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_id_medico_superior_fkey FOREIGN KEY (id_medico_superior) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: medico medico_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: municipio municipio_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.departamento(id_departamento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: paciente_encargado paciente_encargado_id_encargado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_id_encargado_fkey FOREIGN KEY (id_encargado) REFERENCES public.encargado(id_encargado) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente_encargado paciente_encargado_id_paciente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_id_paciente_fkey FOREIGN KEY (id_paciente) REFERENCES public.paciente(id_paciente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente_encargado paciente_encargado_id_parentesco_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.paciente_encargado
    ADD CONSTRAINT paciente_encargado_id_parentesco_fkey FOREIGN KEY (id_parentesco) REFERENCES public.parentesco(id_parentesco) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: paciente paciente_id_estado_civil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_id_estado_civil_fkey FOREIGN KEY (id_estado_civil) REFERENCES public.estado_civil(id_estado_civil) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: paciente paciente_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pago pago_id_factura_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_id_factura_fkey FOREIGN KEY (id_factura) REFERENCES public.factura(id_factura) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pago pago_id_metodo_pago_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_id_metodo_pago_fkey FOREIGN KEY (id_metodo_pago) REFERENCES public.metodo_pago(id_metodo_pago) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: personal personal_id_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT personal_id_hospital_fkey FOREIGN KEY (id_hospital) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: personal personal_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT personal_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: quirofano quirofano_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.quirofano
    ADD CONSTRAINT quirofano_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: receta receta_id_consulta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_id_consulta_fkey FOREIGN KEY (id_consulta) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: receta_medicamento receta_medicamento_id_medicamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_id_medicamento_fkey FOREIGN KEY (id_medicamento) REFERENCES public.medicamento(id_medicamento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: receta_medicamento receta_medicamento_id_receta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.receta_medicamento
    ADD CONSTRAINT receta_medicamento_id_receta_fkey FOREIGN KEY (id_receta) REFERENCES public.receta(id_receta) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro_procedimiento registro_procedimiento_id_aspecto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_id_aspecto_fkey FOREIGN KEY (id_aspecto) REFERENCES public.aspecto_quirurgico(id_aspecto) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: registro_procedimiento registro_procedimiento_id_cirugia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_id_cirugia_fkey FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registro_procedimiento registro_procedimiento_id_enfermero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.registro_procedimiento
    ADD CONSTRAINT registro_procedimiento_id_enfermero_fkey FOREIGN KEY (id_enfermero) REFERENCES public.enfermero(id_enfermero) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: requerimiento_equipo requerimiento_equipo_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.requerimiento_equipo
    ADD CONSTRAINT requerimiento_equipo_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: requerimiento_equipo requerimiento_equipo_id_equipo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.requerimiento_equipo
    ADD CONSTRAINT requerimiento_equipo_id_equipo_fkey FOREIGN KEY (id_equipo) REFERENCES public.equipo(id_equipo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: requerimiento_instrumento requerimiento_instrumento_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.requerimiento_instrumento
    ADD CONSTRAINT requerimiento_instrumento_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: requerimiento_instrumento requerimiento_instrumento_id_instrumento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.requerimiento_instrumento
    ADD CONSTRAINT requerimiento_instrumento_id_instrumento_fkey FOREIGN KEY (id_instrumento) REFERENCES public.instrumento(id_instrumento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: requerimiento_insumo requerimiento_insumo_id_agendamiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.requerimiento_insumo
    ADD CONSTRAINT requerimiento_insumo_id_agendamiento_fkey FOREIGN KEY (id_agendamiento) REFERENCES public.agendamiento_quirurgico(id_agendamiento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: requerimiento_insumo requerimiento_insumo_id_insumo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.requerimiento_insumo
    ADD CONSTRAINT requerimiento_insumo_id_insumo_fkey FOREIGN KEY (id_insumo) REFERENCES public.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: servicio_atencion servicio_atencion_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.servicio_atencion
    ADD CONSTRAINT servicio_atencion_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tipo_cirugia tipo_cirugia_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tipo_cirugia
    ADD CONSTRAINT tipo_cirugia_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_consulta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_consulta_fkey FOREIGN KEY (id_consulta) REFERENCES public.consulta(id_consulta) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_ingreso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_ingreso_fkey FOREIGN KEY (id_ingreso) REFERENCES public.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_institucion_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_institucion_destino_fkey FOREIGN KEY (id_institucion_destino) REFERENCES public.institucion_externa(id_institucion) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_medico_indica_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_medico_indica_fkey FOREIGN KEY (id_medico_indica) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_unidad_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_unidad_destino_fkey FOREIGN KEY (id_unidad_destino) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado traslado_id_unidad_origen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.traslado
    ADD CONSTRAINT traslado_id_unidad_origen_fkey FOREIGN KEY (id_unidad_origen) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: turno_emergencia turno_emergencia_id_unidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.turno_emergencia
    ADD CONSTRAINT turno_emergencia_id_unidad_fkey FOREIGN KEY (id_unidad) REFERENCES public.unidad_medica(id_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: turno_medico turno_medico_id_medico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.turno_medico
    ADD CONSTRAINT turno_medico_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES public.medico(id_medico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: turno_medico turno_medico_id_turno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.turno_medico
    ADD CONSTRAINT turno_medico_id_turno_fkey FOREIGN KEY (id_turno) REFERENCES public.turno_emergencia(id_turno) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: unidad_medica unidad_medica_id_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.unidad_medica
    ADD CONSTRAINT unidad_medica_id_hospital_fkey FOREIGN KEY (id_hospital) REFERENCES public.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA propuesta_bloque_e; Type: ACL; Schema: -; Owner: admin
--

GRANT USAGE ON SCHEMA propuesta_bloque_e TO visor;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO admin;
GRANT USAGE ON SCHEMA public TO visor;
GRANT ALL ON SCHEMA public TO dueno_auditoria;


--
-- Name: FUNCTION fn_agendamiento_aprobado(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_agendamiento_aprobado() FROM PUBLIC;


--
-- Name: FUNCTION fn_auditar_medico(); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_auditar_medico() TO visor;


--
-- Name: FUNCTION fn_auditar_personal(); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_auditar_personal() TO visor;


--
-- Name: FUNCTION fn_cadena_mando(p_id_medico integer); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_cadena_mando(p_id_medico integer) TO visor;


--
-- Name: FUNCTION fn_calificacion_consulta(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_calificacion_consulta() FROM PUBLIC;


--
-- Name: FUNCTION fn_camilla_unidad(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_camilla_unidad() FROM PUBLIC;


--
-- Name: FUNCTION fn_cirugia_personal_rol(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_cirugia_personal_rol() FROM PUBLIC;


--
-- Name: FUNCTION fn_consulta_cita(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_consulta_cita() FROM PUBLIC;


--
-- Name: FUNCTION fn_edad(p_fecha_nacimiento date, p_fecha date); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_edad(p_fecha_nacimiento date, p_fecha date) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_edad(p_fecha_nacimiento date, p_fecha date) TO visor;


--
-- Name: FUNCTION fn_egreso_fecha(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_egreso_fecha() FROM PUBLIC;


--
-- Name: FUNCTION fn_enfermero_desde_personal(); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_enfermero_desde_personal() TO visor;


--
-- Name: FUNCTION fn_hosp_insumo_ingreso(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_hosp_insumo_ingreso() FROM PUBLIC;


--
-- Name: FUNCTION fn_ingreso_consistencia(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_ingreso_consistencia() FROM PUBLIC;


--
-- Name: FUNCTION fn_medico_desde_personal(); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_medico_desde_personal() TO visor;


--
-- Name: FUNCTION fn_medico_jerarquia(); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_medico_jerarquia() TO visor;


--
-- Name: FUNCTION fn_objetivo_01(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_01(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_02(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_02(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_03(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_03(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_04(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_04(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_05(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_05(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_06(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_06(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_07(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_07(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_08(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_08(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_09(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_09(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_10(); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_10() TO visor;


--
-- Name: FUNCTION fn_objetivo_11(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_11(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_12(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_12(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_13(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_13(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_14(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_14(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_17_correlacionada(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_17_correlacionada(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_17_ventana(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_17_ventana(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_objetivo_18(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_objetivo_18(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_paciente_nacimiento(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_paciente_nacimiento() FROM PUBLIC;


--
-- Name: FUNCTION fn_pago_plan(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_pago_plan() FROM PUBLIC;


--
-- Name: FUNCTION fn_personal_a_subtipo(); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_personal_a_subtipo() TO visor;


--
-- Name: FUNCTION fn_personal_completo(); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_personal_completo() TO visor;


--
-- Name: FUNCTION fn_promedio_medico(p_desde date, p_hasta date); Type: ACL; Schema: public; Owner: admin
--

GRANT ALL ON FUNCTION public.fn_promedio_medico(p_desde date, p_hasta date) TO visor;


--
-- Name: FUNCTION fn_quirofano_unidad(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_quirofano_unidad() FROM PUBLIC;


--
-- Name: FUNCTION fn_receta_proxima_cita(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_receta_proxima_cita() FROM PUBLIC;


--
-- Name: FUNCTION fn_registrar_auditoria(p_usuario_bd text, p_tabla text, p_id integer, p_campo text, p_anterior text, p_nuevo text); Type: ACL; Schema: public; Owner: dueno_auditoria
--

REVOKE ALL ON FUNCTION public.fn_registrar_auditoria(p_usuario_bd text, p_tabla text, p_id integer, p_campo text, p_anterior text, p_nuevo text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_registrar_auditoria(p_usuario_bd text, p_tabla text, p_id integer, p_campo text, p_anterior text, p_nuevo text) TO admin;


--
-- Name: FUNCTION fn_registro_resultado(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_registro_resultado() FROM PUBLIC;


--
-- Name: FUNCTION fn_tipo_unidad(p_id_unidad integer); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_tipo_unidad(p_id_unidad integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_tipo_unidad(p_id_unidad integer) TO visor;


--
-- Name: FUNCTION fn_traslado_origen(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_traslado_origen() FROM PUBLIC;


--
-- Name: FUNCTION fn_turno_medico_hospital(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_turno_medico_hospital() FROM PUBLIC;


--
-- Name: FUNCTION fn_turno_unidad(); Type: ACL; Schema: public; Owner: admin
--

REVOKE ALL ON FUNCTION public.fn_turno_unidad() FROM PUBLIC;


--
-- Name: TABLE cirugia; Type: ACL; Schema: propuesta_bloque_e; Owner: admin
--

GRANT SELECT ON TABLE propuesta_bloque_e.cirugia TO visor;


--
-- Name: TABLE cirugia_insumo; Type: ACL; Schema: propuesta_bloque_e; Owner: admin
--

GRANT SELECT ON TABLE propuesta_bloque_e.cirugia_insumo TO visor;


--
-- Name: TABLE cirujano; Type: ACL; Schema: propuesta_bloque_e; Owner: admin
--

GRANT SELECT ON TABLE propuesta_bloque_e.cirujano TO visor;


--
-- Name: TABLE diagnostico; Type: ACL; Schema: propuesta_bloque_e; Owner: admin
--

GRANT SELECT ON TABLE propuesta_bloque_e.diagnostico TO visor;


--
-- Name: TABLE especialidad; Type: ACL; Schema: propuesta_bloque_e; Owner: admin
--

GRANT SELECT ON TABLE propuesta_bloque_e.especialidad TO visor;


--
-- Name: TABLE insumo; Type: ACL; Schema: propuesta_bloque_e; Owner: admin
--

GRANT SELECT ON TABLE propuesta_bloque_e.insumo TO visor;


--
-- Name: TABLE paciente; Type: ACL; Schema: propuesta_bloque_e; Owner: admin
--

GRANT SELECT ON TABLE propuesta_bloque_e.paciente TO visor;


--
-- Name: TABLE reporte_cirugia; Type: ACL; Schema: propuesta_bloque_e; Owner: admin
--

GRANT SELECT ON TABLE propuesta_bloque_e.reporte_cirugia TO visor;


--
-- Name: TABLE agendamiento_quirurgico; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.agendamiento_quirurgico TO visor;


--
-- Name: TABLE aspecto_quirurgico; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.aspecto_quirurgico TO visor;


--
-- Name: TABLE auditoria_personal; Type: ACL; Schema: public; Owner: dueno_auditoria
--

GRANT SELECT ON TABLE public.auditoria_personal TO admin;
GRANT SELECT ON TABLE public.auditoria_personal TO visor;


--
-- Name: SEQUENCE auditoria_personal_id_auditoria_seq; Type: ACL; Schema: public; Owner: dueno_auditoria
--

GRANT ALL ON SEQUENCE public.auditoria_personal_id_auditoria_seq TO admin;


--
-- Name: TABLE calificacion; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.calificacion TO visor;


--
-- Name: TABLE camilla; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.camilla TO visor;


--
-- Name: TABLE chequeo_preanestesico; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.chequeo_preanestesico TO visor;


--
-- Name: TABLE cirugia; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.cirugia TO visor;


--
-- Name: TABLE cirugia_insumo; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.cirugia_insumo TO visor;


--
-- Name: TABLE cirugia_personal; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.cirugia_personal TO visor;


--
-- Name: TABLE cita; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.cita TO visor;


--
-- Name: TABLE consentimiento_informado; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.consentimiento_informado TO visor;


--
-- Name: TABLE consulta; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.consulta TO visor;


--
-- Name: TABLE departamento; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.departamento TO visor;


--
-- Name: TABLE diagnostico; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.diagnostico TO visor;


--
-- Name: TABLE documentacion_etapa; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.documentacion_etapa TO visor;


--
-- Name: TABLE egreso; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.egreso TO visor;


--
-- Name: TABLE egreso_diagnostico; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.egreso_diagnostico TO visor;


--
-- Name: TABLE encargado; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.encargado TO visor;


--
-- Name: TABLE enfermero; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.enfermero TO visor;


--
-- Name: TABLE equipo; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.equipo TO visor;


--
-- Name: TABLE especialidad; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.especialidad TO visor;


--
-- Name: TABLE estado_civil; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.estado_civil TO visor;


--
-- Name: TABLE factura; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.factura TO visor;


--
-- Name: TABLE historia_clinica; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.historia_clinica TO visor;


--
-- Name: TABLE hospital; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.hospital TO visor;


--
-- Name: TABLE hospitalizacion_insumo; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.hospitalizacion_insumo TO visor;


--
-- Name: TABLE ingreso; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.ingreso TO visor;


--
-- Name: TABLE institucion_externa; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.institucion_externa TO visor;


--
-- Name: TABLE instrumento; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.instrumento TO visor;


--
-- Name: TABLE insumo; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.insumo TO visor;


--
-- Name: TABLE medicamento; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.medicamento TO visor;


--
-- Name: TABLE medico; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.medico TO visor;


--
-- Name: TABLE metodo_pago; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.metodo_pago TO visor;


--
-- Name: TABLE municipio; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.municipio TO visor;


--
-- Name: TABLE paciente; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.paciente TO visor;


--
-- Name: TABLE paciente_encargado; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.paciente_encargado TO visor;


--
-- Name: TABLE pago; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.pago TO visor;


--
-- Name: TABLE parentesco; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.parentesco TO visor;


--
-- Name: TABLE personal; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.personal TO visor;


--
-- Name: TABLE quirofano; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.quirofano TO visor;


--
-- Name: TABLE receta; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.receta TO visor;


--
-- Name: TABLE receta_medicamento; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.receta_medicamento TO visor;


--
-- Name: TABLE registro_procedimiento; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.registro_procedimiento TO visor;


--
-- Name: TABLE requerimiento_equipo; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.requerimiento_equipo TO visor;


--
-- Name: TABLE requerimiento_instrumento; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.requerimiento_instrumento TO visor;


--
-- Name: TABLE requerimiento_insumo; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.requerimiento_insumo TO visor;


--
-- Name: TABLE rol_quirurgico; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.rol_quirurgico TO visor;


--
-- Name: TABLE servicio_atencion; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.servicio_atencion TO visor;


--
-- Name: TABLE tipo_anestesia; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.tipo_anestesia TO visor;


--
-- Name: TABLE tipo_cirugia; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.tipo_cirugia TO visor;


--
-- Name: TABLE traslado; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.traslado TO visor;


--
-- Name: TABLE turno_emergencia; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.turno_emergencia TO visor;


--
-- Name: TABLE turno_medico; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.turno_medico TO visor;


--
-- Name: TABLE unidad_medica; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.unidad_medica TO visor;


--
-- Name: TABLE v_cirugia; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.v_cirugia TO visor;


--
-- Name: TABLE v_consulta; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.v_consulta TO visor;


--
-- Name: TABLE v_estancia; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.v_estancia TO visor;


--
-- Name: TABLE v_factura; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.v_factura TO visor;


--
-- Name: TABLE v_paciente; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT ON TABLE public.v_paciente TO visor;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: hospital
--

ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT ALL ON SEQUENCES TO admin;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO visor;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: hospital
--

ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT ALL ON FUNCTIONS TO admin;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE admin IN SCHEMA public GRANT SELECT ON TABLES TO visor;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: hospital
--

ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT SELECT ON TABLES TO visor;
ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public GRANT ALL ON TABLES TO admin;


--
-- PostgreSQL database dump complete
--

\unrestrict rzQAxmA6FzkGGVLi5ZCH93GYZO07ubAS15Q7Uac1qWFbBt4zEsdYh8IzrHh6Qa0

