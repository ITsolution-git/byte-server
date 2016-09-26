class UserProfile < ActiveRecord::Base
  default_scope order('order_num ASC')
  attr_accessible :id, :user_id, :name, :image, :show_type, :publish_date, :unpublish_date, :tags, :zipcode, :latitude, :longitude, :radius, :order_num
  belongs_to :user
end
