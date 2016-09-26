class Page < ActiveRecord::Base
  attr_accessible :body, :name, :title
  validates :body, :presence => true
  validates :name, :presence => true
  validates :title, :presence => true
end
