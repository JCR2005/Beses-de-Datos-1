# Ejercicio #10: SQL del log vs. SQL a mano

Juan Carlos Rodríguez López, carné 202231970
Base de datos: gimnasio (PostgreSQL). API en el puerto 3070.

En cada punto pongo lo que salió en el log de TypeORM y lo que yo escribiría a mano para pedir lo mismo.
Para que no quede tan largo, en algunos SELECT puse "..." en lugar de repetir todas las columnas con alias.

## 1. Listar las clases: GET /clase

SQL del log:
```sql
SELECT "Clase"."id" AS "Clase_id", "Clase"."nombre" AS "Clase_nombre", ... FROM "clase" "Clase" ORDER BY "Clase"."id" ASC
```

SQL a mano:
```sql
SELECT id, nombre, horario, cupo_maximo, cupo_disponible, entrenador_id FROM clase ORDER BY id;
```

Diferencia: TypeORM le pone un alias a cada columna (Clase_id, Clase_nombre...) para poder armar el objeto. El resultado es el mismo.

## 2. Buscar una clase: GET /clase/2

SQL del log:
```sql
SELECT "Clase"."id" AS "Clase_id", ... FROM "clase" "Clase" WHERE (("Clase"."id" = $1)) LIMIT 1
-- PARAMETERS: [2]
```

SQL a mano:
```sql
SELECT * FROM clase WHERE id = 2;
```

Diferencia: el id va como parámetro ($1) y no pegado en el texto. También agrega LIMIT 1 porque espera un solo registro.

## 3. Crear una clase: POST /clase

SQL del log:
```sql
START TRANSACTION
INSERT INTO "clase"("nombre", "horario", "cupo_maximo", "cupo_disponible", "entrenador_id") VALUES ($1, $2, $3, $4, $5) RETURNING "id"
-- PARAMETERS: ["Prueba","Sab 09:00",1,1,2]
COMMIT
```

SQL a mano:
```sql
INSERT INTO clase (nombre, horario, cupo_maximo, cupo_disponible, entrenador_id)
VALUES ('Prueba', 'Sab 09:00', 1, 1, 2) RETURNING id;
```

Diferencia: TypeORM abre su propia transacción (START TRANSACTION y COMMIT) para guardar. A mano un INSERT suelto no la necesita.

## 4. Modificar una clase: PATCH /clase/4

SQL del log:
```sql
SELECT "Clase"."id" AS "Clase_id", ... FROM "clase" "Clase" WHERE (("Clase"."id" = $1)) LIMIT 1
-- PARAMETERS: [4]
START TRANSACTION
UPDATE "clase" SET "horario" = $1 WHERE "id" = $2
-- PARAMETERS: ["Sab 10:00",4]
COMMIT
```

SQL a mano:
```sql
UPDATE clase SET horario = 'Sab 10:00' WHERE id = 4;
```

Diferencia: antes del UPDATE hay un SELECT porque el servicio revisa que la clase exista (si no, responde 404). El UPDATE solo cambia la columna horario, que fue la única que modifiqué.

## 5. Eliminar una clase: DELETE /clase/5

SQL del log:
```sql
SELECT "Clase"."id" AS "Clase_id", ... FROM "clase" "Clase" WHERE (("Clase"."id" = $1)) LIMIT 1
-- PARAMETERS: [5]
DELETE FROM "clase" WHERE "id" = $1
-- PARAMETERS: [5]
```

SQL a mano:
```sql
DELETE FROM clase WHERE id = 5;
```

Si el id no existe (por ejemplo el 999) solo sale el SELECT, no se ejecuta el DELETE y la API responde 404.
Si la clase tiene inscripciones, PostgreSQL no deja borrarla por la llave foránea y la API responde 409.

## 6. Clases con su entrenador: GET /clase/con-entrenador (relations)

SQL del log:
```sql
SELECT "Clase"."id" AS "Clase_id", ..., "Clase__Clase_entrenador"."id" AS "Clase__Clase_entrenador_id", ...
FROM "clase" "Clase"
INNER JOIN "entrenador" "Clase__Clase_entrenador" ON "Clase__Clase_entrenador"."id"="Clase"."entrenador_id"
ORDER BY "Clase"."id" ASC
```

SQL a mano:
```sql
SELECT c.*, e.id, e.nombre, e.especialidad
FROM clase c
INNER JOIN entrenador e ON e.id = c.entrenador_id
ORDER BY c.id;
```

Diferencia: me salió INNER JOIN y no LEFT JOIN. Esto es porque la relación entrenador es obligatoria (nullable: false), toda clase tiene entrenador.

## 7. QueryBuilder: GET /clase/especialidad/Yoga

Esta consulta tiene JOIN, un filtro con parámetro y un orden.

SQL del log:
```sql
SELECT "c"."id" AS "c_id", "c"."nombre" AS "c_nombre", ..., "e"."especialidad" AS "e_especialidad"
FROM "clase" "c" INNER JOIN "entrenador" "e" ON "e"."id"="c"."entrenador_id"
WHERE "e"."especialidad" = $1 ORDER BY "c"."nombre" ASC
-- PARAMETERS: ["Yoga"]
```

SQL a mano:
```sql
SELECT c.*, e.*
FROM clase c
INNER JOIN entrenador e ON e.id = c.entrenador_id
WHERE e.especialidad = 'Yoga'
ORDER BY c.nombre;
```

Diferencia: el valor 'Yoga' nunca se pega en el SQL, va como parámetro ($1). Así se evita la inyección SQL.

## 8. Transacción: POST /inscripcion/inscribir

La transacción hace dos cambios: inserta en inscripcion y le resta 1 al cupo_disponible de la clase.
Se apoya en el CHECK de la tabla clase (cupo_disponible >= 0).

### 8.1 Cuando sí hay cupo (COMMIT)

SQL del log:
```sql
START TRANSACTION
INSERT INTO "inscripcion"("socio_id", "clase_id", "fecha_inscripcion") VALUES ($1, $2, DEFAULT) RETURNING "id", "fecha_inscripcion"
-- PARAMETERS: [4,4]
UPDATE "clase" SET "cupo_disponible" = "cupo_disponible" - 1 WHERE "id" = $1
-- PARAMETERS: [4]
COMMIT
```

SQL a mano:
```sql
BEGIN;
INSERT INTO inscripcion (socio_id, clase_id) VALUES (4, 4);
UPDATE clase SET cupo_disponible = cupo_disponible - 1 WHERE id = 4;
COMMIT;
```

### 8.2 Cuando no hay cupo (ROLLBACK)

SQL del log:
```sql
START TRANSACTION
INSERT INTO "inscripcion"("socio_id", "clase_id", "fecha_inscripcion") VALUES ($1, $2, DEFAULT) RETURNING "id", "fecha_inscripcion"
-- PARAMETERS: [3,4]
UPDATE "clase" SET "cupo_disponible" = "cupo_disponible" - 1 WHERE "id" = $1
-- PARAMETERS: [4]
error: new row for relation "clase" violates check constraint "clase_cupo_disponible_check"
ROLLBACK
```

SQL a mano para reproducirlo:
```sql
BEGIN;
INSERT INTO inscripcion (socio_id, clase_id) VALUES (3, 4);
UPDATE clase SET cupo_disponible = cupo_disponible - 1 WHERE id = 4;  -- da error, viola el CHECK
ROLLBACK;

SELECT * FROM inscripcion WHERE socio_id = 3 AND clase_id = 4;  -- devuelve 0 filas
```

Resultado: el UPDATE falla y el INSERT que se había hecho antes también se deshace. La consulta final no devuelve filas, o sea que el socio 3 no quedó inscrito. La API respondió 409.
