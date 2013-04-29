# 
# 
# 
# Copyright 2013 Adam Florin
# 

class Probability
  
  # Return true if heads, given chance.
  # 
  flip: (chance) ->
    parseInt(Math.random() * (1/chance)) == 0
