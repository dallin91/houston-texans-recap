

SELECT season, ROUND(AVG(texans_score)::numeric, 2) AS avg_texans_points, ROUND(AVG(opp_score)::numeric, 2) AS avg_opp_points
FROM texans_results
GROUP BY season
ORDER BY season;