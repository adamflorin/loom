# 
# logger.coffee: Logging in Max 6
# 
# Copyright 2013 Adam Florin
# 

class Logger
  LOG_PATH = "/../log/wobbly.log"
  LOG_LEVELS = 
    debug: color: 37
    info: color: 36
    warn: color: 33
    error: color: 31
  ESCAPE_CHAR = String.fromCharCode(27)

  # 
  # 
  constructor: ->
    @initWriteMethods()
    @openFile()
  
  # Metaprogramming convenience functions
  # 
  initWriteMethods: ->
    for level of LOG_LEVELS
      do (level) =>
        @[level] = (msg) ->
          @write(msg, level)

  # Init File handle
  # 
  # Then immediately close, as File object will NOT re-open later
  # if autowatch reloads source while a File object is open.
  # 
  openFile: ->
    path = Max::patcherDirPath() + LOG_PATH
    @file = new File(path, "write")
    throw "Unable to open log file at #{path}" unless @file.isopen
    @file.close()

  # Log message
  # 
  write: (msg, level) ->
    @file.open()
    throw "Unable to open log file" unless @file.isopen
    @file.position = @file.eof
    @file.writeline @format(msg, level)
    @file.close()

  # Format log line
  # 
  format: (msg, level) ->
    @colorize "#{@timestamp()} #{level.toUpperCase()} #{msg}", level

  # Handcode time-to-string formatting
  # 
  timestamp: ->
    now = new Date
    "#{now.getFullYear()}-" +
      "#{(now.getMonth()+1).toZeroPaddedString(2)}-" +
      "#{now.getDate().toZeroPaddedString(2)} " +
      "#{now.getHours().toZeroPaddedString(2)}:" +
      "#{now.getMinutes().toZeroPaddedString(2)}:" +
      "#{now.getSeconds().toZeroPaddedString(2)}." +
      "#{now.getMilliseconds().toZeroPaddedString(3)}"

  # ANSI-style coloring
  # 
  colorize: (line, level) ->
    "#{ESCAPE_CHAR}[#{LOG_LEVELS[level].color}m#{line}#{ESCAPE_CHAR}[0m"

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
