child @locations => "locations" do
    attributes :chain_name, :number
    node :logo do |loc|
      loc.logo.fullpath if loc.logo
    end
end
