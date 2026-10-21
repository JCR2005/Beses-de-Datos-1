# Tareas — Proyecto 2

Rutas relativas a `Base de Datos Hospitalaria/proyecto-2/`. Cada tarea termina con un commit.

## Fase 1: Base extendida

### Tarea 1: `admin` como dueño del esquema (S)
Transferir a `admin` la propiedad de los objetos del esquema y definir sus privilegios por defecto hacia `visor`.
- [x] `sql/ddl/00_propietario.sql` lo ejecuta `hospital` y es idempotente
- [x] Todas las tablas, vistas, funciones y secuencias son de `admin`
- [x] Un objeto creado por `admin` queda legible para `visor` sin `GRANT` manual
- **Verificación:** `set role admin; alter table medico add column x int;` funciona dentro de una transacción con `rollback`; `pg_tables.tableowner` = `admin`
- **Depende de:** nada

### Tarea 2: Bloque B — `personal`, subtipos y jerarquía (M)
- [x] `sql/ddl/01_personal.sql`:
  - `personal` con discriminador y `CHECK` en `tipo_personal`, `area`, `nivel_acceso`, `salario` y fechas;
  - FK compuesta de `medico` y `enfermero` hacia `personal`;
  - se copian los 35 registros existentes;
  - trigger de sincronización.
- [x] `sql/ddl/02_jerarquia.sql`: `id_medico_superior` (`SET NULL`), `cargo` con `CHECK`, un director por hospital, trigger contra ciclos y contra superiores de otro hospital
- [x] Todo se ejecuta con `set role admin` y está comentado (una línea por tabla y por `CHECK`)
- **Verificación:**
  - un update del teléfono en `personal` se refleja en `medico`;
  - un update directo del teléfono en `medico` lo revierte el trigger;
  - un ciclo A→B→A se rechaza;
  - un segundo director en el mismo hospital se rechaza;
  - un médico no puede apuntar a personal de tipo enfermero.
- **Depende de:** 1

### Tarea 3: Ampliación de datos I — red, personal y pacientes (M)
- [x] `sql/dml/01_red_y_personal.sql`:
  - hospitales 4 y 5 con sus unidades, servicios, camillas y quirófanos;
  - personal hasta unos 50 médicos y 20 enfermeros;
  - cargos y superiores de 3 o 4 niveles por hospital;
  - salario y nivel de acceso.
- [x] `sql/dml/02_pacientes.sql`: unos 60 pacientes y 20 encargados, con edades y sexos variados
- **Verificación:** conteos ≥ 15 en cada tabla tocada; la cadena de mando llega al director en todos los hospitales
- **Depende de:** 2

### Tarea 4: Ampliación de datos II — actividad clínica y financiera, enero–octubre 2026 (L → 4 archivos)
- [x] `03_consulta_externa.sql`: unas 200 citas en todos los estados, consultas, recetas con próxima cita y calificaciones ligadas a consultas
- [x] `04_emergencias_hospitalizacion.sql`: turnos con 2 o más médicos, ingresos con triage y espera variados, egresos con varios "muerto", hospitalizaciones con insumos, traslados
- [x] `05_cirugia.sql`: unos 40 agendamientos aprobados, rechazados y pendientes, con requerimientos de los 3 tipos, consentimiento, chequeo, cirugías con registros por aspecto (algunos con falla o "no aceptable") y algunas con complicaciones
- [x] `06_facturacion.sql`: facturas de cada origen, planes de 1 a 12 cuotas, pagos con los 3 métodos principales
- **Verificación:**
  - todos los triggers de reglas de negocio aceptan los datos;
  - hay ≥ 1 paciente atendido en las 4 unidades y ≥ 1 al que le falta una;
  - hay decesos en ≥ 3 hospitales.
- **Depende de:** 3

### Checkpoint 1
- [x] La base se reconstruye desde cero: P1 + P2 (`ddl`, `dml`) sin errores
- [x] Commit y push; revisión con el usuario

## Fase 2: Lógica y consultas

### Tarea 5: Bloque F — auditoría (S)
- [x] `sql/auditoria/01_auditoria.sql`:
  - tabla `auditoria_personal` con usuario de BD, usuario de aplicación (`app.usuario`), tabla, registro, campo, valor anterior, valor nuevo y `clock_timestamp()`;
  - triggers sobre `personal` (`salario`, `nivel_acceso`) y `medico` (`id_especialidad`);
  - función `security definer`;
  - nadie puede modificar la bitácora, ni siquiera `admin`.
- [x] `sql/auditoria/02_prueba.sql`: 2 o más cambios de prueba y la consulta de la bitácora
- **Verificación:** cada cambio genera una fila por campo; un update que no cambia el valor no genera nada; `delete from auditoria_personal` falla para `admin`
- **Depende de:** 2

### Tarea 6: Consultas 1–7 (M)
- [x] `sql/consultas/objetivo_01.sql` a `objetivo_07.sql`, cada una como `fn_objetivo_XX(desde, hasta)` con comentario del objetivo y la métrica
- **Verificación:** se ejecutan como `visor` con el rango ene–oct; devuelven filas con sentido; un caso de cada una se verifica a mano
- **Depende de:** 4

### Tarea 7: Consultas 8–14 (M)
- [x] `objetivo_08.sql` a `objetivo_14.sql`
- **Verificación:** igual que la tarea 6; el total del 11 cuadra con `sum(total)` de `factura`
- **Depende de:** 4

### Tarea 8: Consultas 16 y 18 + Bloque E (M)
- [x] `objetivo_16.sql`: `fn_cadena_mando(id_medico)` con CTE recursiva y nivel
- [x] `objetivo_18.sql`: división relacional con `not exists` doble y el álgebra en un comentario
- [x] `objetivo_19.sql`: propuesta en 3FN en el esquema `propuesta_bloque_e`, con datos de ejemplo
- **Verificación:** la cadena de un médico de nivel 4 devuelve 4 filas hasta el director; el 18 coincide con la versión `group by ... having count(distinct) = 4`
- **Depende de:** 4

### Tarea 9: Objetivo 17 — ranking y rendimiento (M)
- [x] `objetivo_17.sql`: forma A (ventana) y forma B (correlacionada) dan el mismo resultado
- [x] `objetivo_17_rendimiento.sql` + script que copia la base, la infla a 1k, 10k y 100k calificaciones y guarda los tiempos de `EXPLAIN ANALYZE`
- **Verificación:** `except` entre A y B devuelve 0 filas; tabla de tiempos con conclusión
- **Depende de:** 6

### Checkpoint 2
- [x] Las 20 consultas se ejecutan como `visor`; commit y push; revisión con el usuario

## Fase 3: ORM, evidencia y entrega

### Tarea 10: ORM (M)
- [x] `orm/`: proyecto Maven con JPA (Hibernate), entidades de las tablas usadas, objetivos 8, 11 y 18 con parámetros enlazados y una clase que compara con el SQL
- **Verificación:** `comparar.py` imprime "iguales" para los 3 objetivos; ningún valor entra concatenado al SQL
- **Depende de:** 7, 8

### Tarea 11: Capturas (S)
- [x] Script que ejecuta cada objetivo como `visor` y genera `documentacion/capturas/objetivo_XX.png`
- **Verificación:** 20 imágenes legibles
- **Depende de:** 5–9

### Tarea 12: Diagrama extendido en draw.io (S/M)
- [x] `modelo/generar_modelo.py` adaptado: subtipos dentro de `PERSONAL`, recursiva anotada, entidades nuevas resaltadas
- [x] Salidas: `.drawio` y `.png`
- **Verificación:** abre en diagrams.net; se ven el supertipo, los subtipos y la recursiva
- **Depende de:** 2, 5

### Tarea 13: PDF del Proyecto 2 (M)
- [ ] `documentacion/generar_documento.py`: modelo extendido, diccionario de las tablas nuevas o modificadas (con DELETE/UPDATE y justificación), las 20 consultas con su captura, el ORM, el Bloque E, la auditoría y la comparación de rendimiento
- **Verificación:** el PDF abre; están las 4 tablas de diccionario (`personal`, `medico`, `enfermero`, `auditoria_personal`)
- **Depende de:** 10–12

### Tarea 14: Respaldo, README y entrega (S)
- [ ] `backup/hospital_p2.backup`; README con la sección del Proyecto 2; push final
- **Verificación:** la restauración en una base nueva da los mismos conteos
- **Depende de:** 13

### Checkpoint final
- [ ] Se cumplen todos los entregables de la página 12 del enunciado
- [ ] Revisión con el usuario antes del 25/10
