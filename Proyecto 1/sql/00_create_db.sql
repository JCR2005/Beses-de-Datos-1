CREATE DATABASE '/tmp/bd1_final.fdb' USER 'SYSDBA' PASSWORD 'masterkey' DEFAULT CHARACTER SET UTF8;
INPUT '/home/carlos/Descargas/01_schema.sql';
INPUT '/home/carlos/Descargas/02_insert.sql';
COMMIT;