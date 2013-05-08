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

# Utility for logger date formatting.
# 
# Pad integer with leading zeros so that it comes out to (at least) a certain
# number of digits.
# 
toZeroPaddedString = (number, digits) ->
  zeros =
    for powers in [Math.max(digits-1, 0)..1]
      if number < Math.pow(10, powers) then "0" else break
  zeros.join("") + number

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
