import requests
import pandas as pd

base_url = "https://mckapi.mckinsey.com/api/jobsearch?pageSize=1000"


def main():
    res = requests.get(base_url).json()
    jobs = res.get('docs')

    assert res.get('status') == 'OK'
    assert res.get('numFound') == len(jobs)

    # Create DataFrame
    df = pd.DataFrame(jobs)


if __name__ == "__main__":
    main()
