class ComboItemCategory < ActiveRecord::Base
  attr_accessible :category_id, :combo_item_id, :quantity, :sequence

  belongs_to :category
  belongs_to :combo_item
  scope :get_quantity, ->(category_id, combo_item_id)\
    {where('category_id = ? AND combo_item_id = ?', category_id, combo_item_id)}

  # def category_by_menu(menu_id)
  #   Category.joins(:build_menus).where("build_menus.menu_id = ?", menu_id).first
  # end



  def ==(obj)
    if obj.instance_of?(self.class)
      compare_attributes = ["category_id", "combo_item_id", "quantity", "sequence"]
      compare_attributes.each do |field|
        if self.send(field) != obj.send(field)
          return false
        end
      end
      return true
    end
    return false
  end
end
