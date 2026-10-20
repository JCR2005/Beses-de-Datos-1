-- Proyecto 1 - BD Hospitales de Occidente
-- 13_reglas_negocio.sql : reglas que involucran mas de una tabla
--
-- Un CHECK solo puede ver la fila que se esta guardando. Las reglas que
-- necesitan consultar otra tabla se validan con disparadores BEFORE que
-- rechazan la operacion con un mensaje claro.

set search_path to public;

-- tipo de una unidad medica (Consulta Externa, Emergencias, Cirugía, Hospitalización)
create function fn_tipo_unidad(p_id_unidad integer) returns varchar
language sql stable
as $$
    select tipo_unidad from unidad_medica where id_unidad = p_id_unidad;
$$;

-- ============================================================
-- infraestructura y personal
-- ============================================================

-- las camillas solo existen en emergencias y hospitalizacion
create function fn_camilla_unidad() returns trigger language plpgsql as $$
begin
    if fn_tipo_unidad(new.id_unidad) not in ('Emergencias','Hospitalización') then
        raise exception 'La camilla % debe pertenecer a Emergencias u Hospitalización', new.numero;
    end if;
    return new;
end $$;

create trigger trg_camilla_unidad before insert or update on camilla
    for each row execute function fn_camilla_unidad();

-- los quirofanos solo existen en la unidad de cirugia
create function fn_quirofano_unidad() returns trigger language plpgsql as $$
begin
    if fn_tipo_unidad(new.id_unidad) <> 'Cirugía' then
        raise exception 'El quirófano % debe pertenecer a la unidad de Cirugía', new.numero;
    end if;
    return new;
end $$;

create trigger trg_quirofano_unidad before insert or update on quirofano
    for each row execute function fn_quirofano_unidad();

-- los turnos de 12 horas son de la unidad de emergencias
create function fn_turno_unidad() returns trigger language plpgsql as $$
begin
    if fn_tipo_unidad(new.id_unidad) <> 'Emergencias' then
        raise exception 'El turno debe pertenecer a la unidad de Emergencias';
    end if;
    return new;
end $$;

create trigger trg_turno_unidad before insert or update on turno_emergencia
    for each row execute function fn_turno_unidad();

-- el medico de turno trabaja en el hospital de esa unidad de emergencias
create function fn_turno_medico_hospital() returns trigger language plpgsql as $$
begin
    if (select id_hospital from medico where id_medico = new.id_medico)
       <> (select u.id_hospital from turno_emergencia t
             join unidad_medica u on u.id_unidad = t.id_unidad
            where t.id_turno = new.id_turno) then
        raise exception 'El médico % no pertenece al hospital del turno %', new.id_medico, new.id_turno;
    end if;
    return new;
end $$;

create trigger trg_turno_medico_hospital before insert or update on turno_medico
    for each row execute function fn_turno_medico_hospital();

-- ============================================================
-- pacientes y consulta externa
-- ============================================================

-- la fecha de nacimiento no puede estar en el futuro
create function fn_paciente_nacimiento() returns trigger language plpgsql as $$
begin
    if new.fecha_nacimiento > current_date then
        raise exception 'La fecha de nacimiento % está en el futuro', new.fecha_nacimiento;
    end if;
    return new;
end $$;

create trigger trg_paciente_nacimiento before insert or update of fecha_nacimiento on paciente
    for each row execute function fn_paciente_nacimiento();

-- solo una cita realizada puede tener consulta
create function fn_consulta_cita() returns trigger language plpgsql as $$
begin
    if (select estado from cita where id_cita = new.id_cita) <> 'realizada' then
        raise exception 'La cita % no está realizada; no puede tener consulta', new.id_cita;
    end if;
    return new;
end $$;

create trigger trg_consulta_cita before insert or update of id_cita on consulta
    for each row execute function fn_consulta_cita();

-- la proxima cita de la receta es posterior a la consulta
create function fn_receta_proxima_cita() returns trigger language plpgsql as $$
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

create trigger trg_receta_proxima_cita before insert or update on receta
    for each row execute function fn_receta_proxima_cita();

-- ============================================================
-- fichas de ingreso, egreso y traslado
-- ============================================================

-- el ingreso es a emergencias, cirugia u hospitalizacion, y todo lo asignado es de esa unidad
create function fn_ingreso_consistencia() returns trigger language plpgsql as $$
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

create trigger trg_ingreso_consistencia before insert or update on ingreso
    for each row execute function fn_ingreso_consistencia();

-- el egreso no puede ser anterior al ingreso que cierra
create function fn_egreso_fecha() returns trigger language plpgsql as $$
declare
    v_ingreso timestamptz;
begin
    select fecha_hora_ingreso into v_ingreso from ingreso where id_ingreso = new.id_ingreso;
    if new.fecha_hora_egreso < v_ingreso then
        raise exception 'El egreso (%) es anterior al ingreso (%)', new.fecha_hora_egreso, v_ingreso;
    end if;
    return new;
end $$;

create trigger trg_egreso_fecha before insert or update on egreso
    for each row execute function fn_egreso_fecha();

-- la unidad de origen del traslado es la del ingreso, o consulta externa del hospital del medico
create function fn_traslado_origen() returns trigger language plpgsql as $$
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

create trigger trg_traslado_origen before insert or update on traslado
    for each row execute function fn_traslado_origen();

-- ============================================================
-- cirugia
-- ============================================================

-- consentimiento, chequeo preanestesico y cirugia solo para solicitudes aprobadas
create function fn_agendamiento_aprobado() returns trigger language plpgsql as $$
begin
    if (select estado_solicitud from agendamiento_quirurgico
         where id_agendamiento = new.id_agendamiento) <> 'aprobada' then
        raise exception 'El agendamiento % no está aprobado por el comité (%)', new.id_agendamiento, tg_table_name;
    end if;
    return new;
end $$;

create trigger trg_consentimiento_aprobado before insert or update of id_agendamiento on consentimiento_informado
    for each row execute function fn_agendamiento_aprobado();
create trigger trg_chequeo_aprobado before insert or update of id_agendamiento on chequeo_preanestesico
    for each row execute function fn_agendamiento_aprobado();
create trigger trg_cirugia_aprobada before insert or update of id_agendamiento on cirugia
    for each row execute function fn_agendamiento_aprobado();

-- el rol quirurgico corresponde al tipo de personal que lo cumple
create function fn_cirugia_personal_rol() returns trigger language plpgsql as $$
declare
    v_tipo varchar;
begin
    select tipo_personal into v_tipo from rol_quirurgico where id_rol = new.id_rol;
    if (v_tipo = 'medico' and new.id_medico is null) or (v_tipo = 'enfermero' and new.id_enfermero is null) then
        raise exception 'El rol % lo debe cumplir un %', new.id_rol, v_tipo;
    end if;
    return new;
end $$;

create trigger trg_cirugia_personal_rol before insert or update on cirugia_personal
    for each row execute function fn_cirugia_personal_rol();

-- el resultado registrado corresponde a como se evalua el aspecto
create function fn_registro_resultado() returns trigger language plpgsql as $$
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

create trigger trg_registro_resultado before insert or update on registro_procedimiento
    for each row execute function fn_registro_resultado();

-- ============================================================
-- hospitalizacion, facturacion y calificaciones
-- ============================================================

-- los insumos de hospitalizacion se cargan a un ingreso de hospitalizacion
create function fn_hosp_insumo_ingreso() returns trigger language plpgsql as $$
begin
    if fn_tipo_unidad((select id_unidad from ingreso where id_ingreso = new.id_ingreso)) <> 'Hospitalización' then
        raise exception 'El ingreso % no es de Hospitalización', new.id_ingreso;
    end if;
    return new;
end $$;

create trigger trg_hosp_insumo_ingreso before insert or update on hospitalizacion_insumo
    for each row execute function fn_hosp_insumo_ingreso();

-- la cuota no pasa del plan de la factura y lo pagado no supera el total
create function fn_pago_plan() returns trigger language plpgsql as $$
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

create trigger trg_pago_plan before insert or update on pago
    for each row execute function fn_pago_plan();

-- si la calificacion viene de una consulta, califica al medico que la atendio
create function fn_calificacion_consulta() returns trigger language plpgsql as $$
begin
    if new.id_consulta is not null and new.id_medico is distinct from
       (select ci.id_medico from consulta co join cita ci on ci.id_cita = co.id_cita
         where co.id_consulta = new.id_consulta) then
        raise exception 'La calificación de la consulta % debe ser para el médico que la atendió', new.id_consulta;
    end if;
    return new;
end $$;

create trigger trg_calificacion_consulta before insert or update on calificacion
    for each row execute function fn_calificacion_consulta();
