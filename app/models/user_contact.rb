class UserContact < ActiveRecord::Base
  attr_accessible :etag, :gg_contact_id, :location_owner_id, :user_id
  belongs_to :location_owner, :class_name => 'User'
  belongs_to :user
  has_many :user_location_contact_groups
  has_many :location_contact_groups, :through => :user_location_contact_groups
end
