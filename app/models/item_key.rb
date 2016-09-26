class ItemKey < ActiveRecord::Base
  attr_accessible :description, :name, :location_id, :old_name, :token, :image_id
  attr_accessor :old_name

  has_many :items, :through => :item_item_keys
  has_many :item_item_keys, :dependent => :destroy
  belongs_to :location
  has_one :item_key_image, :dependent => :destroy
  belongs_to :image, class_name: 'Photo'
  validates :name ,:presence =>true , length:{maximum: 60,message:"^Menu Key Name can't be greater than 60 characters."}
  validates :description, :presence => true, length:{ maximum: 30,message:"^Menu Key Description can't be greater than 30 characters."}
  validates :image, presence: true

  after_initialize :init

  alias_method :photo, :image

  amoeba do
    enable
    customize(lambda { |original_object, new_object|
      dup_image = new_object.build_item_key_image
      begin
        dup_image.duplicate_file(original_object.item_key_image)
      rescue => e
        Rails.logger.error "Error, while copying image for #{original_object.name}"
      end
    })
  end

  def ==(obj)
    if obj.instance_of?(self.class)
      compare_attributes = ["description", "name", "location_id", "token", "item_key_image"]
      compare_attributes.each do |field|
        if self.send(field) != obj.send(field)
          return false
        end
      end
      return true
    end
    return false
  end

  def init
    if self.has_attribute?(:token) && self.token.nil?
      self.generate_token
    end
  end

  def has_item_contains_menu_published?
    self.items.each do |item|
      if item.has_menu_published?
        return true
      end
    end
    false
  end

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Server.where(token: random_token).exists?
    end
  end

  def image_thumbnail
    image.fullpath(width: 100, height: 100, crop: :limit) if image.present?
  end

  def replica_is_attached_to_menu_item( menu_item )
    if is_global?
      return menu_item.item_keys.exists?(:location_id => menu_item.location_id, :name => self.name, :description => self.description)
    end

    false
  end
end
