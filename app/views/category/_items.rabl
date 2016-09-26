attributes *Category.column_names - ['created_at', 'updated_at']
#child :items => "items" do
    node(:items) do |it|
      partial('category/items_two', :object => it.item_by_build_menu(locals[:menu_id], it.id).not_main_dish, locals: {category_id: it.id, menu_id: locals[:menu_id], user_id: locals[:user_id]})
    end
#end