class MenuType < ActiveRecord::Base
  attr_accessible :name

  has_many :menus


end
