class AppService < ActiveRecord::Base
  attr_accessible :name, :limit, :description

  validates :name, :presence => true, :uniqueness => true

  has_many :users
  has_many :prices

  def self.find_plan(id)
    app_service = AppService.find(id)
    return BraintreeRails::Plan.find(app_service.name)
  end

  def unlimit?
    self.limit == 0
  end

  def basic?
    self.name.downcase == BASIC
  end

  def deluxe?
    self.name.downcase == DELUXE
  end

  def premium?
    self.name.downcase == PREMIUM
  end

  def limit
    read_attribute(:limit).present? ? read_attribute(:limit) : -1
  end
end
