-- Proyecto 2 - BD Hospitales de Occidente
-- 02_jerarquia.sql : cadena de mando del personal medico (Bloque B, relacion recursiva)
--
-- Cada medico puede tener un superior directo dentro de su hospital (jefe de
-- servicio o director medico). El director de cada hospital es la cima de la
-- cadena: no tiene superior. Los medicos externos no estan contratados, por
-- lo que pueden quedar fuera de la cadena.
--
-- Se ejecuta con el rol administrativo.

set role admin;

alter table medico
    add column cargo varchar(15) not null default 'medico',
    add column id_medico_superior integer references medico(id_medico)
        on delete set null on update cascade,
    -- valida el cargo del medico dentro de la cadena de mando
    add constraint ck_medico_cargo check (cargo in ('director_medico','jefe_servicio','medico')),
    -- valida que nadie sea su propio superior
    add constraint ck_medico_superior_propio check (id_medico_superior <> id_medico),
    -- valida que el director medico no tenga superior: es la cima de la cadena
    add constraint ck_medico_director_sin_superior check (cargo <> 'director_medico' or id_medico_superior is null);

reset role;
