class Contest < ActiveRecord::Base
  default_scope where('status != ?', "deleted")
  attr_accessible :id, :name, :url, :contact_name, :contact, :description, :publish_date, :start_date, :end_date, :location, :restaurants, :status

  has_many :contest_actions
end
