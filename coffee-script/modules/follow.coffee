# 
# follow.coffee: When other players completes a gesture, begin one.
# 
# Copyright 2013 Adam Florin
# 

class Loom::modules.Follow extends Module

  # Register UI inputs
  # 
  accepts: followed: "Other"

  # Module API contractually invoked by remote player upon scheduling a gesture.
  # 
  remoteOutputComplete: (args) ->
    [remotePlayerId, time] = args
    @player.play(time, @id) if remotePlayerId is @parameters.followed.playerId()
    [remotePlayerId, time]

  