# Proyecto 2 — Consultas Avanzadas, Lógica del Negocio y Seguridad (SBD1)

Extensión de la base de datos del Proyecto 1 (`Proyecto_BD_Hospital/`) para la cadena
**Hospitales de Occidente**: 20 objetivos organizados en los bloques A a F del enunciado.
Es la misma base, extendida mediante migraciones que no borran nada de lo existente.

## Estructura

| Carpeta | Contenido |
|---------|-----------|
| `modelo/` | Modelo extendido en notación Barker: `modelo_barker_p2.drawio` (draw.io) e imagen `modelo_barker_p2.png`. El recuadro PERSONAL es el supertipo con sus subtipos MEDICO y ENFERMERO; la línea naranja es la relación recursiva «superior directo» |
| `sql/ddl/` | Migración del modelo: `00_propietario.sql` (admin pasa a ser dueño del esquema), `01_personal.sql` (supertipo y subtipos, Bloque B), `02_jerarquia.sql` (cadena de mando), `03_comentarios.sql` (descripciones para el diccionario) |
| `sql/dml/` | Ampliación de datos ficticios de enero a octubre de 2026: red y personal, pacientes, consulta externa, emergencias y hospitalización, cirugía y facturación |
| `sql/consultas/` | Un archivo por objetivo (`objetivo_01.sql` … `objetivo_19.sql`); cada uno crea la función `fn_objetivo_XX(desde, hasta)` y la ejecuta con el rol de solo lectura. `rendimiento/` mide las dos formas del objetivo 17 |
| `sql/auditoria/` | Bloque F: bitácora automática de cambios sensibles (`01_auditoria.sql`) y su demostración (`02_prueba.sql`) |
| `orm/` | Proyecto Maven con Java 21 y JPA (Hibernate 6.6) para los objetivos 8, 11 y 18, con una clase que compara su resultado con el de las funciones SQL |
| `backup/` | Respaldo con pg_dump de la base final: `hospital_p2.backup` (formato custom) y `hospital_p2.sql` (texto plano) |
| `documentacion/` | `Proyecto2_Hospitales_de_Occidente.pdf` (modelo, diccionario de datos, los 20 objetivos con su sentencia y captura, ORM, normalización y auditoría), `capturas/` (resultado de cada objetivo), `rendimiento_objetivo_17.md` y los scripts que generan las capturas y el PDF |

## Roles

- `visor` (solo lectura): ejecuta las consultas y el ORM.
- `admin` (administrativo): dueño del esquema; ejecuta la extensión del modelo y crea la auditoría.
- `dueno_auditoria` (sin login): dueño de la bitácora, para que nadie, ni siquiera admin, pueda alterarla.

Las contraseñas no se guardan en el repositorio.

## Cómo reconstruir la base desde cero

Sobre una base vacía (`createdb hospital`), con el superusuario dueño de la base:

1. Proyecto 1: `Proyecto_BD_Hospital/sql/ddl/` (00 → 15), `sql/dml/` (01 → 99) y `sql/dcl/01_roles.sql`.
2. Proyecto 2, en este orden:
   - `sql/ddl/00_propietario.sql`, `01_personal.sql`, `02_jerarquia.sql`
   - `sql/dml/` (01 → 06)
   - `sql/auditoria/01_auditoria.sql` y `02_prueba.sql`
   - `sql/ddl/03_comentarios.sql`
   - `sql/consultas/objetivo_*.sql`

Cada script corre en su propia transacción. O bien restaurar el respaldo (los roles `visor`, `admin` y
`dueno_auditoria` deben existir): `pg_restore -d hospital backup/hospital_p2.backup`.

## Cómo ejecutar el ORM

```bash
cd orm
HOSPITAL_DB_PASSWORD=<clave de visor> mvn -q compile exec:java -Dexec.args="2026-01-01 2026-10-31"
HOSPITAL_DB_PASSWORD=<clave de visor> mvn -q compile exec:java -Dexec.mainClass=gt.cunoc.hospital.orm.Comparar
```

## Entorno

- PostgreSQL 18 (Docker, puerto 5433), zona horaria `America/Guatemala`.
- Java 21 y Maven 3.6; Python 3 con `reportlab` y `Pillow` para generar las capturas y el PDF.
