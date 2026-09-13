-- ============================================================
-- 01_roles.sql : control de acceso (DCL)
-- Rol de solo lectura (auditoría/reportes) y rol administrativo
-- ============================================================

SET search_path TO public;

-- Creacion idempotente de los usuarios de aplicacion (credenciales ficticias).
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usuario_auditoria') THEN
    CREATE ROLE usuario_auditoria LOGIN PASSWORD 'auditoria_2026' NOSUPERUSER NOCREATEDB NOCREATEROLE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usuario_admin') THEN
    CREATE ROLE usuario_admin LOGIN PASSWORD 'admin_2026' NOSUPERUSER NOCREATEDB NOCREATEROLE;
  END IF;
END $$;

-- Limpieza previa de privilegios (deja ambos roles "limpios" antes de otorgar).
REVOKE ALL PRIVILEGES ON DATABASE hospital FROM usuario_auditoria, usuario_admin;
REVOKE ALL ON SCHEMA public FROM usuario_auditoria, usuario_admin;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM usuario_auditoria, usuario_admin;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM usuario_auditoria, usuario_admin;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM usuario_auditoria, usuario_admin;
-- 1) Usuario de solo lectura: para auditoría y consulta de reportes (creado en el DO block previo).

-- 2) Usuario administrativo: privilegios completos sobre el esquema (creado en el DO block previo).

-- Se revoca el acceso público por defecto a la base de datos.
REVOKE CONNECT ON DATABASE hospital FROM PUBLIC;
GRANT CONNECT ON DATABASE hospital TO usuario_auditoria, usuario_admin;

-- ---------- Usuario administrativo ----------
GRANT ALL PRIVILEGES ON SCHEMA public TO usuario_admin;
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO usuario_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO usuario_admin;
-- Privilegios sobre objetos creados a futuro por el propietario (hospital).
ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public
  GRANT ALL PRIVILEGES ON TABLES TO usuario_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public
  GRANT ALL PRIVILEGES ON SEQUENCES TO usuario_admin;

-- ---------- Usuario de solo lectura (auditoría/reportes) ----------
GRANT USAGE ON SCHEMA public TO usuario_auditoria;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usuario_auditoria;
-- Select sobre objetos creados a futuro por el propietario (hospital).
ALTER DEFAULT PRIVILEGES FOR ROLE hospital IN SCHEMA public
  GRANT SELECT ON TABLES TO usuario_auditoria;
-- Reforzar la política de solo lectura: sin escritura ni control DDL.
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA public FROM usuario_auditoria;
REVOKE USAGE ON ALL SEQUENCES IN SCHEMA public FROM usuario_auditoria;
REVOKE CREATE ON SCHEMA public FROM usuario_auditoria;