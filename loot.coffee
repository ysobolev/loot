Items = new Mongo.Collection("items")
Inventory = new Mongo.Collection("inventory")

if Meteor.isClient
  Template.body.helpers
    inventory: () -> Inventory.find {}
    settings: () ->
      position: "bottom"
      limit: 5
      rules: [
        collection: Items
        field: "name"
        template: Template.item_short
      ]

  Template.body.events
    "click #button_add_item": (event) ->
      event.preventDefault()
      item_name = $("#ac_name").val()
      item = Items.findOne {name:item_name}
      if not item?
        item = {name:item_name}
      else
        item._id = new Meteor.Collection.ObjectID()
      item.quantity = 1
      Inventory.insert(item)

  Template.item.helpers
    total_value: () -> this.value * this.quantity
    is_magic: () -> this.type == "magic"
    is_armor: () -> this.type == "armor"
    is_weapon: () -> this.type == "weapon"
    is_equipment: () -> this.type == "equipment"
    is_treasure: () -> this.type == "treasure"

  Template.item.events
    "click .button_delete": (event) ->
      Inventory.remove this._id
    "change .item_property" : (event, context) ->
      property = $(event.target).attr "data-property"
      obj = {}
      obj[property] = event.target.value
      Inventory.update this._id, $set: obj

  Template.item_short.helpers
    is_magic: () -> this.type == "magic"
    is_armor: () -> this.type == "armor"
    is_weapon: () -> this.type == "weapon"
    is_equipment: () -> this.type == "equipment"
    is_treasure: () -> this.type == "treasure"

if Meteor.isServer
  Meteor.startup () ->
    Items.remove {}
    magic = JSON.parse Assets.getText "magic.json"
    armors = JSON.parse Assets.getText "armor.json"
    eastern_armors = JSON.parse Assets.getText "eastern_armor.json"
    gems = JSON.parse Assets.getText "gems.json"
    coins = JSON.parse Assets.getText "coins.json"
    for item in magic
      Items.insert item
    for armor in armors
      Items.insert armor
    for armor in eastern_armors
      Items.insert armor
    for gem in gems
      Items.insert gem
    for coin in coins
      Items.insert coin

