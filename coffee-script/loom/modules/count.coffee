# 
# count.coffee: number of notes in gesture.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Modules.Count extends Module

  # 
  # 
  MAX_COUNT: 4

  # Register UI inputs
  # 
  accepts: count: ["Gaussian", bands: @::MAX_COUNT]

  # Increase count by effectively repeating the whole gesture.
  # 
  # NOTE: Assumes basic note-based gestures.
  # 
  processGesture: (gesture) ->
    repeats = Math.floor(@parameters.count.generateValue() * @MAX_COUNT)
    repeatEvents = []
    if repeats > 0
      for iteration in [1..repeats]
        for note in gesture.events
          repeatEvents.push new (Loom::Events["Note"])
            at: note.at + (gesture.endAt()-gesture.startAt()) * iteration
            duration: note.duration
            deviceId: note.deviceId
    gesture.events.push event for event in repeatEvents
    return gesture
