object @ratings

node(:user_id) {|r| r.user_id.to_s}
node(:rating) {|r| r.rating.to_s}
node(:text) {|r| r.text.to_s}
node(:username) { |r| r.user.try(:username).to_s }
node(:user_avatar) { |r| r.user.try(:avatar).try(:url).to_s }
node(:item_name) { |r| r.item.try(:name).to_s }
node(:item_id) { |r| r.item.try(:id).to_s }
node(:created) { |r| r.created_at}
node(:updated) { |r| r.updated_at }
node(:location_id) { |r| r.location.try(:id).to_s }
node(:location_name) { |r| r.location.try(:name).to_s }
node(:message_id) { |r| r.id.to_s }
node(:item_images) { |r| r.item.images.map(&:url) if r.item.present? }
