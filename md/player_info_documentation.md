# Player Data Schema and Mapping Specification

This document details the array index definitions, schema fields, UI bindings, and database extraction models for the Nowgoal player dataset (`player_info.json` / `player{player_id}_en.json`).

---

## Top-Level JSON Object Structure

| Key | Data Type | Description |
| :--- | :--- | :--- |
| `PlayerInfo` | `Array[16]` | Basic player demographic, club, contract, and market valuation metadata |
| `RadarInfo` | `Array[7]` | Technical attribute ratings for radar chart visualization (Outfield vs Goalkeeper) |
| `TransferInfo` | `Array[Array[11]]` | Historical transfer, loan, and contract transaction records |
| `CountSum` | `Array[Array[32]]` | Pre-aggregated career and per-season technical performance statistics |
| `playerCount` | `Array[Array[44]]` | Match-by-match individual performance logs, ratings, and detailed event metrics |
| `LastUpdateTime` | `String` | Timestamp of the last data synchronization (`YYYY-MM-DD HH:MM:SS`) |

---

## 1. `PlayerInfo` (Player Basic Profile)

Flat 16-element array containing player identity, personal attributes, and current club metadata:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description / Lookup Mapping | Source Example (Lamine Yamal) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `player_id` | `INTEGER` | Unique player identifier | `236346` |
| `[1]` | `[2]` | `player_name` | `VARCHAR` | Full player display name | `"Lamine Yamal"` |
| `[2]` | `[3]` | `player_photo` | `VARCHAR` | Relative path to player headshot | `"images/236346/1jcam0gyb31t.png"` |
| `[3]` | `[4]` | `current_team_id` | `INTEGER` | Unique identifier for current club | `84` |
| `[4]` | `[5]` | `current_team_name` | `VARCHAR` | Current club display name | `"FC Barcelona"` |
| `[5]` | `[6]` | `current_team_logo` | `VARCHAR` | Relative path to current club crest | `"images/164871253294.png"` |
| `[6]` | `[7]` | `nationality` | `VARCHAR` | Country of nationality | `"Spain"` |
| `[7]` | `[8]` | `country_flag` | `VARCHAR` | Relative path to national flag icon | `"images/1kd9trgscek.png"` |
| `[8]` | `[9]` | `jersey_number` | `INTEGER` | Squad shirt number | `"10"` |
| `[9]` | `[10]` | `market_value_raw` | `INTEGER` | Estimated market value scaled by 100 (`Value / 100` = Million EUR/GBP) | `"22000"` (€220.00M) |
| `[10]` | `[11]` | `contract_expiry` | `DATE` | Contract expiration date (`YYYY-MM-DD`) | `"2031-06-30"` |
| `[11]` | `[12]` | `birth_date` | `DATE` | Date of birth (`YYYY-MM-DD`) | `"2007-07-13"` |
| `[12]` | `[13]` | `height_cm` | `INTEGER` | Height in centimeters | `"183"` |
| `[13]` | `[14]` | `weight_kg` | `INTEGER` | Weight in kilograms | `"72"` |
| `[14]` | `[15]` | `preferred_foot` | `INTEGER` | `0` = Left, `1` = Right, `2` = Both | `"0"` |
| `[15]` | `[16]` | `current_league_id`| `INTEGER` | Primary domestic league competition ID | `31` (La Liga) |

---

## 2. `RadarInfo` (Attribute Ratings & Radar Chart)

7-element array defining the player's role classification and the 6 hexagonal radar attributes:

### 2.1 Role Type Classification (`RadarInfo[0]`)
* `1`: Outfield Player
* `2`: Goalkeeper

### 2.2 Outfield Player Attributes (`RadarInfo[0] == 1`)

| Index (0-based) | DuckDB Index (1-based) | Attribute Code | Full Name | UI Axis Position | Sample Value (Yamal) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[1]` | `[2]` | `PAC` | Pace / Speed | Top | `86` |
| `[2]` | `[3]` | `SHO` | Shooting | Top-Left | `84` |
| `[3]` | `[4]` | `PHY` | Physicality | Bottom-Left | `61` |
| `[4]` | `[5]` | `PAS` | Passing | Bottom | `87` |
| `[5]` | `[6]` | `DEF` | Defending | Bottom-Right | `25` |
| `[6]` | `[7]` | `DRI` | Dribbling | Top-Right | `91` |

### 2.3 Goalkeeper Attributes (`RadarInfo[0] == 2`)

| Index (0-based) | DuckDB Index (1-based) | Attribute Code | Full Name | UI Axis Position | Sample Value (Joan Garcia) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[1]` | `[2]` | `DIV` | Diving | Top | `85` |
| `[2]` | `[3]` | `HAN` | Handling | Top-Left | `85` |
| `[3]` | `[4]` | `POS` | Positioning | Bottom-Left | `84` |
| `[4]` | `[5]` | `KIC` | Kicking | Bottom | `80` |
| `[5]` | `[6]` | `SPD` | Speed | Bottom-Right | `46` |
| `[6]` | `[7]` | `REF` | Reflexes | Top-Right | `88` |

---

## 3. `TransferInfo` (Transfer & Loan History)

2D array capturing career transfers, loan durations, and valuations:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description / Lookup Mapping | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `season` | `VARCHAR` | Transfer season interval | `"2023-2024"` |
| `[1]` | `[2]` | `from_team_id` | `INTEGER` | Selling / releasing club ID | `6139` |
| `[2]` | `[3]` | `to_team_id` | `INTEGER` | Purchasing / receiving club ID | `84` |
| `[3]` | `[4]` | `transfer_date` | `DATE` | Effective date of transfer (`YYYY-MM-DD`) | `"2023-07-01"` |
| `[4]` | `[5]` | `contract_end_date`| `DATE` | Contract or loan expiration date (`YYYY-MM-DD`) | `""` |
| `[5]` | `[6]` | `fee_raw` | `DOUBLE` | Fee scaled by 100 (`Fee / 100` = Million EUR/GBP) | `""` |
| `[6]` | `[7]` | `transfer_type_id` | `INTEGER` | `1` = Full Ownership, `2` = Loan, `3` = Free, `4` = End of Loan, `5` = Co-ownership | `1` |
| `[7]` | `[8]` | `from_team_name` | `VARCHAR` | Selling / releasing club name | `"Barcelona U19"` |
| `[8]` | `[9]` | `to_team_name` | `VARCHAR` | Purchasing / receiving club name | `"FC Barcelona"` |
| `[9]` | `[10]` | `from_team_logo` | `VARCHAR` | Relative asset path to selling club crest | `"images/6139/1hkgsyfdyj1v.png"` |
| `[10]` | `[11]` | `to_team_logo` | `VARCHAR` | Relative asset path to purchasing club crest | `"images/164871253294.png"` |

---

## 4. `CountSum` (Aggregated Career & Season Statistics)

32-element array of statistical totals. Row 0 represents overall career aggregates; subsequent rows represent season/competition breakdowns:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | UI Category & HTML Binding | Source Example (Yamal Career) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `starts` | `INTEGER` | Total Starting Lineup Matches | `"152"` |
| `[1]` | `[2]` | `league_starts` | `INTEGER` | Domestic League Starting Lineup Matches | `"55"` |
| `[2]` | `[3]` | `substitutions` | `INTEGER` | Total Substitution Matches (`Starts + Subs = Total Matches`) | `"33"` |
| `[3]` | `[4]` | `competition_goals`| `INTEGER` | Secondary Goal / Cup Metric | `"3"` |
| `[4]` | `[5]` | `penalty_goals` | `INTEGER` | Penalty Goals Scored | `"7"` |
| `[5]` | `[6]` | `reserved_1` | `INTEGER` | Reserved / padding metric | `"0"` |
| `[6]` | `[7]` | `cards_secondary` | `INTEGER` | Secondary tournament caution metric | `"17"` |
| `[7]` | `[8]` | `goals` | `INTEGER` | Summary Card (`#techImportant -> Goals(P)`) | `"49"` |
| `[8]` | `[9]` | `shots` | `INTEGER` | Offensive Panel (`#techOffensive [data-type="1"]`) | `"539"` |
| `[9]` | `[10]` | `shots_on_target` | `INTEGER` | Offensive Panel (`#techOffensive [data-type="2"]`) | `"192"` |
| `[10]` | `[11]` | `assists` | `INTEGER` | Summary & Passing (`#techImportant -> Assists`, `#techPassing [data-type="3"]`) | `"49"` |
| `[11]` | `[12]` | `passes` | `INTEGER` | Passing Panel (`#techPassing [data-type="0"]`) | `"6319"` |
| `[12]` | `[13]` | `passes_success` | `INTEGER` | Passing Panel (`#techPassing [data-type="1"]`) | `"5133"` |
| `[13]` | `[14]` | `key_passes` | `INTEGER` | Passing Panel (`#techPassing [data-type="2"]`) | `"298"` |
| `[14]` | `[15]` | `long_passes` | `INTEGER` | Passing Panel (`#techPassing [data-type="4"]`) | `"135"` |
| `[15]` | `[16]` | `through_balls` | `INTEGER` | Passing Panel (`#techPassing [data-type="5"]`) | `"46"` |
| `[16]` | `[17]` | `dribbles` | `INTEGER` | Passing Panel (`#techPassing [data-type="6"]` Break Loose) | `"622"` |
| `[17]` | `[18]` | `fouled` | `INTEGER` | Offensive Panel (`#techOffensive [data-type="4"]`) | `"283"` |
| `[18]` | `[19]` | `fouls` | `INTEGER` | Defensive Panel (`#techDefensive [data-type="6"]`) | `"142"` |
| `[19]` | `[20]` | `interceptions` | `INTEGER` | Defensive Panel (`#techDefensive [data-type="1"]`) | `"76"` |
| `[20]` | `[21]` | `clearances` | `INTEGER` | Defensive Panel (`#techDefensive [data-type="2"]`) | `"0"` |
| `[21]` | `[22]` | `steals` | `INTEGER` | Defensive Panel (`#techDefensive [data-type="3"]` Steal) | `"205"` |
| `[22]` | `[23]` | `tackles` | `INTEGER` | Defensive Panel (`#techDefensive [data-type="0"]` Tackles) | `"343"` |
| `[23]` | `[24]` | `blocked_shots` | `INTEGER` | Defensive Panel (`#techDefensive [data-type="4"]` Blocked) | `"228"` |
| `[24]` | `[25]` | `headers_won` | `INTEGER` | Defensive Panel (`#techDefensive [data-type="5"]` Header) | `"0"` |
| `[25]` | `[26]` | `offsides` | `INTEGER` | Offensive Panel (`#techOffensive [data-type="5"]`) | `"7"` |
| `[26]` | `[27]` | `yellow_cards` | `INTEGER` | Summary Card (`#techImportant -> Cards`) | `"24"` |
| `[27]` | `[28]` | `red_cards` | `INTEGER` | Summary Card (`#techImportant -> Cards`) | `"0"` |
| `[28]` | `[29]` | `mins_per_goal_rate`| `DOUBLE` | Offensive Panel (`#techOffensive [data-type="0"]` Mins/Goals) | `"2.32"` |
| `[29]` | `[30]` | `sog_rate` | `DOUBLE` | Offensive Panel (`#techOffensive [data-type="3"]` Conversion / SOG Rate) | `"2.13"` |
| `[30]` | `[31]` | `motm_count` | `INTEGER` | Offensive Panel (`#techOffensive [data-type="6"]` Best) | `"36"` |
| `[31]` | `[32]` | `avg_rating` | `DOUBLE` | Summary Card (`#techImportant -> Avg Rating`) | `"7.7"` |

---

## 5. `playerCount` (Match-by-Match Performance Log)

44-element 2D array recording single-match appearances, ratings, highlights, and in-game statistics:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `match_id` | `INTEGER` | Unique fixture identifier | `2907406` |
| `[1]` | `[2]` | `home_team_id` | `INTEGER` | Home club / national team ID | `772` |
| `[2]` | `[3]` | `away_team_id` | `INTEGER` | Away club / national team ID | `766` |
| `[3]` | `[4]` | `match_time` | `VARCHAR` | Kickoff timestamp (`YYYY-MM-DD HH:MM`) | `"2026-07-20 03:00"` |
| `[4]` | `[5]` | `league_name` | `VARCHAR` | Competition title | `"FIFA World Cup"` |
| `[5]` | `[6]` | `league_color` | `VARCHAR` | Hexadecimal league color code | `"#660000"` |
| `[6]` | `[7]` | `home_team_name` | `VARCHAR` | Home team display name | `"Spain"` |
| `[7]` | `[8]` | `away_team_name` | `VARCHAR` | Away team display name | `"Argentina"` |
| `[8]` | `[9]` | `home_score` | `VARCHAR` | Home team score | `"0"` |
| `[9]` | `[10]` | `away_score` | `VARCHAR` | Away team score | `"0"` |
| `[10]` | `[11]` | `lineup_status` | `INTEGER` | `1` = Starter, `0` = Substitute | `1` |
| `[11]` | `[12]` | `goals` | `VARCHAR` | Goals scored in match | `"0"` |
| `[12]` | `[13]` | `penalty_goals` | `VARCHAR` | Penalty goals scored in match | `"0"` |
| `[13]` | `[14]` | `own_goals` | `VARCHAR` | Own goals conceded in match | `"0"` |
| `[14]` | `[15]` | `yellow_cards` | `VARCHAR` | Yellow cards received in match | `"0"` |
| `[15]` | `[16]` | `assists` | `VARCHAR` | Goal assists provided in match | `"0"` |
| `[16]` | `[17]` | `is_motm` | `INTEGER` | `1` = Awarded Man of the Match, `0` = No | `0` |
| `[17]` | `[18]` | `rating` | `VARCHAR` | Match performance rating (e.g. `"7.3"`) | `"7.3"` |
| `[18]` | `[19]` | `shots` | `VARCHAR` | Total shots attempted | `"4"` |
| `[19]` | `[20]` | `shots_on_target` | `VARCHAR` | Shots on target (SOG) | `"2"` |
| `[20]` | `[21]` | `blocked_shots_off`| `VARCHAR` | Shots blocked by opposition | `"0"` |
| `[21]` | `[22]` | `passes` | `VARCHAR` | Total passes attempted | `"51"` |
| `[22]` | `[23]` | `passes_success` | `VARCHAR` | Accurate passes completed | `"44"` |
| `[23]` | `[24]` | `key_passes` | `VARCHAR` | Key passes / chances created | `"1"` |
| `[24]` | `[25]` | `long_passes` | `VARCHAR` | Accurate long balls completed | `"1"` |
| `[25]` | `[26]` | `through_balls` | `VARCHAR` | Accurate through balls completed | `"0"` |
| `[26]` | `[27]` | `dribbles` | `VARCHAR` | Successful dribbles / Break Loose | `"5"` |
| `[27]` | `[28]` | `fouled` | `VARCHAR` | Fouls drawn from opponents | `"1"` |
| `[28]` | `[29]` | `fouls` | `VARCHAR` | Fouls committed | `"2"` |
| `[29]` | `[30]` | `interceptions` | `VARCHAR` | Interceptions made | `"1"` |
| `[30]` | `[31]` | `clearances` | `VARCHAR` | Defensive clearances | `"0"` |
| `[31]` | `[32]` | `steals` | `VARCHAR` | Possession steals / recoveries | `"2"` |
| `[32]` | `[33]` | `tackles` | `VARCHAR` | Tackles attempted | `"0"` |
| `[33]` | `[34]` | `blocked_shots_def`| `VARCHAR` | Opposition shots blocked | `"3"` |
| `[34]` | `[35]` | `aerials_won` | `VARCHAR` | Aerial duels won | `"0"` |
| `[35]` | `[36]` | `offsides` | `VARCHAR` | Offside infractions | `"0"` |
| `[36]` | `[37]` | `cards_cautions` | `VARCHAR` | Match cautions / cumulative discipline | `"0"` |
| `[37]` | `[38]` | `red_cards` | `VARCHAR` | Red cards received in match | `"0"` |
| `[38]` | `[39]` | `minutes_played` | `VARCHAR` | Total minutes on pitch | `"120"` |
| `[39]` | `[40]` | `season` | `VARCHAR` | Season identifier | `"2026"` |
| `[40]` | `[41]` | `league_id` | `VARCHAR` | Competition / League ID | `"75"` |
| `[41]` | `[42]` | `stage_id` | `VARCHAR` | Stage ID / Country group code | `"52"` |
| `[42]` | `[43]` | `video_url` | `VARCHAR` | Embedded highlight / replay URL | `""` |
| `[43]` | `[44]` | `video_status` | `VARCHAR` | Video availability flag (`"0"` = Available) | `"0"` |

---

## 6. Enum & Lookup Reference Tables

### 6.1 Preferred Foot Code (`PlayerInfo[14]`)
* `0`: Left (`T_LeftFoot`)
* `1`: Right (`T_RightFoot`)
* `2`: Both (`T_BothFoot` - Ambidextrous)

### 6.2 Transfer Type Code (`TransferInfo[][6]`)
* `1`: Full Ownership (`T_Zh_OwnedWholly`)
* `2`: Loan (`T_Zh_Loan`)
* `3`: Free Transfer (`T_Zh_FreeTransfer`)
* `4`: End of Loan (`T_Zh_EndLoan`)
* `5`: Co-ownership (`T_Zh_Common`)

### 6.3 Radar Role Type Code (`RadarInfo[0]`)
* `1`: Outfield Player (`PAC`, `SHO`, `PHY`, `PAS`, `DEF`, `DRI`)
* `2`: Goalkeeper (`DIV`, `HAN`, `POS`, `KIC`, `SPD`, `REF`)