-- =============================================================================
-- DuckDB SQL Extraction Script for Nowgoal player_info.json
-- Requirement: Extract player general info (Basic Info, Radar Attributes, 
-- Transfer History, Total Stats, and Match-by-Match Log)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Player Basic Info View
-- Extracts player metadata from the 'PlayerInfo' JSON array.
-- Note: PlayerInfo[10] represents estimated market value (divided by 100 = Million EUR/GBP).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_player_basic_info AS
SELECT 
    TRY_CAST(PlayerInfo[1]->>'$' AS INTEGER) AS player_id,
    PlayerInfo[2]->>'$' AS player_name,
    PlayerInfo[3]->>'$' AS player_photo,
    TRY_CAST(PlayerInfo[4]->>'$' AS INTEGER) AS current_team_id,
    PlayerInfo[5]->>'$' AS current_team_name,
    PlayerInfo[6]->>'$' AS current_team_logo,
    PlayerInfo[7]->>'$' AS nationality,
    PlayerInfo[8]->>'$' AS country_flag,
    TRY_CAST(PlayerInfo[9]->>'$' AS INTEGER) AS jersey_number,
    TRY_CAST(NULLIF(PlayerInfo[10]->>'$', '') AS INTEGER) AS market_value_raw,
    CASE 
        WHEN NULLIF(PlayerInfo[10]->>'$', '') IS NOT NULL 
        THEN TRY_CAST(PlayerInfo[10]->>'$' AS DOUBLE) / 100.0 
        ELSE NULL 
    END AS market_value_million_eur,
    TRY_CAST(NULLIF(PlayerInfo[11]->>'$', '') AS DATE) AS contract_expiry,
    TRY_CAST(NULLIF(PlayerInfo[12]->>'$', '') AS DATE) AS birth_date,
    TRY_CAST(NULLIF(PlayerInfo[13]->>'$', '') AS INTEGER) AS height_cm,
    TRY_CAST(NULLIF(PlayerInfo[14]->>'$', '') AS INTEGER) AS weight_kg,
    TRY_CAST(PlayerInfo[15]->>'$' AS INTEGER) AS preferred_foot_id,
    CASE TRY_CAST(PlayerInfo[15]->>'$' AS INTEGER)
        WHEN 0 THEN 'Left'
        WHEN 1 THEN 'Right'
        WHEN 2 THEN 'Both'
        ELSE 'Unknown'
    END AS preferred_foot,
    TRY_CAST(PlayerInfo[16]->>'$' AS INTEGER) AS current_league_id,
    LastUpdateTime AS last_update_time
FROM read_json('json/player_info.json');


-- -----------------------------------------------------------------------------
-- 2. Player Radar / Attribute Ratings View
-- Extracts player attribute scores from 'RadarInfo' directly named by role.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_player_radar_attributes AS
SELECT 
    TRY_CAST(PlayerInfo[1]->>'$' AS INTEGER) AS player_id,
    TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) AS role_type_id,
    CASE TRY_CAST(RadarInfo[1]->>'$' AS INTEGER)
        WHEN 1 THEN 'Outfield'
        WHEN 2 THEN 'Goalkeeper'
        ELSE 'Unknown'
    END AS role_type,
    -- Outfield Attributes (role_type_id = 1)
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 1 THEN TRY_CAST(RadarInfo[2]->>'$' AS INTEGER) END AS pace,
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 1 THEN TRY_CAST(RadarInfo[3]->>'$' AS INTEGER) END AS shooting,
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 1 THEN TRY_CAST(RadarInfo[4]->>'$' AS INTEGER) END AS physicality,
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 1 THEN TRY_CAST(RadarInfo[5]->>'$' AS INTEGER) END AS passing,
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 1 THEN TRY_CAST(RadarInfo[6]->>'$' AS INTEGER) END AS defending,
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 1 THEN TRY_CAST(RadarInfo[7]->>'$' AS INTEGER) END AS dribbling,
    -- Goalkeeper Attributes (role_type_id = 2)
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 2 THEN TRY_CAST(RadarInfo[2]->>'$' AS INTEGER) END AS diving,
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 2 THEN TRY_CAST(RadarInfo[3]->>'$' AS INTEGER) END AS handling,
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 2 THEN TRY_CAST(RadarInfo[4]->>'$' AS INTEGER) END AS positioning,
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 2 THEN TRY_CAST(RadarInfo[5]->>'$' AS INTEGER) END AS kicking,
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 2 THEN TRY_CAST(RadarInfo[6]->>'$' AS INTEGER) END AS speed,
    CASE WHEN TRY_CAST(RadarInfo[1]->>'$' AS INTEGER) = 2 THEN TRY_CAST(RadarInfo[7]->>'$' AS INTEGER) END AS reflexes
FROM read_json('json/player_info.json');


-- -----------------------------------------------------------------------------
-- 3. Player Transfer History View
-- Unnests and extracts transfer records from the 'TransferInfo' 2D array.
-- Note: TransferInfo is VARCHAR[][], so array elements are accessed directly as strings.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_player_transfers AS
WITH raw_transfers AS (
    SELECT 
        TRY_CAST(PlayerInfo[1]->>'$' AS INTEGER) AS player_id,
        UNNEST(TransferInfo) AS t
    FROM read_json('json/player_info.json')
)
SELECT 
    player_id,
    t[1] AS season,
    TRY_CAST(t[2] AS INTEGER) AS from_team_id,
    t[8] AS from_team_name,
    t[10] AS from_team_logo,
    TRY_CAST(t[3] AS INTEGER) AS to_team_id,
    t[9] AS to_team_name,
    t[11] AS to_team_logo,
    TRY_CAST(NULLIF(t[4], '') AS DATE) AS transfer_date,
    TRY_CAST(NULLIF(t[5], '') AS DATE) AS contract_end_date,
    CASE 
        WHEN t[6] IS NOT NULL AND t[6] != '' 
        THEN TRY_CAST(t[6] AS DOUBLE) / 100.0 
        ELSE NULL 
    END AS fee_million_eur,
    TRY_CAST(t[7] AS INTEGER) AS transfer_type_id,
    CASE TRY_CAST(t[7] AS INTEGER)
        WHEN 1 THEN 'Full Ownership'
        WHEN 2 THEN 'Loan'
        WHEN 3 THEN 'Free Transfer'
        WHEN 4 THEN 'End of loan'
        WHEN 5 THEN 'Co-ownership'
        ELSE 'Other'
    END AS transfer_type
FROM raw_transfers;


-- -----------------------------------------------------------------------------
-- 4. Player Total / Overall Career Stats View
-- Extracts pre-aggregated overall statistical totals from row 0 of 'CountSum' (DuckDB Index 1).
-- Note: CountSum is VARCHAR[][], so array elements are accessed directly as strings.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_player_total_stats AS
WITH raw_stats AS (
    SELECT 
        TRY_CAST(PlayerInfo[1]->>'$' AS INTEGER) AS player_id,
        CountSum[1] AS s -- Index 1 in DuckDB (1-based) corresponds to row 0 (Career Total)
    FROM read_json('json/player_info.json')
)
SELECT 
    player_id,
    TRY_CAST(s[1] AS INTEGER) + TRY_CAST(s[3] AS INTEGER) AS total_matches,
    TRY_CAST(s[1] AS INTEGER) AS starts,
    TRY_CAST(s[3] AS INTEGER) AS substitutions,
    TRY_CAST(s[2] AS INTEGER) AS league_starts,
    TRY_CAST(s[4] AS INTEGER) AS competition_goals,
    TRY_CAST(s[5] AS INTEGER) AS penalty_goals,
    TRY_CAST(s[8] AS INTEGER) AS goals,
    TRY_CAST(s[9] AS INTEGER) AS shots,
    TRY_CAST(s[10] AS INTEGER) AS shots_on_target,
    TRY_CAST(s[11] AS INTEGER) AS assists,
    TRY_CAST(s[12] AS INTEGER) AS passes,
    TRY_CAST(s[13] AS INTEGER) AS passes_success,
    ROUND(TRY_CAST(s[13] AS DOUBLE) * 100.0 / NULLIF(TRY_CAST(s[12] AS DOUBLE), 0), 1) AS pass_success_pct,
    TRY_CAST(s[14] AS INTEGER) AS key_passes,
    TRY_CAST(s[15] AS INTEGER) AS long_passes,
    TRY_CAST(s[16] AS INTEGER) AS through_balls,
    TRY_CAST(s[17] AS INTEGER) AS dribbles,
    TRY_CAST(s[18] AS INTEGER) AS fouled,
    TRY_CAST(s[19] AS INTEGER) AS fouls,
    TRY_CAST(s[20] AS INTEGER) AS interceptions,
    TRY_CAST(s[21] AS INTEGER) AS clearances,
    TRY_CAST(s[22] AS INTEGER) AS steals,
    TRY_CAST(s[23] AS INTEGER) AS tackles,
    TRY_CAST(s[24] AS INTEGER) AS blocked_shots,
    TRY_CAST(s[25] AS INTEGER) AS headers_won,
    TRY_CAST(s[26] AS INTEGER) AS offsides,
    TRY_CAST(s[27] AS INTEGER) AS yellow_cards,
    TRY_CAST(s[28] AS INTEGER) AS red_cards,
    TRY_CAST(s[29] AS DOUBLE) AS mins_per_goal_rate,
    TRY_CAST(s[30] AS DOUBLE) AS sog_rate,
    TRY_CAST(s[31] AS INTEGER) AS motm_count,
    TRY_CAST(s[32] AS DOUBLE) AS avg_rating
FROM raw_stats;


-- -----------------------------------------------------------------------------
-- 5. Player Match Performance Log View
-- Unnests single-match appearances, ratings, and stats from 'playerCount'.
-- Note: playerCount is JSON[][], so array elements inside m are extracted using ->>'$'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_player_match_log AS
WITH raw_matches AS (
    SELECT 
        TRY_CAST(PlayerInfo[1]->>'$' AS INTEGER) AS player_id,
        UNNEST(playerCount) AS m
    FROM read_json('json/player_info.json')
)
SELECT 
    player_id,
    TRY_CAST(m[1]->>'$' AS INTEGER) AS match_id,
    TRY_CAST(m[2]->>'$' AS INTEGER) AS home_team_id,
    m[7]->>'$' AS home_team_name,
    TRY_CAST(NULLIF(m[9]->>'$', '') AS INTEGER) AS home_score,
    TRY_CAST(m[3]->>'$' AS INTEGER) AS away_team_id,
    m[8]->>'$' AS away_team_name,
    TRY_CAST(NULLIF(m[10]->>'$', '') AS INTEGER) AS away_score,
    TRY_CAST(NULLIF(m[4]->>'$', '') AS TIMESTAMP) AS match_time,
    m[40]->>'$' AS season,
    TRY_CAST(NULLIF(m[41]->>'$', '') AS INTEGER) AS league_id,
    m[5]->>'$' AS league_name,
    m[6]->>'$' AS league_color,
    TRY_CAST(NULLIF(m[42]->>'$', '') AS INTEGER) AS stage_id,
    TRY_CAST(m[11]->>'$' AS INTEGER) = 1 AS is_starter,
    TRY_CAST(NULLIF(m[39]->>'$', '') AS INTEGER) AS minutes_played,
    TRY_CAST(NULLIF(m[18]->>'$', '') AS DOUBLE) AS rating,
    TRY_CAST(NULLIF(m[12]->>'$', '') AS INTEGER) AS goals,
    TRY_CAST(NULLIF(m[13]->>'$', '') AS INTEGER) AS penalty_goals,
    TRY_CAST(NULLIF(m[14]->>'$', '') AS INTEGER) AS own_goals,
    TRY_CAST(NULLIF(m[16]->>'$', '') AS INTEGER) AS assists,
    TRY_CAST(m[17]->>'$' AS INTEGER) = 1 AS is_motm,
    TRY_CAST(NULLIF(m[19]->>'$', '') AS INTEGER) AS shots,
    TRY_CAST(NULLIF(m[20]->>'$', '') AS INTEGER) AS shots_on_target,
    TRY_CAST(NULLIF(m[21]->>'$', '') AS INTEGER) AS blocked_shots_off,
    TRY_CAST(NULLIF(m[22]->>'$', '') AS INTEGER) AS passes,
    TRY_CAST(NULLIF(m[23]->>'$', '') AS INTEGER) AS passes_success,
    TRY_CAST(NULLIF(m[24]->>'$', '') AS INTEGER) AS key_passes,
    TRY_CAST(NULLIF(m[25]->>'$', '') AS INTEGER) AS long_passes,
    TRY_CAST(NULLIF(m[26]->>'$', '') AS INTEGER) AS through_balls,
    TRY_CAST(NULLIF(m[27]->>'$', '') AS INTEGER) AS dribbles,
    TRY_CAST(NULLIF(m[28]->>'$', '') AS INTEGER) AS fouled,
    TRY_CAST(NULLIF(m[29]->>'$', '') AS INTEGER) AS fouls,
    TRY_CAST(NULLIF(m[30]->>'$', '') AS INTEGER) AS interceptions,
    TRY_CAST(NULLIF(m[31]->>'$', '') AS INTEGER) AS clearances,
    TRY_CAST(NULLIF(m[32]->>'$', '') AS INTEGER) AS steals,
    TRY_CAST(NULLIF(m[33]->>'$', '') AS INTEGER) AS tackles,
    TRY_CAST(NULLIF(m[34]->>'$', '') AS INTEGER) AS blocked_shots_def,
    TRY_CAST(NULLIF(m[35]->>'$', '') AS INTEGER) AS aerials_won,
    TRY_CAST(NULLIF(m[36]->>'$', '') AS INTEGER) AS offsides,
    TRY_CAST(NULLIF(m[15]->>'$', '') AS INTEGER) AS yellow_cards,
    TRY_CAST(NULLIF(m[38]->>'$', '') AS INTEGER) AS red_cards,
    m[43]->>'$' AS video_url,
    m[44]->>'$' AS video_status
FROM raw_matches;


-- -----------------------------------------------------------------------------
-- Preview queries:
-- -----------------------------------------------------------------------------
SELECT * FROM v_player_basic_info;
SELECT * FROM v_player_radar_attributes;
SELECT * FROM v_player_transfers;
SELECT * FROM v_player_total_stats;
SELECT * FROM v_player_match_log LIMIT 5;
