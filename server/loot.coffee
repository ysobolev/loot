Items = new Mongo.Collection("items")
Inventory = new Mongo.Collection("inventory")

Meteor.startup () ->
  Items.remove {}
  magic = JSON.parse Assets.getText "magic.json"
  armors = JSON.parse Assets.getText "armor.json"
  eastern_armors = JSON.parse Assets.getText "eastern_armor.json"
  weapons = JSON.parse Assets.getText "weapons.json"
  gems = JSON.parse Assets.getText "gems.json"
  coins = JSON.parse Assets.getText "coins.json"
  specials = JSON.parse Assets.getText "special.json"
  for item in magic
    Items.insert item
  for armor in armors
    Items.insert armor
  for armor in eastern_armors
    Items.insert armor
  for weapon in weapons
    Items.insert weapon
  for gem in gems
    Items.insert gem
  for coin in coins
    Items.insert coin
  for special in specials
    Items.insert special

Items.deny
  insert: () -> true
  update: () -> true
  remove: () -> true

Meteor.publish "inventory", (bag) ->
  return Inventory.find bag: bag

Meteor.publish "items", () ->
  return Items.find {}

