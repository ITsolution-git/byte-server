class Category < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :name, :location_id, :description, :order, :redemption_value

  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :location

  has_many :build_menus, :dependent => :destroy, :conditions => {:build_menus => {:active => true}}, inverse_of: :category
  has_many :combo_item_categories, :dependent => :destroy
  has_many :combo_items, :through => :combo_item_categories
  has_many :items, :through => :build_menus
  has_many :menus, :through => :build_menus
  has_many :prizes

  #############################
  ###  VALIDATIONS
  #############################
  validates :name , :presence => true, length:{ maximum: 30,message:"^Category Name can't be greater than 30 characters."}
  validates :redemption_value, :allow_blank => true, :numericality => {:only_integer => true},length:{ maximum: 10}

  #############################
  ###  DEPENDENCY CONFIG
  #############################
  amoeba do
    enable
    exclude_field :build_menus
  end

  #############################
  ###  INSTANCE METHODS
  #############################

  def ==(obj)
    if obj.instance_of?(self.class)
      compare_attributes = ["location_id", "name"]
      compare_attributes.each do |field|
        if self.send(field) != obj.send(field)
          return false
        end
      end
      return true
    end
    return false
  end

  def category_points
    location.try(:points_awarded_for_comment)
  end

  def has_menu_published?
    has_menu_published = false
    self.menus.each do |menu|
      if menu.published?
        has_menu_published = true
        break
      end
    end
    return has_menu_published
  end

  def item_by_build_menu(menu_id, category_id)
    Item.joins(:build_menus).where("build_menus.menu_id = ? AND build_menus.category_id = ?", menu_id, category_id)
  end

  def publish_items
    sql = "SELECT i.id, i.name FROM items i
          INNER JOIN build_menus bm on bm.item_id = i.id and bm.active = 1
          INNER JOIN menus m on m.id = bm.menu_id and m.publish_status = 2
          INNER JOIN categories c on c.id = bm.category_id
          WHERE c.id = #{self.id} ORDER BY bm.category_sequence, bm.item_sequence"
    Item.find_by_sql(sql)
  end
      
  def self.get_name_ids(category_id, location_id)
    category_name = Category.find_by_id(category_id).name
    return Category.where('name = ? AND location_id = ?', category_name, location_id).collect {|x| x.id}
  end

end
