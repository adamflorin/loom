# 
# max.coffee: integration with Max
# 
# Copyright 2013 Adam Florin
# 

# Max `jsthis` properties must be set globally without being declared with `var`.
# 
`autowatch = 1`
`outlets = 2`

# Tooltips
# 
setinletassist 0, "Loom message input"
setoutletassist 0, "Schedule next event"
setoutletassist 1, "Timed event output"

class Max

  # 
  # 
  patcherDirPath: ->
    patcher.filepath.match(/^(.+\/)([^/]+)$/)[1]

  # Use patcher scripting to create [comment] and [panel] objects to display
  # an error condition. Do it in patcher scripting so that the .amxd devices
  # are not responsible for keeping these objects around.
  # 
  # NOTE: Loading patchers or bpatchers here has a tendency to crash Live,
  # so only use native objects, which makes the code awfully verbose but more
  # robust.
  # 
  # This code has some idiosyncrasies to appease Max. See especially: the
  # newline prepended to `message` (without which text will not wrap); the
  # differing syntaxes for `newobject()` and `newdefault()`.
  # 
  displayError: (message) ->
    DEVICE_HEIGHT = 170
    MINIMUM_DEVICE_WIDTH = 100
    deviceWidth = @patcherPresentationWidth @devicePatcher(), true

    # init panel
    panel = @devicePatcher().newdefault(
      0, 0,
      "panel",
      "@presentation", 1,
      "@presentation_rect", 0, 0, deviceWidth, DEVICE_HEIGHT,
      "@rounded", 8,
      "@ignoreclick", 0)
    panel.varname = "error_background"

    # init comment
    comment = @devicePatcher().newobject "comment"
    comment.presentation 1
    comment.presentation_rect(
      (deviceWidth - MINIMUM_DEVICE_WIDTH) / 2, DEVICE_HEIGHT * 0.3,
      MINIMUM_DEVICE_WIDTH, DEVICE_HEIGHT)
    comment.fontsize 10
    comment.textjustification 1
    comment.set "\n#{message}"
    comment.varname = "error_text"

    # set to Live skin colors
    colorNames = ["macro_title", "control_fg"]
    colors = @devicePatcher().newdefault 0, 0, "live.colors"
    route = @devicePatcher().newdefault 0, 0, ["route"].concat colorNames
    bgPrepend = @devicePatcher().newdefault 0, 0, "prepend", "bgcolor"
    textPrepend = @devicePatcher().newdefault 0, 0, "prepend", "textcolor"
    @devicePatcher().connect colors, 0, route, 0
    @devicePatcher().connect route, 0, bgPrepend, 0
    @devicePatcher().connect route, 1, textPrepend, 0
    @devicePatcher().connect bgPrepend, 0, panel, 0
    @devicePatcher().connect textPrepend, 0, comment, 0
    colors.message name for name in colorNames
    @devicePatcher().remove object for object in [colors, route, bgPrepend, textPrepend]

    # tune opacity
    panel.bgcolor (panel.getattr "bgcolor")[0..2].concat [0.95]

    # bringtofront
    @devicePatcher().bringtofront panel
    @devicePatcher().bringtofront comment

  # Dismiss error created by displayError().
  # 
  dismissError: ->
    for name in ["error_background", "error_text"]
      @devicePatcher().remove @devicePatcher().getnamed name

  # Shorthand to .amxd device
  # 
  devicePatcher: ->
    patcher.parentpatcher.parentpatcher

  # Max tools to get a patcher's presentation rect are unreliable, and there's
  # no way to _read_ `devicewidth`. So, just calculate it by hand.
  # 
  # If checkSubPatchers is true, check subpatchers. Never true in recursive
  # calls.
  # 
  patcherPresentationWidth: (patcher, checkSubPatchers) ->
    width = rightmost = 0
    deviceObject = patcher.firstobject
    while deviceObject
      if deviceObject.subpatcher()? and checkSubPatchers
        rightmost = deviceObject.rect[0] +
          @patcherPresentationWidth deviceObject.subpatcher()
      else
        rect = deviceObject.getattr "presentation_rect"
        rightmost = rect[0] + rect[2] if rect?
      width = Math.max rightmost, width
      deviceObject = deviceObject.nextobject
    return width

  # Math utility
  # 
  beatsToTicks: (beats) ->
    beats * 480
