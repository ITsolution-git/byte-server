child @detail_message => "message" do
    attributes :msg_id,:location_id, :alert_type,:alert_logo, :message, :update_time,:create_time, :from_user, :username,:msg_type,:msg_subject, :points
    attribute :get_avatar_message => "avatar"
    node(:avatar) {|message| message.try(:sender).try(:avatar).try(:url)}
    attribute :received=>"is_received"
end
