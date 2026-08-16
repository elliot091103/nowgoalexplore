-- =============================================================================
-- DuckDB SQL Extraction Script for Nowgoal player_match_tech.json
-- Requirement: Extract single-match player technical statistics, substitution timings,
--              attacking, passing, defensive metrics, in-match events, and team summaries
--              based on player_match_tech_documentation.md.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Match Response Envelope & State View
-- Extracts response status and current match state from the root JSON object.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_match_meta AS
SELECT 
    TRY_CAST(ErrCode AS INTEGER) AS err_code,
    TRY_CAST(MatchState AS INTEGER) AS match_state,
    CASE TRY_CAST(MatchState AS INTEGER)
        WHEN -1 THEN 'Finished / Full-Time'
        WHEN 0 THEN 'Not Started'
        WHEN 1 THEN '1st Half'
        WHEN 2 THEN 'Half-Time'
        WHEN 3 THEN '2nd Half'
        ELSE 'Other'
    END AS match_state_desc
FROM read_json('json/player_match_tech.json');


-- -----------------------------------------------------------------------------
-- 2. Match Player Technical Statistics View (35 Metrics)
-- Extracts granular player stats for Home (hList) and Away (gList) teams.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_match_player_tech AS
WITH base AS (
    SELECT 
        Data.hList AS home_list,
        Data.gList AS away_list
    FROM read_json('json/player_match_tech.json')
),
all_players AS (
    SELECT 'Home' AS team_side, UNNEST(home_list) AS p FROM base
    UNION ALL
    SELECT 'Away' AS team_side, UNNEST(away_list) AS p FROM base
)
SELECT 
    team_side,
    TRY_CAST(p.id AS INTEGER) AS player_id,
    TRY_CAST(p.no AS INTEGER) AS jersey_number,
    p.name AS player_name,
    p.photo AS player_photo,
    p.pName AS position_role,
    TRY_CAST(p.valid AS BOOLEAN) AS is_valid,
    TRY_CAST(p.subTime AS INTEGER) AS sub_in_minute,
    TRY_CAST(p.subst AS INTEGER) AS sub_in_added_mins,
    TRY_CAST(p.offsubTime AS INTEGER) AS sub_out_minute,
    TRY_CAST(p.offsub AS INTEGER) AS sub_out_added_mins,
    TRY_CAST(p.rating AS DOUBLE) AS rating,
    TRY_CAST(p.shots AS INTEGER) AS shots,
    TRY_CAST(p.shotsTarget AS INTEGER) AS shots_on_target,
    TRY_CAST(p.dribblesWon AS INTEGER) AS dribbles_won,
    TRY_CAST(p.wasFouled AS INTEGER) AS fouls_drawn,
    TRY_CAST(p.dispossessed AS INTEGER) AS dispossessed,
    TRY_CAST(p.turnOver AS INTEGER) AS turnovers,
    TRY_CAST(p.offsides AS INTEGER) AS offsides,
    TRY_CAST(p.totalPass AS INTEGER) AS total_passes,
    TRY_CAST(p.accuratePass AS INTEGER) AS accurate_passes,
    ROUND(TRY_CAST(p.accuratePass AS DOUBLE) * 100.0 / NULLIF(TRY_CAST(p.totalPass AS DOUBLE), 0), 2) AS pass_accuracy_pct,
    TRY_CAST(p.keyPass AS INTEGER) AS key_passes,
    TRY_CAST(p.crossNum AS INTEGER) AS crosses,
    TRY_CAST(p.crossWon AS INTEGER) AS accurate_crosses,
    TRY_CAST(p.longBall AS INTEGER) AS long_balls,
    TRY_CAST(p.longBallWon AS INTEGER) AS accurate_long_balls,
    TRY_CAST(p.throughBall AS INTEGER) AS through_balls,
    TRY_CAST(p.throughBallWon AS INTEGER) AS accurate_through_balls,
    TRY_CAST(p.tackles AS INTEGER) AS tackles,
    TRY_CAST(p.interception AS INTEGER) AS interceptions,
    TRY_CAST(p.clearances AS INTEGER) AS clearances,
    TRY_CAST(p.clearanceWon AS INTEGER) AS effective_clearances,
    TRY_CAST(p.shotsBlocked AS INTEGER) AS shots_blocked,
    TRY_CAST(p.offsideProvoked AS INTEGER) AS offside_provoked,
    TRY_CAST(p.fouls AS INTEGER) AS fouls_committed,
    NULLIF(p.event, '') AS raw_events
FROM all_players;


-- -----------------------------------------------------------------------------
-- 3. Match Player Events View
-- Unnests caret-delimited (^) event codes and maps them to descriptive names.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_match_player_events AS
WITH base AS (
    SELECT 
        Data.hList AS home_list,
        Data.gList AS away_list
    FROM read_json('json/player_match_tech.json')
),
all_players AS (
    SELECT 'Home' AS team_side, UNNEST(home_list) AS p FROM base
    UNION ALL
    SELECT 'Away' AS team_side, UNNEST(away_list) AS p FROM base
),
players_with_events AS (
    SELECT 
        team_side,
        TRY_CAST(p.id AS INTEGER) AS player_id,
        p.name AS player_name,
        TRY_CAST(p.no AS INTEGER) AS jersey_number,
        p.pName AS position_role,
        UNNEST(string_split(p.event, '^')) AS event_code_str
    FROM all_players
    WHERE p.event IS NOT NULL AND p.event != ''
)
SELECT 
    team_side,
    player_id,
    player_name,
    jersey_number,
    position_role,
    TRY_CAST(event_code_str AS INTEGER) AS event_id,
    CASE TRY_CAST(event_code_str AS INTEGER)
        WHEN 1 THEN 'Goal'
        WHEN 2 THEN 'Red Card'
        WHEN 3 THEN 'Yellow Card'
        WHEN 4 THEN 'Sub in'
        WHEN 5 THEN 'Sub out'
        WHEN 7 THEN 'Penalty Scored'
        WHEN 8 THEN 'Own Goal'
        WHEN 9 THEN 'Second Yellow Card'
        WHEN 11 THEN 'Substitution'
        WHEN 12 THEN 'Assist'
        WHEN 13 THEN 'Penalty Missed'
        WHEN 14 THEN 'VAR'
        WHEN 30 THEN 'Penalty Saved'
        WHEN 31 THEN 'Hit the Post'
        WHEN 32 THEN 'Man of the Match'
        WHEN 33 THEN 'Error Led to Goal'
        WHEN 34 THEN 'Last Man Tackle'
        WHEN 35 THEN 'Clearance Off Line'
        WHEN 36 THEN 'Foul Led to Penalty'
        WHEN 37 THEN 'Last Dribble'
        WHEN 55 THEN 'Mark'
        ELSE 'Unknown Event'
    END AS event_name
FROM players_with_events;


-- -----------------------------------------------------------------------------
-- 4. Match Team Technical Summary View
-- Computes aggregated team totals and shooting/passing efficiencies for Home vs Away.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_match_team_stats_summary AS
SELECT 
    team_side,
    COUNT(CASE WHEN is_valid THEN 1 END) AS players_featured,
    ROUND(AVG(CASE WHEN is_valid AND rating > 0 THEN rating END), 2) AS team_avg_rating,
    SUM(shots) AS total_shots,
    SUM(shots_on_target) AS total_shots_on_target,
    ROUND(SUM(shots_on_target) * 100.0 / NULLIF(SUM(shots), 0), 2) AS shot_accuracy_pct,
    SUM(dribbles_won) AS total_dribbles_won,
    SUM(total_passes) AS total_passes,
    SUM(accurate_passes) AS total_accurate_passes,
    ROUND(SUM(accurate_passes) * 100.0 / NULLIF(SUM(total_passes), 0), 2) AS team_pass_accuracy_pct,
    SUM(key_passes) AS total_key_passes,
    SUM(crosses) AS total_crosses,
    SUM(accurate_crosses) AS total_accurate_crosses,
    SUM(long_balls) AS total_long_balls,
    SUM(accurate_long_balls) AS total_accurate_long_balls,
    SUM(through_balls) AS total_through_balls,
    SUM(accurate_through_balls) AS total_accurate_through_balls,
    SUM(tackles) AS total_tackles,
    SUM(interceptions) AS total_interceptions,
    SUM(clearances) AS total_clearances,
    SUM(effective_clearances) AS total_effective_clearances,
    SUM(shots_blocked) AS total_shots_blocked,
    SUM(offside_provoked) AS total_offside_provoked,
    SUM(fouls_committed) AS total_fouls,
    SUM(fouls_drawn) AS total_fouled,
    SUM(offsides) AS total_offsides
FROM v_match_player_tech
GROUP BY team_side;


-- -----------------------------------------------------------------------------
-- Preview queries:
-- -----------------------------------------------------------------------------
SELECT * FROM v_match_meta;
SELECT * FROM v_match_player_tech;
SELECT * FROM v_match_player_events;
SELECT * FROM v_match_team_stats_summary;
