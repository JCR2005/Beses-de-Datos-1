-- Proyecto 1 - BD Hospitales de Occidente
-- 12_vistas.sql : vistas con los datos derivados que no se guardan en las tablas

set search_path to public;

-- paciente con su edad actual y su direccion completa
create view v_paciente as
select p.id_paciente,
       p.numero_expediente,
       p.nombres,
       p.apellidos,
       p.fecha_nacimiento,
       fn_edad(p.fecha_nacimiento) as edad,
       p.sexo,
       p.dpi,
       p.telefono,
       ec.nombre as estado_civil,
       m.nombre as municipio,
       d.nombre as departamento,
       p.area,
       p.numero_seguro_social
  from paciente p
  join municipio m on m.id_municipio = p.id_municipio
  join departamento d on d.id_departamento = m.id_departamento
  left join estado_civil ec on ec.id_estado_civil = p.id_estado_civil;

-- consulta con los datos de su cita: fecha, paciente, medico y hospital
create view v_consulta as
select co.id_consulta,
       ci.id_cita,
       ci.fecha_hora,
       ci.id_paciente,
       ci.id_medico,
       me.id_hospital,
       me.id_especialidad,
       co.id_diagnostico,
       ci.costo_final
  from consulta co
  join cita ci on ci.id_cita = co.id_cita
  join medico me on me.id_medico = ci.id_medico;

-- ingreso con su egreso (si ya salio), hospital, edad al ingresar y dias de estancia
create view v_estancia as
select i.id_ingreso,
       i.id_paciente,
       u.id_hospital,
       i.id_unidad,
       u.tipo_unidad,
       i.id_servicio,
       i.id_camilla,
       i.fecha_hora_ingreso,
       fn_edad(p.fecha_nacimiento, i.fecha_hora_ingreso::date) as edad_al_ingreso,
       e.id_egreso,
       e.fecha_hora_egreso,
       e.codigo_egreso,
       (e.fecha_hora_egreso::date - i.fecha_hora_ingreso::date) as dias_hospitalizado
  from ingreso i
  join unidad_medica u on u.id_unidad = i.id_unidad
  join paciente p on p.id_paciente = i.id_paciente
  left join egreso e on e.id_ingreso = i.id_ingreso;

-- cirugia con paciente, cirujano, tipo de cirugia y hospital donde se realizo
create view v_cirugia as
select c.id_cirugia,
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
  from cirugia c
  join agendamiento_quirurgico a on a.id_agendamiento = c.id_agendamiento
  join quirofano q on q.id_quirofano = c.id_quirofano
  join unidad_medica u on u.id_unidad = q.id_unidad;

-- factura con paciente, hospital y unidad segun su origen, y lo pagado a la fecha
create view v_factura as
select f.id_factura,
       f.fecha_emision,
       f.total,
       f.numero_cuotas,
       coalesce(ci.id_paciente, i.id_paciente, a.id_paciente) as id_paciente,
       u.id_hospital,
       u.id_unidad,
       u.tipo_unidad,
       coalesce(pg.total_pagado, 0) as total_pagado,
       f.total - coalesce(pg.total_pagado, 0) as saldo
  from factura f
  left join cita ci on ci.id_cita = f.id_cita
  left join medico me on me.id_medico = ci.id_medico
  left join unidad_medica uc on uc.id_hospital = me.id_hospital and uc.tipo_unidad = 'Consulta Externa'
  left join ingreso i on i.id_ingreso = f.id_ingreso
  left join cirugia c on c.id_cirugia = f.id_cirugia
  left join agendamiento_quirurgico a on a.id_agendamiento = c.id_agendamiento
  left join quirofano q on q.id_quirofano = c.id_quirofano
  join unidad_medica u on u.id_unidad = coalesce(uc.id_unidad, i.id_unidad, q.id_unidad)
  left join (select id_factura, sum(monto) as total_pagado
               from pago group by id_factura) pg on pg.id_factura = f.id_factura;
