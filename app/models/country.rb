class Country < ActiveRecord::Base
  attr_accessible :name, :country_code

  has_many :states, foreign_key: 'country_code', dependent: :destroy
  has_many :cities, foreign_key: 'country_code', dependent: :destroy
end
