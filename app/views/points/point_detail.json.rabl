child @locations => "location" do
    attributes :dinner_status
end

child @point => "points" do
    attributes :id,:user_id, :point_type, :points, :most_recent
    node(:status) {|st| st.is_give}
end