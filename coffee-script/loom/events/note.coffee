# 
# note.coffee: One MIDI note.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Events.Note extends Event
  mixin @, Serializable
  @::serialized "pitch", "velocity", "duration"
  
  # Defaults for the Ur-gesture.
  # 
  DEFAULT_PITCH: 60
  DEFAULT_VELOCITY: 100

  # 
  # 
  constructor: (eventData) ->
    @deserialize eventData
    @pitch ?= @DEFAULT_PITCH
    @velocity ?= @DEFAULT_VELOCITY

  # For output to Max event loop.
  # 
  output: ->
    super ["midi", "note", @pitch, @velocity, beatsToTicks @duration]
