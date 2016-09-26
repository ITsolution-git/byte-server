#= require ./index
#= require spin

class app.classes.SpinRunner
  constructor: (@root) ->
    @spinner = @initSpinner()

  initSpinner: ->
    opts =
      lines: 13
      length: 20
      width: 10
      radius: 30
      corners: 1
      rotate: 0
      direction: 1
      color: 'gray'
      speed: 0.8
      trail: 48
      shadow: false
      hwaccel: false
      className: 'spinner'
      zIndex: 2e9
      top: '50%'
      left: '50%'
    new Spinner(opts)

  start: ->
    @spinner.spin(@root)

  stop: ->
    @spinner.stop()
