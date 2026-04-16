# Proyecto 1 BD1 – ETL Champions y Mundial

Este repositorio incluye ETLs para normalizar datos de Champions League (finales 2010–2019)
y Copa del Mundo (1986, 2018, 2022). Los CSV se guardan en `data/processed/` y pueden cargarse en Firebird.

## Contenido
- `sql/01_schema.sql`: esquema de base de datos (Firebird).
- `scripts/etl_champions.py`: ETL de Champions.
- `scripts/etl_worldcup.py`: ETL de Copa del Mundo.
- `scripts/etl_extras.py`: ETL de CSVs adicionales y Messi.
- `data/processed/`: salida de CSVs (se generan al ejecutar el ETL).

## Datos de entrada
Se usan los archivos en `Archivos/Champios-20260304T184340Z-3-001/Champios`,
`Archivos/Copa del mundo-20260304T184238Z-3-001/Copa del mundo` y `Archivos/competitions.json`.

## Salida
Se generan los siguientes CSVs:
- `competitions.csv`
- `seasons.csv`
- `competition_seasons.csv`
- `teams.csv`
- `matches.csv`
- `players.csv`
- `lineups.csv`
- `events.csv`

## Notas
- El ETL de Mundial agrega las ediciones 1986, 2018 y 2022.
- La tabla `events` en SQL contiene solo las columnas solicitadas.

## Uso
Ejecutar Champions:

```bash
python3 main.py --dataset champions
```

Ejecutar Mundial:

```bash
python3 main.py --dataset worldcup
```

Ejecutar extras (rankings, históricos, Messi):

```bash
python3 main.py --dataset extras
```

Ejecutar todo:

```bash
python3 main.py --dataset all
```

## Análisis y gráficas
El script `analysis.py` genera las 30 consultas en forma de tablas y las gráficas
en `reports/tables/` y `reports/figures/` usando pandas, matplotlib y mplsoccer.

Por defecto, `analysis.py` se conecta a la base Firebird en
`/var/lib/firebird/3.0/data/bd1_final.fdb`. Puedes cambiarlo con la variable
de entorno `FIREBIRD_DSN` o editando `DEFAULT_DSN` dentro del script.

```bash
python3 analysis.py
```
