import os
import subprocess
import requests
from bs4 import BeautifulSoup

# The URL of the webpage to scrape
url = "https://devbuilds.drdteam.org/gzdoom/"

# Send a GET request to the webpage
response = requests.get(url)

if response.status_code != 200:
    print(f"Error: Failed to access {url}. Status code: {response.status_code}")
    exit()

# Parse the HTML content of the webpage using BeautifulSoup
soup = BeautifulSoup(response.content, 'html.parser')

# Find all the links on the webpage
links = soup.find_all('a')

# Filter the links to only include those that point to a gzdoom archive file
gzdoom_links = [link for link in links if link.has_attr('href') and link['href'].endswith('.7z')]

# Sort the links by their version number and build number
sorted_links = sorted(gzdoom_links, key=lambda x: tuple(int(part) if part.isdigit() else part for part in x['href'].split('-')[2:]))

# Get the link with the highest version number and build number
latest_file = sorted_links[-1]['href'].split('/gzdoom/')[-1]

# Print the version and build number of the file to be downloaded
version, build = latest_file.split('-')[2:4]
print(f"Downloading GZDoom version {version} build {build}...")

# Download the latest gzdoom archive file
response = requests.get(url + latest_file)

if response.status_code != 200:
    print(f"Error: Failed to download {url+latest_file}. Status code: {response.status_code}")
    exit()

filename = latest_file.split('/')[-1]
with open(filename, 'wb') as f:
    f.write(response.content)

print(f"Downloaded the latest gzdoom archive file ({filename}) successfully.")

# Extract the archive to the current working directory
seven_zip_path = "C:\\Program Files\\7-Zip\\7z.exe"
with open(os.devnull, 'w') as null:
    subprocess.run([seven_zip_path, 'x', filename, '-y'], stdout=null, stderr=null)

# Remove the archive file
os.remove(filename)

print("Extracted the archive successfully.")
