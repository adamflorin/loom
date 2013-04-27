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
    @gestures = []
    @events = []
    @currentEvent = null
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

  # TODO
  # 
  play: (time) ->
    time ?= Live::now()
    # @generateGesture()
    # @nextEvent()

  # Generate a single gesture, let each module process it.
  # 
  generateGesture: (time) ->
    time ?= Live::now()

    if @gesturesAfter(time).length <= 1
      [gesture] = @applyModules "processGesture", new Gesture(time)
      @gestures.push gesture
      # logger.debug "Generated gesture for player #{@id}:", gesture
    else
      # logger.debug "Not generating a gesture"

  # Wipe out gesture history.
  # 
  clearGestures: ->
    @gestures = []

  # Select the earliest future event from the earliest future gesture.
  # 
  # If event queue is empty, populate it from upcoming gestures.
  # 
  nextEvent: (time) ->
    time ?= Live::now()

    # FIXME: need a record of which gestures have been flattened into events
    # 
    if @events.length == 0
      for gesture in @gesturesAfter(time)
        @events.push gesture.toEvents()...

    # select a current event
    # 
    @currentEvent = @events.shift()
    Loom::outputEvent @currentEvent.serialize() if @currentEvent

    if @events.length == 0
      @applyModules "noMoreEvents"

  # Go through modules list in order and fire callback on each where applicable.
  # 
  # TODO: pass splat to module method
  # 
  applyModules: (method, methodArgs...) ->
    for module in @modules when module.mute is off
      if module.module[method]?
        methodArgs = module.module[method](methodArgs)
    return methodArgs

  # Return gestures which end after a given time.
  # 
  # OPT: start counting at end of list and break when done.
  # 
  gesturesAfter: (time) ->
    gesture for gesture in @gestures when gesture.endAt() > time
