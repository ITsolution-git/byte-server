collection @points
    attributes :user_id, :point_type, :totalpoints,:location_id,:name,:date
     node :logo do |pt|
       pt.location.logo.fullpath if pt.location.try(:logo)
     end
