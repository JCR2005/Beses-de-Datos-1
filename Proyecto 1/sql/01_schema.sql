

CREATE TABLE country (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(60) NOT NULL,
    iso2 CHAR(2),
    iso3 CHAR(3),
    UNIQUE (country_name)
);

CREATE TABLE competition (
    competition_id INT PRIMARY KEY,
    competition_name VARCHAR(60) NOT NULL,
    competition_type VARCHAR(20),
    organizer VARCHAR(60),
    UNIQUE (competition_name)
);

CREATE TABLE season (
    season_id INT PRIMARY KEY,
    season_name VARCHAR(50) NOT NULL,
    start_date DATE,
    end_date DATE,
    UNIQUE (season_name)
);

CREATE TABLE competition_season (
    competition_season_id INT PRIMARY KEY,
    competition_id INT NOT NULL,
    season_id INT NOT NULL,
    UNIQUE (competition_id, season_id),
    FOREIGN KEY (competition_id) REFERENCES competition(competition_id),
    FOREIGN KEY (season_id) REFERENCES season(season_id)
);

CREATE TABLE team (
    team_id INT PRIMARY KEY,
    team_name VARCHAR(60) NOT NULL,
    team_type VARCHAR(20),
    country_id INT,
    UNIQUE (team_name),
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE coach (
    coach_id INT PRIMARY KEY,
    coach_name VARCHAR(60) NOT NULL,
    country_id INT,
    UNIQUE (coach_name),
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE player (
    player_id INT PRIMARY KEY,
    player_name VARCHAR(60) NOT NULL,
    position_value VARCHAR(50),
    nationality_country_id INT,
    UNIQUE (player_name),
    FOREIGN KEY (nationality_country_id) REFERENCES country(country_id)
);

CREATE TABLE venue (
    venue_id INT PRIMARY KEY,
    venue_name VARCHAR(120) NOT NULL,
    city_name VARCHAR(120),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE stadium (
    stadium_id INT PRIMARY KEY,
    stadium_name VARCHAR(120) NOT NULL,
    city_name VARCHAR(120)
);

CREATE TABLE stage (
    stage_id INT PRIMARY KEY,
    stage_name VARCHAR(60) NOT NULL,
    stage_order INT,
    UNIQUE (stage_name)
);

CREATE TABLE MATCH (
    match_id INT PRIMARY KEY,
    competition_season_id INT NOT NULL,
    match_date DATE,
    kick_off VARCHAR(20),
    home_team_id INT NOT NULL,
    away_team_id INT NOT NULL,
    home_score INT,
    away_score INT,
    stage_id INT,
    stadium_id INT,
    venue_id INT,
    attendance INT,
    referee_name VARCHAR(120),
    status VARCHAR(20),
    FOREIGN KEY (competition_season_id) REFERENCES competition_season(competition_season_id),
    FOREIGN KEY (home_team_id) REFERENCES team(team_id),
    FOREIGN KEY (away_team_id) REFERENCES team(team_id),
    FOREIGN KEY (stage_id) REFERENCES stage(stage_id),
    FOREIGN KEY (stadium_id) REFERENCES stadium(stadium_id),
    FOREIGN KEY (venue_id) REFERENCES venue(venue_id)
);

CREATE TABLE match_team_coach (
    match_id INT NOT NULL,
    team_id INT NOT NULL,
    coach_id INT NOT NULL,
    PRIMARY KEY (match_id, team_id),
    FOREIGN KEY (match_id) REFERENCES "MATCH"(match_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id),
    FOREIGN KEY (coach_id) REFERENCES coach(coach_id)
);

CREATE TABLE match_team_stats (
    match_team_stats_id INT PRIMARY KEY,
    match_id INT NOT NULL,
    team_id INT NOT NULL,
    is_home SMALLINT,
    possession_pct DECIMAL(5,2),
    shots_total INT,
    shots_on_target INT,
    passes_attempted INT,
    passes_completed INT,
    corners INT,
    fouls INT,
    yellow_cards INT,
    red_cards INT,
    offsides INT,
    xg DECIMAL(6,3),
    UNIQUE (match_id, team_id),
    FOREIGN KEY (match_id) REFERENCES "MATCH"(match_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);

CREATE TABLE lineup (
    match_id INT NOT NULL,
    team_id INT NOT NULL,
    player_id INT NOT NULL,
    jersey_number INT,
    position_value VARCHAR(50),
    is_starter SMALLINT,
    minutes_played INT,
    PRIMARY KEY (match_id, team_id, player_id),
    FOREIGN KEY (match_id) REFERENCES "MATCH"(match_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id)
);

CREATE TABLE EVENT (
    event_id VARCHAR(64) PRIMARY KEY,
    match_id INT,
    team_id INT,
    player_id INT,
    minute_value INT,
    second_value INT,
    x DECIMAL(8,4),
    y DECIMAL(8,4),
    event_type VARCHAR(100),
    outcome VARCHAR(100),
    end_x DECIMAL(8,4),
    end_y DECIMAL(8,4),
    is_goal SMALLINT,
    is_assist SMALLINT,
    is_penalty SMALLINT,
    penalty_scored SMALLINT,
    card_type VARCHAR(10),
    FOREIGN KEY (match_id) REFERENCES "MATCH"(match_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id)
);

CREATE TABLE team_ranking (
    ranking_id INT PRIMARY KEY,
    team_id INT NOT NULL,
    ranking_date DATE,
    rank_value INT,
    previous_rank INT,
    points DECIMAL(10,2),
    previous_points DECIMAL(10,2),
    team_code VARCHAR(10),
    association VARCHAR(50),
    UNIQUE (team_id, ranking_date),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);
