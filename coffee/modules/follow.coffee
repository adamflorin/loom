# 
# follow.coffee: When other players completes a gesture, begin one.
# 
# Copyright 2013 Adam Florin
# 

class Loom::modules.Follow extends Module

  # Populate UI
  # 
  populate: ->
    allPlayerIds = (id for id in Player::allIds())
    Loom::scheduleEvents [new UI(null, @id, ["playerIds"].concat(allPlayerIds))]

  # Module API contractually invoked by remote player upon scheduling a gesture.
  # 
  remoteOutputComplete: (args) ->
    [remotePlayerId, time] = args
    @player.play(time, @id) if remotePlayerId is @followingPlayerId()
    [remotePlayerId, time]

  # [pattr] only furnishes us with the index of the selected menu item.
  # Look that up in our own players listing.
  # 
  followingPlayerId: ->
    parseInt (id for id in Player::allIds())[@parameters.followed?.playerIndex]
