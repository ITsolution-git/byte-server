class Profile < ActiveRecord::Base
  attr_accessible :account_number, :mailing_address, :mailing_city,
      :mailing_country, :mailing_zip, :restaurant_name, :user_id, :physical_address,
      :physical_city, :physical_country, :physical_zip, :physical_state, :mailing_state

  belongs_to :user
  validates :physical_zip, :presence => {message: "^Physical zip can't be blank" }, :numericality => {message: "^Zipcode is not a number"} ,:length => { :is => 5 ,message: "^Zipcode must be 5 numbers" }
  validates :mailing_zip, :presence => {message: "^Mailing zip can't be blank"}, :numericality => {message: "^Zipcode is not a number"} ,:length => { :is => 5 ,message: "^Zipcode must be 5 numbers" }
  validates :restaurant_name, :presence => {message:"^Restaurant name can't be blank"}, length:{ maximum: 40,:message => "^Restaurant Name can't be greater than 40 characters."}
  validates :physical_address, :presence => true, length:{ maximum: 40,:message => "^Physical address can't be greater than 40 characters."}
  validates :mailing_address, :presence => {message:"^Mailing address name can't be blank"}, length:{ maximum: 40,:message => "^Mailing address can't be greater than 40 characters."}

  validates :physical_city, :presence => true, length:{ maximum: 40,:message => "^Physical city can't be greater than 40 characters."}
  validates :mailing_city, :presence => {message:"^Mailing city name can't be blank"}, length:{ maximum: 40,:message => "^Mailing city can't be greater than 40 characters."}
  
  def create_custome_profile(location)
    self.restaurant_name = location.name
    self.physical_address = location.address
    self.physical_country = location.country
    self.physical_city = location.city
    self.physical_zip = location.zip
    self.mailing_address = location.address
    self.mailing_country = location.country
    self.mailing_city = location.city
    self.mailing_zip = location.zip
    self.physical_state = location.state
    self.mailing_state = location.state
    self.save
    self
  end

end
