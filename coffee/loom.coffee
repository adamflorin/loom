# 
# loom.coffee: Bootstrap Loom framework.
# 
# Copyright 2013 Adam Florin
# 

# init
# 
logger = new Logger
Max::initTooltips()

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
    allPlayers = @players()
    allPlayers = (player for player in allPlayers when player.id isnt id)
    logger.info "Destroyed player ID #{Live::playerId()}"
