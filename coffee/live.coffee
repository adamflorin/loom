# 
# live.coffee: wrappers for LiveAPI
# 
# Copyright Adam Florin 2013
# 

class Live

  # 
  # 
  deviceId: ->
    @thisDeviceId ?= parseInt (new LiveAPI "this_device").id

  # A "player" is defined as a group of modules which all
  # share the same parent. So our parent ID _is_ our player ID.
  # 
  # Path type will be "Chain" if device is wrapped in an Effect Rack.
  # Otherwise it will be "Track".
  # 
  playerId: ->
    @thisPlayerId ?= parseInt (new LiveAPI "this_device canonical_parent").id

  # Check that device was inserted into effects rack.
  # 
  deviceInRack: ->
    (new LiveAPI "this_device canonical_parent").type is "Chain"

  # Check if device has been moved to a new player. Do this by clearing and
  # repopulating ID cache.
  # 
  # If device has indeed changed players, return old player ID.
  # 
  detectPlayerChange: ->
    oldPlayerId = @thisPlayerId
    @thisPlayerId = undefined
    newPlayerId = @playerId()
    return oldPlayerId if oldPlayerId isnt newPlayerId

  # Get current time.
  # 
  now: ->
    (new LiveAPI "live_set").get("current_song_time")
  
  # After a script reload, our "cache" globals will be lost.
  # Force populate them now in case the LiveAPI is no longer available
  # the next time they're needed (i.e., on destroy).
  # 
  resetCache: ->
    @deviceId() and @playerId()
