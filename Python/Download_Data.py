import requests
import os
from urllib.parse import unquote
base_url = "https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fwww.nyc.gov%2Fassets%2Ffinance%2Fdownloads%2Fpdf%2Frolling_sales%2Fannualized-sales%2F{year}%2F{year}_{city}.xls&wdOrigin=BROWSELINK"

years = range(2010, 2024)  
cities = ["manhattan", "brooklyn", "queens", "bronx"]
save_dir = "real_estate_data"
os.makedirs(save_dir, exist_ok=True)

def download_file(url, file_name):
    try:
        
        response = requests.get(url, allow_redirects=True)
        response.raise_for_status() 

        if "view.officeapps.live.com" in response.url:
            original_url = unquote(response.url.split("src=")[1].split("&")[0])
            print(f"Redirected to original URL: {original_url}")
            response = requests.get(original_url)
            response.raise_for_status()

        with open(file_name, "wb") as file:
            file.write(response.content)
        print(f"Downloaded {file_name}")
    except requests.exceptions.RequestException as e:
        print(f"Failed to download {file_name}: {e}")

for year in years:
    for city in cities:
        redirect_url = base_url.format(year=year, city=city)
        file_name = os.path.join(save_dir, f"{year}_{city}.xls")
        print(f"Downloading {redirect_url}...")
        download_file(redirect_url, file_name)