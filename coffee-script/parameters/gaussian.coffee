# 
# gaussian.coffee: Generate random numbers using Gaussian a.k.a. normal
# distribution.
# 
# Copyright 2013 Adam Florin
# 

class Loom::parameters.Gaussian extends Parameter

  # Reduce deviation to contain Gaussian random values.
  # 
  DEVIATION_REDUCE: 0.2

  # 
  # 
  constructor: (@name, parameterData) ->
    if parameterData?
      {@mean, @deviation, @inertia, @generatedValue} = parameterData
    @mean ?= 0.5
    @deviation ?= 0
    @inertia ?= 0
    super parameterData

  # 
  # 
  serialize: ->
    extend super,
      mean: @mean
      deviation: @deviation
      inertia: @inertia
      generatedValue: @generatedValue

  # Generate a random value based on parameter input.
  # 
  generateValue: ->
    nextValue = Probability::gaussian(
      @mean,
      @deviation * @DEVIATION_REDUCE)
    nextValue = Probability::constrain nextValue
    @generatedValue = Probability::applyInertia(
      @lastGeneratedValue() || nextValue,
      nextValue,
      @inertia)

  # Get last stored instance of our module, see if we were activated
  # 
  lastGeneratedValue: ->
    @module.atLastGesture()?.parameters[@name]?.generatedValue
    