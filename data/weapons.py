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

def parse_table(table, proficiency, class_):
    weapons = {}
    trs = table.findAll("tr")
    for tr in trs[1:]:
        weapon = {}
        weapon["type"] = "weapon"
        weapon["proficiency"] = proficiency
        weapon["class"] = class_
        tds = tr.findAll("td")
        weapon["name"] = tds[0].text.strip()
        weapon["link"] = ""
        a = tds[0].find("a")
        if a:
            weapon["link"] = a.attrs["href"]
        match = re.match("(.*)\(([0-9]+)\)", weapon["name"])
        if match:
            weapon["name"] = match.groups()[0].strip()
            weapon["quantity"] = match.groups()[1]
        cost = sanitize(tds[1].text.lower()).strip()
        if cost == "":
            cost = "0"
        multiplier = 1
        if "sp" in cost:
            multiplier = 0.1
        try:
            cost = int(cost.strip(string.lowercase))
        except ValueError as e:
            cost = 0
        cost = cost * multiplier
        weapon["cost"] = cost
        weapon["value"] = cost / 2.0
        weapon["damage_s"] = sanitize(tds[2].text.lower()).strip()
        weapon["damage_m"] = sanitize(tds[3].text.lower()).strip()
        weapon["critical"] = sanitize(tds[4].text.lower()).strip()
        weapon["range"] = sanitize(tds[5].text.lower()).strip()
        weapon["weight"] = sanitize(tds[6].text.lower()).strip()
        weapon["weapon_type"] = sanitize(tds[7].text.upper()).strip()
        weapon["special"] = sanitize(tds[8].text.lower()).strip()
        weapons[weapon["name"]] = weapon
    return weapons

def parse_tables(tables):
    weapons = {}
    for table in tables:
        type_ = table.find("th").text.lower()
        type_ = type_.replace(" - Eastern", "")
        type_ = type_.replace(" - eastern", "")
        type_ = type_.replace("weapons", "")
        type_ = type_.replace("melee", "")
        type_ = type_.replace("weapons", "")
        type_ = type_.replace("attacks", "")
        proficiency, class_ = type_.split("\n")
        proficiency = proficiency[1:-1].strip()
        class_ = class_.strip()
        weapons.update(parse_table(table, proficiency, class_))
    return weapons

weapons = {}

data = requests.get("http://www.d20pfsrd.com/equipment---final/weapons").text
soup = BeautifulSoup(data)
tables = soup.findAll("table")[4:-3]
weapons.update(parse_tables(tables))

data = requests.get("http://www.d20pfsrd.com/equipment---final/weapons/eastern-weapons").text
soup = BeautifulSoup(data)
tables = soup.findAll("table")[3:]
weapons.update(parse_tables(tables))

# this is a special item
del weapons["Shield, throwing"]

with open("weapons.json", "w") as output:
    json.dump(weapons.values(), output,
            sort_keys=True, indent=4, separators=(',', ': '))

