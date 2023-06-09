import csv
import requests
import boto3


def get_aws_credentials() -> tuple:
    with open('my_keys.csv', 'r') as input_file:
        reader = csv.reader(input_file)
        next(reader)  # skip first line (header)
        line = next(reader)  # read the next line
        access_key_id = line[0]
        secret_access_key = line[1]
    return access_key_id, secret_access_key


def upload_file_to_s3(file_name: str, bucket_name: str) -> None:
    access_key_id, secret_access_key = get_aws_credentials()
    s3_client = boto3.client('s3', aws_access_key_id=access_key_id, aws_secret_access_key=secret_access_key)
    s3_client.upload_file(file_name, bucket_name, 'feed.xml')


if __name__ == '__main__':
    url = "https://justjoin.it/feed.atom"
    response = requests.get(url=url)

    with open('test.xml', 'w', encoding='utf-8') as file:
        file.write(response.text)

    upload_file_to_s3(file_name='test.xml', bucket_name='job-parse-landing')