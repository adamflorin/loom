# 
#  rescuable.rb: cleanest way to get rich exception logging in ajm.ruby
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 

# wrapper for Max methods to rescue exceptions and display them nicely
#
def rescuable(&block)
  yield
rescue Exception => e
  error "#{e.class}: #{$!}", $@.map{|l| "  #{l}"}
end

# Now make this sure is applied to (global) Max methods
#
# Must attach this to Object as that's where global methods end up.
#
def Object.init_rescuable(ms)
  ms.each do |m|
    m_core = "#{m.to_s}_core".to_sym
    alias_method m_core, m
    define_method m do |*args|
      rescuable do
        send(m_core, *args)
      end
    end
  end
end
