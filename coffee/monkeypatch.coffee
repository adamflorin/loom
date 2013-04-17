# 
# monkeypatch.coffee
# 
# Copyright 2013 Adam Florin
# 

# Monkeypatch
# 
Number::toZeroPaddedString = (digits) ->
  zeros =
    for powers in [Math.max(digits-1, 0)..1]
      if this < Math.pow(10, powers)
        "0"
      else
        break
  zeros.join("") + this

# Utility monkeypatch so we can call .type() on any JS object
# to get its "class"
# 
Object::type = ->
  Object::toString.call(@).match(/(\S+)]$/)[1]
