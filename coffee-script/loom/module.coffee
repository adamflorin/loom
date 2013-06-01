# 
# module.coffee: base class for modules
# 
# Copyright 2013 Adam Florin
# 

class Module
  mixin @, Persisted
  mixin @, Serializable
  @::serialized "id", "probability", "mute", "parameters", "paramsInitializing"

  # 
  # 
  constructor: (@id, moduleData, args) ->
    @deserialize moduleData,
      parameters: (data, name) => @buildParameter name, data
    @probability ?= 1.0
    @mute ?= 0
    @initParameters()
    {@player} = args if args

  # Init parameters based on values in `accepts` declaration in subclass. See
  # buildParameter.
  # 
  initParameters: ->
    @parameters ?= {}
    for name, parameterDefinition of @accepts
      @parameters[name] ?= @buildParameter name

  # Set module value.
  # 
  # Anything with a name of the form patcher::object is a parameter, unless
  # it's coming from `loom-module-ui`.
  # 
  # Determine parameter class based on what each module declared that it
  # accepts. Then instantiate class.
  # 
  # The rest are instance properties.
  # 
  set: (name, values) ->
    [all, major, separator, minor] = name.match(/([^:]*)(::)?([^:]*)/)
    if separator?
      if major is "loom-module-ui"
        @[minor] = values[0]
      else
        @setParameter major, minor,
          if values.length == 1 then values[0] else values
    else
      @[name] = values[0]

  # Set parameter property, optionally processing data if handler is specified
  # in the form:
  # 
  #   onParameterValue:
  #     <parameterName>:
  #       <propertyName>: (value) ->
  #         # ...
  # 
  setParameter: (parameterName, propertyName, value) ->
    setter = @onParameterValue?[parameterName]?[propertyName]
    @parameters[parameterName].set(
      propertyName,
      setter?.call(@, value) || value)

  # Builds parameter class based on module's `accepts` declaration of the form:
  # 
  #   accepts: <parameterName>: "<ParameterClass>"
  # 
  # Or, if parameter requries arguments:
  # 
  #   accepts: <parameterName>: ["<ParameterClass>", {arg: ...}]
  # 
  # parameterData is optional.
  # 
  buildParameter: (name, parameterData) ->
    parameterData ?= {}
    parameterDefinition = @accepts?[name]
    unless objectType(parameterDefinition) is "Array"
      parameterDefinition = [parameterDefinition]
    parameterClassName = parameterDefinition[0]
    parameterClass = Loom::Parameters[parameterClassName]
    unless not parameterClass?
      return new parameterClass extend(
        extend(parameterData,
          name: name,
          module: @),
        parameterDefinition[1])
    else
      logger.warn "No parameter class found for #{name}"
      return null

  # Hook for UI to populate itself.
  # 
  populate: ->
    unless @paramsInitializing
      parameter.populate?() for name, parameter of @parameters

  # Return event for when this module is activated.
  # 
  activated: (at) ->
    @uiEvent "moduleActivated", at

  # Build UI event.
  # 
  # 'at' is optional
  # 
  uiEvent: (message, at) ->
    new (Loom::Events["Module"])
      at: at
      deviceId: @id
      message: message

  # Work backwards through player's gesture history to access the last
  # serialized record for this module.
  # 
  # This historic record of past behavior can inform modules' decisions.
  # 
  atLastGesture: ->
    for gestureIndex in [Math.max(@player.pastGestures.length-1, 0)..0]
      if (gesture = @player.pastGestures[gestureIndex])?
        sameModule = do =>
          for module in gesture.activatedModules when module.id is @id
            return module
        return sameModule if sameModule?

  # Override Persisted's classKey, as Module is subclassable.
  # 
  classKey: -> "module"

  # Overwrite Persisted classFromName
  # 
  classFromName: (name) ->
    Loom::Modules[name]

  # Load player, assuming this is called in device's context.
  # 
  loadPlayer: ->
    Player::load Live::playerId()
