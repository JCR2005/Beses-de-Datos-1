"""Genera sql/02_insert.sql a partir de data/processed/*.csv para Firebird."""
from __future__ import annotations

import csv
from pathlib import Path
from typing import Any, Iterable

import pandas as pd


"""Aqui se guardan las rutas"""
BASE_DIR = Path(__file__).resolve().parents[1]
PROCESSED_DIR = BASE_DIR / "data" / "processed"
OUTPUT_FILE = BASE_DIR / "sql" / "02_insert.sql"

"""Orden de las tablas para respetar las claves foráneas al generar los inserts."""
TABLE_ORDER = [
    "country",
    "competition",
    "season",
    "competition_season",
    "team",
    "coach",
    "team_ranking",
    "venue",
    "stadium",
    "stage",
    "player",
    "MATCH",
    "match_team_stats",
    "match_team_coach",
    "lineup",
    "EVENT",
]


"""Mapeo de nombres de tablas a nombres de archivos CSV si es distinto"""
CSV_NAME_MAP = {
    "country": "countries",
    "competition": "competitions",
    "season": "seasons",
    "competition_season": "competition_seasons",
    "team": "teams",
    "coach": "coaches",
    "player": "players",
    "venue": "venues",
    "stadium": "stadiums",
    "stage": "stages",
    "MATCH": "matches",
    "match_team_stats": "match_team_stats",
    "match_team_coach": "match_team_coaches",
    "lineup": "lineups",
    "EVENT": "events",
    "team_ranking": "team_rankings",
}


"""Convierte un valor de pandas a su representación SQL adecuada
- NaN o None se convierte a NULL
- Números se convierten a su representación sin comillas
- Cadenas se escapan y se encierran entre comillas simples
- Booleanos se convierten a 1 o 0
- Fechas se convierten a 'YYYY-MM-DD' o 'YYYY-MM-DD HH:MM:SS' según corresponda
"""

def to_sql_value(value: Any) -> str:
    if pd.isna(value):
        return "NULL"
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        if isinstance(value, float) and value.is_integer():
            return str(int(value))
        return str(value)
    text = str(value).replace("'", "''")
    return f"'{text}'"



## Genera una sentencia INSERT a partir de una fila de un DataFrame y el nombre de la tabla correspondiente.
def insert_statement(table: str, row: pd.Series) -> str:
    columns = ", ".join(row.index)
    values = ", ".join(to_sql_value(row[col]) for col in row.index)
    table_name = table
    if table in {"MATCH", "EVENT"}: #Caso especial para tablas con nombres reservados en fire bird
        table_name = f'"{table}"'
    return f"INSERT INTO {table_name} ({columns}) VALUES ({values});\n"


def main() -> None:
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True) #crea la carpte si no existe
    with OUTPUT_FILE.open("w", encoding="utf-8") as out:  #abre el archivo para escribir
        out.write("-- Inserts generados para Firebird\n\n")  #aqui escribo un ecabezado si quiero
        for table in TABLE_ORDER:  #aqui recorro las tablas en el orden definido para respetar las claves foráneas
            csv_name = CSV_NAME_MAP.get(table, table)   #busca el nombre del csv correspondiente a la tabla, si no hay un mapeo específico usa el nombre de la tabla
            csv_path = PROCESSED_DIR / f"{csv_name}.csv" #contruye la ruta al csv correspondiente a la tabla
            if not csv_path.exists(): #si no existe el csv para esa tabla, continua con la siguiente tabla
                continue
            df = pd.read_csv(csv_path)  #lee el csv correspondiente a la tabla en un cvs de pandas
            for _, row in df.iterrows():  #Recorremos filas
                out.write(insert_statement(table, row))  #aqui se genra el insert 
            out.write("\n") #aqui escribo un salto de linea entre tablas

    print(f"ultimaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa veessssss!!!!!!!!!!!!!! puata madeeeeeeeeeeeeeeeeeeeeeeeeee: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
