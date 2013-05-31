# 
# parameter.coffee: Update value in a module's parameter.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Events.Parameter extends Event
  mixin @, Serializable
  @::serialized "patcher", "attribute", "value"

  # For output to Max event loop.
  # 
  output: ->
    super ["ui", "parameter", @patcher, @attribute].concat @value
