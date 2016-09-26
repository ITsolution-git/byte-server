node(:status) {"success"}
node(:access_token){@user.access_token}
child @user => :user do
    attributes :id, :email,:username, :first_name, :last_name,:address,:city,:state,:zip,:dinner_status, :phone
    attribute :get_total_point => :points
    node :get_avatar do |u|
      u.avatar.fullpath if u.avatar
    end
    if @defaultsearchprofile
      node(:defaultsearchprofile) {|df| df.defaultsearchprofile}
    else
      node(:defaultsearchprofile) {0}
    end
    if @search_profile
      child @search_profile => "default_search_profile" do
        attributes :id,:name,:location_rating,:item_price,:item_rating,:radius,:item_type,:menu_type,:server_rating,:isdefault
        node (:keyword) {|m| m.text}
        node (:point_offered) {|m| m.item_reward}
      end
    else
      node(:default_search_profile) {[]}
    end
end
