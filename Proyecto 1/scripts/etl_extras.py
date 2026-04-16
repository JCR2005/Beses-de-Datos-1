"""ETL para CSVs adicionales y datos de Messi.
Genera CSVs listos para cargar en Firebird.
"""
from __future__ import annotations

import csv
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
import re

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[1]
ARCHIVOS_DIR = BASE_DIR / "Archivos"
WORLD_CUP_DIR = ARCHIVOS_DIR / "Copa del mundo-20260304T184238Z-3-001" / "Copa del mundo"
OUTPUT_DIR = BASE_DIR / "data" / "processed"

CSV_WORLD_CUP_MATCHES_2022 = WORLD_CUP_DIR / "Fifa_world_cup_matches_2022.csv"
CSV_WORLD_CUP_MATCHES = WORLD_CUP_DIR / "WorldCupMatches.csv"
CSV_WORLD_CUP_PLAYERS = WORLD_CUP_DIR / "WorldCupPlayers.csv"
CSV_FIFA_RANKINGS = WORLD_CUP_DIR / "fifa_ranking_2022-10-06.csv"
CSV_INTERNATIONAL_MATCHES = WORLD_CUP_DIR / "international_matches.csv"
CSV_MESSI_PASSES = ARCHIVOS_DIR / "messi_pases.csv"


def save_csv(df: pd.DataFrame, name: str) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUTPUT_DIR / f"{name}.csv"
    df.to_csv(path, index=False, quoting=csv.QUOTE_MINIMAL)


def load_existing_csv(name: str) -> pd.DataFrame:
    path = OUTPUT_DIR / f"{name}.csv"
    if path.exists():
        return pd.read_csv(path)
    return pd.DataFrame()


TEAM_ALIASES = {
    "usa": "United States",
    "united states of america": "United States",
    "us": "United States",
    "korea republic": "South Korea",
    "republic of korea": "South Korea",
    "ir iran": "Iran",
    "islamic republic of iran": "Iran",
    "russian federation": "Russia",
}


def normalize_text(value: Any) -> Optional[str]:
    if value is None or (isinstance(value, float) and pd.isna(value)):
        return None
    text = str(value).strip()
    if not text:
        return None
    return " ".join(text.split())


def derive_competition_type(name: Optional[str], is_international: Optional[bool]) -> Optional[str]:
    if not name:
        return None
    lowered = name.casefold()
    if "world cup" in lowered:
        return "NATIONAL"
    if "champions league" in lowered:
        return "CLUB"
    if is_international:
        return "INTERNATIONAL"
    return None


def derive_organizer(name: Optional[str]) -> Optional[str]:
    if not name:
        return None
    lowered = name.casefold()
    if "world cup" in lowered:
        return "FIFA"
    if "champions league" in lowered:
        return "UEFA"
    return None


def normalize_team_name(value: Any) -> Optional[str]:
    text = normalize_text(value)
    if not text:
        return None
    key = text.casefold()
    if key in TEAM_ALIASES:
        return TEAM_ALIASES[key]
    if text.isupper():
        return text.title()
    return text


def load_existing_dim(name: str, columns: List[str]) -> pd.DataFrame:
    df = load_existing_csv(name)
    if df.empty:
        return pd.DataFrame(columns=columns)
    for col in columns:
        if col not in df.columns:
            df[col] = None
    return df[columns]


def build_simple_dimension(
    values: pd.Series,
    existing_df: pd.DataFrame,
    id_col: str,
    name_col: str,
) -> Tuple[pd.DataFrame, Dict[str, int]]:
    existing_df = existing_df.copy()
    existing_df[name_col] = existing_df[name_col].apply(normalize_text)
    existing_map = {
        row[name_col]: int(row[id_col])
        for _, row in existing_df.dropna(subset=[name_col]).iterrows()
    }
    next_id = int(existing_df[id_col].max()) if not existing_df.empty else 0
    new_records: List[Dict[str, Any]] = []
    for value in values.dropna().unique().tolist():
        norm = normalize_text(value)
        if not norm:
            continue
        if norm not in existing_map:
            next_id += 1
            existing_map[norm] = next_id
            new_records.append({id_col: next_id, name_col: norm})
    combined = pd.concat([existing_df, pd.DataFrame(new_records)], ignore_index=True)
    return combined, existing_map


def build_stadium_dimension(
    matches_df: pd.DataFrame,
    existing_df: pd.DataFrame,
) -> Tuple[pd.DataFrame, Dict[Tuple[str, Optional[str]], int]]:
    existing_df = existing_df.copy()
    existing_df["stadium_name"] = existing_df["stadium_name"].apply(normalize_text)
    existing_df["city_name"] = existing_df["city_name"].apply(normalize_text)
    existing_map: Dict[Tuple[str, Optional[str]], int] = {}
    for _, row in existing_df.dropna(subset=["stadium_name"]).iterrows():
        key = (row["stadium_name"], row["city_name"])
        existing_map[key] = int(row["stadium_id"])
    next_id = int(existing_df["stadium_id"].max()) if not existing_df.empty else 0
    new_records: List[Dict[str, Any]] = []

    for stadium_name, city_name in matches_df[["stadium", "city"]].itertuples(index=False):
        if not stadium_name:
            continue
        key = (stadium_name, city_name)
        if key not in existing_map:
            next_id += 1
            existing_map[key] = next_id
            new_records.append({
                "stadium_id": next_id,
                "stadium_name": stadium_name,
                "city_name": city_name,
            })

    combined = pd.concat([existing_df, pd.DataFrame(new_records)], ignore_index=True)
    return combined, existing_map


def build_competition_season_dimension(
    new_df: pd.DataFrame,
    existing_df: pd.DataFrame,
) -> Tuple[pd.DataFrame, Dict[Tuple[int, int], int]]:
    existing_df = existing_df.copy()
    if not existing_df.empty:
        existing_df = existing_df.dropna(subset=["competition_id", "season_id"])
    existing_map: Dict[Tuple[int, int], int] = {}
    if not existing_df.empty:
        existing_df["competition_season_id"] = pd.to_numeric(
            existing_df["competition_season_id"],
            errors="coerce",
        )
        max_id = existing_df["competition_season_id"].max()
        next_id = int(max_id) if pd.notna(max_id) else 0
    else:
        next_id = 0
    for _, row in existing_df.dropna(subset=["competition_season_id"]).iterrows():
        key = (int(row["competition_id"]), int(row["season_id"]))
        existing_map[key] = int(row["competition_season_id"])

    new_records: List[Dict[str, Any]] = []
    existing_missing = existing_df[existing_df["competition_season_id"].isna()]
    for comp_id, season_id in existing_missing[["competition_id", "season_id"]].itertuples(index=False):
        key = (int(comp_id), int(season_id))
        if key not in existing_map:
            next_id += 1
            existing_map[key] = next_id
            new_records.append({
                "competition_season_id": next_id,
                "competition_id": int(comp_id),
                "season_id": int(season_id),
            })

    for comp_id, season_id in new_df[["competition_id", "season_id"]].dropna().itertuples(index=False):
        key = (int(comp_id), int(season_id))
        if key not in existing_map:
            next_id += 1
            existing_map[key] = next_id
            new_records.append({
                "competition_season_id": next_id,
                "competition_id": int(comp_id),
                "season_id": int(season_id),
            })

    combined = pd.concat([existing_df, pd.DataFrame(new_records)], ignore_index=True)
    return combined, existing_map


def merge_and_save(name: str, new_df: pd.DataFrame, subset: Optional[List[str]] = None) -> None:
    existing = load_existing_csv(name)
    combined = pd.concat([existing, new_df], ignore_index=True)
    if subset:
        combined = combined.drop_duplicates(subset=subset)
    else:
        combined = combined.drop_duplicates()
    save_csv(combined, name)


def update_teams_from_rankings(teams_df: pd.DataFrame, rankings_df: pd.DataFrame) -> pd.DataFrame:
    existing = teams_df.copy()
    existing["team_name"] = existing["team_name"].apply(normalize_team_name)
    existing_names = set(existing["team_name"].dropna().astype(str)) if not existing.empty else set()
    new_names = sorted({normalize_team_name(name) for name in rankings_df["team"].dropna().astype(str)} - existing_names)
    if not new_names:
        return existing

    next_id = int(existing["team_id"].max()) if not existing.empty else 0
    new_rows = []
    for name in new_names:
        next_id += 1
        new_rows.append({"team_id": next_id, "team_name": name})
    return pd.concat([existing, pd.DataFrame(new_rows)], ignore_index=True)


def update_teams_from_names(teams_df: pd.DataFrame, names: pd.Series) -> Tuple[pd.DataFrame, Dict[str, int]]:
    if teams_df.empty:
        teams_df = pd.DataFrame(columns=["team_id", "team_name"])
    teams_df = teams_df.copy()
    teams_df["team_name"] = teams_df["team_name"].apply(normalize_team_name)
    team_map = {
        row["team_name"]: int(row["team_id"])
        for _, row in teams_df.dropna(subset=["team_name"]).iterrows()
    }
    next_id = int(teams_df["team_id"].max()) if not teams_df.empty else 0
    new_rows: List[Dict[str, Any]] = []
    for name in names.dropna().astype(str).tolist():
        norm = normalize_team_name(name)
        if not norm:
            continue
        if norm not in team_map:
            next_id += 1
            team_map[norm] = next_id
            new_rows.append({"team_id": next_id, "team_name": norm})
    if new_rows:
        teams_df = pd.concat([teams_df, pd.DataFrame(new_rows)], ignore_index=True)
    return teams_df, team_map


def normalize_worldcup_matches_csv() -> pd.DataFrame:
    df = pd.read_csv(CSV_WORLD_CUP_MATCHES)
    df = df.rename(
        columns={
            "Year": "year_value",
            "Datetime": "datetime",
            "Stage": "stage",
            "Stadium": "stadium",
            "City": "city",
            "Home Team Name": "home_team_name",
            "Home Team Goals": "home_team_goals",
            "Away Team Goals": "away_team_goals",
            "Away Team Name": "away_team_name",
            "Win conditions": "win_conditions",
            "MatchID": "match_id",
            "Home Team Initials": "home_team_initials",
            "Away Team Initials": "away_team_initials",
        }
    )
    parsed_datetime = pd.to_datetime(df["datetime"], errors="coerce")
    df["match_date"] = parsed_datetime.dt.date
    df["kick_off"] = parsed_datetime.dt.strftime("%H:%M:%S.000")
    df["home_team_name"] = df["home_team_name"].apply(normalize_team_name)
    df["away_team_name"] = df["away_team_name"].apply(normalize_team_name)
    return df[
        [
            "match_id",
            "year_value",
            "match_date",
            "kick_off",
            "stage",
            "stadium",
            "city",
            "home_team_name",
            "home_team_goals",
            "away_team_goals",
            "away_team_name",
            "home_team_initials",
            "away_team_initials",
        ]
    ]


def normalize_worldcup_match_stats() -> pd.DataFrame:
    if not CSV_WORLD_CUP_MATCHES_2022.exists():
        return pd.DataFrame()
    df = pd.read_csv(CSV_WORLD_CUP_MATCHES_2022)
    df = df.rename(columns={
        "team1": "home_team_name",
        "team2": "away_team_name",
        "possession team1": "home_possession",
        "possession team2": "away_possession",
        "number of goals team1": "home_score",
        "number of goals team2": "away_score",
        "total attempts team1": "home_shots_total",
        "total attempts team2": "away_shots_total",
        "on target attempts team1": "home_shots_on_target",
        "on target attempts team2": "away_shots_on_target",
        "passes team1": "home_passes",
        "passes team2": "away_passes",
        "passes completed team1": "home_passes_completed",
        "passes completed team2": "away_passes_completed",
        "yellow cards team1": "home_yellow",
        "yellow cards team2": "away_yellow",
        "red cards team1": "home_red",
        "red cards team2": "away_red",
        "fouls against team1": "home_fouls_against",
        "fouls against team2": "away_fouls_against",
        "offsides team1": "home_offsides",
        "offsides team2": "away_offsides",
        "corners team1": "home_corners",
        "corners team2": "away_corners",
        "date": "match_date",
    })
    df["match_date"] = pd.to_datetime(df["match_date"], errors="coerce").dt.date
    df["home_team_name"] = df["home_team_name"].apply(normalize_team_name)
    df["away_team_name"] = df["away_team_name"].apply(normalize_team_name)
    return df


def normalize_worldcup_players_csv() -> pd.DataFrame:
    df = pd.read_csv(CSV_WORLD_CUP_PLAYERS)
    df = df.rename(
        columns={
            "RoundID": "round_id",
            "MatchID": "match_id",
            "Team Initials": "team_initials",
            "Coach Name": "coach_name",
            "Line-up": "line_up",
            "Shirt Number": "shirt_number",
            "Player Name": "player_name",
            "Position": "position_value",
            "Event": "event",
        }
    )
    df.insert(0, "id", range(1, len(df) + 1))
    return df[
        [
            "id",
            "match_id",
            "team_initials",
            "coach_name",
            "line_up",
            "shirt_number",
            "player_name",
            "position_value",
            "event",
        ]
    ]


def normalize_international_matches() -> pd.DataFrame:
    df = pd.read_csv(CSV_INTERNATIONAL_MATCHES)
    df = df.rename(
        columns={
            "date": "match_date",
            "home_team": "home_team",
            "away_team": "away_team",
            "home_team_continent": "home_team_continent",
            "away_team_continent": "away_team_continent",
            "home_team_fifa_rank": "home_team_fifa_rank",
            "away_team_fifa_rank": "away_team_fifa_rank",
            "home_team_total_fifa_points": "home_team_total_fifa_points",
            "away_team_total_fifa_points": "away_team_total_fifa_points",
            "home_team_score": "home_team_score",
            "away_team_score": "away_team_score",
            "tournament": "tournament",
            "city": "city",
            "country": "country",
        }
    )
    df["match_date"] = pd.to_datetime(df["match_date"], errors="coerce").dt.date
    df["home_team"] = df["home_team"].apply(normalize_team_name)
    df["away_team"] = df["away_team"].apply(normalize_team_name)
    return df[
        [
            "match_date",
            "home_team",
            "away_team",
            "home_team_continent",
            "away_team_continent",
            "home_team_fifa_rank",
            "away_team_fifa_rank",
            "home_team_total_fifa_points",
            "away_team_total_fifa_points",
            "home_team_score",
            "away_team_score",
            "tournament",
            "city",
            "country",
        ]
    ]


def normalize_fifa_rankings() -> pd.DataFrame:
    df = pd.read_csv(CSV_FIFA_RANKINGS)
    ranking_date = None
    match = None
    if CSV_FIFA_RANKINGS.name:
        match = re.search(r"(\d{4}-\d{2}-\d{2})", CSV_FIFA_RANKINGS.name)
    if match:
        ranking_date = match.group(1)
    df = df.rename(
        columns={
            "team": "team",
            "team_code": "team_code",
            "association": "association",
            "rank": "rank",
            "previous_rank": "previous_rank",
            "points": "points",
            "previous_points": "previous_points",
        }
    )
    df.insert(0, "id", range(1, len(df) + 1))
    df["ranking_date"] = ranking_date
    df["team"] = df["team"].apply(normalize_team_name)
    return df[
        [
            "id",
            "team",
            "team_code",
            "association",
            "rank",
            "previous_rank",
            "points",
            "previous_points",
            "ranking_date",
        ]
    ]


def build_team_rankings(rankings_df: pd.DataFrame, teams_df: pd.DataFrame) -> pd.DataFrame:
    team_lookup = teams_df.set_index("team_name")["team_id"].to_dict()
    rankings_df = rankings_df.copy()
    rankings_df["team_id"] = rankings_df["team"].map(team_lookup)
    rankings_df = rankings_df.dropna(subset=["team_id"]).copy()
    rankings_df["team_id"] = rankings_df["team_id"].astype(int)
    rankings_df = rankings_df.rename(
        columns={
            "id": "ranking_id",
            "rank": "rank_value",
        }
    )
    return rankings_df[
        [
            "ranking_id",
            "team_id",
            "ranking_date",
            "rank_value",
            "previous_rank",
            "points",
            "previous_points",
            "team_code",
            "association",
        ]
    ]


def normalize_fifa_matches_2022() -> pd.DataFrame:
    df = pd.read_csv(CSV_WORLD_CUP_MATCHES_2022)
    for col in ["possession team1", "possession team2", "possession in contest"]:
        if col in df.columns:
            df[col] = (
                df[col]
                .astype(str)
                .str.replace("%", "", regex=False)
                .replace("nan", None)
            )
    df = df.rename(
        columns={
            "team1": "team1",
            "team2": "team2",
            "possession team1": "possession_team1",
            "possession team2": "possession_team2",
            "possession in contest": "possession_in_contest",
            "number of goals team1": "goals_team1",
            "number of goals team2": "goals_team2",
            "date": "match_date",
            "hour": "match_hour",
            "category": "category",
        }
    )
    df["match_date"] = pd.to_datetime(df["match_date"], errors="coerce").dt.date
    df["team1"] = df["team1"].apply(normalize_team_name)
    df["team2"] = df["team2"].apply(normalize_team_name)
    return df[
        [
            "team1",
            "team2",
            "possession_team1",
            "possession_team2",
            "possession_in_contest",
            "goals_team1",
            "goals_team2",
            "match_date",
            "match_hour",
            "category",
        ]
    ]


def normalize_messi_passes() -> pd.DataFrame:
    df = pd.read_csv(CSV_MESSI_PASSES)
    df = df.rename(
        columns={
            "player": "player",
            "minute": "minute_value",
            "second": "second_value",
            "x": "x",
            "y": "y",
            "type": "pass_type",
            "outcome": "outcome",
            "endX": "end_x",
            "endY": "end_y",
        }
    )
    df.insert(0, "id", range(1, len(df) + 1))
    df["player"] = df["player"].apply(normalize_text)
    return df[["id", "player", "minute_value", "second_value", "x", "y", "pass_type", "outcome", "end_x", "end_y"]]


def dedupe_teams(teams_df: pd.DataFrame) -> Tuple[pd.DataFrame, Dict[int, int]]:
    teams_df = teams_df.copy()
    teams_df["team_name"] = teams_df["team_name"].apply(normalize_team_name)
    teams_df["name_key"] = teams_df["team_name"].str.casefold()
    teams_df = teams_df.sort_values("team_id")
    canonical = teams_df.drop_duplicates(subset=["name_key"], keep="first").copy()
    canonical_ids = canonical.set_index("name_key")["team_id"].to_dict()
    id_map = {
        int(row.team_id): int(canonical_ids.get(row.name_key, row.team_id))
        for row in teams_df.itertuples(index=False)
    }
    canonical = canonical.drop(columns=["name_key"])
    return canonical, id_map


def remap_team_ids(df: pd.DataFrame, columns: List[str], id_map: Dict[int, int]) -> pd.DataFrame:
    if df.empty:
        return df
    df = df.copy()
    for col in columns:
        if col in df.columns:
            df[col] = df[col].map(lambda value: id_map.get(int(value), int(value)) if pd.notna(value) else value)
    return df


def main() -> None:
    competitions_df = load_existing_csv("competitions")
    seasons_df = load_existing_csv("seasons")
    competition_seasons_existing = load_existing_dim(
        "competition_seasons",
        ["competition_season_id", "competition_id", "season_id"],
    )
    teams_df = load_existing_csv("teams")
    stadiums_existing = load_existing_dim("stadiums", ["stadium_id", "stadium_name", "city_name"])
    stages_existing = load_existing_dim("stages", ["stage_id", "stage_name"])
    matches_existing = load_existing_csv("matches")
    players_existing = load_existing_csv("players")
    lineups_existing = load_existing_csv("lineups")
    events_existing = load_existing_csv("events")

    worldcup_matches = normalize_worldcup_matches_csv()
    worldcup_players = normalize_worldcup_players_csv()
    international_matches = normalize_international_matches()
    fifa_matches_2022 = normalize_fifa_matches_2022()
    match_stats_df = normalize_worldcup_match_stats()
    messi_passes = normalize_messi_passes()
    rankings_df = normalize_fifa_rankings()

    competitions_df = competitions_df.copy()
    if competitions_df.empty:
        competitions_df = pd.DataFrame(columns=[
            "competition_id",
            "competition_name",
            "competition_type",
            "organizer",
        ])
    for col in ["competition_type", "organizer"]:
        if col not in competitions_df.columns:
            competitions_df[col] = None
    competitions_df["competition_name"] = competitions_df["competition_name"].apply(normalize_text)
    if "competition_international" in competitions_df.columns:
        competitions_df["competition_type"] = competitions_df.apply(
            lambda row: derive_competition_type(
                row.get("competition_name"),
                bool(row.get("competition_international")) if row.get("competition_international") is not None else None,
            ),
            axis=1,
        )
    competitions_df["organizer"] = competitions_df["competition_name"].apply(derive_organizer)
    comp_map = {
        row["competition_name"]: int(row["competition_id"])
        for _, row in competitions_df.dropna(subset=["competition_name"]).iterrows()
    }
    next_comp_id = int(competitions_df["competition_id"].max()) if not competitions_df.empty else 0
    fifa_world_cup_name = "FIFA World Cup"
    if fifa_world_cup_name not in comp_map:
        next_comp_id += 1
        comp_map[fifa_world_cup_name] = next_comp_id
        competitions_df = pd.concat([
            competitions_df,
            pd.DataFrame([{
                "competition_id": next_comp_id,
                "competition_name": fifa_world_cup_name,
                "competition_type": "NATIONAL",
                "organizer": "FIFA",
            }]),
        ], ignore_index=True)

    tournament_names = international_matches["tournament"].dropna().astype(str).unique().tolist()
    for name in sorted(tournament_names):
        norm = normalize_text(name)
        if not norm:
            continue
        if norm not in comp_map:
            next_comp_id += 1
            comp_map[norm] = next_comp_id
            competitions_df = pd.concat([
                competitions_df,
                pd.DataFrame([{
                    "competition_id": next_comp_id,
                    "competition_name": norm,
                    "competition_type": "INTERNATIONAL",
                    "organizer": None,
                }]),
            ], ignore_index=True)

    seasons_df = seasons_df.copy()
    if seasons_df.empty:
        seasons_df = pd.DataFrame(columns=["season_id", "season_name"])
    seasons_df["season_name"] = seasons_df["season_name"].apply(normalize_text)
    season_map = {
        row["season_name"]: int(row["season_id"])
        for _, row in seasons_df.dropna(subset=["season_name"]).iterrows()
    }
    next_season_id = int(seasons_df["season_id"].max()) if not seasons_df.empty else 0
    year_values = set(worldcup_matches["year_value"].dropna().astype(int).astype(str))
    year_values.update(
        international_matches["match_date"].dropna().apply(lambda d: str(d.year)).tolist()
    )
    year_values.update(
        fifa_matches_2022["match_date"].dropna().apply(lambda d: str(d.year)).tolist()
    )
    for year in sorted(year_values):
        if year not in season_map:
            next_season_id += 1
            season_map[year] = next_season_id
            seasons_df = pd.concat([
                seasons_df,
                pd.DataFrame([{"season_id": next_season_id, "season_name": year}]),
            ], ignore_index=True)

    teams_df = update_teams_from_rankings(teams_df, rankings_df)
    team_names = pd.concat([
        worldcup_matches["home_team_name"],
        worldcup_matches["away_team_name"],
        international_matches["home_team"],
        international_matches["away_team"],
        fifa_matches_2022["team1"],
        fifa_matches_2022["team2"],
    ], ignore_index=True)
    teams_df, team_map = update_teams_from_names(teams_df, team_names)

    teams_df, team_id_map = dedupe_teams(teams_df)
    team_map = {row.team_name: int(row.team_id) for row in teams_df.itertuples(index=False)}

    matches_existing = remap_team_ids(matches_existing, ["home_team_id", "away_team_id"], team_id_map)
    lineups_existing = remap_team_ids(lineups_existing, ["team_id"], team_id_map)

    worldcup_matches["stadium"] = worldcup_matches["stadium"].apply(normalize_text)
    worldcup_matches["city"] = worldcup_matches["city"].apply(normalize_text)
    worldcup_matches["stage"] = worldcup_matches["stage"].apply(normalize_text)

    stadiums_df, stadium_map = build_stadium_dimension(worldcup_matches, stadiums_existing)
    stages_df, stage_map = build_simple_dimension(worldcup_matches["stage"], stages_existing, "stage_id", "stage_name")

    comp_season_rows: List[Dict[str, Any]] = []
    fifa_comp_id = comp_map.get(fifa_world_cup_name)
    for year in worldcup_matches["year_value"].dropna().astype(int).tolist():
        season_id = season_map.get(str(year))
        if fifa_comp_id and season_id:
            comp_season_rows.append({"competition_id": fifa_comp_id, "season_id": season_id})
    for row in international_matches.itertuples(index=False):
        tournament = normalize_text(row.tournament) if row.tournament else None
        if not tournament:
            continue
        comp_id = comp_map.get(tournament)
        season_id = season_map.get(str(row.match_date.year)) if row.match_date else None
        if comp_id and season_id:
            comp_season_rows.append({"competition_id": comp_id, "season_id": season_id})
    for row in fifa_matches_2022.itertuples(index=False):
        season_id = season_map.get(str(row.match_date.year)) if row.match_date else None
        if fifa_comp_id and season_id:
            comp_season_rows.append({"competition_id": fifa_comp_id, "season_id": season_id})

    competition_seasons_df = pd.DataFrame(comp_season_rows).drop_duplicates()
    competition_seasons_df, comp_season_map = build_competition_season_dimension(
        competition_seasons_df,
        competition_seasons_existing,
    )

    existing_match_ids = set(matches_existing["match_id"].dropna().astype(int).tolist()) if not matches_existing.empty else set()
    existing_keys = set(
        (
            row.match_date,
            row.home_team_id,
            row.away_team_id,
            row.home_score,
            row.away_score,
        )
        for row in matches_existing.itertuples(index=False)
    ) if not matches_existing.empty else set()

    match_records: List[Dict[str, Any]] = []
    for row in worldcup_matches.itertuples(index=False):
        match_id = int(row.match_id) if pd.notna(row.match_id) else None
        if match_id is None or match_id in existing_match_ids:
            continue
        season_id = season_map.get(str(int(row.year_value))) if pd.notna(row.year_value) else None
        comp_season_id = comp_season_map.get((fifa_comp_id, season_id)) if fifa_comp_id and season_id else None
        home_team_id = team_map.get(normalize_team_name(row.home_team_name))
        away_team_id = team_map.get(normalize_team_name(row.away_team_name))
        if not home_team_id or not away_team_id or not comp_season_id:
            continue
        match_records.append({
            "match_id": match_id,
            "competition_season_id": comp_season_id,
            "match_date": row.match_date,
            "kick_off": row.kick_off,
            "home_team_id": home_team_id,
            "away_team_id": away_team_id,
            "home_score": row.home_team_goals,
            "away_score": row.away_team_goals,
            "stage_id": stage_map.get(row.stage) if row.stage else None,
            "stadium_id": stadium_map.get((row.stadium, row.city)) if row.stadium else None,
        })

    next_match_id = max(existing_match_ids) if existing_match_ids else 0
    for row in international_matches.itertuples(index=False):
        tournament = normalize_text(row.tournament) if row.tournament else None
        comp_id = comp_map.get(tournament) if tournament else None
        season_id = season_map.get(str(row.match_date.year)) if row.match_date else None
        comp_season_id = comp_season_map.get((comp_id, season_id)) if comp_id and season_id else None
        home_team_id = team_map.get(normalize_team_name(row.home_team))
        away_team_id = team_map.get(normalize_team_name(row.away_team))
        key = (row.match_date, home_team_id, away_team_id, row.home_team_score, row.away_team_score)
        if not comp_season_id or not home_team_id or not away_team_id:
            continue
        if key in existing_keys:
            continue
        next_match_id += 1
        existing_keys.add(key)
        match_records.append({
            "match_id": next_match_id,
            "competition_season_id": comp_season_id,
            "match_date": row.match_date,
            "kick_off": None,
            "home_team_id": home_team_id,
            "away_team_id": away_team_id,
            "home_score": row.home_team_score,
            "away_score": row.away_team_score,
            "stage_id": None,
            "stadium_id": None,
        })

    for row in fifa_matches_2022.itertuples(index=False):
        season_id = season_map.get(str(row.match_date.year)) if row.match_date else None
        comp_season_id = comp_season_map.get((fifa_comp_id, season_id)) if fifa_comp_id and season_id else None
        home_team_id = team_map.get(normalize_team_name(row.team1))
        away_team_id = team_map.get(normalize_team_name(row.team2))
        key = (row.match_date, home_team_id, away_team_id, row.goals_team1, row.goals_team2)
        if not comp_season_id or not home_team_id or not away_team_id:
            continue
        if key in existing_keys:
            continue
        next_match_id += 1
        existing_keys.add(key)
        match_records.append({
            "match_id": next_match_id,
            "competition_season_id": comp_season_id,
            "match_date": row.match_date,
            "kick_off": row.match_hour,
            "home_team_id": home_team_id,
            "away_team_id": away_team_id,
            "home_score": row.goals_team1,
            "away_score": row.goals_team2,
            "stage_id": None,
            "stadium_id": None,
        })

    worldcup_initials_map: Dict[str, str] = {}
    for row in worldcup_matches.itertuples(index=False):
        if row.home_team_initials and row.home_team_name:
            worldcup_initials_map[str(row.home_team_initials)] = str(row.home_team_name)
        if row.away_team_initials and row.away_team_name:
            worldcup_initials_map[str(row.away_team_initials)] = str(row.away_team_name)

    players_df = players_existing.copy()
    if players_df.empty:
        players_df = pd.DataFrame(columns=["player_id", "player_name", "position_value"])
    players_df["player_name"] = players_df["player_name"].apply(normalize_text)
    player_map = {
        row["player_name"]: int(row["player_id"])
        for _, row in players_df.dropna(subset=["player_name"]).iterrows()
    }
    next_player_id = int(players_df["player_id"].max()) if not players_df.empty else 0
    new_players: List[Dict[str, Any]] = []

    for row in worldcup_players.itertuples(index=False):
        name = normalize_text(row.player_name)
        if not name:
            continue
        if name not in player_map:
            next_player_id += 1
            player_map[name] = next_player_id
            new_players.append({
                "player_id": next_player_id,
                "player_name": name,
                "position_value": row.position_value,
            })
    messi_name = normalize_text(messi_passes["player"].dropna().astype(str).iloc[0]) if not messi_passes.empty else None
    if messi_name and messi_name not in player_map:
        next_player_id += 1
        player_map[messi_name] = next_player_id
        new_players.append({
            "player_id": next_player_id,
            "player_name": messi_name,
            "position_value": None,
        })

    if new_players:
        players_df = pd.concat([players_df, pd.DataFrame(new_players)], ignore_index=True)

    lineup_records: List[Dict[str, Any]] = []
    for row in worldcup_players.itertuples(index=False):
        match_id = int(row.match_id) if pd.notna(row.match_id) else None
        team_name = worldcup_initials_map.get(str(row.team_initials)) if row.team_initials else None
        team_id = team_map.get(normalize_team_name(team_name)) if team_name else None
        player_id = player_map.get(normalize_text(row.player_name))
        if not match_id or not team_id or not player_id:
            continue
        line_up = str(row.line_up).strip().upper() if pd.notna(row.line_up) else ""
        is_starter = 1 if line_up in {"S", "Y", "1", "TRUE"} else 0
        lineup_records.append({
            "match_id": match_id,
            "team_id": team_id,
            "player_id": player_id,
            "jersey_number": row.shirt_number,
            "position_value": row.position_value,
            "is_starter": is_starter,
        })

    event_records: List[Dict[str, Any]] = []
    for idx, row in enumerate(worldcup_players.itertuples(index=False), start=1):
        if not row.event or pd.isna(row.event):
            continue
        player_id = player_map.get(normalize_text(row.player_name))
        if not player_id:
            continue
        match_id = int(row.match_id) if pd.notna(row.match_id) else None
        team_name = worldcup_initials_map.get(str(row.team_initials)) if row.team_initials else None
        team_id = team_map.get(normalize_team_name(team_name)) if team_name else None
        event_records.append({
            "event_id": f"wcp_event_{idx}",
            "match_id": match_id,
            "team_id": team_id,
            "player_id": player_id,
            "minute_value": None,
            "second_value": None,
            "x": None,
            "y": None,
            "event_type": str(row.event),
            "outcome": None,
            "end_x": None,
            "end_y": None,
        })

    for row in messi_passes.itertuples(index=False):
        player_id = player_map.get(normalize_text(row.player))
        if not player_id:
            continue
        event_records.append({
            "event_id": f"messi_pass_{int(row.id)}",
            "match_id": None,
            "team_id": None,
            "player_id": player_id,
            "minute_value": row.minute_value,
            "second_value": row.second_value,
            "x": row.x,
            "y": row.y,
            "event_type": f"Pass ({row.pass_type})" if pd.notna(row.pass_type) else "Pass",
            "outcome": row.outcome,
            "end_x": row.end_x,
            "end_y": row.end_y,
        })

    team_rankings_df = build_team_rankings(rankings_df, teams_df) if not teams_df.empty else pd.DataFrame()

    team_rankings_df = remap_team_ids(team_rankings_df, ["team_id"], team_id_map)

    competitions_df = competitions_df[["competition_id", "competition_name", "competition_type", "organizer"]]
    merge_and_save("competitions", competitions_df, ["competition_id"])
    merge_and_save("seasons", seasons_df, ["season_id"])
    save_csv(competition_seasons_df, "competition_seasons")
    merge_and_save("teams", teams_df, ["team_id"])
    save_csv(stadiums_df, "stadiums")
    save_csv(stages_df, "stages")
    matches_combined = pd.concat([matches_existing, pd.DataFrame(match_records)], ignore_index=True)
    matches_combined = matches_combined.drop_duplicates(subset=["match_id"])
    save_csv(matches_combined, "matches")
    merge_and_save("players", players_df, ["player_id"])
    lineups_combined = pd.concat([lineups_existing, pd.DataFrame(lineup_records)], ignore_index=True)
    lineups_combined = lineups_combined.drop_duplicates(subset=["match_id", "team_id", "player_id"])
    save_csv(lineups_combined, "lineups")
    merge_and_save("events", pd.DataFrame(event_records), ["event_id"])
    save_csv(team_rankings_df, "team_rankings")

    if not match_stats_df.empty:
        match_stats_df["home_possession"] = match_stats_df["home_possession"].astype(str).str.replace("%", "", regex=False)
        match_stats_df["away_possession"] = match_stats_df["away_possession"].astype(str).str.replace("%", "", regex=False)

        team_name_by_id = {int(row.team_id): row.team_name for row in teams_df.itertuples(index=False) if pd.notna(row.team_id)}
        match_lookup: Dict[Tuple[Any, str, str], int] = {}
        for row in matches_combined.itertuples(index=False):
            home_name = team_name_by_id.get(int(row.home_team_id)) if pd.notna(row.home_team_id) else None
            away_name = team_name_by_id.get(int(row.away_team_id)) if pd.notna(row.away_team_id) else None
            match_lookup[(row.match_date, home_name, away_name)] = int(row.match_id)

        stats_rows: List[Dict[str, Any]] = []
        next_stats_id = 0
        for row in match_stats_df.itertuples(index=False):
            match_id = match_lookup.get((row.match_date, row.home_team_name, row.away_team_name))
            if not match_id:
                continue
            home_id = team_map.get(row.home_team_name)
            away_id = team_map.get(row.away_team_name)
            if home_id:
                next_stats_id += 1
                stats_rows.append({
                    "match_team_stats_id": next_stats_id,
                    "match_id": match_id,
                    "team_id": home_id,
                    "is_home": 1,
                    "possession_pct": row.home_possession,
                    "shots_total": row.home_shots_total,
                    "shots_on_target": row.home_shots_on_target,
                    "passes_attempted": row.home_passes,
                    "passes_completed": row.home_passes_completed,
                    "corners": row.home_corners,
                    "fouls": row.home_fouls_against,
                    "yellow_cards": row.home_yellow,
                    "red_cards": row.home_red,
                    "offsides": row.home_offsides,
                })
            if away_id:
                next_stats_id += 1
                stats_rows.append({
                    "match_team_stats_id": next_stats_id,
                    "match_id": match_id,
                    "team_id": away_id,
                    "is_home": 0,
                    "possession_pct": row.away_possession,
                    "shots_total": row.away_shots_total,
                    "shots_on_target": row.away_shots_on_target,
                    "passes_attempted": row.away_passes,
                    "passes_completed": row.away_passes_completed,
                    "corners": row.away_corners,
                    "fouls": row.away_fouls_against,
                    "yellow_cards": row.away_yellow,
                    "red_cards": row.away_red,
                    "offsides": row.away_offsides,
                })

        if stats_rows:
            stats_df = pd.DataFrame(stats_rows)
            merge_and_save("match_team_stats", stats_df, ["match_id", "team_id"])

    print("CSVs extra normalizados generados en:", OUTPUT_DIR)


if __name__ == "__main__":
    main()
