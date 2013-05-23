# 
# gaussian.coffee: Generate random numbers using Gaussian a.k.a. normal
# distribution.
# 
# Copyright 2013 Adam Florin
# 

class Loom::parameters.Gaussian extends Parameter
  mixin @, Serializable
  @::serialized "mean", "deviation", "inertia", "generatedValue"

  # Reduce deviation to contain Gaussian random values.
  # 
  DEVIATION_REDUCE: 0.2

  # 
  # 
  constructor: (@name, parameterData) ->
    @deserialize parameterData
    super parameterData
    @mean ?= 0.5
    @deviation ?= 0
    @inertia ?= 0

  # Generate a random value based on parameter input.
  # 
  generateValue: ->
    nextValue = @gaussianRandom(@mean, @deviation * @DEVIATION_REDUCE)
    nextValue = constrain(nextValue)
    @generatedValue = @applyInertia(
      @lastGeneratedValue() || nextValue,
      nextValue,
      @inertia)

  # Get last stored instance of our module, see if we were activated
  # 
  lastGeneratedValue: ->
    @module.atLastGesture()?.parameters[@name]?.generatedValue

  # Build UI event when gesture is generated.
  # 
  activated: (at) ->
    @uiEvent(
      at: at
      deviceId: @module.id
      patcher: @name
      attribute: "generatedValue"
      value: @generatedValue)

  # Box Mueller algorithm for Gaussian or normal distribution.
  # 
  gaussianRandom: (mean, deviation) ->
    x1 = 0.0
    x2 = 0.0
    w = 0.0

    until w > 0.0 and w < 1.0
      x1 = 2.0 * Math.random() - 1.0
      x2 = 2.0 * Math.random() - 1.0
      w = ( x1 * x2 ) + ( x2 * x2 )

    w = Math.sqrt( -2.0 * Math.log( w ) / w )
    r = x1 * w

    mean + r * deviation
  
  # Given "start" and "end" values, move toward "end" value in proportion to
  # given "inertia" (0.0-1.0).
  # 
  applyInertia: (start, end, inertia) ->
    start + (end - start) * (1.0 - inertia)
