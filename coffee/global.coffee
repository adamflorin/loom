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

# Called when device is loaded and LiveAPI is available
# (bang from [live.thisdevice])
# 
init = ->
  try
    Loom::initDevice()
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
    Max::messageSelf(["resetObservers", Live::playerId(), "transport", "modules"])
  loaded = true
catch e
  logger.error e

# Is deviced enabled or "muted"?
# 
# This fires before 'init', so make sure module is loaded.
# 
enabled = (isEnabled) ->
  Loom::thisPlayer()?.muteModule Live::deviceId(), !isEnabled

# 
# 
generateGesture = ->
  try
    Loom::thisPlayer().generateGesture()
    Loom::thisPlayer().nextEvent()
  catch e
    logger.error e
  
# Output next event
# 
nextEvent = ->
  try
    Loom::thisPlayer().nextEvent()
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
    Loom::destroyDevice()
  catch e
    logger.error e

# Reset observers as requested by Loom::resetObservers()
# 
resetObservers = (observers...) ->
  try
    if observers.indexOf("modules") >= 0
      Loom::followModuleChange()
    if observers.indexOf("transport") >= 0
      Loom::followTransport()
  catch e
    logger.error e
