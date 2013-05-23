# 
# parameter.coffee: Base class for all module parameter types.
# 
# Each parameter type corresponds to a Max patcher.
# 
# Note: Ancestor class should not be instantiated, only subclasses.
# 
# Copyright 2013 Adam Florin
# 

class Parameter
  mixin @, Serializable
  @::serialized "deviceId"

  # Note: subclass is reponsible for calling deserialize().
  # 
  constructor: (parameterData) ->
    {@module} = parameterData if parameterData?

  # Use cached or fresh module ID.
  # 
  moduleId: ->
    @deviceId || @module?.id

  uiEvent: (eventData) ->
    new (Loom::eventClass "Parameter") eventData

