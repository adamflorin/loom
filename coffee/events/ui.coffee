# 
# ui.coffee: UI event
# 
# Copyright Adam Florin 2013
# 

class UI extends Event
  # 
  # 
  constructor: (at, forDevice, message, scheduleRemotely) ->
    @scheduleRemotely = scheduleRemotely
    @dispatchRemotely = not @scheduleRemotely
    super at, forDevice, message

  # 
  # 
  serialize: ->
    super ["ui"].concat @message
