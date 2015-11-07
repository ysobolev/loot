Template.field.helpers
  value: () ->
    this.data[this.name]

Template.field.events
  "change .item_property" : (event, context) ->
    property = $(event.target).attr "data-property"
    obj = {}
    obj[property] = event.target.value
    Inventory.update this.data._id, $set: obj

