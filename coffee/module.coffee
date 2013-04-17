# 
# module.coffee
# 
# Copyright 2013 Adam Florin
# 

class Module

  # player modules
  # 
  @::modules = {}

  # Register player modules here for instantiation later
  # 
  register: (module) ->
    @modules[module.name] = module

  # Load a player module by name
  # 
  load: (name) ->
    new @modules[name]
