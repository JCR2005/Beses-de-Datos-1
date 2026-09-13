# Proyecto 1 — Bases de Datos Hospitalarias (SBD1)

Base de datos para la cadena **Hospitales de Occidente**: control diario de actividades en
Consulta Externa, Emergencias, Cirugía y Hospitalización.

## Estructura

| Carpeta    | Contenido                                                        |
|------------|------------------------------------------------------------------|
| `modelo/`  | Diagrama del modelo de datos en notación Barker (.drawio) + imagen (.png) |
| `sql/ddl/` | Definición de la base de datos (tablas, CHECK de dominio, acciones referenciales en FK) |
| `sql/dml/` | Inserciones de datos ficticios de prueba |
| `sql/dcl/` | Roles/usuarios y asignación de privilegios (GRANT/REVOKE) |
| `backup/`  | Respaldo generado con pg_dump (estructura + datos) |
| `documentacion/` | PDF con imágenes del modelo, sentencias SQL y diccionario de datos |

## Entorno

- SGBD: PostgreSQL 18.6 (Docker, puerto 5433) — usuario `hospital`.