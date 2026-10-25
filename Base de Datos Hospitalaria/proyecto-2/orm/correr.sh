#!/bin/bash
# Corre el ORM: muestra los objetivos 8, 11 y 18 y luego los compara con el SQL.
# Pide la clave del rol visor (no se guarda en ningun lado).
#
# Uso:  ./correr.sh                         (lapso enero a octubre de 2026)
#       ./correr.sh 2026-03-01 2026-06-30   (otro lapso)

cd "$(dirname "$0")"
DESDE=${1:-2026-01-01}
HASTA=${2:-2026-10-31}

read -r -s -p "Clave de visor: " HOSPITAL_DB_PASSWORD
echo
export HOSPITAL_DB_PASSWORD

# los mensajes de Hibernate van a un archivo aparte para que no ensucien la pantalla
LOG=$(mktemp)

echo
echo "===== Objetivos 8, 11 y 18 con el ORM, del $DESDE al $HASTA ====="
if ! mvn -o -q compile exec:java -Dexec.args="$DESDE $HASTA" 2> "$LOG"; then
    echo "Fallo el ORM:"; tail -5 "$LOG"; rm -f "$LOG"; exit 1
fi

echo
echo "===== Comparacion: ORM contra las consultas SQL ====="
if ! mvn -o -q compile exec:java -Dexec.mainClass=gt.cunoc.hospital.orm.Comparar 2> "$LOG"; then
    echo "Fallo la comparacion:"; tail -5 "$LOG"; rm -f "$LOG"; exit 1
fi
rm -f "$LOG"
