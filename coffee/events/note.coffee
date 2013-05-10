# 
# note.coffee: One MIDI note
# 
# Copyright 2013 Adam Florin
# 

class Loom::events.Note extends Event
  
  DEFAULT_PITCH = 60
  DEFAULT_VELOCITY = 100

  # 
  # 
  constructor: (eventData) ->
    {@duration} = eventData
    @pitch = DEFAULT_PITCH
    @velocity = DEFAULT_VELOCITY
    super eventData

  # For Persistence in Dict.
  # 
  # TODO: factor out commonalities.
  # 
  serialize: ->
    at: @at
    forDevice: @forDevice
    loadClass: @constructor.name
    pitch: @pitch
    velocity: @velocity
    duration: @duration

  # For output to Max event loop.
  # 
  output: ->
    super ["midi", "note", @pitch, @velocity, Max::beatsToTicks @duration]
