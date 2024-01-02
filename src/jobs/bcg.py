import requests
import pandas as pd

base_url = 'https://careers.bcg.com/widgets'


def main():
    body = {"lang": "en_us", "deviceType": "desktop", "country": "us", "pageName": "search-results",
            "ddoKey": "refineSearch", "sortBy": "", "subsearch": "", "from": 0, "jobs": True, "counts": True,
            "all_fields": ["country", "city", "category", "company"], "size": 9999, "clearAll": False,
            "jdsource": "facets", "isSliderEnable": False, "pageId": "page17", "siteType": "external", "keywords": "",
            "global": True, "selected_fields": {}, "locationData": {}}
    res_dict = requests.post(base_url, json=body).json().get('refineSearch')

    jobs = res_dict.get('data').get('jobs')
    hits = res_dict.get('hits')
    total_hits = res_dict.get('totalHits')

    # Check if we got all jobs offers
    assert len(jobs) == hits == total_hits

    # Create DataFrame
    df = pd.DataFrame(jobs)


if __name__ == "__main__":
    main()
