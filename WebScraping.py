from bs4 import BeautifulSoup
import requests
from csv import writer
import datetime

url = "https://www.indeed.com/jobs?q=data%20analyst%20entry%20level%20&l=Bellevue%2C%20WA&vjk=00df3d0dfea52b59"

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36",
    "Accept-Encoding": "gzip, deflate", "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "DNT": "1", "Connection": "close", "Upgrade-Insecure-Requests": "1"}

page = requests.get(url, headers=headers)
soup1 = BeautifulSoup(page.content, 'html.parser')

soup2 = BeautifulSoup(soup1.prettify(), 'html.parser')

lists = soup2.find_all('div', class_='slider_item')
today = datetime.date.today()

#with open('joblist.csv', 'a', encoding='utf8', newline='') as f:
    #thewriter = writer(f)
with open('joblist.csv', 'w', encoding='utf8', newline='') as f:
    thewriter = writer(f)
    header = ['Date', 'Job', 'Company Name', 'Company Location', 'Posted Date']
    thewriter.writerow(header)

    for list1 in lists:
        title = list1.find('h2', class_='jobTitle').text.replace('\n', '')
        companyname = list1.find('span', class_='companyName').text.replace('\n', '')
        companylocation = list1.find('div', class_='companyLocation').text.replace('\n', '')
        posted = list1.find('span', class_='date').text.replace('\n', '')
        info = [today, title, companyname, companylocation, posted]
        thewriter.writerow(info)
