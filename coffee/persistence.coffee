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

  # Static function to just get data for specified object.
  # 
  # (Init data store for this class if necessary.)
  # 
  data: (id) ->
    @connection()[@classKey()] ?= []
    data = @connection()[@classKey()][id]
    # logger.debug "Loading data for #{@classKey()} #{id}", data
    return data

  # Static method to create instance of self and populate it with data stored
  # for that ID.
  # 
  # If loadClass is specified in data record, pass it to optional
  # classFromName callback to get the class to instantiate.
  # 
  load: (id, classFromName, constructorArgs) ->
    data = @data(id)
    loadClass = if data?.loadClass? then classFromName(data.loadClass) else @constructor
    logger.info "Creating #{loadClass.name} #{id}" if not data?
    new loadClass id, data || {}, constructorArgs

  # Invoke instantiated object's serialize method and store the result.
  # 
  save: ->
    # logger.debug "Saving data for #{@classKey()} #{@id}:", @serialize()
    @connection()[@classKey()][@id] = @serialize()

  # Destory data for this object.
  # 
  destroy: ->
    logger.debug "Destroying #{@classKey()} #{@id}"
    @connection()[@classKey()][@id] = null
