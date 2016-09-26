#= require ./index

class app.classes.Subscriptions
  constructor: (@root) ->
    @modal = $('#accounts_form_container #locations.modal')
    @byte_modal = $('#byte-main-package.modal')
    @bindings()

  bindings: ->
    @createSubscriptionModal()
    @createSubscription()
    @removeSubscription()
    @bytePackageManagement()

  createSubscriptionModal: ->
    that = @
    $(document).on 'click', '.subscriptions-table .subscription-btn', ->
      that.modal.data('plan-id', $(@).parent().data('plan-id'))
      that.modal.data('plan-name', $(@).parent().data('plan-name'))
      that.modal.modal('show')

  createSubscription: ->
    that = @
    $(document).on 'click', '#accounts_form_container #locations.modal .submit-btn', ->
      location_ids = $.map $('.locations-table input:checked'), (val, _) -> $(val).val()

      app.instances.loadingPanel.show()
      $.ajax
        type: 'POST'
        url: $(that.root).data('subscriptions-path')
        dataType: 'script'
        data:
          plan_id: that.modal.data('plan-id')
          plan_name: that.modal.data('plan-name')
          locations_ids: location_ids

  removeSubscription: ->
    $(document).on 'click', '.active-subsciptions-table .unsubscribe-btn', ->
      if confirm('Are you sure you want to unsubscribe from this plan?')
        app.instances.loadingPanel.show()
        $.ajax
          type: 'POST'
          url: $(@).parent().data('unsubscribe-path')
          dataType: 'script'
          data: { '_method': 'delete' }

  bytePackageManagement: ->
    that = @
    $(document).on 'click', '.byte-main-table .unsubscribe-byte-btn', ->
      that.byte_modal.modal('show')

    $(document).on 'click', '#byte-main-package.modal .submit-btn', ->
      app.instances.loadingPanel.show()
      $.ajax
        type: 'POST'
        url: $(@).parent().data('byte-path')
        dataType: 'script'
