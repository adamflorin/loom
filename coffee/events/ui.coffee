# 
# ui.coffee: UI event
# 
# Copyright Adam Florin 2013
# 

class UI extends Event
  # 
  # 
  constructor: (at, @deviceId, @message) ->
    super at

  # TODO: refactor with MIDI event serialize
  # 
  serialize: ->
    ["at", Max::beatsToTicks(@at), "ui", "forDevice", @deviceId].concat @message
