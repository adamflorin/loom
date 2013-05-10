# 
# 
# 
# 
# 

class Event
  
  # 
  # 
  constructor: (eventData) ->
    {@at, @forDevice, @message} = eventData

  # For output to Max event loop.
  # 
  # Invoked by subclasses.
  # 
  output: (message) ->
    message ?= @message
    atParams = if @at? then ["at", Max::beatsToTicks(@at)] else ["direct"]
    atParams.concat(message)

  # When event ends
  # 
  endAt: ->
    @at + @duration || 0
