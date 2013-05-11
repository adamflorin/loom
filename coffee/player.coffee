# 
# player.coffee
# 
# Copyright 2013 Adam Florin
# 

class Player extends Persistence

  # How many past gestures to store.
  # 
  @::NUM_PAST_GESTURES = 10

  # 
  # 
  constructor: (@id, playerData) ->
    {@moduleIds} = playerData
    @pastGestures = for gestureData in playerData.pastGestures || {}
      new Gesture gestureData
    @moduleIds ?= []
    @pastGestures ?= []
    @activatedModuleIds = []

  # Serialize object data to be passed into constructor by Persistence later.
  # 
  serialize: ->
    moduleIds: @moduleIds
    pastGestures: gesture.serialize() for gesture in @pastGestures

  # Let modules populate their UI elements.
  # 
  populate: ->
    @applyModules "populate"
  
  # Keep internal state in sync with Live.
  # 
  refreshModuleIds: ->
    @moduleIds = Live::siblingDevices()

  # Transport has started
  # 
  transportStart: () ->
    @applyModules "transportStart"

  # Start playing: generate a gesture and output its events.
  # 
  # If the last generated gesture hasn't begun yet, don't generate. The
  # rule is that no player looks more than one gesture into the future.
  # 
  # If deviceId is specified, all of those events must be individually
  # targeted to another player's device.
  # 
  play: (time, deviceId) ->
    time ?= Live::now()
    deviceId ?= Live::deviceId()
    unless @lastPastGesture()?.startAt() >= time
      gesture = @generateGesture(@nextGestureAfterTime(time), deviceId)
      @scheduleGesture gesture

  # Generate a gesture.
  # 
  # Provide two hooks for modules: gestureData (return )
  # 
  generateGesture: (time, deviceId) ->
    gestureData = @applyModules "gestureData",
      deviceId: deviceId
      afterTime: time
    @applyModules "processGesture", new Gesture(gestureData)

  # Schedule next gesture for dispatch, including both MIDI and UI events,
  # and archive it, including all player modules. Then clear everything.
  # 
  # Also, reap past gestures from earlier than our limit.
  # 
  scheduleGesture: (gesture) ->
    events = gesture.toEvents().concat(@gestureUiEvents(gesture))
    Loom::scheduleEvents events
    gesture.activatedModules = (module.serialize() for module in @modules)
    @pastGestures.push gesture
    @pastGestures.shift() while @pastGestures.length > @NUM_PAST_GESTURES

  # Generate UI events for module patchers.
  # 
  gestureUiEvents: (gesture) ->
    uiEvents = []
    at = gesture.startAt()
    for moduleId in @activatedModuleIds
      uiEvents.push new (Loom::eventClass("UI"))(
        at: at
        deviceId: moduleId
        message: ["moduleActivated", "bang"])
      thisModule = module for module in @modules when module.id is moduleId
      for parameterName, parameter of thisModule.parameters when parameter.generatedValue?
        uiEvents.push new (Loom::eventClass("UI"))(
          at: at
          deviceId: moduleId
          message: ["parameterValue", parameterName, parameter.generatedValue])
    return uiEvents

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
        if Probability::flip(module.probability)
          @activatedModuleIds.push module.id
          methodArgs = module[method](methodArgs)
    return methodArgs

  # Tell all other players to apply a module method.
  # 
  applyModulesRemotely: (method, methodArgs) ->
    for remotePlayerId in (id for id in @allIds() when parseInt(id) isnt @id)
      remotePlayer = @load remotePlayerId
      remotePlayer.applyModules(method, methodArgs)
      remotePlayer.save()

  # Lazily load modules.
  # 
  loadModules: ->
    @modules ?= (Module::load moduleId, player: @ for moduleId in @moduleIds)

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
