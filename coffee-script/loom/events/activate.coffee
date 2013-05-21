# 
# activate.coffee: Notify module when it has been activated in a gesture.
# 
# Copyright 2013 Adam Florin
# 

class Loom::events.Activate extends Event

  # 
  # 
  constructor: (eventData) ->
    @deserialize eventData

  # For output to Max event loop.
  # 
  output: ->
    super ["ui", "moduleActivated", "bang"]
