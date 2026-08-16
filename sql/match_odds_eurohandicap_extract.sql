-- =============================================================================
-- DuckDB SQL Extraction Script for Nowgoal match_odds_eurohandicap.json
-- Requirement: Extract Euro Handicap market odds history (Spread, Home, Draw, Away)
--              based on match_odd_documentation.md (Market Type t=26).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Euro Handicap Odds Response Metadata View
-- Extracts response status and match progress state.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_euro_handicap_meta AS
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
FROM read_json('json/match_odds_eurohandicap.json');


-- -----------------------------------------------------------------------------
-- 2. Euro Handicap Odds View
-- Unnests Euro Handicap market odds:
--   - handicap_spread: Spread line/value (odds.h)
--   - home_win_odds: Home win handicap odds (odds.u)
--   - draw_odds: Draw handicap odds (odds.g)
--   - away_win_odds: Away win handicap odds (odds.d)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_odds_euro_handicap AS
WITH base AS (
    SELECT Data FROM read_json('json/match_odds_eurohandicap.json')
),
raw_list AS (
    SELECT UNNEST(Data.oddsList) AS o FROM base
)
SELECT 
    'Euro Handicap' AS market_name,
    to_timestamp(TRY_CAST(o.mt AS BIGINT)) AS modify_time,
    o.odds.h->>'$' AS handicap_spread,
    TRY_CAST(NULLIF(o.odds.u, '') AS DOUBLE) AS home_win_odds,
    TRY_CAST(NULLIF(o.odds.g, '') AS DOUBLE) AS draw_odds,
    TRY_CAST(NULLIF(o.odds.d, '') AS DOUBLE) AS away_win_odds
FROM raw_list;


-- -----------------------------------------------------------------------------
-- Preview queries:
-- -----------------------------------------------------------------------------
SELECT * FROM v_odds_euro_handicap_meta;
SELECT * FROM v_odds_euro_handicap LIMIT 5;
