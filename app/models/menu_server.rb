class MenuServer < ActiveRecord::Base
  attr_accessible :menu_id, :server_id, :server
  belongs_to :menu
  belongs_to :server
end