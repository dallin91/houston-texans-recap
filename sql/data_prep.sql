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
SELECT game_id, season_type,
passing_epa, passing_cpoe, passing_tds, passing_interceptions, sacks_suffered, passing_yards,
carries, rushing_yards, rushing_tds, rushing_epa,
receiving_epa, receiving_yards,
def_sacks, def_interceptions, def_tackles_for_loss, def_qb_hits, def_pass_defended,
fumbles_lost_total, penalties, penalty_yards, timeouts
FROM team_stats;