class StatusPrize < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :location_id, :name


  #############################
  ###  ASSOCIATIONS
  #############################
  has_many :prizes, :dependent => :destroy
  belongs_to :location


  #############################
  ###  METHODS
  #############################
  def self.search_customer_status(search)
  	return StatusPrize.where("(name LIKE ?)",'%' + search + '%')
  end

  def self.get_location_prizes(location_id)
    @prizes = []
    status_prize_ids = StatusPrize.where(location_id: location_id).pluck(:id) 
    unless status_prize_ids.empty?
      @prizes = Prize.joins(:status_prize).
        where('status_prize_id IN (?)', status_prize_ids).where(is_delete: false).
        order('status_prizes.name')
    end
    return @prizes
  end
  
end

