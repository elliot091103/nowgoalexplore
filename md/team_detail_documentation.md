# Team Data Schema and Mapping Specification

This document details the array index definitions, schema fields, and lookup codes for club/team dataset files (`tdl{teamId}_en.json`) based on frontend view templates and data objects[cite: 6, 7].

---

## 1. `TeamInfo` (Club Profile & Metadata)

Flat array defining club identity, home venue, financial valuation, and league affiliation[cite: 6, 7]:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description / HTML Element Reference | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `team_id` | `INTEGER` | Unique team identifier (`_teamId`)[cite: 6, 7] | `84`[cite: 6] |
| `[1]` | `[2]` | `team_name` | `VARCHAR` | Full official club name (`<div id="title">`)[cite: 6, 7] | `"FC Barcelona"`[cite: 6] |
| `[2]` | `[3]` | `team_logo` | `VARCHAR` | Relative path to club crest (`#imgBox`)[cite: 6, 7] | `"images/164871253294.png"`[cite: 6] |
| `[3]` | `[4]` | `city` | `VARCHAR` | Home city location (`#teamInfoBox -> City`)[cite: 6, 7] | `"Barcelona"`[cite: 6] |
| `[4]` | `[5]` | `home_stadium` | `VARCHAR` | Stadium name (`#teamInfoBox -> Home Stadium`)[cite: 6, 7] | `"Spotify Camp Nou"`[cite: 6] |
| `[5]` | `[6]` | `capacity` | `INTEGER` | Stadium capacity (`#teamInfoBox -> Capacity`)[cite: 6, 7] | `"99354"`[cite: 6] |
| `[6]` | `[7]` | `established_date`| `DATE` | Founding date in `YYYY-MM-DD` (`#teamInfoBox -> Established Date`)[cite: 6, 7] | `"1899-11-29"`[cite: 6] |
| `[7]` | `[8]` | `estimated_value` | `DOUBLE` | Estimated market value in Million EUR (`#teamInfoBox -> Estimated Value`)[cite: 6, 7] | `"1194.8"`[cite: 6] |
| `[8]` | `[9]` | `avg_age` | `DOUBLE` | Squad average age (`#teamInfoBox -> Avg Age`)[cite: 6, 7] | `"24.3"`[cite: 6] |
| `[9]` | `[10]` | `primary_league_id`| `INTEGER` | Identifier of primary domestic league (`31` = La Liga)[cite: 6] | `31`[cite: 6] |
| `[10]` | `[11]` | `primary_league_name`| `VARCHAR`| Full name of primary league[cite: 6] | `"Spanish La Liga"`[cite: 6] |
| `[11]` | `[12]` | `primary_league_logo`| `VARCHAR`| Relative path to primary league emblem[cite: 6] | `"league_match/images/1jx44n35b42j.png"`[cite: 6] |

---

## 2. Positional Squad Groups (`rearguard`, `vanguard`, `goalkeeper`, `midfielder`, `coach`)

2D arrays grouping the active roster by pitch position[cite: 6, 7]:
* `goalkeeper`: Goalkeepers[cite: 6, 7]
* `rearguard`: Defenders / Backline players[cite: 6, 7]
* `midfielder`: Midfielders[cite: 6, 7]
* `vanguard`: Forwards / Wingers / Attackers[cite: 6, 7]
* `coach`: Head coach / Manager profile[cite: 6]

### Squad Item Schema (All Groups):
| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `player_id` | `INTEGER` | Unique player or coach identifier[cite: 6, 7] | `103232`[cite: 6] |
| `[1]` | `[2]` | `jersey_number` | `VARCHAR` | Squad shirt number (empty string for staff or unassigned)[cite: 6] | `"2"`[cite: 6] |
| `[2]` | `[3]` | `player_name` | `VARCHAR` | Full player or manager display name[cite: 6] | `"Joao Cancelo"`[cite: 6] |
| `[3]` | `[4]` | `captain_flag` | `VARCHAR` | `1` = Team Captain / Leadership squad, `0` = Regular player[cite: 6] | `"0"`[cite: 6] |
| `[4]` | `[5]` | `player_photo` | `VARCHAR` | Relative asset path to player headshot[cite: 6] | `"images/1jxvqzm8f01f.png"`[cite: 6] |

---

## 3. `lineupDetail` (Detailed Squad & Player Roster Statistics)

2D array capturing comprehensive personal, contract, valuation, and season performance metrics for each squad member[cite: 6, 7]:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description / HTML Element Reference | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `player_id` | `INTEGER` | Unique player or coach identifier (`lineupItemTpl -> toPlayer`)[cite: 6, 7] | `150899`[cite: 6] |
| `[1]` | `[2]` | `jersey_number` | `VARCHAR` | Squad shirt number (`lineupItemTpl -> {$num}`)[cite: 6, 7] | `"11"`[cite: 6] |
| `[2]` | `[3]` | `player_name` | `VARCHAR` | Full name (`lineupItemTpl -> {$playerName}`)[cite: 6, 7] | `"Raphael Dias Belloli"`[cite: 6] |
| `[3]` | `[4]` | `captain_flag` | `VARCHAR` | `1` = Captain, `0` = Regular squad member, `""` = Staff[cite: 6] | `"0"`[cite: 6] |
| `[4]` | `[5]` | `birth_date` | `DATE` | Date of birth in `YYYY-MM-DD` (used to calculate `{$age}`)[cite: 6, 7] | `"1996-12-14"`[cite: 6] |
| `[5]` | `[6]` | `height_cm` | `INTEGER` | Player height in centimeters[cite: 6] | `"176"`[cite: 6] |
| `[6]` | `[7]` | `weight_kg` | `INTEGER` | Player weight in kilograms[cite: 6] | `"68"`[cite: 6] |
| `[7]` | `[8]` | `position_role`| `VARCHAR` | Specific tactical position (`lineupItemTpl -> {$position}`)[cite: 6, 7] | `"Left Winger"`[cite: 6] |
| `[8]` | `[9]` | `nationality` | `VARCHAR` | Country of nationality (`lineupItemTpl -> {$country}`)[cite: 6, 7] | `"Brazil"`[cite: 6] |
| `[9]` | `[10]` | `market_value` | `DOUBLE` | Value in Ten-Thousand EUR/GBP (e.g., `8000` = €80.00M, `20000` = €200.00M) (`{$money}`)[cite: 6, 7] | `"8000"`[cite: 6] |
| `[10]` | `[11]` | `contract_expiry`| `DATE` | Contract expiry date in `YYYY-MM-DD` (`{$contractDate}`)[cite: 6, 7] | `"2028-06-30"`[cite: 6] |
| `[11]` | `[12]` | `total_matches` | `INTEGER` | Total matches played / appearances for club[cite: 6] | `140`[cite: 6] |
| `[12]` | `[13]` | `starts` | `INTEGER` | Total starting lineup appearances[cite: 6] | `67`[cite: 6] |
| `[13]` | `[14]` | `goals` | `INTEGER` | Total goals scored[cite: 6] | `35`[cite: 6] |
| `[14]` | `[15]` | `penalty_goals` | `INTEGER` | Penalty kick goals scored[cite: 6] | `5`[cite: 6] |
| `[15]` | `[16]` | `assists` | `INTEGER` | Total goal assists provided[cite: 6] | `45`[cite: 6] |

---

## 4. `cupData` (Active Cup Competitions)

List of active or historical cup tournaments in which the club participates[cite: 6]:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `cup_id` | `INTEGER` | Unique cup tournament identifier[cite: 6] | `81`[cite: 6] |
| `[1]` | `[2]` | `cup_short_name`| `VARCHAR` | Tournament abbreviation[cite: 6] | `"SPA CUP"`[cite: 6] |
| `[2]` | `[3]` | `season` | `VARCHAR` | Season interval or active year[cite: 6] | `"2025-2026"`[cite: 6] |

---

## 5. `CountSum` (Historical & Seasonal Competition Performance Aggregates)

2D array compiling cumulative performance metrics across different tournaments, where Row 0 represents the total ("All") and subsequent rows break down individual competitions[cite: 6, 7]:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description / HTML Element Reference | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `league_id` | `INTEGER` | Competition ID (`0` = All competitions aggregate)[cite: 6] | `"0"`[cite: 6] |
| `[1]` | `[2]` | `league_name` | `VARCHAR` | Competition full name (`"All"`, `"Spanish La Liga"`, etc.)[cite: 6, 7] | `"All"`[cite: 6] |
| `[2]` | `[3]` | `total_matches` | `INTEGER` | Total matches evaluated / played (`Plays`)[cite: 6] | `"543"`[cite: 6] |
| `[3]` | `[4]` | `wins` | `INTEGER` | Total matches won (`W`)[cite: 6, 7] | `"143"`[cite: 6] |
| `[4]` | `[5]` | `losses_or_draws`| `INTEGER` | Total draws/losses count[cite: 6, 7] | `"126"`[cite: 6] |
| `[5]` | `[6]` | `total_shots` | `INTEGER` | Total shots attempted[cite: 6] | `"8238"`[cite: 6] |
| `[6]` | `[7]` | `shots_on_target`| `INTEGER` | Shots on target / SOG[cite: 6] | `"1534"`[cite: 6] |
| `[7]` | `[8]` | `conversion_rate`| `DOUBLE` | Goal conversion rate percentage[cite: 6] | `"65"`[cite: 6] |
| `[8]` | `[9]` | `avg_possession` | `DOUBLE` | Average ball possession percentage (`Possession`)[cite: 6] | `"62.71"`[cite: 6] |
| `[9]` | `[10]` | `fouled` | `INTEGER` | Total fouls drawn from opponents[cite: 6] | `"12243"`[cite: 6] |
| `[10]` | `[11]` | `fouls` | `INTEGER` | Total fouls committed (`Fouls`)[cite: 6] | `"5030"`[cite: 6] |
| `[11]` | `[12]` | `total_passes` | `INTEGER` | Total passes attempted[cite: 6] | `"412268"`[cite: 6] |
| `[12]` | `[13]` | `passes_success`| `INTEGER` | Accurate passes completed[cite: 6] | `"356412"`[cite: 6] |
| `[13]` | `[14]` | `pass_rate` | `DOUBLE` | Pass completion rate ratio[cite: 6] | `"0.86"`[cite: 6] |
| `[14]` | `[15]` | `key_passes` | `INTEGER` | Total key passes / chance creations[cite: 6] | `"7942"`[cite: 6] |
| `[15]` | `[16]` | `long_passes` | `INTEGER` | Accurate long balls completed[cite: 6] | `"4832"`[cite: 6] |
| `[16]` | `[17]` | `through_balls` | `INTEGER` | Accurate through balls completed[cite: 6] | `"1898"`[cite: 6] |
| `[17]` | `[18]` | `dribbles` | `INTEGER` | Successful dribbles executed[cite: 6] | `"11609"`[cite: 6] |
| `[18]` | `[19]` | `interceptions` | `INTEGER` | Interceptions executed[cite: 6] | `"6541"`[cite: 6] |
| `[19]` | `[20]` | `clearances` | `INTEGER` | Defensive clearances made[cite: 6] | `"1951"`[cite: 6] |
| `[20]` | `[21]` | `steals` | `INTEGER` | Possession steals / recoveries[cite: 6] | `"11172"`[cite: 6] |
| `[21]` | `[22]` | `tackles` | `INTEGER` | Tackles won[cite: 6] | `"4463"`[cite: 6] |
| `[22]` | `[23]` | `blocked_shots` | `INTEGER` | Opposition shots blocked[cite: 6] | `"2275"`[cite: 6] |
| `[23]` | `[24]` | `aerials_won` | `INTEGER` | Aerial duels won / headers won[cite: 6] | `"11772"`[cite: 6] |
| `[24]` | `[25]` | `avg_rating` | `DOUBLE` | Overall average squad rating (`Avg Rating`)[cite: 6, 7] | `"6.96"`[cite: 6] |

---

## 6. `TeamCount` (Match-by-Match Fixtures, Technical Data & Form Matrix)

2D array recording individual match fixtures, final scores, and detailed technical statistics[cite: 6, 7]:

| Index (0-based) | DuckDB Index (1-based) | Field Name | Data Type | Description / HTML Element Reference | Source Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `match_id` | `INTEGER` | Unique fixture identifier (`matchTPL -> {$ID}`)[cite: 6, 7] | `3057033`[cite: 6] |
| `[1]` | `[2]` | `home_team_id` | `INTEGER` | Home club identifier (`toTeam({$HomeID})`)[cite: 6, 7] | `187`[cite: 6] |
| `[2]` | `[3]` | `away_team_id` | `INTEGER` | Away club identifier (`toTeam({$AwayID})`)[cite: 6, 7] | `84`[cite: 6] |
| `[3]` | `[4]` | `match_time` | `VARCHAR` | Kickoff date & time in `YYYY-MM-DD HH:MM` (`{$Date}`)[cite: 6, 7] | `"2026-08-09 04:15"`[cite: 6] |
| `[4]` | `[5]` | `league_id` | `INTEGER` | Competition / League ID (`{$SclassID}`)[cite: 6, 7] | `41`[cite: 6] |
| `[5]` | `[6]` | `league_code` | `VARCHAR` | Competition abbreviation code (`{$SclassName}`)[cite: 6, 7] | `"INT CF"`[cite: 6] |
| `[6]` | `[7]` | `league_color` | `VARCHAR` | Hexadecimal badge color for competition[cite: 6] | `"#00A8A8"`[cite: 6] |
| `[7]` | `[8]` | `home_team_name`| `VARCHAR` | Home club display name (`{$HomeName}`)[cite: 6, 7] | `"Udinese"`[cite: 6] |
| `[8]` | `[9]` | `away_team_name`| `VARCHAR` | Away club display name (`{$AwayName}`)[cite: 6, 7] | `"FC Barcelona"`[cite: 6] |
| `[9]` | `[10]` | `home_score` | `INTEGER` | Final full-time goals scored by home team[cite: 6] | `1`[cite: 6] |
| `[10]` | `[11]` | `away_score` | `INTEGER` | Final full-time goals scored by away team[cite: 6] | `0`[cite: 6] |
| `[11]` | `[12]` | `ht_home_score` | `INTEGER` | Half-time goals or technical index[cite: 6] | `0`[cite: 6] |
| `[12]` | `[13]` | `ht_away_score` | `INTEGER` | Half-time goals or technical index[cite: 6] | `1`[cite: 6] |
| `[13]` | `[14]` | `red_cards` | `INTEGER` | Red cards issued in match (`{$HomeRedCard}`, `{$AwayRedCard}`)[cite: 6, 7] | `0`[cite: 6] |
| `[14]` | `[15]` | `possession_pct`| `INTEGER` | Ball possession percentage[cite: 6] | `0`[cite: 6] |
| `[15]` | `[16]` | `shots` | `INTEGER` | Total shots attempted[cite: 6] | `0`[cite: 6] |
| `[16]` | `[17]` | `shots_on_target`| `INTEGER`| Shots on target / SOG[cite: 6] | `0`[cite: 6] |
| `[17]` | `[18]` | `passes` | `INTEGER` | Total passes attempted[cite: 6] | `0`[cite: 6] |
| `[18]` | `[19]` | `passes_success`| `INTEGER` | Accurate passes completed[cite: 6] | `0`[cite: 6] |
| `[19]` | `[20]` | `pass_rate` | `DOUBLE` | Pass accuracy rate ratio[cite: 6] | `0`[cite: 6] |
| `[20]` | `[21]` | `key_passes` | `INTEGER` | Key passes / chance creations[cite: 6] | `0`[cite: 6] |
| `[21]` | `[22]` | `corners` | `INTEGER` | Corner kicks earned[cite: 6] | `0`[cite: 6] |
| `[22]` | `[23]` | `offsides` | `INTEGER` | Offside infractions[cite: 6] | `0`[cite: 6] |
| `[23]` | `[24]` | `penalty_count` | `INTEGER` | Penalty kick events[cite: 6] | `0`[cite: 6] |
| `[24]` | `[25]` | `dribbles` | `INTEGER` | Dribbles executed[cite: 6] | `0`[cite: 6] |
| `[25]` | `[26]` | `fouls` | `INTEGER` | Fouls committed[cite: 6] | `0`[cite: 6] |
| `[26]` | `[27]` | `yellow_cards` | `INTEGER` | Yellow cards issued[cite: 6] | `0`[cite: 6] |
| `[27]` | `[28]` | `tackles` | `INTEGER` | Tackles won[cite: 6] | `0`[cite: 6] |
| `[28]` | `[29]` | `interceptions` | `INTEGER` | Interceptions made[cite: 6] | `0`[cite: 6] |
| `[29]` | `[30]` | `blocked_shots` | `INTEGER` | Blocked shots[cite: 6] | `0`[cite: 6] |
| `[30]` | `[31]` | `clearances` | `INTEGER` | Defensive clearances[cite: 6] | `0`[cite: 6] |
| `[31]` | `[32]` | `match_rating` | `DOUBLE` | Team match rating (`{$Rating}`)[cite: 6, 7] | `0`[cite: 6] |
| `[32]` | `[33]` | `has_detail_flag`| `INTEGER`| `1` = Match detail and technical event log available, `0` = None[cite: 6] | `1`[cite: 6] |

---

## 7. `leagueData` (League Form & Standings Matrix)

Nested multi-tier array containing historical form, home/away points distribution, and table standing indices[cite: 6]:
* Structure: 6 rows of 13-element numerical arrays followed by a trailing status integer (`0`)[cite: 6].