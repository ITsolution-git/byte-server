object @prize
node(:name) {|p| p.name.to_s}
node(:id) { |p| Prize.find_by_name(p.name).id }
node(:type) { 'byte' }
node(:location_name) { |p| p.location_name }
node(:location_id) { |p| p.location_id }
node(:location_latitude) { |p| p.location_lat }
node(:location_longitude) { |p| p.location_long}
node(:location_logo) { |p| p.location_logo }
node(:location_cuisine_types) { |p| p.location_cuisine }
node(:byte_prize_type) { |p| p.byte_prize_type }
