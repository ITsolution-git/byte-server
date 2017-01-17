class FundraiserType < ActiveRecord::Base
  attr_accessible :fundraiser_id, :image, :name

  has_and_belongs_to_many :locations
  belongs_to :fundraiser
end
