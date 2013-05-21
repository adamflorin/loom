# 
# module.coffee: base class for modules
# 
# Copyright 2013 Adam Florin
# 

class Module
  mixin @, Persisted
  mixin @, Serializable
  @::serialized "id", "probability", "mute", "parameters"

  # 
  # 
  constructor: (@id, moduleData, args) ->
    @deserialize moduleData,
      parameters: (data, name) => @buildParameter name, extend(data, module: @)
    @probability ?= 1.0
    @mute ?= 0
    @parameters ?= {}
    {@player} = args if args

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
        @parameters[major] ?= @buildParameter major, module: @
        @parameters[major][minor] = if values.length == 1 then values[0] else values
    else
      @[name] = values[0]

  # 
  # 
  buildParameter: (name, parameterData) ->
    parameterClassName = @accepts?[name]
    parameterClass = Loom::parameterClass parameterClassName
    unless not parameterClass?
      new parameterClass name, parameterData
    else
      logger.warn "No parameter class found for #{name}"
      return null

  # Hook for UI to populate itself.
  # 
  populate: ->
    parameter.populate?() for name, parameter of @parameters

  # Work backwards through player's gesture history to acceess the last
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
  classFromName: Loom::moduleClass
