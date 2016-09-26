class LocationVisited < ActiveRecord::Base
  attr_accessible :location_id, :user_id, :visited

  belongs_to :location
  belongs_to :user
end
