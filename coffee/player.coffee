# 
# player.coffee
# 
# Copyright 2013 Adam Florin
# 

class Player extends Persistence

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
      lastScheduledGesture = @pastGestures[-1..][0]
      lastGestureEndsAt = lastScheduledGesture?.gesture.endAt()
      gestureStartTime = if lastGestureEndsAt > time then lastGestureEndsAt else time
      @nextGesture = @generateGesture(gestureStartTime)
      @scheduleNextGesture()

  # Generate a gesture and store it in nextGesture.
  # 
  # Who is responsible for pushing next gesture onto queue?
  # 
  generateGesture: (time) ->
    gesture = @applyModules "processGesture", new Gesture(time)
    return gesture

  # Put nextGesture's events onto the queue, followed by relevant timed UI
  # events. Then drop nextGesture onto pastGestures history and clear
  # nextGesture and activatedModules.
  # 
  scheduleNextGesture: ->
    events = @nextGesture.toEvents()
    for moduleId in @activatedModuleIds
      events.push new UI @nextGesture.startAt(), moduleId, ["moduleActivated", "bang"]
    Loom::scheduleEvents events
    @pastGestures.push gesture: @nextGesture, modules: @activatedModuleIds
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

  # Go through modules list in order and fire callback on each where applicable.
  # 
  # Lazily load modules.
  # 
  # methodArgs can be anything. All modules which accept an argument commit to
  # returning an object of the same type as the argument.
  # 
  applyModules: (method, methodArgs) ->
    @modules ?= (Module::load moduleId, player: @ for moduleId in @moduleIds)
    for module in @modules when module.mute is 0
      if module[method]?
        if Probability::flip(module.probability)
          @activatedModuleIds.push module.id
          methodArgs = module[method](methodArgs)
    return methodArgs
