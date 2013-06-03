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
  DONE_EVENT_DELAY_BEATS: 0.05

  # Ur-gesture
  # 
  constructor: (gestureData) ->
    @deserialize gestureData,
      events: (data) -> new (Loom::Events[data.loadClass]) data
    @meter ?= @DEFAULT_METER
    @events ?= []
    if @events.length == 0
      @events.push new (Loom::Events["Note"])
        at: @nextDownbeat(@afterTime)
        duration: @meter
        deviceId: @deviceId

  # Return all MIDI events, plus done event and UI events for all devices.
  # 
  allEvents: (playerId) ->
    done = new (Loom::Events["Done"])
      at: @DONE_EVENT_DELAY_BEATS + Math.max (event.at for event in @events)...
      deviceId: @deviceId
      playerId: playerId
    uiEvents = []
    for module in @activatedModules
      uiEvents.push module.activated @startAt()
      for name, parameter of module.parameters when parameter.activated?
        uiEvents.push parameter.activated @startAt()
    return @events.concat(done).concat(uiEvents)

  # Return a clone of self, but scheduled after given time, and for a given
  # device.
  # 
  # Do all rescheduling math within the context of _this gesture's meter_, not
  # within global "beats".
  # 
  cloneAfterTime: (time, module) ->
    gestureData = extend @serialize(),
      afterTime: time
      activatedModules: [module.serialize()]
      deviceId: module.id

    oldAfterTimeMeter = @afterTime / @meter
    newAfterTimeMeter = time / @meter
    
    for event in gestureData.events
      atMeter = event.at / @meter
      phase = atMeter % 1
      numPhases = Math.floor(atMeter - oldAfterTimeMeter)
      newAtMeterTime =
        phase +
        numPhases +
        if newAfterTimeMeter % 1 > phase
          Math.ceil(newAfterTimeMeter)
        else
          Math.floor(newAfterTimeMeter)
      event.at = newAtMeterTime * @meter
      event.deviceId = module.id

    return new Gesture gestureData

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
