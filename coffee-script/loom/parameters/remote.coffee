# 
# remote.coffee: Input menu to select other Loom player in this Live set.
# 
# There are two forms for storing the selected player:
# 
# 1. Pass around IDs within a Live session,
# 2. But always persist LOM paths so that links can be restored when opening a
#    saved Live set.
# 
# To further complicate matters, the Max [umenu] object only stores its current
# index, not a value.
# 
# For those reasons, store three identifiers for selected player:
# 
# - index (within [umenu])
# - LOM ID
# - LOM path
# 
# ...and keep them all in sync with one another to handle the many possible
# cases.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Parameters.Remote extends Parameter
  mixin @, Serializable
  @::serialized "selectedPlayerIndex", "selectedPlayerPath", "selectedPlayerId"
  
  # Populate [umenu] with playerNames, and set up cached variables as
  # necessary.
  # 
  # This will be called on init time, and whenever any device or player is
  # moved within the Live set. Check existence of @selectedPlayerId to
  # determine which is the present scenario.
  # 
  # This is called only after all [pattr] params have been set.
  # 
  populate: ->
    playerNames = (Live::humanName id for id in @otherPlayerIds())
    @dispatchUIEvent
      attribute: "playerNames"
      value: if playerNames.length > 0 then playerNames else " "
    @setAll()
    unless not @selectedPlayerIndex?
      @dispatchUIEvent
        attribute: "selectedPlayerIndex"
        value: @selectedPlayerIndex
  
  # Intercept accessor to control what data is used when.
  # 
  # Default value for [pattr] comes in as 0, even for blobs like selectedPlayerPath.
  # Ignore it if so.
  # 
  # selectedPlayerIndex is the value from [umenu].
  # 
  # Note: selectedPlayerIndex may be bogus if module is being initialized from
  # saved Live set. Let it get set regardless, it'll be overwritten by the
  # next call to  setAll().
  # 
  # If user is setting selectedPlayerIndex [umenu], set path from index.
  # 
  set: (name, value) ->
    return if name is "selectedPlayerPath" and value is 0
    super name, value
    if name is "selectedPlayerIndex" and not @module.paramsInitializing
      @setAllFromIndex()
      @dispatchUIEvent
        attribute: "selectedPlayerPath"
        value: @selectedPlayerPath
  
  # Ensure that the trinity of player identifiers are all set, based on whichever
  # one or two happen to already be set.
  # 
  # This is important as modules will query @selectedPlayerId directly, and
  # populate depends on @selectedPlayerIndex being set.
  # 
  # Scenarios:
  # 
  # 0. @selectedPlayerId refers to a player that no longer exists. Clear it and
  # path and run through the next three scenarios afresh.
  # 
  # 1. ID is set. Consider it to be reliable. This may be a reload, or a device
  # has been moved or removed. Reset path in case device was moved, and update
  # index just to be safe.
  # 
  # 2. ID is not set, but path is. User has opened a saved Live set. Set other
  # two identifiers based on path.
  # 
  # 3. Neither ID nor path are set. User has just dropped module into a rack.
  # Index will have been set to 0 (default value), so just set everything based
  # on that so that internal values match what UI is depicting.
  # 
  setAll: ->
    if @selectedPlayerId? and not Player::exists @selectedPlayerId
      @selectedPlayerId = @selectedPlayerPath = null
      @selectedPlayerIndex = constrain(
        @selectedPlayerIndex,
        @otherPlayerIds().length-1)

    if @selectedPlayerId?
      @setIndexFromId()
      @setPathFromId()
    else
      if @selectedPlayerPath?
        @setAllFromPath()
      else
        @setAllFromIndex()

  # From @selectedPlayerPath, determine playerId, and @selectedPlayerIndex in turn.
  # 
  # If player specified by path is not available, it probably hasn't been
  # initialized yet. Just don't set either ID or index, and count on a
  # subsequent call to populate() to clear that up.
  # 
  setAllFromPath: ->
    playerId = Live::objectId @selectedPlayerPath
    playerIndex = @indexFromId playerId
    unless playerIndex is -1
      @selectedPlayerId = playerId
      @selectedPlayerIndex = playerIndex

  # From index, determine playerId, and @selectedPlayerPath in turn.
  # 
  setAllFromIndex: ->
    @setIdFromIndex()
    @setPathFromId() if @selectedPlayerId?

  # Cache path to player so that it is available if Live set is saved and
  # re-opened.
  # 
  setPathFromId: ->
    @selectedPlayerPath = Live::relativePath @selectedPlayerId, @moduleId()
  
  # 
  # 
  setIdFromIndex: ->
    @selectedPlayerId = @otherPlayerIds()[@selectedPlayerIndex]

  # Only set index if ID can be located in Global.
  # 
  setIndexFromId: ->
    playerIndex = @indexFromId @selectedPlayerId
    @selectedPlayerIndex = if playerIndex isnt -1 then playerIndex else 0

  # 
  # 
  indexFromId: (playerId) ->
    @otherPlayerIds().indexOf playerId

  # Return list of other player IDs.
  # 
  otherPlayerIds: ->
    id for id in Player::allIds() when id isnt @playerId()
