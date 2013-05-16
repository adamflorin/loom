# 
# live.coffee: wrappers for LiveAPI
# 
# Copyright Adam Florin 2013
# 

class Live

  # Look up this device ID.
  # 
  # If `available` flag isnt set, only serve cached copy. Accessing LiveAPI
  # when it's not available (e.g. device is being destroyed) can cause crashes.
  # 
  deviceId : ->
    return if @available
      @thisDeviceId ?= parseInt((new LiveAPI "this_device").id)
    else
      @thisDeviceId

  # A "player" is defined as a group of modules which all
  # share the same parent. So our parent ID _is_ our player ID.
  # 
  # Path type will be "Chain" if device is wrapped in an Effect Rack.
  # Otherwise it will be "Track".
  # 
  playerId: ->
    return if @available
      @thisPlayerId ?= parseInt((new LiveAPI "this_device canonical_parent").id)
    else 
      @thisPlayerId

  # Check that device was inserted into effects rack.
  # 
  deviceInRack: ->
    (new LiveAPI "this_device canonical_parent").type is "Chain"

  # Return IDs of devices in this rack.
  # 
  siblingDeviceIds: ->
    deviceIds = (new LiveAPI "this_device canonical_parent").get "devices"
    id for id in deviceIds[1..] when id isnt "id"

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

  # Get current time from Live, unless an override is specified.
  # 
  # Use overrides whenever possible, as it turns out that the LiveAPI
  # current_song_time we have access to is frequently if not always stale.
  # 
  now: (ignoreOverride) ->
    if Persistence::connection().overrideNow? and not ignoreOverride
      Persistence::connection().overrideNow
    else
      (new LiveAPI "live_set").get("current_song_time")

  # After a script reload, our "cache" globals will be lost.
  # Force populate them now in case the LiveAPI is no longer available
  # the next time they're needed (i.e., on destroy).
  # 
  resetCache: ->
    @thisDeviceId = undefined
    @thisPlayerId = undefined
    @deviceId() and @playerId()
