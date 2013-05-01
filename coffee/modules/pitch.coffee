# 
# pitch.coffee: Set MIDI pitch
# 
# Copyright 2013 Adam Florin
# 

class Loom::modules.Pitch extends Module

  # 
  # 
  processGesture: (gesture) ->
    pitch = @generateValue("pitch") * 48 + 36
    note.pitch = pitch for note in gesture.events when note.constructor.name is "Note"
    return gesture
