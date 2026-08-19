<h1 align="center">Houston Texans Recap</h1>
<p align="center">
  <em>A statistical deep-dive into 24 seasons of Houston Texans football (2002–2025)</em>
</p>

<p align="center">
  <img alt="Status" src="https://img.shields.io/badge/status-in%20progress-yellow">
  <img alt="Data" src="https://img.shields.io/badge/data-nflreadpy-blue">
  <img alt="DB" src="https://img.shields.io/badge/database-PostgreSQL-336791">
  <img alt="Dashboard" src="https://img.shields.io/badge/dashboard-Power%20BI-F2C811">
</p>

---

## Overview

This project analyzes every Houston Texans season since the franchise's founding in 2002, using play-by-play and team/player-week data to answer two questions:

<table>
<tr>
<td width="50%" valign="top">

### RQ1 — Common Threads
What separates the Texans' successful seasons from their unsuccessful ones? Specifically: does turnover margin, red zone efficiency, or EPA differential track most closely with wins and playoff appearances?

</td>
<td width="50%" valign="top">

### RQ2 — Stroud Benchmark
What kind of season does CJ Stroud need to have for the Texans to contend, benchmarked against quarterbacks on other contending teams?

</td>
</tr>
</table>

The project targets two deliverables: an interactive **Power BI dashboard** and this **README**.

---

## Data Pipeline

```
nflreadpy  →  CSV (data/raw/)  →  PostgreSQL (load_data.py)  →  SQL views (data_prep.sql)
```

- **Source:** [`nflreadpy`](https://github.com/nflverse/nflreadpy) — `nfl.load_pbp()` (2002–2025, filtered to HOU games) and `load_schedules()` for game results/playoff labeling
- **Storage:** PostgreSQL, loaded via `load_data.py`
- **Derived views:** defined in `data_prep.sql`

<details>
<summary><strong>SQL views reference</strong> (click to expand)</summary>

| View | Grain | Purpose |
|---|---|---|
| `texans_results` | game | Win/loss, playoff game type, opponent, home/away |
| `texans_player_stats` | player-game | Player-level passing/rushing/receiving/defense stats |
| `texans_team_stats` | team-game | Team-level offense/defense stats (HOU only) |
| `texans_turnover_margin` | season | Takeaways − giveaways |
| `texans_redzone_stats` | season | Red zone trips and TD rate, offense and defense |
| `texans_epa_allowed` | season | Offensive/defensive EPA per play, computed directly from play-by-play |
| `texans_season_summary` | season | Combines the above: win %, playoff flag, turnover margin, red zone differential, EPA differential |

</details>

---

## Findings

> **Status:** Research Question 1 complete · Research Question 2 in progress

### RQ1 — Common Threads Across Successful Seasons
*2002-2025*

- **EPA differential is the strongest single predictor of Texans success.** Correlation with win % is r = 0.89, the strongest relationship of any metric tested. This makes intuitive sense as EPA differential is essentially a data point that says "how much better was Houston than its opponents, play by play", but the strength of the metric makes it the highlight.

- **Turnover margin is a strong secondary predictor.** Correlation with win % is r = 0.70. The gap between playoff and non-playoff seasons is stark. Houston averaged a +7.0 turnover margin in playoff seasons vs a -4.6 turnover margin in non-playoff seasons.

- **Redzone TD-rate differential shows little relationship with winning,** both in correlation (r = 0.20) and in the playoff/non-playoff comparison (-0.035 vs -0.038). *Caveat: this metric measures touchdown rate specifically, not overall scoring rate inside the 20. A redzone trip that ends in a field goal counts the same as one that ends in a punt or turnover. It's possible another metric that credits FGs would show a different relationship. As measured here, redzone TD efficiency does not appear to distinguish good seasons from the bad.*

<details>
<summary><strong>Metric summary table</strong></summary>

| Metric | Correlation with win % | Playoff seasons (avg) | Non-playoff seasons (avg) |
|---|---|---|---|
| EPA differential | 0.890 | 0.059 | -0.078 |
| Turnover margin | 0.702 | +7.0 | -4.6 |
| Red zone TD% differential | 0.198 | -0.037 | -0.035 |

</details>

### RQ2 — CJ Stroud Benchmark
*Coming in Phase 4.*

- [ ] Define the "contending" comparison set (e.g., QBs on the last 5 years of playoff teams, or top-8 league-wide EPA/play by season)
- [ ] Build Stroud-vs-contenders comparison view
- [ ] Chart Stroud's career arc against the benchmark

---

## Project Roadmap

| Phase | Description | Status |
|---|---|---|
| 1 | Data foundation — PBP + league-wide pull into Postgres | Complete |
| 2 | Core metric views (red zone, EPA allowed, turnover margin) | Complete |
| 3 | Answer RQ1 — common threads across successful seasons | Complete |
| 4 | Answer RQ2 — CJ Stroud benchmarking | Not started |
| 5 | Cleanup, fix `passing_epa`/`receiving_epa` double-count, documentation | Not started |
| 6 | Power BI dashboard build | Not started |

<details>
<summary><strong>Known issues / technical debt</strong></summary>

- `texans_team_stats.passing_epa` and `receiving_epa` are near-duplicated at the team level and must **not** both be summed into a single DAX measure or Python aggregation. (Note: `texans_epa_allowed` is unaffected — it computes EPA directly from `pbp_stats`, not from `texans_team_stats`.)
- `texans_season_summary` uses inner joins across four views; any season missing from one of the PBP-derived views (redzone/EPA) will silently drop from the summary rather than erroring.

</details>

---

## Methodology Notes

- **Filtering play-by-play:** `play_type` string matching is unreliable for isolating real plays (`no_play` penalty rows still carry EPA values). Filters use the boolean flags `pass_attempt`, `rush_attempt`, and `qb_dropback` instead.
- **Views over tables:** derived metrics are built as SQL views rather than materialized tables, so they auto-refresh as new game data loads — row counts are small enough that on-the-fly scanning is trivial.
- **Playoff labeling:** sourced from `load_schedules()` via `game_type`; neither `hou_stats.csv` nor `hou_player_stats.csv` contains this information on their own.

---

## Repo Structure

```
houston-texans-recap/
├── data/
│   └── raw/                        # CSV exports from nflreadpy
├── get_texans_data.py              # Pulls data via nflreadpy
├── load_data.py                    # Loads CSVs into PostgreSQL
├── data_prep.sql                   # SQL views (data_prep layer)
├── research_q1_common_threads.ipynb   # RQ1 analysis notebook
├── research_q2_stroud_benchmark.ipynb # RQ2 analysis notebook (Phase 4)
├── initial_exploration.ipynb       # Early exploratory work
└── README.md
```

---

## How to Reproduce

```bash
git clone https://github.com/dallin91/houston-texans-recap
cd houston-texans-recap
pip install -r requirements.txt

# Pull raw data
python get_texans_data.py

# Load into Postgres
python load_data.py

# Build SQL views
psql -d your_database -f data_prep.sql
```

Then open `research_q1_common_threads.ipynb` (or the RQ2 equivalent) to reproduce the analysis.

---

<p align="center"><sub>Built with nflreadpy, PostgreSQL, pandas, and Power BI · Data current through the 2025 season</sub></p>