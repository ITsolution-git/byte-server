child @global => "location_global" do
  attributes :dinner_status
end
child @user => "user" do
  attribute :get_total_point => :points
end
child @locations => "locations_chain" do
  attributes :id, :name, :address, :city, :state, :country, :state, :zip, :total, :most_recent
  node :logo do |loc|
     loc.logo.fullpath if loc.logo
  end
  node(:current_prize) do |loc|
    partial('locations/prize', :object => loc.get_prize_by_location(loc.id, loc.total, loc.user_id))
  end
  node(:next_prize) do |loc|
    partial('locations/next_prize', :object => loc.get_next_prize_location(loc.id, loc.total, loc.user_id))
  end
end



