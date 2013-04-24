# 
# loom.coffee: Bootstrap Loom framework.
# 
# Copyright 2013 Adam Florin
# 

# init
# 
logger = new Logger
Max::initTooltips()

# If Loom object exists before it's declared below, then autowatch is reloading
# this script. All objects in memory are possibly from a previous version of
# code. Refresh everything of relevance.
# 
if Loom?
  logger.warn "Detected script reload"
  Live::resetCache()

class Loom
  # 
  # 
  players: ->
    (new Global("loom")).players ?= []

  # Get this player.
  # 
  thisPlayer: ->
    (player for player in @players() when player.id is Live::playerId())[0]
  
  # Rebuild players array, without specified player.
  # 
  destroyPlayer: (id) ->
    fewerPlayers = (player for player in @players() when player.id isnt id)
    (new Global("loom")).players = fewerPlayers
    logger.info "Destroyed player ID #{Live::playerId()}"

  # Send message to this player's devices
  # 
  refreshThisPlayer: ->
    @messageAllPlayers ["refreshPlayer", Live::playerId()]

  # Dispatch message to all devices of all players
  # 
  messageAllPlayers: (msg) ->
    outlet 1, msg
