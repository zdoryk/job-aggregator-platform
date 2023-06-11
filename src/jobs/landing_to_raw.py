import asyncio
import pandas as pd
import aiohttp
import time
from prefect import task, flow
import boto3
from prefect_aws import AwsCredentials
from datetime import datetime

aws_credentials_block = AwsCredentials.load("get-aws-creds")


async def fetch(session, url):
    async with session.get(url) as response:
        return await response.json()


@task
def get_xml_from_s3(today: str) -> pd.DataFrame:
    s3_client = aws_credentials_block.get_boto3_session().client('s3')
    xml = s3_client.get_object(Bucket='job-parse-landing', Key=f'just_join/{today}.xml')
    return pd.read_xml(xml['Body'].read())[9:]['id']


@task
async def get_data_about_each_offer(df: pd.DataFrame) -> list:
    async with aiohttp.ClientSession() as session:
        tasks = []
        for i in [f'https://justjoin.it/api/{x.split("https://justjoin.it/")[1]}' for x in df.tolist()]:
            tasks.append(asyncio.ensure_future(fetch(session, i)))

        responses = await asyncio.gather(*tasks)
        return responses


@task
def process_responses(filename: str, responses: list) -> None:
    df = pd.DataFrame(responses)
    pd.set_option('display.max_columns', None)
    new_df = df[['title', 'city', 'country_code', 'workplace_type', 'company_name', 'company_size', 'experience_level',
                 'published_at', 'remote_interview', 'body', 'skills', 'remote', 'employment_types', 'marker_icon']]
    new_df.to_csv(filename, index=False)


@task
def upload_file_to_s3(file_name: str, bucket_name: str) -> None:
    s3_client = aws_credentials_block.get_boto3_session().client('s3')
    s3_client.upload_file(file_name, bucket_name, f'just_join/{file_name}')


@flow(name='landing_to_raw')
def landing_to_raw():
    today = datetime.today().strftime('%d_%m_%Y')
    new_filename = f'{today}.csv'

    job_offers_df = get_xml_from_s3(today=today)
    read_xml = get_data_about_each_offer(job_offers_df)
    process_responses(filename=new_filename, responses=read_xml)
    upload_file_to_s3(file_name=new_filename, bucket_name='job-parse-raw')


if __name__ == '__main__':
    start = time.time()
    landing_to_raw()
    end = time.time()
    print(end - start)
