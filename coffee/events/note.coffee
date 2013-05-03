# 
# note.coffee: One MIDI note
# 
# Copyright 2013 Adam Florin
# 

class Note extends Event
  
  DEFAULT_PITCH = 60
  DEFAULT_VELOCITY = 100

  # 
  # 
  constructor: (at, meter, forDevice) ->
    @pitch = DEFAULT_PITCH
    @velocity = DEFAULT_VELOCITY
    @duration = meter
    @scheduleRemotely = forDevice?
    @dispatchRemotely = false
    super at, forDevice

  # 
  # 
  serialize: ->
    super ["midi", "note", @pitch, @velocity, Max::beatsToTicks @duration]
