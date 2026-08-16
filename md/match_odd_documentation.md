# Nowgoal Odds API and Data Mapping Specification

This document defines the schema, query parameter mappings, and JSON response structures for Nowgoal live odds feeds and odds comparison markets.

---

## 1. Request Parameters Mapping

```python
NOWGOAL_ODDS_PARAMS_MAP = {
    "cid": {
        "description": "Bookmaker / Company ID",
        "values": {
            1: "Macauslot",
            3: "Crown",
            4: "Ladbrokes",
            8: "Bet365",
            12: "Easybet",
            14: "Vcbet",
            17: "M88",
            19: "Interwetten",
            24: "12Bet",
            31: "Sbobet",
            42: "18Bet",
            50: "1xBet",
        },
    },
    "t": {
        "description": "Odds Market / View Type",
        "values": {
            10: "All Odds (Instant / Live summary)",
            20: "3in1 Odds (AH, 1X2, and O/U trend details)",
            25: "Correct Score (BoDan)",
            26: "Euro Handicap",
            27: "Double Chance",
            28: "Corners Over/Under",
        },
    },
    "h": {
        "description": "Match Period Scope",
        "values": {
            0: "Full Time (FT)",
            1: "Half Time (HT)",
        },
    },
    "r1": {
        "description": "Asian Handicap loaded row count / offset (ahRow for polling)",
    },
    "r2": {
        "description": "1X2 / European Odds loaded row count / offset (opRow for polling)",
    },
    "r3": {
        "description": "Over/Under loaded row count / offset (ouRow for polling)",
    },
}
```

---

## 2. API Endpoint Definition

* Base URL: `/ajax/soccerajax`
* Fixed Query Type: `type=14`
* Query Parameters:
  * `id`: Match schedule ID (`scheId` / `scheduleID`)
  * `cid`: Bookmaker / Company ID
  * `t`: Market view type (`10`, `20`, `25`, `26`, `27`, `28`)
  * `h`: Period scope (`0` = Full Time, `1` = Half Time)
  * `r1`, `r2`, `r3`: Offset row counts used for incremental polling updates

---

## 3. JSON Files Structural Mapping

### 3.1 3in1 Odds Market Trends (t=20)
Consolidated odds change history containing Asian Handicap (`ah`), European 1X2 (`op`), and Over/Under (`ou`).

* Structure: `Data.ah[]`, `Data.op[]`, `Data.ou[]`
* Payload Fields:

| Field Path | Type | Description |
| :--- | :--- | :--- |
| `ErrCode` | integer | Status code (0 represents success) |
| `MatchState` | integer | Match status (-1 = Finished, 0 = Pre-match, 1 = 1st Half, 2 = HT, 3 = 2nd Half) |
| `Data.ah` | array | Asian Handicap change history |
| `Data.op` | array | 1X2 / European Odds change history |
| `Data.ou` | array | Over/Under Goal line change history |
| `[].odds.u` | string/float | Up / Home win odds / Over odds |
| `[].odds.g` | string/float | Goal line / Handicap spread / Draw odds |
| `[].odds.d` | string/float | Down / Away win odds / Under odds |
| `[].hs` | integer | Home score at the time the odds were recorded |
| `[].gs` | integer | Guest score at the time the odds were recorded |
| `[].mt` | integer | Modification timestamp (10-digit Unix epoch in seconds) |
| `[].ht` | string | Match minute / period label ("HT", match minute e.g. "90", or empty for pre-match) |
| `[].close` | boolean | Market suspension flag (true = betting closed/suspended) |
| `[].type` | integer | Record stage type (0 = Live/In-play, 1 or 2 = Pre-match) |

---

### 3.2 Corner Over/Under Trends (t=28)
Live Corner Over/Under markets handled by `createCornerTable`.

* Structure: `Data.ou[]` (Corner Over/Under lines), `Data.ah[]` (Corner Handicap if present)
* Payload Fields:

| Field Path | Type | Description |
| :--- | :--- | :--- |
| `ErrCode` | integer | Status code (0 represents success) |
| `MatchState` | integer | Current match status |
| `Data.ou` | array | Corner Over/Under line updates |
| `[].odds.u` | string/float | Corner Over odds |
| `[].odds.g` | string/float | Corner total line threshold (e.g. "5.5", "6", "7.5") |
| `[].odds.d` | string/float | Corner Under odds |
| `[].hs` | integer | Home team corner count at that point in time |
| `[].gs` | integer | Guest team corner count at that point in time |
| `[].mt` | integer | Modification timestamp (13-digit Unix epoch in milliseconds for corner feeds) |
| `[].ht` | string | Elapsed match time in minutes ("88") or raw period string |
| `[].close` | boolean | Corner market suspension state (true = closed) |
| `[].type` | integer | Data type marker (3 = Corner live stream record) |

---

### 3.3 Single List Odds Markets (oddsList Schema)
Dedicated single-market lists such as Correct Score (`t=25`), Euro Handicap (`t=26`), and Double Chance (`t=27`).

* Structure: `Data.oddsList[]`
* Payload Fields per Market Type:

#### A. Euro Handicap (t=26 - createEuroAHTable)
* `Data.oddsList[].odds.h`: Handicap spread value formatted as integer or +/- notation
* `Data.oddsList[].odds.u`: Home win handicap odds
* `Data.oddsList[].odds.g`: Draw handicap odds
* `Data.oddsList[].odds.d`: Away win handicap odds
* `Data.oddsList[].mt`: Modification timestamp (seconds)

#### B. Double Chance (t=27 - createDoubleChanceTable)
* `Data.oddsList[].odds.u`: 1X odds (Home Win or Draw)
* `Data.oddsList[].odds.g`: 12 odds (Home Win or Away Win)
* `Data.oddsList[].odds.d`: X2 odds (Draw or Away Win)
* `Data.oddsList[].mt`: Modification timestamp (seconds)

#### C. Correct Score / BoDan (t=25 - createBodanTable)
* `Data.oddsList[].odds.h1` to `h10`: Home scoreline odds (1:0, 2:0, 2:1, 3:0, 3:1, 3:2, 4:0, 4:1, 4:2, 4:3)
* `Data.oddsList[].odds.d1` to `d5`, `o`: Draw scoreline odds (0:0, 1:1, 2:2, 3:3, 4:4, Other)
* `Data.oddsList[].odds.g1` to `g10`: Away scoreline odds (0:1, 0:2, 1:2, 0:3, 1:3, 2:3, 0:4, 1:4, 2:4, 3:4)
* `Data.oddsList[].time`: Modification timestamp (seconds)

---

## 4. Odds Triplet (odds.u, odds.g, odds.d) Value Mapping

| Market Key | Market Name | odds.u | odds.g | odds.d |
| :--- | :--- | :--- | :--- | :--- |
| `ah` | Asian Handicap | Home Odds | Handicap Line (Spread) | Away Odds |
| `op` | 1X2 (European Odds) | Home Win (HW) | Draw (D) | Away Win (AW) |
| `ou` | Over / Under (Goals) | Over Odds | Goal Line Total | Under Odds |
| `corner` | Corners Over / Under | Corner Over Odds | Corner Target Line | Corner Under Odds |
| `eh` | Euro Handicap | Home Win | Handicap Spread (h) / Draw (g) | Away Win |
| `double` | Double Chance | 1X (Home / Draw) | 12 (Home / Away) | X2 (Draw / Away) |