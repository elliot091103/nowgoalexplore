-- =============================================================================
-- DuckDB SQL Extraction Script for Nowgoal match_odds_3in1.json
-- Requirement: Extract 3in1 consolidated odds change history (Asian Handicap,
--              1X2 European Odds, and Over/Under Goal lines) based on
--              match_odd_documentation.md (Market Type t=20).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Match Odds Response Metadata View
-- Extracts response status and match progress state.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_3in1_meta AS
SELECT 
    TRY_CAST(ErrCode AS INTEGER) AS err_code,
    TRY_CAST(MatchState AS INTEGER) AS match_state,
    CASE TRY_CAST(MatchState AS INTEGER)
        WHEN -1 THEN 'Finished / Full-Time'
        WHEN 0 THEN 'Pre-match / Not Started'
        WHEN 1 THEN '1st Half'
        WHEN 2 THEN 'Half-Time'
        WHEN 3 THEN '2nd Half'
        ELSE 'Other'
    END AS match_state_desc
FROM read_json('json/match_odds_3in1.json');


-- -----------------------------------------------------------------------------
-- 2. Asian Handicap (AH) Odds Trend View
-- Unnests Asian Handicap line movements, odds prices, score state, and timestamps.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_3in1_asian_handicap AS
WITH base AS (
    SELECT Data FROM read_json('json/match_odds_3in1.json')
)
SELECT 
    'Asian Handicap' AS market_name,
    to_timestamp(TRY_CAST(a.mt AS BIGINT)) AS modify_time,
    NULLIF(a.ht, '') AS match_minute,
    TRY_CAST(a.hs AS INTEGER) AS home_score,
    TRY_CAST(a.gs AS INTEGER) AS guest_score,
    TRY_CAST(NULLIF(a.odds.u, '') AS DOUBLE) AS home_odds,
    NULLIF(a.odds.g, '') AS handicap_line,
    TRY_CAST(NULLIF(a.odds.d, '') AS DOUBLE) AS away_odds,
    TRY_CAST(a.close AS BOOLEAN) AS is_closed,
    TRY_CAST(a.type AS INTEGER) AS stage_type_id,
    CASE TRY_CAST(a.type AS INTEGER)
        WHEN 0 THEN 'Live / In-play'
        ELSE 'Pre-match'
    END AS stage_type
FROM (SELECT UNNEST(Data.ah) AS a FROM base);


-- -----------------------------------------------------------------------------
-- 3. 1X2 European Odds (OP) Trend View
-- Unnests European Home/Draw/Away match odds movements and timestamps.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_3in1_1x2 AS
WITH base AS (
    SELECT Data FROM read_json('json/match_odds_3in1.json')
)
SELECT 
    '1X2' AS market_name,
    to_timestamp(TRY_CAST(o.mt AS BIGINT)) AS modify_time,
    NULLIF(o.ht, '') AS match_minute,
    TRY_CAST(o.hs AS INTEGER) AS home_score,
    TRY_CAST(o.gs AS INTEGER) AS guest_score,
    TRY_CAST(NULLIF(o.odds.u, '') AS DOUBLE) AS home_win_odds,
    TRY_CAST(NULLIF(o.odds.g, '') AS DOUBLE) AS draw_odds,
    TRY_CAST(NULLIF(o.odds.d, '') AS DOUBLE) AS away_win_odds,
    TRY_CAST(o.close AS BOOLEAN) AS is_closed,
    TRY_CAST(o.type AS INTEGER) AS stage_type_id,
    CASE TRY_CAST(o.type AS INTEGER)
        WHEN 0 THEN 'Live / In-play'
        ELSE 'Pre-match'
    END AS stage_type
FROM (SELECT UNNEST(Data.op) AS o FROM base);


-- -----------------------------------------------------------------------------
-- 4. Over / Under (OU) Goals Trend View
-- Unnests total goal line benchmarks, Over/Under odds, and match progress state.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_3in1_over_under AS
WITH base AS (
    SELECT Data FROM read_json('json/match_odds_3in1.json')
)
SELECT 
    'Over/Under' AS market_name,
    to_timestamp(TRY_CAST(u.mt AS BIGINT)) AS modify_time,
    NULLIF(u.ht, '') AS match_minute,
    TRY_CAST(u.hs AS INTEGER) AS home_score,
    TRY_CAST(u.gs AS INTEGER) AS guest_score,
    TRY_CAST(NULLIF(u.odds.u, '') AS DOUBLE) AS over_odds,
    NULLIF(u.odds.g, '') AS goal_line,
    TRY_CAST(NULLIF(u.odds.d, '') AS DOUBLE) AS under_odds,
    TRY_CAST(u.close AS BOOLEAN) AS is_closed,
    TRY_CAST(u.type AS INTEGER) AS stage_type_id,
    CASE TRY_CAST(u.type AS INTEGER)
        WHEN 0 THEN 'Live / In-play'
        ELSE 'Pre-match'
    END AS stage_type
FROM (SELECT UNNEST(Data.ou) AS u FROM base);


-- -----------------------------------------------------------------------------
-- 5. Consolidated 3in1 Odds Stream View
-- Union of Asian Handicap, 1X2, and Over/Under trends into a single chronological feed.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_3in1_consolidated AS
SELECT 
    market_name,
    modify_time,
    match_minute,
    home_score,
    guest_score,
    home_odds AS price_home_or_over,
    handicap_line AS line_spread_or_draw,
    away_odds AS price_away_or_under,
    is_closed,
    stage_type
FROM v_odds_3in1_asian_handicap
UNION ALL
SELECT 
    market_name,
    modify_time,
    match_minute,
    home_score,
    guest_score,
    home_win_odds AS price_home_or_over,
    CAST(draw_odds AS VARCHAR) AS line_spread_or_draw,
    away_win_odds AS price_away_or_under,
    is_closed,
    stage_type
FROM v_odds_3in1_1x2
UNION ALL
SELECT 
    market_name,
    modify_time,
    match_minute,
    home_score,
    guest_score,
    over_odds AS price_home_or_over,
    goal_line AS line_spread_or_draw,
    under_odds AS price_away_or_under,
    is_closed,
    stage_type
FROM v_odds_3in1_over_under;


-- -----------------------------------------------------------------------------
-- Preview queries:
-- -----------------------------------------------------------------------------
SELECT * FROM v_odds_3in1_meta;
SELECT * FROM v_odds_3in1_asian_handicap LIMIT 5;
SELECT * FROM v_odds_3in1_1x2 LIMIT 5;
SELECT * FROM v_odds_3in1_over_under LIMIT 5;
SELECT * FROM v_odds_3in1_consolidated LIMIT 5;
