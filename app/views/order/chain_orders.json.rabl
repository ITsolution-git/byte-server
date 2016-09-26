child @locations => "locations" do
    attributes :id, :name, :chain_name, :address, :city, :state, :country, :zip, :number
    node :logo do |res|
      res.logo.fullpath if res.logo
    end
end
