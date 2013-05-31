# 
# echo.coffee: When remote player completes a gesture, repeat it.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Modules.Echo extends Module

  # Register UI inputs
  # 
  accepts: followed: "Other"

  # When remote player completes a gesture, grab its last gesture, clone it,
  # and put it on our own player's queue.
  # 
  remoteOutputComplete: (args) ->
    [remotePlayerId, time] = args
    if remotePlayerId is @parameters.followed.selectedPlayerId
      remotePlayer = Player::load remotePlayerId
      @echoedGesture = remotePlayer.lastPastGesture()?.cloneAfterTime(time, @)
      @player.play(time, @id)
    [remotePlayerId, time]

  # If we've been triggered by remote player in above API call, get last
  # gesture from remote player and insert it in the chain.
  # 
  # Otherwise, return gesture as usual.
  #
  processGesture: (gesture) ->
    if @echoedGesture
      gesture = @echoedGesture
      @echoedGesture = null
    return gesture
