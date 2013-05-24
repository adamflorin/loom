# 
# module.coffee: Send message to module.
# 
# Copyright 2013 Adam Florin
# 

class Loom::events.Module extends Event
  mixin @, Serializable
  @::serialized "message"

  # 
  # 
  constructor: (eventData) ->
    @deserialize eventData

  # For output to Max event loop.
  # 
  output: ->
    super ["ui", @message]
