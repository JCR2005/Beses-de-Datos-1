-- Proyecto 2 - Objetivo 16
-- Cadena de supervision de cualquier medico hasta el director medico de su
-- hospital, sin conocer de antemano cuantos niveles hay entre ellos.
--
-- CTE recursiva: el caso base es el medico indicado (nivel 0) y el paso
-- recursivo sube a su superior directo hasta llegar a quien no tiene superior.

begin;
set role admin;
set search_path to public;

create or replace function fn_cadena_mando(p_id_medico integer)
returns table (nivel integer, id_medico integer, medico text, cargo varchar, especialidad varchar, hospital varchar)
language sql stable
as $$
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

comment on function fn_cadena_mando(integer) is 'Objetivo 16: cadena de supervisión de un médico hasta el director.';

reset role;
commit;

-- ejemplos: una cadena de 4 niveles (hospital 1) y otra de 3 (hospital 4)
set role visor;
select * from fn_cadena_mando(1018);
select * from fn_cadena_mando(1046);
reset role;
