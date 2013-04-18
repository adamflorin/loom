# 
# live.coffee: wrappers for LiveAPI
# 
# Copyright Adam Florin 2013
# 

class Live

  # A "player" is defined as a group of modules which all
  # share the same parent. So our parent ID _is_ our player ID.
  # 
  # Path type will be "Chain" if device is wrapped in an Effect Rack.
  # Otherwise it will be "Track".
  # 
  playerId: ->
    (new LiveAPI "this_device canonical_parent").id

  # Get current time.
  # 
  now: ->
    (new LiveAPI "live_set").get("current_song_time")

  # Register for timing callbacks, at about 60ms intervals.
  # 
  bindToTime: (timeUpdate) ->
    api = new LiveAPI ((args...) -> timeUpdate args[1]), "live_set"
    api.property = "current_song_time"
    
