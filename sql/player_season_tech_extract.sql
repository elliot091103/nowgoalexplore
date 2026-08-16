-- =============================================================================
-- DuckDB SQL Extraction Script for Nowgoal player_season_tech.json
-- Requirement: Extract tournament player technical statistics, player profiles,
--              teams, and 57 statistical metrics across Total, Home, and Away splits
--              based on player_sesason_tech_documentation.md.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Teams Lookup View
-- Extracts participating teams and country names from 'TechCountInfo.Tid'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_player_season_teams AS
WITH raw AS (
    SELECT TechCountInfo.Tid AS tid_json
    FROM read_json(
        'json/player_season_tech.json',
        columns = {'TechCountInfo': 'STRUCT(Tid JSON)'}
    )
),
keys_extracted AS (
    SELECT UNNEST(json_keys(tid_json)) AS tid_key, tid_json
    FROM raw
),
parsed AS (
    SELECT 
        TRY_CAST(tid_key AS INTEGER) AS team_id,
        json_extract(tid_json, '$.' || tid_key) AS t_data
    FROM keys_extracted
)
SELECT 
    team_id,
    t_data->>'$[0]' AS team_name
FROM parsed;


-- -----------------------------------------------------------------------------
-- 2. Player Profiles Lookup View
-- Extracts player metadata, photos, and team affiliations from 'TechCountInfo.Pid'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_player_season_profiles AS
WITH raw AS (
    SELECT TechCountInfo.Pid AS pid_json
    FROM read_json(
        'json/player_season_tech.json',
        columns = {'TechCountInfo': 'STRUCT(Pid JSON)'}
    )
),
keys_extracted AS (
    SELECT UNNEST(json_keys(pid_json)) AS pid_key, pid_json
    FROM raw
),
parsed AS (
    SELECT 
        TRY_CAST(pid_key AS INTEGER) AS player_id,
        json_extract(pid_json, '$.' || pid_key) AS p_data
    FROM keys_extracted
)
SELECT 
    p.player_id,
    p.p_data->>'$[0][0]' AS player_name,
    NULLIF(p.p_data->>'$[0][1]', '') AS player_photo,
    TRY_CAST(p.p_data->>'$[1]' AS INTEGER) AS team_id,
    t.team_name
FROM parsed p
LEFT JOIN v_player_season_teams t 
    ON TRY_CAST(p.p_data->>'$[1]' AS INTEGER) = t.team_id;


-- -----------------------------------------------------------------------------
-- 3. Tournament Player Technical Statistics View (57 Metrics)
-- Extracts granular performance metrics across Total, Home, and Guest splits.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_player_season_stats AS
WITH base AS (
    SELECT TechCountInfo 
    FROM read_json(
        'json/player_season_tech.json',
        columns = {
            'TechCountInfo': 'STRUCT(Total STRUCT("Value" DOUBLE[][]), Home STRUCT("Value" DOUBLE[][]), Guest STRUCT("Value" DOUBLE[][]))'
        }
    )
),
all_scopes AS (
    SELECT 'Total' AS venue_scope, UNNEST(TechCountInfo.Total.Value) AS m FROM base
    UNION ALL
    SELECT 'Home' AS venue_scope, UNNEST(TechCountInfo.Home.Value) AS m FROM base
    UNION ALL
    SELECT 'Guest' AS venue_scope, UNNEST(TechCountInfo.Guest.Value) AS m FROM base
)
SELECT 
    venue_scope,
    TRY_CAST(m[1] AS INTEGER) AS player_id,
    TRY_CAST(m[2] AS INTEGER) AS matches_played,
    TRY_CAST(m[3] AS INTEGER) AS bench_appearances,
    TRY_CAST(m[4] AS INTEGER) AS minutes_played,
    TRY_CAST(m[5] AS INTEGER) AS non_penalty_goals,
    TRY_CAST(m[6] AS INTEGER) AS penalty_goals,
    TRY_CAST(m[7] AS INTEGER) AS shots,
    TRY_CAST(m[8] AS INTEGER) AS shots_on_target,
    TRY_CAST(m[9] AS INTEGER) AS fouls_drawn,
    TRY_CAST(m[10] AS INTEGER) AS motm_count,
    TRY_CAST(m[11] AS DOUBLE) AS rating_sum,
    TRY_CAST(m[12] AS INTEGER) AS rated_matches,
    ROUND(TRY_CAST(m[11] AS DOUBLE) / NULLIF(TRY_CAST(m[12] AS DOUBLE), 0), 2) AS avg_rating,
    TRY_CAST(m[13] AS INTEGER) AS passes,
    TRY_CAST(m[14] AS INTEGER) AS passes_success,
    TRY_CAST(m[15] AS INTEGER) AS key_passes,
    TRY_CAST(m[16] AS INTEGER) AS assists,
    TRY_CAST(m[17] AS INTEGER) AS long_balls,
    TRY_CAST(m[18] AS INTEGER) AS long_balls_success,
    TRY_CAST(m[19] AS INTEGER) AS through_balls,
    TRY_CAST(m[20] AS INTEGER) AS through_balls_success,
    TRY_CAST(m[21] AS INTEGER) AS crosses,
    TRY_CAST(m[22] AS INTEGER) AS crosses_success,
    TRY_CAST(m[23] AS INTEGER) AS dribbles_success,
    TRY_CAST(m[24] AS INTEGER) AS offsides,
    TRY_CAST(m[25] AS INTEGER) AS tackles,
    TRY_CAST(m[26] AS INTEGER) AS interceptions,
    TRY_CAST(m[27] AS INTEGER) AS clearances,
    TRY_CAST(m[28] AS INTEGER) AS effective_clearances,
    TRY_CAST(m[29] AS INTEGER) AS offsides_provoked,
    TRY_CAST(m[30] AS INTEGER) AS dispossessed,
    TRY_CAST(m[31] AS INTEGER) AS shots_blocked,
    TRY_CAST(m[32] AS INTEGER) AS aerials_won,
    TRY_CAST(m[33] AS INTEGER) AS fouls_committed,
    TRY_CAST(m[34] AS INTEGER) AS red_cards,
    TRY_CAST(m[35] AS INTEGER) AS yellow_cards,
    TRY_CAST(m[36] AS INTEGER) AS own_goals,
    TRY_CAST(m[37] AS INTEGER) AS touches,
    TRY_CAST(m[38] AS INTEGER) AS turnovers,
    TRY_CAST(m[39] AS INTEGER) AS penalties_won,
    TRY_CAST(m[40] AS INTEGER) AS shots_on_post,
    TRY_CAST(m[41] AS DOUBLE) AS xg,
    TRY_CAST(m[42] AS DOUBLE) AS xa,
    TRY_CAST(m[43] AS DOUBLE) AS xgot,
    TRY_CAST(m[44] AS INTEGER) AS headed_clearances,
    TRY_CAST(m[45] AS INTEGER) AS touches_in_box,
    TRY_CAST(m[46] AS DOUBLE) AS xgot_faced,
    TRY_CAST(m[47] AS DOUBLE) AS goals_prevented,
    TRY_CAST(m[48] AS INTEGER) AS passes_final_third,
    TRY_CAST(m[49] AS INTEGER) AS recoveries,
    TRY_CAST(m[50] AS INTEGER) AS defensive_actions,
    TRY_CAST(m[51] AS INTEGER) AS sweeper_actions,
    TRY_CAST(m[52] AS DOUBLE) AS npxg,
    TRY_CAST(m[53] AS INTEGER) AS total_goals,
    TRY_CAST(m[54] AS DOUBLE) AS pass_accuracy_pct,
    TRY_CAST(m[55] AS DOUBLE) AS mins_per_assist,
    TRY_CAST(m[56] AS DOUBLE) AS mins_per_goal,
    TRY_CAST(m[57] AS DOUBLE) AS shot_conversion_pct
FROM all_scopes;


-- -----------------------------------------------------------------------------
-- 4. Full Analytical Player Performance View (Joined with Profiles & Teams)
-- Convenient combined view linking all 57 metrics with player and team names.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_player_season_tech_full AS
SELECT 
    s.venue_scope,
    s.player_id,
    p.player_name,
    p.player_photo,
    p.team_id,
    p.team_name,
    s.matches_played,
    s.bench_appearances,
    s.minutes_played,
    s.total_goals,
    s.non_penalty_goals,
    s.penalty_goals,
    s.assists,
    s.avg_rating,
    s.shots,
    s.shots_on_target,
    s.shot_conversion_pct,
    s.passes,
    s.passes_success,
    s.pass_accuracy_pct,
    s.key_passes,
    s.xg,
    s.xa,
    s.xgot,
    s.npxg,
    s.dribbles_success,
    s.tackles,
    s.interceptions,
    s.clearances,
    s.aerials_won,
    s.touches,
    s.touches_in_box,
    s.recoveries,
    s.defensive_actions,
    s.fouls_drawn,
    s.fouls_committed,
    s.yellow_cards,
    s.red_cards,
    s.motm_count,
    s.mins_per_goal,
    s.mins_per_assist,
    s.xgot_faced,
    s.goals_prevented,
    s.sweeper_actions
FROM v_player_season_stats s
LEFT JOIN v_player_season_profiles p 
    ON s.player_id = p.player_id;


-- -----------------------------------------------------------------------------
-- Preview queries:
-- -----------------------------------------------------------------------------
SELECT * FROM v_player_season_teams;
SELECT * FROM v_player_season_profiles;
SELECT * FROM v_player_season_stats;
SELECT * FROM v_player_season_tech_full;
