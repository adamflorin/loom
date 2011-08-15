# 
#  weather_feed_external.rb: get weather data from Yahoo!! API
#  
#  Copyright March 2011, JJS. All rights reserved.
# 

# IMPORTANT! To install hpricot for ajm.ruby's copy of JRuby,
# run this at the command line:
# 
# `sudo java -jar "/Applications/Max5/Cycling '74/java/lib/jruby.jar" -S gem install hpricot --user-install`

# Provides RSS parsing capabilities
require 'rubygems'
require 'hpricot'

# Allows open to access remote files
require 'open-uri'


# constant
# 
CONDITION_CODE_NON_PRECIPITATION_KEY = [19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,36,44]

# outlet labels
# 
outlet_assist('precipitation', 'temperature')


# query Yahoo! for weather info
# 
def get_weather(where)
  
  # What feed are we parsing?
  rss_feed = "http://weather.yahooapis.com/forecastrss?w=#{where}&u=f"

  # Variable for storing feed content
  rss_content = ""

  # Read the feed into rss_content
  open(rss_feed) do |f|
     rss_content = f.read
  end

  doc = Hpricot(rss_content)
  
  code = (doc/"channel"/"item"/"yweather:condition").first['code']
  precipitation = !(CONDITION_CODE_NON_PRECIPITATION_KEY.include?(code.to_i))
  
  temperature = (doc/"channel"/"item"/"yweather:condition").first['temp'].to_i
  
  outlet 0, precipitation
  outlet 1, temperature
end
