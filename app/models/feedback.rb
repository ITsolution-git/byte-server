class Feedback < ActiveRecord::Base
  attr_accessible :user_id, :rating, :comment

  belongs_to :user
end
