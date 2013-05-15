# 
# module.coffee: base class for modules
# 
# Copyright 2013 Adam Florin
# 

class Module
  
  mixin @, Persisted

  # Reduce deviation to contain Gaussian random values.
  # 
  @::DEVIATION_REDUCE = 0.2

  # 
  # 
  constructor: (@id, moduleData, args) ->
    {@probability, @mute, @parameters} = moduleData
    {@player} = args if args
    @probability ?= 1.0
    @mute ?= 0
    @parameters ?= {}

  # Serialize object data to be passed into constructor by Persisted later.
  # 
  # loadClass tells Persisted which subclass to instantiate.
  # 
  serialize: ->
    id: @id
    loadClass: @constructor.name
    probability: @probability
    mute: @mute
    parameters: @parameters

  # Set module value.
  # 
  # Anything with a name of the form patcher::object is a parameter, unless
  # it's coming from `loom-module-ui`.
  # 
  # The rest are instance properties.
  # 
  set: (name, values) ->
    [all, major, separator, minor] = name.match(/([^:]*)(::)?([^:]*)/)
    if separator?
      if major is "loom-module-ui"
        @[minor] = values[0]
      else
        @parameters[major] ?= {}
        @parameters[major][minor] = if values.length == 1 then values[0] else values
    else
      @[name] = values[0]


  # Override Persisted's classKey, as Module is subclassable.
  # 
  classKey: -> "module"

  # Overwrite Persisted classFromName
  # 
  classFromName: Loom::moduleClass

  # Generate a random value based on parameter input.
  # 
  generateValue: (parameterName) ->
    parameter = @parameters[parameterName] || @defaultParameter()
    nextValue = Probability::gaussian(
      parameter.mean,
      parameter.deviation * @DEVIATION_REDUCE)
    nextValue = Probability::constrain nextValue
    parameter.generatedValue = Probability::applyInertia(
      (@lastValue(parameterName) || nextValue),
      nextValue,
      parameter.inertia)

  # Count backwards from end to beginning of player's gesture history to find
  # last generated output from this module.
  # 
  lastValue: (parameterName) ->
    for gestureIndex in [Math.max(@player.pastGestures.length-1, 0)..0]
      if (gesture = @player.pastGestures[gestureIndex])?
        thisModule = module for module in gesture.activatedModules when module.id is @id
        return thisModule.parameters[parameterName]?.generatedValue if thisModule?

  # Failsafe default parameter.
  # 
  defaultParameter: ->
    mean: 0.5, deviation: 0, inertia: 0
