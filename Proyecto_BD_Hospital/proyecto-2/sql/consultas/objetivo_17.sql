-- Proyecto 2 - Objetivo 17
-- Ranking de medicos de consulta externa por calificacion (objetivo 2) con su
-- posicion dentro de su hospital y en toda la cadena, en un mismo reporte.
--
-- Se construye de dos formas para comparar como responden al crecer los datos
-- (la medicion esta en rendimiento/ y la conclusion en el PDF):
--   A) funciones de ventana: RANK() OVER (PARTITION BY hospital) y RANK() OVER ()
--   B) subconsultas correlacionadas: la posicion es 1 + cuantos medicos tienen
--      un promedio menor (en su hospital, o en toda la cadena)
-- La posicion 1 es la calificacion mas baja, igual que en el objetivo 2.

begin;
set role admin;
set search_path to public;

-- promedio de calificacion por servicio de cada medico en el lapso (comun a ambas formas)
create or replace function fn_promedio_medico(p_desde date, p_hasta date)
returns table (id_medico integer, id_hospital integer, promedio numeric, calificaciones bigint)
language sql stable
as $$
    select ci.id_medico, me.id_hospital, avg(ca.puntuacion), count(*)
      from calificacion ca
      join consulta co on co.id_consulta = ca.id_consulta
      join cita ci on ci.id_cita = co.id_cita
      join medico me on me.id_medico = ci.id_medico
     where ci.fecha_hora >= p_desde and ci.fecha_hora < p_hasta + 1
     group by ci.id_medico, me.id_hospital;
$$;

-- forma A: funciones de ventana (una sola pasada ordenada por particion)
create or replace function fn_objetivo_17_ventana(p_desde date, p_hasta date)
returns table (id_medico integer, medico text, hospital varchar, calificacion_promedio numeric,
               posicion_en_hospital bigint, posicion_en_cadena bigint)
language sql stable
as $$
    select pm.id_medico, me.nombres || ' ' || me.apellidos, h.nombre, round(pm.promedio, 2),
           rank() over (partition by pm.id_hospital order by pm.promedio),
           rank() over (order by pm.promedio)
      from fn_promedio_medico(p_desde, p_hasta) pm
      join medico me on me.id_medico = pm.id_medico
      join hospital h on h.id_hospital = pm.id_hospital
     order by 6, 3, 2;
$$;

-- forma B: subconsultas correlacionadas (cada medico se compara con todos los demas)
create or replace function fn_objetivo_17_correlacionada(p_desde date, p_hasta date)
returns table (id_medico integer, medico text, hospital varchar, calificacion_promedio numeric,
               posicion_en_hospital bigint, posicion_en_cadena bigint)
language sql stable
as $$
    with pm as materialized (select * from fn_promedio_medico(p_desde, p_hasta))
    select p1.id_medico, me.nombres || ' ' || me.apellidos, h.nombre, round(p1.promedio, 2),
           1 + (select count(*) from pm p2 where p2.id_hospital = p1.id_hospital and p2.promedio < p1.promedio),
           1 + (select count(*) from pm p2 where p2.promedio < p1.promedio)
      from pm p1
      join medico me on me.id_medico = p1.id_medico
      join hospital h on h.id_hospital = p1.id_hospital
     order by 6, 3, 2;
$$;

comment on function fn_objetivo_17_ventana(date, date) is 'Objetivo 17 (forma A): ranking por hospital y global con funciones de ventana.';
comment on function fn_objetivo_17_correlacionada(date, date) is 'Objetivo 17 (forma B): ranking por hospital y global con subconsultas correlacionadas.';

reset role;
commit;

set role visor;
-- los 10 medicos con menor calificacion de la cadena, con su posicion en su hospital
select * from fn_objetivo_17_ventana('2026-01-01', '2026-10-31') limit 10;

-- las dos formas dan exactamente el mismo resultado (0 filas de diferencia en ambos sentidos)
select count(*) as filas_distintas
  from ((select * from fn_objetivo_17_ventana('2026-01-01', '2026-10-31')
         except select * from fn_objetivo_17_correlacionada('2026-01-01', '2026-10-31'))
        union all
        (select * from fn_objetivo_17_correlacionada('2026-01-01', '2026-10-31')
         except select * from fn_objetivo_17_ventana('2026-01-01', '2026-10-31'))) d;
reset role;
