# 
# module.coffee: base class for modules
# 
# Copyright 2013 Adam Florin
# 

class Module extends Persistence
  
  # Reduce deviation to contain Gaussian random values.
  # 
  @::DEVIATION_REDUCE = 0.2

  # 
  # 
  constructor: (@id, moduleData, args) ->
    {@playerId, @probability, @mute, @mean, @deviation, @inertia} = moduleData
    {@player} = args if args
    @probability ?= 1.0
    @mute ?= 0

  # Serialize object data to be passed into constructor by Persistence later.
  # 
  # loadClass tells Persistence
  # 
  serialize: ->
    id: @id
    loadClass: @constructor.name
    playerId: @playerId
    probability: @probability
    mute: @mute
    value: @value
    mean: @mean
    deviation: @deviation
    inertia: @inertia

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

  # Generate a random value based on parameter input.
  # 
  generateValue: ->
    nextValue = Probability::gaussian(@mean, @deviation * @DEVIATION_REDUCE)
    nextValue = Probability::constrain nextValue
    @value = Probability::applyInertia (@lastValue() || nextValue), nextValue, @inertia

  # Get last output value from player's gesture history.
  # 
  lastValue: ->
    for gestureIndex in [Math.max(@player.pastGestures.length-1, 0)..0]
      if (gesture = @player.pastGestures[gestureIndex])?
        thisModule = module for module in gesture.activatedModules when module.id is @id
        return thisModule.value if thisModule?
