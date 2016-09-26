class Server < ActiveRecord::Base
  attr_accessible :location_id, :name ,:bio, :rating, :token, :avatar_id

  belongs_to :location
  validates :name, :presence => true, length: { maximum: 16, :message => "^Name can't be greater than 16 characters."}
  has_many :menus, :through => :menu_servers
  has_many :menu_servers, :dependent => :destroy
  has_many :server_ratings
  has_one :server_avatar, :dependent => :destroy
  belongs_to :avatar, class_name: 'Photo'
  has_many :orders
  after_initialize :init

  def ==(obj)
    if obj.instance_of?(self.class)
      compare_attributes = ["location_id", "name", "bio", "token", "server_avatar"]
      compare_attributes.each do |field|
        puts "@@ field: #{self.send(field).inspect}"
        puts "@@ obj field: #{obj.send(field).inspect}"
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

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Server.where(token: random_token).exists?
    end
  end

  def get_avg_rating
    rating =0
    s = ServerRating.where("rating IS NOT NULL AND server_id=?",self.id)
    if s.empty?
      return 0
    else
      s.collect {|c| rating=rating + c.rating}
      rating = rating.to_f/s.count
      return rating
    end
    return rating
  end

  def get_rating_count
    count=0
    item_comment = ServerRating.where("server_id=?",self.id)
    item_comment.each do |item|
      if item.rating !=0
        count=count+1
      end
    end
    return count
  end

  def get_comment_count
    count=0
    item_comment = ServerRating.where("server_id=?",self.id)
    item_comment.each do |item|
      if item.text !=""
        count=count+1
      end
    end
    return count
  end

  def self.get_servers_current_order(user_id, location_id)
    sql = "SELECT distinct sf.user_id,s.*,IFNULL(sf.favourite,0) as is_favorite FROM servers s
           join menu_servers ms on ms.server_id = s.id
           join menus m on m.id =ms.menu_id and m.publish_status = 2
           join locations l on l.id = m.location_id
           left join server_favourites sf on s.id = sf.server_id and sf.user_id = #{user_id}
           where l.id = #{location_id} order by s.id"
    return self.find_by_sql(sql)
  end

  def self.get_servers_order_detail(user_id, order_id)
    sql = "SELECT distinct s.*, IFNULL(sf.favourite, 0) as is_favorite FROM servers s
                 join orders o on o.server_id = s.id
                 left join server_favourites sf on s.id = sf.server_id and sf.user_id = #{user_id}
                 where o.id = #{order_id} order by s.id"
    return self.find_by_sql(sql)
  end

  #Get servers favourite
  def self.servers_favourite(user_id, location_id)
    sql="SELECT s.id, CONCAT(s.name, ' (server)')  as name, IFNULL(s.rating,0) as rating
          FROM server_favourites sf
          JOIN servers s ON sf.server_id = s.id
          LEFT JOIN server_avatars sav ON sav.server_id = s.id
          JOIN locations l ON l.id = s.location_id AND l.id=#{location_id}
          WHERE sf.favourite=1 AND sf.user_id=#{user_id}"
    return self.find_by_sql(sql)
  end

  # Begin - Implement the new version of order feature
  def self.get_server_of_current_order(user_id, location)
    sql = "SELECT distinct sf.user_id,s.*,IFNULL(sf.favourite, 0) as is_favorite FROM servers s
           join menu_servers ms on ms.server_id = s.id
           join menus m on m.id =ms.menu_id and m.publish_status = 2
           join locations l on l.id = m.location_id
           left join server_favourites sf on s.id = sf.server_id and sf.user_id = #{user_id}
           where l.id = #{location.id} order by s.id"
    return self.find_by_sql(sql)
  end

  def self.get_servers(user_id, order_id)
    sql = "SELECT distinct s.*,IFNULL(sf.favourite, 0) as is_favorite FROM servers s
           join orders o on o.server_id = s.id
           left join server_favourites sf on s.id = sf.server_id and sf.user_id = #{user_id}
           where o.id = #{order_id} order by s.id"
    return self.find_by_sql(sql)
  end
  # End - Implement the new version of order feature
end
