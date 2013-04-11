# 
#  loom.rb: Ruby generative music tools for MaxForLive
#  
#  Copyright 2010-2013, Adam Florin. All rights reserved.
# 

LOOM_ROOT = File.dirname(__FILE__)

require "logger"

# require core
# 
[ "loom/core_ext",
  "loom/tools/randomness",
  "loom/tools/timing",
  "loom/tools/tonality",
  "loom/max",
  "loom/environment",
  "loom/event",
  "loom/generator",
  "loom/gesture",
  "loom/player"].each do |file|
    require File.join(LOOM_ROOT, file)
  end

# require events + players
# 
Dir.glob(File.join(LOOM_ROOT, "/loom/event/*"), &method(:require))
Dir.glob(File.join(LOOM_ROOT, "/loom/player/*"), &method(:require))

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
