object @nearby_locations
  attributes :id, :name, :address, :city, :state, :country, :lat, :long, :distance, :type, :reference
  node :logo do |loc|
    loc.logo.fullpath if loc.logo
  end
  attribute :cid => :distance        # use to show restaurant info from google places
  attribute :icon => :logo           # use to show restaurant info from google places
  attribute :street_number => :type  # use to show restaurant info from google places
  attribute :reference               # use to show restaurant info from google places
  attribute :photos
