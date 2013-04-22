# 
# gesture.coffee
# 
# Copyright 2013 Adam Florin
# 

class Gesture

  # half note
  DEFAULT_METER = 2

  # Ur-gesture
  # 
  constructor: (now) ->
    @meter = DEFAULT_METER
    @events = [new Note(@nextDownbeat(now), @meter)]

  # Gesture ends when its last event ends.
  # 
  endAt: ->
    Math.max (event.endAt() for event in @events)...
  
  # Find next downbeat (relative to internal meter).
  # 
  nextDownbeat: (time) ->
    Math.ceil(time / @meter) * @meter
