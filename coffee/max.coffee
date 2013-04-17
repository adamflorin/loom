# 
# max.coffee: integration with Max
# 
# Copyright 2013 Adam Florin
# 

# TODO: set up autowatch system
# 
# jsthis.autowatch = 1;

logger = null

class Max
  # 
  # 
  initTooltips: ->
    # ...
  
  # 
  # 
  patcherDirPath: ->
    patcher.filepath.match(/^(.+\/)([^/]+)$/)[1]

  # wrapper
  # 
  time: () -> max.time
