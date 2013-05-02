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
    # logger.info "New UI event #{message}. scheduleRemotely #{@scheduleRemotely} but dispatchRemotely #{@dispatchRemotely}"
    
    super at, forDevice, message

  # 
  # 
  serialize: ->
    super @message
