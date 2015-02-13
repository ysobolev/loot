Items = new Mongo.Collection("items")
Inventory = new Mongo.Collection("inventory")

Router.route "/", () -> this.render "welcome"
Router.route "/:bag", () ->
  this.render "main", data: bag: this.params.bag
 ,
  loadingTemplate: "loading"
  waitOn: () ->
    [Meteor.subscribe("inventory", this.params.bag),
     Meteor.subscribe ("items")]

Template.welcome.helpers
  random: () ->
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    bag = ""
    for i in [1..5]
      bag += chars.charAt Math.floor Math.random() * chars.length
    return bag

Template.main.helpers
  inventory: () -> Inventory.find {bag: this.bag}
  settings: () ->
    position: "bottom"
    limit: 5
    rules: [
      collection: Items
      field: "name"
      template: Template.item_short
    ]
  sortable_options: () ->
    draggable: ".item"

Template.main.events
  "click #button_add_item": (event) ->
    event.preventDefault()
    item_name = $("#ac_name").val()
    if not item_name? or item_name == ""
      return
    item = Items.findOne {name:item_name}
    if not item?
      item = {name:item_name}
    else
      item._id = new Meteor.Collection.ObjectID()
    item.bag = this.bag
    item.quantity = 1
    Inventory.insert(item)
  "click #transfer": (event) ->
    event.preventDefault()
    bootbox.prompt "Which bag do you want everything moved to?", (new_bag) =>
      if not new_bag? or new_bag == ""
        return
      Inventory.find(bag: this.bag).forEach (item) ->
        Inventory.update item._id, $set: bag: new_bag
      Router.go("/" + new_bag)


Template.item.helpers
  total_value: () -> this.value * this.quantity

Template.item.events
  "click .button_delete": (event) ->
    Inventory.remove this._id
  "change .item_property" : (event, context) ->
    property = $(event.target).attr "data-property"
    obj = {}
    obj[property] = event.target.value
    Inventory.update this._id, $set: obj

methods =
  is_magic: () -> this.type == "magic"
  is_armor: () -> this.type == "armor"
  is_weapon: () -> this.type == "weapon"
  is_equipment: () -> this.type == "equipment"
  is_treasure: () -> this.type == "treasure"

for name, method of methods
  Template.registerHelper name, method

