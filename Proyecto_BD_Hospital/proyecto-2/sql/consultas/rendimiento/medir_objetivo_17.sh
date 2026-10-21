#!/usr/bin/env bash
# Proyecto 2 - Objetivo 17: compara las dos formas del ranking al crecer los datos.
#
# Para cada escenario crea una copia de la base hospital, la infla con
# inflar.sql y mide con EXPLAIN ANALYZE el tiempo de ejecucion de cada forma
# (mediana de 3 corridas). La base entregada no se modifica.
#
# Uso: ./medir_objetivo_17.sh   (requiere el contenedor hospital-db en marcha)
# Salida: ../../../documentacion/rendimiento_objetivo_17.md

set -euo pipefail
cd "$(dirname "$0")"

CONTENEDOR=hospital-db
COPIA=hospital_rendimiento
SALIDA=../../../documentacion/rendimiento_objetivo_17.md
PSQL=(docker exec -i "$CONTENEDOR" psql -U hospital -v ON_ERROR_STOP=1 -q)

# escenarios: medicos adicionales y calificaciones adicionales
ESCENARIOS=("0 0" "500 10000" "2000 40000" "5000 100000")

mediana_ms() {   # $1 = funcion a medir
    for _ in 1 2 3; do
        "${PSQL[@]}" -d "$COPIA" -At -c \
          "explain (analyze, format json) select * from $1('2026-01-01', '2026-10-31')" |
          python3 -c "import json,sys; print(json.load(sys.stdin)[0]['Execution Time'])"
    done | sort -n | sed -n 2p
}

{
  echo "# Objetivo 17: rendimiento de las dos formas del ranking"
  echo
  echo "Tiempo de ejecución (mediana de 3 corridas de \`EXPLAIN ANALYZE\`, en milisegundos)."
  echo "Generado por \`sql/consultas/rendimiento/medir_objetivo_17.sh\` el $(date '+%Y-%m-%d %H:%M')."
  echo
  echo "| Médicos calificados | Calificaciones | A: ventana (ms) | B: correlacionada (ms) | B / A |"
  echo "|---:|---:|---:|---:|---:|"
} > "$SALIDA"

for escenario in "${ESCENARIOS[@]}"; do
    read -r medicos calificaciones <<< "$escenario"
    "${PSQL[@]}" -d postgres -c "drop database if exists $COPIA" -c "create database $COPIA template hospital"
    if [ "$medicos" -gt 0 ]; then
        "${PSQL[@]}" -d "$COPIA" -v medicos="$medicos" -v calificaciones="$calificaciones" < inflar.sql
    fi
    total_medicos=$("${PSQL[@]}" -d "$COPIA" -At -c "select count(*) from fn_promedio_medico('2026-01-01', '2026-10-31')")
    total_calif=$("${PSQL[@]}" -d "$COPIA" -At -c "select count(*) from calificacion where id_consulta is not null")
    a=$(mediana_ms fn_objetivo_17_ventana)
    b=$(mediana_ms fn_objetivo_17_correlacionada)
    razon=$(python3 -c "print(f'{$b / $a:.1f}x')")
    printf '| %s | %s | %.1f | %.1f | %s |\n' "$total_medicos" "$total_calif" "$a" "$b" "$razon" | tee -a "$SALIDA"
done

{
  echo
  echo "## Conclusión"
  echo
  echo "Con pocos médicos las dos formas tardan lo mismo, pero al crecer los datos la forma A"
  echo "(funciones de ventana) crece casi en proporción a los registros, mientras que la forma B"
  echo "(subconsultas correlacionadas) crece con el cuadrado del número de médicos: para cada"
  echo "médico vuelve a recorrer a todos los demás, dos veces (hospital y cadena). La forma A"
  echo "ordena una sola vez cada partición, así que es la que se recomienda para un reporte que"
  echo "se ejecuta con frecuencia sobre un volumen creciente."
  echo
  echo "## Plan de ejecución con el mayor volumen"
  echo
  echo "Forma A (ventana): un solo recorrido y ordenamientos para cada \`rank()\`."
  echo
  echo '```'
  "${PSQL[@]}" -d "$COPIA" -At -c "explain (analyze, costs off, timing off)
    select pm.id_medico, rank() over (partition by pm.id_hospital order by pm.promedio), rank() over (order by pm.promedio)
      from fn_promedio_medico('2026-01-01', '2026-10-31') pm"
  echo '```'
  echo
  echo "Forma B (correlacionada): las dos subconsultas se ejecutan una vez por cada médico (loops)."
  echo
  echo '```'
  "${PSQL[@]}" -d "$COPIA" -At -c "explain (analyze, costs off, timing off)
    with pm as materialized (select * from fn_promedio_medico('2026-01-01', '2026-10-31'))
    select p1.id_medico,
           1 + (select count(*) from pm p2 where p2.id_hospital = p1.id_hospital and p2.promedio < p1.promedio),
           1 + (select count(*) from pm p2 where p2.promedio < p1.promedio)
      from pm p1"
  echo '```'
} >> "$SALIDA"

"${PSQL[@]}" -d postgres -c "drop database if exists $COPIA"
echo "Resultado en $SALIDA"
