# Nowgoal Data Exploration & ETL Pipeline

An end-to-end data exploration, schema reverse-engineering, and SQL extraction pipeline for **Nowgoal** football (soccer) datasets using **DuckDB** and **Python**.

---

## 📁 Project Structure

```
nowgoal-explore/
│
├── html/                           # Raw HTML page templates fetched from Nowgoal
│   ├── match_detail_source.html    # Live match center UI template
│   ├── match_odd_source.html       # Live odds comparison UI template
│   ├── player_info_source.html     # Player profile UI template
│   ├── player_season_tech_source.html # Tournament technical statistics UI template
│   ├── season_detail_source.html   # Tournament/Season summary UI template
│   └── team_detail_source.html     # Club/Team profile UI template
│
├── json/                           # Scraped / AJAX API response payloads
│   ├── general_events.json         # Match incidents and event timeline
│   ├── match_odds_3in1.json        # 3-in-1 market trends (AH, 1X2, Over/Under)
│   ├── match_odds_corners.json     # Live corner line and Over/Under trends
│   ├── match_odds_doubleschance.json # Double chance odds history
│   ├── match_odds_eurohandicap.json  # Euro handicap odds history
│   ├── player_info.json            # Player biodata and career transfers
│   ├── player_match_tech.json      # Single-match player technical stats
│   ├── player_season_tech.json     # Tournament aggregate player stats (57 metrics)
│   ├── season_detail.json          # Tournament schedule, standings & matrices
│   ├── team_detail.json            # Club roster, cup stats & honors
│   └── team_transfer_by_year.json  # Club transfer history by season
│
├── md/                             # Data schema definitions & index specifications
│   ├── match_odd_documentation.md  # Odds API parameter mapping & payload specs
│   ├── player_info_documentation.md # Player JSON schema and positional lookups
│   ├── player_match_tech_documentation.md # Match technical metrics & event codes
│   ├── player_sesason_tech_documentation.md # 57 season metric array index mapping
│   ├── season_detail_documentation.md # Season stage, fixture & standings schema
│   └── team_detail_documentation.md # Team profile, lineup & honor array schemas
│
├── sql/                            # DuckDB SQL extraction scripts (Views)
│   ├── match_odds_3in1_extract.sql # 3-in-1 live odds transformation views
│   ├── match_odds_corners_extract.sql # Corner odds and running count views
│   ├── match_odds_doubleschance_extract.sql # Double chance odds views
│   ├── match_odds_eurohandicap_extract.sql # Euro handicap odds views
│   ├── player_info_extract.sql     # Player profile & career history views
│   ├── player_match_tech_extract.sql # Single-match player stats & events views
│   ├── player_season_tech_extract.sql # 57 season performance metric views
│   ├── season_detail_extract.sql   # Standings, fixtures, matrices & goal stats views
│   └── team_detail_extract.sql     # Roster, characteristics, matches & honors views
│
├── general.py                      # Python HTTP scraper script
├── general_duckdb.py               # DuckDB quick runner & test script
├── general_duckdb.ipynb            # Interactive Jupyter Notebook for exploratory queries
├── requirement.txt                 # Python dependencies
├── .gitignore                      # Git ignore rules
└── README.md                       # Project overview and documentation
```

---

## 📂 Folder & File Purpose

### 1. `html/` (Source Web Templates)
Contains raw HTML page sources downloaded from Nowgoal. These files serve as reference templates to understand UI data bindings, element selectors, and DOM structures.

### 2. `json/` (Raw Data Payloads)
Contains API JSON payloads captured from AJAX endpoints (e.g. `soccerajax`, `GetTeamTransferByYear`, `tdl{id}_en.json`).

### 3. `md/` (Data Dictionary & Schema Docs)
Documentation files detailing exact array index mappings (0-based vs 1-based), data types, nested structure definitions, and frontend UI mappings.

### 4. `sql/` (DuckDB Extraction Scripts)
SQL view definitions designed for **DuckDB**. These scripts parse nested arrays, JSON keys, and string-delimited fields into clean, relational database views.

| SQL Script | Domain / Description |
| :--- | :--- |
| `player_info_extract.sql` | Basic player info, transfer history, and cumulative career statistics. |
| `player_season_tech_extract.sql` | 57 granular metrics (xG, xA, xGOT, passes, tackles, duels) split by Total/Home/Away. |
| `player_match_tech_extract.sql` | Single-match player stats, substitution timing, in-game events, and team totals. |
| `season_detail_extract.sql` | League info, stage rounds, fixtures, standings, half/full-time matrix, and goal distributions. |
| `team_detail_extract.sql` | Team metadata, squad positional groups, tournament stats, match logs, and characteristics. |
| `match_odds_3in1_extract.sql` | Live odds change history for Asian Handicap, 1X2 European odds, and Over/Under. |
| `match_odds_corners_extract.sql` | Live corner Over/Under trends and running corner counts. |
| `match_odds_doubleschance_extract.sql` | Double Chance odds history (1X, 12, X2). |
| `match_odds_eurohandicap_extract.sql` | Euro Handicap spread and price changes. |

### 5. Core Scripts & Notebooks
- **`general.py`**: Requests-based fetching script with custom headers and session simulation.
- **`general_duckdb.py`**: Helper script to initialize an in-memory DuckDB connection and run extraction views.
- **`general_duckdb.ipynb`**: Interactive notebook for exploring queries, validating views, and running analytical benchmarks.
- **`requirement.txt`**: List of Python requirements (`duckdb`, `requests`, etc.).

---

## 🚀 Quickstart & Usage

### 1. Install Dependencies
```bash
pip install -r requirement.txt
```

### 2. Run SQL Extraction in Python
```python
import duckdb

con = duckdb.connect()

# Load and execute any SQL extraction script
with open('sql/player_season_tech_extract.sql', 'r', encoding='utf-8') as f:
    sql_script = f.read()

for stmt in sql_script.split(';'):
    if stmt.strip():
        con.sql(stmt)

# Query the extracted views
con.sql("""
    SELECT player_name, team_name, total_goals, assists, xg, avg_rating
    FROM v_player_season_tech_full
    WHERE venue_scope = 'Total'
    ORDER BY total_goals DESC
    LIMIT 5
""").show()
```
