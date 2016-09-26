#= require ./index

ready = ->
  app.methods.checkImageSize()
  new app.classes.MenuManagement '.menus_container'
  new app.classes.MenuStatusPoller '.copying-menus'
  new app.classes.AccountsManagement '.locations-table'
  new app.classes.PackageManagement '#packages-table'
  new app.classes.Subscriptions '.subscriptions-table'
  app.instances.loadingPanel = new app.classes.loadingPanel

$ -> ready()
$(document).on 'page:load', -> ready()

$(document).on 'click', '.remove-location', ->
  isLast = $(@).data("islast")
  url = $(@).data("location")
  msg = if isLast
    'If you delete this last restaurant, your account will be deleted. Are you sure you want to delete?'
  else
    'Are you sure you want to delete this Restaurant?'
  if confirm(msg)
    app.instances.loadingPanel.show()
    $.ajax
      type: 'POST'
      url: url
      dataType: 'script'
      data: { '_method': 'delete' }
  else
    false
