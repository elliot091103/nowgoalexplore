# Match Player Technical Statistics & Lineup Data Schema

This document provides the complete schema definition, field data types, and lookup codes for the single-match player technical statistics JSON dataset (`ajax/soccerajax?type=23&id={scheduleId}` or match technical feed) based on the API response object and frontend modal view bindings[cite: 10, 11].

---

## 1. Root Response Envelope

| Field Name | Data Type | Description | Example / Values |
| :--- | :--- | :--- | :--- |
| `ErrCode` | `INTEGER` | Status / Error code of the API response (`0` = Success)[cite: 10, 11] | `0`[cite: 11] |
| `MatchState` | `INTEGER` | Match state code (`0` = Not started, `1` = 1st Half, `2` = HT, `3` = 2nd Half, `-1` = Full Time)[cite: 10, 11] | `0`[cite: 11] |
| `Data` | `OBJECT` | Container holding team player lists (`hList` and `gList`)[cite: 11] | `{ "hList": [...], "gList": [...] }`[cite: 11] |

---

## 2. Player Technical Object (`hList` and `gList`)

The `Data` object contains two arrays of player objects: `hList` for the home team and `gList` for the guest/away team[cite: 11]. Each object contains 35 attributes covering player profile, substitution timestamps, attacking, passing, defending, and disciplinary statistics[cite: 11]:

### 2.1 Identity & Roster Profile
| Field Name | Data Type | Description / Frontend Binding | Source Example |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | Unique player identifier matching global database (`techWinId`)[cite: 10, 11] | `251089`[cite: 11] |
| `no` | `INTEGER` | Squad shirt / jersey number (`#techWin -> Num`)[cite: 10, 11] | `9`[cite: 11] |
| `name` | `VARCHAR` | Full player display name (`#techWin -> Name`)[cite: 10, 11] | `"Nguyen Dinh Bac"`[cite: 11] |
| `photo` | `VARCHAR` | Relative asset path to player headshot icon[cite: 10, 11] | `"images/1hmb2gjzwv12.png"`[cite: 11] |
| `pName` | `VARCHAR` | Tactical position / role title (`#techWin -> Position`)[cite: 10, 11] | `"Left Winger"`[cite: 11] |
| `valid` | `BOOLEAN` | Activity flag (`true` = player featured on pitch with recorded stats; `false` = unused substitute)[cite: 10, 11] | `true`[cite: 11] |

### 2.2 Substitution & Timing Attributes
| Field Name | Data Type | Description / Timing Logic | Source Example |
| :--- | :--- | :--- | :--- |
| `subTime` | `INTEGER` | Regulation minute when player was substituted IN (`0` if starter or unused)[cite: 10, 11] | `46`[cite: 11] |
| `subst` | `INTEGER` | Added / injury time minutes for substitution IN (e.g., `2` for 90+2')[cite: 10, 11] | `2`[cite: 11] |
| `offsubTime` | `INTEGER` | Regulation minute when player was substituted OUT (`0` if played full duration)[cite: 10, 11] | `79`[cite: 11] |
| `offsub` | `INTEGER` | Added / injury time minutes for substitution OUT[cite: 10, 11] | `0`[cite: 11] |

### 2.3 Attacking & Offensive Metrics
| Field Name | Data Type | Description / Modal Tab Binding | Source Example |
| :--- | :--- | :--- | :--- |
| `shots` | `INTEGER` | Total shots attempted (`#attackTech -> Shots`)[cite: 10, 11] | `4`[cite: 11] |
| `shotsTarget` | `INTEGER` | Shots on target (`#attackTech -> Shots (OT)`)[cite: 10, 11] | `4`[cite: 11] |
| `dribblesWon` | `INTEGER` | Successful take-ons / dribbles (`#attackTech -> Break Loose`)[cite: 10, 11] | `2`[cite: 11] |
| `wasFouled` | `INTEGER` | Total fouls drawn from opponent (`#attackTech -> Fouled`)[cite: 10, 11] | `2`[cite: 11] |
| `dispossessed` | `INTEGER` | Times player lost ball possession (`#attackTech -> Possession Lost`)[cite: 10, 11] | `0`[cite: 11] |
| `turnOver` | `INTEGER` | Unforced turnovers / miscontrols (`#attackTech -> Turnover`)[cite: 10, 11] | `3`[cite: 11] |
| `offsides` | `INTEGER` | Offside infractions committed (`#attackTech -> Offsides`)[cite: 10, 11] | `0`[cite: 11] |

### 2.4 Passing & Playmaking Metrics
| Field Name | Data Type | Description / Modal Tab Binding | Source Example |
| :--- | :--- | :--- | :--- |
| `totalPass` | `INTEGER` | Total passes attempted (`#passTech -> Passes`)[cite: 10, 11] | `39`[cite: 11] |
| `accuratePass` | `INTEGER` | Accurate passes completed (`#passTech -> Acc. Passes`)[cite: 10, 11] | `33`[cite: 11] |
| `keyPass` | `INTEGER` | Key passes / shot assists created (`#passTech -> Key Passes`)[cite: 10, 11] | `3`[cite: 11] |
| `crossNum` | `INTEGER` | Total crosses attempted (`#passTech -> Crosses`)[cite: 10, 11] | `2`[cite: 11] |
| `crossWon` | `INTEGER` | Accurate crosses completed (`#passTech -> Acc. Crosses`)[cite: 10, 11] | `0`[cite: 11] |
| `longBall` | `INTEGER` | Total long passes attempted (`#passTech -> Long Passes`)[cite: 10, 11] | `1`[cite: 11] |
| `longBallWon` | `INTEGER` | Accurate long passes completed (`#passTech -> Acc. Long Passes`)[cite: 10, 11] | `1`[cite: 11] |
| `throughBall` | `INTEGER` | Total through balls attempted (`#passTech -> Through`)[cite: 10, 11] | `0`[cite: 11] |
| `throughBallWon` | `INTEGER` | Accurate through balls completed (`#passTech -> AccThrough`)[cite: 10, 11] | `0`[cite: 11] |

### 2.5 Defending & Disciplinary Metrics
| Field Name | Data Type | Description / Modal Tab Binding | Source Example |
| :--- | :--- | :--- | :--- |
| `tackles` | `INTEGER` | Total tackles won (`#defendTech -> Tackles`)[cite: 10, 11] | `0`[cite: 11] |
| `interception` | `INTEGER` | Interceptions made (`#defendTech -> Interceptions`)[cite: 10, 11] | `0`[cite: 11] |
| `clearances` | `INTEGER` | Total clearances made (`#defendTech -> Clearances`)[cite: 10, 11] | `0`[cite: 11] |
| `clearanceWon` | `INTEGER` | Effective clearances completed (`#defendTech -> Effective Clearance`)[cite: 10, 11] | `0`[cite: 11] |
| `shotsBlocked` | `INTEGER` | Opposition shots blocked (`#defendTech -> Blocked`)[cite: 10, 11] | `0`[cite: 11] |
| `offsideProvoked` | `INTEGER` | Offside trap provoked / offsides drawn (`#defendTech -> Offside Trap`)[cite: 10, 11] | `0`[cite: 11] |
| `fouls` | `INTEGER` | Fouls committed (`#defendTech -> Fouls`)[cite: 10, 11] | `1`[cite: 11] |

### 2.6 Performance Rating & In-Match Events
| Field Name | Data Type | Description / Value Mapping | Source Example |
| :--- | :--- | :--- | :--- |
| `rating` | `DOUBLE` | Individual match rating score out of 10.0 (`0.0` if unrated/unplayed)[cite: 10, 11] | `9.4`[cite: 11] |
| `event` | `VARCHAR` | Caret-delimited string (`^`) of match event code IDs (see Section 3)[cite: 10, 11] | `"1^1"`[cite: 11] |

---

## 3. Match Event Codes Reference Table (`event`)

The `event` field stores in-game event occurrences concatenated by `^` (e.g., `"12^5"` = Assist + Sub out, `"4^1"` = Sub in + Goal)[cite: 10, 11]. Each code maps to icons rendered in the lineup view and `#techWin` header[cite: 10]:

| Event ID | Event Name | Description / Asset Icon |
| :--- | :--- | :--- |
| `1` | `Goal` | Regular open-play or set-piece goal scored (`/images/bf_img/1.png`)[cite: 10] |
| `2` | `Red Card` | Direct red card issued (`/images/bf_img/2.png`)[cite: 10] |
| `3` | `Yellow Card` | Yellow card caution issued (`/images/bf_img/3.png`)[cite: 10] |
| `4` | `Sub in` | Player entered match as substitute (`/images/bf_img/4.png`)[cite: 10] |
| `5` | `Sub out` | Player substituted off pitch (`/images/bf_img/5.png`)[cite: 10] |
| `7` | `Penalty Scored` | Goal scored from penalty kick (`/images/bf_img/7.png`)[cite: 10] |
| `8` | `Own Goal` | Own goal conceded by player (`/images/bf_img/8.png`)[cite: 10] |
| `9` | `Second Yellow Card` | Second yellow resulting in red card (`/images/bf_img/9.png`)[cite: 10] |
| `11` | `Substitution` | Generic substitution event (`/images/bf_img/11.png`)[cite: 10] |
| `12` | `Assist` | Direct goal assist credited (`/images/bf_img/12.png`)[cite: 10] |
| `13` | `Penalty Missed` | Penalty kick missed or off target (`/images/bf_img/13.png`)[cite: 10] |
| `14` | `VAR` | VAR review incident (`/images/bf_img/14.png`)[cite: 10] |
| `30` | `Penalty Saved` | Penalty kick saved by goalkeeper (`/images/bf_img/30.png`)[cite: 10] |
| `31` | `Hit the Post` | Shot hit woodwork / goal frame (`/images/bf_img/31.png`)[cite: 10] |
| `32` | `Man of the Match` | Best player of the match designation[cite: 10] |
| `33` | `Error Led to Goal` | Defensive error directly leading to opposition goal (`/images/bf_img/33.png`)[cite: 10] |
| `34` | `Last Man Tackle` | Crucial defensive intervention as last defender (`/images/bf_img/34.png`)[cite: 10] |
| `35` | `Clearance Off Line` | Goal-line clearance executed (`/images/bf_img/35.png`)[cite: 10] |
| `36` | `Foul Led to Penalty` | Foul committed inside box conceding penalty (`/images/bf_img/36.png`)[cite: 10] |
| `37` | `Last Dribble` | Final third take-on / dribble event (`/images/bf_img/37.png`)[cite: 10] |
| `55` | `Mark` | Special player indicator / tactical mark (`/images/bf_img/55.png`)[cite: 10] |

---

## 4. Modal Tab Aggregation Mapping (`_techWin`)

When a player card is selected in the UI, the frontend formats the raw fields into three category panels[cite: 10]:

### Offensing (`#attackTech`)
* `Shots (Shots on Target)`: `shots + " (" + shotsTarget + ")"`[cite: 10]
* `Break Loose`: `dribblesWon`[cite: 10]
* `Fouled`: `wasFouled`[cite: 10]
* `Possession Lost`: `dispossessed`[cite: 10]
* `Turnover`: `turnOver`[cite: 10]
* `Offsides`: `offsides`[cite: 10]

### Defensing (`#defendTech`)
* `Clearances (Effective Clearances)`: `clearances + " (" + clearanceWon + ")"`[cite: 10]
* `Tackles`: `tackles`[cite: 10]
* `Interceptions`: `interception`[cite: 10]
* `Blocked`: `shotsBlocked`[cite: 10]
* `Offside Trap`: `offsideProvoked`[cite: 10]
* `Fouls`: `fouls`[cite: 10]

### Passing (`#passTech`)
* `Key Passes`: `keyPass`[cite: 10]
* `Passes (Accurate Passes)`: `totalPass + " (" + accuratePass + ")"`[cite: 10]
* `Crosses (Accurate Crosses)`: `crossNum + " (" + crossWon + ")"`[cite: 10]
* `Long Passes (Accurate Long Passes)`: `longBall + " (" + longBallWon + ")"`[cite: 10]
* `Through (Accurate Through Balls)`: `throughBall + " (" + throughBallWon + ")"`[cite: 10]