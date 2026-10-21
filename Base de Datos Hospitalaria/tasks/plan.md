# Plan de implementación: Proyecto 2 — Consultas avanzadas, lógica del negocio y seguridad

Entrega: **domingo 25 de octubre de 2026, 23:59**, en `Base de Datos Hospitalaria/proyecto-2/` del mismo repo (todo lo del Proyecto 2 va en `Base de Datos Hospitalaria/`, por indicación del usuario).
Base: la del Proyecto 1 reestructurada (PostgreSQL 18, Docker `hospital-db`, puerto 5433, BD `hospital`).

## Qué pide el enunciado

| Bloque | Objetivos | Entregable |
|---|---|---|
| A — Inteligencia de negocio | 1–14 | Una consulta por objetivo, filtrable por lapso de tiempo |
| B — Extensión del modelo | 15 | Migración DDL comentada: jerarquía de mando (relación recursiva) + supertipo `personal` con subtipos `medico` y `enfermero`; diagrama extendido en draw.io (Barker) |
| C — Reportes de personal | 16, 17 | 16: cadena de supervisión con CTE recursiva. 17: ranking por hospital y global, comparando al menos dos formas de escribir la consulta, con `EXPLAIN ANALYZE` mientras crece el volumen |
| D — Fidelidad | 18 | Pacientes atendidos en las 4 unidades (división relacional) |
| E — Normalización | 19 | Anomalías de `Reporte_Cirugia` + propuesta en 3FN con `CREATE TABLE` |
| F — Auditoría | 20 | Trigger que registra quién, qué campo, valor anterior, valor nuevo y cuándo; demostración con 2 cambios |

Requisitos transversales:
- `CHECK` en todo dominio cerrado nuevo.
- Acción `ON DELETE`/`ON UPDATE` decidida y justificada en cada FK nueva (justificación solo en el PDF).
- SQL comentado.
- De 15 a 20 registros por tabla relevante, todos ficticios.
- `visor` para las consultas; `admin` para el Bloque B y la auditoría.
- ORM en al menos 3 objetivos, con el mismo resultado que el SQL.
- Siempre parámetros enlazados, nunca concatenación.
- Capturas de los 20 resultados.
- PDF con el diccionario de las tablas nuevas o modificadas.
- Respaldo con `pg_dump`.
- README actualizado.
- Commits progresivos.

Carpetas exigidas: `modelo/`, `sql/ddl/`, `sql/dml/`, `sql/consultas/`, `sql/auditoria/` (el enunciado escribe "auditoría"; se usa sin tilde para evitar problemas de rutas), `orm/`, `backup/`, `documentacion/`.

## Decisiones de diseño

1. **Supertipo: tabla por jerarquía con PK compartida, sin borrar columnas.**
   - Se crea `personal` con los datos compartidos: nombres, apellidos, DPI, teléfono, dirección, municipio, área, hospital y fecha de contratación, más `salario` y `nivel_acceso`.
   - Tiene el discriminador `tipo_personal` con su `CHECK`.
   - `medico.id_medico` y `enfermero.id_enfermero` pasan a ser FK hacia `personal.id_personal`. Se usa una FK compuesta `(id, tipo_personal)` para que un médico solo pueda apuntar a personal de tipo médico.
   - Las columnas originales de los subtipos **no se borran**, porque el enunciado pide una extensión no destructiva. Un trigger las copia desde `personal` en cada insert o update, así que no pueden quedar distintas. Esta redundancia controlada se justifica en el PDF.
2. **Jerarquía en `medico`.**
   - `id_medico_superior` es una FK recursiva con `ON DELETE SET NULL`: si sale el jefe, el subordinado queda temporalmente sin superior y no se pierde su historia.
   - `cargo` tiene `CHECK` con los valores `director_medico`, `jefe_servicio` y `medico`.
   - Hay un solo director por hospital, garantizado con un índice único parcial.
   - Un trigger impide los ciclos y que el superior sea de otro hospital.
3. **`admin` como dueño del esquema.** El paso `00` lo ejecuta `hospital`, que es superusuario. Transfiere a `admin` la propiedad de las tablas, vistas, funciones y secuencias, y define los privilegios por defecto de `admin` para `visor`. A partir de ahí los Bloques B y F se ejecutan con `set role admin`.
4. **Consultas como funciones SQL** `fn_objetivo_XX(p_desde, p_hasta)`, una por archivo en `sql/consultas/`. Cada archivo trae un ejemplo de llamada. Así el "lapso de tiempo" es un parámetro, se cumple el objetivo de "utilizar funciones", y `visor` las ejecuta con `GRANT EXECUTE`.
5. **Ampliación de datos.**
   - Se agregan los hospitales 4 y 5, porque un "top 3" con solo 3 hospitales no dice nada.
   - Los datos cubren de enero a octubre de 2026.
   - Los volúmenes se generan con SQL determinista (`setseed` + `generate_series`), para que se reproduzcan igual cada vez. Los registros que se usan para explicar casos quedan escritos a mano.
6. **ORM: Java + JPA (Hibernate) + driver JDBC de PostgreSQL**, elegido por el usuario porque es lo que más ha usado. Proyecto Maven en `orm/`. Cubre los objetivos 8, 11 y 18 con consultas JPQL/Criteria y parámetros enlazados. Una clase compara fila por fila el resultado del ORM con el de la función SQL.
7. **Objetivo 17.**
   - Forma A: funciones de ventana `RANK() OVER (PARTITION BY hospital)` y `RANK() OVER ()`.
   - Forma B: subconsultas correlacionadas que cuentan cuántos médicos tienen mejor promedio.
   - Forma C, opcional: CTE con `JOIN` agregado.
   - Las mediciones con 1k, 10k y 100k calificaciones se hacen en una **copia** de la base, para no contaminar los datos entregados.
8. **Bloque E.** La propuesta en 3FN se crea en un esquema aparte, `propuesta_bloque_e`, para demostrar que los `CREATE TABLE` son válidos sin mezclarlos con el modelo.
9. **Capturas.** Un script ejecuta cada consulta como `visor` y genera la imagen PNG de su resultado. Si el ingeniero prefiere capturas de DBeaver, se reemplazan.
10. **Diagrama.** Se genera a partir de la base y en draw.io, extendiendo el del P1:
    - las entidades nuevas o modificadas van resaltadas;
    - `MEDICO` y `ENFERMERO` se dibujan dentro de `PERSONAL`, como pide Barker para los subtipos;
    - la relación recursiva va anotada.

## Métricas de los objetivos ambiguos (a validar con el ingeniero si hay duda)

| # | Cómo se mide |
|---|---|
| 1 | Por hospital: citas no canceladas + consultas + próximas consultas de las recetas, en el lapso. Se muestra cada componente y el total; top 3 por total |
| 2 | Médicos con citas de consulta externa: promedio de las calificaciones ligadas a sus consultas (1–5) y número de consultas; los 5 con menor promedio |
| 3 | Médicos con turnos de emergencia: turnos × 12 = horas; egresos "vivo" sin `sin_consentimiento` firmados por él; orden: egresos, horas, turnos |
| 4 | Ingresos a emergencias por hospital: % atendidos sin espera (`turnos_espera = 0`), promedio de turnos de espera, ingresos y egresos; top 3 por % sin espera y luego menor espera |
| 5 | Por cirujano: suma de insumos, instrumentos y equipos solicitados (cada uno en su columna) y agendamientos aprobados; orden: más aprobados y menos recursos por aprobado |
| 6 | Tipos de cirugía con mayor monto facturado, solo cirugías `sin_complicaciones` cuyos registros intraoperatorios son todos `exito` o `aceptable` |
| 7 | Hospitalización: monto facturado, camillas distintas asignadas, costo promedio del servicio y monto por camilla; top 3 por monto por camilla |
| 8 | Suma de pagos por método (efectivo, crédito, débito) por hospital y unidad |
| 9 | Monto facturado ÷ (ingresos + consultas + citas no canceladas); top 3 |
| 10 | Por hospital: fecha con más egresos "muerto" y la unidad con más decesos |
| 11 | Total facturado y total cobrado por hospital en el lapso |
| 12 | Ingresos a emergencias por hospital y jornada: edad promedio al ingreso y conteo por sexo |
| 13 | Citas por hospital, especialidad y sexo, ordenadas por fecha |
| 14 | Promedio de `numero_cuotas` por hospital y unidad en el lapso |

## Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Objetivos ambiguos (4, 5, 7, 9) | Alto | Métrica explícita en la tabla de arriba y en el PDF; mostrar cada componente para que se lea la decisión |
| `admin` no es dueño de las tablas | Alto | Tarea 1 transfiere la propiedad antes de cualquier migración |
| Volumen de datos insuficiente para rankings | Alto | Tareas 3–4 con conteos verificados por tabla (≥ 15) |
| Descargar Hibernate y el driver JDBC (Maven Central) | Medio | Confirmar con el usuario antes de descargar; verificar que Java y Maven estén instalados |
| Plazo de 5 días | Alto | Lo crítico primero (B, datos, consultas); el PDF y las capturas se generan con scripts |
| Defensa oral | Medio | Cada decisión documentada; consultas legibles con CTE nombradas |

## Preguntas abiertas
- ¿Acepta el ingeniero el criterio de las métricas ambiguas? Si cambia alguna, solo se ajusta su función.
- ¿Capturas generadas por script o de DBeaver?
- ¿Se aprueba descargar las dependencias de Maven para el ORM?
