class FundraiserType < ActiveRecord::Base
  attr_accessible :fundraiser_id, :image, :name

  belongs_to :fundraiser
end
	