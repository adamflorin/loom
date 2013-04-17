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

    # TODO: get this player ID
    # 

  # 
  # 
  loadModule: (name) ->
    @modules.push Module::load name
    logger.info "Loaded module #{@name}"

  generateGesture: ->
    gesture = new Gesture
    gesture = module.processGesture(gesture) for module in @modules
    return gesture
