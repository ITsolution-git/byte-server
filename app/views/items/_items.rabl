collection @items => "items"

@items.each do |item|
  attributes :id, :name, :price, :description,:calories,:special_message,:category_id,:menu_id ,:is_favourite, :is_nexttime, :review, :redemption_value
  attribute  :get_reward_point => :reward_points
  attribute :avg_rating => :rating
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

  node(:combo_item) do |i|
    partial('category/combo_items', :object => i.combo_item(i.menu_id), locals: {user_id: i.user_id, menu_id: i.menu_id, item: i})
  end
end
