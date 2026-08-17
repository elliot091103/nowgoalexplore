-- =============================================================================
-- DuckDB SQL Extraction Script for Nowgoal season_detail.json
-- Requirement: Extract season tournament metadata, stages, participating teams,
--              fixtures/results, knockout aggregate ties, group standings,
--              advanced team technical stats, Asian Handicap (PanLu) stats,
--              Over/Under (Big/Small) stats, HT/FT outcome matrices, and
--              goal distribution based on season_detail_documentation.md.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Tournament / League Metadata View
-- Extracts tournament-level information and rules from 'LeagueInfo'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_league_info AS
SELECT 
    TRY_CAST(LeagueInfo[1] AS INTEGER) AS league_id,
    LeagueInfo[2] AS tournament_name,
    LeagueInfo[3] AS short_name,
    LeagueInfo[4] AS season_year,
    LeagueInfo[5] AS logo_path,
    LeagueInfo[6] AS primary_color,
    LeagueInfo[7] AS tournament_rules,
    TRY_CAST(LeagueInfo[8] AS INTEGER) AS status_flag,
    LastUpdateTime AS last_update_time
FROM read_json(
    'json/season_detail.json',
    columns = {
        'LeagueInfo': 'VARCHAR[]',
        'LastUpdateTime': 'TIMESTAMP'
    }
);


-- -----------------------------------------------------------------------------
-- 2. Tournament Stages View
-- Unnests competition stages / rounds from 'CupKindList'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_stages AS
WITH base AS (
    SELECT 
        TRY_CAST(LeagueInfo[1] AS INTEGER) AS league_id,
        UNNEST(CupKindList) AS s
    FROM read_json(
        'json/season_detail.json',
        columns = {
            'LeagueInfo': 'VARCHAR[]',
            'CupKindList': 'VARCHAR[][]'
        }
    )
)
SELECT 
    league_id,
    TRY_CAST(s[1] AS INTEGER) AS stage_id,
    TRY_CAST(s[2] AS INTEGER) AS stage_format_id,
    CASE TRY_CAST(s[2] AS INTEGER)
        WHEN 0 THEN 'Knockout / Two-legged'
        WHEN 1 THEN 'Group round-robin'
        ELSE 'Other'
    END AS stage_format,
    s[3] AS stage_name,
    s[4] AS group_count,
    TRY_CAST(s[5] AS INTEGER) AS stage_status_flag,
    TRY_CAST(s[6] AS INTEGER) = 1 AS is_current_stage
FROM base;


-- -----------------------------------------------------------------------------
-- 3. Participating Teams View
-- Unnests participating national/club teams from 'TeamList'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_teams AS
WITH base AS (
    SELECT 
        TRY_CAST(LeagueInfo[1] AS INTEGER) AS league_id,
        UNNEST(TeamList) AS t
    FROM read_json(
        'json/season_detail.json',
        columns = {
            'LeagueInfo': 'VARCHAR[]',
            'TeamList': 'VARCHAR[][]'
        }
    )
)
SELECT 
    league_id,
    TRY_CAST(t[1] AS BIGINT) AS team_id,
    t[2] AS team_name,
    NULLIF(t[3], '') AS short_code,
    t[4] AS logo_path
FROM base;


-- -----------------------------------------------------------------------------
-- 4. Knockout / Two-Legged Aggregate Ties View
-- Extracts aggregate pairings from knockout / qualifier stages in 'ScheduleList'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_knockout_ties AS
WITH base AS (
    SELECT ScheduleList 
    FROM read_json('json/season_detail.json', columns = {'ScheduleList': 'JSON'})
),
keys_extracted AS (
    SELECT UNNEST(json_keys(ScheduleList)) AS stage_key, ScheduleList
    FROM base
),
entries AS (
    SELECT 
        stage_key,
        UNNEST(TRY_CAST(json_extract(ScheduleList, '$.' || stage_key) AS JSON[])) AS entry_json
    FROM keys_extracted
)
SELECT 
    stage_key,
    TRY_CAST(TRY_CAST(entry_json AS JSON[])[1] AS BIGINT) AS team1_id,
    TRY_CAST(TRY_CAST(entry_json AS JSON[])[2] AS BIGINT) AS team2_id,
    TRY_CAST(TRY_CAST(entry_json AS JSON[])[3] AS INTEGER) AS aggregate_score_team1,
    TRY_CAST(TRY_CAST(entry_json AS JSON[])[4] AS INTEGER) AS aggregate_score_team2,
    json_array_length(TRY_CAST(entry_json AS JSON[])[5]) AS leg_count
FROM entries
WHERE json_array_length(entry_json) = 5;


-- -----------------------------------------------------------------------------
-- 5. Match Fixtures and Results View (Full 23 Fields)
-- Extracts all individual fixtures across group stages and knockout legs from 'ScheduleList'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_matches AS
WITH base AS (
    SELECT ScheduleList 
    FROM read_json('json/season_detail.json', columns = {'ScheduleList': 'JSON'})
),
keys_extracted AS (
    SELECT UNNEST(json_keys(ScheduleList)) AS stage_key, ScheduleList
    FROM base
),
entries AS (
    SELECT 
        stage_key,
        UNNEST(TRY_CAST(json_extract(ScheduleList, '$.' || stage_key) AS JSON[])) AS item_json
    FROM keys_extracted
),
all_matches AS (
    -- Direct group round-robin match fixtures (23 elements)
    SELECT 
        stage_key,
        NULL::BIGINT AS aggregate_team1_id,
        NULL::BIGINT AS aggregate_team2_id,
        NULL::INTEGER AS aggregate_score1,
        NULL::INTEGER AS aggregate_score2,
        TRY_CAST(item_json AS VARCHAR[]) AS m
    FROM entries
    WHERE json_array_length(item_json) = 23

    UNION ALL

    -- Two-legged knockout fixtures unnested from leg array (index 5)
    SELECT 
        stage_key,
        TRY_CAST(TRY_CAST(item_json AS JSON[])[1] AS BIGINT) AS aggregate_team1_id,
        TRY_CAST(TRY_CAST(item_json AS JSON[])[2] AS BIGINT) AS aggregate_team2_id,
        TRY_CAST(TRY_CAST(item_json AS JSON[])[3] AS INTEGER) AS aggregate_score1,
        TRY_CAST(TRY_CAST(item_json AS JSON[])[4] AS INTEGER) AS aggregate_score2,
        TRY_CAST(UNNEST(TRY_CAST(TRY_CAST(item_json AS JSON[])[5] AS JSON[][])) AS VARCHAR[]) AS m
    FROM entries
    WHERE json_array_length(item_json) = 5
)
SELECT 
    stage_key,
    TRY_CAST(m[1] AS BIGINT) AS match_id,
    TRY_CAST(m[2] AS INTEGER) AS league_id,
    TRY_CAST(m[3] AS INTEGER) AS match_status,
    CASE TRY_CAST(m[3] AS INTEGER)
        WHEN -1 THEN 'Finished'
        WHEN 0 THEN 'Not Started'
        ELSE 'In Progress / Other'
    END AS match_status_desc,
    TRY_CAST(m[4] AS TIMESTAMP) AS match_time,
    TRY_CAST(m[5] AS BIGINT) AS home_team_id,
    TRY_CAST(m[6] AS BIGINT) AS away_team_id,
    NULLIF(m[7], '') AS score_ft,
    NULLIF(m[8], '') AS score_ht,
    NULLIF(m[9], '') AS ah_line_ft,
    NULLIF(m[10], '') AS ah_line_ht,
    NULLIF(m[11], '') AS ou_line_ft,
    NULLIF(m[12], '') AS ou_line_ht,
    TRY_CAST(m[13] AS INTEGER) = 1 AS has_live_detail,
    TRY_CAST(m[14] AS INTEGER) = 1 AS has_lineup_analysis,
    TRY_CAST(m[15] AS INTEGER) = 1 AS has_odds_comparison,
    TRY_CAST(m[16] AS INTEGER) = 1 AS has_tech_stats,
    TRY_CAST(m[17] AS INTEGER) AS home_red_cards,
    TRY_CAST(m[18] AS INTEGER) AS away_red_cards,
    NULLIF(m[19], '') AS match_note,
    NULLIF(m[20], '') AS secondary_note,
    m[21] AS venue_context,
    TRY_CAST(NULLIF(m[22], '') AS INTEGER) AS home_fifa_rank,
    TRY_CAST(NULLIF(m[23], '') AS INTEGER) AS away_fifa_rank,
    aggregate_team1_id,
    aggregate_team2_id,
    aggregate_score1,
    aggregate_score2
FROM all_matches;


-- -----------------------------------------------------------------------------
-- 6. Group Standings View
-- Unnests ranking and points tables for each group from 'Standings'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_standings AS
WITH base AS (
    SELECT Standings 
    FROM read_json('json/season_detail.json', columns = {'Standings': 'JSON'})
),
keys_extracted AS (
    SELECT UNNEST(json_keys(Standings)) AS group_key, Standings
    FROM base
),
rows_extracted AS (
    SELECT 
        group_key,
        UNNEST(TRY_CAST(json_extract(Standings, '$.' || group_key) AS VARCHAR[][])) AS row_arr
    FROM keys_extracted
)
SELECT 
    group_key,
    TRY_CAST(row_arr[1] AS INTEGER) AS rank,
    TRY_CAST(row_arr[2] AS BIGINT) AS team_id,
    TRY_CAST(row_arr[3] AS INTEGER) AS matches_played,
    TRY_CAST(row_arr[4] AS INTEGER) AS wins,
    TRY_CAST(row_arr[5] AS INTEGER) AS draws,
    TRY_CAST(row_arr[6] AS INTEGER) AS losses,
    TRY_CAST(row_arr[7] AS INTEGER) AS goals_for,
    TRY_CAST(row_arr[8] AS INTEGER) AS goals_against,
    TRY_CAST(row_arr[9] AS INTEGER) AS goal_difference,
    TRY_CAST(row_arr[10] AS INTEGER) AS points,
    TRY_CAST(row_arr[11] AS INTEGER) AS home_matches,
    TRY_CAST(row_arr[12] AS INTEGER) AS away_matches,
    NULLIF(row_arr[13], '') AS qualification_remark
FROM rows_extracted;


-- -----------------------------------------------------------------------------
-- 7. Team Technical Statistics View
-- Extracts advanced and traditional metrics across Total, Home, and Guest scopes from 'TeamTech'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_team_tech AS
WITH base AS (
    SELECT TeamTech 
    FROM read_json(
        'json/season_detail.json', 
        columns = {
            'TeamTech': 'STRUCT(Total STRUCT("Value" DOUBLE[][]), Home STRUCT("Value" DOUBLE[][]), Guest STRUCT("Value" DOUBLE[][]))'
        }
    )
),
all_scopes AS (
    SELECT 'Total' AS venue_scope, UNNEST(TeamTech.Total.Value) AS t FROM base
    UNION ALL
    SELECT 'Home' AS venue_scope, UNNEST(TeamTech.Home.Value) AS t FROM base
    UNION ALL
    SELECT 'Guest' AS venue_scope, UNNEST(TeamTech.Guest.Value) AS t FROM base
)
SELECT 
    venue_scope,
    TRY_CAST(t[1] AS BIGINT) AS team_id,
    TRY_CAST(t[2] AS INTEGER) AS matches_evaluated,
    TRY_CAST(t[3] AS INTEGER) AS shots,
    TRY_CAST(t[4] AS INTEGER) AS shots_on_target,
    TRY_CAST(t[5] AS INTEGER) AS shots_off_target,
    TRY_CAST(t[6] AS INTEGER) AS passes,
    TRY_CAST(t[7] AS INTEGER) AS passes_successful,
    ROUND(TRY_CAST(t[7] AS DOUBLE) * 100.0 / NULLIF(TRY_CAST(t[6] AS DOUBLE), 0), 2) AS pass_success_pct,
    TRY_CAST(t[8] AS INTEGER) AS dribbles,
    TRY_CAST(t[9] AS INTEGER) AS yellow_cards,
    TRY_CAST(t[10] AS INTEGER) AS red_cards,
    TRY_CAST(t[11] AS INTEGER) AS shots_conceded,
    TRY_CAST(t[12] AS INTEGER) AS fouls_committed,
    TRY_CAST(t[13] AS INTEGER) AS corners,
    TRY_CAST(t[14] AS INTEGER) AS offsides,
    TRY_CAST(t[15] AS INTEGER) AS headers_attempted,
    TRY_CAST(t[16] AS INTEGER) AS headers_won,
    TRY_CAST(t[17] AS INTEGER) AS saves,
    TRY_CAST(t[18] AS INTEGER) AS blocked_shots,
    TRY_CAST(t[19] AS INTEGER) AS tackles,
    TRY_CAST(t[20] AS INTEGER) AS throw_ins,
    TRY_CAST(t[21] AS INTEGER) AS goals_scored,
    TRY_CAST(t[22] AS INTEGER) AS goals_conceded,
    TRY_CAST(t[23] AS DOUBLE) AS xg,
    TRY_CAST(t[24] AS DOUBLE) AS xg_open_play,
    TRY_CAST(t[25] AS DOUBLE) AS xg_set_play,
    TRY_CAST(t[26] AS DOUBLE) AS xg_non_penalty,
    TRY_CAST(t[27] AS DOUBLE) AS xgot,
    TRY_CAST(t[28] AS INTEGER) AS touches_opp_box,
    TRY_CAST(t[29] AS INTEGER) AS accurate_crosses,
    TRY_CAST(t[30] AS INTEGER) AS ground_duels_won,
    TRY_CAST(t[31] AS INTEGER) AS aerial_duels_won,
    TRY_CAST(t[32] AS INTEGER) AS clearances,
    TRY_CAST(t[33] AS DOUBLE) AS possession_pct
FROM all_scopes;


-- -----------------------------------------------------------------------------
-- 8. Asian Handicap / PanLu Statistics View
-- Extracts handicap win/push/loss counts and rates across FT/HT and venue splits from 'LetgoalPan'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_handicap_stats AS
WITH base AS (
    SELECT LetgoalPan 
    FROM read_json(
        'json/season_detail.json', 
        columns = {
            'LetgoalPan': 'STRUCT(TotalPanLu DOUBLE[][], HomePanLu DOUBLE[][], GuestPanLu DOUBLE[][], TotalHalfPanLu DOUBLE[][], HomeHalfPanLu DOUBLE[][], GuestHalfPanLu DOUBLE[][])'
        }
    )
),
all_pan AS (
    SELECT 'Total' AS venue_scope, 'Full-Time' AS half_scope, UNNEST(LetgoalPan.TotalPanLu) AS p FROM base
    UNION ALL
    SELECT 'Home' AS venue_scope, 'Full-Time' AS half_scope, UNNEST(LetgoalPan.HomePanLu) AS p FROM base
    UNION ALL
    SELECT 'Guest' AS venue_scope, 'Full-Time' AS half_scope, UNNEST(LetgoalPan.GuestPanLu) AS p FROM base
    UNION ALL
    SELECT 'Total' AS venue_scope, 'Half-Time' AS half_scope, UNNEST(LetgoalPan.TotalHalfPanLu) AS p FROM base
    UNION ALL
    SELECT 'Home' AS venue_scope, 'Half-Time' AS half_scope, UNNEST(LetgoalPan.HomeHalfPanLu) AS p FROM base
    UNION ALL
    SELECT 'Guest' AS venue_scope, 'Half-Time' AS half_scope, UNNEST(LetgoalPan.GuestHalfPanLu) AS p FROM base
)
SELECT 
    venue_scope,
    half_scope,
    ROW_NUMBER() OVER (
        PARTITION BY venue_scope, half_scope 
        ORDER BY TRY_CAST(p[11] AS DOUBLE) DESC, TRY_CAST(p[7] AS INTEGER) DESC, TRY_CAST(p[3] AS INTEGER) ASC
    ) AS rank,
    TRY_CAST(p[1] AS INTEGER) AS raw_rank,
    TRY_CAST(p[2] AS BIGINT) AS team_id,
    TRY_CAST(p[3] AS INTEGER) AS matches_played,
    TRY_CAST(p[4] AS INTEGER) AS outright_wins,
    TRY_CAST(p[5] AS INTEGER) AS outright_draws,
    TRY_CAST(p[6] AS INTEGER) AS outright_losses,
    TRY_CAST(p[7] AS INTEGER) AS ah_wins,
    TRY_CAST(p[8] AS INTEGER) AS ah_pushes,
    TRY_CAST(p[9] AS INTEGER) AS ah_losses,
    TRY_CAST(p[10] AS INTEGER) AS net_ah_wins,
    TRY_CAST(p[11] AS DOUBLE) AS ah_win_rate_pct,
    TRY_CAST(p[12] AS DOUBLE) AS ah_push_rate_pct,
    TRY_CAST(p[13] AS DOUBLE) AS ah_loss_rate_pct
FROM all_pan;


-- -----------------------------------------------------------------------------
-- 9. Over / Under (Big/Small) Statistics View
-- Extracts Over/Under benchmark rates across FT/HT and venue splits from 'BigSmallPan'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_over_under_stats AS
WITH base AS (
    SELECT BigSmallPan 
    FROM read_json(
        'json/season_detail.json', 
        columns = {
            'BigSmallPan': 'STRUCT(TotalBs DOUBLE[][], HomeBs DOUBLE[][], GuestBs DOUBLE[][], TotalBsHalf DOUBLE[][], HomeBsHalf DOUBLE[][], GuestBsHalf DOUBLE[][])'
        }
    )
),
all_bs AS (
    SELECT 'Total' AS venue_scope, 'Full-Time' AS half_scope, UNNEST(BigSmallPan.TotalBs) AS b FROM base
    UNION ALL
    SELECT 'Home' AS venue_scope, 'Full-Time' AS half_scope, UNNEST(BigSmallPan.HomeBs) AS b FROM base
    UNION ALL
    SELECT 'Guest' AS venue_scope, 'Full-Time' AS half_scope, UNNEST(BigSmallPan.GuestBs) AS b FROM base
    UNION ALL
    SELECT 'Total' AS venue_scope, 'Half-Time' AS half_scope, UNNEST(BigSmallPan.TotalBsHalf) AS b FROM base
    UNION ALL
    SELECT 'Home' AS venue_scope, 'Half-Time' AS half_scope, UNNEST(BigSmallPan.HomeBsHalf) AS b FROM base
    UNION ALL
    SELECT 'Guest' AS venue_scope, 'Half-Time' AS half_scope, UNNEST(BigSmallPan.GuestBsHalf) AS b FROM base
)
SELECT 
    venue_scope,
    half_scope,
    ROW_NUMBER() OVER (
        PARTITION BY venue_scope, half_scope 
        ORDER BY TRY_CAST(b[7] AS DOUBLE) DESC, TRY_CAST(b[4] AS INTEGER) DESC, TRY_CAST(b[3] AS INTEGER) ASC
    ) AS rank,
    TRY_CAST(b[1] AS INTEGER) AS raw_rank,
    TRY_CAST(b[2] AS BIGINT) AS team_id,
    TRY_CAST(b[3] AS INTEGER) AS matches_played,
    TRY_CAST(b[4] AS INTEGER) AS over_count,
    TRY_CAST(b[5] AS INTEGER) AS push_count,
    TRY_CAST(b[6] AS INTEGER) AS under_count,
    TRY_CAST(b[7] AS DOUBLE) AS over_rate_pct,
    TRY_CAST(b[8] AS DOUBLE) AS push_rate_pct,
    TRY_CAST(b[9] AS DOUBLE) AS under_rate_pct
FROM all_bs;


-- -----------------------------------------------------------------------------
-- 10. Half-Time / Full-Time Outcome Matrices View
-- Maps the 9 HT/FT outcome permutations across Total, Home, and Guest splits from 'AllHalf'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_half_full_matrix AS
WITH base AS (
    SELECT AllHalf 
    FROM read_json(
        'json/season_detail.json',
        columns = {
            'AllHalf': 'STRUCT(allData INTEGER[][], homeData INTEGER[][], guestData INTEGER[][])'
        }
    )
),
all_matrices AS (
    SELECT 'Total' AS venue_scope, UNNEST(AllHalf.allData) AS a FROM base
    UNION ALL
    SELECT 'Home' AS venue_scope, UNNEST(AllHalf.homeData) AS a FROM base
    UNION ALL
    SELECT 'Guest' AS venue_scope, UNNEST(AllHalf.guestData) AS a FROM base
)
SELECT 
    venue_scope,
    TRY_CAST(a[1] AS BIGINT) AS team_id,
    TRY_CAST(a[2] AS INTEGER) AS ht_w_ft_w,
    TRY_CAST(a[3] AS INTEGER) AS ht_w_ft_d,
    TRY_CAST(a[4] AS INTEGER) AS ht_w_ft_l,
    TRY_CAST(a[5] AS INTEGER) AS ht_d_ft_w,
    TRY_CAST(a[6] AS INTEGER) AS ht_d_ft_d,
    TRY_CAST(a[7] AS INTEGER) AS ht_d_ft_l,
    TRY_CAST(a[8] AS INTEGER) AS ht_l_ft_w,
    TRY_CAST(a[9] AS INTEGER) AS ht_l_ft_d,
    TRY_CAST(a[10] AS INTEGER) AS ht_l_ft_l
FROM all_matrices;


-- -----------------------------------------------------------------------------
-- 11. Goal Distribution and Odd/Even Counts View
-- Extracts exact total goal buckets [0..6+] and odd/even distribution from 'SinDouList'.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_season_goal_distribution AS
WITH base AS (
    SELECT UNNEST(SinDouList) AS s 
    FROM read_json(
        'json/season_detail.json', 
        columns = {'SinDouList': 'INTEGER[][]'}
    )
)
SELECT 
    TRY_CAST(s[1] AS BIGINT) AS team_id,
    TRY_CAST(s[2] AS INTEGER) AS goals_0,
    TRY_CAST(s[3] AS INTEGER) AS goals_1,
    TRY_CAST(s[4] AS INTEGER) AS goals_2,
    TRY_CAST(s[5] AS INTEGER) AS goals_3,
    TRY_CAST(s[6] AS INTEGER) AS goals_4,
    TRY_CAST(s[7] AS INTEGER) AS goals_5,
    TRY_CAST(s[8] AS INTEGER) AS goals_6_plus,
    TRY_CAST(s[9] AS INTEGER) AS odd_goals_count,
    TRY_CAST(s[10] AS INTEGER) AS even_goals_count
FROM base;


-- -----------------------------------------------------------------------------
-- Preview queries:
-- -----------------------------------------------------------------------------
SELECT * FROM v_season_league_info;
SELECT * FROM v_season_stages;
SELECT * FROM v_season_teams;
SELECT * FROM v_season_knockout_ties;
SELECT * FROM v_season_matches;
SELECT * FROM v_season_standings;
SELECT * FROM v_season_team_tech;
SELECT * FROM v_season_handicap_stats;
SELECT * FROM v_season_over_under_stats;
SELECT * FROM v_season_half_full_matrix;
SELECT * FROM v_season_goal_distribution;
