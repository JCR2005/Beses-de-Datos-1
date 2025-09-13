-- ============================================================
-- 01_roles.sql : control de acceso (DCL)
-- Roles: visor (solo lectura) y admin (lectura/escritura)
-- ============================================================

SET search_path TO public;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'visor') THEN
    CREATE ROLE visor LOGIN PASSWORD 'visor_2026' NOSUPERUSER NOCREATEDB NOCREATEROLE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'admin') THEN
    CREATE ROLE admin LOGIN PASSWORD 'admin_2026' NOSUPERUSER NOCREATEDB NOCREATEROLE;
  END IF;
END $$;

-- Limpiar privilegios
REVOKE ALL PRIVILEGES ON DATABASE hospital FROM visor, admin;
REVOKE ALL ON SCHEMA public FROM visor, admin;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM visor, admin;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM visor, admin;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM visor, admin;

-- Permisos de conexión
REVOKE CONNECT ON DATABASE hospital FROM PUBLIC;
GRANT CONNECT ON DATABASE hospital TO visor, admin;

-- ---------- Admin (lectura/escritura) ----------
GRANT USAGE, CREATE ON SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin;

ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public
  GRANT ALL PRIVILEGES ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public
  GRANT ALL PRIVILEGES ON SEQUENCES TO admin;
ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public
  GRANT ALL PRIVILEGES ON FUNCTIONS TO admin;

-- ---------- Visor (solo lectura) ----------
GRANT USAGE ON SCHEMA public TO visor;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO visor;

ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public
  GRANT SELECT ON TABLES TO visor;

REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA public FROM visor;
REVOKE USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public FROM visor;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM visor;
