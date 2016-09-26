class Group < ActiveRecord::Base
  attr_accessible :name, :location_id, :customer_arr
  attr_accessor :customer_arr
  belongs_to :location
  has_many :group_user, :dependent => :destroy
end
