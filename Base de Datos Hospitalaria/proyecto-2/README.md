# Proyecto 2 — Consultas Avanzadas, Lógica del Negocio y Seguridad (SBD1)

Extensión de la base de datos del Proyecto 1 (`Proyecto_BD_Hospital/`) para la cadena
**Hospitales de Occidente**: 20 objetivos organizados en los bloques A a F del enunciado.
Es la misma base, extendida mediante migraciones que no borran nada de lo existente.

## Estructura

| Carpeta | Contenido |
|---------|-----------|
| `modelo/` | Modelo extendido en notación Barker: `modelo_barker_p2.drawio` (draw.io) e imagen `modelo_barker_p2.png`. El recuadro PERSONAL es el supertipo con sus subtipos MEDICO y ENFERMERO; la línea naranja es la relación recursiva «superior directo» |
| `sql/proyecto1/` | Copia de los scripts de creación del Proyecto 1 (`ddl/`, `dml/`, `dcl/`), para tener todo el SQL de la base en un solo lugar |
| `sql/ddl/` | Migración del modelo: `01_personal.sql` (supertipo y subtipos, Bloque B), `02_jerarquia.sql` (cadena de mando), `03_catalogos.sql` (catálogos que reemplazan los CHECK con muchas opciones) y `04_laboratorio_y_clinicas.sql` (clínicas y órdenes de laboratorio de consulta externa) |
| `sql/dml/` | Ampliación de datos ficticios de enero a octubre de 2026: red y personal, pacientes, consulta externa, emergencias y hospitalización, cirugía, facturación, exámenes y órdenes de laboratorio |
| `sql/consultas/` | Un archivo por objetivo (`objetivo_01.sql` … `objetivo_19.sql`) con su sentencia SELECT, que se ejecuta con el rol de solo lectura `visor`; el `objetivo_19.sql` es la propuesta de tablas del Bloque E (solo los CREATE TABLE, no se corre sobre la base del hospital). `rendimiento/` mide las dos formas del objetivo 17 |
| `sql/auditoria/` | Bloque F: bitácora automática de cambios sensibles (`01_auditoria.sql`) y su demostración (`02_prueba.sql`) |
| `orm/` | Proyecto Maven con Java 21 y JPA (Hibernate 6.6) para los objetivos 8, 11 y 18, con una clase que compara su resultado con el de las consultas SQL |
| `backup/` | Respaldo con pg_dump de la base final: `hospital_p2.backup` (formato custom) y `hospital_p2.sql` (texto plano) |
| `documentacion/` | `Proyecto2_Hospitales_de_Occidente.pdf` (modelo, diccionario de datos, los 20 objetivos con su sentencia y captura, ORM, normalización y auditoría), `capturas/` (resultado de cada objetivo), `rendimiento_objetivo_17.md`, los scripts que generan las capturas y el PDF, `descripciones_p2.py` (descripción de cada tabla y columna nueva o modificada) y `justificaciones_p2.py` (justificación de cada llave foránea nueva) |

## Roles

- `visor` (solo lectura): ejecuta las consultas y el ORM.
- `admin` (administrativo): dueño del esquema; ejecuta la extensión del modelo y crea la auditoría.

Las contraseñas no se guardan en el repositorio.

## Cómo reconstruir la base desde cero

Sobre una base vacía (`createdb hospital`), con el superusuario dueño de la base:

1. Proyecto 1: `sql/proyecto1/ddl/` (00 → 11), `sql/proyecto1/dml/` (01 → 99) y `sql/proyecto1/dcl/01_roles.sql`.
2. Proyecto 2, en este orden:
   - `sql/ddl/01_personal.sql` y `02_jerarquia.sql`
   - `sql/dml/` (01 → 06)
   - `sql/ddl/03_catalogos.sql` y `04_laboratorio_y_clinicas.sql` (se aplican sobre la base ya cargada)
   - `sql/dml/07_laboratorio_y_clinicas.sql`
   - `sql/auditoria/01_auditoria.sql` y `02_prueba.sql`

   Las demás consultas solo leen datos: se ejecutan con `visor` cuando se quieran ver.

O bien restaurar el respaldo (los roles `visor` y `admin` deben existir): `pg_restore -d hospital backup/hospital_p2.backup`.

## Cómo ejecutar el ORM

```bash
cd orm
./correr.sh
```

Pide la clave del rol `visor`, muestra los objetivos 8, 11 y 18 resueltos con el ORM y luego los compara
con las consultas SQL. Para otro lapso: `./correr.sh 2026-03-01 2026-06-30`.

## Entorno

- PostgreSQL 18 (Docker, puerto 5433), zona horaria `America/Guatemala`.
- Java 21 y Maven 3.6; Python 3 con `reportlab` y `Pillow` para generar las capturas y el PDF.
