# 
# parameter-ui.coffee: Visualize normal distribution of probability values.
# 
# Copyright 2013 Adam Florin
# 

# Autowatch
# 
`autowatch = 1`

# 
# 
AREA =
  width: 90
  height: 50

# Init graphics
# 
mgraphics.init()
mgraphics.relative_coords = 0
mgraphics.autofill = 0
mgraphics.set_line_cap "butt"
mgraphics.set_line_join "miter"

# Mouse input: Update internal state, and output to patcher.
# 
onclick = ondrag = (x, y) ->
  mean = Math.min(Math.max(x, 0), AREA.width) / AREA.width
  deviation = 1 - Math.min(Math.max(y, 0), AREA.height) / AREA.height
  GaussianCurve::set "mean", mean
  GaussianCurve::set "deviation", deviation
  outlet 0, ["mean", mean]
  outlet 0, ["deviation", deviation]

# Max message inputs
# 
# The following are Live rgba colors:
#   surface_bg, contrast_frame, selection, control_text_bg
# 
anything = -> GaussianCurve::set messagename, arrayfromargs(arguments)...
paint = -> GaussianCurve::draw()

# 
# 
class GaussianCurve

  # 
  # 
  @::CORNER_RADIUS = 8
  @::DEVIATION_PIXEL_COEFFICIENT = 32
  @::ANIMATION_FRAMES = 5
  @::ANIMATION_FRAME_RATE = 10

  # Set parameter.
  # 
  set: (key, value...) ->
    @[key] = value
    if key is "activatePosition"
      @startLineAnimation()
    else
      mgraphics.redraw()

  # Draw all, making sure necessary params are set.
  # 
  draw: ->
    @drawBackground() if @contrast_frame? and @surface_bg?
    @drawCurve() if @mean? and @deviation? and @selection?
    @drawPosition() if @linePosition? and @selection?

  # Draw background and corners.
  # 
  drawBackground: ->
    mgraphics.set_source_rgba @contrast_frame...
    mgraphics.rectangle 0, 0, AREA.width, AREA.height
    mgraphics.fill_with_alpha 1.0
    for x in [0, AREA.width]
      for y in [0, AREA.height]
        @drawCorner x: x, y: y

  # Roll our own rounded corners to resemble [panel]'s.
  # 
  drawCorner: (corner) ->
    mgraphics.new_path()
    mgraphics.move_to corner.x, corner.y
    mgraphics.line_to(
      (if corner.x > 0 then corner.x - @CORNER_RADIUS else @CORNER_RADIUS), corner.y)
    mgraphics.curve_to(
      corner.x, corner.y,
      corner.x, corner.y,
      corner.x, (if corner.y > 0 then corner.y - @CORNER_RADIUS else @CORNER_RADIUS))
    mgraphics.line_to corner.x, corner.y
    mgraphics.close_path()
    mgraphics.set_source_rgba @surface_bg...
    mgraphics.fill_with_alpha 1.0
    mgraphics.restore()

  # Crude approxmiation of Gaussian distribution curve.
  # 
  drawCurve: ->
    midpoint = @mean * AREA.width
    margin = @deviation * @DEVIATION_PIXEL_COEFFICIENT
    top = 2
    mgraphics.new_path()
    mgraphics.move_to midpoint - AREA.width, AREA.height
    mgraphics.curve_to(
      midpoint - margin, AREA.height,
      midpoint - margin, top,
      midpoint, top)
    mgraphics.curve_to(
      midpoint + margin, top,
      midpoint + margin, AREA.height,
      midpoint + AREA.width, AREA.height)
    mgraphics.set_line_width 2
    mgraphics.set_source_rgba @selection...
    mgraphics.stroke_with_alpha 1.0
    mgraphics.restore()

  # Draw vertical line indicating most recent random value.
  # 
  drawPosition: ->
    pixelposition = @linePosition * AREA.width * 0.96 + 2
    mgraphics.new_path()
    mgraphics.move_to pixelposition, 0
    mgraphics.line_to pixelposition, AREA.height
    mgraphics.set_line_width 0.5
    mgraphics.set_source_rgba @selection...
    mgraphics.stroke_with_alpha 1.0
    mgraphics.restore()

  # Reset and cue up animation.
  # 
  startLineAnimation: ->
    @animationFrame = 0
    @linePosition ?= parseInt @activatePosition
    @lastPosition ?= @linePosition
    @lineAnimation = new Task => @animateLine()
    @lineAnimation.interval = @ANIMATION_FRAME_RATE
    @lineAnimation.repeat()

  # Each frame of line animation.
  # 
  animateLine: ->
    if @animationFrame < @ANIMATION_FRAMES
      @linePosition =
        (@animationFrame / @ANIMATION_FRAMES) *
        (@activatePosition - @lastPosition) +
        (@lastPosition)
    else
      @lineAnimation.cancel()
      @lastPosition = @linePosition
    mgraphics.redraw()
    @animationFrame++
