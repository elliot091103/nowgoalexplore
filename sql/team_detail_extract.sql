-- =============================================================================
-- DuckDB SQL Extraction Script for Nowgoal team_detail.json
-- Requirement: Extract club profile metadata, squad groups, detailed roster stats,
--              cup competitions, aggregate tournament performance, match-by-match
--              technical fixtures, league standings matrix, honors, and tactical
--              characteristics based on team_detail_documentation.md.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Club Profile & Metadata View
-- Extracts core team metadata, stadium, valuation, and league affiliation from 'TeamInfo'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_team_info AS
SELECT 
    TRY_CAST(TeamInfo[1] AS INTEGER) AS team_id,
    TeamInfo[2] AS team_name,
    TeamInfo[3] AS team_logo,
    TeamInfo[4] AS city,
    TeamInfo[5] AS home_stadium,
    TRY_CAST(TeamInfo[6] AS INTEGER) AS capacity,
    TRY_CAST(TeamInfo[7] AS DATE) AS established_date,
    TRY_CAST(TeamInfo[8] AS DOUBLE) AS estimated_value_million_eur,
    TRY_CAST(TeamInfo[9] AS DOUBLE) AS avg_age,
    TRY_CAST(TeamInfo[10] AS INTEGER) AS primary_league_id,
    TeamInfo[11] AS primary_league_name,
    TeamInfo[12] AS primary_league_logo,
    teamLastUpdateTime AS last_update_time
FROM read_json(
    'json/team_detail.json',
    columns = {
        'TeamInfo': 'VARCHAR[]',
        'teamLastUpdateTime': 'TIMESTAMP'
    }
);


-- -----------------------------------------------------------------------------
-- 2. Positional Squad Groups View
-- Unnests active squad members across Goalkeeper, Defender, Midfielder, Forward, and Coach groups.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_team_squad_groups AS
WITH base AS (
    SELECT 
        TRY_CAST(TeamInfo[1] AS INTEGER) AS team_id,
        rearguard,
        vanguard,
        goalkeeper,
        midfielder,
        coach
    FROM read_json(
        'json/team_detail.json',
        columns = {
            'TeamInfo': 'VARCHAR[]',
            'rearguard': 'VARCHAR[][]',
            'vanguard': 'VARCHAR[][]',
            'goalkeeper': 'VARCHAR[][]',
            'midfielder': 'VARCHAR[][]',
            'coach': 'VARCHAR[][]'
        }
    )
),
all_squad AS (
    SELECT team_id, 'Goalkeeper' AS position_group, UNNEST(goalkeeper) AS p FROM base
    UNION ALL
    SELECT team_id, 'Defender' AS position_group, UNNEST(rearguard) AS p FROM base
    UNION ALL
    SELECT team_id, 'Midfielder' AS position_group, UNNEST(midfielder) AS p FROM base
    UNION ALL
    SELECT team_id, 'Forward' AS position_group, UNNEST(vanguard) AS p FROM base
    UNION ALL
    SELECT team_id, 'Coach' AS position_group, UNNEST(coach) AS p FROM base
)
SELECT 
    team_id,
    position_group,
    TRY_CAST(p[1] AS INTEGER) AS player_id,
    NULLIF(p[2], '') AS jersey_number,
    p[3] AS player_name,
    TRY_CAST(p[4] AS INTEGER) = 1 AS is_captain,
    NULLIF(p[5], '') AS player_photo
FROM all_squad;


-- -----------------------------------------------------------------------------
-- 3. Detailed Squad & Player Roster Statistics View
-- Extracts personal info, valuation, contract expiry, and season totals from 'lineupDetail'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_team_lineup_detail AS
WITH base AS (
    SELECT 
        TRY_CAST(TeamInfo[1] AS INTEGER) AS team_id,
        UNNEST(lineupDetail) AS l
    FROM read_json(
        'json/team_detail.json',
        columns = {
            'TeamInfo': 'VARCHAR[]',
            'lineupDetail': 'VARCHAR[][]'
        }
    )
)
SELECT 
    team_id,
    TRY_CAST(l[1] AS INTEGER) AS player_id,
    NULLIF(l[2], '') AS jersey_number,
    l[3] AS player_name,
    TRY_CAST(NULLIF(l[4], '') AS INTEGER) = 1 AS is_captain,
    TRY_CAST(NULLIF(l[5], '') AS DATE) AS birth_date,
    TRY_CAST(NULLIF(l[6], '') AS INTEGER) AS height_cm,
    TRY_CAST(NULLIF(l[7], '') AS INTEGER) AS weight_kg,
    NULLIF(l[8], '') AS position_role,
    NULLIF(l[9], '') AS nationality,
    CASE 
        WHEN l[10] IS NOT NULL AND l[10] != '' THEN TRY_CAST(l[10] AS DOUBLE) / 100.0
        ELSE NULL 
    END AS market_value_million_eur,
    TRY_CAST(NULLIF(l[11], '') AS DATE) AS contract_expiry,
    TRY_CAST(l[12] AS INTEGER) AS total_matches,
    TRY_CAST(l[13] AS INTEGER) AS starts,
    TRY_CAST(l[14] AS INTEGER) AS goals,
    TRY_CAST(l[15] AS INTEGER) AS penalty_goals,
    TRY_CAST(l[16] AS INTEGER) AS assists
FROM base;


-- -----------------------------------------------------------------------------
-- 4. Active Cup Competitions View
-- Unnests cup tournaments and active seasons from 'cupData'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_team_cup_competitions AS
WITH base AS (
    SELECT 
        TRY_CAST(TeamInfo[1] AS INTEGER) AS team_id,
        UNNEST(cupData) AS c
    FROM read_json(
        'json/team_detail.json',
        columns = {
            'TeamInfo': 'VARCHAR[]',
            'cupData': 'VARCHAR[][]'
        }
    )
)
SELECT 
    team_id,
    TRY_CAST(c[1] AS INTEGER) AS cup_id,
    c[2] AS cup_short_name,
    c[3] AS season
FROM base;


-- -----------------------------------------------------------------------------
-- 5. Competition Performance Aggregates View
-- Extracts cumulative metrics across all competitions and individual tournaments from 'CountSum'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_team_competition_stats AS
WITH base AS (
    SELECT 
        TRY_CAST(TeamInfo[1] AS INTEGER) AS team_id,
        UNNEST(CountSum) AS s
    FROM read_json(
        'json/team_detail.json',
        columns = {
            'TeamInfo': 'VARCHAR[]',
            'CountSum': 'VARCHAR[][]'
        }
    )
)
SELECT 
    team_id,
    TRY_CAST(s[1] AS INTEGER) AS league_id,
    s[2] AS league_name,
    TRY_CAST(s[3] AS INTEGER) AS total_matches,
    TRY_CAST(s[4] AS INTEGER) AS wins,
    TRY_CAST(s[5] AS INTEGER) AS losses_or_draws,
    TRY_CAST(s[6] AS INTEGER) AS total_shots,
    TRY_CAST(s[7] AS INTEGER) AS shots_on_target,
    TRY_CAST(s[8] AS DOUBLE) AS conversion_rate,
    TRY_CAST(s[9] AS DOUBLE) AS avg_possession,
    TRY_CAST(s[10] AS INTEGER) AS fouled,
    TRY_CAST(s[11] AS INTEGER) AS fouls,
    TRY_CAST(s[12] AS INTEGER) AS total_passes,
    TRY_CAST(s[13] AS INTEGER) AS passes_success,
    TRY_CAST(s[14] AS DOUBLE) AS pass_rate,
    TRY_CAST(s[15] AS INTEGER) AS key_passes,
    TRY_CAST(s[16] AS INTEGER) AS long_passes,
    TRY_CAST(s[17] AS INTEGER) AS through_balls,
    TRY_CAST(s[18] AS INTEGER) AS dribbles,
    TRY_CAST(s[19] AS INTEGER) AS interceptions,
    TRY_CAST(s[20] AS INTEGER) AS clearances,
    TRY_CAST(s[21] AS INTEGER) AS steals,
    TRY_CAST(s[22] AS INTEGER) AS tackles,
    TRY_CAST(s[23] AS INTEGER) AS blocked_shots,
    TRY_CAST(s[24] AS INTEGER) AS aerials_won,
    TRY_CAST(s[25] AS DOUBLE) AS avg_rating
FROM base;


-- -----------------------------------------------------------------------------
-- 6. Match-by-Match Fixtures & Technical Data View
-- Extracts match logs, scores, and technical indicators (all 33 fields) from 'TeamCount'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_team_matches AS
WITH base AS (
    SELECT 
        UNNEST(TeamCount) AS m
    FROM read_json(
        'json/team_detail.json',
        columns = {
            'TeamCount': 'VARCHAR[][]'
        }
    )
)
SELECT 
    TRY_CAST(m[1] AS INTEGER) AS match_id,
    TRY_CAST(m[2] AS INTEGER) AS home_team_id,
    TRY_CAST(m[3] AS INTEGER) AS away_team_id,
    TRY_CAST(m[4] AS TIMESTAMP) AS match_time,
    TRY_CAST(m[5] AS INTEGER) AS league_id,
    m[6] AS league_code,
    m[7] AS league_color,
    m[8] AS home_team_name,
    m[9] AS away_team_name,
    TRY_CAST(m[10] AS INTEGER) AS home_score,
    TRY_CAST(m[11] AS INTEGER) AS away_score,
    TRY_CAST(m[12] AS INTEGER) AS ht_home_score,
    TRY_CAST(m[13] AS INTEGER) AS ht_away_score,
    TRY_CAST(m[14] AS INTEGER) AS red_cards,
    TRY_CAST(m[15] AS INTEGER) AS possession_pct,
    TRY_CAST(m[16] AS INTEGER) AS shots,
    TRY_CAST(m[17] AS INTEGER) AS shots_on_target,
    TRY_CAST(m[18] AS INTEGER) AS passes,
    TRY_CAST(m[19] AS INTEGER) AS passes_success,
    TRY_CAST(m[20] AS DOUBLE) AS pass_rate,
    TRY_CAST(m[21] AS INTEGER) AS key_passes,
    TRY_CAST(m[22] AS INTEGER) AS corners,
    TRY_CAST(m[23] AS INTEGER) AS offsides,
    TRY_CAST(m[24] AS INTEGER) AS penalty_count,
    TRY_CAST(m[25] AS INTEGER) AS dribbles,
    TRY_CAST(m[26] AS INTEGER) AS fouls,
    TRY_CAST(m[27] AS INTEGER) AS yellow_cards,
    TRY_CAST(m[28] AS INTEGER) AS tackles,
    TRY_CAST(m[29] AS INTEGER) AS interceptions,
    TRY_CAST(m[30] AS INTEGER) AS blocked_shots,
    TRY_CAST(m[31] AS INTEGER) AS clearances,
    TRY_CAST(m[32] AS DOUBLE) AS match_rating,
    TRY_CAST(m[33] AS INTEGER) = 1 AS has_detail_flag
FROM base;


-- -----------------------------------------------------------------------------
-- 7. League Form & Standings Matrix View
-- Extracts multi-tier domestic league matrix records from 'leagueData'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_team_league_data AS
WITH base AS (
    SELECT 
        TRY_CAST(TeamInfo[1] AS INTEGER) AS team_id,
        leagueData
    FROM read_json(
        'json/team_detail.json',
        columns = {
            'TeamInfo': 'VARCHAR[]',
            'leagueData': 'JSON[]'
        }
    )
),
unnested_rows AS (
    SELECT 
        team_id,
        UNNEST(TRY_CAST(leagueData AS JSON[][])) AS r
    FROM base
    WHERE json_array_length(leagueData) >= 6
)
SELECT 
    team_id,
    TRY_CAST(r[1] AS INTEGER) AS col_1,
    TRY_CAST(r[2] AS INTEGER) AS col_2,
    TRY_CAST(r[3] AS INTEGER) AS col_3,
    TRY_CAST(r[4] AS INTEGER) AS col_4,
    TRY_CAST(r[5] AS INTEGER) AS col_5,
    TRY_CAST(r[6] AS INTEGER) AS col_6,
    TRY_CAST(r[7] AS INTEGER) AS col_7,
    TRY_CAST(r[8] AS INTEGER) AS col_8,
    TRY_CAST(r[9] AS INTEGER) AS col_9,
    TRY_CAST(r[10] AS INTEGER) AS col_10,
    TRY_CAST(r[11] AS INTEGER) AS col_11,
    TRY_CAST(r[12] AS INTEGER) AS col_12,
    TRY_CAST(r[13] AS INTEGER) AS col_13
FROM unnested_rows;


-- -----------------------------------------------------------------------------
-- 8. Club Trophy Cabinet & Honors View
-- Extracts tournament trophies, winning seasons, and competition IDs from 'TeamHonor'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_team_honors AS
WITH base AS (
    SELECT 
        TRY_CAST(TeamInfo[1] AS INTEGER) AS team_id,
        UNNEST(TeamHonor) AS h
    FROM read_json(
        'json/team_detail.json',
        columns = {
            'TeamInfo': 'VARCHAR[]',
            'TeamHonor': 'VARCHAR[][]'
        }
    )
)
SELECT 
    team_id,
    h[1] AS honor_title,
    h[2] AS seasons_won,
    TRY_CAST(h[3] AS INTEGER) AS honor_id
FROM base;


-- -----------------------------------------------------------------------------
-- 9. Tactical Characteristics & Play Style View
-- Extracts tactical strengths, weaknesses, and playing styles from 'teamCharacter'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_team_characteristics AS
WITH base AS (
    SELECT 
        TRY_CAST(TeamInfo[1] AS INTEGER) AS team_id,
        UNNEST(teamCharacter) AS c
    FROM read_json(
        'json/team_detail.json',
        columns = {
            'TeamInfo': 'VARCHAR[]',
            'teamCharacter': 'VARCHAR[][]'
        }
    )
)
SELECT 
    team_id,
    TRY_CAST(c[1] AS INTEGER) AS character_type_id,
    CASE TRY_CAST(c[1] AS INTEGER)
        WHEN 1 THEN 'Strength'
        WHEN 2 THEN 'Weakness'
        WHEN 3 THEN 'Style'
        ELSE 'Other'
    END AS character_type,
    TRY_CAST(c[2] AS INTEGER) AS character_rating_id,
    c[3] AS character_name
FROM base;


-- -----------------------------------------------------------------------------
-- Preview queries:
-- -----------------------------------------------------------------------------
SELECT * FROM v_team_info;
SELECT * FROM v_team_squad_groups;
SELECT * FROM v_team_lineup_detail;
SELECT * FROM v_team_cup_competitions;
SELECT * FROM v_team_competition_stats;
SELECT * FROM v_team_matches;
SELECT * FROM v_team_league_data;
SELECT * FROM v_team_honors;
SELECT * FROM v_team_characteristics;
