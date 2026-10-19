# gimnasio-api

Ejercicio #10 del laboratorio de Bases de Datos 1. API hecha con NestJS y TypeORM sobre la base de datos gimnasio de la práctica #7.

Juan Carlos Rodríguez López, carné 202231970.
El puerto es 3070 (3000 + los últimos dos dígitos del carné).

## Cómo correrlo

Se necesita Node.js y la base gimnasio en PostgreSQL. En mi caso está en un contenedor de Docker (lab_DB1) en el puerto 5435.

```bash
npm install
npm run start:dev
```

Por defecto se conecta a localhost:5435, base gimnasio, usuario postgres y contraseña 4170. Se puede cambiar con variables de entorno:

```bash
DB_PORT=5435 DB_PASS=4170 DB_NAME=gimnasio PORT=3070 npm run start:dev
```

TypeORM tiene synchronize y logging en true, así que cada SQL aparece en la consola.

## Entidades

TipoMembresia, Entrenador, Socio, Clase e Inscripcion. Las relaciones son:

- TipoMembresia 1:N Socio
- Entrenador 1:N Clase
- Socio 1:N Inscripcion y Clase 1:N Inscripcion (juntas resuelven la relación M:N entre socio y clase)

## Endpoints

- GET /clase: lista las clases
- GET /clase/:id: una clase (404 si no existe)
- POST /clase: crea una clase
- PATCH /clase/:id: modifica una clase (404 si no existe)
- DELETE /clase/:id: elimina una clase (404 si no existe, 409 si tiene inscripciones)
- GET /clase/con-entrenador: cada clase con su entrenador (relations)
- GET /clase/especialidad/:nombre: QueryBuilder con JOIN, filtro con parámetro y orden
- POST /inscripcion/inscribir: transacción de dos cambios (INSERT y UPDATE)
- GET /inscripcion: lista las inscripciones

Cuerpo de ejemplo para POST /clase:

```json
{ "nombre": "Zumba", "horario": "Sab 09:00", "cupoMaximo": 12, "cupoDisponible": 12, "entrenadorId": 2 }
```

Cuerpo para POST /inscripcion/inscribir:

```json
{ "socioId": 4, "claseId": 4 }
```

## Probar la transacción que falla

1. Crear una clase con un solo cupo (cupoMaximo 1 y cupoDisponible 1).
2. Inscribir a un socio en esa clase. Responde 201 y en la consola se ve COMMIT.
3. Inscribir a otro socio en la misma clase. Responde 409 y en la consola se ve ROLLBACK.
4. Con un SELECT a la tabla inscripcion se comprueba que el segundo socio no quedó inscrito.

La comparación del SQL del log con el SQL a mano está en docs/comparacion-sql.md.
