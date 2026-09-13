-- ============================================================
-- 07_secuencias.sql : resincroniza las secuencias de identidad
-- tras inserciones con IDs explícitos (OVERRIDING SYSTEM VALUE)
-- ============================================================

SET search_path TO public;

-- Recalcula cada secuencia al máximo id existente + 1, para que las
-- futuras inserciones no colisionen con las filas insertadas a mano.
DO $sec$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT table_name, column_name
      FROM information_schema.columns
     WHERE table_schema = 'public'
       AND identity_generation IS NOT NULL
  LOOP
    EXECUTE format(
      'SELECT setval(pg_get_serial_sequence(%L, %L),
                     (SELECT COALESCE(MAX(%I), 0) + 1 FROM %I.%I), false)',
      'public.' || r.table_name,
      r.column_name,
      r.column_name,
      'public',
      r.table_name
    );
  END LOOP;
END $sec$;