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
    @id = Live::playerId()

  # 
  # 
  loadModule: (name) ->
    @modules.push Module::load name
    logger.info "Loaded module #{@name}"

  generateGesture: ->
    gesture = new Gesture
    gesture = module.processGesture(gesture) for module in @modules
    return gesture
