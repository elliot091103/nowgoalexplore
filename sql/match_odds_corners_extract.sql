-- =============================================================================
-- DuckDB SQL Extraction Script for Nowgoal match_odds_corners.json
-- Requirement: Extract live Corner Over/Under and Corner Handicap trend updates
--              based on match_odd_documentation.md (Market Type t=28).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Corner Odds Response Metadata View
-- Extracts response status and match state.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_corners_meta AS
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
FROM read_json('json/match_odds_corners.json');


-- -----------------------------------------------------------------------------
-- 2. Corner Over / Under Odds Trend View
-- Unnests live Corner Over/Under line threshold movements and running corner counts.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_corners_over_under AS
WITH base AS (
    SELECT Data FROM read_json('json/match_odds_corners.json')
)
SELECT 
    'Corners Over/Under' AS market_name,
    epoch_ms(TRY_CAST(o.mt AS BIGINT)) AS modify_time,
    NULLIF(o.ht, '') AS match_minute,
    TRY_CAST(o.hs AS INTEGER) AS home_corners,
    TRY_CAST(o.gs AS INTEGER) AS guest_corners,
    TRY_CAST(o.hs AS INTEGER) + TRY_CAST(o.gs AS INTEGER) AS total_corners,
    TRY_CAST(NULLIF(o.odds.u, '') AS DOUBLE) AS corner_over_odds,
    NULLIF(o.odds.g, '') AS corner_line,
    TRY_CAST(NULLIF(o.odds.d, '') AS DOUBLE) AS corner_under_odds,
    TRY_CAST(o.close AS BOOLEAN) AS is_closed,
    TRY_CAST(o.type AS INTEGER) AS stage_type_id,
    CASE TRY_CAST(o.type AS INTEGER)
        WHEN 3 THEN 'Corner Live Feed'
        ELSE 'Pre-match'
    END AS stage_type
FROM (SELECT UNNEST(Data.ou) AS o FROM base);


-- -----------------------------------------------------------------------------
-- 3. Corner Asian Handicap Odds Trend View (if present)
-- Unnests corner spread and handicap changes from Data.ah.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_corners_handicap AS
WITH base AS (
    SELECT Data FROM read_json('json/match_odds_corners.json')
)
SELECT 
    'Corners Handicap' AS market_name,
    epoch_ms(TRY_CAST(a.mt AS BIGINT)) AS modify_time,
    NULLIF(a.ht, '') AS match_minute,
    TRY_CAST(a.hs AS INTEGER) AS home_corners,
    TRY_CAST(a.gs AS INTEGER) AS guest_corners,
    TRY_CAST(a.hs AS INTEGER) + TRY_CAST(a.gs AS INTEGER) AS total_corners,
    TRY_CAST(NULLIF(a.odds.u, '') AS DOUBLE) AS home_corner_odds,
    NULLIF(a.odds.g, '') AS corner_handicap_line,
    TRY_CAST(NULLIF(a.odds.d, '') AS DOUBLE) AS away_corner_odds,
    TRY_CAST(a.close AS BOOLEAN) AS is_closed,
    TRY_CAST(a.type AS INTEGER) AS stage_type_id
FROM (SELECT UNNEST(Data.ah) AS a FROM base);


-- -----------------------------------------------------------------------------
-- Preview queries:
-- -----------------------------------------------------------------------------
SELECT * FROM v_odds_corners_meta;
SELECT * FROM v_odds_corners_over_under WHERE corner_over_odds IS NOT NULL LIMIT 5;
SELECT * FROM v_odds_corners_handicap LIMIT 5;
