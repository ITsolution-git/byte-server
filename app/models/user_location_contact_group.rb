class UserLocationContactGroup < ActiveRecord::Base
  attr_accessible :location_contact_group_id, :user_contact_id
  belongs_to :location_contact_group
  belongs_to :user_contact
end
