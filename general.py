import requests
import json

url = 'https://football.nowgoal.net/jsData/playerInfo/player236346_en.json'
# url = 'https://www.nowgoal.net/flashdata/get?id=2991085&t=1786795722000'
# url = 'https://football.nowgoal.net/jsData/matchResult/json/2026/c1124_en.json'
# url = 'https://www.nowgoal.net/Ajax/SoccerAjax?type=18&id=2991085'
# url = 'https://football.nowgoal.net/jsData/Count/json/2026/playerTech_1124_en.json'
# url = 'https://www.nowgoal.net/Ajax/SoccerAjax?type=3&id=2991085'
# url = 'https://football.nowgoal.net/jsdata/teamInfo/teamdetail/json/tdl84_en.json'
# url = 'https://football.nowgoal.net/ajax/GetTeamTransferByYear?teamId=84&year=2022'
# url = 'https://www.nowgoal.net/match/live-3061002'
# url = 'https://www.nowgoal.net/oddscomp/3061002'
# url = 'https://www.nowgoal.net/ajax/soccerajax?type=14&=&id=2991085&t=20&cid=8&h=0&r1=0&r2=0&r3=0&flesh=0.8648749084071264'
# # url = '	https://www.nowgoal.net/ajax/soccerajax?type=14&=&id=2991085&t=28&cid=8&h=0&r1=0&r2=0&r3=0&flesh=0.707316658384802'
# # url = 'https://www.nowgoal.net/ajax/soccerajax?type=14&=&id=2991085&t=26&cid=8&flesh=0.40328318684885833'
# url = 'https://www.nowgoal.net/ajax/soccerajax?type=14&=&id=2991085&t=27&cid=8&flesh=0.36212393486571093'
url = 'https://www.nowgoal.net/Ajax/SoccerAjax?type=4&id=2991080&p=17868988349000&flesh=0.4748982472313874'
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
}

headers = {
    "User-Agent": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    "Referer": "https://www.nowgoal.net",
    "X-Requested-With": "XMLHttpRequest"
}

re = requests.get(url, headers=headers)
print(re.status_code)
re.encoding = 'utf-8-sig'
with open('json/match_general.json', 'w', encoding='utf-8') as f:
    json.dump(re.json(),f, ensure_ascii=False, indent=2)

