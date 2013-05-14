# 
# gesture.coffee
# 
# Copyright 2013 Adam Florin
# 

class Gesture

  DEFAULT_METER = 2

  # Ur-gesture
  # 
  constructor: (gestureData) ->
    {@meter, @deviceId, @afterTime, @activatedModules} = gestureData
    @meter ?= DEFAULT_METER
    @events = for eventData in gestureData.events || []
      new (Loom::eventClass(eventData.loadClass)) eventData
    if @events.length == 0
      @events.push new (Loom::eventClass("Note"))(
        at: @nextDownbeat(@afterTime)
        duration: @meter
        deviceId: @deviceId)

  # 
  # 
  serialize: ->
    meter: @meter
    deviceId: @deviceId
    afterTime: @afterTime
    events: event.serialize() for event in @events
    activatedModules: @activatedModules

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
