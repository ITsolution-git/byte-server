class SearchProfile < ActiveRecord::Base
  attr_accessible :isdefault, :item_price, :item_rating, :item_reward, :item_type, 
  		:location_rating, :menu_type, :name, :radius, :server_rating, :text, :user_id

  belongs_to :user
  validates :name, :presence => true
end
