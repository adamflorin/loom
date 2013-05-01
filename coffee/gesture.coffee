# 
# gesture.coffee
# 
# Copyright 2013 Adam Florin
# 

class Gesture

  DEFAULT_METER = 2

  # Ur-gesture
  # 
  constructor: (now, gestureArguments) ->
    {@meter} = gestureArguments
    @meter ?= DEFAULT_METER
    @afterTime = now
    @events = [new Note(@nextDownbeat(@afterTime), @meter)]

  # Gesture starts when its first event starts.
  # 
  startAt: ->
    Math.min (event.at for event in @events)...

  # Gesture ends when its last event ends.
  # 
  endAt: ->
    Math.max (event.endAt() for event in @events)...
  
  # 
  # 
  toEvents: ->
    @events

  # Find next downbeat (relative to internal meter).
  # 
  nextDownbeat: (time) ->
    Math.ceil(time / @meter) * @meter
