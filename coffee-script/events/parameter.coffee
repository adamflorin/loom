# 
# parameter.coffee: Update value in a module's parameter.
# 
# Copyright 2013 Adam Florin
# 

class Loom::events.Parameter extends Event

  # 
  # 
  constructor: (eventData) ->
    {@patcher, @attribute, @value} = eventData
    super eventData

  # For Persistence in Dict.
  # 
  serialize: ->
    extend super,
      patcher: @patcher
      attribute: @attribute
      value: @value

  # For output to Max event loop.
  # 
  output: ->
    super ["ui", "parameter", @patcher, @attribute, @value]
