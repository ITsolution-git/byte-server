#= require ./index

jQuery(document).on 'click', '.with-loader a, .with-loader li a, .with-loader button, input.with-loader, button.with-loader, a.with-loader', ->
  app.instances.loadingPanel.show()
