#= require ./index

class app.classes.AccountsManagement
  constructor: (@root) ->
     @bindings()

  bindings: ->
    @updateClientID()

  updateClientID: ->
    $(@root).find('.save-btn').on 'click', (e) ->
      app.instances.loadingPanel.show()
      $.ajax(
        data:
          customer_id: $(@).parents('tr').find('input').val()
          location_id: $(@).parents('tr').data('locationId')
        method: 'POST'
        dataType: 'json'
        url: $(@).parents('tr').data('update-path')
      ).done ->
        app.instances.loadingPanel.hide()

