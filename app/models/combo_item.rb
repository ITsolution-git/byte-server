class ComboItem < ActiveRecord::Base
  attr_accessible :item_id, :menu_id, :name, :combo_type
   attr_accessor :check_combo_type

  belongs_to :item
  belongs_to :menu
  has_many :combo_item_categories, :dependent => :destroy
  has_many :categories, :through => :combo_item_categories
  has_many :combo_item_items, :dependent => :destroy
  has_many :items, :through => :combo_item_items
  has_many :order_items

  delegate :location_id , to: :menu, allow_nil: true

  validates :name, :presence => true, length: {maximum: 40}
  validate :name_unique
  validates :menu_id, :presence => true
  # validates :item_id, :presence => {message:"^Please select main dish to create combo"}

  def ==(obj)
    if obj.instance_of?(self.class)
      compare_attributes = ["item_id", "menu_id", "name", "combo_type", "combo_item_items", "combo_item_categories"]
      compare_attributes.each do |field|
        if self.send(field) != obj.send(field)
          return false
        end
      end
      return true
    end
    return false
  end

  def pmi?
    return self.combo_type == PMI
  end

  def cmi?
    return self.combo_type == PMI_GMI || self.combo_type == GMI_PMI
  end

  def name_unique
    return if self.name.to_s.empty?
    location_id = self.location_id
    combo = ComboItem.joins(:menu).where('combo_items.name = ? AND
      menus.location_id = ? AND combo_items.id != ?', self.name, location_id, self.id.to_i)
    errors.add(:name, "^The Combo name is duplicated. Please enter another name.") unless combo.empty?
  end

  def gmi?
    return self.combo_type == GMI
  end
end
