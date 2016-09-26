$(document).ready ->
  $('#showpwd').on 'click', (e) ->
    if $(@).text() == 'Show Password'
      $('#user_password').attr 'type', 'text'
      $(@).text 'Hide Password'
    else
      $('#user_password').attr 'type', 'password'
      $(@).text 'Show Password'
