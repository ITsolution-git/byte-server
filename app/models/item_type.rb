class ItemType < ActiveRecord::Base
  attr_accessible :name
  has_many :items

  def self.get_type_id(name)
    return ItemType.find_by_name(name)
  end

  def self.get_all_type
    return ItemType.all
  end

end
