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

# Update the ETL function
def etlProject1(db=dbContext(), isClose=False):
    print("Starting ETL process for Project 1")
    
    try:
        # Retrieve table periods
        tables = getTablePeriod(db=db)
        
        if tables:
            for table in tables:
                table_name = table[0]
                print(f"Processing table: {table_name}")

                # Define query to aggregate data by period
                query = f"""
                            SELECT 
                                CONCAT(
                                    EXTRACT(YEAR FROM TO_TIMESTAMP(SPLIT_PART(time_interval, '/', 1), 'YYYY-MM-DD'))::TEXT,
                                    '_',
                                    LPAD(EXTRACT(MONTH FROM TO_TIMESTAMP(SPLIT_PART(time_interval, '/', 1), 'YYYY-MM-DD'))::TEXT, 2, '0')
                                ) AS period,
                                payer_account_id,
                                payer_account_name,
                                usage_account_id,
                                usage_account_name,
                                COALESCE(sum(CASE WHEN billing_entity = 'AWS' AND line_item_type = 'Usage' THEN unblended_cost END), 0) AS total_usage_cost,
                                COALESCE(sum(CASE WHEN billing_entity = 'AWS' AND line_item_type = 'Tax' THEN unblended_cost END), 0) AS total_tax,
                                COALESCE(sum(CASE WHEN billing_entity = 'AWS' AND line_item_type IN ('Edp Discount', 'Spp Discount') THEN unblended_cost END), 0) AS total_discount_program,
                                COALESCE(sum(CASE WHEN billing_entity = 'AWS' AND line_item_type = 'Usage' THEN unblended_cost END), 0) 
                                + COALESCE(sum(CASE WHEN billing_entity = 'AWS' AND line_item_type IN ('Edp Discount', 'Spp Discount') THEN unblended_cost END), 0) 
                                + COALESCE(sum(CASE WHEN billing_entity = 'AWS' AND line_item_type = 'Tax' THEN unblended_cost END), 0) AS total_discounted_cost,
                                COALESCE(sum(CASE WHEN billing_entity = 'AWS Marketplace' THEN unblended_cost END), 0) AS total_marketplace,
                                COALESCE(sum(unblended_cost), 0) AS total_cost,
                                COALESCE(sum(CASE WHEN billing_entity = 'AWS' AND line_item_type = 'Usage' THEN unblended_cost END), 0) 
                                + COALESCE(sum(CASE WHEN billing_entity = 'AWS' AND line_item_type IN ('Edp Discount', 'Spp Discount') THEN unblended_cost END), 0)
                                + COALESCE(sum(CASE WHEN billing_entity = 'AWS' AND line_item_type = 'Tax' THEN unblended_cost END), 0)
                                + COALESCE(sum(CASE WHEN billing_entity = 'AWS Marketplace' THEN unblended_cost END), 0) AS total_expenditure,
                                current_timestamp::DATE AS created_date
                            FROM public.{table_name}   
                            GROUP BY 
                                payer_account_id,
                                payer_account_name,
                                usage_account_id,
                                usage_account_name,
                                time_interval
                            ORDER BY usage_account_id;
                """

                results = db.executeQuery(query)

                if results:
                    insert_query = """
                        INSERT INTO t_billing (
                            period, payer_account_id, payer_account_name, usage_account_id, 
                            usage_account_name, total_usage_cost, total_tax, total_discount_program, 
                            total_discounted_cost, total_marketplace, total_cost, total_expenditure, 
                            created_date, created_by
                        ) VALUES (
                            %(period)s, %(payer_account_id)s, %(payer_account_name)s, %(usage_account_id)s, 
                            %(usage_account_name)s, %(total_usage_cost)s, %(total_tax)s, 
                            %(total_discount_program)s, %(total_discounted_cost)s, %(total_marketplace)s, 
                            %(total_cost)s, %(total_expenditure)s, %(created_date)s, 'system'
                        )
                        ON CONFLICT (usage_account_id, period, created_date) 
                        DO UPDATE SET
                            total_usage_cost = EXCLUDED.total_usage_cost,
                            total_tax = EXCLUDED.total_tax,
                            total_discount_program = EXCLUDED.total_discount_program,
                            total_discounted_cost = EXCLUDED.total_discounted_cost,
                            total_marketplace = EXCLUDED.total_marketplace,
                            total_cost = EXCLUDED.total_cost,
                            total_expenditure = EXCLUDED.total_expenditure;
                    """

                    try:
                        for row in results:
                            db.executeNonQuery(insert_query, {
                                'period': row[0],
                                'payer_account_id': row[1],
                                'payer_account_name': row[2],
                                'usage_account_id': row[3],
                                'usage_account_name': row[4],
                                'total_usage_cost': row[5],
                                'total_tax': row[6],
                                'total_discount_program': row[7],
                                'total_discounted_cost': row[8],
                                'total_marketplace': row[9],
                                'total_cost': row[10],
                                'total_expenditure': row[11],
                                'created_date': row[12]
                            })
                            
                        print(f"Data successfully inserted for table {table_name}")

                    except Exception as e:
                        print(f"Error inserting data for table {table_name}: {e}")
                        raise
                else:
                    print(f"No data found for table {table_name}")
                    
    except Exception as e:
        print(f"Error in ETL process for Project 1: {e}")
    finally:
        # Close the connection if necessary
        if isClose:
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

    print(f"Starting ETL process with a delay of {10} seconds to ensure dependencies are ready.")
    time.sleep(10)

    main()