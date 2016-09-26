collection @friend
    attributes :id, :first_name, :last_name,:username ,:date_invited, :date_registered, :friend_status,:last_rating,:number_rating,:point_received,:restaurant_visited
node(:userPhotoImageURL) { |m| m.avatar.fullpath if m.avatar }
