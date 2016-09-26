class State < ActiveRecord::Base
  attr_accessible :country_code, :name, :state_code

  has_many :cities, foreign_key: 'state_code', dependent: :destroy
  belongs_to :country, foreign_key: 'country_code'
end
