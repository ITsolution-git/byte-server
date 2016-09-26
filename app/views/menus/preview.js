$('#myModal_menu_<%= @menu.id %> #wrapper-myCarousel').html("<%= j render partial: 'menus/item_images_of_category', locals: {items: @items} %>");
$('#myModal_menu_<%= @menu.id %> #items_from_category').html("<%= j render partial: 'menus/items_from_category_preview', locals: {item: @item, device: @device, menu: @menu, category: @category} %>");
var indicator = $('#myModal_menu_<%= @menu.id %> .wrapper-preview .carousel-indicators');
indicator.css({'margin-left': -indicator.width()/2});