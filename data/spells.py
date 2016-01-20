import csv
import json

spells = []
with open("spells.csv") as spells_csv:
    reader = csv.DictReader(spells_csv)
    for row in reader:
        name = row["name"].strip()
        spell = {"name":row["name"], "level":{}}
        for pair in row["spell_level"].strip().split(","):
            classes, level = pair.strip().rsplit(" ", 1)
            for cls in classes.split("/"):
                spell["level"][cls] = int(level)
        spells.append(spell)
 
json.dump(spells, open("spells.json", "w"))

