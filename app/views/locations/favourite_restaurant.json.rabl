child @fav => "favourites" do

    attribute :id => "location_id"
    attributes :name, :address, :city, :state, :zip, :most_recent, :total_favourites
    node :logo do |fav|
      fav.logo.fullpath if fav.logo
    end
end
