import requests
import pandas as pd

base_url = "https://www.bain.com/en/api/jobsearch/keyword/get?results={}"


def main():
    num_of_posts = requests.get(base_url.format("1")).json().get('totalResults')
    res = requests.get(base_url.format(num_of_posts)).json()
    pd.DataFrame(res)


if __name__ == "__main__":
    main()
