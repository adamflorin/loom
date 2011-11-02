# 
#  core_ext.rb: useful additions to basic Ruby objects
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

# Numeric extensions
#
class Numeric
  
  # constrain number within a given range
  # 
  def constrain(range)
    if self > range.end
      return range.end
    elsif self < range.begin
      return range.begin
    else
      return self
    end
  end
  
  # to manage things like timescale shifts which for now 
  # must be divisible by 2
  # 
  def round_to_power(power = 2)
    power ** (Math.log(self) / Math.log(power)).round
  end
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
