# 
# other.coffee: input menu to select other Loom player in this Live set.
# 
# Copyright 2013 Adam Florin
# 

class Loom::parameters.Other extends Parameter

  # 
  # 
  constructor: (@name, parameterData) ->
    {@playerIndex} = parameterData if parameterData?
    super parameterData

  # 
  # 
  serialize: ->
    extend super,
      playerIndex: @playerIndex

  # Send list of playerIds to Max [umenu].
  # 
  populate: ->
    allPlayerIds = (id for id in Player::allIds())
    Loom::scheduleEvents [
      new (Loom::eventClass("UI"))(
        deviceId: @moduleId(),
        message: ["parameter", @name, "playerIds"].concat(allPlayerIds))]

  # [pattr] only furnishes us with the index of the selected menu item.
  # Look that up in our own players listing.
  # 
  playerId: ->
    parseInt (id for id in Player::allIds())[@playerIndex]
