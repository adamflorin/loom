# 
# ui.coffee: UI event
# 
# Copyright Adam Florin 2013
# 

class Loom::events.UI extends Event
  # 
  # 
  constructor: (eventData) ->
    {@message} = eventData
    super eventData

  # For Persistence in Dict.
  # 
  serialize: ->
    extend super,
      message: @message

  # For output to Max event loop.
  # 
  output: ->
    super ["ui"].concat @message
