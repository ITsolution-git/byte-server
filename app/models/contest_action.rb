class ContestAction < ActiveRecord::Base
  default_scope where('status != ?', "deleted")
  default_scope order('created_at desc')
  attr_accessible :id, :contest_id, :user_id, :location_id, :item_id, :item_name, :type, :photo_url, :facebook, :twitter, :instagram, :grade, :comment, :status, :created_at

  belongs_to :user
  belongs_to :item
  belongs_to :contest
  belongs_to :location
end
