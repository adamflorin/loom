# 
# live.coffee: wrappers for LiveAPI
# 
# Copyright Adam Florin 2013
# 

# Store IDs at this scope so that we still have a handle to them
# once we lose access to LiveAPI on device removal.
# 
thisPlayerId = null
thisDeviceId = null

class Live

  # 
  # 
  deviceId: ->
    thisPlayerId ?= (new LiveAPI "this_device").id

  # A "player" is defined as a group of modules which all
  # share the same parent. So our parent ID _is_ our player ID.
  # 
  # Path type will be "Chain" if device is wrapped in an Effect Rack.
  # Otherwise it will be "Track".
  # 
  playerId: ->
    thisDeviceId ?= (new LiveAPI "this_device canonical_parent").id

  # Count sibling devices
  # 
  numSiblingDevices: ->
    (new LiveAPI "this_device canonical_parent devices").children[0]

  # Get current time.
  # 
  now: ->
    (new LiveAPI "live_set").get("current_song_time")

  # Transport start/stop callback
  # 
  onStartStop: (callback) ->
    @registerObserver "is_playing", callback

  # Timing callbacks, at ~60ms intervals.
  # 
  onTimeUpdate: (callback) ->
    @registerObserver "current_song_time", callback
  
  # Utility to register observer on Song object
  # 
  registerObserver: (property, callback) ->
    api = new LiveAPI(
      ((args) -> callback args[1] if args[0] is property),
      "live_set")
    api.property = property
