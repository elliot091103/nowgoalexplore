# Schema and Data Findings Documentation: Season Detail & Web Architecture

This document provides a comprehensive reference and data schema breakdown for the soccer tournament dataset (`season_detail.json`) and its corresponding web application frontend (`season_detail_source.html`).

---

## 1. System Architecture and API Endpoints

### 1.1 Base Domains
* **Data Web Domain (`_dataWebDomain`)**: `https://data.thscore1.com/`
* **Live Score Web Domain (`_livescoreWebDomain`)**: `https://www.nowgoal.net/`
* **CDN Asset Web Domain (`_cdnWebDomain`)**: `https://imgcms.thscore.fun`
* **Info Domain (`_infoDomain`)**: `https://football.nowgoal.net/`
* **User Domain (`_userWebDomain`)**: `https://user2.nowgoal.net/`
* **Touch / Mobile Domain (`_touchWebDomain`)**: `https://m.nowgoal.net/`

### 1.2 Data Endpoints
* **Tournament & Match Data**: `https://data.thscore1.com/jsData/matchResult/json/2026/c1124_en.json` (constructed from `_dataWebDomain` + `_dataPath`)
* **Season History List**: `https://data.thscore1.com/jsData/leagueSeason/sea1124.json` (constructed from `_seasonPath`)
* **Player Statistics / Technical Data**: `https://data.thscore1.com/jsData/Count/json/2026/playerTech_1124_en.json` (constructed from `_playerTechPath`)

### 1.3 Static Media & Image Asset Templates
* **Team Crest / Logo**: `https://imgcms.thscore.fun/mini/fbteam/{teamId}.png`
* **Country Flag**: `https://imgcms.thscore.fun/mini/fbcountry/{countryId}-flag-small.png`
* **League / Tournament Logo**: `https://imgcms.thscore.fun/mini/fbleague/{leagueId}.png`
* **Player Headshot**: `https://imgcms.thscore.fun/football/image/player/{pPic}`

### 1.4 Country Names and ISO Standards
* **Country Names**: Extracted from the `TeamList` array (e.g., Vietnam, Thailand, Indonesia, Malaysia, Singapore, Philippines, Myanmar, Cambodia, Laos, Brunei Darussalam, Timor Leste).
* **ISO Country Codes**: Standard ISO 3166-1 alpha-2 or alpha-3 codes are **not provided** in either the JSON data or HTML source. Entities are tracked exclusively via internal numeric IDs (e.g., Vietnam = `883`, Thailand = `886`, Indonesia = `890`).

---

## 2. Global JSON Schema Definitions

### 2.1 `LeagueInfo` (Tournament Metadata)
Fixed-length array describing the league/cup tournament:
* `[0]` **League ID** (`int`): Unique tournament identifier (`1124`).
* `[1]` **Tournament Name** (`string`): Full name (`"ASEAN Championship"`).
* `[2]` **Short / Display Name** (`string`): Abbreviated name (`"ASEAN Cup"`).
* `[3]` **Season Year** (`string`): Current season (`"2026"`).
* `[4]` **Logo Path** (`string`): Relative image URL path (`"league_match/images/1kt3k94zz914.png"`).
* `[5]` **Primary Color Theme** (`string`): Hexadecimal color code (`"#333388"`).
* `[6]` **Tournament Rules & Historical Description** (`string`): HTML-formatted tournament regulations and history.
* `[7]` **Status Flag** (`int`): League status flag (`0`).

---

### 2.2 `CupKindList` (Tournament Stages)
Array of stage objects representing the rounds/phases of the competition:
* `[0]` **Stage ID** (`int`): Unique stage identifier (e.g., `28705` for Qualifiers, `28706` for Group Stage, `28989` for Semifinal).
* `[1]` **Stage Group Index / Format** (`int`): `0` = Knockout/Two-legged ties, `1` = Group round-robin.
* `[2]` **Stage Name** (`string`): Stage title (`"Qualifi 1"`, `"Group stage"`, `"Semifinal"`).
* `[3]` **Group Count / Code** (`string`): Number of groups or stage code (`"0"`, `"2"`).
* `[4]` **Unknown Status Flag** (`int`): Internal status flag (`0` or `1`).
* `[5]` **Is Current / Active Stage** (`int`): Binary indicator (`0` or `1`).

---

### 2.3 `TeamList` (Participating Teams)
List of participating national teams:
* `[0]` **Team ID** (`int`): Unique entity ID (e.g., `883` = Vietnam, `886` = Thailand).
* `[1]` **Team / Country Name** (`string`): Country display name.
* `[2]` **Short Code** (`string`): Abbreviation or empty string.
* `[3]` **Logo Path** (`string`): Relative image path (e.g., `"images/165018999384.png"`).

---

### 2.4 `ScheduleList` (Fixtures and Results)

The `ScheduleList` object is partitioned by stage/group keys (e.g., `G28706A`, `G28706B`, `G28705`, `G28989`).

#### A. Single Match Row Schema (23 Fields)
Standard format for all individual match arrays:
* `[0]` **Match ID** (`int`): Unique match fixture identifier (e.g., `2991080`).
* `[1]` **League ID** (`int`): Identifier of the tournament (`1124`).
* `[2]` **Match State / Status** (`int`): `-1` = Finished / Full-Time, `0` = Not Started / Scheduled.
* `[3]` **Match Date & Kickoff Time** (`string`): Format `YYYY-MM-DD HH:MM` (e.g., `"2026-07-24 20:00"`).
* `[4]` **Home Team ID** (`int`): Identifier matching `TeamList`.
* `[5]` **Away Team ID** (`int`): Identifier matching `TeamList`.
* `[6]` **Full-Time Score** (`string`): Format `"Home-Away"` (e.g., `"1-2"`), or empty string if unplayed.
* `[7]` **Half-Time Score** (`string`): Format `"Home-Away"` (e.g., `"0-1"`), or empty string if unplayed.
* `[8]` **Full-Time Asian Handicap Line (AH)** (`string`): Handicap value (e.g., `"0.25"`, `"-3.5"`).
* `[9]` **Half-Time Asian Handicap Line** (`string`): First-half handicap line (e.g., `"0"`, `"-1.5"`).
* `[10]` **Full-Time Over/Under Line (O/U)** (`string`): Total goals benchmark (e.g., `"2.5/3"`, `"4/4.5"`).
* `[11]` **Half-Time Over/Under Line** (`string`): First-half total goals benchmark (e.g., `"1/1.5"`, `"2"`).
* `[12]` **Has Live / Detail Data Flag** (`int`): Binary indicator (`1` = Available, `0` = None).
* `[13]` **Has Lineup / Analysis Flag** (`int`): Binary indicator (`1` = Available, `0` = None).
* `[14]` **Has Odds Comparison Flag** (`int`): Binary indicator (`1` = Available, `0` = None).
* `[15]` **Has Tech Stats / Event Data Flag** (`int`): Binary indicator (`1` = Available, `0` = None).
* `[16]` **Home Team Red Cards** (`int`): Number of red cards issued to home team.
* `[17]` **Away Team Red Cards** (`int`): Number of red cards issued to away team.
* `[18]` **Match Note / Extra Info** (`string`): Neutral venue notes, extra time, or shootout details.
* `[19]` **Secondary Broadcast / Venue Note** (`string`): Additional text information.
* `[20]` **Venue / Match Context Flag** (`string`): `"0"` = Standard venue, `"1"` = Specific leg/neutral context.
* `[21]` **Home Team FIFA World Ranking** (`string`): Global FIFA rank (e.g., `"99"` for Vietnam, `"94"` for Thailand, `"118"` for Indonesia).
* `[22]` **Away Team FIFA World Ranking** (`string`): Global FIFA rank (e.g., `"148"` for Singapore, `"175"` for Cambodia, `"201"` for Timor Leste).

#### B. Two-Legged Tie / Aggregate Wrapper Schema (Knockouts & Qualifiers)
For stages formatted as two-legged knockout ties (e.g., `G28705`, `G28989`), each entry contains:
* `[0]` **Team 1 ID** (`int`): Identifier of the first team in the pairing.
* `[1]` **Team 2 ID** (`int`): Identifier of the second team in the pairing.
* `[2]` **Aggregate Score Team 1** (`int`): Total goals across legs by Team 1.
* `[3]` **Aggregate Score Team 2** (`int`): Total goals across legs by Team 2.
* `[4]` **Leg Fixtures Array** (`list`): List containing the individual 23-field match arrays for Leg 1 and Leg 2.

---

### 2.5 `Standings` (Group Standings Table)
Array of group ranking records (e.g., `S28706A`, `S28706B`):
* `[0]` **Rank** (`int`): Position in the group (1 to 5).
* `[1]` **Team ID** (`int`): Identifier matching `TeamList`.
* `[2]` **Played (P / Sum)** (`int`): Total matches played.
* `[3]` **Won (W)** (`int`): Total matches won.
* `[4]` **Drawn (D)** (`int`): Total matches drawn.
* `[5]` **Lost (L)** (`int`): Total matches lost.
* `[6]` **Goals For (GF)** (`int`): Total goals scored.
* `[7]` **Goals Against (GA)** (`int`): Total goals conceded.
* `[8]` **Goal Difference (GD)** (`int`): Net goal differential (`GF - GA`).
* `[9]` **Points (PTS)** (`int`): Total points accrued (`W * 3 + D * 1`).
* `[10]` **Home Matches Count** (`int`): Number of home games scheduled/played.
* `[11]` **Away Matches Count / Penalty Deductions** (`int`): Number of away games / point deductions.
* `[12]` **Qualification Status / Remark** (`string`): Qualification notation text.

---

### 2.6 `TeamTech` (Team Technical Statistics)
Includes `Total`, `Home`, and `Guest` sub-objects. Each contains:
1. `Key`: Dictionary mapping metric names to zero-based array indices.
2. `Value`: Array of data rows corresponding to each participating team.

#### Metric Column Mappings:
| Index | Key Name | Description |
| :--- | :--- | :--- |
| `0` | `TeamID` | Team identifier |
| `1` | `SchSum` | Total matches evaluated |
| `2` | `shots` | Total shots |
| `3` | `target` | Shots on target (SOG) |
| `4` | `offTarget` | Shots off target |
| `5` | `passBall` | Total attempted passes |
| `6` | `passBallSuc` | Successful passes completed |
| `7` | `dribbles` | Total dribbles |
| `8` | `yellow` | Yellow cards received |
| `9` | `red` | Red cards received |
| `10` | `shotsed` | Shots conceded |
| `11` | `fouls` | Fouls committed |
| `12` | `Corner` | Corner kicks earned |
| `13` | `offside` | Offside infractions |
| `14` | `header` | Headers attempted |
| `15` | `headerSuc` | Headers won/scored |
| `16` | `save` | Goalkeeper saves |
| `17` | `blocked` | Blocked shots |
| `18` | `tackle` | Tackles executed |
| `19` | `throwIns` | Throw-ins taken |
| `20` | `goal` | Goals scored |
| `21` | `fumble` | Goals conceded / Defensive errors |
| `22` | `ExpectedGoals` | Total Expected Goals (xG) |
| `23` | `xGOpenPlay` | Expected Goals from open play |
| `24` | `xGSetPlay` | Expected Goals from set pieces |
| `25` | `xGNonPenalty` | Non-penalty Expected Goals (npxG) |
| `26` | `xGOT` | Expected Goals on Target (xGOT) |
| `27` | `TIOBx` | Touches inside the opponent's box |
| `28` | `AccurateCrosses` | Accurate crosses delivered |
| `29` | `GroundDuelsWon` | Ground duels won |
| `30` | `AerialDuelsWon` | Aerial duels won |
| `31` | `Clearances` | Clearances made |
| `32` | `avgControl` | Average ball possession percentage |

---

### 2.7 `LetgoalPan` (Asian Handicap / PanLu Statistics)
Organized under `TotalPanLu`, `HomePanLu`, `GuestPanLu`, `TotalHalfPanLu`, `HomeHalfPanLu`, and `GuestHalfPanLu`:
* `[0]` **Rank** (`int`): Standing by handicap win rate.
* `[1]` **Team ID** (`int`): Team identifier.
* `[2]` **Total Matches** (`int`): Matches played.
* `[3]` **Outright Wins** (`int`): Matches won outright.
* `[4]` **Outright Draws** (`int`): Matches drawn outright.
* `[5]` **Outright Losses** (`int`): Matches lost outright.
* `[6]` **Handicap Wins (Covered)** (`int`): Matches winning the AH line.
* `[7]` **Handicap Pushes (Void)** (`int`): Matches pushing the AH line.
* `[8]` **Handicap Losses (Failed)** (`int`): Matches losing the AH line.
* `[9]` **Net Handicap Wins** (`int`): `Handicap Wins - Handicap Losses`.
* `[10]` **Handicap Win Rate %** (`float`): Percentage of matches covering AH.
* `[11]` **Handicap Push Rate %** (`float`): Percentage of voided AH matches.
* `[12]` **Handicap Loss Rate %** (`float`): Percentage of failed AH matches.

---

### 2.8 `BigSmallPan` (Over/Under / Total Goals Statistics)
Organized under `TotalBs`, `HomeBs`, `GuestBs`, `TotalBsHalf`, `HomeBsHalf`, and `GuestBsHalf`:
* `[0]` **Rank** (`int`): Standing by Over rate.
* `[1]` **Team ID** (`int`): Team identifier.
* `[2]` **Total Matches** (`int`): Matches played.
* `[3]` **Over Count** (`int`): Matches exceeding the total goal line.
* `[4]` **Push Count** (`int`): Matches landing exactly on the total goal line.
* `[5]` **Under Count** (`int`): Matches staying below the total goal line.
* `[6]` **Over Rate %** (`float`): Percentage of matches going Over.
* `[7]` **Push Rate %** (`float`): Percentage of pushed matches.
* `[8]` **Under Rate %** (`float`): Percentage of matches going Under.

---

### 2.9 `AllHalf` (Half-Time / Full-Time Outcome Matrices)
Organized under `allData`, `homeData`, and `guestData`. Maps the 9 discrete HT/FT result permutations:
* `[0]` **Team ID** (`int`): Team identifier.
* `[1]` **W/W** (`int`): Lead at HT, Win at FT.
* `[2]` **W/D** (`int`): Lead at HT, Draw at FT.
* `[3]` **W/L** (`int`): Lead at HT, Lose at FT.
* `[4]` **D/W** (`int`): Tied at HT, Win at FT.
* `[5]` **D/D** (`int`): Tied at HT, Draw at FT.
* `[6]` **D/L** (`int`): Tied at HT, Lose at FT.
* `[7]` **L/W** (`int`): Trail at HT, Win at FT.
* `[8]` **L/D** (`int`): Trail at HT, Draw at FT.
* `[9]` **L/L** (`int`): Trail at HT, Lose at FT.

---

### 2.10 `SinDouList` (Goal Distribution & Odd/Even Counts)
Maps exact total goal outcomes and Odd/Even splits for all matches:
* `[0]` **Team ID** (`int`): Team identifier.
* `[1]` **0 Goals** (`int`): Matches with 0 total goals scored.
* `[2]` **1 Goal** (`int`): Matches with 1 total goal scored.
* `[3]` **2 Goals** (`int`): Matches with 2 total goals scored.
* `[4]` **3 Goals** (`int`): Matches with 3 total goals scored.
* `[5]` **4 Goals** (`int`): Matches with 4 total goals scored.
* `[6]` **5 Goals** (`int`): Matches with 5 total goals scored.
* `[7]` **6+ Goals** (`int`): Matches with 6 or more total goals scored.
* `[8]` **Odd Total (Single)** (`int`): Matches finishing with an odd goal total.
* `[9]` **Even Total (Double)** (`int`): Matches finishing with an even goal total.
