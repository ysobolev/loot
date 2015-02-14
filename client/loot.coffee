Items = new Mongo.Collection("items")
Inventory = new Mongo.Collection("inventory")

Router.route "/", () -> this.render "welcome"
Router.route "/:bag", () ->
  this.render "list", data: bag: this.params.bag
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

Template.list.helpers
  inventory: () -> Inventory.find {bag: this.bag}, {sort: order: 1}
  autocomplete_settings: () ->
    position: "bottom"
    limit: 5
    rules: [
      collection: Items
      field: "name"
      template: Template.item_short
    ]
  sortable_settings: () ->
    draggable: ".item"
    handle: ".handle"

Template.list.events
  "click #button_add_item": (event) ->
    event.preventDefault()
    item_name = $("#ac_name").val()
    $("#ac_name").val("")
    if not item_name? or item_name == ""
      return
    item = Items.findOne {name:item_name}
    if not item?
      item = {name:item_name}
    else
      delete item._id
    if not item.quantity?
      item.quantity = 1
    Meteor.call "add", item, this.bag
  "click #transfer": (event) ->
    event.preventDefault()
    bootbox.prompt "Which bag do you want everything moved to?", (new_bag) =>
      if not new_bag? or new_bag == ""
        return
      Inventory.find(bag: this.bag).forEach (item) ->
        Inventory.update item._id, $set: bag: new_bag
      Router.go("/" + new_bag)
  "click #sort": (event) ->
    event.preventDefault()
    bootbox.prompt
      title: "Please specify a sort order."
      "value": "treasure magic armor weapon equipment"
      callback: (type_order) =>
        if not type_order? or type_order == ""
          return
        Meteor.call "sort", type_order, this.bag

Template.item.helpers
  total_value: () -> this.value * this.quantity
  total_weight: () -> this.weight * this.quantity

Template.item.events
  "click .button_delete": (event) ->
    Inventory.remove this._id
  "change .item_property" : (event, context) ->
    property = $(event.target).attr "data-property"
    obj = {}
    obj[property] = event.target.value
    Inventory.update this._id, $set: obj

methods =
  is_magic: () -> (this.type.indexOf "magic") > -1
  is_armor: () -> (this.type.indexOf "armor") > -1
  is_weapon: () -> (this.type.indexOf "weapon") > -1
  is_equipment: () -> (this.type.indexOf "equipment") > -1
  is_treasure: () -> (this.type.indexOf "treasure") > -1

for name, method of methods
  Template.registerHelper name, method

