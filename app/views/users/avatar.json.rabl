object @user

attributes :id
node(:avatar){|v| v.avatar.fullpath if v.avatar}
