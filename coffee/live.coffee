# 
# live.coffee: wrappers for LiveAPI
# 
# Copyright Adam Florin 2013
# 

class Live

  # A "player" is defined as a group of modules which all
  # share the same parent. So our parent ID _is_ our player ID.
  # 
  playerId: ->
    (new LiveAPI "this_device canonical_parent").id
