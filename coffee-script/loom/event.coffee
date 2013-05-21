# 
# event.coffee: Ancestor class for all MIDI and UI events.
# 
# Note: Ancestor class should not be instantiated, only subclasses.
# 
# Copyright 2013 Adam Florin
# 

class Event
  mixin @, Serializable
  @::serialized "at", "deviceId"

  # For output to Max event loop.
  # 
  # Invoked by subclasses with subclass-specific message.
  # 
  output: (message) ->
    (if @at? then ["at", beatsToTicks @at] else ["direct"]).concat message

  # When event ends
  # 
  endAt: ->
    @at + @duration || 0
