# 
# parameter.coffee: Base class for all module parameter types.
# 
# Each parameter type corresponds to a Max patcher.
# 
# Copyright 2013 Adam Florin
# 

class Parameter

  # 
  # 
  constructor: (parameterData) ->
    {@deviceId, @module} = parameterData if parameterData?
    
  # Called by subclasses, who promise to extend it into their return value.
  # 
  serialize: ->  
    deviceId: @module.id

  # Use cached or fresh module ID.
  # 
  moduleId: ->
    @deviceId || @module?.id
