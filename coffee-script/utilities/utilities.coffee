# 
# utilities.coffee: Global utility functions to extend basic JavaScript.
# 
# Not monkeypatching because then patched-in function turn up when serializing,
# etc.
# 
# Copyright 2013 Adam Florin
# 

# Support homebrew mixins so that classes can import other classes as mixins
# or so code for a given class may be visually divided into distinct packages.
# 
# Example:
# 
#   class Class
#     mixin @, Mixin:
#       method: ->
# 
# Or:
# 
#   class Mixin
#     method: ->
#   class Class
#     mixin @, Mixin
# 
# mixin() will determine which syntax is used (whether argument is a Function
# or an Object).
# 
mixin = (target, mixins) ->
  mixins = if objectType(mixins) is "Function" then {mixin: mixins::} else mixins
  for mixinName, mixinMethods of mixins
    target::[name] = method for name, method of mixinMethods

# Get string representation of object type, but more precise than typeof.
# 
objectType = (object) ->
  Object::toString.call(object).match(/(\S+)]$/)[1]

# De-dupe array.
# 
# http://coffeescriptcookbook.com/chapters/arrays/removing-duplicate-elements-from-arrays
# 
unique = (array) ->
  output = {}
  output[array[key]] = array[key] for key in [0...array.length]
  value for key, value of output

# Extend a source object with the properties of another object (shallow copy).
# 
# http://jashkenas.github.io/coffee-script/documentation/docs/helpers.html
# 
extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object
