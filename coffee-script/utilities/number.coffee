# 
# number.coffee: Global numeric JS helpers.
# 
# Copyright 2013 Adam Florin
# 

# Constrain value between 0.0-1.0.
# 
constrain = (number, max, min) ->
  max ?= 1.0
  min ?= 0.0
  Math.max(min, Math.min(max, number))

# Return boolean, given chance of returning heads as a fraction of 1.0.
# 
randomBoolean = (chance) ->
  parseInt(Math.random() * (1/chance)) == 0

# Math utility
# 
beatsToTicks = (beats) ->
  beats * 480

# Utility for logger date formatting.
# 
# Pad integer with leading zeros so that it comes out to (at least) a certain
# number of digits.
# 
toZeroPaddedString = (number, digits) ->
  zeros =
    for powers in [Math.max(digits-1, 0)..1]
      if number < Math.pow(10, powers) then "0" else break
  zeros.join("") + number
