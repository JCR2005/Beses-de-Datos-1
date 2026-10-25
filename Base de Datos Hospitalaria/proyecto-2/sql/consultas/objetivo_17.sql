-- Objetivo 17: ranking de medicos por calificacion como el objetuvo 2
-- con su posicion en su hospital y en toda la cadena.
-- La posicion 1 es la nota mas baja.
-- Hay dos formas que dan lo mismo, para ver cual es mas rapida (ver rendimiento/).
-- lapso: enero a octubre de 2026

-- Forma A: funciones de ventana
with promedios as (                                       -- tabla temporal con el promedio de cada medico
    select m.id_medico,                                   -- id del medico
           m.nombres || ' ' || m.apellidos as medico,     -- nombre completo (|| junta los textos)
           h.nombre as hospital,                          -- su hospital
           avg(ca.puntuacion) as promedio                 -- su nota promedio (de 1 a 5)
    from calificacion ca                                  -- las notas que dieron los pacientes
    inner join consulta co on co.id_consulta = ca.id_consulta   -- la consulta que se califico
    inner join cita c on c.id_cita = co.id_cita                 -- su cita, para la fecha y el medico
    inner join medico m on m.id_medico = c.id_medico            -- el medico que atendio
    inner join hospital h on h.id_hospital = m.id_hospital      -- el hospital del medico
    where c.fecha_hora between '2026-01-01' and '2026-10-31 23:59:59'   -- solo el lapso
    group by m.id_medico, m.nombres, m.apellidos, h.nombre      -- una fila por medico
)
select medico,                                            -- nombre
       hospital,                                          -- hospital
       round(promedio, 2) as calificacion_promedio,       -- promedio con 2 decimales
       rank() over (partition by hospital order by promedio) as posicion_en_hospital,   -- puesto contando solo su hospital
       rank() over (order by promedio) as posicion_en_cadena                            -- puesto contando a todos los medicos
from promedios                                            -- sale de la tabla temporal
order by posicion_en_cadena, hospital, medico;            -- del peor al mejor

-- Forma B: subconsultas correlacionadas (la posicion es 1 + cuantos medicos tienen menor promedio)
with promedios as (                                       -- la misma tabla temporal de la forma A
    select m.id_medico, m.nombres || ' ' || m.apellidos as medico, h.nombre as hospital,   -- id, nombre y hospital
           avg(ca.puntuacion) as promedio                 -- nota promedio
    from calificacion ca                                  -- las notas
    inner join consulta co on co.id_consulta = ca.id_consulta   -- su consulta
    inner join cita c on c.id_cita = co.id_cita                 -- su cita
    inner join medico m on m.id_medico = c.id_medico            -- el medico
    inner join hospital h on h.id_hospital = m.id_hospital      -- su hospital
    where c.fecha_hora between '2026-01-01' and '2026-10-31 23:59:59'   -- solo el lapso
    group by m.id_medico, m.nombres, m.apellidos, h.nombre      -- una fila por medico
)
-- p1 = el medico al que se le busca el puesto, p2 = los demas medicos con los que se compara.
-- puesto = 1 + cuantos van delante (los que tienen menos nota), como el lugar en una fila:
-- si nadie va delante eres el 1, si van 2 delante eres el 3
select p1.medico,                                         -- el medico al que se le busca el puesto
       p1.hospital,                                       -- su hospital
       round(p1.promedio, 2) as calificacion_promedio,    -- su promedio con 2 decimales
       1 + (select count(*) from promedios p2             -- 1 + los que van delante = su puesto en el hospital
            where p2.hospital = p1.hospital               -- el where no ordena, elige a quien contar: solo los de su hospital
              and p2.promedio < p1.promedio) as posicion_en_hospital,   -- y que tengan menos nota que el
       1 + (select count(*) from promedios p2             -- 1 + los que van delante = su puesto en la cadena
            where p2.promedio < p1.promedio) as posicion_en_cadena      -- cuenta a todos los que tienen menos nota (de cualquier hospital)
from promedios p1                                         -- se hace para cada medico de la lista
order by posicion_en_cadena, hospital, medico;            -- este si ordena: del puesto 1 (peor nota) al ultimo
