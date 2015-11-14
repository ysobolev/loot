
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
  settings: () ->
    collection: Inventory.find {bag: this.bag, type: {$regex: Session.get "type"}}, {sort: order: 1}
    showNavigation: "never"
    showColumnToggles: true
    fields: [
      key: "name"
      label: "Name"
      headerClass: "col-md-6"
      tmpl: Template.table_item
      hideToggle: true
    ,
      key: "quantity"
      label: "Quantity"
      headerClass: "col-md-2"
    ,
      key: "value"
      label: "Value"
      headerClass: "col-md-2"
    ,
      key: "weight"
      label: "Weight"
      headerClass: "col-md-2"
      hidden: true
    ,
      key: "order"
      label: "Order"
      headerClass: "col-md-2"
      ]
    filters: ["filter"]
    rowClass: (item) ->
      selected = Session.get("selected")
      if item._id in selected
        "info"
      else
        ""

Template.navbar.helpers
  select_one: () -> Session.get("selected").length == 1
  select_many: () -> Session.get("selected").length > 1
  selected: () -> Session.get("selected").length >= 1
  current_type: () ->
    type = Session.get "type"
    if type == ""
      "All"
    else
      type[0].toUpperCase() + type[1..-1]
  navbar_class: () ->
    if Session.get("selected").length >= 1
      "navbar-inverse"
    else
      "navbar-default"

Template.navbar.events
  "click .action_split": (event) ->
    event.preventDefault()
    item = Inventory.findOne Session.get("selected")[0]
    Session.set "selected", []
    bootbox.prompt "How many do you wish to separate?", (split) =>
      split = parseInt(split) or 0
      if split <= 0
        return
      if split == item.quantity
        return
      if split > item.quantity
        return bootbox.alert "You do not have that many."
      Inventory.update item._id, $set: quantity: item.quantity - split
      new_item = {}
      for key of item
        new_item[key] = item[key]
      delete new_item._id
      new_item.quantity = split
      Meteor.call "add", new_item, this.bag

  "click .action_merge": (event) ->
    event.preventDefault()
    items = Inventory.find({_id: {$in: Session.get "selected"}}).fetch()
    Session.set "selected", []

    similar = (item1, item2) ->
      for key of item1
        if key not in ["_id", "quantity", "order"]
          if item1[key] != item2[key]
            return false
      true

    unique = []
    for item in items
      matched = false
      for set in unique
        if similar item, set[0]
          set.push item
          matched = true
          break
      if not matched
        unique.push [item]

    for set in unique
      if set.length == 1
        continue
      new_item = {}
      for key of set[0]
        new_item[key] = set[0][key]
      delete new_item._id
      new_item.quantity = 0
      for item in set
        new_item.quantity += parseInt(item.quantity)
        Inventory.remove item._id
      Meteor.call "add", new_item, this.bag

  "click .action_clone": (event) ->
    event.preventDefault()
    items = Inventory.find({_id: {$in: Session.get "selected"}}).fetch()
    Session.set "selected", []
    for item in items
      new_item = {}
      for key of item
        new_item[key] = item[key]
      delete new_item._id
      Meteor.call "add", new_item, this.bag

  "click .action_transfer": (event) ->
    event.preventDefault()
    bootbox.prompt "Which bag do you want this moved to?", (new_bag) =>
      if not new_bag? or new_bag == ""
        return
      Inventory.find(bag: this.bag).forEach (item) ->
        if item._id in Session.get("selected")
          Inventory.update item._id, $set: bag: new_bag
      Router.go("/" + new_bag)
  
  "click .action_trash": (event) ->
    event.preventDefault()
    for item in Session.get "selected"
      Inventory.remove item
    Session.set "selected", []

  "click .action_stats": (event) ->
    event.preventDefault()
    items = Inventory.find({_id: {$in: Session.get "selected"}}).fetch()
    values = (item.quantity * item.value for item in items)
    value = values.reduce (a, b) -> a + b
    bootbox.alert "This is worth a total of #{value} gold."

  "click #action_switch": (event) ->
    event.preventDefault()
    bootbox.prompt "Which bag do you want to go to?", (new_bag) =>
      if not new_bag? or new_bag == ""
        return
      Router.go("/" + new_bag)
  
  "click .action_edit": (event) ->
    item = Inventory.findOne Session.get("selected")[0]
    Modal.show "edit_item", {bag: this.bag, item:item}

Template.list.events
  "click .reactive-table tbody tr": (event) ->
    selected = Session.get "selected"
    if this._id in selected
      selected.splice (selected.indexOf this._id), 1
    else
      selected.push this._id
    Session.set "selected", selected
  "click #select_none": (event) ->
    Session.set "selected", []
  "click #select_all": (event) ->
    Session.set "selected", (item._id for item in Inventory.find({bag: this.bag, type: {$regex: Session.get "type"}}).fetch())
  "click #type_all": (event) ->
    Session.set "selected", []
    Session.set "type", ""
  "click #type_treasure": (event) ->
    Session.set "selected", []
    Session.set "type", "treasure"
  "click #type_magic": (event) ->
    Session.set "selected", []
    Session.set "type", "magic"
  "click #type_armor": (event) ->
    Session.set "selected", []
    Session.set "type", "armor"
  "click #type_weapon": (event) ->
    Session.set "selected", []
    Session.set "type", "weapon"
  "click #type_equipment": (event) ->
    Session.set "selected", []
    Session.set "type", "equipment"
  "click #action_add": (event) ->
    Modal.show "add_item", {bag: this.bag}

Template.item.helpers
  total_value: () -> this.value * this.quantity
  total_weight: () -> this.weight * this.quantity
  id: () ->  this._id._str or this._id

Template.add_item.helpers
  item_type: () ->
    type = Session.get "type"
    if type == ""
      "Item"
    else if type == "magic"
      "Magic Item"
    else
      type[0].toUpperCase() + type[1..-1]
  autocomplete_settings: () ->
    position: "bottom"
    limit: 5
    rules: [
      collection: Items
      field: "name"
      filter: {type: {$regex: Session.get "type"}}
      template: Template.item_short
    ]

Template.add_item.events
  "click #button_add": (event) ->
    Modal.hide("add_item")
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
    Meteor.call "add", item, this.bag

Template.edit_item.current_section = new ReactiveVar("General")
Template.edit_item.sections =
  General: [
    name: "name"
    label: "Name"
  ,
    name: "type"
    label: "Type"
  ,
    name: "quantity"
    label: "Quantity"
  ,
    name: "value"
    label: "Value"
  ,
    name: "weight"
    label: "Weight"
  ,
    name: "link"
    label: "Link"
  ],
  Magic: [
    name: "aura_type"
    label: "Aura Type"
  ,
    name: "aura_strength"
    label: "Aura Strength"
  ,
    name: "caster_level"
    label: "Caster Level"
  ,
    name: "descriptors"
    label: "Descriptors"
  ,
    name: "base_item"
    label: "Base Item"
  ],
  Armor: [
    name: "bonus"
    label: "Armor Bonus"
  ,
    name: "arcane_failure"
    label:"Arcane Failure"
  ,
    name: "max_dex"
    label: "Max Dexterity"
  ,
    name: "check_penalty"
    label: "Check Penalty"
  ,
    name: "speed_30"
    label: "Unencumbered (30ft)"
  ,
    name: "speed_20"
    label: "Unencumbered (20ft)"
  ],
  Weapon: [
    name: "class"
    label: "Class"
  ,
    name: "critical"
    label: "Critical Range"
  ,
    name: "damage_m"
    label: "Damage (M)"
  ,
    name: "damage_s"
    label: "Damage (S)"
  ,
    name: "proficiency"
    label: "Proficiency"
  ,
    name: "weapon_type"
    label: "Damage Type"
  ,
    name: "range"
    label: "Range"
  ,
    name: "special"
    label: "Special"
  ],
  Equipment: [
    name: "craft_dc"
    label: "Craft DC"
  ]
  
Template.edit_item.helpers
  section: () ->
    Template.edit_item.current_section.get()
  fields: () ->
    section = Template.edit_item.current_section.get()
    if section != "Other"
      Template.edit_item.sections[section]

Template.edit_item.events
  "click .section": (event, context) ->
    Template.edit_item.current_section.set(event.target.innerHTML)

Template.field.helpers
  value: () ->
    this.data[this.name]

Template.field.events
  "change .item_property" : (event, context) ->
    property = $(event.target).attr "data-property"
    obj = {}
    obj[property] = event.target.value
    Inventory.update this.data._id, $set: obj

methods =
  is_magic: () -> (this.type.indexOf "magic") > -1
  is_armor: () -> (this.type.indexOf "armor") > -1
  is_weapon: () -> (this.type.indexOf "weapon") > -1
  is_equipment: () -> (this.type.indexOf "equipment") > -1
  is_treasure: () -> (this.type.indexOf "treasure") > -1

for name, method of methods
  Template.registerHelper name, method

