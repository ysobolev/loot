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
  alchemy = JSON.parse Assets.getText "alchemy.json"
  mundane = JSON.parse Assets.getText "mundane.json"
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
  for item in alchemy
    Items.insert item
  for item in mundane
    Items.insert item

Items.deny
  insert: () -> true
  update: () -> true
  remove: () -> true

Inventory.allow
  insert: () -> true
  update: () -> true
  remove: () -> true

Meteor.publish "inventory", (bag) ->
  return Inventory.find bag: bag

Meteor.publish "items", () ->
  return Items.find {}

Meteor.publish "autocomplete-items", (selector, options) ->
  options.limit = Math.min(50, Math.abs(options.limit)) if options.limit
  cursor = Items.find selector, options
  Mongo.Collection._publishCursor cursor, this, "autocompleteRecords"
  this.ready()

Meteor.methods
  add: (item, bag) ->
    check item, Object
    check bag, String
    items = Inventory.find {bag: bag}
    item.bag = bag
    items = items.map (x) -> x.order or 0
    max_order = Math.max 0, items...
    item.order = max_order + 1
    if not item.type?
      item.type = ""
    if not item.quantity?
      item.quantity = 1
    if not item.value?
      item.value = 0
    Inventory.insert item

