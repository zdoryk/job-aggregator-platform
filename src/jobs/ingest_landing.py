import csv
import requests
import boto3
from datetime import datetime
from prefect import task, flow
from prefect_aws import AwsCredentials

aws_credentials_block = AwsCredentials.load("get-aws-creds")


@task
def upload_file_to_s3(file_name: str, bucket_name: str) -> None:
    s3_client = aws_credentials_block.get_boto3_session().client('s3')
    today = datetime.today().strftime('%d_%m_%Y')
    s3_client.upload_file(file_name, bucket_name, f'just_join/{today}.xml')


@flow(name='ingest_landing')
def ingest_landing():
    url = "https://justjoin.it/feed.atom"
    response = requests.get(url=url)

    with open('test.xml', 'w', encoding='utf-8') as file:
        file.write(response.text)
    upload_file_to_s3(file_name='test.xml', bucket_name='job-parse-landing')


if __name__ == '__main__':
    ingest_landing()
