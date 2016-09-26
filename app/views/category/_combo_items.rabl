attributes *ComboItem.column_names - ['created_at', 'updated_at', 'name', 'menu_id']
if  locals[:item].gmi?(locals[:menu_id])
  #List of items in GMI
  child :combo_item_categories => "GMI_items" do
      attributes :sequence, :quantity

      node(:categories) do |c|
        partial('category/items', :object => c.category, locals: {category_id: c.id, menu_id: locals[:menu_id], user_id: locals[:user_id]})
      end

  end
  #List of items in PMI
  child :combo_item_items => "PMI_items" do
  end

elsif locals[:item].pmi?(locals[:menu_id])

#List of items in GMI
child :combo_item_categories => "GMI_items" do
end


#List of items in PMI
child :combo_item_items => "PMI_items" do

    child :item => "items" do
        attribute :id =>"item_id"
        attributes :name, :price, :description, :calories, :special_message, :redemption_value, :rating
        node(:menu_id) do |me|
          locals[:menu_id]
        end

        node(:category_id) do |i|
            i.get_category_id_by_menu_id(i.id, locals[:menu_id])
        end

        node(:reward_points) do |rw|
            rw.get_reward_points(locals[:menu_id],rw.get_category_id_by_menu_id(rw.id, locals[:menu_id]))
        end

        node(:is_favourite) do |item_fav|
          item_fav.item_favourites.where("item_favourites.user_id = ? and item_favourites.favourite = 1", locals[:user_id]).count
        end

        node(:is_nexttime) do |item_nxt|
          item_nxt.item_nexttimes.where("item_nexttimes.user_id = ? and item_nexttimes.nexttime = 1", locals[:user_id]).count
        end

        node(:review) do |item_review|
          item_review.item_comments.where("item_comments.build_menu_id = ?", item_review.build_menus.first.id).count
        end

        #list of item_images, item_keys in PMI
        child :item_photos => "item_images" do
          attributes :item_id
          node :image do
            |i| i.photo.fullpath if i.photo
          end
        end
        child :item_photos => "item_image_thumbnail" do
          attributes :item_id
          node :image do
            |i| i.photo.fullpath if i.photo
          end
        end
        child :item_keys => "item_keys" do
              attributes :id, :name, :description
              node :image do |i|
                i.photo.fullpath if i.photo
              end
        end
        child :item_keys => "item_key_thumbnail" do
             attributes :id, :name, :description, :image_thumbnail
        end
    end
end

elsif locals[:item].cmi?(locals[:menu_id])

#List of items in GMI
child :combo_item_categories => "GMI_items" do
    attributes :sequence, :quantity

    node(:categories) do |c|
      partial('category/items', :object => c.category, locals: {category_id: c.id, menu_id: locals[:menu_id], user_id: locals[:user_id]})
    end

end

#List of items in PMI
child :combo_item_items => "PMI_items" do

    child :item => "items" do
        attribute :id =>"item_id"
        attributes :name, :price, :description, :calories, :special_message, :redemption_value, :rating
        node(:menu_id) do |me|
          locals[:menu_id]
        end

        node(:category_id) do |i|
            i.get_category_id_by_menu_id(i.id, locals[:menu_id])
        end

        node(:reward_points) do |rw|
            rw.get_reward_points(locals[:menu_id],rw.get_category_id_by_menu_id(rw.id, locals[:menu_id]))
        end

        node(:is_favourite) do |item_fav|
          item_fav.item_favourites.where("item_favourites.user_id = ? and item_favourites.favourite = 1", locals[:user_id]).count
        end

        node(:is_nexttime) do |item_nxt|
          item_nxt.item_nexttimes.where("item_nexttimes.user_id = ? and item_nexttimes.nexttime = 1", locals[:user_id]).count
        end

        node(:review) do |item_review|
          item_review.item_comments.where("item_comments.build_menu_id = ?", item_review.build_menus.first.id).count
        end

        #list of item_images, item_keys in PMI
        child :item_photos => "item_images" do
          attributes :item_id
          node :image do
            |i| i.photo.fullpath if i.photo
          end
        end
        child :item_photos => "item_image_thumbnail" do
          attributes :item_id
          node :image do
            |i| i.photo.fullpath if i.photo
          end
        end
        child :item_keys => "item_keys" do
              attributes :id, :name, :description
              node :image do |i|
                i.fullpath if i.photo
              end
        end
        child :item_keys => "item_key_thumbnail" do
            attributes :id, :name, :description, :image_thumbnail
        end
    end
end

end
