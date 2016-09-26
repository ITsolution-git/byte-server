child @fav => "favourites" do
    attributes :chain_name, :total_favourites
    node :logo do |loc|
      loc.logo.fullpath if loc.logo
    end
    attribute :favourite_type => :type
    #attribute :get_total_favourites_global =>"total_favourites"
end
