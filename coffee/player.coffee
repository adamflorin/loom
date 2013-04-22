# 
# player.coffee
# 
# Copyright 2013 Adam Florin
# 

class Player

  # 
  # 
  constructor: () ->
    @modules = []
    @gestures = []
    @events = []
    @id = Live::playerId()

  # 
  # 
  loadModule: (name) ->
    @modules.push Module::load name
    logger.info "Loaded module #{name}"

  # Generate a single gesture, let each module process it.
  # 
  generateGesture: (time) ->
    if @gesturesAfter(time).length == 0
      gesture = new Gesture(time)
      gesture = module.processGesture(gesture) for module in @modules
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
