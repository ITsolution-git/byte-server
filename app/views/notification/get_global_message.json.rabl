child @restaurant => "restaurants" do
    attributes :chain_name , :most_recent, :unread
    attribute :chain_logo =>"logo"
    node :chain_logo do |res|
      res.logo.fullpath if res.logo
    end
    #node(:unread) {|_| _.get_unread_message }
end
