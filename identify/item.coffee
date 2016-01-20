FuzzySet = require "./fuzzyset.js"

spells = {}
spell_matcher = FuzzySet [], false, 2, 3, 0
for spell in require "./spells.json"
  spells[spell.name] = spell
  spell_matcher.add spell.name

lookup_spell = (name) ->
  results = spell_matcher.get(name)
  if results?
    spells[results[0][1]]

class Item
  constructor: ->

  name: -> "generic item"
  price: -> 0

class CraftedItem extends Item
  base: "item"
  multiplier: 50
  constructor: (@spell) ->
    # find the spell
    if (not @spell.name?) or (not @spell.level?)
      @spell = lookup_spell @spell

    if not @spell?
      return

    # default to wizard spell if possible
    # then try cleric
    # finally, find the class which minimizes to level
    if "wizard" of @spell.level
      @class = "wizard"
    else if "cleric" of @spell.level
      @class = "cleric"
    else
      @class = ([@spell.level[cls], cls] for cls of @spell.level).sort()[0][1]
    @level = @spell.level[@class]
    # minimum caster level is 2 * level - 1, unless it is a cantrip
    @caster_level = if @level is 0 then 1 else 2 * @level - 1

  name: -> if @spell? then "#{@base} of #{@spell.name}" else @base
  price: ->
    if not @spell?
      0
    else
      (@spell.level[@class] or 0.5) * @caster_level * @multiplier

class Potion extends CraftedItem
  base: "potion"
  multiplier: 50

class Oil extends CraftedItem
  base: "oil"
  multiplier: 50

class Scroll extends CraftedItem
  base: "scroll"
  multiplier: 25

item = new Potion "cure light"
console.log "#{item.name()} costs #{item.price()}"
item = new Potion "cure mod"
console.log "#{item.name()} costs #{item.price()}"
item = new Scroll "guide"
console.log "#{item.name()} costs #{item.price()}"
