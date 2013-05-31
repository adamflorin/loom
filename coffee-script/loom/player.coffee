# 
# player.coffee: Generate Gestures by applying Modules in time.
# 
# Copyright 2013 Adam Florin
# 

class Player
  mixin @, Persisted
  mixin @, Serializable
  @::serialized "moduleIds", "pastGestures"
  
  # How many past gestures to store.
  # 
  NUM_PAST_GESTURES: 10

  # 
  # 
  constructor: (@id, playerData) ->
    @deserialize playerData,
      pastGestures: (data) -> new Gesture data
    @moduleIds ?= []
    @pastGestures ?= []
    @activatedModuleIds = []
  
  # Keep internal state in sync with Live.
  # 
  refreshModuleIds: ->
    @moduleIds = (id for id in Live::siblingDeviceIds() when Module::exists(id))

  # Transport has started
  # 
  transportStart: () ->
    @applyModules "transportStart"

  # Start playing: generate a gesture and output its events.
  # 
  # If the last generated gesture hasn't begun yet, don't generate. The
  # rule is that no player looks more than one gesture into the future.
  # 
  play: (time) ->
    time ?= Live::now()
    unless @lastPastGesture()?.startAt() > time
      gesture = @generateGesture(@nextGestureAfterTime(time))
      @scheduleGesture gesture

  # Generate a gesture.
  # 
  # Provide two hooks for modules: gestureData (return constructor args for
  # gesture), and processGesture.
  # 
  generateGesture: (time) ->
    gestureData = @applyModules "gestureData",
      deviceId: @outputModuleId()
      afterTime: time
    return @applyModules "processGesture", new Gesture(gestureData)

  # Schedule next gesture for dispatch, including both MIDI and UI events,
  # and archive it, including all player modules. Then clear everything.
  # 
  # Also, reap past gestures from earlier than our limit.
  # 
  scheduleGesture: (gesture) ->
    gesture.activatedModules =
      (module for module in @modules when module.id in @activatedModuleIds)
    Loom::scheduleEvents gesture.allEvents(), gesture.deviceId
    @pastGestures.push gesture
    @pastGestures.shift() while @pastGestures.length > @NUM_PAST_GESTURES

  # Reset all gesture information, history and upcoming,
  # and notify patcher event scheduler to do the same.
  # 
  clearGestures: ->
    @pastGestures = []
    Loom::clearEventQueue(@moduleIds)

  # Notification from patcher that all scheduled events have been dispatched.
  # 
  eventQueueEmpty: ->
    @applyModules "gestureOutputComplete"
    lastGestureEndsAt = @lastPastGesture()?.endAt()
    @applyModulesRemotely "remoteOutputComplete", [@id, lastGestureEndsAt]

  # Go through module list in order, firing callback on each where applicable.
  # 
  # methodArgs can be anything. All modules which accept an argument commit to
  # returning an object of the same type as the argument.
  # 
  applyModules: (method, methodArgs) ->
    @loadModules()
    for module in @modules when module.mute is 0
      if module[method]?
        if randomBoolean(module.probability)
          @activatedModuleIds.push module.id
          methodArgs = module[method](methodArgs)
    return methodArgs

  # Tell all other players to apply a module method.
  # 
  applyModulesRemotely: (method, methodArgs) ->
    for remotePlayerId in (id for id in @allIds() when parseInt(id) isnt @id)
      @update remotePlayerId, (remotePlayer) ->
        remotePlayer.applyModules(method, methodArgs)

  # Lazily load modules.
  # 
  loadModules: ->
    @modules ?= for moduleId in @moduleIds when Module::exists moduleId
      Module::load moduleId, player: @

  # Always output from last module in player. If output comes from an earlier
  # module, and module downstream are listening to MIDI input, unspecified
  # behavior may occur.
  # 
  outputModuleId: ->
    @moduleIds[-1..][0]

  # Next gesture should start after now, or end of last gesture, whichever is
  # later.
  # 
  nextGestureAfterTime: (time) ->
    lastGestureEndsAt = @lastPastGesture()?.endAt()
    return if lastGestureEndsAt > time then lastGestureEndsAt else time

  # Get last gesture that was output (typically to influence nextGesture).
  # 
  lastPastGesture: ->
    @pastGestures[-1..][0]
