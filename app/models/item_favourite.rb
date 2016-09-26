class ItemFavourite < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :build_menu_id, :user_id, :favourite


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :build_menu
  belongs_to :user

  def self.recent(days)
    where('item_favourites.created_at > ?', days)
  end
end
