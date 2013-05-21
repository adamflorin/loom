# 
# parameter.coffee: Update value in a module's parameter.
# 
# Copyright 2013 Adam Florin
# 

class Loom::events.Parameter extends Event
  mixin @, Serializable
  @::serialized "patcher", "attribute", "value"

  # 
  # 
  constructor: (eventData) ->
    @deserialize eventData

  # For output to Max event loop.
  # 
  output: ->
    super ["ui", "parameter", @patcher, @attribute].concat @value
