# 
# module.coffee: base class for modules
# 
# Copyright 2013 Adam Florin
# 

class Module extends Persistence
  
  # 
  # 
  constructor: (@id, moduleData, args) ->
    {@playerId, @probability, @mute} = moduleData
    {@player} = args if args
    @probability ?= 1.0
    @mute ?= 0
    logger.info "Module #{@id}: Loaded"

  # Serialize object data to be passed into constructor by Persistence later.
  # 
  # loadClass tells Persistence
  # 
  serialize: ->
    loadClass: @constructor.name
    playerId: @playerId
    probability: @probability
    mute: @mute

  # Override Persistence's classKey, as Module is subclassable.
  # 
  classKey: -> "module"

  # Overwrite Persistence for convenience, as we always want the appropriate
  # subclass
  # 
  load: (id, constructorArgs) -> super id, Loom::moduleClass, constructorArgs

  # 
  # 
  player: -> Loom::player @playerId
