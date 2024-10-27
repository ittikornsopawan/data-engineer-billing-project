# app/common/dbContext.py

import psycopg2
from psycopg2 import OperationalError
from app.config.config import DB_USERNAME, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME
from app.common.dbObject import convert_to_object
import time

class dbContext:
    def __init__(self):
        self.connection = None
        self.cursor = None
        self.connect()

    def connect(self):
        """Establish a connection to the database with retry mechanism."""
        attempts = 5
        for attempt in range(1, attempts + 1):
            try:
                self.connection = psycopg2.connect(
                    dbname=DB_NAME,
                    user=DB_USERNAME,
                    password=DB_PASSWORD,
                    host=DB_HOST,
                    port=DB_PORT
                )
                self.cursor = self.connection.cursor()
                print("Connection to the database was successful.")
                return  # Exit the loop if connection is successful
            except OperationalError as e:
                print(f"Attempt {attempt} failed: {e}. Retrying in 3 seconds...")
                time.sleep(3)  # Delay before retrying
        print("Failed to connect to the database after multiple attempts.")

    def execute_query(self, query, params=None):
        """Execute a SELECT query and return the results as objects."""
        self.check_connection()  # Ensure the connection is alive
        if params:
            self.cursor.execute(query, params)
        else:
            self.cursor.execute(query)

        # Convert to object-like rows
        rows = self.cursor.fetchall()

        # Check if data exists
        if not rows:
            print("No data found.")
            return None

        # Convert to object-like rows if data exists
        return convert_to_object(rows, self.cursor)
    
    def execute_non_query(self, query, params=None):
        """Execute a non-SELECT query without expecting a response."""
        try:
            self.check_connection()
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
                
            self.connection.commit()
        except Exception as e:
            print(f"Error executing query: {query}")
            print(f"Params: {params}")
            print(e)

    def get_column_names(self, query, params=None):
        """Get column names from a given SQL query."""
        self.check_connection()
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)

            column_names = [desc[0] for desc in self.cursor.description]
            return column_names
        except Exception as e:
            print(f"Error getting column names: {e}")
            return None

    def check_connection(self):
        """Check if the connection is still alive."""
        if self.connection is None or self.cursor is None:
            self.connect()
        else:
            try:
                # Attempt to execute a simple query to check connection
                self.cursor.execute("SELECT 1")
            except (psycopg2.OperationalError, psycopg2.InterfaceError):
                print("Connection lost, reconnecting...")
                self.connect()

    def close(self):
        """Close the cursor and connection."""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
        print("Database connection closed.")

    def begin_transaction(self):
        """Begin a transaction."""
        self.check_connection()
        self.connection.autocommit = False

    def commit_transaction(self):
        """Commit the transaction if successful."""
        try:
            self.connection.commit()
            print("Transaction committed successfully.")
        except Exception as e:
            print(f"Commit failed: {e}")
            self.rollback_transaction()
            raise