# 
# note.coffee: One MIDI note.
# 
# Copyright 2013 Adam Florin
# 

class Loom::events.Note extends Event
  
  # Defaults for the Ur-gesture.
  # 
  DEFAULT_PITCH: 60
  DEFAULT_VELOCITY: 100

  # 
  # 
  constructor: (eventData) ->
    {@duration, @pitch, @velocity} = eventData
    @pitch ?= @DEFAULT_PITCH
    @velocity ?= @DEFAULT_VELOCITY
    super eventData

  # For Persistence in Dict.
  # 
  serialize: ->
    extend super,
      pitch: @pitch
      velocity: @velocity
      duration: @duration

  # For output to Max event loop.
  # 
  output: ->
    super ["midi", "note", @pitch, @velocity, Max::beatsToTicks @duration]
