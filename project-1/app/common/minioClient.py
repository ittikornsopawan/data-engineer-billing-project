import os
import time
from minio import Minio
from minio.error import S3Error

class minioClient:
    def __init__(self):
        self.endpoint = os.getenv("MINIO_ENDPOINT", "http://minio:9000")
        self.access_key = os.getenv("MINIO_ACCESS_KEY", "minio")
        self.secret_key = os.getenv("MINIO_SECRET_KEY", "minio123")
        self.bucket_name = os.getenv("MINIO_BUCKET_NAME", "project-1-bucket")

        self.client = Minio(
            self.endpoint,
            access_key=self.access_key,
            secret_key=self.secret_key,
            secure=False
        )

        self.ensure_bucket_exists()

    def ensure_bucket_exists(self):
        print("Start ensure_bucket_exists")
        try:
            if not self.client.bucket_exists(self.bucket_name):
                self.client.make_bucket(self.bucket_name)
                print(f"Bucket '{self.bucket_name}' created.")
            else:
                print(f"Bucket '{self.bucket_name}' already exists.")
        except S3Error as e:
            print(f"Error ensuring bucket exists: {e}")
        finally:
            print("End ensure_bucket_exists")


    def upload_file(self, file_path, object_name):
        print("Start: upload_file")
        try:
            self.client.fput_object(self.bucket_name, object_name, file_path)
            print(f"File '{file_path}' uploaded as '{object_name}'.")
        except S3Error as e:
            print(f"Error uploading file: {e}")
        finally:
            print("End: upload_file")