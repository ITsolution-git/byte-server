child @restaurant => "restaurants" do
    attribute :id => "location_id"
    attributes :name, :address, :city, :state, :zip, :unread
    node :logo do |res|
      res.logo.fullpath if res.logo
    end

end
