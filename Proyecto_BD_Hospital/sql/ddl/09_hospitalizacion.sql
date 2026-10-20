-- Proyecto 1 - BD Hospitales de Occidente
-- 09_hospitalizacion.sql : insumos usados durante la hospitalizacion

set search_path to public;

-- insumos usados en un internamiento, con el costo al momento de usarlos (asociativa M:N)
create table hospitalizacion_insumo (
    id_ingreso integer not null references ingreso(id_ingreso)
        on delete cascade on update cascade,
    id_insumo integer not null references insumo(id_insumo)
        on delete restrict on update cascade,
    cantidad smallint not null,
    costo_unitario numeric(10,2) not null,
    primary key (id_ingreso, id_insumo),
    -- valida que se use al menos una unidad
    constraint ck_hosp_insumo_cantidad check (cantidad > 0),
    -- valida que el costo unitario no sea negativo
    constraint ck_hosp_insumo_costo check (costo_unitario >= 0)
);
