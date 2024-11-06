import os
import pandas as pd
from sqlalchemy import create_engine

class processUtil:
    def __init__(self):
        self.db_host = os.getenv("DB_HOST")
        self.db_user = os.getenv("DB_USER")
        self.db_password = os.getenv("DB_PASSWORD")
        self.db_name = os.getenv("DB_NAME")

        if not all([self.db_host, self.db_user, self.db_password, self.db_name]):
            raise ValueError("Database configuration environment variables are not fully set")
        
        self.db_url = f"postgresql://{self.db_user}:{self.db_password}@{self.db_host}/{self.db_name}"

    def push_csv_to_db(self, csvFilePaths, if_exists='replace'):
        for csv_file_path in csvFilePaths:
            table_name = "t_" + os.path.splitext(os.path.basename(csv_file_path))[0].lower()
            
            try:
                df = pd.read_csv(csv_file_path)
            except Exception as e:
                print(f"Error reading CSV file '{csv_file_path}': {e}")
                continue

            try:
                engine = create_engine(self.db_url)
            except Exception as e:
                print(f"Error creating database engine: {e}")
                continue

            try:
                df.to_sql(table_name, engine, if_exists=if_exists, index=False)
                print(f"Data from '{csv_file_path}' successfully pushed to table '{table_name}'.")
            except Exception as e:
                print(f"Error pushing data from '{csv_file_path}' to database: {e}")

            os.remove(csv_file_path)
