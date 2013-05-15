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

# Canvas context
# 
context = (new MaxCanvas @).getContext('max-2d')

# Mouse input: Update internal state, and output to patcher.
# 
onclick = ondrag = (x, y) ->
  mean = Math.min(Math.max(x, 0), AREA.width) / AREA.width
  deviation = 1 - Math.min(Math.max(y, 0), AREA.height) / AREA.height
  GaussianCurveCanvas::set "mean", mean
  GaussianCurveCanvas::set "deviation", deviation
  outlet 0, ["mean", mean]
  outlet 0, ["deviation", deviation]

# Max message inputs
# 
# The following are Live rgba colors:
#   surface_bg, contrast_frame, selection, control_text_bg
# 
anything = -> GaussianCurveCanvas::set messagename, arrayfromargs(arguments)...
paint = -> GaussianCurveCanvas::draw()
bang = -> context.redraw()

# 
# 
class GaussianCurveCanvas

  # 
  # 
  @::CORNER_RADIUS = 8
  @::DEVIATION_PIXEL_COEFFICIENT = 32
  @::ANIMATION_FRAMES = 5
  @::ANIMATION_FRAME_RATE = 10

  # Set parameter.
  # 
  set: (key, val) ->
    @[key] = val
    if key is "activatePosition"
      @startLineAnimation()
    else
      context.redraw()

  # Draw all, making sure necessary params are set.
  # 
  draw: ->
    @drawBackground() if @contrast_frame? and @surface_bg?
    @drawCurve() if @mean? and @deviation? and @selection?
    @drawPosition() if @linePosition? and @selection?

  # Draw background and corners.
  # 
  drawBackground: ->
    context.fillStyle = @contrast_frame
    context.fillRect(0, 0, AREA.width, AREA.height)

    for x in [0, AREA.width]
      for y in [0, AREA.height]
        @drawCorner x: x, y: y

  # Roll our own rounded corners to resemble [panel]'s.
  # 
  drawCorner: (corner) ->
    context.beginPath()
    context.moveTo(corner.x, corner.y)
    context.lineTo(
      (if corner.x > 0 then corner.x - @CORNER_RADIUS else @CORNER_RADIUS), corner.y)
    context.quadraticCurveTo(
      corner.x, corner.y,
      corner.x, (if corner.y > 0 then corner.y - @CORNER_RADIUS else @CORNER_RADIUS))
    context.lineTo(corner.x, corner.y)
    context.closePath()
    context.fillStyle = @surface_bg
    context.fill()

  # Crude approxmiation of Gaussian distribution curve.
  # 
  drawCurve: ->
    midpoint = @mean * AREA.width
    margin = @deviation * @DEVIATION_PIXEL_COEFFICIENT
    top = 2

    context.lineWidth = 2
    context.strokeStyle = @selection
    context.beginPath()
    context.moveTo(midpoint - AREA.width, AREA.height)
    context.bezierCurveTo(
      midpoint - margin, AREA.height,
      midpoint - margin, top,
      midpoint, top)
    context.bezierCurveTo(
      midpoint + margin, top,
      midpoint + margin, AREA.height,
      midpoint + AREA.width, AREA.height)
    context.stroke()

  # Draw vertical line indicating most recent random value.
  # 
  drawPosition: ->
    pixelposition = @linePosition * AREA.width * 0.96 + 2
    context.lineWidth = 0.5
    context.strokeStyle = @selection
    context.beginPath()
    context.moveTo(pixelposition, 0)
    context.lineTo(pixelposition, AREA.height)
    context.stroke()

  # Reset and cue up animation.
  # 
  startLineAnimation: ->
    @animationFrame = 0
    @linePosition ?= @activatePosition
    @lastPosition ?= @linePosition
    @lineAnimation = context.setInterval((=> @animateLine()), @ANIMATION_FRAME_RATE)

  # Each frame of line animation.
  # 
  animateLine: ->
    if @animationFrame <= @ANIMATION_FRAMES
      @linePosition =
        (@animationFrame / @ANIMATION_FRAMES) *
        (@activatePosition - @lastPosition) +
        (@lastPosition)
    else
      context.clearInterval(@lineAnimation)
      @lastPosition = @linePosition
    context.redraw()
    @animationFrame++
