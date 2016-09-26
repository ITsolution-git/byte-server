class CustomersLocations < ActiveRecord::Base
  attr_accessible :location_id, :is_deleted, :user_id
  belongs_to :location
  belongs_to :user

  # Rate, Set Favorite, Share Menu Items, Share Restaurant Points, Order, Pay, Accept Menu Points, Share prizes, &Receive / accept points or prizes
  def self.add_contact(user_ids, location_id)
    user_ids.each do |user_id|
      contact = CustomersLocations.find_by_user_id_and_location_id(user_id, location_id)
      if contact.nil?
        new_contact = CustomersLocations.new
        new_contact.location_id = location_id
        new_contact.user_id = user_id
        new_contact.is_deleted = 0
        new_contact.save!
      else
        unless contact.is_deleted == 1
          contact.update_attributes!(:is_deleted => 0)
        end
      end
    end
    return
  end
end
