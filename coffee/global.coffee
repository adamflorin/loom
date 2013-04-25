# 
# global.coffee: all global entrypoint code, from (re-)initialization to
# Max messages accepted by [js] object's left inlet.
# 
# This file is loaded last, after all the APIs are ready.
# 
# *Note*: All code that's invoked globally--Max message inputs, API callbacks--
# should be wrapped in a try/catch that passes exceptions to logger. Otherwise
# they'll just go to Max console, which is suboptimal.
# 
# Copyright 2013 Adam Florin
# 

# init logger
# 
logger = new Logger

# Called when device is loaded and LiveAPI is available
# (bang from [live.thisdevice])
# 
# Load player and own module, then reset observers for all modules of this
# player. (Adding a device to a chain can knock out the other devices' observers).
# 
init = ->
  try
    Loom::createThisPlayer() unless Loom::thisPlayer()?
    Loom::loadThisPlayerModule()
    Loom::resetPlayerObservers ["transport", "modules"]
  catch e
    logger.error e

# Reload
# 
# If loaded flag is already set, then autowatch is reloading this script.
# 
# Clear memory and re-init everything. No need to wait for 'init' message this
# time as we know that LiveAPI is already available.
# 
try
  if loaded?
    logger.warn "Detected script reload"
    Live::resetCache()
    Loom::reloadThisPlayerModule()
    Max::messageSelf(["resetPlayerObservers", Live::playerId(), "transport", "modules"])
  loaded = true
catch e
  logger.error e

# Output next event
# 
nextEvent = ->
  try
    Loom::nextEvent()
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

    Loom::resetPlayerObservers ["transport", "modules"]
  catch e
    logger.error e

# Reset device chain observer, as it tends to go dark when device chain is
# updated. See Live::onPlayerUpdate().
# 
# Do this liberally, as there's no harm in registering this callback too many
# times (redundant but not very expensive).
# 
resetPlayerObservers = (playerId, observers...) ->
  try
    if playerId is Live::playerId()
      if observers.indexOf("modules") >= 0
        Loom::followModuleChange()
      if observers.indexOf("transport") >= 0
        Loom::followTransport()
  catch e
    logger.error e
