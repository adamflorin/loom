# 
# messages.coffee: Max messages accepted by [js] object's left inlet.
# 
# Copyright 2013 Adam Florin
# 

# Called when device is loaded and LiveAPI is available
# (bang from [live.thisdevice])
# 
# Create player if it doesn't already exist, and load this module either way.
# Then notify all player devices, and sign up for some callbacks.
# 
init = ->
  try
    # Create player if not present
    # 
    if Live::numSiblingDevices() is 1
      Loom::players().push new Player(Live::playerId())

    # Load player module
    # 
    Loom::thisPlayer().loadModule jsarguments[1], Live::deviceId()

    # Notify all player devices
    # 
    Loom::refreshThisPlayer()

    # Callback on transport start/stop
    # 
    Live::onStartStop (playing) ->
      try
        if playing
          now = Live::now()

          # Live bizarrely sends 2x transport start events:
          # one _before_ the playhead has been reset to zero,
          # and one just after.
          # 
          # Anticipate this and consider that first "start" event
          # to be zero here.
          # 
          now = 0 if now > 0.1

          Loom::thisPlayer().generateGesture(now)
          nextEvent()
        else
          Loom::thisPlayer().clearGestures()
      catch e
        logger.error e

  catch e
    logger.error e

# Output next event
# 
nextEvent = ->
  try
    now = Live::now()
    event = Loom::thisPlayer().nextEvent(now)
    logger.debug "Outputting event", event
    outlet 0, event
  catch e
    logger.error e

# Called from [freebang]
# 
# By the time this is called, module may already have been removed
# from player. So just destroy player if no modules remain.
# Then tell all devices in this player to refresh themselves.
# 
# NOTE that LiveAPI is no longer available at this point.
# 
destroy = ->
  try
    Loom::thisPlayer().unloadModule Live::deviceId()

    if Loom::thisPlayer().modules.length is 0
      Loom::destroyPlayer Live::playerId()

    Loom::refreshThisPlayer()
  catch e
    logger.error e

# Do self-maintenance when environment has changed (device has been added or
# removed, or script reloaded). Do this liberally, as there's no harm in
# registering this callback too many times (redundant but not very expensive).
# 
# Currently, that means re-registering relevant Live API callbacks.
# 
refreshPlayer = (playerId) ->
  try
    if playerId is Live::playerId()
      Live::onPlayerUpdate (deviceIds) ->
        try
          Loom::thisPlayer().sortModules(deviceIds)
        catch e
          logger.error e
  catch e
    logger.error e
