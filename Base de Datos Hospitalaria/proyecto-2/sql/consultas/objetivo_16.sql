-- Objetivo 16: cadena de supervision de un medico hasta el director medico de su hospital,
-- sin saber de antemano cuantos niveles hay entre ellos.
-- Se usa una CTE recursiva: el caso base es el medico indicado (nivel 0) y la parte
-- recursiva sube a su superior directo hasta llegar a quien ya no tiene superior.
-- Para consultar otro medico solo se cambia el id del caso base.

-- ============================================================
-- ejemplo 1: medico 1018 (cadena de 4 niveles en el hospital 1)
-- ============================================================

with recursive cadena as (                          -- tabla temporal "cadena"; recursive = se usa a si misma para crecer

    -- CASO BASE: el medico que se quiere consultar
    select m.id_medico,                             -- el id del mesico
           m.id_medico_superior,                    -- el id de su jefe directo
           0 as nivel                               -- nivel 0 = el medico consultado
    from medico m                                   -- se buca en la tabla medico
    where m.id_medico = 1018                        -- el medico del que se parte (cambiar este id para otro medico)

    union all                                       -- junta el caso base con las filas que agrega la parte recursiva

    -- PARTE RECURSIVA: se repite sola, cada vuelta sube un nivel
    select m.id_medico,                             -- el id del jefe encontrado
           m.id_medico_superior,                    -- el jefe de ese jefe (para la siguiente vuelta)
           c.nivel + 1                              -- un nivel mas ariba que la fila anterior
    from medico m                                   -- se busca otra vez en medico
    inner join cadena c                             -- se une con lo que ya hay en "cadena"
            on m.id_medico = c.id_medico_superior   -- el medico buscado es el jefe de la ultima fila;
                                                    -- cuando llegs al director (superior null) ya no encuentra a nadie y termina
)
-- con la cadena armada se muestran los datos de cada medico
select c.nivel,                                     -- 0 = el consultado ... el mas alto = el director
       m.id_medico,                                 -- id del medico
       m.nombres,                                   -- nombres
       m.apellidos,                                 -- apellidos
       m.cargo,                                     -- medico, jefe_servicio o director_medico
       e.nombre as especialidad,                    -- nombre de su especialidad
       h.nombre as hospital                         -- nombre de su hospital
from cadena c                                       -- la tabla temporal que armo la parte de arriba
inner join medico m on m.id_medico = c.id_medico    -- se trae el nombre y cargo de cada medico de la cadena
inner join especialidad e on e.id_especialidad = m.id_especialidad   -- su especialidad
inner join hospital h on h.id_hospital = m.id_hospital               -- su hospital
order by c.nivel;                                   -- del medico consultado hasta el director

-- ============================================================
-- ejemplo 2: medico 1046 (hospital 4)
-- es la misma consulta: solo cambia el id del caso base
-- ============================================================

with recursive cadena as (                          -- taba temporl "cadena" que se usa a si misma
    -- caso base: el medico 1046 en el nivel 0
    select m.id_medico, m.id_medico_superior, 0 as nivel
    from medico m
    where m.id_medico = 1046                        -- unico cambio respecto al ejemplo 1
    union all                                       -- junta el caso base con lo que agrega la parte recursiva
    -- parte recursiva: trae al jefe de la ultima fila, un nivel mas arriba
    select m.id_medico, m.id_medico_superior, c.nivel + 1
    from medico m
    inner join cadena c on m.id_medico = c.id_medico_superior
)
select c.nivel, m.id_medico, m.nombres, m.apellidos, m.cargo,
       e.nombre as especialidad, h.nombre as hospital
from cadena c                                       -- la cadena ya armada
inner join medico m on m.id_medico = c.id_medico    -- nombre y cargo
inner join especialidad e on e.id_especialidad = m.id_especialidad   -- especialidad
inner join hospital h on h.id_hospital = m.id_hospital               -- hospital
order by c.nivel;                                   -- del medico hasta el director
