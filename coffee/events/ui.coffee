# 
# ui.coffee: UI event
# 
# Copyright Adam Florin 2013
# 

class Loom::events.UI extends Event
  # 
  # 
  constructor: (eventData) ->
    super eventData

  # For Persistence in Dict.
  # 
  # TODO: factor out commonalities.
  # 
  serialize: ->
    at: @at
    forDevice: @forDevice
    loadClass: @constructor.name
    message: @message

  # For output to Max event loop.
  # 
  output: ->
    super ["ui"].concat @message
