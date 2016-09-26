class Price < ActiveRecord::Base
  attr_accessible :plan_id, :app_service_id
  
  belongs_to :plan
  belongs_to :app_service
  has_one :user
end
