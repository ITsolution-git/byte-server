object @locations
  attributes :id, :type, :name, :address, :city, :state, :country, :lat, :long, :com_url
  node :logo do |loc|
    if loc.logo
      if loc.logo.is_a?(String)
        loc.logo
      else
        loc.logo.fullpath
      end
    end
  end
  attribute :type_v1 => "type"
  attribute :region => :state        # use to show restaurant info from google places
  attribute :lng => :long            # use to show restaurant info from google places
  attributes :vicinity => :address, :if => lambda { |m| m.vicinity} # use to show restaurant info from google places - nearby search
  attributes :formatted_address => :address , :if => lambda { |m| m.formatted_address} # use to show restaurant info from google places - text search
  attribute :icon => :logo           # use to show restaurant info from google places
  attribute :street_number => :type  # use to show restaurant info from google places
  attribute :reference               # use to show restaurant info from google places
