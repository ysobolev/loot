import csv
import json

class Item:
    def __init__(self, name):
        self.name = name
        self.caster_level = set()
        self.description = set()
        self.base_item = set()
        self.link = set()
        self.slot = set()
        self.value = set()
        self.descriptor = set()
        self.weight = set()
        self.school = set()
        self.strength = set()

    def parse(self, row):
        self.caster_level.add(row["CL"].lower())
        self.description.add(row["Description"])
        self.base_item.add(row["BaseItem"].lower())
        self.link.add(row["LinkText"])
        self.slot.add(row["Slot"].lower())
        self.school.add(row["Aura_School1"].lower())
        self.school.add(row["Aura_School2"].lower())
        self.school.add(row["Aura_School3"].lower())
        self.school.add(row["Aura_School4"].lower())
        self.school.add(row["(subschool1)"].lower())
        self.school.add(row["(subschool2)"].lower())
        for school in ["Enchantment", "Necromancy", "Transmutation",
                "Evocation", "Divination", "Conjuration", "Abjuration"]:
            try:
                if int(row[school]):
                    self.school.add(school.lower())
            except ValueError as e:
                pass
        self.strength.add(row["Aura_Strength"].lower())
        self.strength.add(row["AuraStrength"].lower())
        self.descriptor.add(row["[Descriptor1]"].lower())
        self.descriptor.add(row["[Descriptor2]"].lower())
        self.descriptor.add(row["[Descriptor3]"].lower())
        self.weight.add(row["Weight (lbs.)"].lower())
        self.weight.add(row["WeightValue"].lower())
        self.value.add(row["Craft Cost (gp)"].lower())
        self.value.add(row["CostValue"].lower())

        drop = ["null", "none", "-", "", "n/a", "N/A", "NULL", "None", "Null",
                "None"]
        self.caster_level.difference_update(drop)
        self.description.difference_update(drop)
        self.base_item.difference_update(drop)
        self.link.difference_update(drop)
        self.slot.difference_update(drop)
        self.school.difference_update(drop)
        self.strength.difference_update(drop)
        self.descriptor.difference_update(drop)
        self.weight.difference_update(drop)
        self.value.difference_update(drop)

    def as_dict(self):
        item = {}
        item["name"] = self.name
        item["type"] = "magic"
        item["aura_type"] = ", ".join(self.school)
        item["aura_strength"] = " or ".join(self.strength)
        item["descriptors"] = " ".join(self.descriptor)
        item["base_item"] = " or ".join(self.base_item)
        item["caster_level"] = " or ".join(self.caster_level)
        item["value"] = " or ".join(self.value)
        item["weight"] = " or ".join(self.weight)
        try:
            item["link"] = self.link.pop()
        except KeyError as e:
            item["link"] = ""
        try:
            item["description"] = self.description.pop()
        except KeyError as e:
            item["description"] = ""
        return item

class Encoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Item):
            return obj.as_dict()
        return json.JSONEncoder.default(self, obj)


items = {}
with open("magic.csv") as item_csv:
    reader = csv.DictReader(item_csv)
    for row in reader:
        name = row["Name"]
        item = items.setdefault(name, Item(name))
        item.parse(row)
 
with open("magic.json", "w") as magic_db:
    encoder = Encoder()
    magic_db.write(encoder.encode(items.values()))

