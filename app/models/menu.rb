class Menu < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :name, :location_id, :rating_grade, :publish_start_date, :repeat_time, :repeat_time_to,
                  :menu_servers_attributes, :repeat_on, :publish_status, :publish_email, :menu_type_id, :published_date,
                  :notification_emails, :is_shared

  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :location
  belongs_to :menu_type
  has_many :feedbacks
  has_many :items, :through => :build_menus
  has_many :categories, :through => :build_menus
  has_many :servers, :through => :menu_servers
  has_many :dependent_build_menus, :class_name => 'BuildMenu', :dependent => :destroy, inverse_of: :menu
  has_many :menu_servers, :dependent => :destroy
  has_many :build_menus, :conditions => {:build_menus => {:active => true}}, inverse_of: :menu
  has_many :combo_items

  #############################
  ###  VALIDATIONS
  #############################
  validates :name, :presence => :true, length: { maximum: 30, message:"^Menu Name can't be greater than 30 characters." }
  validate :validate_publish_email
  validate :check_conflict_published


  #############################
  ###  CALLBACKS
  #############################

  before_save :set_default_value
  after_save :update_publish_status


  #############################
  ###  SCOPES
  #############################
  scope :other_menus, -> (id, location_id) { where('id != ? AND location_id = ?', id, location_id) }
  scope :shared, -> (menus) { where(is_shared: true).where('id NOT IN (?)', menus) }


  #############################
  ###  SPECIAL CONFIG
  #############################
  serialize :publish_email, Array
  accepts_nested_attributes_for :menu_servers, :allow_destroy => true


  #############################
  ###  DEPENDENCY CONFIG
  #############################
  amoeba do
    enable
    exclude_field :feedbacks
    exclude_field :build_menus
    exclude_field :dependent_build_menus
    clone [:servers]
    customize(
      lambda do |original, new|
        if original.is_shared?
          new.publish_status = PENDING_STATUS
          new.is_shared = false
        end
      end
    )
  end


  #############################
  ###  CLASS METHODS
  #############################

  def ==(obj)
    if obj.instance_of?(self.class)
      compare_attributes = ["location_id", "name", "rating_grade", "menu_servers", "menu_type_id", "publish_email"]
      compare_attributes.each do |field|
        if self.send(field) != obj.send(field)
          return false
        end
      end
      return true
    end
    false
  end

  def approved?
    self.categories.length != 0 && self.publish_status == APPROVE_STATUS
  end

  def check_conflict_published # TODO: Refactor this method
    if self.pending? || self.publish_start_date.to_s.empty? \
        || self.repeat_time.to_s.empty? || self.repeat_time_to.to_s.empty?
      return true
    end
    now = Time.now.utc.strftime("%Y-%m-%d %H:%M")
    published_date_str = self.publish_start_date.strftime("%Y-%m-%d %H:%M")

    repeat_time = Time.now.utc
    if self.repeat_time
      time_arr = self.repeat_time.split(':')
      repeat_time = repeat_time.change(:hour => time_arr[0], :min => time_arr[1])
    end
    repeat_time_to = Time.now.utc
    if self.repeat_time_to
      time_arr = self.repeat_time_to.split(':')
      repeat_time_to = repeat_time_to.change(:hour => time_arr[0], :min => time_arr[1])
    end
    if repeat_time > repeat_time_to
      repeat_time -= 1.day
    end

    weekday = ""
    weekday = self.repeat_on unless self.repeat_on.to_s.empty?
    weekday = weekday.split(',')

    id = 0
    unless self.new_record?
      id = self.id
    end
    other_menus = Menu.where('publish_start_date != ? AND repeat_time != ? AND repeat_time_to !=?
        AND publish_status = ? AND location_id = ? AND id != ?', "", "", "", APPROVE_STATUS, self.location_id, id)

    other_menus.each do |menu|
      o_weekday = ""
      o_weekday = menu.repeat_on unless menu.repeat_on.to_s.empty?
      o_weekday = o_weekday.split(',')

      o_repeat_time_from = Time.now.utc
      if menu.repeat_time
        time_arr = menu.repeat_time.split(':')
        o_repeat_time_from = o_repeat_time_from.change(:hour => time_arr[0], :min => time_arr[1])
      end
      o_repeat_time_to = Time.now.utc
      if menu.repeat_time_to
        time_arr = menu.repeat_time_to.split(':')
        o_repeat_time_to = o_repeat_time_to.change(:hour => time_arr[0], :min => time_arr[1])
      end
      if o_repeat_time_from > o_repeat_time_to
        o_repeat_time_from -= 1.day
      end

      if published_date_str >= now && self.publish_start_date == menu.publish_start_date
        errors.add(:publish_start_date, "^There was an other menu published at the same time")
        return
      end

      o_weekday.each do |wd|
        if published_date_str >= now
          dayname = self.publish_start_date.wday
          published_start_date_sync = Time.now.utc
          time_arr = self.publish_start_date.strftime("%H:%M").split(':')
          published_start_date_sync = published_start_date_sync.change(:hour => time_arr[0], :min => time_arr[1])
          if dayname.to_s == wd.to_s && (published_start_date_sync >= o_repeat_time_from \
              && published_start_date_sync < o_repeat_time_to)
            errors.add(:publish_start_date, "^There was an other menu published at the same time")
            return
          end
        end
      end

      weekday.each do |wd|

        if menu.publish_start_date.strftime("%Y-%m-%d %H:%M") >= now
          dayname = menu.publish_start_date.wday
          published_start_date_sync = Time.now.utc
          time_arr = menu.publish_start_date.strftime("%H:%M").split(':')
          published_start_date_sync = published_start_date_sync.change(:hour => time_arr[0], :min => time_arr[1])
          if dayname.to_s == wd.to_s && (published_start_date_sync >= repeat_time \
              && published_start_date_sync < repeat_time_to)
            errors.add(:repeat_on, "^There was an other menu published at the same time on #{WEEKDAY[wd.to_i]}")
            return
          end
        end

        if o_weekday.include?(wd) && ((repeat_time >= o_repeat_time_from && repeat_time < o_repeat_time_to) \
            || (repeat_time_to >= o_repeat_time_from && repeat_time_to < o_repeat_time_to))
          errors.add(:repeat_on, "^There was an other menu published at the same time on #{WEEKDAY[wd.to_i]} ")
          return
        end
      end
    end
  end

  def generate_copy_name
    suffix = 'Copy'
    menu = Menu.other_menus(self.id, self.location_id).where('name = ?', "#{self.name} #{suffix}")
    if menu.empty?
      return "#{self.name} #{suffix}"
    end
    (1..100).each do |index|
      menu = Menu.other_menus(self.id, self.location_id).where('name LIKE ?', "#{self.name} #{suffix} #{index}")
      if menu.empty?
        return "#{self.name} #{suffix} #{index}"
      end
    end
    self.name
  end

  def get_categories_built
    category_ids = BuildMenu.where('menu_id = ?', self.id).pluck(:category_id)
    Category.where('id IN (?)', category_ids.uniq)
  end

  def get_items_built
    item_ids = BuildMenu.where('menu_id = ?', self.id).pluck(:item_id)
    Item.where('id IN (?)', item_ids.uniq).not_main_dish
  end

  def get_main_dish
    item_ids = BuildMenu.where('menu_id = ?', self.id).pluck(:item_id)
    item_ids_uniq = item_ids.uniq
    items = Item.where('id IN (?)', item_ids_uniq).main_dish.pluck(:id)
    combo_items = ComboItem.where('item_id IN (?) AND menu_id = ?',
      item_ids_uniq, self.id).pluck(:item_id)
    Item.where('id IN (?)', items - combo_items)
  end

  def get_main_dish_except_combo_item(item_id)
    item_ids = BuildMenu.where('menu_id = ?', self.id).pluck(:item_id)
    item_ids_uniq = item_ids.uniq
    items = Item.where('id IN (?)', item_ids_uniq).main_dish.pluck(:id)
    combo_items = ComboItem.where('item_id IN (?) AND menu_id = ?',
      item_ids_uniq, self.id).pluck(:item_id)
    Item.where('id IN (?)', items - combo_items + [item_id])
  end

  def pending?
    self.publish_status == PENDING_STATUS
  end

  def published?
    self.publish_status == PUBLISH_STATUS
  end

  def notification_emails
    if self.publish_email.is_a?(String)
      self.publish_email
    else
      self.publish_email.join(', ')
    end
  end

  def reward_points # Included for backward compatibility ONLY
    location.points_awarded_for_comment
  end

  def set_default_value
    self.publish_status = 0 if self.new_record?
  end

  def validate_publish_email
    if self.publish_email.is_a?(Array)
      self.publish_email.each do |email|
        unless email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
          errors.add(:publish_email, '^Please enter a valid email')
          return
        end
      end
    else
      unless self.publish_email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        errors.add(:publish_email, '^Please enter a valid email')
      end
    end
  end

  def update_publish_status
    if self.published?
      menu = Menu.where('location_id = ? and publish_status = ? and id != ?', self.location_id, PUBLISH_STATUS, self.id)
      unless menu.empty?
        menu.update_all(:publish_status => APPROVE_STATUS)
      end
    end
  end

  def was_built?
    BuildMenu.where(:menu_id => self.id).any?
  end

end
