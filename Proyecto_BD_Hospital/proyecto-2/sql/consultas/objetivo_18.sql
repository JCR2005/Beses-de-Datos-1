-- Proyecto 2 - Objetivo 18
-- Pacientes que recibieron atencion en TODAS las unidades medicas (Consulta
-- Externa, Emergencias, Cirugia y Hospitalizacion) dentro de un lapso de tiempo.
--
-- Es una division del algebra relacional:
--     Atencion(paciente, unidad)  ÷  Unidad(unidad)
-- "los pacientes para los que no existe una unidad en la que no hayan sido
-- atendidos". En SQL se escribe con dos NOT EXISTS anidados.
--
-- Atencion en cada unidad:
--   Consulta Externa -> consulta de una cita del paciente
--   Emergencias, Cirugia, Hospitalizacion -> ficha de ingreso a esa unidad

begin;
set role admin;
set search_path to public;

create or replace function fn_objetivo_18(p_desde date, p_hasta date)
returns table (id_paciente integer, numero_expediente varchar, paciente text, edad smallint, sexo varchar)
language sql stable
as $$
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

comment on function fn_objetivo_18(date, date) is 'Objetivo 18: pacientes atendidos en las 4 unidades (división relacional).';

reset role;
commit;

set role visor;
select * from fn_objetivo_18('2026-01-01', '2026-10-31');

-- comprobacion con otra forma de la division: contar unidades distintas por paciente
select count(*) as pacientes_con_4_unidades
  from (select id_paciente
          from (select ci.id_paciente, 'Consulta Externa' as tipo_unidad
                  from consulta co join cita ci on ci.id_cita = co.id_cita
                 where ci.fecha_hora >= '2026-01-01' and ci.fecha_hora < '2026-11-01'
                union
                select i.id_paciente, u.tipo_unidad
                  from ingreso i join unidad_medica u on u.id_unidad = i.id_unidad
                 where i.fecha_hora_ingreso >= '2026-01-01' and i.fecha_hora_ingreso < '2026-11-01') a
         group by id_paciente
        having count(distinct tipo_unidad) = 4) x;
reset role;
