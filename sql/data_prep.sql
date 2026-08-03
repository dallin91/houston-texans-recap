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