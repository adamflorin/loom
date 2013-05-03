# 
# 
# 
# 
# 

class Event
  
  # 
  # 
  constructor: (@at, @forDevice, @message) ->

  # Serialize self for output to event dispatch.
  # 
  # Invoked by subclasses.
  # 
  # Format is evolving.
  # 
  serialize: (message) ->
    message ?= @message
    atParams = if @at? then ["at", Max::beatsToTicks(@at)] else ["direct"]
    atParams.concat(message)

  # When event ends
  # 
  endAt: ->
    @at + @duration || 0
