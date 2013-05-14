# 
# persistence.coffee: Simple persistence layer between Loom and [js]'s Globals.
# 
# Used for a few purposes:
# 
# 1. Persisted mixin provides tools to CRUD models.
# 2. deviceContext() stores JS context of each device's [js].
# 3. connection() may be used directly to store any old global, used
#    especially to correct bogus values from LiveAPI.
# 
# Copyright 2013 Adam Florin
# 

class Persistence

  # Open up connection to data store. Just namespace everything in "loom"
  # to be safe.
  # 
  connection: ->
    (new Global("loom"))

  # Hybrid getter/setter where each device stores its 'jsthis' so that other
  # devices may access one another's outlets. This is an important aspect of
  # event dispatch, enabling UI events for a number of devices to come from
  # the device that scheduled a gesture, and enabling devices to affect the
  # output of other devices in other players.
  # 
  deviceContext: (deviceId, object) ->
    @connection()["deviceContext"] ?= []
    if object
      @connection()["deviceContext"][deviceId] = object
    else
      @connection()["deviceContext"][deviceId]
