object @reward
node(:id) { |r| r.id }
node(:name) { |r| r.name }
node(:photo) { |r| r.photo.url }
node(:available_from) { |r| r.available_from }
node(:expired_until) { |r| r.expired_until }
node(:timezone) { |r| r.timezone }
node(:description) { |r| r.description }
node(:restaurant_id) { |r| r.location_id }
node(:restaurant_name) { |r| r.location.name }
