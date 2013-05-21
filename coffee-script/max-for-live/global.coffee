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

# Create global logger for development.
# 
logger = new Logger config.disableLogger?

# Pass all messages directly to Loom: initDevice, destroyDevice, etc.
# 
anything = ->
  try
    if Loom::[messagename]
      Loom::[messagename] arrayfromargs(arguments)...
    else
      throw new Error "Message \"#{messagename}\" not recognized"
  catch e
    logger.error e

# Destroy device data when removed.
# 
notifydeleted = ->
  try
    Loom::destroyDevice()
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
    logger.info "Detected script reload"
    Loom::initDevice()
  loaded = true
catch e
  logger.error e
