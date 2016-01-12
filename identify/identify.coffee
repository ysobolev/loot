isNumeric = (obj) -> (obj - parseFloat obj)  + 1 >= 0
powerset = (S) ->
  P = [[]]
  P.push P[j].concat S[i] for j of P for i of S
  P

FuzzySet = require "./fuzzyset.js"
magic_data = (item.name for item in require "./magic.json")
magic_items = FuzzySet magic_data, false, 2, 3, 0
base_data = ["longsword", "chainmail", "chain shirt", "wooden shield"]
base_items = FuzzySet base_data, false, 2, 3, 0.1
modifier_data = ["flaming", "flaming burst", "mithral"]
modifiers = FuzzySet modifier_data, false, 2, 3, 0.2

identify = (name) ->
  console.log "testing: #{name}"
  candidates = []

  # check to make sure string is not empty
  # TODO: convert other whitespace?
  tokens = (token for token in name.split " " when token.length)
  return null if not tokens.length

  # see if first token is a count
  count = 1
  first = tokens[0]
  if isNumeric first
    if first[0] isnt "+" and first[0] isnt "-"
      count = parseInt first
      tokens.splice 0, 1

  # try to match known magical items
  candidates.push.apply candidates, magic_items.get name

  # try to identify common items

  # strip enchantment
  enchantment = 0
  remaining_tokens = []
  for token in tokens
    if isNumeric(token) and (token[0] is "+" or token[0] is "-")
      enchantment = parseInt token
    else
      remaining_tokens.push token

  enchantment_label = ""
  if enchantment > 0
    enchantment_label = "+#{enchantment}"
  if enchantment < 0
    enchantment_label = "#{enchantment}"

  name = remaining_tokens.join " "

  # try to find base item
  base_matches = (base_item[1] for base_item in (base_items.get(name) or []))
  # console.log "bases: #{base_matches}"
  
  # try to find modifiers
  modifier_matches = (modifier[1] for modifier in (modifiers.get(name) or []))
  # console.log "mods: #{modifier_matches}"

  # build candidate items to test agains
  constructed = FuzzySet [], false, 2, 3, 0
  for base in base_matches
    for mods in powerset modifier_matches
      mods.unshift enchantment_label
      mods = mods.join " "
      test_item = "#{mods} #{base}".trim()
      # console.log "built: #{test_item}"
      constructed.add test_item

  candidates.push.apply candidates, constructed.get name

  # sort and return
  candidates.sort().reverse()
  candidates = (candidate for candidate in candidates when candidate[0] >= 0.5)

  if candidates.length > 0
    item = candidates[0][1]
    best_guess = "#{count}x #{item}".trim()
    console.log best_guess
  else
    console.log "Not found"
  console.log ""

identify "2 -1 flaming longsword"
identify "2 -1 flaming mithral longsword"
identify "flaming burst +1 longsword"
identify "flaming flaming burst +1 longsword"
identify "3 +2 chain mail"
identify "+2 chain shirt"
identify "headband of vast int +2"
identify "32432rfsdf"

