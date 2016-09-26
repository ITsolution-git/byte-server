child @user => "user" do
    attribute :get_total_point => :points
    attributes :dinner_status
end
child @locations => "locations" do
    attributes :chain_name,:total_point
    node :logo do |loc|
      loc.logo.fullpath if loc.logo
    end
end

