class CuisineType < ActiveRecord::Base
  attr_accessible :name

  def self.get_type_id(name)
    return CuisineType.find_by_name(name)
  end

  def self.get_all_type
    return CuisineType.all
  end
end
