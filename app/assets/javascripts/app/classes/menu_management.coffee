#= require ./index

class app.classes.MenuManagement
  constructor: (@root) ->
     @categoriesChanged = { value: [] }
     @itemsChanged = { value: [] }
     @bindings($(@root))

  bindings: ($root) ->
    @setMenuAttributes()
    @dragAndDropCategory()
    @dragAndDropItem()
    @itemsOrdering()

  setMenuAttributes: ->
    $.each $(@root).find('.menu-container'), (i, menu_container) ->
      $(".publish_menu_tz_#{$(menu_container).data('menu-id')}").attr 'href', (index, value) -> "#{value}?tz=#{jstz.determine().name()}"
      $(".unpublish_menu_tz_#{$(menu_container).data('menu-id')}").attr 'href', (index, value) -> "#{value}?tz=#{jstz.determine().name()}"

  dragAndDropCategory: ->
    that = @
    $.each $(@root).find('.menu-container'), (i, menu_container) ->
      $("#menu_#{$(menu_container).data('menu-id')}.category-drag-container").sortable
        handle: '.handle-drag'
        update: (event, ui) ->
          $("#update_order_#{$(menu_container).data('menu-id')}").removeClass('hide')
          order = new Menu.Order
            menuId: $(menu_container).data('menu-id')
            type: 'category'
            listChanged: that.categoriesChanged
          that.categoriesChanged.value.push(order.buildSequence(this))
          console.log that.categoriesChanged.value

  dragAndDropItem: ->
    that = @
    $.each $(@root).find('.menu-container'), (i, menu_container) ->
      $("#menu_#{$(menu_container).data('menu-id')} .item-drag-container").sortable
        handle: '.handle-drag'
        update: (event, ui) ->
          $("#update_order_#{$(menu_container).data('menu-id')}").removeClass('hide')
          categoryId = $(this).parent().attr('category-id')
          order = new Menu.Order
            menuId: $(menu_container).data('menu-id')
            type: 'item'
            categoryId: categoryId
            listChanged: that.itemsChanged
          that.itemsChanged.value.push(order.buildSequence(this))

  itemsOrdering: ->
    that = @

    $.each $(@root).find('.menu-container'), (i, menu_container) ->
      $("#update_order_#{$(menu_container).data('menu-id')}").on 'click', (e) ->
         e.preventDefault()
         that.loadOrderBuildMenu($(menu_container).data('menu-id'))

  loadOrderBuildMenu: (menu_id) ->
    data =
      categoriesChanged: @categoriesChanged.value
      itemsChanged: @itemsChanged.value
    $.ajax
      url: $(@root).find('.menu-container').first().data('order-build-menu-path')
      type: 'POST'
      data: data
      success: (data) ->
        $("#update_order_#{menu_id}").addClass 'hide'
