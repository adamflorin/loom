# 
# event.coffee: Ancestor class for all MIDI and UI events.
# 
# Copyright 2013 Adam Florin
# 

class Event
  
  # 
  # 
  constructor: (eventData) ->
    {@at, @deviceId} = eventData

  # Called by subclasses, who promise to extend it into their return value.
  # 
  serialize: ->
    at: @at
    deviceId: @deviceId
    loadClass: @constructor.name

  # For output to Max event loop.
  # 
  # Invoked by subclasses with subclass-specific message.
  # 
  output: (message) ->
    (if @at? then ["at", Max::beatsToTicks(@at)] else ["direct"]).concat message

  # When event ends
  # 
  endAt: ->
    @at + @duration || 0
