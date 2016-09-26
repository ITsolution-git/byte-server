attribute :id =>"item_id"
    attributes :name, :price, :description, :calories, :special_message, :redemption_value, :rating
    node(:category_id) do |i|
      locals[:category_id]
    end

    node(:menu_id) do |i|
      locals[:menu_id]
    end
    node(:reward_points) do |rw|
      rw.get_reward_points(locals[:menu_id],locals[:category_id])
    end
    node(:is_favourite) do |i|
        i.item_favourites.where("item_favourites.user_id = ? and item_favourites.favourite = 1", locals[:user_id]).count
    end

    node(:is_nexttime) do |i|
        i.item_nexttimes.where("item_nexttimes.user_id = ? and item_nexttimes.nexttime = 1", locals[:user_id]).count
    end

    node(:review) do |i|
      i.item_comments.where("item_comments.build_menu_id = ?", i.build_menus.first.id).count
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
