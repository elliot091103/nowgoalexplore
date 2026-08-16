-- =============================================================================
-- DuckDB SQL Extraction Script for Nowgoal match_odds_doubleschance.json
-- Requirement: Extract Double Chance market odds history (1X, 12, X2)
--              based on match_odd_documentation.md (Market Type t=27).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Double Chance Odds Response Metadata View
-- Extracts response status and match progress state.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_double_chance_meta AS
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
FROM read_json('json/match_odds_doubleschance.json');


-- -----------------------------------------------------------------------------
-- 2. Double Chance Odds View
-- Unnests Double Chance market odds:
--   - odds_1x: Home Win or Draw (odds.u)
--   - odds_12: Home Win or Away Win (odds.g)
--   - odds_x2: Draw or Away Win (odds.d)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_double_chance AS
WITH base AS (
    SELECT Data FROM read_json('json/match_odds_doubleschance.json')
),
raw_list AS (
    SELECT UNNEST(Data.oddsList) AS o FROM base
)
SELECT 
    'Double Chance' AS market_name,
    to_timestamp(TRY_CAST(o.mt AS BIGINT)) AS modify_time,
    TRY_CAST(NULLIF(o.odds.u, '') AS DOUBLE) AS odds_1x,
    TRY_CAST(NULLIF(o.odds.g, '') AS DOUBLE) AS odds_12,
    TRY_CAST(NULLIF(o.odds.d, '') AS DOUBLE) AS odds_x2
FROM raw_list;


-- -----------------------------------------------------------------------------
-- Preview queries:
-- -----------------------------------------------------------------------------
SELECT * FROM v_odds_double_chance_meta;
SELECT * FROM v_odds_double_chance LIMIT 5;
