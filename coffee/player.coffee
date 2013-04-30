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
    @outputNextEvent(time)

  # Generate a gesture and store it in nextGesture.
  # 
  # Who is responsible for pushing next gesture onto queue?
  # 
  generateGesture: (time) ->
    gesture = @applyModules "processGesture", new Gesture(time)
    return gesture

  # Reset all gesture and event information, history and upcoming,
  # and notify patcher event scheduler to do the same.
  # 
  clearGestures: ->
    @pastGestures = []
    @nextGesture = null
    @events = []
    @currentEvent = null
    @activatedModules = []
    Loom::outputEvent new Clear

  # Confirmation from patcher that last event was either successfully
  # dispatched, or that it's definitely too late to dispatch it now anyway.
  # 
  eventComplete: ->
    @currentEvent = null
    @outputNextEvent()

  # Output next event in queue that is still in the future.
  # 
  # After outputting, provide hook for modules.
  # 
  outputNextEvent: (time) ->
    time ?= Live::now()
    unless @currentEvent?
      @scheduleNextGesture() if @nextGesture?
      while @currentEvent = @events.shift()
        if @currentEvent.at < time
          logger.warn "Skipping event before #{time}:", @currentEvent
        else
          Loom::outputEvent @currentEvent
          break
      @applyModules "gestureOutputComplete" if @events.length == 0

  # If scheduled event hasn't fired yet from [timepoint], it's not going to.
  # 
  # Log the warning and proceed as usual.
  # 
  clearOverdueEvents: (time) ->
    if time > @currentEvent?.at
      logger.warn "Event failed to dispatch before time #{time}:", @currentEvent
      @eventComplete()


  # Put nextGesture's events onto the queue, followed by relevant timed UI
  # events. Then drop nextGesture onto pastGestures history.
  # 
  scheduleNextGesture: ->
    @events.push @nextGesture.toEvents()...
    for module in @activatedModules
      @events.push new UI @nextGesture.startAt(), module.id, ["moduleActivated", "bang"]
    @pastGestures.push gesture: @nextGesture, modules: @activatedModules
    @nextGesture = null
    @activatedModules = []

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
