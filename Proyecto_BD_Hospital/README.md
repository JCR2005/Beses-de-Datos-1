# Proyecto 1 — Bases de Datos Hospitalarias (SBD1)

Base de datos para la cadena **Hospitales de Occidente**: control diario de actividades en
Consulta Externa, Emergencias, Cirugía y Hospitalización, personal, pacientes, facturación
en cuotas y archivo de calificaciones de la calidad del servicio.

## Estructura

| Carpeta | Contenido |
|---------|-----------|
| `modelo/` | Modelo en notación Barker: `modelo_barker.drawio` (editable), `modelo_barker.png` (completo) y `modelo_barker_parte1-3.png` (en franjas para imprimir). `generar_modelo.py` los genera a partir del esquema |
| `sql/ddl/` | Definición de la base: tablas, CHECK de dominio, acciones referenciales, vistas, reglas de negocio (disparadores), índices y descripciones |
| `sql/dml/` | Inserciones de datos ficticios de prueba |
| `sql/dcl/` | Roles `visor` (solo lectura) y `admin` (privilegios completos) |
| `backup/` | Respaldo con pg_dump: `hospital.backup` (formato custom) y `hospital.sql` (texto plano) |
| `documentacion/` | `Diccionario_Datos_Hospital.pdf` con el modelo, el diccionario de datos y todas las sentencias SQL. `generar_diccionario.py` lo genera; `justificaciones.py` contiene la justificación de cada llave foránea, que el enunciado pide solo en el PDF |

## Scripts DDL

| Script | Contenido |
|--------|-----------|
| `00_esquema.sql` | Convenciones, zona horaria y función `fn_edad` |
| `01_geografia.sql` | Departamentos y municipios |
| `02_hospital.sql` | Hospitales, unidades, servicios, camillas y quirófanos |
| `03_personal.sql` | Especialidades, médicos, enfermeros y turnos de emergencia |
| `04_recursos.sql` | Insumos, instrumentos, equipos, medicamentos y diagnósticos CIE-10 |
| `05_pacientes.sql` | Pacientes, encargados y sus catálogos |
| `06_consulta_externa.sql` | Citas, consultas y recetas |
| `07_fichas.sql` | Fichas de ingreso, egreso y traslado |
| `08_cirugia.sql` | Agendamiento, preoperatorio, cirugía y registro por etapa |
| `09_hospitalizacion.sql` | Insumos de hospitalización |
| `10_facturacion.sql` | Facturas y pagos en cuotas |
| `11_calificaciones.sql` | Archivo de calificaciones |
| `12_vistas.sql` | Datos derivados: edad, días hospitalizado, hospital y saldo de cada factura |
| `13_reglas_negocio.sql` | Disparadores para las reglas que involucran más de una tabla |
| `14_indices.sql` | Índices en llaves foráneas y fechas |
| `15_comentarios.sql` | Descripción de cada tabla y columna (la usa el diccionario) |

## Cómo reconstruir la base

Sobre una base vacía (`createdb hospital`), ejecutar en orden:

1. `sql/ddl/` (00 → 15)
2. `sql/dml/` (01 → 99)
3. `sql/dcl/01_roles.sql`, y luego asignar contraseñas con `\password visor` y `\password admin`

O restaurar el respaldo: `pg_restore -d hospital backup/hospital.backup`.

Para regenerar el modelo y el PDF (con la base en marcha):

```bash
PGPASSWORD=... python3 modelo/generar_modelo.py
PGPASSWORD=... python3 documentacion/generar_diccionario.py
```

## Entorno

- SGBD: PostgreSQL 18 (Docker, puerto 5433) — dueño `hospital`, zona horaria `America/Guatemala`.
- Generadores: Python 3 con `reportlab` y `Pillow`, y Graphviz (`dot`).

## Proyecto 2

El Proyecto 2 extiende esta misma base y está en
[`../Base de Datos Hospitalaria/proyecto-2/`](../Base%20de%20Datos%20Hospitalaria/proyecto-2/README.md):

| Carpeta | Contenido |
|---------|-----------|
| `modelo/` | Modelo extendido en notación Barker (draw.io + imagen) |
| `sql/ddl/` | Migración: admin como dueño, supertipo PERSONAL, cadena de mando y descripciones |
| `sql/dml/` | Ampliación de datos de enero a octubre de 2026 |
| `sql/consultas/` | Una función por objetivo y la medición de rendimiento del objetivo 17 |
| `sql/auditoria/` | Bitácora automática de cambios sensibles y su demostración |
| `orm/` | Objetivos 8, 11 y 18 con Java y JPA (Hibernate) |
| `backup/` | Respaldo pg_dump de la base extendida |
| `documentacion/` | PDF con diccionario de datos, los 20 objetivos y sus capturas |

Después de aplicar el Proyecto 2, el dueño de los objetos del esquema es el rol `admin`.
