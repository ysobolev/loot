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

Meteor.methods
  add: (item, bag) ->
    check item, Object
    check bag, String
    items = Inventory.find {bag: bag}
    item.bag = bag
    items = items.map (x) -> x.order or 0
    max_order = Math.max 0, items...
    item.order = max_order + 1
    Inventory.insert item

  sort: (type_order, bag) ->
    console.log type_order, bag
    check type_order, String
    check bag, String
    console.log type_order
    all_items = Inventory.find bag: bag
    console.log "got items"
    orders = all_items.map (item) -> item.order or 0
    console.log orders
    counter = Math.max orders.length, orders...
    console.log counter
    type_order = type_order.split(" ").reverse()
    console.log type_order
    for type in type_order
      console.log type
      items = Inventory.find
        bag: bag
        type:
          $regex: type
      items.forEach (item) ->
        console.log "setting #{item.name}: #{item.order} -> #{counter}"
        Inventory.update item._id, $set: order: counter
        counter -= 1

