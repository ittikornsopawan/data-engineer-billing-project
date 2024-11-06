import time
import csv
import gzip
import os
import random

from datetime import datetime, timedelta
from decimal import Decimal
import shutil
from app.common.dbContext import dbContext
from app.common.minioClient import minioClient
from app.common.processUtil import processUtil

def getCurrentPeriod():
    currentDate = datetime.now()
    currentPeriod = f"{currentDate.year}_{currentDate.month:02}"

    return currentPeriod

# function: project-1
def downloadFiles(minio = minioClient()):
    listFile = minio.list_files()

    downloadDir = "downloads"
    
    if not os.path.exists(downloadDir):
        os.makedirs(downloadDir)
        print(f"Download directory created: {downloadDir}")

    gz_file_paths = []
    for file in listFile:
        downloadPath = os.path.join(downloadDir, file)
        print(f"Downloading {file} to {downloadPath}")
        minio.download_file(file, downloadPath)
        gz_file_paths.append(downloadPath)
    
    return gz_file_paths

def unzipCsvGz(gzFilePath, outputFilePath):
    """Unzips a .csv.gz file to a specified output path."""
    try:
        with gzip.open(gzFilePath, 'rb') as gzGile:
            with open(outputFilePath, 'wb') as outFile:
                shutil.copyfileobj(gzGile, outFile)
        print(f"Successfully unzipped '{gzFilePath}' to '{outputFilePath}'")
    except Exception as e:
        print(f"Error unzipping file '{gzFilePath}': {e}")

def getTablePeriod(db=dbContext(), period=None,isClose = False):
    try:
        if period == None:
            period = getCurrentPeriod()

        print(f"results: {period}")

        query = f"""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_name LIKE '%{period}%'
            AND table_schema = 'public'
        """

        result = db.executeQuery(query=query)

        return result
    except Exception as e:
        print(f"Error getTablePeriod: {getTablePeriod}")
    finally:
        if isClose == True:
            db.close()

def etlProject1(db=dbContext(), isClose = False):
    print("Start etlProject1")

    try:
        tables = getTablePeriod(db=db)
        
        if tables != None and len(tables) > 0:
            for table in tables:
                print(f"result: {table[0]}")

                query = f"""
                    select * from public.{table[0]}
                """

                results = db.executeQuery(query)

                print(f"results: {results}")
    except Exception as e:
        print(f"Error etlProject1: {e}")
    finally:
        if isClose == True:
            db.close()

# process
def processProject1():
    print(f"Start processProject1")

    try:
        db = dbContext()
        minio = minioClient()
        process = processUtil()

        filePaths = downloadFiles(minio)

        csvFilePath = []
        if len(filePaths) > 0:
            for file in filePaths:
                if file.endswith('.gz'):
                    outputFilePath = file[:-3]
                    unzipCsvGz(file, outputFilePath)
                    os.remove(file)

                    csvFilePath.append(outputFilePath)

        process.push_csv_to_db(csvFilePaths=csvFilePath)
        
        etlProject1()
    except Exception as e:
        print(f"Error main: {e}")
    finally:
        db.close()
        print(f"End processProject1")

def main():
    processProject1()

if __name__ == "__main__":

    # print(f"Starting ETL process with a delay of {30} seconds to ensure dependencies are ready.")
    # time.sleep(30)

    main()