class ServerFavourite < ActiveRecord::Base
  attr_accessible :favourite, :server_id, :user_id

  belongs_to :user
end
