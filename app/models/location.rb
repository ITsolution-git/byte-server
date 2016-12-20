require 'cgi'
class Location < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper #fix to calculate rating precision(action view method in activerecord)
  extend FriendlyId


  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessor :full_address, :hour_of_operation, :time_open, :time_close, :days, :skip_primary_cuisine_validation, :contests

  attr_accessible :name, :address, :owner_id, :lat, :long, :rating, :city, :state, :country, :zip, :phone, :url,
    :location_images_attributes, :redemption_password, :bio, :token, :rsr_admin, :rsr_manager,
    :tax, :time_from, :time_to, :full_address, :hour_of_operation, :chain_name, :timezone,
    :created_by, :last_updated_by, :info_id, :twiter_url, :facebook_url, :google_url,
    :instagram_username,:linked_url, :primary_cuisine, :secondary_cuisine,:com_url, :location_dates,
    :location_dates_attributes, :time_open, :time_close, :days, :customer_id, :logo_id, :logo_url,
    :location_image_photos_attributes, :images_attributes, :skip_primary_cuisine_validation, :service_fee_type, :fee, :contests,
    :weekly_progress_report, :weekly_progress_email, :fundraisers


  #############################
  ###  ASSOCIATIONS
  #############################

  has_and_belongs_to_many :fundraisers
  belongs_to :info
  belongs_to :owner, class_name: 'User'
  belongs_to :logo, class_name: 'Photo'
  has_many :location_image_photos
  has_many :images, through: :location_image_photos, source: :photo

  has_one :subscription

  has_many :build_menus, :through => :menus, :conditions => {:build_menus => {:active => true}}
  has_many :cashiers, :foreign_key => 'employer_id', :class_name => 'User'
  has_many :categories, :dependent => :destroy
  has_many :checkins, :dependent => :destroy
  has_many :recent_checkins, :class_name => "Checkin",
              :conditions => proc { [ "checkins.created_at > ?", CHECKINS_VALID_FOR_HOURS.hours.ago ]}
  has_many :copy_shared_menu_statuses, dependent: :destroy
  has_many :customers_locations, :class_name => "CustomersLocations", :dependent => :destroy
  has_many :group, :dependent => :destroy
  has_many :hour_operations, :dependent => :destroy
  has_many :items, :dependent => :destroy
  has_many :item_comments, :through => :items
  has_many :item_keys, :dependent => :destroy
  has_many :item_options, :dependent => :destroy
  has_many :location_comments, :dependent => :destroy
  has_many :location_dates, :dependent => :destroy
  has_many :location_favourites, :dependent=>:destroy
  has_many :location_images, :dependent => :destroy
  has_one  :location_logo, :dependent => :destroy
  has_many :location_visiteds, :dependent => :destroy
  has_many :menus, :dependent => :destroy
  has_many :notifications, :class_name => "Notifications", :dependent => :destroy
  has_many :share_prizes, :class_name => "SharePrize", :dependent => :destroy
  has_many :photos, as: :photoable
  has_many :push_notifications, as: :push_notifiable, :dependent => :destroy
  has_many :orders, :dependent => :destroy
  has_many :contest_actions
  has_many :servers, :dependent => :destroy
  has_many :status_prizes, dependent: :destroy
  has_many :user_points, :dependent => :destroy
  has_many :subscriptions
  has_many :social_shares
  has_many :rewards
  has_many :user_rewards, through: :rewards

  #############################
  ###  CALLBACKS
  #############################
  after_initialize :init
  after_validation :reverse_geocode
  after_validation :geocode, if: :needs_to_be_geocoded?
  before_save :set_default_chain_name, :update_timezone
  after_create :create_manager_account

  #############################
  ###  SCOPES
  #############################
  default_scope where('locations.active = true')
  scope :in_chain, -> (name) { where(chain_name: name) }

  ['rsr_admin', 'rsr_manager'].each do |field|
    scope "where_by_#{field}", ->(user_id) {where("#{field} LIKE ? OR #{field} LIKE ? OR #{field} LIKE ?",
        "#{user_id},%", "%,#{user_id},%", "%,#{user_id},")}
  end


  #############################
  ###  VALIDATIONS
  #############################
  validates_format_of :url, :with => /^[w]{3}\.[\S]+\.[\S]+/, :allow_blank=> true
  validates :phone,:allow_blank=> true,
    :format => { :with => /^\(([0-9]{3})\)([ ])([0-9]{3})([-])([0-9]{4})$/,
      :message => "^Invalid Phone number format. Use: (xxx) xxx-xxxx"}
  validates :name, :presence => {message:"^Restaurant name can't be blank"},
    length:{ maximum: 40,:message => "^Restaurant Name can't be greater than 40 characters."}
  validates :chain_name, :allow_blank => true,
    length:{ maximum: 40,:message => "^Chain Name can't be greater than 40 characters."}
  validates :address, :presence => true
  validates :city, :presence => true
  validates :primary_cuisine, :presence => true, if: :use_primary_cuisine? #on: :update
  validates :state, :presence => true
  validates :lat, :numericality => true, :allow_blank=> true
  validates :long, :numericality => true, :allow_blank=> true
  validates :rating, :numericality => true, :allow_blank => true
  validates :zip, :allow_blank => true, :numericality => {message: "^Zipcode is not a number"},
    :length => { :is => 5 ,message: "^Zipcode must be 5 numbers" }
  validates :zip, presence: true
  validates :tax,:numericality => true, :allow_blank => true,
   :format => { :with => /^(\d{1,3})\.(\d{0,2})$/,
   :message => "^Invalid Tax number format. Use: xxx.xx"}

  #############################
  ###  NESTED ATTRIBUTES
  #############################
  accepts_nested_attributes_for :location_dates, :allow_destroy => true,
    :reject_if => proc { |a| a[:day].blank? && a[:time_from].blank? && a[:time_to].blank? }
  accepts_nested_attributes_for :location_image_photos
  accepts_nested_attributes_for :images


  #############################
  ###  DEPENDENCY CONFIG
  #############################
  acts_as_strip :name, :address, :city, :state, :country, :zip, :phone, :url, :bio, :tax
  reverse_geocoded_by :latitude, :longitude, address: :full_address
  geocoded_by :full_address, latitude: :lat, longitude: :long
  friendly_id :name, use: :slugged
  amoeba do
    enable
  end


  #############################
  ###  INSTANCE METHODS
  #############################

  # TODO: We should probably get rid of the following 3 methods:
  def type
    "mymenu"
  end

  def reference
    ""
  end

  def type_v1
    "byte"
  end


  def create_manager_account
    user = self.owner
    rsr_manager = user.id.to_s + ','
    self.update_attribute(:rsr_manager, rsr_manager)
    nil
  end

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Server.where(token: random_token).exists?
    end
  end

  def get_menus_built
    menu_ids = self.menus.select {|m| m.id unless m.published?}
    menu_built_ids = BuildMenu.where('menu_id IN (?)', menu_ids).pluck(:menu_id)
    Menu.where('id IN (?)', menu_built_ids.uniq)
  end

  def init
    if self.has_attribute?(:token) && self.token.nil?
      self.generate_token
    end
  end

  def is_owned_by?(user)
    user.id.to_i == self.owner_id.to_i
  end

  def contests
    res = []
    contests = Contest.all
    contests.each do |c|
      if Time.parse(c.start_date) < Time.now && Time.parse(c.end_date) > Time.now
        restaurants = c.restaurants.split(",").map { |s| s.to_i }
        if restaurants.include?(self.id)
          res.push(c)
        end
      end
    end
    res
  end

  # def messages?(user)
  #   self.get_global_message(user.email, self.id).first
  # end
  #
  # def prizes?(user)
  #   @points = self.points_awarded_for_checkin + user.points
  #   @prizes = Prize.get_unlocked_prizes_by_location(self.id, @points, user.id)
  # end

  def points_awarded_for_checkin
    if social_points.present? && social_points.ibecon_point.present?
      return social_points.ibecon_point
    else
      return DEFAULT_POINTS_AWARDED_FOR_CHECKIN
    end
  end

  def points_awarded_for_comment
    if social_points.present? && social_points.comment_point.present?
      return social_points.comment_point
    else
      return DEFAULT_POINTS_AWARDED_FOR_COMMENT
    end
  end

  def set_default_chain_name
    self.chain_name = name if chain_name.nil? || chain_name.strip.empty?
  end

  def social_points
    return @social_points if @social_points
    @social_points = SocialPoint.find_by_location_id(self.id)
  end

  def update_timezone
    # This method relies on the Google Timezone API:
    # https://developers.google.com/maps/documentation/timezone/#Requests
    base_url = 'https://maps.googleapis.com/maps/api/timezone/json?location='
    location = "#{self.lat},#{self.long}"
    tail_url = '&timestamp=1331161200'
    other_url = '&sensor=true'
    main_url = base_url + location + tail_url + other_url
    url = URI.parse(URI.encode(main_url))
    response = Net::HTTP.start(url.host, use_ssl: true, verify_mode:
    OpenSSL::SSL::VERIFY_NONE) do |http|
      http.get url.request_uri
    end
    case response
    when Net::HTTPRedirection
      # repeat the request using response['Location']
    when Net::HTTPSuccess
      outputData = JSON.parse response.body
      self.timezone = outputData['timeZoneId'] if not outputData.nil?
    else
      # response code isn't a 200; raise an exception
      self.timezone = DEFAULT_TIMEZONE
    end
  end

  def needs_to_be_geocoded?
    # If lat/long is empty, or the 'address' field has changed
    lat.blank? || long.blank? || address_changed?
  end

  def full_address
    "#{(address + ',') unless address.to_s.empty?} #{(city + ',') unless city.to_s.empty?} #{(state + ',') unless state.to_s.empty?} #{country}"
  end

  def short_address
    "#{city},#{state}".chomp(',').reverse.chomp(',').reverse
  end

  def hour_of_operation
    "#{time_from} - #{time_to}"
  end

  def self.braintree_subscriptions(locations)
    subscription_ids = []
    st = Time.now
    location_subscriptions_map = locations.inject({}) do |memo, obj|
      subs = obj.subscriptions.map{|s| s.subscription_id}.flatten
      memo[obj.id] = subs unless subs.empty?
      subscription_ids.concat subs
      memo
    end
    return {} if subscription_ids.empty?
    subscription_ids = subscription_ids.uniq
    t = Time.now
    bt_subscriptions_raw = Braintree::Subscription.search{|s| s.ids.in(subscription_ids) }.to_a
    Rails.logger.debug("== Looking up Braintree Subscription IDS: #{subscription_ids} [Completed in #{Time.now - t}s]")
    bt_subscriptions = {}
    location_subscriptions_map.each_pair do |obj_id, sub_ids|
      bt_subscriptions[obj_id] = bt_subscriptions_raw.select{|bt_sub| sub_ids.include?(bt_sub.id)}
    end
    Rails.logger.debug("== Braintree Subscription lookup total time: #{Time.now - st}s")
    return bt_subscriptions
  end

  def self.search_location(search)
    find(:all, :conditions => ['name LIKE :search', {:search => "%#{search}%"}])
  end

  def totalpoint
    @totalpoint = 0
    return 0 if self.user_points.point.count == 0
    self.user_points.point.collect { |p| @totalpoint = @totalpoint + p.points }
    return @totalpoint
  end

  def get_prize_by_location(location_id, points, user_id)
    prize = []
    sql = "select stp.id as status_prize_id
            from share_prizes sp
            join prizes p on p.id = sp.prize_id and is_delete = 0
            join status_prizes stp on p.status_prize_id =stp.id
            where stp.location_id = #{location_id} and sp.from_user =#{user_id} and (sp.is_refunded = 0 or sp.is_refunded = 1 or sp.is_refunded = 2 )
                 and sp.share_id = 0 and stp.id =(select max(stp.id)
                              from share_prizes sp
                               join prizes p on p.id =sp.prize_id and is_delete = 0
                               join status_prizes stp on p.status_prize_id=stp.id
                              where stp.location_id = #{location_id} and sp.share_id = 0 and sp.from_user =#{user_id} and (sp.is_refunded = 0 or sp.is_refunded = 1 or sp.is_refunded = 2  )
                  )"
    share = SharePrize.find_by_sql(sql)

    sql1 = "select stp.id as status_prize_id
            from prize_redeems pr
             join prizes p on p.id = pr.prize_id and is_delete =0
            join status_prizes stp on p.status_prize_id =stp.id
            where stp.location_id = #{location_id} and pr.user_id =#{user_id} and pr.from_user =0
             and stp.id =(select max(stp.id)
                    from prize_redeems pr
                    join prizes p on p.id = pr.prize_id and is_delete =0
                    join status_prizes stp on p.status_prize_id =stp.id
                    where stp.location_id = #{location_id} and pr.user_id = #{user_id} and pr.from_user =0
          )"
    redeem_pr = PrizeRedeem.find_by_sql(sql1)
    redeem_pr = redeem_pr.concat(share).sort { |x,y| x.status_prize_id <=> y.status_prize_id}

    status_prize = StatusPrize.where("location_id =?",location_id).order("id asc").first
   #=================== END count of list prize redeem/share to get prize next

   #================= BEGIN list prize
   status_prize_id = 0
   max_status_location = StatusPrize.where("location_id =?",location_id).order("id desc").first
      unless redeem_pr.empty?
         max_arr = redeem_pr.max_by {|x| x.status_prize_id }
         arr_redeem = []
          for i in (0..redeem_pr.length-1)
             if redeem_pr[i][:status_prize_id] == max_arr.status_prize_id
                arr_redeem << redeem_pr[i]
             end
          end
          sql2 = "select p.id
                  from prizes p
                  join status_prizes stp on p.status_prize_id = stp.id
                  where stp.id = #{max_arr.status_prize_id} and stp.location_id = #{location_id} and is_delete =0 "
          prize_restaurants = Prize.find_by_sql(sql2)
          unless arr_redeem.empty?
            if prize_restaurants.count <= arr_redeem.count

              status_prize_id = max_arr.status_prize_id.to_i + 1
              check_prize = Prize.where("status_prize_id =? and is_delete = 0",status_prize_id).first
              while check_prize.nil? && status_prize_id <= max_status_location.id
                status_prize_id = status_prize_id + 1
                check_prize = Prize.where("status_prize_id =? and is_delete = 0",status_prize_id).first
              end
              sql3  = "select stp.id as status_prize_id,0 as share_prize_id,p.role as type ,p.id as prize_id,p.name,p.level as level_number,p.redeem_value ,0 as from_user,null as email,DATE_FORMAT(NOW(), '%m/%d/%Y %H:%i:%S') as date_time_current,DATE_FORMAT(CONVERT_TZ(NOW(),@@session.time_zone,'+00:00'), '%m/%d/%Y %H:%i:%S') as date_currents,null as date_redeem,null as date_time_redeem
                     from prizes p
                     join status_prizes stp on p.status_prize_id = stp.id
                    where stp.location_id =#{location_id}  and p.is_delete = 0 and stp.id = #{status_prize_id}
                    order by p.level ASC"


            else
              status_prize_id = max_arr.status_prize_id.to_i
              sql3 = "select stp.id as status_prize_id,0 as share_prize_id,p.role as type ,p.id as prize_id,p.name,p.level as level_number,p.redeem_value ,0 as from_user,null as email,DATE_FORMAT(NOW(), '%m/%d/%Y %H:%i:%S') as date_time_current,DATE_FORMAT(CONVERT_TZ(NOW(),@@session.time_zone,'+00:00'), '%m/%d/%Y %H:%i:%S') as date_currents,null as date_redeem,null as date_time_redeem
                     from prizes p
                     join status_prizes stp on p.status_prize_id = stp.id
                    where stp.location_id =#{location_id}  and p.is_delete = 0 and stp.id = #{status_prize_id}
                    order by p.level ASC"
            end
          end
          prize = Prize.find_by_sql(sql3)
      else
        unless status_prize.nil?
            status_prize_id = status_prize.id
            check_prize = Prize.where("status_prize_id =?",status_prize_id).first
            while check_prize.nil? && status_prize_id <= max_status_location.id
              status_prize_id = status_prize_id + 1
              check_prize = Prize.where("status_prize_id =? and is_delete = 0",status_prize_id).first
            end
            if points > 0
                 sql3 = "select stp.id as status_prize_id, 0 as share_prize_id,p.role as type ,p.id as prize_id,p.name,p.level as level_number,p.redeem_value ,0 as from_user,null as email,DATE_FORMAT(NOW(), '%m/%d/%Y %H:%i:%S') as date_time_current,DATE_FORMAT(CONVERT_TZ(NOW(),@@session.time_zone,'+00:00'), '%m/%d/%Y %H:%i:%S') as date_currents,null as date_redeem,null as date_time_redeem
                             from prizes p
                             join status_prizes stp on p.status_prize_id = stp.id
                             where stp.location_id =#{location_id}  and p.is_delete = 0 and stp.id = #{status_prize_id}
                             order by p.level ASC"
                 prize = Prize.find_by_sql(sql3)

           end

        end
      end
      #================END list prize
      #================BEGIN reject prize redeem
      sql4 = "SELECT p.id as prize_id
              FROM prizes p
              JOIN status_prizes stp on stp.id = p.status_prize_id
              JOIN prize_redeems pr ON p.id = pr.prize_id AND pr.from_user = 0
              WHERE p.is_delete = 0 and stp.location_id =#{location_id} and pr.user_id =#{user_id} and stp.id =#{status_prize_id}"

      reject_redeem = Prize.find_by_sql(sql4)
      #list prize redeem
      arr=[]
      reject_redeem.each do |p|
        arr << p.prize_id
      end
      prize = prize.reject{|pr| arr.include?(pr.prize_id)}

      #================END reject prize redeem
      #================BEGIN reject prize share
    sql5 = "select sp.prize_id
              from prizes p
              join status_prizes stp on p.status_prize_id = stp.id
              join share_prizes sp on sp.prize_id = p.id
              where stp.location_id = #{location_id} and sp.from_user =#{user_id} and p.is_delete =0
               and stp.id = #{status_prize_id} and (sp.is_refunded = 0 or sp.is_refunded =1 or sp.is_refunded = 2 ) and sp.share_id = 0"
    share_friend = SharePrize.find_by_sql(sql5)

    arr =[]
    unless share_friend.empty?
      share_friend.each do |i|
        arr << i.prize_id
      end
    end
    prize = prize.reject {|pr|( 0 == pr.from_user) && arr.include?(pr.prize_id)}
    #================END reject prize share
    #=================BEGIN calculator value redeem < points
     total_redeem_value = 0
     arr_prize =[]
     prize.each do |pr|
        total_redeem_value = total_redeem_value + pr[:redeem_value]
        if total_redeem_value <= points
          arr_prize << pr
        end
     end
    #=================END calculator value redeem < points
    #================BEGIN concat prize redeem
     sql6 = "SELECT stp.id as status_prize_id,pr.share_prize_id as share_prize_id,pr.from_redeem as type,
              p.id as prize_id,p.name,p.level AS level_number,p.redeem_value ,
              pr.from_user AS from_user,u.email as email,
              DATE_FORMAT(CONVERT_TZ(pr.created_at,'+00:00',pr.timezone), '%m/%d/%Y %H:%i:%S')  as date_time_redeem,
              DATE_FORMAT(NOW(), '%m/%d/%Y %H:%i:%S') as date_time_current,
              DATE_FORMAT(CONVERT_TZ(NOW(),@@session.time_zone,'+00:00'), '%m/%d/%Y %H:%i:%S') as date_currents,
              DATE_FORMAT(pr.created_at, '%m/%d/%Y %H:%i:%S')  as date_redeem
              FROM prizes p
              JOIN status_prizes stp on stp.id = p.status_prize_id
              JOIN prize_redeems pr ON p.id = pr.prize_id
              LEFT JOIN users u ON u.id = pr.from_user
              WHERE p.is_delete = 0 and stp.location_id =#{location_id} and pr.user_id =#{user_id}"
    prize_redeem = Prize.find_by_sql(sql6)

    arr_prize = arr_prize.concat(prize_redeem)

    #================END concat prize redeem

    #================BEGIN concat prize friend share
     sql7 = "SELECT stp.id as status_prize_id,sp.id as share_prize_id,sp.from_share as type,
              p.id as prize_id,p.name,p.level AS level_number,p.redeem_value ,
              sp.from_user AS from_user,u.email as email,
              null  as date_time_redeem,
              DATE_FORMAT(NOW(), '%m/%d/%Y %H:%i:%S') as date_time_current,
              DATE_FORMAT(CONVERT_TZ(NOW(),@@session.time_zone,'+00:00'), '%m/%d/%Y %H:%i:%S') as date_currents,
              null  as date_redeem
              FROM prizes p
              JOIN status_prizes stp on stp.id = p.status_prize_id
              JOIN share_prizes sp ON p.id = sp.prize_id
              Join users u on u.id = sp.from_user
              WHERE p.is_delete = 0 and stp.location_id = #{location_id} and sp.to_user =#{user_id} and is_redeem=0  and (sp.is_refunded = 0 or sp.is_refunded = 1)"
    prize_friend_share = Prize.find_by_sql(sql7)
    arr_prize = arr_prize.concat(prize_friend_share)
    #================END concat prize friend share
    #================BEGIN disappeared prize after redeem over 3 hours
    arr_prize_list = []
    unless arr_prize.empty?
      arr_prize.each do |prize_list|
        if prize_list[:date_redeem].nil?
           arr_prize_list << prize_list
        else
          date_current = Time.strptime(prize_list[:date_currents], '%m/%d/%Y %H:%M:%S').to_s
          date_redeem = Time.strptime(prize_list[:date_redeem], '%m/%d/%Y %H:%M:%S').to_s
          date_time = (Time.parse(date_current) - Time.parse(date_redeem))/3600

          if date_time <= 3
            arr_prize_list << prize_list
          else
            unless prize_list.share_prize_id.blank?
              share_prize_limit = SharePrize.find_by_id(prize_list.share_prize_id)
              unless share_prize_limit.nil?
                share_prize_limit.update_attributes(:is_limited => 1)
              end
            end
          end
        end
      end
    end

    #================END disappeared prize after redeem over 3 hours

    return arr_prize_list.sort { |x,y| x.level_number <=> y.level_number}

  end

  def chain_logo
    logo.fullpath if logo
  end

  def ios_logo
      if self.logo_url.nil? && self.logo.present?
        return Cloudinary::Utils.cloudinary_url(self.logo.path("png"), {transformation: [
          {width: 180, height: 180, radius: "max", crop: 'fit'}]})
      end
      self.logo_url
  end

  def android_logo
      if self.logo_url.nil? && self.logo.present?
        return Cloudinary::Utils.cloudinary_url(self.logo.path("png"), {transformation: [
          {width: 180, height: 180, radius: "max", crop: 'fit'},
          {border: { width: 2, color: "#e4e3e2" } }]})
      end
      Cloudinary::Utils.cloudinary_url(logo_url, {transformation: [
          {width: 180, height: 180, radius: "max", crop: 'fit'},
          {border: { width: 2, color: "#e4e3e2" } }]})
      android_url = ""
      if(self.logo_url.present? && self.logo.present?)
        self.logo_url.split("/").each do |x|
          if(x === ('v'+self.logo.version))
            android_url = android_url + "bo_2px_solid_rgb:e4e3e2/"
          end
          android_url += x + "/"
        end
        return android_url
      end
      return nil;
  end

  def current_rating
    current_rating = 0
    return 0 if self.location_comments.ratings.count == 0
    self.location_comments.ratings.collect{|c| current_rating = current_rating + c.rating}
    current_rating = current_rating.to_f/self.location_comments.ratings.count
    current_rating.round(1)
  end

  #set status for dinner via total point
  def dinner_status
    dinner_status = DinnerType.where("location_id = ? ",self.id).order("dinner_types.point")
    if dinner_status.count != 0
      if dinner_status.count == 1
        if self.total >= dinner_status[0].point
          return dinner_status[0].types
        else
          return nil
        end
      else
        if dinner_status.count == 2
          if self.total >= dinner_status[1].point
            return dinner_status[1].types
          elsif self.total >= dinner_status[0].point
            return dinner_status[0].types
          end
        else
          if self.total >= dinner_status[2].point
            return dinner_status[2].types
          elsif self.total >= dinner_status[1].point
            return dinner_status[1].types
          elsif self.total >= dinner_status[0].point
            return dinner_status[0].types
          end
        end
      end
    else
      return nil
    end
  end

  def ratings_count
    self.location_comments.ratings.count
  end

  def comments_count
    self.location_comments.comments.count
  end

  #Get unread message for each restaurant
  def get_unread_message_restaurant
    unread = Location.find_by_sql("select n.restaurant, count(*) as total
              from notifications n
              where n.status=0 and n.restaurant='#{self.id}' and n.to_user='#{self.useremail}'
              group by n.restaurant")

    if unread.blank?
      return 0
    else
      return unread.first.total
    end
  end

  def get_favourite_restaurant
    @fav = Location.find_by_sql("SELECT count(*) as total
          FROM items i JOIN item_favourites f ON i.id = f.item_id JOIN locations l ON i.location_id = l.id
          WHERE l.id ='#{self.id}' and f.user_id='#{self.user_id}'")
    return @fav.first.total
  end

  def get_total_favourites_global
    chain_name = self.chain_name.gsub("'","''")
    total=0
    sql ="SELECT COUNT (f.id) as total
          FROM locations l
          JOIN items i ON i.location_id = l.id
          JOIN build_menus b ON b.item_id = i.id
          JOIN menus m ON m.id = b.menu_id
          JOIN item_favourites f ON f.build_menu_id = b.id
          WHERE m.publish_status=2 AND f.favourite =1 AND f.user_id=#{self.user_id} AND l.chain_name='#{chain_name}' AND b.active = '1'"
    fav = Location.find_by_sql(sql).first
    unless fav.nil?
      total +=fav.total
    end
    sql2="SELECT COUNT (sf.id) as total
          FROM locations l
          JOIN servers s ON s.location_id = l.id
          JOIN server_favourites sf ON sf.server_id = s.id AND sf.favourite=1
          WHERE sf.user_id=#{self.user_id} AND l.chain_name='#{chain_name}'"
    fav2 = Location.find_by_sql(sql2).first
    unless fav2.nil?
      total +=fav2.total
    end
    return total
  end


  #############################
  ###  CLASS METHODS
  #############################

  def self.active_locations
    where(active: true)
  end

  def self.all_nearby_including_unregistered(latitude, longitude, radius_in_miles = nil, restaurant_name = nil)
    radius_in_miles = DEFAULT_SEARCH_RADIUS_IN_MILES if radius_in_miles.blank?
    matching_locations = near_coordinates_with_conditions(latitude, longitude, radius_in_miles, restaurant_name)
    includes = [:recent_checkins, :images, :logo, :item_comments, :subscriptions, :location_favourites, :hour_operations]
    Location.includes(includes).find(matching_locations.map(&:id))
  end

  def self.near_coordinates(latitude, longitude, radius_in_miles)
    Location
      .joins(:menus)
      .where(menus: {publish_status: 2})
      .near([latitude, longitude], radius_in_miles, order: :distance)
      .active_locations
      #.to_a
  end

  def self.near_coordinates_with_ids(latitude, longitude, radius_in_miles = nil, restaurant_ids = nil)
    radius_in_miles = DEFAULT_SEARCH_RADIUS_IN_MILES if radius_in_miles.blank?
    query = near_coordinates(latitude, longitude, radius_in_miles)

    if restaurant_ids.present?
      query = query.where('locations.id IN (?)', restaurant_ids)
    end

    return query
  end

  def self.near_coordinates_with_conditions(latitude, longitude, radius_in_miles = nil, keyword = nil)
    radius_in_miles = DEFAULT_SEARCH_RADIUS_IN_MILES if radius_in_miles.blank?
    query = near_coordinates(latitude, longitude, radius_in_miles)

    if keyword.present?
      split_string = keyword.split(',').map(&:strip)
      name_or_cuisine_sql = '(name LIKE ? OR primary_cuisine LIKE ? OR secondary_cuisine LIKE ? OR (state LIKE ? AND city LIKE ?) OR city LIKE ?)'
      value = "%#{keyword}%"
      query = query.where(name_or_cuisine_sql, value, value, value, split_string[1], split_string[0], split_string[0])
    end

    return query
  end










  #########  CLASS METHODS IN NEED OF REFACTORING:  ##############


  def self.create_custome_location(location_id, user_new)
    location = self.find(location_id)
    new_location = location.amoeba_dup
    new_location.owner_id = user_new.id
    new_location.save!
    new_location
  end

  def self.get_orders_chain(user_id, chain_name)
    sql = "select  l.id, l.name, l.address, l.city, l.state, l.country, l.zip, o.paid_date, l.logo_id,
          (case when l.chain_name = '' then l.name else l.chain_name end ) as chain_name,
          count(case o.read when 0 then 1 else null end) as number
          from locations l  left join orders o on o.location_id = l.id
          where o.user_id = #{user_id}  and o.is_cancel = 0 and is_paid = 1 and l.chain_name = '#{chain_name}'
          group by l.id"
    return self.find_by_sql(sql)
  end

  def self.get_orders_global(user_id)
    sql = "select l.id, l.logo_id, (case when l.chain_name = '' then l.name else l.chain_name end ) as chain_name,
          count(case o.read when 0 then 1 else null end) as number
          from locations l  left join orders o on o.location_id = l.id
          where o.user_id = #{user_id}  and o.is_cancel = 0 and is_paid = 1
          group by l.chain_name"
    return self.find_by_sql(sql)
  end

  def self.get_categories(user_id, location_id)
    sql = "SELECT distinct c.*, count(i.id) as number_item, (b.created_at) as date,
          IFNULL(max(f.favourite),0) as is_favourite, IFNULL(max(nt.nexttime),0) as is_nexttime, b.category_sequence
          FROM locations l
          INNER JOIN items i ON   l.id = i.location_id
          INNER JOIN build_menus b ON i.id = b.item_id
          LEFT JOIN item_nexttimes nt on nt.build_menu_id = b.id and  nt.user_id=#{user_id}
          LEFT JOIN item_favourites f on f.build_menu_id = b.id and  f.user_id=#{user_id}
          INNER JOIN menus m ON b.menu_id = m.id
          INNER JOIN categories c ON c.id = b.category_id
          WHERE m.publish_status = '2' AND i.location_id = #{location_id} AND b.active = 1
          GROUP BY c. name
          order by b.category_sequence"
    return self.find_by_sql(sql)
  end

  #Get global message
  def self.get_global_message(email, location_id)
    sql="SELECT l.id, l.chain_name,p.to_user, l.logo_id, DATE_FORMAT(max(p.updated_at), '%m/%d/%Y') as most_recent,
        COUNT(CASE WHEN p.status=0 THEN p.location_id ELSE null END) as unread
        FROM locations l
        JOIN notifications p ON p.location_id=l.id AND p.alert_type !='Publish Menu Notification'
        WHERE p.to_user='#{email}' AND p.is_show=1"
    if location_id > 0
        sql << " AND l.id=#{location_id} GROUP BY l.chain_name, l.id"
    else
        sql << " GROUP BY l.chain_name, l.id"
    end

    return self.find_by_sql(sql)
  end

  #Get message by chain
  def self.get_message_by_chain(chain_name, email)
    sql="SELECT l.id, l.name, l.address, l.city, l.state, l.zip, l.logo_id,
          COUNT(CASE WHEN n.status=0 THEN n.location_id ELSE null END) as unread
          FROM locations l
          LEFT JOIN notifications n ON l.id = n.location_id AND n.alert_type !='Publish Menu Notification'
          AND n.is_show=1
          WHERE l.chain_name='#{chain_name}' AND n.to_user='#{email}'
          GROUP BY l.id"
    return self.find_by_sql(sql)
  end

  #Get global points
  def self.my_global_point(user_id)
    sql="SELECT l.id, (CASE WHEN l.chain_name='' THEN l.name ELSE l.chain_name END )AS chain_name,
        sum( CASE WHEN u.is_give = 1 THEN u.points ELSE u.points*(-1) END) as total_point
        FROM locations l
        JOIN user_points u ON l.id = u.location_id AND u.status=1
        WHERE u.user_id=#{user_id}
        GROUP BY l.chain_name"
    return self.find_by_sql(sql)
  end

  #Get my points by chain
  def self.my_point_by_chain(chain_name, user_id, location_id)
    #logger.info ""
    sql="SELECT l.id, l.name, l.address, l.city, l.state, l.country, l.zip, l.logo_id,
          DATE_FORMAT(max(u.updated_at), '%m/%d/%Y') as most_recent, u.user_id,
          SUM( CASE WHEN u.is_give = 1 THEN u.points ELSE u.points*(-1) END) as total
          FROM locations l
          JOIN user_points u ON u.location_id = l.id AND u.user_id=#{user_id} AND u.status=1"

    sql2 = "SELECT l.id, l.name, l.address, l.city, l.state, l.country, l.zip, sp.to_user as user_id,
           DATE_FORMAT(max(sp.updated_at), '%m/%d/%Y') as most_recent, sp.to_user, 0 as total
           FROM locations l
           join status_prizes stp on stp.location_id = l.id
           join prizes p on p.status_prize_id = stp.id and is_delete =0
           JOIN share_prizes sp On sp.prize_id = p.id
           WHERE  sp.to_user = #{user_id} AND sp.status=1 and (sp.is_refunded = 0 or sp.is_refunded = 1) and sp.is_limited = 0"

    if chain_name.to_s == 'null'
        if location_id > 0
            sql << " WHERE l.id = #{location_id} GROUP BY l.id"
            sql2 << " And l.id = #{location_id} GROUP BY l.id"
        else
            sql << " GROUP BY l.id"
            sql2 << " GROUP BY l.id"
        end
    else
        if location_id > 0
            sql << " WHERE l.id=#{location_id} AND l.chain_name = '#{chain_name}' GROUP BY l.id"
            sql2 << " AND l.id=#{location_id} AND l.chain_name = '#{chain_name}' GROUP BY l.id"
        else
            sql << " WHERE l.chain_name = '#{chain_name}' GROUP BY l.id"
            sql2 << " AND l.chain_name = '#{chain_name}' GROUP BY l.id"
        end
    end

    location = self.find_by_sql(sql)
    location2 = self.find_by_sql(sql2)
    arr = []
    location.each do |i|
      arr << i.id
    end
    loc = location2.reject{|l| arr.include?(l.id)}
    return location.concat(loc)
  end

  def self.get_location_global(user_id)
    sql="SELECT l.id, l.name, l.address, l.city, l.state, l.country, l.zip,
          DATE_FORMAT(max(u.updated_at), '%m/%d/%Y') as most_recent, u.user_id,
          SUM( CASE WHEN u.is_give = 1 THEN u.points ELSE u.points*(-1) END) as total
          FROM locations l
          JOIN user_points u ON u.location_id = l.id AND u.user_id=#{user_id} AND u.status=1
          GROUP BY l.id"
    location = self.find_by_sql(sql)
    sql2 = "SELECT l.id, l.name, l.address, l.city, l.state, l.country, l.zip, sp.to_user as user_id,
           DATE_FORMAT(max(sp.updated_at), '%m/%d/%Y') as most_recent, sp.to_user, 0 as total
           FROM locations l
           join status_prizes stp on stp.location_id = l.id
           join prizes p on p.status_prize_id = stp.id and is_delete =0
           JOIN share_prizes sp On sp.prize_id = p.id
           WHERE  sp.to_user = #{user_id} AND sp.status=1 and (sp.is_refunded = 0 or sp.is_refunded = 1) and sp.is_limited = 0
           GROUP BY l.id"
    location2 = self.find_by_sql(sql2)
    arr = []
    location.each do |i|
      arr << i.id
    end
    loc = location2.reject{|l| arr.include?(l.id)}
    return location.concat(loc)
  end

  #Get favourite global
  def self.favourite_global(user_id)
    sql ="SELECT l.id, l.chain_name, l.logo_id,
          (case when count(lf.id) != 0 AND count(f.id) = 0 then 0 else count(f.id) end )as total_favourites, 0 as favourite_type
          FROM locations l
          LEFT JOIN location_favourites lf ON lf.location_id = l.id AND lf.favourite = 1 and lf.user_id = #{user_id}
          LEFT JOIN items i ON i.location_id = l.id
          LEFT JOIN build_menus b ON b.item_id = i.id
          LEFT JOIN menus m ON m.id = b.menu_id
          LEFT JOIN item_favourites f ON f.build_menu_id = b.id AND f.favourite =1 and f.user_id = #{user_id} AND m.publish_status = 2
          WHERE ( lf.user_id = #{user_id} or  f.user_id = #{user_id} )
          GROUP BY l.chain_name"
    @fav = self.find_by_sql(sql)

    sql2 = "SELECT l.id, l.chain_name,
           (case when count(lf.id) !=  0 AND count(sf.id) = 0 then 0 else count(sf.id) end) as total_favourites, 1 as favourite_type
           FROM locations l
           LEFT JOIN location_favourites lf ON lf.location_id = l.id AND lf.favourite = 1 and lf.user_id = #{user_id}
           JOIN servers s ON s.location_id = l.id
           LEFT JOIN server_favourites sf ON sf.server_id = s.id AND sf.favourite = 1 and sf.user_id = #{user_id}
           WHERE (sf.user_id = #{user_id} or lf.user_id = #{user_id} )
           GROUP BY l.chain_name"
    @server_fav =self.find_by_sql(sql2)
    return @fav.concat(@server_fav)
  end

  #Get favourite by chain
  def self.favourite_by_chain(chain_name, user_id)
    sql =  "SELECT l.id,l.name,l.address,l.city, l.state, l.zip, l.logo_id,
           DATE_FORMAT((case when count(f.id) != 0 then max(f.updated_at) else max(lf.updated_at) end), '%m/%d/%Y' )as most_recent,
           (case when count(lf.id) != 0 AND count(f.id) = 0 then 0 else count(f.id) end)as total_favourites
           FROM locations l
           LEFT JOIN location_favourites lf ON lf.location_id = l.id AND lf.favourite = 1 and lf.user_id = #{user_id}
           LEFT JOIN items i ON i.location_id = l.id
           LEFT JOIN build_menus b ON b.item_id = i.id
           LEFT JOIN menus m ON m.id = b.menu_id
           LEFT JOIN item_favourites f ON f.build_menu_id = b.id AND f.favourite = 1 and f.user_id = #{user_id} AND m.publish_status = 2
           WHERE  ( lf.user_id = #{user_id} or f.user_id = #{user_id}) and l.chain_name = '#{chain_name}'
           GROUP BY l.id"
    @fav = self.find_by_sql(sql)

    sql2 = "SELECT l.id,l.name,l.address,l.city, l.state, l.zip,
           DATE_FORMAT((case when count(sf.id) != 0 then max(sf.updated_at) else max(lf.updated_at) end), '%m/%d/%Y' )as most_recent,
           (case when count(lf.id) !=  0 AND count(sf.id) =  0 then 0 else count(sf.id) end) as total_favourites
           FROM locations l
           left JOIN location_favourites lf ON lf.location_id = l.id AND lf.favourite  = 1 and lf.user_id= #{user_id}
           JOIN servers s ON s.location_id = l.id
           LEFT JOIN server_favourites sf ON sf.server_id = s.id AND sf.favourite = 1 and sf.user_id = #{user_id}
           WHERE (sf.user_id = #{user_id} or lf.user_id = #{user_id} ) AND l.chain_name='#{chain_name}'
           GROUP BY l.id"
    @server_fav = self.find_by_sql(sql2)
    return @fav = @fav.concat(@server_fav)
  end

  def self.build_statement(menu_type, item_rating_max, item_rating_min, point_offered_max, point_offered_min, item_price_max,\
    item_price_min, item_type, server_rating_max, server_rating_min, restaurant_rating_max, restaurant_rating_min)
    sql = ""
    where_sql = []
    join = ""
    join_sql = "select distinct l.id from locations l left join menus m on l.id = m.location_id and m.publish_status = 2 left join build_menus bm on bm.menu_id = m.id and bm.active = 1 "

    if item_rating_max == 13 && item_rating_min == 1 && item_price_max == 100 && item_price_min == 0 && point_offered_max == 500\
      && point_offered_min == 0 && item_type.blank? && menu_type.blank? && server_rating_max == 13 && server_rating_min == 1\
      && restaurant_rating_max == 13 && restaurant_rating_min == 1
        join_sql["and m.publish_status = 2"] = ''
        join_sql["and bm.active = 1 "] = ''
    end

    if !menu_type.blank?
      join_sql = join_sql + " join menu_types mt on m.menu_type_id = mt.id "
      where_sql << " mt.id in (#{menu_type}) "
    end

    if item_rating_max != 13 || item_rating_min != 1 || item_price_max != 100 || item_price_min != 0 || point_offered_max != 500 || point_offered_min !=0
      join_sql = join_sql + " join items i on i.id = bm.item_id "
      if item_rating_max != 13 || item_rating_min != 1
        where_sql << " i.rating >= (#{item_rating_min} - 0.5) and  i.rating < (#{item_rating_max} + 0.5) "
      end
      if item_price_max != 100 || item_price_min != 0
        where_sql << " IFNULL(i.price,0) between #{item_price_min} and #{item_price_max} "
      end
      if point_offered_max != 500 || point_offered_min != 0
        where_sql << " IFNULL(i.reward_points,0) between #{point_offered_min} and #{point_offered_max} "
      end
    end

    if join_sql.match(/items/)
      if !item_type.blank?
        join_sql = join_sql + " join item_types it on i.item_type_id = it.id "
        where_sql << " it.id in (#{item_type}) "
      end
    else
      if !item_type.blank?
        join_sql = join_sql + " join items i on i.id = bm.item_id join item_types it on i.item_type_id = it.id "
        where_sql << " it.id in (#{item_type}) "
      end
    end

    if server_rating_max.to_i != 13 || server_rating_min.to_i != 1
      join_sql = join_sql + " join servers s on l.id = s.location_id "
      where_sql << " s.rating >= (#{server_rating_min} - 0.5) and s.rating < (#{server_rating_max} + 0.5) "
    end

    if restaurant_rating_max != 13 || restaurant_rating_min != 1
      where_sql << " l.rating >= (#{restaurant_rating_min} - 0.5) and l.rating < (#{restaurant_rating_max} + 0.5) "
    end

    where_sql.each do |i|
      join = join + '*' + i
    end

    if !join.blank?
      join["*"] = ' where '
      join = join.split("*").join(" and ")
      sql = join_sql + join
    else
      sql = join_sql
    end
    return sql
  end

  def self.split_conditions(keyword)
    condition_obj = {}
    no_conditions = []
    conditions = []
    arr_no = []
    arr_have =[]
    keyword = keyword.split(",")
    keyword.each do |i|
      arr_no << i if i.match(/no /)
      arr_have << i if !i.match(/no /)
    end
    arr_no.each do |j|
      j['no '] =''
    end
    arr_no.each do |k|
      no_conditions << k
    end
    arr_have.each do |l|
      conditions << l
    end
    condition_obj['conditions'] = conditions
    condition_obj['no_conditions'] = no_conditions
    return condition_obj
  end

  def self.find_by_keyword_advance_search(conditions, no_conditions)
    # find locations have items or item keys or item ingredients or item description
    # no_condition : above criteria don't contain list of elements in no_condition array
    # condition : above criteria contain list of elements in condition array
    condition = self.have_condition(conditions)
    no_condition = self.no_condition(no_conditions)
    sql = "SELECT l.id FROM locations l
          JOIN items i on l.id = i.location_id
          JOIN build_menus bm on bm.item_id = i.id and bm.active = 1
          JOIN menus m on m.id = bm.menu_id and m.publish_status = 2
          LEFT JOIN item_item_keys iik on iik.item_id = i.id
          LEFT JOIN item_keys ik on ik.id = iik.item_key_id
          WHERE
          (MATCH (ik.name) AGAINST (? IN BOOLEAN MODE)
            OR MATCH (i.name) AGAINST (? IN BOOLEAN MODE)
            OR MATCH (i.ingredients) AGAINST (? IN BOOLEAN MODE)
            OR MATCH (i.description) AGAINST (? IN BOOLEAN MODE)
          )
          AND (NOT MATCH (ik.name) AGAINST (? IN BOOLEAN MODE))
          AND (NOT MATCH (i.name) AGAINST (? IN BOOLEAN MODE))
          AND (NOT MATCH (i.ingredients) AGAINST (? IN BOOLEAN MODE))
          AND (NOT MATCH (i.description) AGAINST (? IN BOOLEAN MODE))"
    completed_sql = ActiveRecord::Base.send(:sanitize_sql_array,\
      [sql, condition, condition, condition, condition, no_condition, no_condition, no_condition, no_condition])
    return self.find_by_sql(completed_sql)
  end

  def self.no_condition(no_conditions)
    return no_conditions.map { |no| no + '* '}.join
  end

  def self.have_condition(conditions)
    return conditions.map { |c| c + '* '}.join
  end

  def self.compare_address(byte_restaurant, ggp_restaurant, search_type)
    gg_location = ggp_restaurant.vicinity
    if search_type.downcase == "location"
      gg_location = ggp_restaurant.formatted_address
    end
    gg_address = ""
    mmn_address = ""
    gg_full_address = ""
    gg_full_address = gg_location if !gg_location.nil?
    gg_full_address = gg_full_address.split(",")
    gg_full_address.each do |s|
      s.strip!
    end
    gg_address = gg_full_address.first.mb_chars.downcase.strip.to_s if !gg_full_address[0].nil?
    ggp_address = gg_address.split(" ")[0] if !gg_address.blank?
    mmn_address = byte_restaurant.address.split(" ")[0] if !byte_restaurant.address.blank?
    if ggp_address.to_s == mmn_address.to_s
      return true
    end
    return false
  end

  def self.edit_keyword(keyword) # We should probably get rid of this nonsense
    keyword = keyword.split(" ")
    keyword.each do  |i|
      i.strip
    end
    return keyword.map { |k| k + '* '}.join.chop
  end

  def self.get_restaurants_by_special_message(radius, lat, lng)
    string = ''
    location_ids = []
    item_sql = "SELECT DISTINCT i.id, i.name, i.price, bm.menu_id, bm.category_id, i.location_id,i.special_message from items i
                JOIN build_menus bm on bm.item_id = i.id and bm.active = 1
                JOIN menus m on m.id = bm.menu_id and m.publish_status = 2
                WHERE i.special_message != ? and i.special_message is not null"
    item_completed_sql = ActiveRecord::Base.send(:sanitize_sql_array, [item_sql, string])
    items = Item.find_by_sql(item_completed_sql)
    items.each do |i|
      location_ids << i.location_id
    end
    location_ids = location_ids.uniq
    locations = near_coordinates(lat, lng, radius, location_ids)
    locations.each do |l|
      l[:menu_items] = []
      items.each do |i|
        if i.location_id == l.id
          l[:menu_items] << i
        end
      end
      l[:logo] = l.logo
    end
    return locations
  end
  # NEW NORMAL SEARCH -- End

  # Older Normal Search -- BEGIN
  def self.get_mymenu_restaurant(lat, lng, keyword, radius, city, state)
    keyword = keyword.strip if !keyword.blank?
    common_sql = "SELECT DISTINCT l.id FROM locations l
                        LEFT JOIN items i on l.id = i.location_id
                        LEFT JOIN item_item_keys iik on iik.item_id = i.id
                        LEFT JOIN item_keys ik on ik.id = iik.item_key_id
                        WHERE (MATCH (l.name) AGAINST (? IN BOOLEAN MODE)
                          OR MATCH (i.name) AGAINST (? IN BOOLEAN MODE)
                          OR MATCH (i.ingredients) AGAINST (? IN BOOLEAN MODE)
                          OR MATCH (i.description) AGAINST (? IN BOOLEAN MODE)
                          OR MATCH (ik.description) AGAINST (? IN BOOLEAN MODE))"
    sql = ""
    if city.nil? && !keyword.blank?
      sql = ActiveRecord::Base.send(:sanitize_sql_array, [common_sql, keyword, keyword, keyword, keyword, keyword])
    elsif !city.nil? && !keyword.blank?
      temp_sql = common_sql + " AND l.city = ?"
      if !state.nil? && !state.blank?
        temp_sql = temp_sql + " AND l.state = '#{state}'"
      end
      sql = ActiveRecord::Base.send(:sanitize_sql_array, [temp_sql, keyword, keyword, keyword, keyword, keyword, city.strip])
    else
      temp_sql_1 = "SELECT DISTINCT id FROM locations WHERE city = ?"
      if !state.nil? && !state.blank?
        temp_sql_1 = temp_sql_1 + " AND state = '#{state}'"
      end
      sql = ActiveRecord::Base.send(:sanitize_sql_array, [temp_sql_1, city.strip])
    end
    restaurants = Location.find_by_sql(sql)
    return self.near_coordinates(lat, lng, radius, restaurants)
  end

  def self.combine_restaurant(lat, lng, byte_restaurants, ggp_restaurants)
    return byte_restaurants if ggp_restaurants.empty? || ggp_restaurants.nil?
    results = []
    if !byte_restaurants.nil? || byte_restaurants.empty?
      byte_restaurants.each do |m|
        ggp_restaurants.each do |g|
          g.cid = 0
          g.street_number = nil
        end
        ggp_restaurants.delete_if do |g|
          self.compare_address(m, g, '') == true &&  Geocoder::Calculations.distance_between([m.lat, m.long], [g.lat, g.lng]).to_f < 0.02
        end
      end
      ggp_restaurants.delete_if do |gg|
        Geocoder::Calculations.distance_between([lat, lng], [gg.lat, gg.lng]).to_f > DEFAULT_SEARCH_RADIUS_IN_MILES
      end
      results = byte_restaurants + (ggp_restaurants)
    else
      ggp_restaurants.each do |g|
          g.cid = 0
          g.street_number = nil
      end
      ggp_restaurants.delete_if do |gg|
        Geocoder::Calculations.distance_between([lat, lng], [gg.lat, gg.lng]).to_f > DEFAULT_SEARCH_RADIUS_IN_MILES
      end
      results = ggp_restaurants
    end
    return results
  end
# Older Normal Search -- END

  def self.create_custome_location(location_id, user_new)
    location = self.find(location_id)
    new_location = location.amoeba_dup
    new_location.owner_id = user_new.id
    new_location.save!
    new_location
  end

  def self.get_location_name_and_email(location_id)
    sql = "SELECT  l.name, u.email,l.timezone from locations l
            join users u on l.rsr_manager = u.id
            where l.id = #{location_id}"
    return self.find_by_sql(sql).first
  end

  def get_next_prize_location(location_id,points,user_id)
    results = []
    current_prizes = Prize.get_unlocked_prizes_by_location(location_id, points, user_id)

    current_prizes = current_prizes.reject{|p| p.type != "owner"}
    share_sql = "SELECT
                    p.id as prize_id, p.level as level_number, sp.id as status_prize_id
                FROM
                    prizes p
                        JOIN
                    share_prizes shp ON p.id = shp.prize_id
                        JOIN
                    status_prizes sp ON sp.id = p.status_prize_id
                        JOIN
                    locations l ON l.id = sp.location_id
                WHERE
                    shp.from_user = ? AND shp.share_id = 0 AND l.id = ? AND p.is_delete = 0 AND p.status_prize_id IS NOT NULL
                ORDER BY p.status_prize_id"
    shared_sql_completed = ActiveRecord::Base.send(:sanitize_sql_array, [share_sql, user_id, location_id])
    shared_prizes = Prize.find_by_sql(shared_sql_completed)

    order_sql = "SELECT
                    p.id as prize_id, p.level as level_number, sp.id as status_prize_id
                FROM
                    order_items oi
                        JOIN
                    orders o ON o.id = oi.order_id AND o.is_paid = 1
                        JOIN
                    prizes p ON p.id = oi.prize_id AND p.is_delete = 0
                        JOIN
                    status_prizes sp ON p.status_prize_id = sp.id
                WHERE
                    o.user_id = ? AND sp.location_id = ? AND oi.share_prize_id = 0 AND p.is_delete = 0
                ORDER BY p.status_prize_id"
    order_sql_completed = ActiveRecord::Base.send(:sanitize_sql_array, [order_sql, user_id, location_id])
    ordered_prizes = Prize.find_by_sql(order_sql_completed)

    current_prizes = current_prizes | shared_prizes | ordered_prizes

    max_prize = current_prizes.sort_by { |p| [p.status_prize_id, p.level_number]}.last
    values = "prizes.name as name_next_level, prizes.redeem_value as point_next_level, #{location_id} as location_id, #{user_id} as user_id"

    # if user don't have any prize in current prize list. the next prize is the min prize level of the first status of restaurant
    # in case current prize list contains a prize, shoul be based on that prize to determine the next prize
    if !max_prize.nil?
      max_restaurant_prize = Prize.joins(:status_prize)\
        .where('status_prizes.location_id = ? and prizes.is_delete = 0', location_id)\
        .order('status_prizes.id, prizes.level')\
        .select(values + ', prizes.id').last

      # if user unlocked the max prize level of restaurant, then current status of them is one.
      if max_prize.prize_id == max_restaurant_prize.id
        result = max_restaurant_prize
        result.name_next_level = ""
        result.point_next_level = 0
        results << result
        return results
      else
        prizes = Prize.joins(:status_prize)\
          .where('prizes.status_prize_id = ? and prizes.is_delete = 0 and prizes.level > ?', max_prize.status_prize_id, max_prize.level_number)\
          .select(values)\
          .order("level")
        status = StatusPrize.where('location_id = ? and id > ?', location_id, max_prize.status_prize_id).first

        if prizes.empty? || prizes.nil?
          unless status.nil?
            next_prizes = Prize.joins(:status_prize)\
              .where('prizes.status_prize_id = ? and prizes.is_delete = 0', status.id)\
              .select(values)\
              .order('prizes.level')
          end
          results << next_prizes.first unless next_prizes.empty?
        else
          results << prizes.first
        end
      end
    else
      redeemed_prizes = Prize.get_redeemed_prizes(location_id, user_id)
      shared_prizes = Prize.get_shared_prizes(location_id, user_id)
      ordered_prizes = Prize.get_ordered_prizes(location_id, user_id)
      used_prizes = redeemed_prizes | shared_prizes | ordered_prizes
      max_used_prize = used_prizes.sort_by{|p| [p.status_prize_id, p.level]}.last
      if max_used_prize.nil?
        status = StatusPrize.where('location_id = ?', location_id).order("id").first
        unless status.nil?
          prizes = Prize.joins(:status_prize)\
           .where('prizes.status_prize_id = ? and prizes.is_delete = 0', status.id)\
           .select(values)\
           .order('prizes.level')
          results << prizes.first unless prizes.empty?
        end
      else
        prizes = Prize.joins(:status_prize)\
           .where('prizes.status_prize_id = ? and prizes.is_delete = 0', max_used_prize.status_prize_id)\
           .select(values)\
           .order('prizes.level')

        logger.info "@@@@@ : #{prizes.length}"
        if used_prizes.length >= prizes.length
          next_prizes = Prize.joins(:status_prize)\
           .where('prizes.status_prize_id = ? and prizes.is_delete = 0', max_used_prize.status_prize_id + 1)\
           .select(values)\
           .order('prizes.level')
           results << next_prizes.first unless next_prizes.empty?
        else
          next_prizes = Prize.joins(:status_prize)\
           .where('prizes.status_prize_id = ? and prizes.is_delete = 0 and prizes.level = ?', max_used_prize.status_prize_id, max_used_prize.level + 1)\
           .select(values)\
           .order('prizes.level')
           results << next_prizes.first unless next_prizes.empty?
        end
      end
    end
    return results
  end

  #check location time current is open or close
  def check_status_location
    current_day_of_week = DateTime.now.in_time_zone(timezone).strftime("%A")
    day_of_week = convert_day_of_week(current_day_of_week)
    hour_operations.select{|h| h.day == day_of_week}.any?{|h| h.is_open?(timezone)}
  end

  def get_hour_operation
     hour_operations = []
     hour_operations1 = []
     group_hour = HourOperation.where("location_id = ? ", self.id).select('group_hour').uniq.order("group_hour ASC")
    unless group_hour.empty?
      for i in (0..group_hour.length - 1)
          hour_operations = HourOperation.where("location_id = ? and group_hour =? and day < ? ", self.id,group_hour[i].group_hour,9).order("day ASC")
          str = ""
          arr_day_of_week = []
          hour_operations.each do |horp|
              arr_day_of_week << horp.day
          end
          for j in (0..hour_operations.length - 1)
            if check_number_consecutive(arr_day_of_week)
                if hour_operations.length == 1
                   str = convert_day_of_week(hour_operations[0][:day])
                else
                   str = convert_day_of_week(hour_operations[0][:day]) + "-" + convert_day_of_week(hour_operations[hour_operations.length - 1][:day])
                end
            else
                   str.gsub!(/$/," "+ convert_day_of_week(hour_operations[j][:day]))
            end
            hour_operations[0][:day_of_week] = str.strip.tr(' ', ',')
            hour_operations[0][:time_open]  =   hour_operations[0][:time_open]
            hour_operations[0][:time_close] =  hour_operations[0][:time_close]
            if j <  hour_operations.length - 1
             hour_operations[j+1][:is_delete] = 1
            end
          end
          hour_operations.delete_if do |a|
            a[:is_delete] == 1
          end
          hour_operations1 <<  hour_operations[0]
      end
    end
    return hour_operations1
  end

  def hours_of_operation_for_api
    hours = hour_operations.select{|ho| ho.day < 9}.sort_by{|ho| ho.day}
    hours = hours.sort_by{|h| [h.day, Time.parse(h[:time_open]).strftime("%H:%M")]}

    for i in (hours.length-1).downto(0)
      temp = hours[i]
      temp_open = Time.parse(temp[:time_open]).strftime("%H:%M")
      temp_close = Time.parse(temp[:time_close]).strftime("%H:%M")
      for j in (i-1).downto(0) # combines overlapping periods of time?
        if temp[:day] == hours[j][:day]
          j_close = Time.parse(hours[j][:time_close]).strftime("%H:%M")
          if temp_open <= j_close
            if temp_close <= j_close
              temp[:day] = nil
            else
              hours[j][:time_close] = temp[:time_close]
              temp[:day] = nil
            end
          end
        end
      end
    end
    hours.delete_if do |h|
      h[:day].nil?
    end
    return hours.sort_by{|h| [h.day, Time.parse(h[:time_open]).strftime("%H:%M")]}
  end

  def convert_day_of_week(param)
    dates = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    if param.is_a? String
      return dates.index(param) + 2
    else
      return dates[param - 2]
    end
  end

  def check_number_consecutive(arr)
    check = false
    for i in(0..arr.length-1)
      if arr.length == 1
         check = true
      else
        if i < arr.length - 1
          if arr[i] == (arr[i+1].to_i - 1)
            check = true
          else
            check = false
            break
          end
        end
      end
    end
    return check
  end

  def copy_shared_menu(menu)
    dup_menu = menu.amoeba_dup
    dup_menu.location = self
    dup_menu.save!(validate: false)
    dup_menu.update_attribute(:publish_email, nil)
    dup_menu.update_attribute(:name, "Copy of #{dup_menu.name}")

    items = menu.items.reduce({}) do |acc, item|
      dup_item = item.amoeba_dup
      dup_item.location = self
      dup_item.save!(validate: false)
      acc[item.id] = dup_item.id
      acc
    end

    categories = menu.categories.reduce({}) do |acc, category|
      dup_category = category.amoeba_dup
      dup_category.location = self
      dup_category.save!(validate: false)
      acc[category.id] = dup_category.id
      acc
    end


    menu.build_menus.each do |build_menu|
      category_id = categories[build_menu.category.id]
      item_id = items[build_menu.item.id]

      bm = dup_menu.build_menus.new
      bm.category_id = category_id
      bm.item_id = item_id
      bm.menu_id = dup_menu.id
      bm.active = build_menu.active
      bm.category_sequence = build_menu.category_sequence
      bm.item_sequence = build_menu.item_sequence
      bm.save!(validate: false)
    end

    menu.location.item_keys.each do |item_key|
      dup_item_key = item_key.dup
      dup_item_key.location_id = self.id
      dup_image = dup_item_key.build_item_key_image
      begin
        dup_image.duplicate_file(item_key.item_key_image)
      rescue => e
        Rails.logger.error "Error, while copying image for #{item_key.name}"
      end
      dup_item_key.save!(validate: false)
    end
  end

  def grades
    @_comments ||= item_comments
  end

  # Takes Location grades (via ItemComments), sorts them by months
  # (last updated value) and gets the average
  # the final result's format that is passed to LocationGrader is:
  # { 1 => 4.3, 4 => 5.0 }
  # where the keys (1,2..12) are the months
  # and the values are the average for comments per month

  def calculate_grade
    rating = LocationGraderService.new(self).grade.to_i
    rating.zero? ? nil : rating
  end

  def use_primary_cuisine?
    skip_primary_cuisine_validation.to_i != 1
  end

  def self.sending_weekly_progress_report
    self.where(weekly_progress_report: 1).find_in_batches do |locations|
      locations.each { |location| LocationReport.perform_async(location.id) }
    end
  end

end
