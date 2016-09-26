#= require ./index

class app.classes.PackageManagement
  constructor: (@root) ->
    @bindings()

  bindings: ($root) ->
    @statusToggle()

  statusToggle: ->
    $(@root).find('.onoffswitch').on 'change', (e) ->
      app.instances.loadingPanel.show()
      $.ajax
        data:
          status: $(@).find('input.onoffswitch-checkbox').attr('checked')
        method: 'POST'
        dataType: 'script'
        url: $(@).data('status-path')
