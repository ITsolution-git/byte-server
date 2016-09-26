class SocialShare < ActiveRecord::Base
  attr_accessible :social_point_id, :type, :user_id
  belongs_to :location
  belongs_to :item
end
