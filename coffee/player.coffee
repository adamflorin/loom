# 
# player.coffee
# 
# Copyright 2013 Adam Florin
# 

class Player

  # 
  # 
  constructor: (@id) ->
    @modules = []
    @clearGestures()
    logger.info "Player #{@id}: Created"

  # Build module, append to modules array.
  # 
  loadModule: (name, deviceId) ->
    @modules.push(
      module: new Loom::modules[name]
      id: deviceId
      probability: 1.0
      mute: 0)
    logger.info "Player #{@id}: Loaded module #{name} at #{deviceId}"

  # Rebuild modules array, without specified module.
  # 
  unloadModule: (deviceId) ->
    @modules = (module for module in @modules when module.id isnt deviceId)
    logger.info "Player #{@id}: Removed module at #{deviceId}"

  # Sort module list according to order of array argument.
  # 
  # *Note*: This will implicitly delete modules which have been removed.
  # 
  sortModules: (deviceIds) ->
    @modules = for deviceId in deviceIds
      modules = (module for module in @modules when module.id is deviceId)
      if modules.length then modules[0] else # (return nothing)
    logger.info "Player #{@id}: Sorted modules to [#{deviceIds}]"

  # Set paramenter for specified module.
  # 
  setModuleParameter: (deviceId, name, value) ->
    module[name] = value for module in @modules when module.id is deviceId

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
    for module in @activatedModules
      events.push new UI @nextGesture.startAt(), module.id, ["moduleActivated", "bang"]
    Loom::scheduleEvents events
    @pastGestures.push gesture: @nextGesture, modules: @activatedModules
    @nextGesture = null
    @activatedModules = []

  # Reset all gesture information, history and upcoming,
  # and notify patcher event scheduler to do the same.
  # 
  clearGestures: ->
    @pastGestures = []
    @nextGesture = null
    @activatedModules = []
    Loom::clearEventQueue()

  # Notification from patcher that all scheduled events have been dispatched.
  # 
  eventQueueEmpty: ->
    @applyModules "gestureOutputComplete"

  # Go through modules list in order and fire callback on each where applicable.
  # 
  # methodArgs can be anything. All modules which accept an argument commit to
  # returning an object of the same type as the argument.
  # 
  applyModules: (method, methodArgs) ->
    for module in @modules when module.mute is 0
      if module.module[method]?
        if Probability::flip(module.probability)
          @activatedModules.push module
          methodArgs = module.module[method](methodArgs)
          
    return methodArgs
