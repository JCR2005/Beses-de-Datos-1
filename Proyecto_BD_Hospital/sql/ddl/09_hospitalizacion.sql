-- Proyecto 1 - BD Hospitales de Occidente
-- 09_hospitalizacion.sql : insumos usados durante la hospitalizacion

-- los insumos que se usan internando se suman a la cuenta del paciente (asociativa M:N)
create table hospitalizacion_insumo (
    id_hospitalizacion_insumo serial primary key,
    ingreso_id integer not null references ingreso(id_ingreso)
        on delete cascade on update cascade,
    insumo_id integer not null references insumo(id_insumo)
        on delete no action on update cascade,
    cantidad smallint not null,
    costo_unitario numeric(10,2) not null
);