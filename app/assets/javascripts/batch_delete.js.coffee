$(->
  #close = (excluded_element)->
  #  $('.open').not(excluded_element).removeClass 'open'

  #$(document).on('click', '.custom-toggle', (event)->
  #  parent = $(@).parent()
  #  close parent
  #  parent.toggleClass 'open'
  #)

  #$('body').click((event)->
  #  dropdown = $('.dropdown-menu')
  #  if !dropdown.is(event.target) and
  #  dropdown.has(event.target).length == 0 and
  #  $('.open').has(event.target).length == 0
  #    close()
  #)
  $(document).on('click', '.item-name > a', (event)->
    $(@).closest('.modal').modal 'hide'
  )
  $(document).on('submit', '.batch-delete-form', (event)->
    event.preventDefault()

    self = $(@)
    submit_info =  self.data 'ujs:submit-button'

    # intercept shared form submit button: "Global"
    if submit_info[ 'name' ] == 'make_global'
      source = self.data 'source'
      error_class = self.data 'errorClass'
      checked_fields = self.find 'input:checkbox:checked'
      items_to_publish = []
      $('input:checkbox:checked', @).each(()->
        items_to_publish.push $(@).data 'id'
      )
      send_request source, items_to_publish, error_class, []
    else if confirm('Are you sure you want to delete these items?')
      source = self.data 'source'
      error_class = self.data 'errorClass'
      checked_fields = self.find 'input:checkbox:checked'
      items_to_delete = []
      elements_to_delete = []
      $('input:checkbox:checked', @).each(()->
        items_to_delete.push $(@).data 'id'
        elements_to_delete.push $(@).closest('li')
      )
      send_request source, items_to_delete, error_class, elements_to_delete
  )

  send_request = (url, array, error_class, elements_to_delete)->
    $.ajax(
      data:
        items_to_delete: array, make_global: elements_to_delete.length == 0
      method: 'delete'
      url: '/' + url + '/batch_delete'
    ).done(()->
      elements_to_delete.forEach((element)->
        $(element).remove()
      )
      if elements_to_delete.length > 0
        $('.' + error_class).html('<div class="alert alert-success" role="alert">Items successfully deleted</div>').show().delay(3000).fadeOut();
    )
)
