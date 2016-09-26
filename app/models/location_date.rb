class LocationDate < ActiveRecord::Base
  attr_accessible :time_from, :time_to, :day, :location_id
  
  DAYSLIST = [["Monday", "monday"], ["Tuesday", "tuesday"], ["Wednesday", "wednesday"], ["Thursday", "thursday"], ["Friday", "friday"], ["Saturday", "saturday"], ["Sunday", "sunday"], ["Mon - Fri", "mon_fri"], ["Sat - Sun", "sat_sun"]]
  
  belongs_to :location
  
  after_save :delete_blank_record
  
  def delete_blank_record
    destroy if day.blank?
  end 
end
