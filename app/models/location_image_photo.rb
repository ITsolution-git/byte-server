class LocationImagePhoto < ActiveRecord::Base
  attr_accessible :location_id, :photo_id, :index
  belongs_to :location
  belongs_to :photo
end
