object @location
attributes :rating,:ratings_count,:comments_count

child @comments=>"comments" do
    attributes :user_id, :text, :rating, :created, :updated, :server_name ,:location_id, :user_avatar
    node(:location_name){|m| m.location.name}
    node(:username){|m| m.user.nil? ? "Guest" : m.user.username}
    node(:message_id) {|m| m.id}
end
