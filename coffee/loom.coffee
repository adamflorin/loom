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
  # Use special list comprehension trick to return one value, not an array.
  # 
  thisPlayer: ->
    onePlayer = player for player in @players() when player.id is Live::playerId()
    return onePlayer

  # Rebuild players array, without specified player.
  # 
  destroyPlayer: (id) ->
    fewerPlayers = (player for player in @players() when player.id isnt id)
    (new Global("loom")).players = fewerPlayers
    logger.info "Destroyed player ID #{Live::playerId()}"
