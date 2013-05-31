# 
# follow.coffee: When other players completes a gesture, begin one.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Modules.Follow extends Module

  # Register UI inputs
  # 
  accepts: followed: "RemotePlayer"

  # Module API contractually invoked by remote player upon scheduling a gesture.
  # 
  remoteOutputComplete: (args) ->
    [remotePlayerId, time] = args
    if remotePlayerId is @parameters.followed.selectedPlayerId
      @player.play(time, @id)
    [remotePlayerId, time]
