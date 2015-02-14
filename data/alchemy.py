# -*- coding: utf-8 -*-

import requests
from bs4 import BeautifulSoup
import string
import re
import json

def sanitize(x):
    x = x.replace(u"\xd7", "x")
    x = x.replace(u"\u2013", "-")
    x = x.replace(u"\u2014", "")
    return x

def parse_table(table, prefix):
    items = {}
    trs = table.findAll("tr")
    for tr in trs:
        item = {}
        tds = tr.findAll("td")
        if len(tds) == 0:
            continue
        item["name"] = tds[0].text.split("[")[0].strip()
        item["type"] = "equipment"
        item["link"] = prefix
        a = tds[0].find("a")
        if a:
            item["link"] = prefix + a.attrs["href"]
        item["craft_dc"] = sanitize(tds[1].text.lower()).strip()
        cost = sanitize(tds[2].text.lower()).strip()
        if cost == "":
            cost = "0"
        multiplier = 1
        if "sp" in cost:
            multiplier = 0.1
        if "cp" in cost:
            multiplier = 0.01
        try:
            cost = int(cost.strip(string.lowercase)) * multiplier
            value = cost / 2.0
        except ValueError as e:
            value = ""
        item["cost"] = cost
        item["value"] = value
        item["weight"] = sanitize(tds[3].text.lower()).strip()
        items[item["name"]] = item
    return items

def parse_tables(tables, prefix):
    items = {}
    for table in tables:
        items.update(parse_table(table, prefix))
    return items

items = {}

link = "http://www.d20pfsrd.com/equipment---final/goods-and-services/herbs-oils-other-substances"
data = requests.get(link).text
soup = BeautifulSoup(data)
tables = soup.findAll("table")[4:5]
items.update(parse_tables(tables, link))

with open("alchemy.json", "w") as output:
    json.dump(items.values(), output,
            sort_keys=True, indent=4, separators=(',', ': '))

