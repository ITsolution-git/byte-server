class LocationContactGroup < ActiveRecord::Base
  attr_accessible :contact_group_id, :gg_contact_group_id, :location_owner_id
  belongs_to :contact_group
  belongs_to :location_owner, :class_name => 'User'
  has_many :user_location_contact_groups
  scope :get_gg_contact_group_id, ->(location_owner_id, contact_group_id) {where('location_owner_id = ? AND contact_group_id = ?',
      location_owner_id, contact_group_id)}
end
