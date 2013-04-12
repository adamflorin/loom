# 
# logger.rb: basic logger for Loom
# 
#  Copyright 2013, Adam Florin. All rights reserved.
# 

require "logger"

# 
# 
module Loom
  class << self
    attr_accessor :logger
  end
end

# init logger with ANSI-escaped color
# 
Loom::logger = Logger.new File.join(LOOM_ROOT, "../log/loom.log")
Loom::logger.formatter = proc do |severity, datetime, progname, msg|
  colors = {
    debug: 37,
    info: 36,
    warn: 33,
    error: 31,
    fatal: 31
  }

  [ "\e[#{colors[severity.downcase.to_sym]}m",
    datetime.strftime("%H:%M:%S.%L"),
    severity,
    "#{msg}",
    "\e[0m\n"].join(" ")
end
