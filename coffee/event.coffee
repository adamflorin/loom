# 
# 
# 
# 
# 

class Event
  
  # 
  # 
  constructor: (@at) ->

  # TODO: refactor with UI event
  # 
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
    ["at", Max::beatsToTicks(@at), "midi", @constructor.name.toLowerCase()].concat data

  # When event ends
  # 
  endAt: ->
    @at + @duration || 0
