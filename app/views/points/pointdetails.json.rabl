collection @points
    attributes :id,:user_id, :point_type, :points,:dateformat,:status
    node(:logo){|m| "uploads/location/logo/"+m.location_id.to_s+"/"+m.pic}