import time
import os

import psycopg2
from psycopg2 import OperationalError
from app.common.dbObject import convertToObject

dbHost = os.getenv("DB_HOST")
dbUser = os.getenv("DB_USER")
dbPassword = os.getenv("DB_PASSWORD")
dbName = os.getenv("DB_NAME")

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
                    dbname=dbName,
                    user=dbUser,
                    password=dbPassword,
                    host=dbHost  
                )
                self.cursor = self.connection.cursor()
                print("Connection to the database was successful.")
                return  # Exit the loop if connection is successful
            except OperationalError as e:
                print(f"Attempt {attempt} failed: {e}. Retrying in 3 seconds...")
                time.sleep(3)  # Delay before retrying
        print("Failed to connect to the database after multiple attempts.")

    def executeQuery(self, query, params=None):
        """Execute a SELECT query and return the results as objects."""
        self.checkConnection()  # Ensure the connection is alive
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
        return convertToObject(rows, self.cursor)
    
    def executeNonQuery(self, query, params=None):
        """Execute a non-SELECT query without expecting a response."""
        try:
            self.checkConnection()
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
                
            self.connection.commit()
        except Exception as e:
            print(f"Error executing query: {query}")
            print(f"Params: {params}")
            print(e)

    def getColumnNames(self, query, params=None):
        """Get column names from a given SQL query."""
        self.checkConnection()
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)

            columnNames = [desc[0] for desc in self.cursor.description]
            return columnNames
        except Exception as e:
            print(f"Error getting column names: {e}")
            return None

    def checkConnection(self):
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

    def beginTransaction(self):
        """Begin a transaction."""
        self.checkConnection()
        self.connection.autocommit = False

    def commit_transaction(self):
        """Commit the transaction if successful."""
        try:
            self.connection.commit()
            print("Transaction committed successfully.")
        except Exception as e:
            print(f"Commit failed: {e}")
            self.rollbackTransaction()
            raise