class ItemPhoto < ActiveRecord::Base
  attr_accessible :item_id, :photo_id
  belongs_to :item
  belongs_to :photo
end
