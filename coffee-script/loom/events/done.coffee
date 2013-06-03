# 
# done.coffee: Notify player that its last gesture has been fully output
# 
# Copyright 2013 Adam Florin
# 

class Loom::Events.Done extends Event
  mixin @, Serializable
  @::serialized "playerId"

  # For output to Max event loop.
  # 
  output: ->
    super ["done", @playerId]
