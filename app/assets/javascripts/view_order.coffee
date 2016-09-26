ready = () ->
  $('.modal').on('click', '.issue-refund', ()->
    if(window.confirm('Are you sure?'))
      $.ajax(
        url: $(@).data('url')
        method: 'DELETE'
        dataType: 'json'
      )
      .done () =>
        document.location.reload true
      .fail () =>
        alert 'There was an error in refunding this order.'
  )

$ -> ready()
$(document).on 'page:load', -> ready()
