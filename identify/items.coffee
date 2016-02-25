class Item
  constructor: (obj) ->
    @properties = {}
    @name = obj?.name or "Generic Item"
    for key of obj
      @properties[key] = obj[key]

  getCanonicalName: -> @name

  toObj: -> @properties

class EquipableItem extends Item
  constructor: (item) ->
    super(item)

    # put adjective first
    @base = item?.name or "Item"
    @modifiers = []
    @material = null
    @enchantment = 0

  enchant: (modifier) ->
    @modifiers.push modifier

  getCanonicalName: () ->
    @modifiers.sort()
    parts = @modifiers[..]
    enchantment_label = ""
    if @enchantment
      if @enchantment > 0
        parts.unshift "+#{@enchantment}"
      else
        parts.unshift = "#{@enchantment}"
    if @material?
      parts.push @material
    parts.push @base or "item"
    parts.join " "

  toObj: () ->
    # TODO: embed link, add price, add weight
    properties = {}
    for key of @properties
      properties[key] = @properties[key]
    properties.name = @getCanonicalName()
    properties.base = @base
    return properties

class Spell extends Item
  constructor: (item) ->
    super(item)
    @spell = item.name
    @level = item.level

class ConsumableItem extends Item
  constructor: (item) ->
    super(item)
    @base = @properties.name
    @multiplier = @properties.multiplier or 0

  enchant: (@spell) ->
    if not @spell? or not @spell.level? or typeof @spell.level isnt "object"
      delete @spell
      return

    # default to wizard spell if possible
    # then try cleric
    # finally, find the class which minimizes the level
    if "wizard" of @spell.level
      @class = "wizard"
      @type = "arcane"
    else if "cleric" of @spell.level
      @class = "cleric"
      @type = "divine"
    else
      @class = ([@spell.level[cls], cls] for cls of @spell.level).sort()[0][1]
      @type = @class
    @level = parseInt @spell.level[@class]
    @level = 0 if isNaN @level
    # minimum caster level is 2 * level - 1, unless it is a cantrip
    @caster_level = if @level is 0 then 1 else 2 * @level - 1

  getCanonicalName: -> if @spell? then "#{@base} of #{@spell.name}" else @base

  toObj: ->
    # TODO: embed link
    name: @getCanonicalName()
    price: if not @spell? then 0 else
      (@spell.level[@class] or 0.5) * @caster_level * @multiplier
    weight: 0
    base: @base

module.exports =
  Item: Item
  EquipableItem: EquipableItem
  Spell: Spell
  ConsumableItem: ConsumableItem
