FuzzySet = require "./fuzzyset.js"
Items = require("./items")

class Database
  constructor: (klass, path) ->
    @items = {}
    for item in require path
      @items[item.name] = new klass item
    @fuzzyset =  FuzzySet (name for name of @items), false, 2, 3, 0

  search: (query) ->
    ([score, @items[name]] for [score, name] in @fuzzyset.get(query) or [])

  searchOne: (query) ->
    @search(query)[0]?[1]

## database of items
Wondrous = new Database Items.Item, "./magic.json"
Equipment = new Database Items.EquipableItem, "./armor.json"
Equipment.fuzzyset.epsilon = 0.1
Spells = new Database Items.Spell, "./spells.json"
#Modifiers = new Database "./modifiers.json"
#Modifiers.fuzzyset.epsilon = 0.2
Consumables = new Database Items.ConsumableItem, "./consumables.json"

cure_light = Spells.searchOne "cure light"
potion = Consumables.searchOne "potion"
potion.enchant cure_light
chainshirt = Equipment.searchOne "chainshirt"
console.log potion.getCanonicalName()
console.log chainshirt.getCanonicalName()
