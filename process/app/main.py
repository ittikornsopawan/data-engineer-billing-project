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

# function: project-1
def download_files(minio = minioClient()):
    listFile = minio.list_files()

    download_dir = "downloads"
    
    if not os.path.exists(download_dir):
        os.makedirs(download_dir)
        print(f"Download directory created: {download_dir}")

    gz_file_paths = []
    for file in listFile:
        download_path = os.path.join(download_dir, file)
        print(f"Downloading {file} to {download_path}")
        minio.download_file(file, download_path)
        gz_file_paths.append(download_path)
    
    return gz_file_paths

def unzip_csv_gz(gz_file_path, output_file_path):
    """Unzips a .csv.gz file to a specified output path."""
    try:
        with gzip.open(gz_file_path, 'rb') as gz_file:
            with open(output_file_path, 'wb') as out_file:
                shutil.copyfileobj(gz_file, out_file)
        print(f"Successfully unzipped '{gz_file_path}' to '{output_file_path}'")
    except Exception as e:
        print(f"Error unzipping file '{gz_file_path}': {e}")

# process
def project1_process():
    print(f"Start project1_process")

    try:
        db = dbContext()
        minio = minioClient()
        process = processUtil()

        filePaths = download_files(minio)

        csvFilePath = []
        if len(filePaths) > 0:
            for file in filePaths:
                if file.endswith('.gz'):
                    output_file_path = file[:-3]
                    unzip_csv_gz(file, output_file_path)
                    os.remove(file)

                    csvFilePath.append(output_file_path)

        process.push_csv_to_db(csv_file_paths=csvFilePath)
    except Exception as e:
        print(f"Error main: {e}")
    finally:
        db.close()
        print(f"End project1_process")


def main():
    project1_process()

if __name__ == "__main__":
    main()
