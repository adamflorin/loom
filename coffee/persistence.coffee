# 
# persistence.coffee: Mixin enabling simple persistence layer between Loom and
# [js]'s Global object.
# 
# Contains a mix of static and instance methods; context should make clear
# which are which.
# 
# Copyright 2013 Adam Florin
# 

class Persistence

  # Open up connection to data store
  # 
  connection: ->
    (new Global("loom"))

  # Return and cache string that we use as a JSON key to organize data.
  # 
  classKey: ->
    @key ?= @constructor.name.toLowerCase()

  # Static method to create instance of self and populate it with data stored
  # for that ID.
  # 
  # If loadClass is specified in data record, pass it to optional
  # classFromName callback to get the class to instantiate.
  # 
  load: (id, classFromName, constructorArgs) ->
    data = @allData()[id]
    loadClass = if data?.loadClass? then classFromName(data.loadClass) else @constructor
    logger.info "Loading previously nonexistant #{loadClass.name} #{id}" if not data?
    new loadClass id, data || {}, constructorArgs

  # Instantiate objects for all stored items.
  # 
  loadAll: ->
    allData = @allData()
    new @constructor id, allData[id] for id of allData
  
  # Invoke instantiated object's serialize method and store the result.
  # 
  save: ->
    @allData()[@id] = @serialize()

  # Destory data for this object.
  # 
  destroy: ->
    logger.info "Destroying #{@classKey()} #{@id}"
    @allData()[@id] = null

  # Static method to return complete array of all elements.
  # 
  allData: ->
    @connection()[@classKey()] ?= []
