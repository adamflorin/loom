# 
# other.coffee: input menu to select other Loom player in this Live set.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Parameters.Other extends Parameter
  mixin @, Serializable
  @::serialized "playerIndex"

  # 
  # 
  constructor: (parameterData) ->
    @deserialize parameterData
    super parameterData

  # Send list of playerIds to Max [umenu].
  # 
  populate: ->
    @dispatchUIEvent
      attribute: "playerIds"
      value: (id for id in Player::allIds())
  
  # [pattr] only furnishes us with the index of the selected menu item.
  # Look that up in our own players listing.
  # 
  playerId: ->
    parseInt (id for id in Player::allIds())[@playerIndex]
