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
setinletassist(0, "Loom message input")
setoutletassist(0, "Schedule next event")
setoutletassist(1, "Timed event output")

class Max

  # 
  # 
  patcherDirPath: ->
    patcher.filepath.match(/^(.+\/)([^/]+)$/)[1]

  # Use patcher scripting to create [comment] and [panel] objects to display
  # an error condition. Do it in patcher scripting so that the .amxd devices
  # are not responsible for keeping these objects around.
  # 
  # This code has some idiosyncrasies to appease Max. See especially: the
  # newline prepended to `message` (without which text will not wrap); the
  # differing sytnaxes for `newobject()` and `newdefault()`; the [button].
  # 
  displayError: (message) ->
    PADDING = 4
    DEVICE_HEIGHT = 170
    MINIMUM_DEVICE_WIDTH = 100
    deviceWidth = (@devicePatcher().getattr "rect")[2]

    # init panel
    panel = @devicePatcher().newdefault(
      0, 0,
      "panel",
      "@presentation", 1,
      "@presentation_rect",
        PADDING,
        PADDING,
        deviceWidth - PADDING * 2,
        DEVICE_HEIGHT - PADDING * 2,
      "@rounded", 8)
    panel.varname = "error_background"

    # init comment
    comment = @devicePatcher().newobject "comment"
    comment.presentation 1
    comment.presentation_rect(
      (deviceWidth - MINIMUM_DEVICE_WIDTH) / 2 + PADDING * 2,
      PADDING * 8,
      MINIMUM_DEVICE_WIDTH - PADDING * 4,
      DEVICE_HEIGHT - PADDING * 4)
    comment.fontsize 10
    comment.textjustification 1
    comment.set "\n" + message
    comment.varname = "error_text"

    # set to Live skin colors
    colors = @devicePatcher().newdefault 0, 0, "loom-colors"
    @devicePatcher().connect colors, 2, panel, 0
    @devicePatcher().connect colors, 3, comment, 0
    bang = @devicePatcher().newobject "button"
    @devicePatcher().connect bang, 0, colors, 0
    bang.bang()
    @devicePatcher().remove colors
    @devicePatcher().remove bang

    # tune opacity
    panel.bgcolor (panel.getattr "bgcolor")[0..2].concat [0.9]

    # bringtofront
    @devicePatcher().bringtofront panel
    @devicePatcher().bringtofront comment

  # Dismiss error created by displayError().
  # 
  dismissError: ->
    @devicePatcher().remove @devicePatcher().getnamed "error_background"
    @devicePatcher().remove @devicePatcher().getnamed "error_text"

  # Shorthand to .amxd device
  # 
  devicePatcher: ->
    patcher.parentpatcher.parentpatcher

  # Math utility
  # 
  beatsToTicks: (beats) ->
    beats * 480
