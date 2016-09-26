class LocationFavourite < ActiveRecord::Base
   attr_accessible :location_id, :user_id,:favourite
   belongs_to :user
   belongs_to :location
end
