# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item_image, class: ItemImage do |i|
    i.image "test image"
    i.item_token "image-token"
  end
  
  factory :item_image_true, class: ItemImage do |i|
    i.image "test image"
    i.item_token "image-token"
    i.crop_x true
    i.crop_y true
    i.crop_w true
    i.crop_h true
  end
  
  factory :item_image_false, class: ItemImage do |i|
    i.image "test image"
    i.item_token "image-token"
    i.crop_x false
    i.crop_y false
    i.crop_w false
    i.crop_h false
  end
  
  factory :item_image_crop_x_true, class: ItemImage do |i|
    i.image "test image"
    i.item_token "image-token"
    i.crop_x true
    i.crop_y false
    i.crop_w false
    i.crop_h false
  end
  
  factory :item_image_crop_y_true, class: ItemImage do |i|
    i.image "test image"
    i.item_token "image-token"
    i.crop_x false
    i.crop_y true
    i.crop_w false
    i.crop_h false
  end
  
  factory :item_image_crop_w_true, class: ItemImage do |i|
    i.image "test image"
    i.item_token "image-token"
    i.crop_x false
    i.crop_y false
    i.crop_w true
    i.crop_h false
  end
  
  factory :item_image_crop_h_true, class: ItemImage do |i|
    i.image "test image"
    i.item_token "image-token"
    i.crop_x false
    i.crop_y false
    i.crop_w false
    i.crop_h true
  end
end
