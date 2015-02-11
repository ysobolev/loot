import csv
import json

def true(x):
    try:
        x = int(x)
        if x:
            return True
        return False
    except:
        return False

items = []
names = []
itemlist = open("items.csv")
fields = ['Name', 'Purchase Price (gp)', 'Description', 'Aura_Strength', 'Aura_School1', 'Aura_School2', 'Aura_School3', 'Aura_School4', '(subschool1)', '(subschool2)', '[Descriptor1]', '[Descriptor2]', '[Descriptor3]', 'CL', 'Slot', 'Weight (lbs.)', 'Crafting Requirements', 'Craft Cost (gp)', 'Group', 'Source', 'AL', 'Int', 'Wis', 'Cha', 'Ego', 'Communication', 'Senses', 'Powers', 'MagicItems', 'Destruction', 'MinorArtifactFlag', 'MajorArtifactFlag', 'Abjuration', 'Conjuration', 'Divination', 'Enchantment', 'Evocation', 'Necromancy', 'Transmutation', 'AuraStrength', 'WeightValue', 'PriceValue', 'CostValue', 'Languages', 'BaseItem', 'LinkText', 'id', 'Mythic', 'LegendaryWeapon', 'Illusion', 'Universal']
reader = csv.DictReader(itemlist, fields)
for row in reader:
    if not row["Name"]:
        continue
    if row["Name"] in names:
        continue
    names.append(row["Name"])
    item = {}
    item["name"] = row["Name"]
    item["type"] = "wondrous"
    item["caster_level"] = row["CL"].lower()
    item["description"] = row["Description"]
    item["slot"] = row["Slot"]
    item["value"] = 0
    link = row["LinkText"]
    if link.lower() in ["none", "null", "-", "n/a"]:
        link = ""
    item["link"] = link
    item["base_item"] = row["BaseItem"]
    item["notes"] = ""
    strengths = set()
    strengths.add(row["Aura_Strength"].lower())
    strengths.add(row["AuraStrength"].lower())
    strengths.discard("none")
    strengths.discard("null")
    strengths.discard("")
    strengths.discard("-")
    strengths.discard("n/a")
    item["aura_strength"] = " or ".join(strengths)
    schools = set()
    schools.add(row["Aura_School1"].lower())
    schools.add(row["Aura_School2"].lower())
    schools.add(row["Aura_School3"].lower())
    schools.add(row["Aura_School4"].lower())
    schools.add(row["(subschool1)"].lower())
    schools.add(row["(subschool2)"].lower())
    if true(row["Enchantment"]):
        schools.add("enchantment")
    if true(row["Necromancy"]):
        schools.add("necromancy")
    if true(row["Transmutation"]):
        schools.add("transmutation")
    if true(row["Evocation"]):
        schools.add("evocation")
    if true(row["Divination"]):
        schools.add("divination")
    if true(row["Conjuration"]):
        schools.add("conjuration")
    if true(row["Abjuration"]):
        schools.add("abjuration")
    schools.discard("none")
    schools.discard("null")
    schools.discard("")
    schools.discard("-")
    schools.discard("n/a")
    item["aura_type"] = ", ".join(schools)
    descriptors = set()
    descriptors.add(row["[Descriptor1]"].lower())
    descriptors.add(row["[Descriptor2]"].lower())
    descriptors.add(row["[Descriptor3]"].lower())
    descriptors.discard("none")
    descriptors.discard("null")
    descriptors.discard("")
    descriptors.discard("-")
    descriptors.discard("n/a")
    item["descriptors"] = ", ".join(descriptors)
    weights = set()
    weights.add(row["Weight (lbs.)"].lower())
    weights.add(row["WeightValue"].lower())
    weights.discard("none")
    weights.discard("null")
    weights.discard("")
    weights.discard("-")
    weights.discard("n/a")
    item["weight"] = " or ".join(weights)
    values = set()
    values.add(row["Craft Cost (gp)"].lower())
    values.add(row["CostValue"].lower())
    values.discard("none")
    values.discard("null")
    values.discard("")
    values.discard("-")
    values.discard("n/a")
    item["value"] = " or ".join(values)

    items.append(item)

json.dump(items, open("wondrous.json", "w"))

#import pymongo
#con = pymongo.MongoClient("127.0.0.1", 3001)
#meteor = con["meteor"]
#meteor["items"].remove({})
#for item in items:
#    meteor["items"].insert(item)

