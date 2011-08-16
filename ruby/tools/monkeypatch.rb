# 
#  monkeypatch.rb: useful additions to basic Ruby objects
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 


# Monkeypatch Array so we can cleanly get SUM
#
class Array
  def sum
    inject( nil ) { |sum,x| sum ? sum+x : x }
  end
end

# So that we can do the neat Railsy syntax like array.map(&:method) in Ruby 1.8.6
# See http://jlaine.net/2008/5/8/amp-lified
#
class Symbol
  def to_proc
    lambda {|i| i.send(self)}
  end
end

# Constrainable so we can constrain all numbers (Fixnum & Float)
#
module Constrainable
  def constrain(range)
    if self > range.end
      return range.end
    elsif self < range.begin
      return range.begin
    else
      return self
    end
  end
end
class Fixnum
  include Constrainable
end
class Float
  include Constrainable
end

# To convert :symbol_names to ClassNames and back.
# 
class String
  def camelize
    self.gsub(/[^_]+/){|c| c.capitalize}.gsub('_', '')
  end
  
  def underscorize
    self.gsub(/[A-Z]/, "_\\0").gsub(/^_/, '').downcase
  end
end

# for Rails-like method chaining
# 
class Module
  def alias_method_chain(target, feature)
    alias_method "#{target}_without_#{feature}", target
    alias_method target, "#{target}_with_#{feature}"
  end
end
