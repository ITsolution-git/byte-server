class ContactGroup < ActiveRecord::Base
  attr_accessible :description, :title
  has_many :location_contact_groups
  has_many :users, :through => :location_contact_groups

  def to_element
    return GContacts::Element.new({
      "category" => {
        "@term" => "group"
      },
      "title" => "#{self.title}",
      "gd:extendedProperty" => {
        "@name" => "description",
        "@value" => "#{self.description}",
      }
    })
  end

  def new_group?(location_owner_id)
    ContactGroup.joins(:location_contact_groups).where('contact_groups.id = ? AND location_contact_groups.location_owner_id = ?',
        self.id, location_owner_id).empty?
  end

  def get_gg_contact_group(location_owner_id)
    return LocationContactGroup.find_by_location_owner_id_and_contact_group_id(location_owner_id, self.id)
  end
end
