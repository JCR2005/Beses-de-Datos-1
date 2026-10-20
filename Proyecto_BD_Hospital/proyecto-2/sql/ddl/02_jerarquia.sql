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
set search_path to public;

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

-- un solo director medico por hospital
create unique index uq_medico_director_hospital on medico (id_hospital) where cargo = 'director_medico';

-- indice para recorrer la cadena desde el superior hacia sus subordinados
create index ix_medico_id_medico_superior on medico (id_medico_superior);

-- el superior trabaja en el mismo hospital y la cadena no puede cerrarse en un ciclo
create function fn_medico_jerarquia() returns trigger language plpgsql as $$
begin
    if new.id_medico_superior is null then
        return new;
    end if;
    if (select id_hospital from medico where id_medico = new.id_medico_superior) <> new.id_hospital then
        raise exception 'El superior % no trabaja en el hospital del médico %', new.id_medico_superior, new.id_medico;
    end if;
    -- se sube por la cadena desde el nuevo superior; si se llega al propio medico hay un ciclo
    if exists (
        with recursive cadena(id_medico) as (
            select new.id_medico_superior
            union
            select m.id_medico_superior
              from medico m join cadena c on m.id_medico = c.id_medico
             where m.id_medico_superior is not null
        )
        select 1 from cadena where id_medico = new.id_medico
    ) then
        raise exception 'Asignar a % como superior de % crearía un ciclo en la cadena de mando',
            new.id_medico_superior, new.id_medico;
    end if;
    return new;
end $$;

-- se ejecuta despues de trg_01_medico_desde_personal, que fija el hospital del medico
create trigger trg_02_medico_jerarquia before insert or update on medico
    for each row execute function fn_medico_jerarquia();

reset role;
