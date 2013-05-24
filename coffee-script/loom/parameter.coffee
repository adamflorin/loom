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
    {@module, @name} = parameterData if parameterData?

  # Use cached or fresh module ID.
  # 
  moduleId: ->
    @deviceId || @module?.id

  # Build UI event.
  # 
  # eventData must contain 'attribute' and 'value', and may optionally contain
  # 'at'.
  # 
  uiEvent: (eventData) ->
    new (Loom::Events["Parameter"])(
      extend(eventData,
        deviceId: @moduleId()
        patcher: @name))

  # Build and dispatch UI event.
  # 
  dispatchUIEvent: (eventData) ->
    Loom::scheduleEvents [@uiEvent(eventData)]
