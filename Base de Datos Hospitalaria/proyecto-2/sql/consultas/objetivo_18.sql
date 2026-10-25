-- Objetivo 18: pacientes atendidos en TODAS las unidades medicas (Consulta Externa,
-- Emergencias, Cirugia y Hospitalizacion) para invitarlos al programa de fidelidad.
-- lapso: enero a octubre de 2026

select p.id_paciente,
       p.numero_expediente,
       p.nombres,
       p.apellidos,
       p.sexo
from paciente p
inner join ingreso i on i.id_paciente = p.id_paciente           -- sus fichas de ingreso (emergencias, cirugia, hospitalizacion)
inner join unidad_medica u on u.id_unidad = i.id_unidad         -- para saber en que unidad fue cada ingreso
where i.fecha_hora_ingreso between '2026-01-01' and '2026-10-31 23:59:59'
  and p.id_paciente in (select c.id_paciente                    -- y que tambien haya tenido una consulta (consulta externa)
                        from consulta co
                        inner join cita c on c.id_cita = co.id_cita
                        where c.fecha_hora between '2026-01-01' and '2026-10-31 23:59:59')
group by p.id_paciente, p.numero_expediente, p.nombres, p.apellidos, p.sexo   -- una fila por paciente
having count(distinct u.tipo_unidad) = 3                        -- que sus ingresos sean de las 3 unidades distintas
order by p.id_paciente;
