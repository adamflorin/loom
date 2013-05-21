# 
# gesture.coffee: A gesture is a collection of MIDI Events, as influenced by
# certain applicable Modules.
# 
# Copyright 2013 Adam Florin
# 

class Gesture
  mixin @, Serializable
  @::serialized "meter", "deviceId", "afterTime", "events", "activatedModules"

  DEFAULT_METER: 2

  # Ur-gesture
  # 
  constructor: (gestureData) ->
    @deserialize gestureData,
      events: (data) -> new (Loom::eventClass data.loadClass) data
    @meter ?= @DEFAULT_METER
    @events ?= []
    if @events.length == 0
      @events.push new (Loom::eventClass "Note")
        at: @nextDownbeat(@afterTime)
        duration: @meter
        deviceId: @deviceId

  # Gesture starts when its first event starts.
  # 
  startAt: ->
    Math.min (event.at for event in @events)...

  # Gesture ends when its last event ends.
  # 
  endAt: ->
    Math.max (event.endAt() for event in @events)...

  # Find next downbeat (relative to internal meter).
  # 
  nextDownbeat: (time) ->
    Math.ceil(time / @meter) * @meter
