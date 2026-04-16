"""Genera consultas analíticas y gráficas del Proyecto 1.

Ejecuta sobre los CSVs en data/processed y guarda salidas en reports/.
"""
from __future__ import annotations

import os
from pathlib import Path
from typing import Dict, Optional

import fdb

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mplsoccer import Pitch

"""Constantes para la gestión de rutas y configuración."""
BASE_DIR = Path(__file__).resolve().parent
REPORTS_DIR = BASE_DIR / "reports"
FIGURES_DIR = REPORTS_DIR / "figures"
TABLES_DIR = REPORTS_DIR / "tables"
DEFAULT_DSN = os.getenv("FIREBIRD_DSN", "")
UCL_2015_EVENTS_MATCH_ID = 2015
WC2018_COMPETITION_SEASON_ID = 11
LALIGA_COMPETITION_NAME = "La Liga"


"""Funciones para conexión a la base de datos y carga de datos desde CSV como respaldo."""
def resolve_dsn() -> str:
    if DEFAULT_DSN:
        return DEFAULT_DSN
    candidates = [
        "localhost:/var/lib/firebird/3.0/data/bd1_final.fdb",
        "localhost:/tmp/bd1_final.fdb",
    ]
    for dsn in candidates:
        _, path = dsn.split(":", 1)
        try:
            if Path(path).exists():
                return dsn
        except PermissionError:
            continue
    return "localhost:/var/lib/firebird/3.0/data/bd1_final.fdb"
 

"""Devuelve una conexión a la base de datos Firebird usando el DSN resuelto o el valor por defecto."""
def get_connection(dsn: Optional[str] = None) -> fdb.Connection:
    dsn = dsn or resolve_dsn()
    return fdb.connect(dsn=dsn, user="SYSDBA", password="89c9dd1c")

""" Carga local de CSV para usar como respaldo cuando la BD no tenga datos """
def load_processed_data() -> Dict[str, pd.DataFrame]:
    data_dir = BASE_DIR / "data" / "processed"
    dfs: Dict[str, pd.DataFrame] = {}
    try:
        dfs["events"] = pd.read_csv(data_dir / "events.csv")
        dfs["matches"] = pd.read_csv(data_dir / "matches.csv")
        dfs["teams"] = pd.read_csv(data_dir / "teams.csv")
        dfs["players"] = pd.read_csv(data_dir / "players.csv")
        dfs["match_team_stats"] = pd.read_csv(data_dir / "match_team_stats.csv")
        dfs["stages"] = pd.read_csv(data_dir / "stages.csv")
        dfs["competitions"] = pd.read_csv(data_dir / "competitions.csv")
        dfs["competition_seasons"] = pd.read_csv(data_dir / "competition_seasons.csv")
        dfs["seasons"] = pd.read_csv(data_dir / "seasons.csv")
    except FileNotFoundError:
        # Si falta algún CSV, devolvemos lo que tengamos y los fallback fallarán en vacío.
        pass
    return dfs


"""Funciones para guardar tablas y figuras generadas a partir de los datos."""
def save_table(df: pd.DataFrame, filename: str) -> None:
    TABLES_DIR.mkdir(parents=True, exist_ok=True)
    df.to_csv(TABLES_DIR / filename, index=False)



"""Funciones para guardar gráficos generados a partir de los datos."""
def save_barplot(df: pd.DataFrame, x: str, y: str, title: str, filename: str, rotation: int = 45) -> None:
    if df.empty: return
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    fig, ax = plt.subplots(figsize=(10, 6))
    bars = ax.bar(df[x].astype(str), df[y], color='#60a5fa', edgecolor='#1f2937', linewidth=0.6)
    ax.set_title(title)
    ax.set_ylabel(y)
    ax.set_xlabel(x)
    ax.tick_params(axis="x", rotation=rotation)
    ax.grid(axis='y', linestyle='--', alpha=0.3)
    # etiquetas sobre cada barra
    for bar in bars:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2, height, f"{height:.1f}" if isinstance(height, float) else f"{height}",
                ha='center', va='bottom', fontsize=8, color='#111827', rotation=0)
    fig.tight_layout()
    fig.savefig(FIGURES_DIR / filename, dpi=150)
    plt.close(fig)


"""Función para guardar un gráfico de líneas generado a partir de los datos."""
def save_lineplot(df: pd.DataFrame, x: str, y: str, title: str, filename: str) -> None:
    if df.empty: return
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(df[x].astype(str), df[y], marker="o", color='#10b981', linewidth=2.4, markersize=6)
    ax.set_title(title)
    ax.set_ylabel(y)
    ax.set_xlabel(x)
    ax.tick_params(axis="x", rotation=45)
    ax.grid(True, linestyle="--", alpha=0.5)
    fig.tight_layout()
    fig.savefig(FIGURES_DIR / filename, dpi=150)
    plt.close(fig)


"""Función para guardar un gráfico con un solo valor destacado  generado a partir de los datos."""
def save_single_value(df: pd.DataFrame, title: str, filename: str) -> None:
    if df.empty:
        return
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    col = df.columns[0]
    value = df[col].iloc[0]
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.axis("off")
    display_value = f"{value:.2f}" if isinstance(value, (float, int)) else f"{value}"
    ax.text(0.5, 0.7, title, ha="center", va="center", fontsize=14, fontweight="bold")
    ax.text(0.5, 0.45, display_value, ha="center", va="center", fontsize=42, color="#38f842", fontweight="bold")
    ax.text(0.5, 0.2, col.replace("_", " "), ha="center", va="center", fontsize=11, color="#6b7280")
    fig.tight_layout()
    fig.savefig(FIGURES_DIR / filename, dpi=150)
    plt.close(fig)


"""Función para guardar un gráfico de mapa de calor de eventos generado a partir de los datos."""
def save_heatmap(df: pd.DataFrame, x_col: str, y_col: str, title: str, filename: str) -> None:
    if df.empty or x_col not in df.columns or y_col not in df.columns: return
    df = df.dropna(subset=[x_col, y_col])
    if df.empty: return
    
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    pitch = Pitch(pitch_type="statsbomb", pitch_color="#0b1224", line_color="#e5e7eb", line_zorder=2)
    fig, ax = pitch.draw(figsize=(9.5, 6.8))
    bin_stat = pitch.bin_statistic(df[x_col], df[y_col], statistic="count", bins=(36, 24))
    heatmap = pitch.heatmap(bin_stat, ax=ax, cmap="inferno", edgecolors="#0b1224", alpha=0.92)
    pitch.scatter(df[x_col], df[y_col], s=8, color="#f8fafc", alpha=0.28, ax=ax, zorder=3)
    cbar = fig.colorbar(heatmap, ax=ax, shrink=0.78, pad=0.02)
    cbar.ax.set_ylabel("Frecuencia", color="#e5e7eb")
    ax.set_title(title, color="#e5e7eb", fontsize=12, pad=10)
    fig.savefig(FIGURES_DIR / filename, dpi=150)
    plt.close(fig)


"""Función para guardar un gráfico de mapa de pases generado a partir de los datos."""
def save_pass_map(df: pd.DataFrame, title: str, filename: str) -> None:
    if df.empty or not all(col in df.columns for col in ['x', 'y', 'end_x', 'end_y']): return
    df = df.dropna(subset=['x', 'y', 'end_x', 'end_y'])
    if df.empty: return

    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    pitch = Pitch(pitch_type="statsbomb", pitch_color="#0a0f1f", line_color="#e5e7eb", line_zorder=2)
    fig, ax = pitch.draw(figsize=(9.5, 6.8))
    pitch.arrows(df["x"], df["y"], df["end_x"], df["end_y"], ax=ax,
                 width=1.5, headwidth=5, headlength=5.5, color="#38bdf8", alpha=0.55, zorder=3)
    pitch.scatter(df["x"], df["y"], s=16, color="#f59e0b", alpha=0.45, ax=ax, zorder=4, edgecolors="#0f172a", linewidth=0.4)
    ax.set_title(title, color="#e5e7eb", fontsize=12, pad=10)
    fig.savefig(FIGURES_DIR / filename, dpi=150)
    plt.close(fig)


"""Función para guardar un gráfico de mapa de tiros generado a partir de los datos."""
def save_placeholder_figure(title: str, filename: str, message: str = "Sin datos en la BD para graficar") -> None:
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.axis("off")
    ax.text(0.5, 0.6, title, ha="center", va="center", fontsize=12, fontweight="bold")
    ax.text(0.5, 0.4, message, ha="center", va="center", fontsize=10)
    fig.tight_layout()
    fig.savefig(FIGURES_DIR / filename, dpi=150)
    plt.close(fig)


"""Funciones para generar tablas y gráficos específicos a partir de los datos, con lógica de filtrado y agrupamiento."""
def _team_map(teams: pd.DataFrame) -> pd.Series:
    return teams.set_index("team_id")["team_name"] if not teams.empty else pd.Series(dtype=str)


"""Devuelve un DataFrame con solo los partidos del Mundial 2018 a partir del DataFrame de partidos completo."""
def _wc2018_matches(matches: pd.DataFrame) -> pd.DataFrame:
    if matches.empty or "competition_season_id" not in matches.columns:
        return pd.DataFrame()
    return matches[matches["competition_season_id"] == WC2018_COMPETITION_SEASON_ID].copy()


"""Devuelve un DataFrame con solo los partidos de La Liga a partir del DataFrame de partidos completo, usando los DataFrames de competiciones y temporadas para filtrar por nombre de competición."""
def _matches_by_competition(matches: pd.DataFrame, competition_seasons: pd.DataFrame,
                            competitions: pd.DataFrame, seasons: pd.DataFrame,
                            competition_name: str) -> pd.DataFrame:
    if matches.empty or competition_seasons.empty or competitions.empty or seasons.empty:
        return pd.DataFrame()
    cs = competition_seasons.merge(competitions, on="competition_id", how="left")
    cs = cs.merge(seasons, on="season_id", how="left")
    cs = cs[cs["competition_name"] == competition_name]
    if cs.empty:
        return pd.DataFrame()
    return matches.merge(cs[["competition_season_id", "season_name"]],
                         on="competition_season_id", how="inner")


"""Devuelve un DataFrame con la precisión de pases por equipo en un partido específico, calculada como el porcentaje de pases completos sobre el total de pases intentados."""
def precision_pases(events: pd.DataFrame, teams: pd.DataFrame, match_id: int) -> pd.DataFrame:
    if events.empty or teams.empty:
        return pd.DataFrame()
    df = events[events.match_id == match_id].copy()
    if df.empty:
        return df
    df["team_name"] = df["team_id"].map(_team_map(teams))
    df["is_pass"] = df["event_type"].fillna("").str.startswith("Pass")
    df["is_complete"] = df["is_pass"] & df["outcome"].isna()
    grouped = df.groupby("team_name").agg(
        pases=("is_pass", "sum"),
        pases_completos=("is_complete", "sum"),
    ).reset_index()
    grouped["precision_pct"] = grouped["pases_completos"] / grouped["pases"].replace({0: np.nan})
    return grouped.sort_values("precision_pct", ascending=False)

def tiros_goles(events: pd.DataFrame, teams: pd.DataFrame, match_id: int) -> pd.DataFrame:
    if events.empty or teams.empty:
        return pd.DataFrame()
    df = events[events.match_id == match_id].copy()
    if df.empty:
        return df
    df["team_name"] = df["team_id"].map(_team_map(teams))
    df["is_shot"] = df["event_type"].fillna("").str.startswith("Shot")
    grouped = df.groupby("team_name").agg(
        tiros=("is_shot", "sum"),
        goles=("is_goal", "sum"),
    ).reset_index()
    return grouped.sort_values("tiros", ascending=False)

def faltas(events: pd.DataFrame, teams: pd.DataFrame, match_id: int) -> pd.DataFrame:
    if events.empty or teams.empty:
        return pd.DataFrame()
    df = events[(events.match_id == match_id) & (events.event_type == "Foul Committed")].copy()
    if df.empty:
        return df
    df["team_name"] = df["team_id"].map(_team_map(teams))
    grouped = df.groupby("team_name").size().reset_index(name="faltas")
    return grouped.sort_values("faltas", ascending=False)

def tiros_por_minuto(events: pd.DataFrame, match_id: int) -> pd.DataFrame:
    df = events[(events.match_id == match_id) & (events.event_type.fillna("").str.startswith("Shot"))]
    if df.empty:
        return pd.DataFrame()
    grouped = df.groupby("minute_value").size().reset_index(name="tiros")
    grouped = grouped.rename(columns={"minute_value": "minuto"})
    return grouped.sort_values("minuto")

def goleadores(events: pd.DataFrame, players: pd.DataFrame, match_id: int) -> pd.DataFrame:
    if events.empty or players.empty:
        return pd.DataFrame()
    df = events[(events.match_id == match_id) & (events.is_goal == 1)].copy()
    if df.empty:
        return df
    df["player_name"] = df["player_id"].map(players.set_index("player_id")["player_name"])
    grouped = df.groupby("player_name").size().reset_index(name="goles")
    return grouped.sort_values("goles", ascending=False)

def heatmap_events(events: pd.DataFrame, teams: pd.DataFrame, match_id: int) -> pd.DataFrame:
    if events.empty:
        return pd.DataFrame()
    df = events[(events.match_id == match_id) & (events.event_type.fillna("").str.startswith("Shot"))].copy()
    df = df.dropna(subset=["x", "y"])
    if df.empty:
        return df
    df["team_name"] = df["team_id"].map(_team_map(teams))
    return df[["x", "y", "team_name"]]

def heatmap_player_events(events: pd.DataFrame, players: pd.DataFrame, match_id: int, player_name: str, event_prefix: str) -> pd.DataFrame:
    if events.empty or players.empty:
        return pd.DataFrame()
    player_ids = players[players.player_name.str.contains(player_name, case=False, na=False)]["player_id"].tolist()
    if not player_ids:
        return pd.DataFrame()
    df = events[(events.match_id == match_id) & (events.player_id.isin(player_ids)) & (events.event_type.fillna("").str.startswith(event_prefix))].copy()
    df = df.dropna(subset=["x", "y"])
    return df[["x", "y"]] if not df.empty else pd.DataFrame()

def heatmap_global(events: pd.DataFrame, teams: pd.DataFrame) -> pd.DataFrame:
    """Devuelve todas las posiciones de tiro del dataset (x, y, team_name)."""
    if events.empty:
        return pd.DataFrame()
    df = events[events.event_type.fillna("").str.startswith("Shot")].copy()
    df = df.dropna(subset=["x", "y"]) if not df.empty else df
    if df.empty:
        return df
    if not teams.empty:
        df["team_name"] = df["team_id"].map(_team_map(teams))
    else:
        df["team_name"] = df["team_id"].astype(str)
    return df[["x", "y", "team_name"]]

def goles_wc2018(matches: pd.DataFrame, teams: pd.DataFrame) -> pd.DataFrame:
    df = _wc2018_matches(matches)
    if df.empty or teams.empty:
        return pd.DataFrame()
    team_map = _team_map(teams)
    home = df[["home_team_id", "home_score"]].rename(columns={"home_team_id": "team_id", "home_score": "goles"})
    away = df[["away_team_id", "away_score"]].rename(columns={"away_team_id": "team_id", "away_score": "goles"})
    combined = pd.concat([home, away], ignore_index=True)
    combined["team_name"] = combined["team_id"].map(team_map)
    grouped = combined.groupby("team_name")["goles"].sum().reset_index()
    return grouped.sort_values("goles", ascending=False)

def victorias_wc2018(matches: pd.DataFrame, teams: pd.DataFrame) -> pd.DataFrame:
    df = _wc2018_matches(matches)
    if df.empty or teams.empty:
        return pd.DataFrame()
    team_map = _team_map(teams)
    home_wins = df[df.home_score > df.away_score][["home_team_id"]].rename(columns={"home_team_id": "team_id"})
    away_wins = df[df.away_score > df.home_score][["away_team_id"]].rename(columns={"away_team_id": "team_id"})
    winners = pd.concat([home_wins, away_wins], ignore_index=True)
    winners["team_name"] = winners["team_id"].map(team_map)
    grouped = winners.groupby("team_name").size().reset_index(name="victorias")
    return grouped.sort_values("victorias", ascending=False)

def promedio_goles_wc2018(matches: pd.DataFrame) -> pd.DataFrame:
    df = _wc2018_matches(matches)
    if df.empty:
        return pd.DataFrame()
    df["goles_partido"] = df["home_score"].fillna(0) + df["away_score"].fillna(0)
    return pd.DataFrame({"metric": ["Promedio goles por partido"], "valor": [df["goles_partido"].mean()]})

def goles_por_fase_wc2018(matches: pd.DataFrame, stages: pd.DataFrame) -> pd.DataFrame:
    df = _wc2018_matches(matches)
    if df.empty or stages.empty:
        return pd.DataFrame()
    df["goles_partido"] = df["home_score"].fillna(0) + df["away_score"].fillna(0)
    df = df.merge(stages, on="stage_id", how="left")
    grouped = df.groupby("stage_name")["goles_partido"].sum().reset_index(name="goles")
    return grouped.sort_values("goles", ascending=False)

def goles_laliga(matches: pd.DataFrame, teams: pd.DataFrame,
                 competition_seasons: pd.DataFrame, competitions: pd.DataFrame,
                 seasons: pd.DataFrame) -> pd.DataFrame:
    df = _matches_by_competition(matches, competition_seasons, competitions, seasons, LALIGA_COMPETITION_NAME)
    if df.empty or teams.empty:
        return pd.DataFrame()
    team_map = _team_map(teams)
    home = df[["home_team_id", "home_score"]].rename(columns={"home_team_id": "team_id", "home_score": "goles"})
    away = df[["away_team_id", "away_score"]].rename(columns={"away_team_id": "team_id", "away_score": "goles"})
    combined = pd.concat([home, away], ignore_index=True)
    combined["team_name"] = combined["team_id"].map(team_map)
    grouped = combined.groupby("team_name")["goles"].sum().reset_index()
    return grouped.sort_values("goles", ascending=False)

def victorias_laliga(matches: pd.DataFrame, teams: pd.DataFrame,
                     competition_seasons: pd.DataFrame, competitions: pd.DataFrame,
                     seasons: pd.DataFrame) -> pd.DataFrame:
    df = _matches_by_competition(matches, competition_seasons, competitions, seasons, LALIGA_COMPETITION_NAME)
    if df.empty or teams.empty:
        return pd.DataFrame()
    team_map = _team_map(teams)
    home_wins = df[df.home_score > df.away_score][["home_team_id"]].rename(columns={"home_team_id": "team_id"})
    away_wins = df[df.away_score > df.home_score][["away_team_id"]].rename(columns={"away_team_id": "team_id"})
    winners = pd.concat([home_wins, away_wins], ignore_index=True)
    winners["team_name"] = winners["team_id"].map(team_map)
    grouped = winners.groupby("team_name").size().reset_index(name="victorias")
    return grouped.sort_values("victorias", ascending=False)

def promedio_goles_laliga(matches: pd.DataFrame, competition_seasons: pd.DataFrame,
                          competitions: pd.DataFrame, seasons: pd.DataFrame) -> pd.DataFrame:
    df = _matches_by_competition(matches, competition_seasons, competitions, seasons, LALIGA_COMPETITION_NAME)
    if df.empty:
        return pd.DataFrame()
    df["goles_partido"] = df["home_score"].fillna(0) + df["away_score"].fillna(0)
    return pd.DataFrame({"metric": ["Promedio goles por partido"], "valor": [df["goles_partido"].mean()]})

def goles_por_temporada_laliga(matches: pd.DataFrame, competition_seasons: pd.DataFrame,
                               competitions: pd.DataFrame, seasons: pd.DataFrame) -> pd.DataFrame:
    df = _matches_by_competition(matches, competition_seasons, competitions, seasons, LALIGA_COMPETITION_NAME)
    if df.empty:
        return pd.DataFrame()
    df["goles_partido"] = df["home_score"].fillna(0) + df["away_score"].fillna(0)
    grouped = df.groupby("season_name")["goles_partido"].sum().reset_index(name="goles")
    return grouped.sort_values("season_name")

def pases_map(events: pd.DataFrame, teams: pd.DataFrame, match_id: int, team_name: str) -> pd.DataFrame:
    if events.empty or teams.empty:
        return pd.DataFrame()
    df = events[(events.match_id == match_id) & (events.event_type.fillna("").str.startswith("Pass"))].copy()
    df = df[df["team_id"].map(_team_map(teams)) == team_name]
    df = df.dropna(subset=["x", "y", "end_x", "end_y"])
    if df.empty:
        return pd.DataFrame()
    return df[["x", "y", "end_x", "end_y"]]

def pases_player_map(events: pd.DataFrame, players: pd.DataFrame, match_id: int, player_name: str) -> pd.DataFrame:
    if events.empty or players.empty:
        return pd.DataFrame()
    player_ids = players[players.player_name.str.contains(player_name, case=False, na=False)]["player_id"].tolist()
    if not player_ids:
        return pd.DataFrame()
    df = events[(events.match_id == match_id) & (events.player_id.isin(player_ids)) & (events.event_type.fillna("").str.startswith("Pass"))].copy()
    df = df.dropna(subset=["x", "y", "end_x", "end_y"])
    if df.empty:
        return pd.DataFrame()
    return df[["x", "y", "end_x", "end_y"]]

def stats_wc(mts: pd.DataFrame, teams: pd.DataFrame, match_range: tuple[int, int], column: str, alias: str, top: Optional[int] = None) -> pd.DataFrame:
    if mts.empty or teams.empty:
        return pd.DataFrame()
    low, high = match_range
    df = mts[(mts.match_id >= low) & (mts.match_id <= high)].copy()
    if df.empty:
        return pd.DataFrame()
    df["team_name"] = df["team_id"].map(_team_map(teams))
    grouped = df.groupby("team_name")[column].sum().reset_index(name=alias)
    grouped = grouped.sort_values(alias, ascending=False)
    if top:
        grouped = grouped.head(top)
    return grouped

def posesion_promedio_wc(mts: pd.DataFrame, teams: pd.DataFrame, match_range: tuple[int, int]) -> pd.DataFrame:
    if mts.empty or teams.empty:
        return pd.DataFrame()
    low, high = match_range
    df = mts[(mts.match_id >= low) & (mts.match_id <= high)].copy()
    if df.empty:
        return pd.DataFrame()
    df["team_name"] = df["team_id"].map(_team_map(teams))
    grouped = df.groupby("team_name")["possession_pct"].mean().reset_index(name="posesion_promedio")
    return grouped.sort_values("posesion_promedio", ascending=False)

def stats_partido(mts: pd.DataFrame, teams: pd.DataFrame, match_id: int) -> pd.DataFrame:
    if mts.empty or teams.empty:
        return pd.DataFrame()
    df = mts[mts.match_id == match_id].copy()
    if df.empty:
        return pd.DataFrame()
    df["team_name"] = df["team_id"].map(_team_map(teams))
    return df[["team_name", "possession_pct", "shots_total", "shots_on_target", "passes_completed"]]


"""Función para devolver un DataFrame con la precisión de pases por equipo en un rango de partidos específico, calculada como el porcentaje de pases completos sobre el total de pases intentados, permitiendo comparar la precisión de pase entre equipos a lo largo de varias etapas del Mundial 2018."""
def precision_pases_wc(mts: pd.DataFrame, teams: pd.DataFrame, match_range: tuple[int, int]) -> pd.DataFrame:
    if mts.empty or teams.empty:
        return pd.DataFrame()
    low, high = match_range
    df = mts[(mts.match_id >= low) & (mts.match_id <= high)].copy()
    if df.empty:
        return pd.DataFrame()
    df["team_name"] = df["team_id"].map(_team_map(teams))
    grouped = df.groupby("team_name").agg(
        pases_completos=("passes_completed", "sum"),
        pases_intentados=("passes_attempted", "sum"),
    ).reset_index()
    grouped["precision_pct"] = grouped["pases_completos"] / grouped["pases_intentados"].replace({0: np.nan})
    return grouped.sort_values("precision_pct", ascending=False)


"""Función para devolver un DataFrame con un resumen de estadísticas clave de un jugador específico en un partido específico, incluyendo conteo de eventos, pases, tiros, dribbles y goles, calculando métricas como precisión de pase y éxito de regate, para ofrecer una visión general del desempeño del jugador en ese partido."""
def resumen_player(events: pd.DataFrame, players: pd.DataFrame, match_id: int, player_name: str) -> pd.DataFrame:
    if events.empty or players.empty:
        return pd.DataFrame()
    pids = players[players.player_name.str.contains(player_name, case=False, na=False)]["player_id"].tolist()
    if not pids:
        return pd.DataFrame()
    df = events[(events.match_id == match_id) & (events.player_id.isin(pids))].copy()
    if df.empty:
        return pd.DataFrame()
    df["is_pass"] = df.event_type.fillna("").str.startswith("Pass")
    df["is_shot"] = df.event_type.fillna("").str.startswith("Shot")
    df["is_dribble"] = df.event_type.fillna("").str.contains("Dribble")
    df["is_carry"] = df.event_type == "Carry"
    df["pass_complete"] = df["is_pass"] & df["outcome"].isna()
    df["dribble_complete"] = df["is_dribble"] & df["outcome"].fillna("").str.contains("Complete")
    summary = {
        "metric": ["Eventos", "Pases", "Pases Completos", "Precisión Pase %", "Carries", "Dribbles", "Dribbles Exitosos", "Tiros", "Goles"],
        "valor": [
            len(df),
            df["is_pass"].sum(),
            df["pass_complete"].sum(),
            (df["pass_complete"].sum() / df["is_pass"].replace({0: np.nan}).sum()) * 100 if df["is_pass"].sum() else np.nan,
            df["is_carry"].sum(),
            df["is_dribble"].sum(),
            df["dribble_complete"].sum(),
            df["is_shot"].sum(),
            df["is_goal"].sum(),
        ],
    }
    return pd.DataFrame(summary)


"""Función para devolver un DataFrame con los jugadores más determinantes de un partido específico, calculando una métrica de impacto basada en goles, asistencias, tiros, pases completos y regates exitosos, y ordenando por esta métrica para identificar a los jugadores clave del partido."""
def determinantes_final(events: pd.DataFrame, players: pd.DataFrame, match_id: int, top: int = 10) -> pd.DataFrame:
    if events.empty or players.empty:
        return pd.DataFrame()
    df = events[events.match_id == match_id].copy()
    if df.empty:
        return pd.DataFrame()
    df["is_pass"] = df.event_type.fillna("").str.startswith("Pass")
    df["pass_complete"] = df["is_pass"] & df["outcome"].isna()
    df["is_shot"] = df.event_type.fillna("").str.startswith("Shot")
    df["is_dribble"] = df.event_type.fillna("").str.contains("Dribble")
    df["dribble_complete"] = df["is_dribble"] & df["outcome"].fillna("").str.contains("Complete")
    grouped = df.groupby("player_id").agg(
        goles=("is_goal", "sum"),
        asistencias=("is_assist", "sum"),
        tiros=("is_shot", "sum"),
        pases_completos=("pass_complete", "sum"),
        regates_exitosos=("dribble_complete", "sum"),
    ).reset_index()
    grouped["impacto"] = (
        grouped["goles"] * 5
        + grouped["asistencias"] * 3
        + grouped["tiros"] * 1
        + grouped["pases_completos"] * 0.1
        + grouped["regates_exitosos"] * 0.5
    )
    grouped["player_name"] = grouped["player_id"].map(players.set_index("player_id")["player_name"])
    grouped = grouped.dropna(subset=["player_name"])
    grouped = grouped.sort_values(["impacto", "goles", "asistencias"], ascending=False)
    if top:
        grouped = grouped.head(top)
    return grouped[["player_name", "impacto", "goles", "asistencias", "tiros", "pases_completos", "regates_exitosos"]]


"""Función para devolver un DataFrame con todos los eventos crudos de un jugador específico en un partido específico, filtrando por nombre del jugador y ID del partido, para usar en análisis detallados o detección de ausencia de datos a nivel granular."""
def eventos_player(events: pd.DataFrame, players: pd.DataFrame, match_id: int, player_name: str) -> pd.DataFrame:
    """Devuelve eventos crudos de un jugador en un partido (para detección de ausencia de datos)."""
    if events.empty or players.empty:
        return pd.DataFrame()
    pids = players[players.player_name.str.contains(player_name, case=False, na=False)]["player_id"].tolist()
    if not pids:
        return pd.DataFrame()
    return events[(events.match_id == match_id) & (events.player_id.isin(pids))]


"""Función para ejecutar una consulta SQL sobre la conexión a Firebird y devolver el resultado como un DataFrame, con manejo de excepciones para devolver un DataFrame vacío en caso de error (como falta de datos o problemas de conexión), lo que activa el mecanismo de fallback a los CSV procesados localmente."""
def run_query(connection: fdb.Connection, sql: str) -> pd.DataFrame:
    try:
        df = pd.read_sql(sql, connection)
        df.columns = df.columns.str.lower()
        return df
    except Exception:
        # Si falla la consulta (o la tabla está vacía) devolvemos DF vacío y activamos el fallback.
        return pd.DataFrame()

def main() -> None:
    try:
        connection = get_connection()
      
    except Exception as exc:
        connection = None
        print("No se pudo conectar a esa cosaaaaaa ({exc}).")

    fallback_data = load_processed_data() 

    fallback_funcs = {
        "q06_tiros_por_equipo_final_2019.png": lambda d: tiros_goles(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), 22912),
        "q07_heatmap_tiros_final_2019.png": lambda d: heatmap_events(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), 22912),
        "q08_pases_liverpool_final_2019.png": lambda d: pases_map(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), 22912, "Liverpool"),
        "q13_faltas_equipo_final_2019.png": lambda d: faltas(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), 22912),
        "q14_precision_pase_final_2019.png": lambda d: precision_pases(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), 22912),
        "q15_heatmap_tiros_arg_ing_1986.png": lambda d: heatmap_events(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), 3750191),
        "q16_tiros_goles_arg_ing_1986.png": lambda d: tiros_goles(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), 3750191),
        "q17_goleadores_arg_ing_1986.png": lambda d: goleadores(d.get("events", pd.DataFrame()), d.get("players", pd.DataFrame()), 3750191),
        "q18_tiros_por_minuto_arg_ing_1986.png": lambda d: tiros_por_minuto(d.get("events", pd.DataFrame()), 3750191),
        "q19_faltas_arg_ing_1986.png": lambda d: faltas(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), 3750191),
        "q20_precision_pase_arg_ing_1986.png": lambda d: precision_pases(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), 3750191),
        "q21_posesion_promedio_wc2022.png": lambda d: posesion_promedio_wc(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), (3913071, 3913134)),
        "q22_top_tiros_wc2022.png": lambda d: stats_wc(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), (3913071, 3913134), "shots_total", "tiros", top=10),
        "q23_top_tiros_arco_wc2022.png": lambda d: stats_wc(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), (3913071, 3913134), "shots_on_target", "tiros_arco", top=10),
    "q24_precision_pase_wc2022.png": lambda d: precision_pases_wc(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), (3913071, 3913134)),
        "q25_amarillas_wc2022.png": lambda d: stats_wc(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), (3913071, 3913134), "yellow_cards", "amarillas"),
        "q26_offsides_wc2022.png": lambda d: stats_wc(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), (3913071, 3913134), "offsides", "offsides"),
        "q27_corners_wc2022.png": lambda d: stats_wc(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), (3913071, 3913134), "corners", "corners"),
        "q28_final_wc2022_stats.png": lambda d: stats_partido(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), 3913134),
        "q29_semi_arg_cro_wc2022.png": lambda d: stats_partido(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), 3913131),
        "q30_semi_fra_mar_wc2022.png": lambda d: stats_partido(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), 3913132),
        "q31_heatmap_tiros_global.png": lambda d: heatmap_global(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame())),
        "q32_pases_maradona_arg_ing_1986.png": lambda d: pases_player_map(d.get("events", pd.DataFrame()), d.get("players", pd.DataFrame()), 3750191, "Maradona"),
        "q33_heatmap_carries_maradona_arg_ing_1986.png": lambda d: heatmap_player_events(d.get("events", pd.DataFrame()), d.get("players", pd.DataFrame()), 3750191, "Maradona", "Carry"),
        "q34_resumen_maradona_arg_ing_1986.png": lambda d: resumen_player(d.get("events", pd.DataFrame()), d.get("players", pd.DataFrame()), 3750191, "Maradona"),
        "q35_stats_final_2022_arg_fra.png": lambda d: stats_partido(d.get("match_team_stats", pd.DataFrame()), d.get("teams", pd.DataFrame()), 3913134),
        "q36_messi_final_2022.png": lambda d: eventos_player(d.get("events", pd.DataFrame()), d.get("players", pd.DataFrame()), 3913134, "Messi"),
    "q37_tiros_por_equipo_final_2015.png": lambda d: tiros_goles(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), UCL_2015_EVENTS_MATCH_ID),
    "q38_heatmap_tiros_final_2015.png": lambda d: heatmap_events(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), UCL_2015_EVENTS_MATCH_ID),
    "q39_pases_barcelona_final_2015.png": lambda d: pases_map(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), UCL_2015_EVENTS_MATCH_ID, "Barcelona"),
    "q40_precision_pase_final_2015.png": lambda d: precision_pases(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), UCL_2015_EVENTS_MATCH_ID),
    "q41_faltas_equipo_final_2015.png": lambda d: faltas(d.get("events", pd.DataFrame()), d.get("teams", pd.DataFrame()), UCL_2015_EVENTS_MATCH_ID),
    "q42_goleadores_final_2015.png": lambda d: goleadores(d.get("events", pd.DataFrame()), d.get("players", pd.DataFrame()), UCL_2015_EVENTS_MATCH_ID),
    "q43_resumen_messi_final_2015.png": lambda d: resumen_player(d.get("events", pd.DataFrame()), d.get("players", pd.DataFrame()), UCL_2015_EVENTS_MATCH_ID, "Messi"),
    "q44_jugadores_determinantes_final_2015.png": lambda d: determinantes_final(d.get("events", pd.DataFrame()), d.get("players", pd.DataFrame()), UCL_2015_EVENTS_MATCH_ID),
    "q45_goles_por_equipo_wc2018.png": lambda d: goles_wc2018(d.get("matches", pd.DataFrame()), d.get("teams", pd.DataFrame())),
    "q46_victorias_wc2018.png": lambda d: victorias_wc2018(d.get("matches", pd.DataFrame()), d.get("teams", pd.DataFrame())),
    "q47_promedio_goles_wc2018.png": lambda d: promedio_goles_wc2018(d.get("matches", pd.DataFrame())),
    "q48_goles_por_fase_wc2018.png": lambda d: goles_por_fase_wc2018(d.get("matches", pd.DataFrame()), d.get("stages", pd.DataFrame())),
    "q49_goles_por_equipo_laliga.png": lambda d: goles_laliga(d.get("matches", pd.DataFrame()), d.get("teams", pd.DataFrame()),
                                  d.get("competition_seasons", pd.DataFrame()), d.get("competitions", pd.DataFrame()),
                                  d.get("seasons", pd.DataFrame())),
    "q50_victorias_laliga.png": lambda d: victorias_laliga(d.get("matches", pd.DataFrame()), d.get("teams", pd.DataFrame()),
                                   d.get("competition_seasons", pd.DataFrame()), d.get("competitions", pd.DataFrame()),
                                   d.get("seasons", pd.DataFrame())),
    "q51_promedio_goles_laliga.png": lambda d: promedio_goles_laliga(d.get("matches", pd.DataFrame()),
                                      d.get("competition_seasons", pd.DataFrame()), d.get("competitions", pd.DataFrame()),
                                      d.get("seasons", pd.DataFrame())),
    "q52_goles_por_temporada_laliga.png": lambda d: goles_por_temporada_laliga(d.get("matches", pd.DataFrame()),
                                            d.get("competition_seasons", pd.DataFrame()), d.get("competitions", pd.DataFrame()),
                                            d.get("seasons", pd.DataFrame())),
    }

    queries = {
        "q01_goles_finales_ucl.png": """
            SELECT t.team_name,
                         SUM(CASE WHEN m.home_team_id = t.team_id THEN m.home_score ELSE 0 END
                             + CASE WHEN m.away_team_id = t.team_id THEN m.away_score ELSE 0 END) AS goles_totales
              FROM "MATCH" m
              JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
              JOIN competition c ON cs.competition_id = c.competition_id
              JOIN team t ON m.home_team_id = t.team_id OR m.away_team_id = t.team_id
             WHERE c.competition_name = 'Champions League'
             GROUP BY t.team_name
             ORDER BY goles_totales DESC
        """,
        "q02_top_visitantes_victorias.png": """
            SELECT t.team_name, COUNT(*) AS ganadores
              FROM "MATCH" m
              JOIN team t ON m.away_team_id = t.team_id
             WHERE m.away_score > m.home_score
             GROUP BY t.team_name
             ORDER BY ganadores DESC
        """,
        "q03_goles_por_final_ucl.png": """
            SELECT s.season_name,
                   SUM(m.home_score + m.away_score) AS total_goals
              FROM "MATCH" m
              JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
              JOIN competition c ON cs.competition_id = c.competition_id
              JOIN season s ON cs.season_id = s.season_id
             WHERE c.competition_name = 'Champions League'
             GROUP BY s.season_name
             ORDER BY s.season_name
        """,
        "q04_promedio_goles_final_ucl.png": """
            SELECT t.team_name,
                   AVG(CASE WHEN m.home_team_id = t.team_id THEN m.home_score ELSE m.away_score END) AS goles
              FROM "MATCH" m
              JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
              JOIN competition c ON cs.competition_id = c.competition_id
              JOIN team t ON t.team_id IN (m.home_team_id, m.away_team_id)
             WHERE c.competition_name = 'Champions League'
             GROUP BY t.team_name
             ORDER BY goles DESC
        """,
        "q05_mundiales_por_seleccion.png": """
            SELECT FIRST 10 t.team_name, COUNT(DISTINCT m.competition_season_id) as torneos
              FROM "MATCH" m JOIN team t ON (m.home_team_id = t.team_id)
             GROUP BY t.team_name ORDER BY torneos DESC
        """,
               "q06_tiros_por_equipo_final_2019.png": """
                  SELECT t.team_name,
                        SUM(CASE WHEN e.event_type LIKE 'Shot%' THEN 1 ELSE 0 END) AS tiros,
                        SUM(CASE WHEN e.event_type LIKE 'Shot%' AND e.outcome = 'Goal' THEN 1 ELSE 0 END) AS goles
                    FROM "EVENT" e
                    JOIN team t ON e.team_id = t.team_id
                   WHERE e.match_id = 22912
                   GROUP BY t.team_name
                   ORDER BY tiros DESC
               """,
                "q07_heatmap_tiros_final_2019.png": """
            SELECT e.x, e.y, t.team_name
              FROM "EVENT" e
              JOIN team t ON e.team_id = t.team_id
             WHERE e.match_id = 22912
               AND e.event_type LIKE 'Shot%'
               AND e.x IS NOT NULL AND e.y IS NOT NULL
        """,
                "q08_pases_liverpool_final_2019.png": """
                        SELECT e.x, e.y, e.end_x, e.end_y
                            FROM "EVENT" e
                            JOIN team t ON e.team_id = t.team_id
                         WHERE e.match_id = 22912
                             AND t.team_name = 'Liverpool'
                             AND e.event_type LIKE 'Pass%'
                             AND (e.outcome = 'Successful' OR e.outcome IS NULL)
                             AND e.x IS NOT NULL AND e.y IS NOT NULL
                             AND e.end_x IS NOT NULL AND e.end_y IS NOT NULL
                """,
               "q09_goles_equipo_cuartos_final_wc_1986.png": """
                  SELECT t.team_name,
                        SUM(CASE WHEN e.is_goal = 1 THEN 1 ELSE 0 END) AS goles
                    FROM "EVENT" e
                    JOIN team t ON e.team_id = t.team_id
                   WHERE e.match_id = 3750191
                   GROUP BY t.team_name
                   ORDER BY goles DESC
               """,
               "q10_goleadores_final_2019.png": """
                  SELECT p.player_name,
                        COUNT(*) AS goles_final
                    FROM "EVENT" e
                    JOIN player p ON e.player_id = p.player_id
                   WHERE e.match_id = 22912
                    AND e.is_goal = 1
                   GROUP BY p.player_name
                   ORDER BY goles_final DESC
               """,
                "q11_tiros_por_jugador_final_2019.png": """
                        SELECT p.player_name, COUNT(*) AS tiros
                            FROM "EVENT" e
                            JOIN player p ON e.player_id = p.player_id
                         WHERE e.match_id = 22912
                             AND e.event_type LIKE 'Shot%'
                         GROUP BY p.player_name
                         ORDER BY tiros DESC
                """,
                "q12_tiros_por_minuto_final_2019.png": """
                        SELECT e.minute_value AS minuto,
                                     COUNT(*) AS tiros
                            FROM "EVENT" e
                         WHERE e.match_id = 22912
                             AND e.event_type LIKE 'Shot%'
                         GROUP BY e.minute_value
                         ORDER BY minuto
                """,

        # 13. Faltas cometidas por equipo en la final UCL 2019
        "q13_faltas_equipo_final_2019.png": """
            SELECT t.team_name,
                   COUNT(*) AS faltas
              FROM "EVENT" e
              JOIN team t ON e.team_id = t.team_id
             WHERE e.match_id = 22912
               AND e.event_type = 'Foul Committed'
             GROUP BY t.team_name
             ORDER BY faltas DESC
        """,

        # 14. Precisión de pase por equipo en la final UCL 2019
       "q14_precision_pase_final_2019.png": """
          SELECT t.team_name,
                SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END) AS pases,
                SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS pases_completos,
                CAST(SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS DECIMAL(10,2)) /
                NULLIF(SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END), 0) AS precision_pct
            FROM "EVENT" e
            JOIN team t ON e.team_id = t.team_id
           WHERE e.match_id = 22912
           GROUP BY t.team_name
           ORDER BY precision_pct DESC
       """,

        # 15. Heatmap de tiros Argentina vs Inglaterra 1986
        "q15_heatmap_tiros_arg_ing_1986.png": """
            SELECT e.x, e.y, t.team_name
              FROM "EVENT" e
              JOIN team t ON e.team_id = t.team_id
             WHERE e.match_id = 3750191
               AND e.event_type LIKE 'Shot%'
               AND e.x IS NOT NULL AND e.y IS NOT NULL
        """,

        # 16. Tiros y goles por equipo Argentina vs Inglaterra 1986
        "q16_tiros_goles_arg_ing_1986.png": """
            SELECT t.team_name,
                   SUM(CASE WHEN e.event_type LIKE 'Shot%' THEN 1 ELSE 0 END) AS tiros,
                   SUM(CASE WHEN e.event_type LIKE 'Shot%' AND e.is_goal = 1 THEN 1 ELSE 0 END) AS goles
              FROM "EVENT" e
              JOIN team t ON e.team_id = t.team_id
             WHERE e.match_id = 3750191
             GROUP BY t.team_name
             ORDER BY tiros DESC
        """,

        # 17. Goleadores Argentina vs Inglaterra 1986
        "q17_goleadores_arg_ing_1986.png": """
            SELECT p.player_name,
                   COUNT(*) AS goles
              FROM "EVENT" e
              JOIN player p ON e.player_id = p.player_id
             WHERE e.match_id = 3750191
               AND e.is_goal = 1
             GROUP BY p.player_name
             ORDER BY goles DESC
        """,

        # 18. Tiros por minuto Argentina vs Inglaterra 1986
        "q18_tiros_por_minuto_arg_ing_1986.png": """
            SELECT e.minute_value AS minuto,
                   COUNT(*) AS tiros
              FROM "EVENT" e
             WHERE e.match_id = 3750191
               AND e.event_type LIKE 'Shot%'
             GROUP BY e.minute_value
             ORDER BY minuto
        """,

        # 19. Faltas por equipo Argentina vs Inglaterra 1986
        "q19_faltas_arg_ing_1986.png": """
            SELECT t.team_name,
                   COUNT(*) AS faltas
              FROM "EVENT" e
              JOIN team t ON e.team_id = t.team_id
             WHERE e.match_id = 3750191
               AND e.event_type = 'Foul Committed'
             GROUP BY t.team_name
             ORDER BY faltas DESC
        """,

        # 20. Precisión de pase Argentina vs Inglaterra 1986
       "q20_precision_pase_arg_ing_1986.png": """
          SELECT t.team_name,
                SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END) AS pases,
                SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS pases_completos,
                CAST(SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS DECIMAL(10,2)) /
                NULLIF(SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END), 0) AS precision_pct
            FROM "EVENT" e
            JOIN team t ON e.team_id = t.team_id
           WHERE e.match_id = 3750191
           GROUP BY t.team_name
           ORDER BY precision_pct DESC
       """,

        # 21. Posesión promedio por equipo Mundial 2022 (stats)
        "q21_posesion_promedio_wc2022.png": """
            SELECT t.team_name,
                   AVG(mts.possession_pct) AS posesion_promedio
              FROM match_team_stats mts
              JOIN team t ON mts.team_id = t.team_id
             WHERE mts.match_id BETWEEN 3913071 AND 3913134
             GROUP BY t.team_name
             ORDER BY posesion_promedio DESC
        """,

        # 22. Top 10 equipos por tiros totales Mundial 2022
        "q22_top_tiros_wc2022.png": """
            SELECT FIRST 10 t.team_name,
                   SUM(mts.shots_total) AS tiros
              FROM match_team_stats mts
              JOIN team t ON mts.team_id = t.team_id
             WHERE mts.match_id BETWEEN 3913071 AND 3913134
             GROUP BY t.team_name
             ORDER BY tiros DESC
        """,

        # 23. Top 10 equipos por tiros a puerta Mundial 2022
        "q23_top_tiros_arco_wc2022.png": """
            SELECT FIRST 10 t.team_name,
                   SUM(mts.shots_on_target) AS tiros_arco
              FROM match_team_stats mts
              JOIN team t ON mts.team_id = t.team_id
             WHERE mts.match_id BETWEEN 3913071 AND 3913134
             GROUP BY t.team_name
             ORDER BY tiros_arco DESC
        """,

        # 24. Precisión de pase por equipo Mundial 2022
       "q24_precision_pase_wc2022.png": """
          SELECT t.team_name,
                SUM(mts.passes_completed) AS pases_completos,
                SUM(mts.passes_attempted) AS pases_intentados,
                CAST(SUM(mts.passes_completed) AS DECIMAL(10,2)) /
                NULLIF(SUM(mts.passes_attempted), 0) AS precision_pct
            FROM match_team_stats mts
            JOIN team t ON mts.team_id = t.team_id
           WHERE mts.match_id BETWEEN 3913071 AND 3913134
           GROUP BY t.team_name
           ORDER BY precision_pct DESC
       """,

        # 25. Tarjetas amarillas por equipo Mundial 2022
        "q25_amarillas_wc2022.png": """
            SELECT t.team_name,
                   SUM(mts.yellow_cards) AS amarillas
              FROM match_team_stats mts
              JOIN team t ON mts.team_id = t.team_id
             WHERE mts.match_id BETWEEN 3913071 AND 3913134
             GROUP BY t.team_name
             ORDER BY amarillas DESC
        """,

        # 26. Offsides por equipo Mundial 2022
        "q26_offsides_wc2022.png": """
            SELECT t.team_name,
                   SUM(mts.offsides) AS offsides
              FROM match_team_stats mts
              JOIN team t ON mts.team_id = t.team_id
             WHERE mts.match_id BETWEEN 3913071 AND 3913134
             GROUP BY t.team_name
             ORDER BY offsides DESC
        """,

        # 27. Corners por equipo Mundial 2022
        "q27_corners_wc2022.png": """
            SELECT t.team_name,
                   SUM(mts.corners) AS corners
              FROM match_team_stats mts
              JOIN team t ON mts.team_id = t.team_id
             WHERE mts.match_id BETWEEN 3913071 AND 3913134
             GROUP BY t.team_name
             ORDER BY corners DESC
        """,

        # 28. Estadísticas de la final Mundial 2022 (ARG vs FRA)
        "q28_final_wc2022_stats.png": """
            SELECT t.team_name,
                   mts.possession_pct AS posesion,
                   mts.shots_total AS tiros,
                   mts.shots_on_target AS tiros_arco,
                   mts.passes_completed AS pases_completos
              FROM match_team_stats mts
              JOIN team t ON mts.team_id = t.team_id
             WHERE mts.match_id = 3913134
             ORDER BY tiros DESC
        """,

        # 29. Semifinal Argentina vs Croacia 2022
        "q29_semi_arg_cro_wc2022.png": """
            SELECT t.team_name,
                   mts.possession_pct AS posesion,
                   mts.shots_total AS tiros,
                   mts.shots_on_target AS tiros_arco,
                   mts.passes_completed AS pases_completos
              FROM match_team_stats mts
              JOIN team t ON mts.team_id = t.team_id
             WHERE mts.match_id = 3913131
             ORDER BY tiros DESC
        """,

        # 30. Semifinal Francia vs Marruecos 2022
        "q30_semi_fra_mar_wc2022.png": """
            SELECT t.team_name,
                   mts.possession_pct AS posesion,
                   mts.shots_total AS tiros,
                   mts.shots_on_target AS tiros_arco,
                   mts.passes_completed AS pases_completos
              FROM match_team_stats mts
              JOIN team t ON mts.team_id = t.team_id
             WHERE mts.match_id = 3913132
             ORDER BY tiros DESC
        """
                ,
                "q31_heatmap_tiros_global.png": """
                        SELECT e.x, e.y, t.team_name
                            FROM "EVENT" e
                            JOIN team t ON e.team_id = t.team_id
                         WHERE e.event_type LIKE 'Shot%'
                             AND e.x IS NOT NULL AND e.y IS NOT NULL
                """
                        ,
                        "q32_pases_maradona_arg_ing_1986.png": """
                                SELECT e.x, e.y, e.end_x, e.end_y
                                    FROM "EVENT" e
                                    JOIN player p ON e.player_id = p.player_id
                                 WHERE e.match_id = 3750191
                                     AND p.player_name LIKE '%Maradona%'
                                     AND e.event_type LIKE 'Pass%'
                                     AND e.x IS NOT NULL AND e.y IS NOT NULL
                                     AND e.end_x IS NOT NULL AND e.end_y IS NOT NULL
                        """
                                ,
                                "q33_heatmap_carries_maradona_arg_ing_1986.png": """
                                        SELECT e.x, e.y
                                            FROM "EVENT" e
                                            JOIN player p ON e.player_id = p.player_id
                                         WHERE e.match_id = 3750191
                                             AND p.player_name LIKE '%Maradona%'
                                             AND e.event_type = 'Carry'
                                             AND e.x IS NOT NULL AND e.y IS NOT NULL
                                """
                                ,
                                "q34_resumen_maradona_arg_ing_1986.png": """
                                        SELECT 'Eventos' AS metric, COUNT(*) AS valor
                                            FROM "EVENT" e
                                            JOIN player p ON e.player_id = p.player_id
                                         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%'
                                        UNION ALL
                                        SELECT 'Pases', COUNT(*)
                                            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
                                         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.event_type LIKE 'Pass%'
                                        UNION ALL
                                        SELECT 'Pases Completos', COUNT(*)
                                            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
                                         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.event_type LIKE 'Pass%' AND e.outcome IS NULL
                                        UNION ALL
                                        SELECT 'Carries', COUNT(*)
                                            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
                                         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.event_type = 'Carry'
                                        UNION ALL
                                        SELECT 'Dribbles', COUNT(*)
                                            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
                                         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.event_type LIKE '%Dribble%'
                                        UNION ALL
                                        SELECT 'Tiros', COUNT(*)
                                            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
                                         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.event_type LIKE 'Shot%'
                                        UNION ALL
                                        SELECT 'Goles', COUNT(*)
                                            FROM "EVENT" e JOIN player p ON e.player_id = p.player_id
                                         WHERE e.match_id = 3750191 AND p.player_name LIKE '%Maradona%' AND e.is_goal = 1
                                """
                                ,
                                "q35_stats_final_2022_arg_fra.png": """
                                        SELECT t.team_name,
                                                     mts.possession_pct AS posesion,
                                                     mts.shots_total AS tiros,
                                                     mts.shots_on_target AS tiros_arco,
                                                     mts.passes_completed AS pases_completos,
                                                     mts.passes_attempted AS pases_intentados,
                                                     mts.yellow_cards AS amarillas
                                            FROM match_team_stats mts
                                            JOIN team t ON mts.team_id = t.team_id
                                         WHERE mts.match_id = 3913134
                                         ORDER BY tiros DESC
                                """
                                        ,
                                        "q36_messi_final_2022.png": """
                                                SELECT e.*
                                                    FROM "EVENT" e
                                                    JOIN player p ON e.player_id = p.player_id
                                                 WHERE e.match_id = 3913134
                                                     AND p.player_name LIKE '%Messi%'
                                        """
                                        ,
                                "q37_tiros_por_equipo_final_2015.png": f"""
                                            SELECT t.team_name,
                                                   SUM(CASE WHEN e.event_type LIKE 'Shot%' THEN 1 ELSE 0 END) AS tiros,
                                                   SUM(CASE WHEN e.event_type LIKE 'Shot%' AND e.outcome = 'Goal' THEN 1 ELSE 0 END) AS goles
                                              FROM "EVENT" e
                                              JOIN team t ON e.team_id = t.team_id
                                    WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                             GROUP BY t.team_name
                                             ORDER BY tiros DESC
                                        """
                                        ,
                                "q38_heatmap_tiros_final_2015.png": f"""
                                                SELECT e.x, e.y, t.team_name
                                                    FROM "EVENT" e
                                                    JOIN team t ON e.team_id = t.team_id
                                        WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                     AND e.event_type LIKE 'Shot%'
                                                     AND e.x IS NOT NULL AND e.y IS NOT NULL
                                        """
                                        ,
                                "q39_pases_barcelona_final_2015.png": f"""
                                                SELECT e.x, e.y, e.end_x, e.end_y
                                                    FROM "EVENT" e
                                                    JOIN team t ON e.team_id = t.team_id
                                        WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                     AND t.team_name = 'Barcelona'
                                                     AND e.event_type LIKE 'Pass%'
                                                     AND (e.outcome = 'Successful' OR e.outcome IS NULL)
                                                     AND e.x IS NOT NULL AND e.y IS NOT NULL
                                                     AND e.end_x IS NOT NULL AND e.end_y IS NOT NULL
                                        """
                                        ,
                                "q40_precision_pase_final_2015.png": f"""
                                            SELECT t.team_name,
                                                   SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END) AS pases,
                                                   SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS pases_completos,
                                                   CAST(SUM(CASE WHEN e.event_type = 'Pass' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS DECIMAL(10,2)) /
                                                   NULLIF(SUM(CASE WHEN e.event_type = 'Pass' THEN 1 ELSE 0 END), 0) AS precision_pct
                                              FROM "EVENT" e
                                              JOIN team t ON e.team_id = t.team_id
                                    WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                             GROUP BY t.team_name
                                             ORDER BY precision_pct DESC
                                        """
                                        ,
                                "q41_faltas_equipo_final_2015.png": f"""
                                            SELECT t.team_name,
                                                   COUNT(*) AS faltas
                                              FROM "EVENT" e
                                              JOIN team t ON e.team_id = t.team_id
                                    WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                               AND e.event_type = 'Foul Committed'
                                             GROUP BY t.team_name
                                             ORDER BY faltas DESC
                                        """
                                                                                ,
                                                                                "q42_goleadores_final_2015.png": f"""
                                                                                        SELECT p.player_name,
                                                                                                     COUNT(*) AS goles
                                                                                            FROM "EVENT" e
                                                                                            JOIN player p ON e.player_id = p.player_id
                                                                                         WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                                                             AND e.is_goal = 1
                                                                                         GROUP BY p.player_name
                                                                                         ORDER BY goles DESC
                                                                                """
                                                                                ,
                                                                                "q43_resumen_messi_final_2015.png": f"""
                                                                                        SELECT 'Eventos' AS metric, COUNT(*) AS valor
                                                                                            FROM "EVENT" e
                                                                                            JOIN player p ON e.player_id = p.player_id
                                                                                         WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                                                             AND p.player_name LIKE '%Messi%'
                                                                                        UNION ALL
                                                                                        SELECT 'Pases', COUNT(*)
                                                                                            FROM "EVENT" e
                                                                                            JOIN player p ON e.player_id = p.player_id
                                                                                         WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                                                             AND p.player_name LIKE '%Messi%'
                                                                                             AND e.event_type LIKE 'Pass%'
                                                                                        UNION ALL
                                                                                        SELECT 'Pases Completos', COUNT(*)
                                                                                            FROM "EVENT" e
                                                                                            JOIN player p ON e.player_id = p.player_id
                                                                                         WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                                                             AND p.player_name LIKE '%Messi%'
                                                                                             AND e.event_type LIKE 'Pass%'
                                                                                             AND e.outcome IS NULL
                                                                                        UNION ALL
                                                                                        SELECT 'Carries', COUNT(*)
                                                                                            FROM "EVENT" e
                                                                                            JOIN player p ON e.player_id = p.player_id
                                                                                         WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                                                             AND p.player_name LIKE '%Messi%'
                                                                                             AND e.event_type = 'Carry'
                                                                                        UNION ALL
                                                                                        SELECT 'Dribbles', COUNT(*)
                                                                                            FROM "EVENT" e
                                                                                            JOIN player p ON e.player_id = p.player_id
                                                                                         WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                                                             AND p.player_name LIKE '%Messi%'
                                                                                             AND e.event_type LIKE '%Dribble%'
                                                                                        UNION ALL
                                                                                        SELECT 'Tiros', COUNT(*)
                                                                                            FROM "EVENT" e
                                                                                            JOIN player p ON e.player_id = p.player_id
                                                                                         WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                                                             AND p.player_name LIKE '%Messi%'
                                                                                             AND e.event_type LIKE 'Shot%'
                                                                                        UNION ALL
                                                                                        SELECT 'Goles', COUNT(*)
                                                                                            FROM "EVENT" e
                                                                                            JOIN player p ON e.player_id = p.player_id
                                                                                         WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                                                             AND p.player_name LIKE '%Messi%'
                                                                                             AND e.is_goal = 1
                                                                                """
                                                                                                                            ,
                                                                                                                            "q44_jugadores_determinantes_final_2015.png": f"""
                                                                                                                                    SELECT FIRST 10 p.player_name,
                                                                                                                                                 SUM(CASE WHEN e.is_goal = 1 THEN 1 ELSE 0 END) AS goles,
                                                                                                                                                 SUM(CASE WHEN e.is_assist = 1 THEN 1 ELSE 0 END) AS asistencias,
                                                                                                                                                 SUM(CASE WHEN e.event_type LIKE 'Shot%' THEN 1 ELSE 0 END) AS tiros,
                                                                                                                                                 SUM(CASE WHEN e.event_type LIKE 'Pass%' AND e.outcome IS NULL THEN 1 ELSE 0 END) AS pases_completos,
                                                                                                                                                 SUM(CASE WHEN e.event_type LIKE '%Dribble%' AND e.outcome LIKE '%Complete%' THEN 1 ELSE 0 END) AS regates_exitosos,
                                                                                                                                                 SUM(CASE WHEN e.is_goal = 1 THEN 1 ELSE 0 END) * 5
                                                                                                                                                 + SUM(CASE WHEN e.is_assist = 1 THEN 1 ELSE 0 END) * 3
                                                                                                                                                 + SUM(CASE WHEN e.event_type LIKE 'Shot%' THEN 1 ELSE 0 END) * 1
                                                                                                                                                 + SUM(CASE WHEN e.event_type LIKE 'Pass%' AND e.outcome IS NULL THEN 1 ELSE 0 END) * 0.1
                                                                                                                                                 + SUM(CASE WHEN e.event_type LIKE '%Dribble%' AND e.outcome LIKE '%Complete%' THEN 1 ELSE 0 END) * 0.5
                                                                                                                                                 AS impacto
                                                                                                                                        FROM "EVENT" e
                                                                                                                                        JOIN player p ON e.player_id = p.player_id
                                                                                                                                     WHERE e.match_id = {UCL_2015_EVENTS_MATCH_ID}
                                                                                                                                     GROUP BY p.player_name
                                                                                                                                     ORDER BY impacto DESC, goles DESC, asistencias DESC
                                                                                                                            """
                                                                                                                            ,
                                                                                                                    "q45_goles_por_equipo_wc2018.png": f"""
                                                                                                                        SELECT t.team_name,
                                                                                                                             SUM(CASE WHEN m.home_team_id = t.team_id THEN m.home_score ELSE 0 END
                                                                                                                                + CASE WHEN m.away_team_id = t.team_id THEN m.away_score ELSE 0 END) AS goles
                                                                                                                         FROM "MATCH" m
                                                                                                                         JOIN team t ON t.team_id IN (m.home_team_id, m.away_team_id)
                                                                                                                        WHERE m.competition_season_id = {WC2018_COMPETITION_SEASON_ID}
                                                                                                                        GROUP BY t.team_name
                                                                                                                        ORDER BY goles DESC
                                                                                                                    """
                                                                                                                    ,
                                                                                                                    "q46_victorias_wc2018.png": f"""
                                                                                                                        SELECT t.team_name,
                                                                                                                             SUM(CASE WHEN m.home_team_id = t.team_id AND m.home_score > m.away_score THEN 1 ELSE 0 END
                                                                                                                                + CASE WHEN m.away_team_id = t.team_id AND m.away_score > m.home_score THEN 1 ELSE 0 END) AS victorias
                                                                                                                         FROM "MATCH" m
                                                                                                                         JOIN team t ON t.team_id IN (m.home_team_id, m.away_team_id)
                                                                                                                        WHERE m.competition_season_id = {WC2018_COMPETITION_SEASON_ID}
                                                                                                                        GROUP BY t.team_name
                                                                                                                        ORDER BY victorias DESC
                                                                                                                    """
                                                                                                                    ,
                                                                                                                    "q47_promedio_goles_wc2018.png": f"""
                                                                                                                        SELECT AVG(m.home_score + m.away_score) AS promedio_goles
                                                                                                                         FROM "MATCH" m
                                                                                                                        WHERE m.competition_season_id = {WC2018_COMPETITION_SEASON_ID}
                                                                                                                    """
                                                                                                            ,
                                                                                                            "q48_goles_por_fase_wc2018.png": f"""
                                                                                                                SELECT s.stage_name,
                                                                                                                     SUM(m.home_score + m.away_score) AS goles
                                                                                                                 FROM "MATCH" m
                                                                                                                 JOIN stage s ON m.stage_id = s.stage_id
                                                                                                                WHERE m.competition_season_id = {WC2018_COMPETITION_SEASON_ID}
                                                                                                                GROUP BY s.stage_name
                                                                                                                ORDER BY goles DESC
                                                                                                            """
                                                                                                            ,
                                                                                                            "q49_goles_por_equipo_laliga.png": f"""
                                                                                                                SELECT t.team_name,
                                                                                                                       SUM(CASE WHEN m.home_team_id = t.team_id THEN m.home_score ELSE 0 END
                                                                                                                           + CASE WHEN m.away_team_id = t.team_id THEN m.away_score ELSE 0 END) AS goles
                                                                                                                  FROM "MATCH" m
                                                                                                                  JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
                                                                                                                  JOIN competition c ON cs.competition_id = c.competition_id
                                                                                                                  JOIN team t ON t.team_id IN (m.home_team_id, m.away_team_id)
                                                                                                                 WHERE c.competition_name = '{LALIGA_COMPETITION_NAME}'
                                                                                                                 GROUP BY t.team_name
                                                                                                                 ORDER BY goles DESC
                                                                                                            """
                                                                                                            ,
                                                                                                            "q50_victorias_laliga.png": f"""
                                                                                                                SELECT t.team_name,
                                                                                                                       SUM(CASE WHEN m.home_team_id = t.team_id AND m.home_score > m.away_score THEN 1 ELSE 0 END
                                                                                                                           + CASE WHEN m.away_team_id = t.team_id AND m.away_score > m.home_score THEN 1 ELSE 0 END) AS victorias
                                                                                                                  FROM "MATCH" m
                                                                                                                  JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
                                                                                                                  JOIN competition c ON cs.competition_id = c.competition_id
                                                                                                                  JOIN team t ON t.team_id IN (m.home_team_id, m.away_team_id)
                                                                                                                 WHERE c.competition_name = '{LALIGA_COMPETITION_NAME}'
                                                                                                                 GROUP BY t.team_name
                                                                                                                 ORDER BY victorias DESC
                                                                                                            """
                                                                                                            ,
                                                                                                            "q51_promedio_goles_laliga.png": f"""
                                                                                                                SELECT AVG(m.home_score + m.away_score) AS promedio_goles
                                                                                                                  FROM "MATCH" m
                                                                                                                  JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
                                                                                                                  JOIN competition c ON cs.competition_id = c.competition_id
                                                                                                                 WHERE c.competition_name = '{LALIGA_COMPETITION_NAME}'
                                                                                                            """
                                                                                                            ,
                                                                                                            "q52_goles_por_temporada_laliga.png": f"""
                                                                                                                SELECT s.season_name,
                                                                                                                       SUM(m.home_score + m.away_score) AS goles
                                                                                                                  FROM "MATCH" m
                                                                                                                  JOIN competition_season cs ON m.competition_season_id = cs.competition_season_id
                                                                                                                  JOIN competition c ON cs.competition_id = c.competition_id
                                                                                                                  JOIN season s ON cs.season_id = s.season_id
                                                                                                                 WHERE c.competition_name = '{LALIGA_COMPETITION_NAME}'
                                                                                                                 GROUP BY s.season_name
                                                                                                                 ORDER BY s.season_name
                                                                                                            """
    }

    # Recorrer, ejecutar y graficar
    for fig_name, sql in queries.items():
        try:
            df = run_query(connection, sql) if connection else pd.DataFrame()

         
            if (df.empty or df.dropna(how="all").empty) and fig_name in fallback_funcs:
                df = fallback_funcs[fig_name](fallback_data)

            csv_name = fig_name.replace('.png', '.csv')
            save_table(df, csv_name)

            title = fig_name.replace('.png', '').replace('q', 'C').replace('_', ' ').title()

            if 'heatmap' in fig_name:
                save_heatmap(df, 'x', 'y', title, fig_name)
            elif 'pases' in fig_name or 'mapa' in fig_name:
                save_pass_map(df, title, fig_name)
            elif 'red_pases' in fig_name:
                save_pass_map(df, title, fig_name)
            else:
                cols = list(df.columns)
                if len(cols) == 1:
                    save_single_value(df, title, fig_name)
                elif len(cols) >= 2:
                    # Diferenciar entre gráficos de línea y de barras
                    if 'evolucion' in fig_name or 'historicas' in fig_name:
                        save_lineplot(df, cols[0], cols[1], title, fig_name)
                    else:
                        save_barplot(df, cols[0], cols[1], title, fig_name)
                else:
                    save_placeholder_figure(title, fig_name)
            
            print(f" Generado: {fig_name}")
        except Exception as e:
            print(f" Error en {fig_name}: {e}")

    if connection:
        connection.close()

    # Placeholders en caso de fallo o datos insuficientes
    expected_figures = [(k, k.replace('.png', '')) for k in queries.keys()]
    
    for fig_name, title in expected_figures:
        fig_path = FIGURES_DIR / fig_name
        if not fig_path.exists():
            save_placeholder_figure(f"Datos faltantes: {title}", fig_name)
            
    print("\n salieroooooooooooooooooooooooooooon")

if __name__ == "__main__":
    main()