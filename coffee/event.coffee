# 
# 
# 
# 
# 

class Event
  
  # 
  # 
  constructor: (@at, @forDevice, @message) ->

  # Serialize self for output to event dispatch.
  # 
  # Invoked by subclasses.
  # 
  # Format is evolving. Examples:
  # 
  # NORMAL NOTE (scheduled locally, dispatched locally)
  # [
  #   "at", Max::beatsToTicks(@at),
  #   "local"
  # ].concat message
  # 
  # NORMAL UI EVENT (scheduled locally -> dispatched remotely)
  # [
  #   "at", Max::beatsToTicks(@at),
  #   "remote", "forDevice", @forDevice
  # ].concat message
  # 
  # NOTE SCHEDULED REMOTELY (scheduled remotely -> dispatched locally)
  # [
  #   "direct",
  #   "remote", "forDevice", @forDevice,
  #   "event",
  #   "at", Max::beatsToTicks(@at),
  #   "local"
  # ].concat message
  # 
  serialize: (message) ->
    message ?= @message
    
    atParams = if @at? then ["at", Max::beatsToTicks(@at)] else ["direct"]
    deviceParams = if @forDevice? then ["remote", "forDevice", @forDevice] else ["local"]

    if @scheduleRemotely
      ["direct"].concat(deviceParams, ["event"], atParams, ["local"], message)
    else if @dispatchRemotely
      atParams.concat(deviceParams, message)
    else
      atParams.concat(deviceParams, message)

  # When event ends
  # 
  endAt: ->
    @at + @duration || 0
