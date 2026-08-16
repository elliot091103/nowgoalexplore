# Tournament Player Technical Statistics Schema Specification

This document defines the schema, key-value mappings, and 57 statistical metrics contained in the season-level player statistics dataset (`playerTech_{leagueId}_en.json`) based on the API response object and frontend filter bindings.

---

## 1. Top-Level Structure (`TechCountInfo`)

The root object `TechCountInfo` contains player reference dictionaries, team reference dictionaries, and partitioned statistical arrays:

* **`Pid`**: Player metadata dictionary mapping `PlayerID` to display names, photos, and team IDs.
* **`Tid`**: Team reference dictionary mapping `TeamID` to country/club names.
* **`Total`**: Aggregate statistics across all matches in the tournament/season.
* **`Home`**: Statistics recorded only during home matches.
* **`Guest` / `Away`**: Statistics recorded only during away matches.

---

## 2. Reference Mappings

### 2.1 `Pid` (Player Profile Lookup)
Object mapping string `PlayerID` keys to an array containing profile data and affiliated team:
* `[0][0]` **Player Name** (`string`): Full display name (e.g., `"Nguyen Dinh Bac"`, `"Hariss Harun"`).
* `[0][1]` **Player Photo** (`string`): Relative asset path to player headshot (e.g., `"images/1hmb2gjzwv12.png"`).
* `[1]` **Team ID** (`int`): Identifier of the player's national team or club (e.g., `883` = Vietnam, `892` = Singapore).

### 2.2 `Tid` (Team Lookup)
Object mapping string `TeamID` keys to team names:
* `[0]` **Team Name** (`string`): Country / Club display name (e.g., `["Vietnam"]`, `["Thailand"]`).

---

## 3. Statistical Metrics Schema (`Key` and `Value` Rows)

Each split (`Total`, `Home`, `Guest`) contains a `Key` lookup object mapping metric names to 0-based array indices, and a `Value` 2D array where each row represents a player:

| Index (0-based) | DuckDB Index (1-based) | Metric Key | Data Type | Description / Calculation Reference |
| :--- | :--- | :--- | :--- | :--- |
| `[0]` | `[1]` | `PlayerID` | `INTEGER` | Unique player identifier matching `Pid`. |
| `[1]` | `[2]` | `SchSum` | `INTEGER` | Total matches played (Appearances). |
| `[2]` | `[3]` | `BackSum` | `INTEGER` | Substitution appearances from the bench. |
| `[3]` | `[4]` | `PlayingTime` | `INTEGER` | Total minutes on pitch. |
| `[4]` | `[5]` | `notPenaltyGoals` | `INTEGER` | Open-play / non-penalty goals scored. |
| `[5]` | `[6]` | `penaltyGoals` | `INTEGER` | Goals scored from penalty kicks. |
| `[6]` | `[7]` | `shots` | `INTEGER` | Total shots attempted. |
| `[7]` | `[8]` | `shotsTarget` | `INTEGER` | Shots on target (SOG). |
| `[8]` | `[9]` | `wasFouled` | `INTEGER` | Total fouls drawn from opponents. |
| `[9]` | `[10]` | `bestSum` | `INTEGER` | Man of the Match / Best Player awards count. |
| `[10]` | `[11]` | `rating` | `DOUBLE` | Cumulative rating score sum across matches. |
| `[11]` | `[12]` | `effRating` | `INTEGER` | Number of rated matches used to calculate average rating. |
| `[12]` | `[13]` | `pass` | `INTEGER` | Total attempted passes. |
| `[13]` | `[14]` | `passSuc` | `INTEGER` | Successful passes completed. |
| `[14]` | `[15]` | `keyPass` | `INTEGER` | Key passes / shot assists created. |
| `[15]` | `[16]` | `assist` | `INTEGER` | Direct goal assists. |
| `[16]` | `[17]` | `longBalls` | `INTEGER` | Long balls attempted. |
| `[17]` | `[18]` | `longBallsSuc` | `INTEGER` | Accurate long balls completed. |
| `[18]` | `[19]` | `throughBall` | `INTEGER` | Through balls attempted. |
| `[19]` | `[20]` | `throughBallSuc` | `INTEGER` | Accurate through balls completed. |
| `[20]` | `[21]` | `Cross` | `INTEGER` | Crosses attempted. |
| `[21]` | `[22]` | `CrossSuc` | `INTEGER` | Accurate crosses completed. |
| `[22]` | `[23]` | `dribblesSuc` | `INTEGER` | Successful dribbles completed. |
| `[23]` | `[24]` | `offside` | `INTEGER` | Offside infractions committed. |
| `[24]` | `[25]` | `tackle` | `INTEGER` | Tackles won. |
| `[25]` | `[26]` | `interception` | `INTEGER` | Interceptions made. |
| `[26]` | `[27]` | `clearance` | `INTEGER` | Defensive clearances made. |
| `[27]` | `[28]` | `clearanceSuc` | `INTEGER` | Effective clearances. |
| `[28]` | `[29]` | `offsideProvoked` | `INTEGER` | Offsides drawn / offside trap triggered. |
| `[29]` | `[30]` | `dispossessed` | `INTEGER` | Times possession was lost / dispossessed. |
| `[30]` | `[31]` | `shotsBlocked` | `INTEGER` | Opposition shots blocked. |
| `[31]` | `[32]` | `aerialSuc` | `INTEGER` | Aerial duels won / headers won. |
| `[32]` | `[33]` | `foul` | `INTEGER` | Fouls committed. |
| `[33]` | `[34]` | `red` | `INTEGER` | Red cards received. |
| `[34]` | `[35]` | `yellow` | `INTEGER` | Yellow cards received. |
| `[35]` | `[36]` | `ownGoal` | `INTEGER` | Own goals scored. |
| `[36]` | `[37]` | `touch` | `INTEGER` | Total touches of the ball. |
| `[37]` | `[38]` | `turnOver` | `INTEGER` | Unforced turnovers / miscontrols. |
| `[38]` | `[39]` | `penaltyProvoked` | `INTEGER` | Penalty kicks earned / provoked. |
| `[39]` | `[40]` | `shotsOnPost` | `INTEGER` | Shots hitting the woodwork / post. |
| `[40]` | `[41]` | `ExpectedGoals` | `DOUBLE` | Total Expected Goals (xG). |
| `[41]` | `[42]` | `ExpectedAssists` | `DOUBLE` | Total Expected Assists (xA). |
| `[42]` | `[43]` | `xGOT` | `DOUBLE` | Expected Goals on Target (xGOT). |
| `[43]` | `[44]` | `HeadedClearance` | `INTEGER` | Headed clearances. |
| `[44]` | `[45]` | `TIOBx` | `INTEGER` | Touches inside the opponent's penalty area. |
| `[45]` | `[46]` | `xGOTFaced` | `DOUBLE` | Post-shot expected goals faced by goalkeeper. |
| `[46]` | `[47]` | `GoalsPrevented` | `DOUBLE` | Goals prevented by goalkeeper (`xGOTFaced - GoalsConceded`). |
| `[47]` | `[48]` | `PassesIntoFinalThird` | `INTEGER` | Accurate passes played into the attacking third. |
| `[48]` | `[49]` | `Recoveries` | `INTEGER` | Loose ball recoveries. |
| `[49]` | `[50]` | `DefensiveActions` | `INTEGER` | Total active defensive actions. |
| `[50]` | `[51]` | `ActedAsSweeper` | `INTEGER` | Sweeper-keeper interventions outside penalty box. |
| `[51]` | `[52]` | `xGNonPenalty` | `DOUBLE` | Non-penalty Expected Goals (npxG). |
| `[52]` | `[53]` | `Goals` | `INTEGER` | Cumulative total goals scored (`notPenaltyGoals + penaltyGoals`). |
| `[53]` | `[54]` | `passSucPercent` | `DOUBLE` | Passing accuracy percentage (`passSuc / pass * 100`). |
| `[54]` | `[55]` | `assistMinute` | `DOUBLE` | Minutes per assist (`PlayingTime / assist`). |
| `[55]` | `[56]` | `goalMinute` | `DOUBLE` | Minutes per goal (`PlayingTime / Goals`). |
| `[56]` | `[57]` | `goalPercent` | `DOUBLE` | Shot conversion rate percentage (`Goals / shots * 100`). |

---

## 4. Frontend Filter & Sorting Map (`#techPlayerDataType`)

Mappings connecting frontend select options to statistical metric array indices:

* **Goals(P)** (`data-tech-sort="52"`): Metric index `[52]` (`Goals`)
* **Assists** (`data-tech-sort="15"`): Metric index `[15]` (`assist`)
* **Red/Yellow** (`data-tech-sort="33"`): Metric index `[33]` (`red`) and `[34]` (`yellow`)
* **Rating** (`data-tech-sort="10"`): Average rating derived from `[10]` (`rating`) / `[11]` (`effRating`)
* **Mins(Avg)** (`data-tech-sort="3"`): Metric index `[3]` (`PlayingTime`)
* **Shots/OT** (`data-tech-sort="6"`): Metric index `[6]` (`shots`) and `[7]` (`shotsTarget`)
* **Passes/Rate** (`data-tech-sort="12"`): Metric index `[12]` (`pass`) and `[53]` (`passSucPercent`)
* **Key Passes** (`data-tech-sort="14"`): Metric index `[14]` (`keyPass`)
* **Tackles** (`data-tech-sort="24"`): Metric index `[24]` (`tackle`)
* **Interceptions** (`data-tech-sort="25"`): Metric index `[25]` (`interception`)
* **Clearances** (`data-tech-sort="26"`): Metric index `[26]` (`clearance`)
* **Steal** (`data-tech-sort="29"`): Metric index `[29]` (`dispossessed`)
* **Fouls** (`data-tech-sort="32"`): Metric index `[32]` (`foul`)
* **Fouled** (`data-tech-sort="8"`): Metric index `[8]` (`wasFouled`)
* **Dribbles** (`data-tech-sort="22"`): Metric index `[22]` (`dribblesSuc`)