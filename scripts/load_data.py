import pandas as pd
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

load_dotenv()

DB_NAME = os.getenv('DB_NAME')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_PORT = os.getenv('DB_PORT')
DB_HOST = os.getenv('DB_HOST')

engine = create_engine(f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}')

# Prep player and team data to be exported to Postgres
player_df = pd.read_csv("./data/raw/hou_player_stats.csv")
player_df.columns = player_df.columns.str.strip().str.lower().str.replace(' ', '_')

team_df = pd.read_csv("./data/raw/team_stats.csv")
team_df.columns = team_df.columns.str.strip().str.lower().str.replace(' ', '_')

schedule_df = pd.read_csv("./data/raw/hou_schedules.csv")
schedule_df.columns = schedule_df.columns.str.strip().str.lower().str.replace(' ', '_')

pbp_df = pd.read_csv("./data/raw/hou_pbp.csv")
pbp_df.columns = pbp_df.columns.str.strip().str.lower().str.replace(' ', '_')

# Load data to database
player_df.to_sql('player_stats', engine, if_exists='delete_rows', index=False)
team_df.to_sql('team_stats', engine, if_exists='delete_rows', index=False)
schedule_df.to_sql('schedule_stats', engine, if_exists='delete_rows', index=False)
pbp_df.to_sql('pbp_stats', engine, if_exists='delete_rows', index=False)