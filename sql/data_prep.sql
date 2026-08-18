-- Run this after loading data to Postgres via get_texans_data.py and load_data.py

DROP VIEW IF EXISTS texans_results;
-- Creates a view containing Texans games and results, along with interesting data
CREATE VIEW texans_results
AS
SELECT game_id, season, game_type, week, gameday, weekday, 
CASE
WHEN (away_team = 'HOU' AND away_score > home_score) OR (home_team = 'HOU' AND home_score > away_score) THEN 'win'
WHEN (away_team = 'HOU' AND away_score < home_score) OR (home_team = 'HOU' AND home_score < away_score) THEN 'loss'
ELSE 'tie'
END AS result,
CASE 
WHEN away_team = 'HOU' THEN away_score
WHEN home_team = 'HOU' THEN home_score
END AS texans_score,
CASE
WHEN away_team != 'HOU' THEN away_score
WHEN home_team != 'HOU' THEN home_score
END AS opp_score, 
CASE
WHEN home_team = 'HOU' THEN away_team
ELSE home_team
END AS opponent,
CASE
WHEN home_team = 'HOU' THEN 1
ELSE 0
END AS home_game,
div_game, roof, surface, temp, wind
FROM schedule_stats
WHERE away_score IS NOT NULL
ORDER BY gameday;


DROP VIEW IF EXISTS texans_player_stats;

CREATE VIEW texans_player_stats
AS
SELECT player_id, player_display_name AS player_name, position, game_id,
completions, attempts, passing_epa, passing_cpoe, passing_yards, passing_tds, passing_interceptions, sacks_suffered, pacr,
carries, rushing_yards, rushing_epa, rushing_tds, rushing_fumbles,
receptions, targets, receiving_yards, receiving_epa, target_share, wopr,
def_sacks, def_interceptions, def_tackles_for_loss, def_qb_hits, def_pass_defended, def_fumbles
FROM player_stats;


DROP VIEW IF EXISTS texans_team_stats;

CREATE VIEW texans_team_stats
AS
SELECT game_id, season, team, season_type,
passing_epa, passing_cpoe, passing_tds, passing_interceptions, sacks_suffered, passing_yards,
carries, rushing_yards, rushing_tds, rushing_epa,
receiving_epa, receiving_yards,
def_sacks, def_interceptions, def_tackles_for_loss, def_qb_hits, def_pass_defended,
fumble_recovery_opp, fumbles_lost_total, penalties, penalty_yards, timeouts
FROM team_stats
WHERE team = 'HOU';


DROP VIEW IF EXISTS texans_turnover_margin;

CREATE VIEW texans_turnover_margin 
AS
SELECT
    season,
    SUM(def_interceptions + fumble_recovery_opp) AS takeaways,
    SUM(passing_interceptions + fumbles_lost_total) AS giveaways,
    SUM(def_interceptions + fumble_recovery_opp) - SUM(passing_interceptions + fumbles_lost_total) AS turnover_margin
FROM texans_team_stats
GROUP BY season
ORDER BY season;


DROP VIEW IF EXISTS texans_redzone_stats;

CREATE VIEW texans_redzone_stats 
AS
WITH offense_trips AS (
    SELECT
        game_id,
        season,
        drive,
        MAX(touchdown) AS scored_touchdown
    FROM pbp_stats
    WHERE yardline_100 <= 20
      AND posteam = 'HOU'
    GROUP BY game_id, season, drive
),
defense_trips AS (
    SELECT
        game_id,
        season,
        drive,
        MAX(touchdown) AS allowed_touchdown
    FROM pbp_stats
    WHERE yardline_100 <= 20
      AND defteam = 'HOU'
    GROUP BY game_id, season, drive
),
offense_summary AS (
    SELECT
        season,
        COUNT(*) AS redzone_trips,
        SUM(scored_touchdown) AS redzone_tds,
        ROUND(SUM(scored_touchdown)::numeric / COUNT(*), 3) AS redzone_td_pct
    FROM offense_trips
    GROUP BY season
),
defense_summary AS (
    SELECT
        season,
        COUNT(*) AS redzone_trips_allowed,
        SUM(allowed_touchdown) AS redzone_tds_allowed,
        ROUND(SUM(allowed_touchdown)::numeric / COUNT(*), 3) AS redzone_td_pct_allowed
    FROM defense_trips
    GROUP BY season
)
SELECT
    o.season,
    o.redzone_trips, o.redzone_tds, o.redzone_td_pct,
    d.redzone_trips_allowed, d.redzone_tds_allowed, d.redzone_td_pct_allowed,
    ROUND(o.redzone_td_pct - d.redzone_td_pct_allowed, 3) AS redzone_td_pct_differential
FROM offense_summary o
JOIN defense_summary d ON o.season = d.season
ORDER BY o.season;


DROP VIEW IF EXISTS texans_epa_allowed;

CREATE VIEW texans_epa_allowed 
AS
WITH offense_epa AS (
    SELECT
        season,
        AVG(epa) AS avg_offensive_epa
    FROM pbp_stats
    WHERE (pass_attempt = 1 OR rush_attempt = 1) AND posteam = 'HOU'
    GROUP BY season
),
defense_epa AS (
    SELECT
        season,
        AVG(epa) AS avg_defensive_epa
    FROM pbp_stats
    WHERE (pass_attempt = 1 OR rush_attempt = 1) AND defteam = 'HOU'
    GROUP BY season
)
SELECT
    o.season,
    ROUND(o.avg_offensive_epa::numeric, 3) AS avg_offensive_epa,
    ROUND(d.avg_defensive_epa::numeric, 3) AS avg_defensive_epa,
    ROUND((o.avg_offensive_epa - d.avg_defensive_epa)::numeric, 3) AS epa_differential
FROM offense_epa o
JOIN defense_epa d ON o.season = d.season
ORDER BY o.season;