# 
# live.coffee: wrappers for LiveAPI
# 
# Copyright Adam Florin 2013
# 

class Live

  # Look up this device ID.
  # 
  # If @available flag isnt set, only serve cached copy. Accessing
  # LiveAPI when it's not available (e.g. device is being destroyed) can result
  # in bad data or even crashes.
  # 
  deviceId : ->
    if @available
      @thisDeviceId ?= @objectId "this_device"
    else if @thisDeviceId
      @thisDeviceId
    else
      logger.warn "Cached deviceId and LiveAPI are both unavilable"
      null

  # A "player" is defined as a group of modules which all
  # share the same parent. So our parent ID _is_ our player ID.
  # 
  # Path type will be "Chain" if device is wrapped in an Effect Rack.
  # Otherwise it will be "Track".
  # 
  playerId: ->
    if @available
      @thisPlayerId ?= @objectId "this_device canonical_parent"
    else if @thisPlayerId
      @thisPlayerId
    else
      logger.warn "Cached playerId and LiveAPI are both unavilable"
      null

  # Given a Live object ID, walk up ancestor tree to build a human-readable
  # name string of the form:
  # 
  #   Track > Rack > Etc.
  # 
  # If no object exists in the LOM at that ID, device has probably been deleted
  # and Global has yet to get updated by destroy handlers. Test for that case
  # and return placeholder text. (Could also check empty path or type
  # "unknown").
  # 
  humanName: (id) ->
    liveObject = new LiveAPI "id #{id}"
    return "[DESTROYED]" if parseInt(liveObject.id) isnt id
    ancestorNames = loop
      liveObject.path = @parentPath liveObject
      break if liveObject.path is "live_set"
      name = liveObject.get("name").toString()
      name unless name is "Chain"
    (name for name in ancestorNames when name?).reverse().join(" > ")

  # Return Live path to object at toId, attempting to return a relative path
  # from fromId if they're in the same track--otherwise, regular absolute path
  # is fine.
  # 
  # Use LiveAPI to get the paths, tokenize them, and process the tokens.
  # 
  relativePath: (toId, fromId) ->
    toPathTokens = @pathTokens toId
    fromPathTokens = @pathTokens fromId
    unless toPathTokens[0] is fromPathTokens[0]
      return "live_set #{toPathTokens.join(" ")}"
    else
      path = "this_device "
      for depth of toPathTokens
        if toPathTokens[depth] isnt fromPathTokens[depth]
          path += "canonical_parent " for n in [1..fromPathTokens.length-depth]
          path += toPathTokens[depth..].join(" ")
          break
      return path

  # Check that device was inserted into effects rack.
  # 
  deviceInRack: ->
    (new LiveAPI "this_device canonical_parent").type is "Chain"

  # Check that device was inserted into effects rack.
  # 
  transportPlaying: ->
    ((new LiveAPI "live_set").get "is_playing")[0] == 1

  # Return IDs of devices in this rack.
  # 
  siblingDeviceIds: ->
    deviceIds = (new LiveAPI "this_device canonical_parent").get "devices"
    if objectType(deviceIds) is "Array"
      id for id in deviceIds[1..] when id isnt "id"
    else
      logger.warn "LiveAPI returned bogus device IDs for this device's rack"
      []    

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

  # Return integer Live ID for object at given path.
  # 
  objectId: (path) ->
    parseInt((new LiveAPI path).id)

  # Remove superfluous punctuation from Live object path.
  # 
  objectPath: (liveObject) ->
    liveObject.path.replace(/"/g, '')

  # Utility: Return path to parent, given Live object.
  # 
  parentPath: (liveObject) ->
    "#{@objectPath liveObject} canonical_parent"

  # Return Live absolute path, broken into tokens given an ID.
  # 
  pathTokens: (id) ->
    path = @objectPath(new LiveAPI "id #{id}")
    path = path.replace "live_set ", ""
    path.match(/\w+ \d+/g)

  # Sanity check.
  # 
  # When LiveAPI is no longer available (i.e., device is being destroyed),
  # it will still return values as normal, but it'll be the same value over and
  # over, regardless of context. I.e., it'll return the same type (or ID, or 
  # property) for any path. So just compare the types for the app and the set.
  # 
  # NOTE: This check can crash Live in certain contexts, so be sparing with it.
  # 
  isAvailable: ->
    (new LiveAPI "live_app").type isnt (new LiveAPI "live_set").type

  # After a script reload, our "cache" globals will be lost.
  # Force populate them now in case the LiveAPI is no longer available
  # the next time they're needed (i.e., on destroy).
  # 
  resetCache: ->
    @thisDeviceId = undefined
    @thisPlayerId = undefined
    @deviceId() and @playerId()
