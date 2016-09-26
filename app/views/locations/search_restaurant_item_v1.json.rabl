collection @items => "items"

@items.each do |item|
  attributes :id, :name, :price, :description,:calories,:reward_points,:special_message,:category_id, :category_name,:menu_id ,:is_favourite, :is_nexttime, :review, :redemption_value, :rating, :primary_cuisine, :secondary_cuisine
  child :item_images => "item_images" do
    attributes :item_id
    node :image do
      |i| i.photo.fullpath if i.photo
    end
  end
   child :item_images => "item_image_thumbnail" do
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

  child :view_item_options => "item_options"do
      attributes :id, :name, :only_select_one
      child :view_item_option_addons => "item_option_addons" do
        attributes :id, :name, :is_selected
        attribute :display_price_with_float_format => "price"
      end
  end
end
