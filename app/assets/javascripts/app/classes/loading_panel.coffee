#= require ./index

class app.classes.loadingPanel
  constructor: ->
    @overlay = $('<div id="overlay"> </div>')
               .append('<div class="center"><p>Please, Wait</p></div>')
    @spinner = new app.classes.SpinRunner(@overlay[0])

  show: ->
    return if $('body #overlay').length > 0

    @overlay.appendTo(document.body)
    @spinner.start()

  hide: ->
    @spinner.stop()
    $('body #overlay').remove()
