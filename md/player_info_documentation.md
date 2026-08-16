# Player Data Schema and Mapping Specification

This document details the array index definitions, schema fields, and lookup codes for player-level dataset files (`player.json`) based on frontend view bindings and database extraction models[cite: 3, 4, 5].

---

## 1. `PlayerInfo` (Player Basic Profile)

Flat array containing player identity, personal attributes, and current club metadata[cite: 4]:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description / Lookup Mapping | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `player_id` | `INTEGER` | Unique player identifier[cite: 3, 4] | `251089`[cite: 4] |
| `[1]` | `[2]` | `player_name` | `VARCHAR` | Full player display name[cite: 3, 4] | `"Nguyen Dinh Bac"`[cite: 4] |
| `[2]` | `[3]` | `player_photo` | `VARCHAR` | Relative path to player headshot[cite: 3, 4] | `"images/1hmb2gjzwv12.png"`[cite: 4] |
| `[3]` | `[4]` | `current_team_id` | `INTEGER` | Unique identifier for current club[cite: 3, 4] | `24468`[cite: 4] |
| `[4]` | `[5]` | `current_team_name` | `VARCHAR` | Current club display name[cite: 3, 4] | `"Cong An Ha Noi"`[cite: 4] |
| `[5]` | `[6]` | `current_team_logo` | `VARCHAR` | Relative path to current club crest[cite: 3, 4] | `"images/24468/1hgvtfy5jt15.png"`[cite: 4] |
| `[6]` | `[7]` | `nationality` | `VARCHAR` | Country of nationality[cite: 3, 4] | `"Vietnam"`[cite: 4] |
| `[7]` | `[8]` | `country_flag` | `VARCHAR` | Relative path to national flag icon[cite: 3, 4] | `"images/165018999384.png"`[cite: 4] |
| `[8]` | `[9]` | `jersey_number` | `INTEGER` | Squad jersey number[cite: 3, 4] | `"9"`[cite: 4] |
| `[9]` | `[10]` | `position_id` | `INTEGER` | Position classification code (e.g., `40` = Forward)[cite: 3, 4] | `"40"`[cite: 4] |
| `[10]` | `[11]` | `contract_expiry` | `DATE` | Contract expiration date (`YYYY-MM-DD`)[cite: 3, 4] | `"2029-06-30"`[cite: 4] |
| `[11]` | `[12]` | `birth_date` | `DATE` | Date of birth (`YYYY-MM-DD`)[cite: 3, 4] | `"2004-08-19"`[cite: 4] |
| `[12]` | `[13]` | `height_cm` | `INTEGER` | Height in centimeters[cite: 3, 4] | `"179"`[cite: 4] |
| `[13]` | `[14]` | `weight_kg` | `INTEGER` | Weight in kilograms (nullable / empty string)[cite: 3, 4] | `""`[cite: 4] |
| `[14]` | `[15]` | `preferred_foot` | `INTEGER` | `0` = Left, `1` = Right, `2` = Both[cite: 3, 4, 5] | `"1"`[cite: 4] |
| `[15]` | `[16]` | `current_league_id`| `INTEGER` | Primary league competition identifier[cite: 3, 4] | `766`[cite: 4] |

---

## 2. `TransferInfo` (Transfer & Loan History)

2D array capturing historical career moves, loan periods, and valuations[cite: 4]:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description / Lookup Mapping | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `season` | `VARCHAR` | Transfer season interval[cite: 3, 4] | `"2024-2025"`[cite: 4] |
| `[1]` | `[2]` | `from_team_id` | `INTEGER` | Selling / releasing club ID[cite: 3, 4] | `"19900"`[cite: 4] |
| `[2]` | `[3]` | `to_team_id` | `INTEGER` | Purchasing / receiving club ID[cite: 3, 4] | `"24468"`[cite: 4] |
| `[3]` | `[4]` | `transfer_date` | `DATE` | Effective date of transfer (`YYYY-MM-DD`)[cite: 3, 4] | `"2024-08-15"`[cite: 4] |
| `[4]` | `[5]` | `contract_end_date`| `DATE` | Contract or loan end date (`YYYY-MM-DD`)[cite: 3, 4] | `""`[cite: 4] |
| `[5]` | `[6]` | `fee_raw` | `DOUBLE` | Fee scaled by 100 (Fee / 100 = Million GBP/EUR)[cite: 3, 4] | `"13"`[cite: 4] |
| `[6]` | `[7]` | `transfer_type_id` | `INTEGER` | `1` = Full Ownership, `2` = Loan, `3` = Free, `4` = End of Loan, `5` = Co-ownership[cite: 3, 4, 5] | `"1"`[cite: 4] |
| `[7]` | `[8]` | `from_team_name` | `VARCHAR` | Selling / releasing club name[cite: 3, 4] | `"Quang Nam"`[cite: 4] |
| `[8]` | `[9]` | `to_team_name` | `VARCHAR` | Purchasing / receiving club name[cite: 3, 4] | `"Cong An Ha Noi"`[cite: 4] |
| `[9]` | `[10]` | `from_team_logo` | `VARCHAR` | Relative asset path to selling club crest[cite: 3, 4] | `"images/19900/1hdajsbqzw24.png"`[cite: 4] |
| `[10]` | `[11]` | `to_team_logo` | `VARCHAR` | Relative asset path to purchasing club crest[cite: 3, 4] | `"images/24468/1hgvtfy5jt15.png"`[cite: 4] |

---

## 3. `CountSum` (Aggregated Career & Season Statistics)

Matrix of statistical aggregates where Row 0 represents the player's overall career total and subsequent rows map to specific seasons/competitions[cite: 3, 4]:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Metric Category & HTML Reference | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `total_matches` | `INTEGER` | Matches Played (`#techImportant -> Plays`)[cite: 3, 4, 5] | `"39"`[cite: 4] |
| `[1]` | `[2]` | `starts` | `INTEGER` | Starting Lineup Appearances[cite: 3, 4] | `"17"`[cite: 4] |
| `[2]` | `[3]` | `substitutions` | `INTEGER` | Substitution Appearances[cite: 3, 4] | `"22"`[cite: 4] |
| `[3]` | `[4]` | `wins` | `INTEGER` | Team Wins in Played Matches[cite: 3, 4] | `"4"`[cite: 4] |
| `[4]` | `[5]` | `draws` | `INTEGER` | Team Draws in Played Matches[cite: 3, 4] | `"0"`[cite: 4] |
| `[5]` | `[6]` | `losses` | `INTEGER` | Team Losses in Played Matches[cite: 3, 4] | `"0"`[cite: 4] |
| `[6]` | `[7]` | `clean_sheets` | `INTEGER` | Team Clean Sheets (when player featured)[cite: 3, 4] | `"0"`[cite: 4] |
| `[7]` | `[8]` | `motm_count` | `INTEGER` | Man of the Match / Best Player Awards[cite: 3, 4, 5] | `"5"`[cite: 4] |
| `[8]` | `[9]` | `shots` | `INTEGER` | Total Shots Attempted (`#techOffensive -> Shots`)[cite: 3, 4, 5] | `"19"`[cite: 4] |
| `[9]` | `[10]` | `shots_on_target` | `INTEGER` | Shots on Target (`#techOffensive -> Shots (SOG)`)[cite: 3, 4, 5] | `"11"`[cite: 4] |
| `[10]` | `[11]` | `assists` | `INTEGER` | Goal Assists (`#techPassing -> Assists`)[cite: 3, 4, 5] | `"1"`[cite: 4] |
| `[11]` | `[12]` | `passes` | `INTEGER` | Total Passes Attempted (`#techPassing -> Passes`)[cite: 3, 4, 5] | `"163"`[cite: 4] |
| `[12]` | `[13]` | `passes_success` | `INTEGER` | Accurate Passes Completed (`#techPassing -> Passes Success`)[cite: 3, 4, 5] | `"131"`[cite: 4] |
| `[13]` | `[14]` | `key_passes` | `INTEGER` | Key Passes / Shot Assists (`#techPassing -> Key Passes`)[cite: 3, 4, 5] | `"5"`[cite: 4] |
| `[14]` | `[15]` | `long_passes` | `INTEGER` | Accurate Long Balls (`#techPassing -> Long Passes`)[cite: 3, 4, 5] | `"7"`[cite: 4] |
| `[15]` | `[16]` | `through_balls` | `INTEGER` | Through Balls (`#techPassing -> Through`)[cite: 3, 4, 5] | `"0"`[cite: 4] |
| `[16]` | `[17]` | `dribbles` | `INTEGER` | Successful Dribbles (`#techPassing -> Break Loose`)[cite: 3, 4, 5] | `"6"`[cite: 4] |
| `[17]` | `[18]` | `fouled` | `INTEGER` | Fouls Drawn (`#techOffensive -> Fouled`)[cite: 3, 4, 5] | `"10"`[cite: 4] |
| `[18]` | `[19]` | `fouls` | `INTEGER` | Fouls Committed (`#techDefensive -> Fouls`)[cite: 3, 4, 5] | `"7"`[cite: 4] |
| `[19]` | `[20]` | `interceptions` | `INTEGER` | Interceptions Made (`#techDefensive -> Interceptions`)[cite: 3, 4, 5] | `"0"`[cite: 4] |
| `[20]` | `[21]` | `clearances` | `INTEGER` | Defensive Clearances (`#techDefensive -> Clearances`)[cite: 3, 4, 5] | `"0"`[cite: 4] |
| `[21]` | `[22]` | `steals` | `INTEGER` | Possession Steals / Recoveries (`#techDefensive -> Steal`)[cite: 3, 4, 5] | `"1"`[cite: 4] |
| `[22]` | `[23]` | `tackles` | `INTEGER` | Tackles Won (`#techDefensive -> Tackles`)[cite: 3, 4, 5] | `"11"`[cite: 4] |
| `[23]` | `[24]` | `blocked_shots` | `INTEGER` | Blocked Shots (`#techDefensive -> Blocked`)[cite: 3, 4, 5] | `"2"`[cite: 4] |
| `[24]` | `[25]` | `aerials_won` | `INTEGER` | Aerial Duels Won / Headers (`#techDefensive -> Header`)[cite: 3, 4, 5] | `"0"`[cite: 4] |
| `[25]` | `[26]` | `offsides` | `INTEGER` | Offside Violations (`#techOffensive -> Offsides`)[cite: 3, 4, 5] | `"2"`[cite: 4] |
| `[26]` | `[27]` | `red_cards` | `INTEGER` | Red Cards Received[cite: 3, 4] | `"0"`[cite: 4] |
| `[27]` | `[28]` | `yellow_cards` | `INTEGER` | Yellow Cards Received[cite: 3, 4] | `"0"`[cite: 4] |
| `[28]` | `[29]` | `shots_per_match` | `DOUBLE` | Average Shots per Game[cite: 3, 4] | `"1.79"`[cite: 4] |
| `[29]` | `[30]` | `sog_per_match` | `DOUBLE` | Average Shots on Target per Game[cite: 3, 4] | `"1.65"`[cite: 4] |
| `[30]` | `[31]` | `goals` | `INTEGER` | Total Goals Scored (`#techImportant -> Goals(P)`)[cite: 3, 4, 5] | `"2"`[cite: 4] |
| `[31]` | `[32]` | `avg_rating` | `DOUBLE` | Average Match Performance Rating[cite: 3, 4, 5] | `"7.33"`[cite: 4] |

---

## 4. `playerCount` (Match-by-Match Performance Log)

2D array recording single-match appearances, performance ratings, and match highlights[cite: 4]:

| Index (0-based) | Field Name | Data Type | Description | Source Example |
| :--- | :--- | :--- | :--- | :--- |
| `[0]` | `match_id` | `INTEGER` | Unique fixture identifier[cite: 4] | `2991085`[cite: 4] |
| `[1]` | `home_team_id` | `INTEGER` | Home club / national team ID[cite: 4] | `883`[cite: 4] |
| `[2]` | `away_team_id` | `INTEGER` | Away club / national team ID[cite: 4] | `1565`[cite: 4] |
| `[3]` | `match_time` | `VARCHAR` | Kickoff date and time (`YYYY-MM-DD HH:MM`)[cite: 4] | `"2026-08-07 21:00"`[cite: 4] |
| `[4]` | `league_name` | `VARCHAR` | Competition / League title[cite: 4] | `"ASEAN Championship"`[cite: 4] |
| `[5]` | `league_color` | `VARCHAR` | Hexadecimal color code of competition[cite: 4] | `"#333388"`[cite: 4] |
| `[6]` | `home_team_name` | `VARCHAR` | Home team display name[cite: 4] | `"Vietnam"`[cite: 4] |
| `[7]` | `away_team_name` | `VARCHAR` | Away team display name[cite: 4] | `"Cambodia"`[cite: 4] |
| `[8]` | `home_score` | `VARCHAR` | Final score of home team[cite: 4] | `"3"`[cite: 4] |
| `[9]` | `away_score` | `VARCHAR` | Final score of away team[cite: 4] | `"1"`[cite: 4] |
| `[10]` | `lineup_status` | `INTEGER` | `1` = Starter, `0` = Substitute[cite: 4] | `1`[cite: 4] |
| `[11]` | `goals` | `VARCHAR` | Goals scored by the player in match[cite: 4] | `"2"`[cite: 4] |
| `[12]` | `penalty_goals` | `VARCHAR` | Penalty goals scored[cite: 4] | `"0"`[cite: 4] |
| `[13]` | `own_goals` | `VARCHAR` | Own goals scored[cite: 4] | `"0"`[cite: 4] |
| `[14]` | `yellow_cards` | `VARCHAR` | Yellow cards received in match[cite: 4] | `"0"`[cite: 4] |
| `[15]` | `red_cards` | `VARCHAR` | Red cards received in match[cite: 4] | `"0"`[cite: 4] |
| `[16]` | `is_motm` | `INTEGER` | `1` = Awarded Man of the Match, `0` = No[cite: 4] | `1`[cite: 4] |
| `[17]` | `rating` | `VARCHAR` | Individual match rating score (out of 10)[cite: 4] | `"9.4"`[cite: 4] |
| `[18]` | `shots` | `VARCHAR` | Total shots attempted in match[cite: 4] | `"4"`[cite: 4] |
| `[19]` | `shots_on_target` | `VARCHAR` | Shots on target in match[cite: 4] | `"4"`[cite: 4] |
| `[20]` | `blocked_shots` | `VARCHAR` | Shots blocked by opposition[cite: 4] | `"0"`[cite: 4] |
| `[21]` | `passes` | `VARCHAR` | Total passes attempted[cite: 4] | `"39"`[cite: 4] |
| `[22]` | `passes_success` | `VARCHAR` | Accurate passes completed[cite: 4] | `"33"`[cite: 4] |
| `[23]` | `key_passes` | `VARCHAR` | Key passes delivered[cite: 4] | `"3"`[cite: 4] |
| `[24]` | `long_passes` | `VARCHAR` | Accurate long balls completed[cite: 4] | `"1"`[cite: 4] |
| `[25]` | `through_balls` | `VARCHAR` | Through balls completed[cite: 4] | `"0"`[cite: 4] |
| `[26]` | `dribbles` | `VARCHAR` | Successful dribbles executed[cite: 4] | `"2"`[cite: 4] |
| `[27]` | `fouled` | `VARCHAR` | Fouls drawn from opponents[cite: 4] | `"2"`[cite: 4] |
| `[28]` | `fouls` | `VARCHAR` | Fouls committed[cite: 4] | `"1"`[cite: 4] |
| `[29]` | `interceptions` | `VARCHAR` | Interceptions made[cite: 4] | `"0"`[cite: 4] |
| `[30]` | `clearances` | `VARCHAR` | Clearances made[cite: 4] | `"0"`[cite: 4] |
| `[31]` | `steals` | `VARCHAR` | Tackles won / recoveries[cite: 4] | `"0"`[cite: 4] |
| `[32]` | `tackles` | `VARCHAR` | Tackles attempted[cite: 4] | `"3"`[cite: 4] |
| `[33]` | `shot_blocks` | `VARCHAR` | Opposition shots blocked[cite: 4] | `"0"`[cite: 4] |
| `[34]` | `aerials_won` | `VARCHAR` | Aerial duels won[cite: 4] | `"0"`[cite: 4] |
| `[35]` | `offsides` | `VARCHAR` | Offside infractions[cite: 4] | `"0"`[cite: 4] |
| `[36]` | `stat_custom_1` | `VARCHAR` | Reserved match event metric[cite: 4] | `"0"`[cite: 4] |
| `[37]` | `stat_custom_2` | `VARCHAR` | Reserved match event metric[cite: 4] | `"0"`[cite: 4] |
| `[38]` | `minutes_played` | `VARCHAR` | Total minutes on pitch[cite: 4] | `"90"`[cite: 4] |
| `[39]` | `season` | `VARCHAR` | Season identifier[cite: 4] | `"2026"`[cite: 4] |
| `[40]` | `league_id` | `VARCHAR` | League / competition ID[cite: 4] | `"1124"`[cite: 4] |
| `[41]` | `stage_id` | `VARCHAR` | Stage ID / Country group code[cite: 4] | `"56"`[cite: 4] |
| `[42]` | `video_url` | `VARCHAR` | Embedded YouTube highlight / replay URL[cite: 4] | `"https://www.youtube.com/embed/..."`[cite: 4] |
| `[43]` | `video_status` | `VARCHAR` | Video availability flag (`"0"` = Available)[cite: 4] | `"0"`[cite: 4] |

---

## 5. Enum & Value Reference Tables

### 5.1 Preferred Foot Code (`PlayerInfo[14]`)
* `0`: Left[cite: 3, 5]
* `1`: Right[cite: 3, 5]
* `2`: Both[cite: 3, 5]

### 5.2 Transfer Type Code (`TransferInfo[6]`)
* `1`: Full Ownership (`T_Zh_OwnedWholly`)[cite: 3, 5]
* `2`: Loan (`T_Zh_Loan`)[cite: 3, 5]
* `3`: Free Transfer (`T_Zh_FreeTransfer`)[cite: 3, 5]
* `4`: End of Loan (`T_Zh_EndLoan`)[cite: 3, 5]
* `5`: Co-ownership (`T_Zh_Common`)[cite: 3, 5]

### 5.3 Radar Attributes (`RadarInfo` Lookup Keys)
* `PAC`: Pace / Speed[cite: 5]
* `SHO`: Shooting[cite: 5]
* `PAS`: Passing[cite: 5]
* `DRI`: Dribbling[cite: 5]
* `DEF`: Defending[cite: 5]
* `PHY`: Physicality[cite: 5]
* `DIV`: Diving (Goalkeeper)[cite: 5]
* `HAN`: Handling (Goalkeeper)[cite: 5]
* `KIC`: Kicking (Goalkeeper)[cite: 5]
* `REF`: Reflexes (Goalkeeper)[cite: 5]
* `SPD`: Speed (Goalkeeper)[cite: 5]
* `POS`: Positioning (Goalkeeper)[cite: 5]