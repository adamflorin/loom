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

  # Transport has started
  # 
  transportStart: () ->
    @applyModules "transportStart"

  # Start playing: generate a gesture and output its events.
  # 
  play: (time) ->
    time ?= Live::now()
    unless @nextGesture?
      lastGestureEndsAt = @lastPastGesture()?.endAt()
      gestureStartTime = if lastGestureEndsAt > time then lastGestureEndsAt else time
      @nextGesture = @generateGesture(gestureStartTime)
      @scheduleNextGesture()

  # Generate a gesture and store it in nextGesture.
  # 
  # Provide two hooks for modules: gestureArguments (return )
  # 
  generateGesture: (time) ->
    gestureArguments = @applyModules "gestureArguments", {}
    @applyModules "processGesture", new Gesture(time, gestureArguments)

  # Schedule next gesture for dispatch, including both MIDI and UI events,
  # and archive it, including all player modules. Then clear everything.
  # 
  # Also, reap past gestures from earlier than our limit.
  # 
  scheduleNextGesture: ->
    @nextGesture.activatedModules = (module.serialize() for module in @modules)
    events = @nextGesture.toEvents()
    for moduleId in @activatedModuleIds
      events.push new UI @nextGesture.startAt(), moduleId, ["moduleActivated", "bang"]
      thisModule = module for module in @modules when module.id is moduleId
      for parameterName, parameter of thisModule.parameters when parameter.generatedValue?
        events.push new UI(
          @nextGesture.startAt(),
          moduleId,
          ["parameterValue", parameterName, parameter.generatedValue])
    Loom::scheduleEvents events
    @pastGestures.push @nextGesture
    @pastGestures.shift() while @pastGestures.length > @NUM_PAST_GESTURES
    @nextGesture = null

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

  # Lazily load modules.
  # 
  loadModules: ->
    @modules ?= (Module::load moduleId, player: @ for moduleId in @moduleIds)

  # Get last gesture that was output (typically to influence nextGesture).
  # 
  lastPastGesture: ->
    @pastGestures[-1..][0]
