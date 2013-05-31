# 
# numeric.coffee: Just store a static number.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Parameters.Numeric extends Parameter
  mixin @, Serializable
  @::serialized "value"
