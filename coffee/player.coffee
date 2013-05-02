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
    {@moduleIds, @pastGestures, @nextGesture} = playerData
    @moduleIds ?= []
    @pastGestures ?= []
    @activatedModuleIds = []

  # Serialize object data to be passed into constructor by Persistence later.
  # 
  serialize: ->
    moduleIds: @moduleIds
    pastGestures: @pastGestures
    nextGesture: @nextGesture

  # Let modules populate their UI elements.
  # 
  populate: ->
    @applyModules "populate"
  
  # Transport has started
  # 
  transportStart: () ->
    @applyModules "transportStart"

  # Start playing: generate a gesture and output its events.
  # 
  # If forPlayer is specified, all of those events must be individually
  # targeted to another player's device
  # 
  play: (time, forDevice) ->
    time ?= Live::now()
    unless @nextGesture?
      lastGestureEndsAt = @lastPastGesture()?.endAt()
      gestureStartTime = if lastGestureEndsAt > time then lastGestureEndsAt else time
      @nextGesture = @generateGesture(gestureStartTime, forDevice)
      @scheduleNextGesture(forDevice)

  # Generate a gesture and store it in nextGesture.
  # 
  # Provide two hooks for modules: gestureArguments (return )
  # 
  generateGesture: (time, forDevice) ->
    gestureArguments = @applyModules "gestureArguments", {forDevice: forDevice}
    @applyModules "processGesture", new Gesture(time, gestureArguments)

  # Schedule next gesture for dispatch, including both MIDI and UI events,
  # and archive it, including all player modules. Then clear everything.
  # 
  # Also, reap past gestures from earlier than our limit.
  # 
  scheduleNextGesture: (forDevice) ->
    events = @nextGesture.toEvents().concat(@gestureUiEvents(forDevice))
    Loom::scheduleEvents events.sort((x, y) -> x.at - y.at), forDevice
    @nextGesture.activatedModules = (module.serialize() for module in @modules)
    @pastGestures.push @nextGesture
    @pastGestures.shift() while @pastGestures.length > @NUM_PAST_GESTURES
    @nextGesture = null

  # Generate UI events for module patchers.
  # 
  gestureUiEvents: (forDevice) ->
    uiEvents = []
    at = @nextGesture.startAt()
    for moduleId in @activatedModuleIds
      uiEvents.push new UI(
        at,
        forDevice || moduleId,
        ["moduleActivated", "bang"],
        forDevice?)
      thisModule = module for module in @modules when module.id is moduleId
      for parameterName, parameter of thisModule.parameters when parameter.generatedValue?
        uiEvents.push new UI(
          at,
          forDevice || moduleId,
          ["parameterValue", parameterName, parameter.generatedValue],
          forDevice?)
    return uiEvents

  # Reset all gesture information, history and upcoming,
  # and notify patcher event scheduler to do the same.
  # 
  clearGestures: ->
    @pastGestures = []
    @nextGesture = null
    Loom::clearEventQueue()

  # Notification from patcher that all scheduled events have been dispatched.
  # 
  eventQueueEmpty: ->
    @applyModules "gestureOutputComplete"
    lastGestureEndsAt = (@nextGesture || @lastPastGesture())?.endAt()
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
    for remotePlayerId in (id for id of Player::allData() when parseInt(id) isnt @id)
      remotePlayer = @load remotePlayerId
      remotePlayer.applyModules(method, methodArgs)
      remotePlayer.save()

  # Lazily load modules.
  # 
  loadModules: ->
    @modules ?= (Module::load moduleId, player: @ for moduleId in @moduleIds)

  # Get last gesture that was output (typically to influence nextGesture).
  # 
  lastPastGesture: ->
    @pastGestures[-1..][0]
