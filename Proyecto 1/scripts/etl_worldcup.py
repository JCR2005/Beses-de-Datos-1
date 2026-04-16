"""ETL para Copa del Mundo (1986, 2018, 2022).
Genera o combina CSVs normalizados en data/processed/.
"""
from __future__ import annotations

import csv
import json
import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[1]
ARCHIVOS_DIR = BASE_DIR / "Archivos"
WORLD_CUP_DIR = ARCHIVOS_DIR / "Copa del mundo-20260304T184238Z-3-001" / "Copa del mundo"
OUTPUT_DIR = BASE_DIR / "data" / "processed"

MATCHES_1986 = WORLD_CUP_DIR / "partidos" / "FIFA_W_C_1986" / "54__MATCHES_FWC_1986.json"
MATCHES_2018 = WORLD_CUP_DIR / "partidos" / "FIDA_W_C_2018" / "3__MATCHES_FWC_2018.json"
MATCHES_2022 = WORLD_CUP_DIR / "partidos" / "FIFA_W_C_2022" / "106___Matches__FWC_2022.json"

EVENTS_1986 = WORLD_CUP_DIR / "partidos" / "FIFA_W_C_1986" / "CuartosFinal_ARG_VS_ENG" / "EventosDelPartido.json"
LINEUPS_1986 = WORLD_CUP_DIR / "partidos" / "FIFA_W_C_1986" / "CuartosFinal_ARG_VS_ENG" / "alineacion.json"

COMPETITIONS_FILE = ARCHIVOS_DIR / "competitions.json"

QUARTERFINAL_MATCH_ID = 3750191  # Argentina vs Inglaterra (1986)


def normalize_text(value: Any) -> Optional[str]:
    if value is None or (isinstance(value, float) and pd.isna(value)):
        return None
    text = str(value).strip()
    if not text:
        return None
    return re.sub(r"\s+", " ", text)


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


def parse_minute(value: Optional[str]) -> Optional[int]:
    if not value:
        return None
    try:
        return int(str(value).split(":", maxsplit=1)[0])
    except (ValueError, AttributeError):
        return None


def load_existing_dim(name: str, columns: List[str]) -> pd.DataFrame:
    path = OUTPUT_DIR / f"{name}.csv"
    if path.exists():
        df = pd.read_csv(path)
        for col in columns:
            if col not in df.columns:
                df[col] = None
        return df[columns]
    return pd.DataFrame(columns=columns)


def build_simple_dimension(values: pd.Series, existing_df: pd.DataFrame, id_col: str, name_col: str) -> Tuple[pd.DataFrame, Dict[str, int]]:
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


def build_stadium_dimension(matches_df: pd.DataFrame, existing_df: pd.DataFrame) -> Tuple[pd.DataFrame, Dict[Tuple[str, Optional[str]], int]]:
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


def load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def safe_get(mapping: Dict[str, Any], key: str) -> Any:
    value = mapping.get(key)
    if isinstance(value, dict) and "name" in value:
        return value.get("name")
    return value


def parse_outcome_and_end_location(event: Dict[str, Any]) -> Tuple[Optional[str], Optional[float], Optional[float]]:
    for key in ("pass", "shot", "carry", "dribble", "ball_recovery", "clearance", "goalkeeper"):
        if key in event and isinstance(event[key], dict):
            sub = event[key]
            outcome = safe_get(sub, "outcome") if isinstance(sub, dict) else None
            end_loc = sub.get("end_location") if isinstance(sub, dict) else None
            if isinstance(end_loc, list) and len(end_loc) >= 2:
                return outcome, float(end_loc[0]), float(end_loc[1])
            return outcome, None, None
    return None, None, None


def load_existing(name: str) -> pd.DataFrame:
    path = OUTPUT_DIR / f"{name}.csv"
    if path.exists():
        return pd.read_csv(path)
    return pd.DataFrame()


def save_csv(df: pd.DataFrame, name: str) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUTPUT_DIR / f"{name}.csv"
    df.to_csv(path, index=False, quoting=csv.QUOTE_MINIMAL)


def normalize_matches() -> Tuple[
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
]:
    matches_records: List[Dict[str, Any]] = []
    teams_records: Dict[int, Dict[str, Any]] = {}
    countries_records: Dict[int, Dict[str, Any]] = {}
    venues_records: Dict[int, Dict[str, Any]] = {}
    coaches_records: Dict[int, Dict[str, Any]] = {}
    match_team_coaches: List[Dict[str, Any]] = []
    competition_ids: set[int] = set()
    season_ids: set[int] = set()

    for match_file in [MATCHES_1986, MATCHES_2018, MATCHES_2022]:
        data = load_json(match_file)
        for match in data:
            competition = match.get("competition", {})
            season = match.get("season", {})
            competition_id = competition.get("competition_id")
            season_id = season.get("season_id")
            if competition_id is not None:
                competition_ids.add(int(competition_id))
            if season_id is not None:
                season_ids.add(int(season_id))

            home_team = match.get("home_team", {})
            away_team = match.get("away_team", {})
            for team in (home_team, away_team):
                team_id = team.get("home_team_id") or team.get("away_team_id") or team.get("team_id")
                team_name = team.get("home_team_name") or team.get("away_team_name") or team.get("team_name")
                team_country = team.get("country") if isinstance(team.get("country"), dict) else None
                if team_country and team_country.get("id") is not None:
                    countries_records[int(team_country["id"])] = {
                        "country_id": int(team_country["id"]),
                        "country_name": team_country.get("name"),
                    }
                if team_id is not None:
                    teams_records[team_id] = {
                        "team_id": team_id,
                        "team_name": team_name,
                        "country_id": int(team_country["id"]) if team_country and team_country.get("id") is not None else None,
                    }

                for manager in team.get("managers", []) or []:
                    coach_id = manager.get("id")
                    if coach_id is None:
                        continue
                    coach_country = manager.get("country") if isinstance(manager.get("country"), dict) else None
                    if coach_country and coach_country.get("id") is not None:
                        countries_records[int(coach_country["id"])] = {
                            "country_id": int(coach_country["id"]),
                            "country_name": coach_country.get("name"),
                        }
                    coaches_records[int(coach_id)] = {
                        "coach_id": int(coach_id),
                        "coach_name": manager.get("name"),
                        "country_id": int(coach_country["id"]) if coach_country and coach_country.get("id") is not None else None,
                    }
                    if team_id is not None and match.get("match_id") is not None:
                        match_team_coaches.append({
                            "match_id": match.get("match_id"),
                            "team_id": team_id,
                            "coach_id": int(coach_id),
                        })

            stadium = match.get("stadium", {})
            stadium_country = stadium.get("country") if isinstance(stadium.get("country"), dict) else None
            if stadium_country and stadium_country.get("id") is not None:
                countries_records[int(stadium_country["id"])] = {
                    "country_id": int(stadium_country["id"]),
                    "country_name": stadium_country.get("name"),
                }
            if stadium.get("id") is not None:
                venues_records[int(stadium.get("id"))] = {
                    "venue_id": int(stadium.get("id")),
                    "venue_name": stadium.get("name"),
                    "city_name": stadium.get("city"),
                    "country_id": int(stadium_country["id"]) if stadium_country and stadium_country.get("id") is not None else None,
                }
            referee = match.get("referee") if isinstance(match.get("referee"), dict) else None
            referee_name = referee.get("name") if referee else None
            referee_country = referee.get("country") if referee and isinstance(referee.get("country"), dict) else None
            if referee_country and referee_country.get("id") is not None:
                countries_records[int(referee_country["id"])] = {
                    "country_id": int(referee_country["id"]),
                    "country_name": referee_country.get("name"),
                }
            matches_records.append({
                "match_id": match.get("match_id"),
                "competition_id": competition_id,
                "season_id": season_id,
                "match_date": match.get("match_date"),
                "kick_off": match.get("kick_off"),
                "home_team_id": home_team.get("home_team_id"),
                "away_team_id": away_team.get("away_team_id"),
                "home_score": match.get("home_score"),
                "away_score": match.get("away_score"),
                "match_status": match.get("match_status"),
                "referee_name": referee_name,
                "venue_id": stadium.get("id"),
                "stage": safe_get(match.get("competition_stage", {}), "name"),
                "stadium": safe_get(stadium, "name"),
                "city": safe_get(stadium, "city"),
            })

    competitions_records: Dict[int, Dict[str, Any]] = {}
    seasons_records: Dict[int, Dict[str, Any]] = {}
    competition_seasons: List[Dict[str, Any]] = []
    if COMPETITIONS_FILE.exists():
        competitions_data = load_json(COMPETITIONS_FILE)
        for row in competitions_data:
            comp_id = row.get("competition_id")
            season_id = row.get("season_id")
            if comp_id in competition_ids:
                comp_name = row.get("competition_name")
                competitions_records[comp_id] = {
                    "competition_id": comp_id,
                    "competition_name": comp_name,
                    "competition_type": derive_competition_type(
                        comp_name,
                        bool(row.get("competition_international")) if row.get("competition_international") is not None else None,
                    ),
                    "organizer": derive_organizer(comp_name),
                }
            if season_id in season_ids:
                seasons_records[season_id] = {
                    "season_id": season_id,
                    "season_name": row.get("season_name"),
                }
            if comp_id in competition_ids and season_id in season_ids:
                competition_seasons.append({
                    "competition_id": comp_id,
                    "season_id": season_id,
                })

    competitions_df = pd.DataFrame(competitions_records.values())
    seasons_df = pd.DataFrame(seasons_records.values())
    competition_seasons_df = pd.DataFrame(competition_seasons).drop_duplicates()
    teams_df = pd.DataFrame(teams_records.values())
    matches_df = pd.DataFrame(matches_records)
    countries_df = pd.DataFrame(countries_records.values())
    venues_df = pd.DataFrame(venues_records.values())
    coaches_df = pd.DataFrame(coaches_records.values())
    match_team_coaches_df = pd.DataFrame(match_team_coaches)

    return (
        competitions_df,
        seasons_df,
        competition_seasons_df,
        teams_df,
        matches_df,
        countries_df,
        venues_df,
        coaches_df,
        match_team_coaches_df,
    )


def normalize_lineups() -> Tuple[pd.DataFrame, pd.DataFrame]:
    lineups_records: List[Dict[str, Any]] = []
    players_records: Dict[int, Dict[str, Any]] = {}

    if LINEUPS_1986.exists():
        data = load_json(LINEUPS_1986)
        for team in data:
            team_id = team.get("team_id")
            for player in team.get("lineup", []):
                player_id = player.get("player_id")
                if player_id is not None:
                    players_records[player_id] = {
                        "player_id": player_id,
                        "player_name": player.get("player_name"),
                        "position_value": (player.get("positions", [{}])[0] or {}).get("position") if player.get("positions") else None,
                    }
                positions = player.get("positions") or []
                first_position = positions[0] if positions else {}
                start_reason = first_position.get("start_reason") if isinstance(first_position, dict) else None
                start_min = parse_minute(first_position.get("from") if isinstance(first_position, dict) else None)
                end_min = parse_minute(first_position.get("to") if isinstance(first_position, dict) else None)
                if start_min is not None and end_min is None:
                    end_min = 90
                minutes_played = None
                if start_min is not None and end_min is not None:
                    minutes_played = max(end_min - start_min, 0)

                lineups_records.append({
                    "match_id": QUARTERFINAL_MATCH_ID,
                    "team_id": team_id,
                    "player_id": player_id,
                    "jersey_number": player.get("jersey_number"),
                    "position_value": first_position.get("position") if isinstance(first_position, dict) else None,
                    "is_starter": 1 if start_reason == "Starting XI" else 0,
                    "minutes_played": minutes_played,
                })

    lineups_df = pd.DataFrame(lineups_records)
    players_df = pd.DataFrame(players_records.values())
    return lineups_df, players_df


def normalize_events() -> pd.DataFrame:
    events_records: List[Dict[str, Any]] = []
    if EVENTS_1986.exists():
        data = load_json(EVENTS_1986)
        for event in data:
            location = event.get("location") or [None, None]
            outcome, end_x, end_y = parse_outcome_and_end_location(event)
            event_type = safe_get(event.get("type", {}), "name")
            team_id = (event.get("team") or {}).get("id")
            shot = event.get("shot") if isinstance(event.get("shot"), dict) else None
            pass_event = event.get("pass") if isinstance(event.get("pass"), dict) else None
            foul = event.get("foul_committed") if isinstance(event.get("foul_committed"), dict) else None
            card = None
            if foul and isinstance(foul.get("card"), dict):
                card = foul.get("card")
            if isinstance(event.get("card"), dict):
                card = event.get("card")
            card_name = safe_get(card, "name") if card else None
            card_type = None
            if card_name:
                if "yellow" in card_name.casefold():
                    card_type = "YELLOW"
                elif "red" in card_name.casefold():
                    card_type = "RED"

            is_penalty = None
            penalty_scored = None
            is_goal = None
            if shot:
                shot_type = safe_get(shot.get("type", {}), "name") if isinstance(shot.get("type"), dict) else None
                is_penalty = 1 if shot_type and shot_type.casefold() == "penalty" else 0
                shot_outcome = safe_get(shot.get("outcome", {}), "name") if isinstance(shot.get("outcome"), dict) else None
                is_goal = 1 if shot_outcome and shot_outcome.casefold() == "goal" else 0
                if is_penalty:
                    penalty_scored = 1 if is_goal else 0

            is_assist = 1 if pass_event and pass_event.get("goal_assist") else 0

            events_records.append({
                "event_id": event.get("id"),
                "match_id": QUARTERFINAL_MATCH_ID,
                "team_id": team_id,
                "player_id": (event.get("player") or {}).get("id"),
                "minute_value": event.get("minute"),
                "second_value": event.get("second"),
                "x": location[0],
                "y": location[1],
                "event_type": event_type,
                "outcome": outcome,
                "end_x": end_x,
                "end_y": end_y,
                "is_goal": is_goal,
                "is_assist": is_assist,
                "is_penalty": is_penalty,
                "penalty_scored": penalty_scored,
                "card_type": card_type,
            })

    return pd.DataFrame(events_records)


def merge_and_save(name: str, new_df: pd.DataFrame, subset: Optional[List[str]] = None) -> None:
    existing = load_existing(name)
    combined = pd.concat([existing, new_df], ignore_index=True)
    if subset:
        combined = combined.drop_duplicates(subset=subset)
    else:
        combined = combined.drop_duplicates()
    save_csv(combined, name)


def main() -> None:
    (
        competitions_df,
        seasons_df,
        competition_seasons_df,
        teams_df,
        matches_df,
        countries_df,
        venues_df,
        coaches_df,
        match_team_coaches_df,
    ) = normalize_matches()
    lineups_df, players_df = normalize_lineups()
    events_df = normalize_events()

    matches_df["stadium"] = matches_df["stadium"].apply(normalize_text)
    matches_df["city"] = matches_df["city"].apply(normalize_text)
    matches_df["stage"] = matches_df["stage"].apply(normalize_text)
    matches_df["match_status"] = matches_df["match_status"].apply(normalize_text)

    competition_seasons_existing = load_existing_dim(
        "competition_seasons",
        ["competition_season_id", "competition_id", "season_id"],
    )
    stadiums_existing = load_existing_dim("stadiums", ["stadium_id", "stadium_name", "city_name"])
    stages_existing = load_existing_dim("stages", ["stage_id", "stage_name"])

    competition_seasons_df, comp_season_map = build_competition_season_dimension(
        competition_seasons_df,
        competition_seasons_existing,
    )
    stadiums_df, stadium_map = build_stadium_dimension(matches_df, stadiums_existing)
    stages_df, stage_map = build_simple_dimension(matches_df["stage"], stages_existing, "stage_id", "stage_name")

    matches_df["stadium_id"] = [stadium_map.get((row.stadium, row.city)) if row.stadium else None for row in matches_df.itertuples()]
    matches_df["stage_id"] = matches_df["stage"].apply(lambda value: stage_map.get(value) if value else None)
    matches_df["competition_season_id"] = matches_df.apply(
        lambda row: comp_season_map.get((int(row["competition_id"]), int(row["season_id"])))
        if pd.notna(row["competition_id"]) and pd.notna(row["season_id"])
        else None,
        axis=1,
    )
    matches_df = matches_df.drop(columns=["stadium", "city", "stage", "match_status", "competition_id", "season_id"])

    merge_and_save("countries", countries_df, ["country_id"])
    merge_and_save("competitions", competitions_df, ["competition_id"])
    merge_and_save("seasons", seasons_df, ["season_id"])
    save_csv(competition_seasons_df, "competition_seasons")
    merge_and_save("teams", teams_df, ["team_id"])
    merge_and_save("venues", venues_df, ["venue_id"])
    merge_and_save("coaches", coaches_df, ["coach_id"])
    merge_and_save("match_team_coaches", match_team_coaches_df, ["match_id", "team_id", "coach_id"])
    save_csv(stadiums_df, "stadiums")
    save_csv(stages_df, "stages")
    merge_and_save("matches", matches_df, ["match_id"])
    merge_and_save("players", players_df, ["player_id"])
    merge_and_save("lineups", lineups_df, ["match_id", "team_id", "player_id"])
    merge_and_save("events", events_df, ["event_id"])

    print("CSVs generados/actualizados en:", OUTPUT_DIR)


if __name__ == "__main__":
    main()
