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

  # Get player ID via module if module was loaded by player which would have
  # passed a handle to itself in.
  # 
  # Otherwise, we must have been created in global context, so global Live
  # helper should be fine.
  # 
  playerId: ->
    @module?.player?.id || Live::playerId()

  # Set parameter value.
  # 
  set: (name, value) ->
    @[name] = value

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
