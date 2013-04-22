# 
# 
# 
# 
# 

class Event
  
  # 
  # 
  constructor: (@at) ->

  # Serialize self for output to event dispatch.
  # 
  # Invoked by subclasses.
  # 
  # Format:
  # - at (time in beats)
  # - event name (stringified subclass name)
  # - [subclass data]
  # 
  serialize: (data) ->
    [Max::beatsToTicks(@at), @constructor.name.toLowerCase()].concat data

  # When event ends
  # 
  endAt: ->
    @at + @duration || 0
