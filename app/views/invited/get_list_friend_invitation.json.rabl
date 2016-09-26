child @list_invation => "invitation" do
    attributes :msg_id, :username,:first_name,:last_name,:message,:location_id,:unread ,:request_day,:request_time
    attribute :get_avatar_message => "avatar"
end
