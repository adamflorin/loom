# 
# module.coffee: Send message to module.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Events.Module extends Event
  mixin @, Serializable
  @::serialized "message"

  # For output to Max event loop.
  # 
  output: ->
    super ["ui", @message]
