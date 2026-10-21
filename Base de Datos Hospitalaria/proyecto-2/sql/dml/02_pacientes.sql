-- Proyecto 2 - BD Hospitales de Occidente
-- 02_pacientes.sql : ampliacion de pacientes y encargados (datos FICTICIOS)
--
-- Los pacientes 8 a 67 se generan combinando listas de nombres y apellidos
-- ficticios con formulas fijas, para que la carga sea reproducible (siempre
-- produce los mismos datos) y cubra ambos sexos, todas las edades, zonas
-- urbanas y rurales y los municipios de los 5 hospitales.

begin;
set role admin;
set search_path to public;

insert into paciente (id_paciente, numero_expediente, nombres, apellidos, fecha_nacimiento, sexo, dpi,
                      telefono, id_municipio, area, id_estado_civil, numero_seguro_social)
select n,
       format('HG%s-%s', 1 + n % 5, lpad(n::text, 4, '0')),
       case when n % 2 = 0
            then (array['María José','Ana Belén','Lucía','Carmen','Rosa Elena','Andrea','Sofía','Gabriela','Paola','Verónica',
                        'Marta','Julia','Claudia','Daniela','Elena'])[1 + n % 15]
            else (array['José Luis','Carlos','Miguel','Juan Pablo','Luis Fernando','Diego','Mario','Jorge','Pedro','Andrés',
                        'Ricardo','Héctor','Fernando','Rafael','Óscar'])[1 + n % 15] end,
       (array['García','López','Pérez','Morales','Hernández','Castillo','Ramírez','Gómez','Méndez','Cruz','Ortiz','Fuentes',
              'Vásquez','Juárez','Sosa','Tzul','Coyoy','Ajcá','Xicará','Batz'])[1 + n % 20] || ' ' ||
       (array['Paz','Rojas','Ixcot','Sic','Barrios','Chávez','Ruiz','Lima','Soto','Pop','Tum','Chan'])[1 + (n * 7) % 12],
       fecha_nac,
       case when n % 2 = 0 then 'Femenino' else 'Masculino' end,
       case when fn_edad(fecha_nac) >= 18 then '41' || lpad(n::text, 11, '0') end,
       format('55%s-%s', lpad((10 + n % 90)::text, 2, '0'), lpad((1000 + n * 37 % 9000)::text, 4, '0')),
       (array[1, 2, 3, 4, 5, 6, 13, 8, 14, 9, 10, 11, 12])[1 + n % 13],
       case when n % 3 = 0 then 'Rural' else 'Urbana' end,
       case when fn_edad(fecha_nac) < 18 then 1 else 1 + n % 5 end,
       case when n % 4 = 0 then 'IGSS-' || (50000 + n * 113) end
  from (select n, date '1940-03-01' + (n * 4517) % 30500 as fecha_nac
          from generate_series(8, 67) n) g;

insert into encargado (id_encargado, nombres, apellidos, dpi, telefono, id_municipio, area)
select 300 + n,
       (array['Marta','Juan','Lidia','Rodrigo','Elsa','Pedro','Olga','Mynor','Silvia','Erick'])[1 + n % 10],
       (array['Pérez','Coyoy','Ruiz','Batz','Sosa','Castillo','Ixcot','Fuentes','Lima','Morales'])[1 + (n * 3) % 10] || ' ' ||
       (array['García','Tzul','Paz','Chan','Rojas'])[1 + n % 5],
       '42' || lpad(n::text, 11, '0'),
       format('56%s-%s', lpad((10 + n)::text, 2, '0'), lpad((2000 + n * 41)::text, 4, '0')),
       (array[1, 6, 8, 9, 11])[1 + n % 5],
       case when n % 4 = 0 then 'Rural' else 'Urbana' end
  from generate_series(4, 23) n;

-- cada menor de edad tiene uno o dos encargados (madre o padre); algunos adultos, un hermano
insert into paciente_encargado (id_paciente, id_encargado, id_parentesco)
select p.id_paciente, 304 + (p.id_paciente % 20), case when p.id_paciente % 2 = 0 then 1 else 2 end
  from paciente p
 where p.id_paciente >= 8 and fn_edad(p.fecha_nacimiento) < 18
union all
select p.id_paciente, 304 + ((p.id_paciente + 7) % 20), case when p.id_paciente % 2 = 0 then 2 else 1 end
  from paciente p
 where p.id_paciente >= 8 and fn_edad(p.fecha_nacimiento) < 12
union all
select p.id_paciente, 304 + ((p.id_paciente + 3) % 20), 3
  from paciente p
 where p.id_paciente >= 8 and fn_edad(p.fecha_nacimiento) >= 65;

do $$
begin
    perform setval(pg_get_serial_sequence('paciente', 'id_paciente'), (select max(id_paciente) from paciente));
    perform setval(pg_get_serial_sequence('encargado', 'id_encargado'), (select max(id_encargado) from encargado));
end $$;

reset role;
commit;
