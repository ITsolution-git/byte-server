class Item < ActiveRecord::Base
  # This class would be better named MenuItem.
  # An Item is a specific dish that appears on a Menu.
  # (An Item's category and position on a Menu is defined by a BuildMenu.)

  include ActionView::Helpers::NumberHelper #fix to calculate rating precision(action view method in activerecord)


  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :location_id, :name, :price, :description, :item_type_id, :token,
    :calories, :item_images_attributes, :item_grade, :rating, :alert_type,
    :special_message, :ingredients, :item_item_keys_attributes, :redemption_value, :old_name,
    :old_item_type, :old_description, :old_ingredients, :old_item_keys, :is_main_dish,
    :item_item_options_attributes, :old_item_options, :item_photos_attributes

  attr_accessor :old_name, :old_item_type, :old_description, :old_ingredients, :old_item_keys, :old_item_options


  #############################
  ###  ASSOCIATIONS
  #############################

  belongs_to :item_type
  belongs_to :location

  has_many :build_menus, :dependent => :destroy, :conditions => {:build_menus => {:active => true}},
    inverse_of: :item
  has_many :categories, :through => :build_menus
  has_many :combo_item_items, :dependent => :destroy
  has_many :combo_items, :dependent => :destroy
  has_many :item_photos
  has_many :images, through: :item_photos, source: :photo
  has_many :item_comments, :through=>:build_menus
  has_many :item_favourites, :through=>:build_menus
  has_many :item_images, :dependent=>:destroy
  has_many :item_item_keys, :dependent => :destroy # Redundant - is this used anywhere?
  has_many :item_item_options, :dependent => :destroy # Redundant - is this used anywhere?
  has_many :item_keys, :through => :item_item_keys
  has_many :item_options, :through => :item_item_options
  has_many :item_nexttimes, :through => :build_menus
  has_many :menus, :through => :build_menus
  has_many :order_items
  has_many :contest_actions
  has_many :order_item_combos
  has_many :prizes, :through => :build_menus
  has_many :push_notifications, as: :push_notifiable, :dependent => :destroy
  has_many :social_shares
  has_many :view_item_options, :class_name => "ItemOption", :through => :item_item_options,
    :conditions => {:item_options => {:is_deleted => 0}}, :order =>"name"
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings


  #############################
  ###  NESTED ATTRIBUTES
  #############################
  accepts_nested_attributes_for :item_item_keys, :allow_destroy => true
  accepts_nested_attributes_for :item_item_options, :allow_destroy => true
  accepts_nested_attributes_for :item_photos, :allow_destroy => true
  accepts_nested_attributes_for :images


  #############################
  ###  SCOPES
  #############################
  scope :main_dish, -> {where(is_main_dish: true)}
  scope :not_main_dish, -> {where(is_main_dish: false)}



  #############################
  ###  CALLBACKS
  #############################
  after_initialize :init
  #remove directory left after destroy
  # after_destroy :remove_logo_dir
  # def remove_logo_dir
  #   #remove carrierwave uploads
  #   FileUtils.remove_dir("#{Rails.root}/public/uploads/item/logo/#{id}", :force => true)
  # end


  #############################
  ###  VALIDATIONS
  #############################
  validates :location_id, presence: true, numericality: { only_integer: true }
  validates_length_of :special_message, :maximum => 20, :message => "^Special Message can't be greater than 20 characters."
  validates :name , :presence => {message: "^Item name can't be blank"},length:{ maximum: 60,message:"^Menu Item name can't be greater than 60 characters"}
  #validates :special_message , :allow_blank => true
  validates :description , :presence => {message: "^Item Description can't be blank"}
  validates :price, :presence => {message: "^Price can't be blank"}, :numericality => true,
            :format => { :with => /^(\d{1,3})\.(\d{0,2})$/,:message => "^Invalid Price number format. Use: xxx.xx"}
  validates :redemption_value, :allow_blank => true, :numericality => {:only_integer => true}
  validates :calories, :numericality => {:only_integer => true}, :allow_blank => true,length:{ maximum: 6}
  validates :ingredients,:allow_blank => true,length:{ maximum: 100, message: "^Ingredients and tags can't be greater than 100 characters."}
  validate :ensure_has_3_item_keys


  #############################
  ###  DEPENDENCY CONFIG
  #############################
  # validates :logo, :presence => true
  mount_uploader :logo, LogoUploader

  amoeba do
    enable
    exclude_field :build_menus
    customize(lambda { |original_object, new_object|
      original_object.item_images.each do |item_image|
        dup_image = new_object.item_images.new
        begin
          dup_image.duplicate_file(item_image)
        rescue => e
          Rails.logger.error "Error, while copying image for #{original_object.name}"
        end
      end
    })
  end


  #############################
  ###  INSTANCE METHODS
  #############################

  [:pmi?, :gmi?, :cmi?].each do |method_name|
    define_method method_name do |menu_id|
      combo_item = ComboItem.find_by_menu_id_and_item_id(menu_id, self.id)
      if combo_item.nil?
        return false
      end
      return combo_item.send(method_name)
    end
  end

  def ==(obj)
    if obj.instance_of?(self.class)
      compare_attributes = ["location_id", "is_main_dish", "name", "price", "description", "item_type_id", "token",
          "calories", "ingredients", "special_message", "redemption_value", "item_item_keys", "item_images"]
      compare_attributes.each do |field|
        if self.send(field) != obj.send(field)
          return false
        end
      end
      return true
    end
    return false
  end

  def avg_rating
    rating = 0
    item_comment = ItemComment.joins(:build_menu).where("build_menus.id=?", self.build_id)
    if item_comment.empty?
      return 0
    else
      item_comment.collect {|c| rating=rating + c.rating}
      rating = rating.to_f/item_comment.count
      return rating
    end
    return rating
  end

  def backup_attributes
    if not self.new_record?
      self.old_name = self.name
      self.old_description = self.description
      self.old_item_type = self.item_type.nil? ? '' : self.item_type.name
      self.old_ingredients = (self.ingredients.nil? or self.ingredients.empty?) ? '' : self.ingredients
      self.old_item_keys = (self.item_item_keys.map {|x| x.item_key.name}).join('|||').strip
      self.old_item_options = (self.item_item_options.map {|x| x.item_option.id}).join('|').strip
    end
  end

  def combo_item(menu_id)
    ComboItem.find_by_menu_id_and_item_id(menu_id, self.id)
  end

  def comments_count
    self.item_comments.comments.count
  end

  def display_price_with_float_format
    self.price.to_f
  end

  def ensure_has_3_item_keys
    item_keys = self.item_item_keys.map {|x| x.id unless x.id.nil?}.compact
    errors.add(:item_keys, "^Item only has maximum 3 item keys") if item_keys.length > 3
  end

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Server.where(token: random_token).exists?
    end
  end

  def get_category_id
    return Category.joins(:build_menus).where("build_menus.item_id=?",self.id).first.id
  end

  def get_category_id_by_menu_id(item_id, menu_id)
    return BuildMenu.where("item_id = ? AND menu_id = ? AND active = 1", item_id, menu_id).first.category_id
  end

  def get_category_name
    return Category.joins(:build_menus).where("build_menus.item_id=?",self.id).first.name
  end

  def get_reward_point  # TODO: duplicate of points_awarded_for_comment
    return points_awarded_for_comment
  end

  def get_reward_points(menu_id = nil, category_id = nil)  # TODO: duplicate of points_awarded_for_comment
    return points_awarded_for_comment
  end

  def has_menu_published?
    self.menus.each do |menu|
      if menu.published?
        return true
      end
    end
    return false
  end

  def init
    if self.has_attribute?(:token) && self.token.nil?
      self.generate_token
    end
  end

  def logo_changed? # TODO: Refactor this craziness
    logger.debug "---------------------------------------- LOGO CHANGED -------------------------------------"
    return false
  end

  def points_awarded_for_comment
    location.try(:points_awarded_for_comment)
  end

  def point_pay
    return (use_point == 't' ? price : nil)
  end

  def average_rating
    total = item_comments.reduce(0) do |accumulator, review|
      accumulator + review.rating.to_i
    end
    count = item_comments.count.zero? ? 1 : item_comments.count
    total / count
  end

  def ratings_count
    item_comments.ratings.size
  end

  def review
    item_comments = ItemComment.joins(:build_menu).where("build_menus.item_id=?", self.id)
    if item_comments.empty?
      return 0
    else
      item_comments.size
    end
  end

  def reward_points # Synonymous with points_awarded_for_comment - included for backward compatibility ONLY
    points_awarded_for_comment
  end


  #############################
  ###  CLASS METHODS
  #############################

  def self.get_items_category(user_id, location_id, category_id)
    sql = "SELECT distinct #{user_id} as user_id, i.*, IFNULL(i.rating,0) as rating, c.id as category_id,(b.created_at) as date, m.id as menu_id,b.id as build_id ,
          IFNULL(nt.nexttime,0) as is_nexttime, IFNULL( f.favourite,0) as is_favourite, b.category_sequence, b.item_sequence FROM locations l
          INNER JOIN items i ON   l.id = i.location_id
          INNER JOIN build_menus b ON i.id = b.item_id
          LEFT JOIN item_nexttimes nt on nt.build_menu_id = b.id and  nt.user_id = #{user_id}
          LEFT JOIN item_favourites f on f.build_menu_id = b.id and f.user_id = #{user_id}
          INNER JOIN menus m ON b.menu_id = m.id
          INNER JOIN categories c ON c.id = b.category_id
          WHERE m.publish_status = 2 AND i.location_id = #{location_id} AND c.id = #{category_id} AND b.active = #{1}
          ORDER BY b.category_sequence, b.item_sequence"
    return self.find_by_sql(sql)
  end

  def self.get_items_publish(location_id)
    item_id_arr = []
    sql = "select distinct(item_id) as id from build_menus b join item_favourites i on b.id = i.build_menu_id
    where b.menu_id = (SELECT (id) as menu_id FROM menus where location_id=#{location_id}
    and publish_status=2) and b.active = 1 and i.favourite =1"

    # sql= "SELECT distinct(bm.item_id) as id
    # FROM item_favourites ifa
    # INNER JOIN build_menus bm ON bm.id = ifa.build_menu_id
    # INNER JOIN menus m ON bm.menu_id = m.id
    # Inner join locations lo
    # On lo.id= m.location_id
    # INNER JOIN items i ON i.location_id = m.location_id
    # Inner join users u
    # On u.id= lo.owner_id
    # WHERE m.location_id =#{location_id} and ifa.favourite=1 and m.publish_status=2 and bm.active=1"
    item_id_arr = self.find_by_sql(sql)

    items = Item.where("id IN (?)", item_id_arr)

    return items
  end

  def self.items_favourite(user_id, location_id)
    sql="SELECT it.id, it.name, c.id as category_id, c.name as category_name, b.menu_id as menu_id, b.id as build_id, 0 as type
        FROM item_favourites i
        JOIN build_menus b ON i.build_menu_id = b.id
        JOIN menus m ON m.id = b.menu_id
        JOIN categories c ON c.id = b.category_id
        JOIN items it ON it.id =b.item_id
        WHERE m.publish_status = 2 AND i.user_id=#{user_id} AND i.favourite=1 AND it.location_id=#{location_id} AND b.active = '1'"
    return self.find_by_sql(sql)
  end

  #Search item by item name/item key
  def self.search_items(user_id, location_id, keyword)
    sql ="SELECT distinct ? as user_id, i.*, c.id as category_id, c.name as category_name, m.id as menu_id, b.id as build_id,
            IFNULL(nt.nexttime,0) as is_nexttime, IFNULL( f.favourite,0) as is_favourite, b.created_at
          FROM locations l
          INNER JOIN items i ON l.id = i.location_id
          INNER JOIN build_menus b ON i.id = b.item_id
          LEFT JOIN item_nexttimes nt on nt.build_menu_id = b.id and  nt.user_id = ?
          LEFT JOIN item_favourites f on f.build_menu_id = b.id and f.user_id = ?
          LEFT JOIN item_item_keys iik ON iik.item_id = i.id
          LEFT JOIN item_keys ik ON ik.id = iik.item_key_id
          INNER JOIN menus m ON b.menu_id = m.id
          INNER JOIN categories c ON c.id = b.category_id
          WHERE m.publish_status = 2  AND l.id = ? AND b.active = 1
          AND (MATCH (i.name) AGAINST (? IN BOOLEAN MODE)
              OR MATCH (i.ingredients) AGAINST (? IN BOOLEAN MODE)
              OR MATCH (i.description) AGAINST (? IN BOOLEAN MODE)
              OR MATCH (i.special_message) AGAINST (? IN BOOLEAN MODE)
              OR MATCH (ik.description) AGAINST (? IN BOOLEAN MODE))
          ORDER BY b.created_at, c.id, i.id"
    completed_sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, user_id, user_id, user_id, location_id, edit_keyword(keyword),\
      edit_keyword(keyword), edit_keyword(keyword), edit_keyword(keyword), edit_keyword(keyword)])
    return Item.find_by_sql(completed_sql)
  end

  def self.edit_keyword(keyword)
    keyword = keyword.split(" ")
    keyword.each do  |i|
      i.strip
    end
    return keyword.map { |k| k + '* '}.join.chop
  end

  def self.get_items(user_id, location_id, category_id, item_id)
    sql = "SELECT distinct #{user_id} as user_id, i.*, IFNULL(i.rating,0) as rating, c.id as category_id,(b.created_at) as date, m.id as menu_id,b.id as build_id ,
          IFNULL(nt.nexttime,0) as is_nexttime, IFNULL( f.favourite,0) as is_favourite, b.category_sequence, b.item_sequence FROM locations l
          INNER JOIN items i ON   l.id = i.location_id
          INNER JOIN build_menus b ON i.id = b.item_id
          LEFT JOIN item_nexttimes nt on nt.build_menu_id = b.id and  nt.user_id = ?
          LEFT JOIN item_favourites f on f.build_menu_id = b.id and f.user_id = ?
          INNER JOIN menus m ON b.menu_id = m.id
          INNER JOIN categories c ON c.id = b.category_id
          WHERE m.publish_status = 2 AND i.location_id = ? AND c.id = ? AND b.active = ? AND i.id = ?
          ORDER BY b.category_sequence, b.item_sequence"
    completed_sql = ActiveRecord::Base.send(:sanitize_sql_array,[sql, user_id, user_id, location_id, category_id, ACTIVE, item_id])
    return self.find_by_sql(completed_sql)
  end

  # Begin - Implement the new version of order feature

  def self.get_items_v1(user_id, location_id, category_id, item_id)
    sql = "SELECT distinct #{user_id} as user_id, i.*, IFNULL(i.rating, 0) as rating, c.id as category_id,(b.created_at) as date,
          m.id as menu_id,b.id as build_id, IFNULL(nt.nexttime, 0) as is_nexttime, IFNULL(f.favourite, 0) as is_favourite
          FROM locations l
          INNER JOIN items i ON l.id = i.location_id
          INNER JOIN build_menus b ON i.id = b.item_id
          LEFT JOIN item_nexttimes nt on nt.build_menu_id = b.id and  nt.user_id = ?
          LEFT JOIN item_favourites f on f.build_menu_id = b.id and f.user_id = ?
          INNER JOIN menus m ON b.menu_id = m.id
          INNER JOIN categories c ON c.id = b.category_id
          WHERE m.publish_status = 2 AND i.location_id = ? AND c.id = ? AND b.active = ? AND i.id = ?"
    completed_sql = ActiveRecord::Base.send(:sanitize_sql_array,[sql, user_id, user_id, location_id, category_id, ACTIVE, item_id])
    return self.find_by_sql(completed_sql)
  end

  # TODO: should implement ability to apply tags
  def drink?
    true
  end

  def trending_points
    social_shares = 0
    favorites = self.item_favourites.count
    b_grades = self.item_comments.where('rating > ? and rating < ?', 5.0, 9.0).count
    a_grades = self.item_comments.where('rating > ?', 9.0).count
    social_shares + favorites + b_grades + a_grades
  end

  def recent_trending_points
    time = Time.now.in_time_zone(self.location.timezone) - 3.days

    favorites = self.item_favourites.recent(time).count
    b_grades = self.item_comments.where('rating > ? and rating < ?', 5.0, 9.0).recent(time).count
    a_grades = self.item_comments.where('rating > ?', 9.0).recent(time).count
    favorites + b_grades + a_grades
  end

  # End - Implement the new version of order feature
  private
    def replace_word(string, word, new_word)
      return "" if string.nil?
      str_array = string.split('|||')
      index = str_array.index(word.to_s)
      str_array.delete_at(index.to_i) if not index.nil?
      str_array.push(new_word.to_s.strip)
      return str_array.join('|||')
    end

    def strip_attrs(string)
      string_array = string.split('|||')
      if string[0..2] == '|||'
        string_array.delete_at(0)
      end
      return string_array.join('|||').strip
    end

end
