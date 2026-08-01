"""
The purpose of this script is to pull all game and player data for the Houston Texans from 2002-2025.
This data will be exported to .csv files in /data/raw
"""

import nflreadpy as nfl
import polars as pl

# Pull and write Houston Texans game data to CSV
team_stats = nfl.load_team_stats(seasons=True)
hou_stats = team_stats.filter(pl.col("team") == "HOU")
hou_stats.write_csv("./data/raw/hou_stats.csv")

# Pull and write Texans player stats to CSV
player_stats = nfl.load_player_stats([2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025])
hou_player_stats = player_stats.filter(pl.col("team") == "HOU")
hou_player_stats.write_csv("./data/raw/hou_player_stats.csv")

# Pull and write Texans schedule data to CSV
schedules = nfl.load_schedules()
hou_schedules = schedules.filter((pl.col("home_team") == "HOU") | (pl.col("away_team") == "HOU"))
hou_schedules.write_csv("./data/raw/hou_schedules.csv")