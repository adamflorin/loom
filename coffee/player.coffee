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
      mute: off)
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

  # Mute module, if present.
  # 
  muteModule: (deviceId, mute) ->
    module.mute = mute for module in @modules when module.id is deviceId

  # Return the ID of our designated "output module".
  # By convention, make this the last module.
  # 
  # See Loom::messagePlayerOutputDevice().
  # 
  outputModuleId: ->
    @modules[-1..][0].id

  # Transport has started
  # 
  transportStart: (time) ->
    @applyModules "transportStart", time

  # Start playing: generate a gesture and output its events.
  # 
  play: (time) ->
    time ?= Live::now()
    unless @nextGesture?
      lastScheduledGesture = @pastGestures[-1..][0]
      gestureStartTime = lastScheduledGesture?.endAt() || time
      @nextGesture = @generateGesture(gestureStartTime)
    @outputNextEvent()

  # Generate a gesture and store it in nextGesture.
  # 
  # Who is responsible for pushing next gesture onto queue?
  # 
  generateGesture: (time) ->
    [gesture] = @applyModules "processGesture", new Gesture(time)
    return gesture

  # Reset all gesture and event information, history and upcoming,
  # and notify patcher event scheduler to do the same.
  # 
  clearGestures: ->
    @pastGestures = []
    @nextGesture = null
    @events = []
    @currentEvent = null
    Loom::outputEvent "clear"

  # Input from patcher confirming that last event was successfully dispatched.
  # 
  eventTriggered: ->
    @currentEvent = null
    @outputNextEvent()

  # Output next event in gesture.
  # 
  # After outputting, provide hook for modules.
  # 
  outputNextEvent: ->
    unless @currentEvent?
      @scheduleNextGesture() if @nextGesture?
      @currentEvent = @events.shift()
      Loom::outputEvent @currentEvent if @currentEvent
      @applyModules "gestureOutputComplete" if @events.length == 0

  # Take nextGesture, put its events on the event queue, and put it into
  # pastGestures.
  # 
  scheduleNextGesture: ->
    @events.push @nextGesture.toEvents()...
    @pastGestures.push @nextGesture
    @nextGesture = null

  # Go through modules list in order and fire callback on each where applicable.
  # 
  # TODO: pass splat to module method
  # 
  applyModules: (method, methodArgs...) ->
    for module in @modules when module.mute is off
      if module.module[method]?
        methodArgs = module.module[method](methodArgs)
    return methodArgs
