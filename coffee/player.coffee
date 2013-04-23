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
    logger.info "Created player ID #{@id}"

  # Build module, append to modules array.
  # 
  loadModule: (name, deviceId) ->
    @modules.push module: Module::load(name), id: deviceId
    logger.info "Loaded module #{name} at device ID #{deviceId} for player #{@id}"

  # Rebuild modules array, without specified module.
  # 
  unloadModule: (deviceId) ->
    @modules = (module for module in @modules when module.id isnt deviceId)
    logger.info "Removed module #{deviceId} from player #{@id}"

  # Generate a single gesture, let each module process it.
  # 
  generateGesture: (time) ->
    if @gesturesAfter(time).length == 0
      gesture = new Gesture(time)
      gesture = module.module.processGesture(gesture) for module in @modules
      @gestures.push gesture
      logger.debug "Generated gesture for player #{@id}:", gesture
    else
      logger.debug "Not generating a gesture"

  # Wipe out gesture history.
  # 
  clearGestures: ->
    @gestures = []
    logger.debug "Cleared gestures for player #{@id}"

  # Select the earliest future event from the earliest future gesture.
  # 
  # If event queue is empty, populate it from upcoming gestures.
  # 
  nextEvent: (time) ->
    if @events.length == 0
      for gesture in @gesturesAfter(time)
        @events.push event for event in gesture.events
    @events.shift().serialize()

  # Return gestures which end after a given time.
  # 
  # OPT: start counting at end of list and break when done
  # 
  gesturesAfter: (time) ->
    gesture for gesture in @gestures when gesture.endAt() > time
