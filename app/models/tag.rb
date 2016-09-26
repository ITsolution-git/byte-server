class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :items, through: :taggings, source: :taggable, source_type: 'Item'

  validates :name, presence: true

  attr_accessible :name
end
