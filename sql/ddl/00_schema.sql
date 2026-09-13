-- ============================================================
-- Proyecto 1 - BD Hospitales de Occidente - DDL
-- 00_schema.sql : esquema y entorno de la base de datos
-- SGBD: PostgreSQL 18
-- ============================================================

-- Esquema public reutilizable (permite re-ejecutar el DDL completo)
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- Ordena la busqueda de objetos en el esquema public (seguido de pg_catalog)
SET search_path TO public, pg_catalog;

COMMENT ON SCHEMA public IS 'Esquema principal de la base de datos de Hospitales de Occidente.';