object @location

attribute :check_status_location => :open_now
node(:id) {|l| l.id.to_s}
node(:is_checked_in) {|l| userid = current_user.id; l.recent_checkins.any?{|ci| ci.user_id == userid}}
node(:name) {|l| l.name.to_s}
node(:address) {|l| l.address.to_s}
node(:city) {|l| l.city.to_s}
node(:state) {|l| l.state.to_s}
node(:country) {|l| l.country.to_s}
node(:phone) {|l| l.phone.to_s}
node(:rating) {|l| l.rating.present? ? l.rating : ''}
node(:zip) {|l| l.zip.to_s}
node(:tax) {|l| l.tax.to_s}
node(:fee) {|l| l.fee.to_s}
node(:service_fee_type) {|l| l.service_fee_type.to_s}
node(:bio) {|l| l.bio.to_s}
node(:owner_id) {|l| l.owner_id.to_s}
node(:twiter_url) {|l| l.twiter_url.to_s}
node(:twitter_url) {|l| l.twiter_url.to_s}
node(:facebook_url) {|l| l.facebook_url.to_s}
node(:google_url) {|l| l.google_url.to_s}
node(:url) {|l| l.com_url.to_s}
node(:instagram_username) {|l| l.instagram_username.to_s}
node(:linked_url) {|l| l.linked_url.to_s}
node(:created_date) { |l| l.created_at.strftime("%m/%d/%Y") }
node(:created_time) { |l| l.created_at.strftime("%H:%M") }
node(:latitude) { |l| l.lat.to_f }
node(:longitude) { |l| l.long.to_f }
node(:updated_date) { |l| l.updated_at.strftime("%m/%d/%Y") }
node(:updated_time) { |l| l.updated_at.strftime("%H:%M") }
node(:logo) { |l| (l.logo_url.nil? || l.logo_url == "") ? l.logo.try(:url) : l.logo_url }
node(:favourited) { |l| userid = current_user.id; l.location_favourites.any?{|lf| lf.favourite == 1 && lf.user_id == userid } }
node(:favourited_total) { |l| l.location_favourites.select{|lf| lf.favourite == 1}.size }

node(:cuisine_types) do |l|
  res = []
  res << {name: l.primary_cuisine} if l.primary_cuisine.present?
  res << {name: l.secondary_cuisine} if l.secondary_cuisine.present?
  res
end
node(:rating) { |l| l.calculate_grade }
node(:rating_total) {|l| l.grades.to_a.size }
node(:hours_of_operation) do |l|
  l.hours_of_operation_for_api.map do |ho|
    {
      "time_open" =>  ho.time_open,
      "time_close" => ho.time_close,
      "day_of_week" => ho.day
    }
  end
end

# child :messages => :messages do
#   node(:unread) {|m| m.unread}
#   node(:chain_name) {|m| m.chain_name}
#   node(:id) {|m| m.id}
#   node(:logo_id) {|m| m.logo_id}
#   node(:most_recent) {|m| m.most_recent}
#   node(:to_user) {|m| m.to_user}
# end
# node(:unread_messages) { |l| l.messages.present? ? l.messages.unread : 0}
#
# node(:unlocked_prizes) { |l| l.prizes.count }

node(:contests) do |l|
  l.contests.map do |c|
    {
      "id"=>c.id,
      "name"=>c.name,
      "contact"=>c.contact,
      "contact_name"=>c.contact_name,
      "created_at"=>c.created_at,
      "description"=>c.description,
      "end_date"=>c.end_date,
      "location"=>c.location,
      "publish_date"=>c.publish_date,
      "restaurants"=>c.restaurants,
      "start_date"=>c.start_date,
      "status"=>c.status,
      "updated_at"=>c.updated_at,
      "url"=>c.url
    }
  end
end

child :subscriptions => :packages do
 node(:subscription_id) {|s| s.subscription_id.to_s }
 node(:plan_id) {|s| s.plan_id.to_s }
 node(:expiration_date) {|p| p.next_billing_date }
end
child(:images) do
 node(:url) {|i| i.url.to_s}
end
node(:unread_message_count) {|l| l.notifications.select{|ln| ln.status == 1}.size }
node(:prize_count) {|l| l.share_prizes.select{|ln| ln.is_redeem == 0}.size }
