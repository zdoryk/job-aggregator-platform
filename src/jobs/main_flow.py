from ingest_landing import ingest_landing
from landing_to_raw import landing_to_raw
from prefect import flow


@flow(name='main_flow')
def main_flow():
    ingest_landing()
    landing_to_raw()


if __name__ == '__main__':
    main_flow()
