class BuildMenu < ActiveRecord::Base
  # BuildMenu is not well named - it should probably be ItemMenuPosition or something similar.
  # A BuildMenu defines where an Item appears, and how it is categorized,
  # on a given Menu.

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :item_id, :menu_id, :category_id, :active, :category_sequence, :item_sequence


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :menu, inverse_of: :build_menus
  belongs_to :category, inverse_of: :build_menus
  belongs_to :item, inverse_of: :build_menus
  has_one :location, through: :item
  has_many :item_comments, :dependent => :destroy
  has_many :item_favourites, :dependent => :destroy
  has_many :item_nexttimes, :dependent => :destroy
  has_many :order_items, :dependent => :destroy
  has_many :order_item_combos, :dependent => :destroy


  #############################
  ###  VALIDATIONS
  #############################
  validates :item, presence: { message: '^Need to Select Menu Item' }
  validates :menu, presence: { message: '^Need to Select Menu' }
  # validates :category, presence: { message: '^Need to Select Category' }
  # validate :ensure_menu_not_published


  #############################
  ###  SCOPES
  #############################
  default_scope where(:active => true)
  scope :get_categories_by_menu, ->(menu_id) { where('menu_id = ?', menu_id).select('distinct category_id, category_sequence') }


  #############################
  ###  CALLBACKS
  #############################
  before_save :set_default_value
  after_save :update_combo
  after_destroy :update_menu_status


  #############################
  ###  DEPENDENCY CONFIG
  #############################
  amoeba do
    enable
  end


  #############################
  ###  INSTANCE METHODS
  #############################
  def get_category_id_by_buid_menu_id(id)
    return BuildMenu.find_by_id(id).category_id
  end

  def get_menu_id_by_buid_menu_id(id)
    return BuildMenu.find_by_id(id).menu_id
  end

  def get_item_name
    return self.item.name
  end
  def update_combo
    unless self.active
      all_menus = BuildMenu.where('menu_id = ?', self.menu_id)
      if all_menus.empty?
        menu = Menu.find(self.menu_id)
        menu.update_attribute(:publish_status, PENDING_STATUS)
      end

      all_build_ids = []
      all_item_ids_delete = []

      build_menu_ids = BuildMenu.where('menu_id = ? AND category_id = ?', self.menu_id,
        self.category_id)
      build_menu_ids.each do |b|
        unless b.item.is_main_dish
          all_build_ids << b.id
        else
          all_item_ids_delete << b.item_id
        end
      end

      # Update Combo Item
      if self.item.is_main_dish
        ComboItem.destroy_all(['menu_id = ? AND item_id = ?', self.menu_id,
          self.item_id])
      #elsif all_build_ids.count == 0
       #  ComboItem.destroy_all(['menu_id = ? AND item_id IN (?)', self.menu_id,
        #  all_item_ids_delete])
      else
        # update PMI
        ComboItemItem.joins(:combo_item).destroy_all(['combo_items.menu_id = ?
          AND combo_item_items.item_id = ?', self.menu_id, self.item_id])

        combos = ComboItem.where('menu_id = ?', self.menu_id)
        combos.each do |combo|
          if combo.combo_item_items.empty? && combo.pmi?
            combo.destroy
          end
          if combo.combo_item_items.empty? && combo.cmi?
            combo.update_attribute(:combo_type, GMI)
          end
        end

        # update GMI
        build_menus = BuildMenu.where('menu_id = ? AND category_id = ?',
          self.menu_id, self.category_id)

        build_menu_count = []
        main_dish = 0
        if !build_menus.empty?
           build_menus.each do |b|
            main_dish =  b.item.is_main_dish
            build_menu_count << main_dish
          end
        end



        if build_menus.empty? || get_value_main_dish(build_menu_count) == true
          ComboItemCategory.joins(:combo_item).destroy_all(['combo_items.menu_id = ?
            AND combo_item_categories.category_id = ?', self.menu_id, self.category_id])
          combos = ComboItem.where('menu_id = ?', self.menu_id)
          combos.each do |combo|
            if combo.combo_item_categories.empty? && combo.gmi?
              combo.destroy
            end
            if combo.combo_item_categories.empty? && combo.cmi?
              combo.update_attribute(:combo_type, PMI)
            end
          end
        end
      end
    end
  end

  def get_value_main_dish(build_menu_count)
    return build_menu_count.uniq.length == 1 &&  build_menu_count[0] == true
    # build_menu_count.each do |b|
    #   if b == false
    #     return false
    #   else
    #     return true
    #   end
    # end
  end

  def set_default_value
    self.active = true if self.active.nil?
  end

  def disable
    self.update_attribute(:active, false)
  end

  def enable?
    return self.active
  end

  def enable(item_sequence=false)
    self.update_attribute(:active, true)
    if item_sequence
      self.update_attribute(:item_sequence, item_sequence)
    end
  end

  # def ensure_menu_not_published
  #   # errors.add(:menu, "published could not be built more") if menu.present? && self.menu.published?
  # end

  def update_menu_status
    if self.menu.present? && self.menu.categories.present? && self.menu.categories.length == 0
      self.menu.update_attributes(:publish_status => PENDING_STATUS)
    end
  end


  #############################
  ###  CLASS METHODS
  #############################
  def self.find_by_items_id(items_id)
    where("item_id IN (?)", items_id)
  end

end
