class ItemNexttime < ActiveRecord::Base
  attr_accessible :nexttime, :user_id
  belongs_to :user
  belongs_to :build_menu
end
