# 
# count.coffee: number of notes in gesture.
# 
# Copyright 2013 Adam Florin
# 

class Loom::modules.Count extends Module

  # 
  # 
  @::MAX_COUNT = 4

  # Increase count by effectively repeating the whole gesture.
  # 
  # NOTE: Assumes basic note-based gestures.
  # 
  processGesture: (gesture) ->
    repeats = Math.round(@generateValue("count") * (@MAX_COUNT-1))
    repeatEvents = []
    for iteration in [1..repeats]
      for note in gesture.events
        repeatEvents.push new (Loom::eventClass("Note"))(
          at: note.at + (gesture.endAt()-gesture.startAt()) * iteration
          meter: note.duration
          forDevice: note.forDevice)
    gesture.events.push event for event in repeatEvents
    return gesture
