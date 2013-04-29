# 
# clear.coffee: Meta-event to clear schedule-event patcher.
# 
# Copyright Adam Florin 2013
# 

class Clear extends Event
  constructor: ->
  serialize: -> "clear"
