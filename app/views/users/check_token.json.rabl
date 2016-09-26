node(:status) {"success"}
node(:access_token){@user.access_token}
child @user => :user do
    attributes :id, :email,:username, :first_name, :last_name,:address,:city,:state,:zip,:points,:dinner_status
    node(:userPhotoImageURL) { @user.avatar.present? ? @user.avatar.url : @user.social_image_url}
    if @defaultsearchprofile
      node(:defaultsearchprofile) {|df| df.defaultsearchprofile}
    else
      node(:defaultsearchprofile) {0}
    end
end
