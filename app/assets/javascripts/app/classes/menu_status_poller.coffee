#= require ./index

class app.classes.MenuStatusPoller
  constructor: (@root) ->
     @bindings $(@root)

  bindings: ($root) ->
    return if $root.length == 0

    that = @
    setInterval (->
      that.updateMenuStatus()
    ), that.pollingTimeout()


  updateMenuStatus: ->
    $.ajax
      type: 'POST'
      dataType: 'script'
      url: @updatePath()
      data: { restaurant_id: $(@root).data('location-id') }

  updatePath: -> $(@root).data('update-path')
  pollingTimeout: -> parseInt $(@root).data('polling-timeout'), 10
