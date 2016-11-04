class User < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessor \
    :agree,
    :autofill,
    :credit_card_number,
    :credit_card_expiration_date,
    :credit_card_cvv,
    :billing_address,
    :billing_country,
    :billing_state,
    :billing_city,
    :billing_zip,
    :billing_country_code,
    :credit_card_type,
    :login,
    :email_confirmation,
    :password_bak,
    :full_name,
    :restaurant_manager,
    :skip_zip_validation,
    :skip_username_validation,
    :skip_first_name_validation,
    :skip_last_name_validation,
    :credit_card_holder_name,
    :skip_credit_card_validation,
    :skip_restaurant_type_validation

  attr_accessible \
    :username,
    :email,
    :password,
    :password_confirmation,
    :remember_me,
    :first_name,
    :customer_id,
    :credit_card_type,
    :last_name,
    :points,
    :city,
    :state,
    :address,
    :role,
    :phone,
    :parent_user_id,
    :gg_refresh_token,
    :app_service_id,
    :restaurants_attributes,
    :credit_card_attributes,
    :agree,
    :autofill,
    :zip,
    :gg_access_token,
    :credit_card_number,
    :credit_card_expiration_date,
    :credit_card_cvv,
    :billing_address,
    :billing_country,
    :billing_state,
    :billing_city,
    :billing_zip,
    :billing_country_code,
    :active_braintree,
    :subscription_id,
    :time_request,
    :email_confirmation,
    :password_bak,
    :full_name,
    :profile_attributes,
    :confirmed_at,
    :unconfirmed_email,
    :checkbox_app_service_value,
    :confirmation_token,
    :login,
    :is_register,
    :email_profile,
    :restaurant_manager,
    :token,
    :access_token_levelup,
    :account_number,
    :is_add_friend,
    :skip_zip_validation,
    :skip_username_validation,
    :skip_first_name_validation,
    :skip_last_name_validation,
    :credit_card_holder_name,
    :price_id,
    :token_authenticatable,
    :skip_credit_card_validation,
    :avatar,
    :contact_delete,
    :latitude,
    :longitude,
    :is_suspended,
    :employer_id,
    :avatar_id,
    :skip_restaurant_type_validation,
    :restaurant_type


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :app_service
  belongs_to :employer, :class_name => 'Location', :foreign_key => 'employer_id'
  belongs_to :parent_user, :class_name => "User", :foreign_key => "parent_user_id"
  belongs_to :price

  has_many :photos, as: :photoable
  has_one :avatar, class_name: 'Photo', as: :photoable
  has_many :checkins
  has_many :contact_groups, :through => :location_contact_groups
  has_many :contact_on_locations, :through => :user_contacts, :source => :location
  has_many :customers_locations, class_name: "CustomersLocations", dependent: :destroy
  has_one :device, :dependent => :destroy
  has_many :feedbacks, :dependent => :destroy
  has_many :item_comments, :dependent => :destroy
  has_one :info
  has_many :item_favourites, :dependent => :destroy
  has_many :location_comments, :dependent => :destroy
  has_many :location_contact_groups, :foreign_key => "location_owner_id"
  has_many :location_favourites, :dependent => :destroy
  has_many :location_visiteds, :dependent => :destroy
  has_many :orders, :dependent => :destroy
  has_many :contest_actions
  has_one :profile
  has_many :push_notifications, as: :push_notifiable, :dependent => :destroy
  has_many :push_notification_preferences # NOTE: These are only the disabled notification_types
  has_many :push_notification_subscriptions # NOTE: These are only the disabled notification_types
  has_many :restaurants, :foreign_key => 'owner_id', :class_name => "Location", :dependent => :destroy
  has_many :search_profiles, :dependent => :destroy
  has_many :server_favourites, :dependent => :destroy
  has_many :server_ratings, :dependent => :destroy
  has_many :services, :dependent => :destroy
  has_many :sub_users, :class_name => "User", :foreign_key => "parent_user_id"
  has_one :user_avatar, :dependent => :destroy
  has_one :user_billing
  has_many :user_contacts
  has_many :user_recent_searches, :dependent => :destroy
  has_many :subscriptions
  has_many :user_rewards, foreign_key: "receiver_id", dependent: :destroy
  has_many :rewards, through: :user_rewards

  #############################
  ###  VALIDATIONS
  #############################
  validates :username,
            presence: { message: 'can\'t be blank' },
            length: { minimum: 3, maximum: 30,
                      message: 'must be between 3 and 30 characters.'
                    },
            format: { without: /[\s]/,
                      message: 'should not have space' },
                      uniqueness: true,
                      unless: :get_skip_username_validation?

  validates :phone,
            allow_blank: true,
            format: { with: /^\(([0-9]{3})\)([ ])([0-9]{3})([-])([0-9]{4})$/,
                      message: "^Invalid Phone number format. Use: (xxx) xxx-xxxx"
                    }
  validate :validate_space_password
  # validate :validate_email_confirmation, if: :use_credit_card?
  validates :zip,
            presence: { message:"can't be blank" },
            numericality: { message: "is not a number" } ,
            length: { is: 5 },
            unless: :get_skip_zip_validation?

  validate :credit_card_format
  validates :credit_card_type, presence: true, if: :use_credit_card?
  validates :credit_card_number, presence: true, numericality: { message: 'must be numbers' }, if: :use_credit_card?
  validates :credit_card_holder_name, presence: true, if: :use_credit_card?
  validates :credit_card_expiration_date,
            presence: true,
            format: { with: /^((0[1-9])|(1[0-2]))\/(\d{2})$/,
                      message: "^Invalid expiration date - please use the format: MM/YY"
                    },
            if: :use_credit_card?
  validates :credit_card_cvv,
            presence: true,
            numericality: { message: "must be numbers" },
            if: :use_credit_card?
  validates :billing_address,
            presence: true,
            if: :use_credit_card?
  validates :billing_zip,
            presence: true,
            length: {is: 5},
            if: :use_credit_card?
  validates :restaurant_type,
            presence: { message: 'must be selected' },
            if: :use_restaurant_type?


  #############################
  ###  SCOPES
  #############################
  scope :ordered, ->(location_id, user_id) { joins(:orders).where('users.id != ? AND orders.location_id = ?',
                                                                  user_id, location_id).readonly(false) }
  scope :search_by_emails_except, ->(emails, user_id) { where('email IN (?) AND id != ?', emails, user_id) }
  scope :search_by_usernames_except, ->(usernames, user_id) {where('username IN (?) AND id != ?',usernames, user_id)}


  #############################
  ###  CALLBACKS
  #############################
  after_validation :geocode
  after_initialize :init
  before_create :set_default_value
  after_create :subscribe_user_to_push_notifications
  after_destroy :remove_avatar_dir

  #############################
  ###  NESTED ATTRIBUTES
  #############################
  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :restaurants


  #############################
  ###  DEPENDENCY CONFIG
  #############################
  devise \
    :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable,
    :token_authenticatable, # creates the ensure_authentication_token! method
    :confirmable,
    authentication_keys: [:login]
  geocoded_by :zip


  #############################
  ###  CONSTANTS
  #############################
  ROLES = [USER_ROLE, RTR_MANAGER_ROLE, RTR_ADMIN_ROLE, OWNER_ROLE, ADMIN_ROLE, CASHIER_ROLE]


  #############################
  ###  INSTANCE METHODS
  #############################

  def access_token
    self.authentication_token
  end

  def add_points(p1,location_id)
    p = self.points.to_f + (p1.to_f*0.99)
    self.update_attribute(:points,p)
    @p = p1
    @user_id = self.id
    @location_id = location_id
    add_point_friend
  end

  def add_point_friend
    if @p != 0 && @user_id != 0
      while (friend_id = Friendship.where("friend_id = ? AND pending = 2 ",@user_id).first) do
        user = User.find(friend_id.friendable_id)
        point_add = @p.to_f/100 # 1% point

        if Friendship.where("friend_id = ? AND pending = 2 ",friend_id.friendable_id).first
          p_received = point_add.to_f*0.99
          p_share = p_received.to_f/100

          user.update_attribute(:points,user.points + p_received)

          add_userpoint(friend_id.friend_id,@location_id,point_add,"Points Shared",2)
          add_userpoint(user.id,@location_id,p_received,RECEIVED_POINT_TYPE,1)
          @user_id = friend_id.friendable_id
          @p = point_add
        else
          user.update_attribute(:points,(user.points + point_add))
          add_userpoint(friend_id.friend_id,@location_id,point_add,"Points Shared",2)
          add_userpoint(user.id,@location_id,point_add,RECEIVED_POINT_TYPE,1)
          @user_id = friend_id.friendable_id
          break
        end
      end
    end
  end

  def add_points_user(p)
    p = self.points.to_f + p.to_f
    self.update_attribute(:points,p)
  end

  def build_query_string(params)
    return nil unless params

    query_string = ""

    params.each do |k, v|
      next unless v
      query_string << "&" unless query_string == ""
      query_string << "#{k}=#{CGI::escape(v.to_s)}"
    end

    query_string == "" ? nil : query_string
  end

  def confirm!
    super
    if confirmed? && self.owner?
      # Payment with user's package
      customer = BraintreeRails::Customer.find(self.customer_id)
      credit_card = customer.credit_cards[0]
      plan = AppService.find_plan(self.app_service_id)
      unless plan.nil?
        subscription = plan.subscriptions.build(
          :payment_method_token => credit_card.token
        )
        if subscription.save
          self.subscription_id = subscription.id

        # else
        #   BraintreeRails::Customer.delete(customer.id)
        #   raise "Couldn't pay."
          # @braintree_errors = true
          # # clear customer
          # BraintreeRails::Customer.delete(@customer.id)
          # clean_security_fields resource
          # return render :new
        end
      else
        raise "This package could not be found."
      end
    end
  end

  def confirmed?
    rs = !!confirmed_at
    unless self.parent_user.nil?
      rs = rs && !!self.parent_user.confirmed_at
    end
    return rs
  end

  def cropping?
    false
  end

  def create_google_account(role, restaurant_id=nil)
    is_failed = false
    # Create a new google account if user's email is not google account
    self.email_profile = self.email
    if self.google_account?(self.parse_domain)
      # self.save
    else
      admin_account = User.find_by_email(ENV["MYMENU_ADMIN_NAME"])
      begin
        auth_client_obj ||= OAuth2::Client.new(ENV["CLIENT_ID"], ENV["CLIENT_SECRET"],
                                               {:site => 'https://accounts.google.com',
                                                :authorize_url => "/o/oauth2/auth", :token_url => "/o/oauth2/token"})
        now = Time.now
        if !admin_account.time_request.nil? && (now - admin_account.time_request) > ENV['REFRESH_TIME']
          refresh_access_token_obj = OAuth2::AccessToken.new(auth_client_obj,
                                                             admin_account.gg_access_token, {refresh_token: admin_account.gg_refresh_token})

          new_token = refresh_access_token_obj.refresh!

          # update token to admin_account
          admin_account.gg_access_token = new_token.token
          admin_account.gg_refresh_token = new_token.refresh_token
          admin_account.time_request = Time.now
          admin_account.save(:validate => false)
        end
      rescue
        is_failed = true
        #raise "Admin has not confirmed with Google Service."
      end
      if is_failed == false
        index = 1
        begin
          while true
            self.google_account_http_request(:get,
              URI.parse("https://www.googleapis.com/admin/directory/v1/users/#{self.generate_google_account(role, restaurant_id, index)}"),
                {
                  token: admin_account.gg_access_token
                }
              )
            index += 1
          end
        rescue
          # while true
          rs = self.google_account_http_request(:post,
            URI.parse("https://www.googleapis.com/admin/directory/v1/users"),
              {
                token: admin_account.gg_access_token,
                body: self.to_google_account_json(role, restaurant_id, index)
              }
            )
          index += 1
          user_info = JSON.parse(rs)
          self.email = user_info['primaryEmail']
          # end
        end
      end
    end
    return self.email
  end

  def create_manager_account_with_location(location_id)
    location = Location.find(location_id)
    user = self.sub_users.build
    user.first_name = "Restaurant"
    user.last_name = "Manager"
    user.role = RTR_MANAGER_ROLE
    user.password_bak = user.generate_password(8)
    user.create_google_account(user.role, location_id)
    user.generate_username(user.role, location.name)
    user.skip_confirmation!
    if user.save(validate: false)
      location.rsr_manager = user.id.to_s + ','
      location.save
    end
    user
  end

  def current_checkin_at(location)
    Checkin.users_current_checkin_at_location(self, location)
  end

  def current_device_is?(given_device)
    given_device == current_device
  end

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless User.where(token: random_token).exists?
    end
  end

  def generate_username(role, restaurant)
    index = 1
    restaurant = restaurant.squish.downcase.tr(" ", "_")
    while true
      name = ROLE_RESTAURANT_NAME[role] + index.to_s + '_' + restaurant
      if User.find_by_username(name.downcase).nil?
        self.username = name.downcase
        return name.downcase
      end
      index += 1
    end
  end

  def full_name
    first_name = ''
    first_name = (self.first_name.to_s + ' ') unless self.first_name.nil?
    return first_name + self.last_name.to_s
  end

  def generate_google_account(role, restaurant_id, index=1)
    domain = "@mymenu.us"
    name = ''

    # Get restaurant name
    restaurant = ''
    if restaurant_id
      restaurant = Location.find(restaurant_id).name
    else
      if self.owner?
        restaurant = self.restaurants[0].name unless self.restaurants[0].nil?
      end
    end

    restaurant = restaurant.squish.downcase.tr(" ", "_")
    # index = 1 if index.zero?

    # Generate email
    name = ROLE_RESTAURANT_NAME[role] + index.to_s + '_' + restaurant + domain
    name.downcase
  end

  def get_real_app_service
    # return nil if self.admin?
    return self.app_service if self.parent_user.nil? || self.admin?
    return self.parent_user.app_service
  end

  def get_skip_zip_validation?
    return self.skip_zip?
  end

  def get_skip_username_validation?
    return self.skip_username?
  end

  def get_skip_first_name_validation?
    return self.skip_first_name?
  end

  def get_skip_last_name_validation?
    return self.skip_last_name?
  end

  def get_total_point
    return UserPoint.get_points(self.id).first.sum.to_i
  end

  def google_account_http_request(method, uri, args)
    headers = args[:headers] || {}
    headers["Authorization"] = "Bearer #{args[:token]}"
    headers["Content-Type"] = "application/json"
    # headers["GData-Version"] = "3.0"

    http = Net::HTTP.new(uri.host, uri.port)
    # http.set_debug_output(@options[:debug_output]) if @options[:debug_output]
    http.use_ssl = true

    if args[:verify_ssl]
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    else
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    http.start

    query_string = build_query_string(args[:params])
    request_uri = query_string ? "#{uri.request_uri}?#{query_string}" : uri.request_uri

    # GET
    if method == :get
      response = http.request_get(request_uri, headers)
      # POST
    elsif method == :post
      response = http.request_post(request_uri, args.delete(:body), headers)
      # PUT
    elsif method == :put
      response = http.request_put(request_uri, args.delete(:body), headers)
      # DELETE
    elsif method == :delete
      response = http.request(Net::HTTP::Delete.new(request_uri, headers))
    else
      raise ArgumentError, "Invalid method #{method}"
    end

    if response.code == "400" or response.code == "412" or response.code == "404"
      raise "#{response.body} (HTTP #{response.code})"
    elsif response.code == "401"
      raise response.body
    elsif response.code != "200" and response.code != "201"
      raise Net::HTTPError.new("#{response.message} (#{response.code})", response)
    end

    response.body
  end

  def google_account?(domain)
    return false if domain.nil?
    return true if domain == 'gmail.com'
    uri = URI.parse("http://dns-record-viewer.online-domain-tools.com/tool-form-submit/")

    # Shortcut
    response = Net::HTTP.post_form(uri, {"host" => domain, "nameServer" => "8.8.8.8",
                                         'types' => 'MX', 'send' => '> Query!'})
    out = response.body.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
    result = out.scan(/<div class="results">(.*)<\/div>/m)
    if !result[0].nil? && result[0][0].to_s.match(/ASPMX.L.GOOGLE.COM/i)
      return true
    end
    return false
  end

  def image
    return self.user_avatar.image.url(:primary) if !self.user_avatar.nil?
  end

  def init
    if self.has_attribute?(:token) && self.token.nil?
      self.generate_token
    end
  end

  def is_checked_in_at?(location)
    Checkin.user_is_checked_in_at_location?(self, location)
  end

  def limit_available?
    return true

    # Now there is only one plan ("byte") based on how many restaurants on on account.
    # No need to limit restaurants.

    # *********** Old version of code ***********
    # return true if self.admin?
    # if self.parent_user.nil?
    #   return (self.unlimit? || Location.where(:owner_id => self.id).count < self.app_service.limit.to_i)
    # end
    # return (self.unlimit? || Location.where(:owner_id => self.parent_user.id).count < self.parent_user.app_service.limit.to_i)
    # *******************************************
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.email
  end

  # def may_comment_on?(resource) # Location or Item

  # end

  def most_recently_used_device_that_was_not(given_device)
    Device.users_most_recently_used_device(self, [given_device.id])
  end

  def new_contact?(location_owner_id)
    UserContact.find_by_user_id_and_location_owner_id(self.id, location_owner_id).nil?
  end

  def parse_domain
    return nil if self.email_profile.nil?
    domain = self.email_profile.match(/(.*)@(gmail.com)$/)
    unless domain.nil?
      return domain[-1]
    end
    return nil
  end

  # validate :check_agree
  #after_save :add_point_friend,:only => :add_points
  def remove_avatar_dir
    #remove carrierwave uploads
    FileUtils.remove_dir("#{Rails.root}/public/uploads/user/avatar/#{id}", :force => true)
  end

  def skip_first_name?
    skip_first_name_validation.to_i == 1
  end

  def skip_last_name?
    skip_last_name_validation.to_i == 1
  end

  def skip_username?
    skip_username_validation.to_i == 1
  end

  def skip_zip?
    skip_zip_validation.to_i == 1
  end

  def sub_points(p)
    p = self.points.to_f - p.to_f
    self.update_attribute(:points,p)
  end

  def subscribe_user_to_push_notifications
    # Each user needs to be subscribed to his/her individual channel
    PushNotificationSubscription.subscribe(self, self)
  end

  def to_element(location_owner_id,  *title_groups)
    first_name = self.first_name.nil? ? 'Unknown' : self.first_name
    last_name = self.last_name.nil? ? 'Unknown' : self.last_name
    el = GContacts::Element.new({
                                  'category' => {
                                    '@term' => 'contact'
                                  },
                                  "gd:name" => {
                                    "gd:fullName" => "#{first_name} #{last_name}",
                                    "gd:givenName" => "#{last_name}",
                                    "gd:familyName" => "#{first_name}"
                                  },
                                  "gd:email" => {
                                    "@rel" => "http://schemas.google.com/g/2005#other",
                                    "@address" => "#{self.email}",
                                    "@primary" => "true"
                                  },
                                  "gd:extendedProperty" => {
                                    "@name" => "zipcode",
                                    "@value" => "#{self.zip}"
                                  }
    })

    user_contact = UserContact.find_by_user_id_and_location_owner_id(self.id, location_owner_id)

    unless user_contact.nil?
      # Prepare contact group for user
      title_groups.each do |title|
        group = ContactGroup.find_by_title(title)
        unless group.nil?
          location_group = group.get_gg_contact_group(location_owner_id)
          if location_group
            # contact_group_ids << location_group.id
            UserLocationContactGroup.find_or_create_by_location_contact_group_id_and_user_contact_id(
            :location_contact_group_id => location_group.id, :user_contact_id => user_contact.id)
          end
        end
      end

      gg_contact_groups = user_contact.location_contact_groups
      gg_contact_groups.each do |g|
        el.group_ids << "#{g.gg_contact_group_id}"
      end
      el.id = user_contact.gg_contact_id unless user_contact.gg_contact_id.nil?
      el.etag = user_contact.etag unless user_contact.etag.nil?
    end

    return el
  end

  def update_email_address
    # Generate Google account
    if self.owner?
      self.create_google_account(self.role)
    end
  end

  def update_push_notification_settings!
    device.try(:update_push_notification_settings!)
  end

  def validate_email_confirmation
    return if self.email.nil?
    errors.add(:email, "doesn't match email confirmation") unless self.email == self.email_confirmation
  end



  def send_devise_notification(notification, opts={})
    email = self.email_profile
    email = self.email if email.nil?
    default_opts = {to: email}
    default_opts.merge(opts)
    devise_mailer.send(notification, self, default_opts).deliver
  end

  def to_google_account_json(role, restaurant_id, index=1)
    first_name = self.first_name.to_s == '' ? 'Restaurant' : self.first_name
    last_name = self.last_name.to_s == '' ? 'Admin' : self.last_name
    info = {
      primaryEmail: self.generate_google_account(role, restaurant_id, index),
      name: {
        givenName: first_name,
        familyName: last_name,
      },
      password: self.password_bak,
      changePasswordAtNextLogin: true
    }
    info.to_json
  end

  def use_credit_card?
    self.owner? && skip_credit_card_validation.to_i != 1
  end

  def use_restaurant_type?
    !self.user? && skip_restaurant_type_validation.to_i != 1
  end

  def user_update_package(old_subscription_id, new_app_service_id)
    customer = BraintreeRails::Customer.find(self.customer_id)
    credit_card = customer.credit_cards[0]
    #old_plan = AppService.find_plan(old_app_service_id)
    plan = AppService.find_plan(new_app_service_id)
    unless old_subscription_id.nil?
      Braintree::Subscription.cancel(old_subscription_id)
    end
    unless plan.nil?
      subscription = plan.subscriptions.build(
        :payment_method_token => credit_card.token
      )
      if subscription.save
        self.update_attribute(:subscription_id, subscription.id)
      else
        BraintreeRails::Customer.delete(customer.id)
        raise "Couldn't pay."
      end
    else
      raise "This package could not be found."
    end
  end

  def has_parent?
    return !self.parent_user_id.nil?
  end

  def admin?
    return self.role == ADMIN_ROLE
  end

  def owner?
    return self.role == OWNER_ROLE
  end

  def restaurant_admin?
    return self.role == RTR_ADMIN_ROLE
  end

  def restaurant_manager?
    return self.role == RTR_MANAGER_ROLE
  end

  def role?(base_role)
    ROLES.index(base_role) <= ROLES.index(self.role)
  end

  def user?
    return self.role == USER_ROLE
  end

  def set_default_value
    self.role = USER_ROLE if (self.role.nil? || self.role.empty?)
    max_num = nil
    max_num = User.last.account_number if !User.last.nil?
    self.account_number = max_num.nil? ? 1 : max_num + 1
  end

  # TODO: Eliminate the credit_card_format method in favor of:
  # https://github.com/tobias/credit_card_validator
  def credit_card_format
    # check format
    return true if self.credit_card_type.to_s.empty?
    format = CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:format]
    format_range = CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:format_range]
    unless format.nil?
      unless self.credit_card_number.start_with?(*format)
        return errors.add(:credit_card_number, build_error_msg(format, format_range))
      end
    end

    unless format_range.nil?
      format_range.each do |index|
        range = (index[:from]..index[:to]).to_a
        if !self.credit_card_number.start_with?(*range) && !self.credit_card_number.start_with?(*format)
          return errors.add(:credit_card_number, build_error_msg(format, format_range))
        end
      end
    end

    # check length
    unless CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:length].nil?
      if self.credit_card_number.length != CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:length]
        return errors.add(:credit_card_number, "^#{self.credit_card_type} card must have
            #{CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:length]} digits")
      end
    else
      unless self.credit_card_number.length.between?(CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:min_length],
                                                     CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:max_length])
        return errors.add(:credit_card_number, "^#{self.credit_card_type} card must have
            #{CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:min_length]}
            - #{CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:max_length]} digits")
      end
    end

    # check cvv
    unless CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:cvv_length].nil?
      if self.credit_card_cvv.length != CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:cvv_length]
        return errors.add(:credit_card_number, "^#{self.credit_card_type} card CVV must have
            #{CARD_TYPE_NUMBER_FORMAT[self.credit_card_type][:cvv_length]} digits")
      end
    end

  end


  #############################
  ###  CLASS METHODS
  #############################

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    # password = conditions.delete(:password)
    if login = conditions.delete(:login)
      user = where(conditions).where(["lower(email) = :value or lower(username) = :value", { :value => login.downcase }]).first
      # sub_users = []
      # unless user.nil?
      #   sub_users = [user] + user.sub_users
      # end
      # users = sub_users.select {|u| u.valid_password?(password)}
      # user = users.first
    else
      user = where(conditions).first
    end
    return user
  end

  def self.get_total_point_my_contact(user_id)
    user_point = UserPoint.get_points(user_id).first
    unless user_point.nil?
      user_point = user_point.sum
    end
    return user_point
  end

  def self.get_total_point_contact(user_id, location_id)
    user_point = UserPoint.get_point_contacts(user_id, location_id).first
    unless user_point.nil?
      user_point =user_point.sum
    end
    return user_point
  end

  def self.search_customer_contact(search)
    user_id_arr = []
    user_arr = User.where("(username LIKE ? || zip LIKE ? || email LIKE ?) AND (role=?)",'%' + search + '%', '%' + search + '%', '%' + search + '%',USER_ROLE)
    unless user_arr.empty?
      user_arr.each do |user|
        user_id_arr << user.id
      end
    end
    return user_id_arr
  end

  def self.search_customer_contact_message(search)
    user_id_arr = []
    user_arr = User.where("(username LIKE ? || email LIKE ? || first_name LIKE ? || last_name LIKE ?) AND (role=?)", '%' + search + '%', '%' + search + '%', '%' + search + '%', '%' + search + '%', USER_ROLE)
    unless user_arr.empty?
      user_arr.each do |user|
        user_id_arr << user.id
      end
    end
    return user_id_arr
  end

  def self.search_user_account(search, role)
    first_name = search.split(' ').first
    last_name = search.split(' ').last
    if role != 'user'
      locations = Location.where('name like ?', '%' + search + '%')
      owner_id_arr = []
      rsr_manager_arr = []
      if !locations.empty?
        locations.each do |location|
          owner_id_arr << location.owner_id
          rsr_manager = location.rsr_manager
          if !rsr_manager.nil?
            rsr_manager = rsr_manager.split(',')
            rsr_manager_arr << rsr_manager[0].to_i
          end
        end
        return User.where("id IN (?) || id IN (?)", owner_id_arr, rsr_manager_arr)
      else
        return User.where("(first_name LIKE ? || last_name LIKE ? || username LIKE ? || email LIKE ?) AND (role=? || role=?)",
                          '%' + first_name + '%', '%' + last_name + '%', '%' + search + '%', '%' + search + '%',OWNER_ROLE, RTR_MANAGER_ROLE)
      end
    else
      return User.where("(first_name LIKE ? || last_name LIKE ? || username LIKE ? || email LIKE ?) AND (role=?) AND (is_register = ?)",
          '%' + first_name + '%', '%' + last_name + '%', '%' + search + '%', '%' + search + '%',USER_ROLE, 0)
    end
  end

  [:basic?, :deluxe?, :premium?, :unlimit?].each do |method_name|
    define_method method_name do |arg=nil|
      return false if self.admin?
      return self.app_service.send(method_name) if self.parent_user.nil?
      return self.parent_user.app_service.send(method_name)
    end
  end

  [:restaurant_name, :physical_zip,:physical_city, :physical_address,
   :physical_country, :mailing_city, :mailing_address, :mailing_country,
  :mailing_zip, :physical_state, :mailing_state].each do |attribute|
    define_method attribute do |arg=nil|
      return self.profile.send(attribute) unless self.profile.nil?
      return nil
    end
  end

  def ==(obj)
    if obj.instance_of?(self.class)
      compare_attributes = ["phone", "first_name", "last_name",
                            "restaurant_name", "physical_zip", "physical_address",
                            "physical_country", "physical_city", "mailing_address",
                            "mailing_country", "mailing_city", "mailing_zip",
                            "physical_state", "mailing_state"]
      compare_attributes.each do |field|
        if self.send(field) != obj.send(field)
          return false
        end
      end
      return true
    end
    false
  end

  def self.search_friend(name,current_user,limit,offset)
    sql = "SELECT  u.id as user_id , u.first_name,u.last_name,u.username, u.email, (case when f.pending != 0  then 1 else 0 end ) as status
        FROM users u
        LEFT JOIN friendships f ON (f.friendable_id = u.id OR f.friend_id = u.id)  AND (f.friendable_id = #{current_user.id} OR f.friend_id = #{current_user.id})
        WHERE (u.username like '#{name}%' OR u.email like '#{name}%'
              OR u.first_name like '#{name}%' OR u.last_name like '#{name}%')
              AND ( u.username !='#{current_user.username}' AND u.email !='#{current_user.email}')
              AND u.is_register = 0 AND u.role ='user'
       ORDER  BY u.username
       LIMIT #{limit}
       OFFSET #{offset}"
    return self.find_by_sql(sql)
  end

  def self.get_current_status(location_id, user_id)
    current_status = nil
    # get prizes in order (not pay yet)
    ordering_sql = "SELECT
                        p.id, p.level, sp.id as status_prize_id
                    FROM
                        order_items oi
                            JOIN
                        orders o ON o.id = oi.order_id AND o.is_paid = 0
                            JOIN
                        prizes p ON p.id = oi.prize_id AND p.is_delete = 0
                            JOIN
                        status_prizes sp ON p.status_prize_id = sp.id
                    WHERE
                        o.user_id = ? AND sp.location_id = ? AND oi.share_prize_id = 0 AND oi.prize_id IS NOT NULL AND oi.is_prize_item = 1
                    ORDER BY p.status_prize_id"
    ordering_sql_completed = ActiveRecord::Base.send(:sanitize_sql_array, [ordering_sql, user_id, location_id])
    ordering_prizes = Prize.find_by_sql(ordering_sql_completed)

    # if diner was adding prizes to order, then current status of diner is status name of max prize in that order
    # In case diner hasn't yet ordered any prize. Base on prizes what diner redeemed/shared/paid (order),
    #   get max prize and determine the status name as current status of diner at a restaurant
    unless ordering_prizes.empty?
      max_ordering_prize = ordering_prizes.max_by { |p| p.status_prize_id && p.level}
      current_status = StatusPrize.find(max_ordering_prize.status_prize_id).name
    else
      redeemed_prizes = Prize.get_redeemed_prizes(location_id, user_id)
      shared_prizes = Prize.get_shared_prizes(location_id, user_id)
      ordered_prizes = Prize.get_ordered_prizes(location_id, user_id)

      used_prizes = redeemed_prizes | shared_prizes | ordered_prizes
      max_prize = used_prizes.sort_by { |p| [p.status_prize_id, p.level]}.last

      if max_prize.nil?
        status = StatusPrize.where('location_id = ?', location_id).select('name').order("id")
        current_status = status.first.name unless status.empty?
      else
        prizes_by_max_status =[]
        used_prizes.each do |i|
          if i.status_prize_id == max_prize.status_prize_id
            prizes_by_max_status << i
          end
        end

        prizes = Prize.where('status_prize_id = ? and is_delete = 0', max_prize.status_prize_id)
        if prizes_by_max_status.length < prizes.length
          current_status = StatusPrize.find(max_prize.status_prize_id).name
        else
          max_status = StatusPrize.where('location_id = ?', location_id).order('id').last
          if max_prize.status_prize_id == max_status.id
            current_status = max_status.name
          else
            current_status = StatusPrize.find(max_prize.status_prize_id + 1).name
          end
        end
      end
    end
    return current_status
  end

  #set status for dinner via total point
  def dinner_status
    begin
      dinner_status = DinnerType.where("dinner_types.key = ?",1).order("dinner_types.point")
      if dinner_status.count != 0
        if dinner_status.count == 1
          if self.points >= dinner_status[0].point
            return dinner_status[0].types
          else
            return nil
          end
        else
          if dinner_status.count == 2
            if self.points >= dinner_status[1].point
              return dinner_status[1].types
            elsif self.points >= dinner_status[0].point
              return dinner_status[0].types
            end
          else
            if self.points >= dinner_status[2].point
              return dinner_status[2].types
            elsif self.points >= dinner_status[1].point
              return dinner_status[1].types
            elsif self.points >= dinner_status[0].point
              return dinner_status[0].types
            end
          end
        end
      else
        return nil
      end
    rescue
      return nil
    end
  end

  def point
    point = Location.find_by_sql("SELECT l.id , sum(p.points) as total
                                  FROM locations l
                                  INNER JOIN user_points p
                                  ON p.location_id = l.id
                                  WHERE p.user_id = '#{self.id}'
                                   GROUP BY l.id")
    return point
  end
  def defaultsearchprofile
    defaultsearchprofile = SearchProfile.where("user_id = ? AND isdefault = 1",self.id).first
    if defaultsearchprofile
      return defaultsearchprofile.id
    else
      return ''
    end
  end
  def name
    "#{self.first_name} #{self.last_name}"
  end
  def friend_status
    if self.pending == 0
      return "Pending"
    elsif self.pending == 1
      return "Registered"
    elsif self.pending == 2
      return "Actived"
    end
    return nil
  end
  def apply_omniauth(provider,uid,uname)
    services.build(:provider => provider,
                   :uid => uid,
                   :uname => uname)
  end
  def generate_password(length)
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    while true
      password = ''
      length.times { |i| password << chars[rand(chars.length)] }
      break if self.admin? || self.owner? || self.user?
      if self.new_record?
        sub_users = User.where('parent_user_id = ?', self.parent_user_id)
      else
        sub_users = User.where('parent_user_id = ? AND id != ?', self.parent_user_id,
                               self.id)
      end
      valid = true
      sub_users.each do |u|
        if u.valid_password?(password)
          valid = false
          break
        end
      end

      break if valid
    end

    self.password = password
    password
  end
  #data fake
  def last_rating
    last = ItemComment.where("user_id = ?",self.id)
    unless last.empty?
      return last.last.created_at.strftime("%m/%d/%Y")
    end
    return nil
  end
  def number_rating
    last = ItemComment.where("user_id = ?",self.id)
    unless last.empty?
      return last.count
    end
    return nil
  end
  def point_received
    point = UserPoint.where("user_id = ? AND point_type = 'Points Received'", self.id)
    total = 0
    unless point.empty?
      for x in point do
        total = total + x.points
      end
      return total
    end
    return nil
  end
  def restaurant_visited
    visit = LocationVisited.where("user_id = ?", self.id)
    unless visit.empty?
      return visit.count
    end
    return nil
  end

  #share point to other user
  def share_point(restaurant_id, point)
  end

  def validate_space_password
    return if self.password.nil?
    errors.add(:password, "cannot contain spaces.") unless self.password.index(/\s/).nil?
  end

  #Get list of friend by friendable_id field
  def self.get_friend_by_friendable_id(user_id)
    sql = "SELECT CASE WHEN f.pending != 0 THEN DATE_FORMAT(u.created_at, '%m/%d/%Y %H:%i:%S')
       WHEN f.pending = 0 AND u.is_register = 0 THEN DATE_FORMAT(u.created_at, '%m/%d/%Y %H:%i:%S')
      ELSE null END as date_registered, u.*,DATE_FORMAT(f.created_at, '%m/%d/%Y %H:%i:%S') as date_invited, f.pending
      FROM users as u
      INNER JOIN friendships as f ON u.id = f.friend_id
      WHERE f.friendable_id = #{user_id}"
    return self.find_by_sql(sql)
  end

  #Get list of friend by friend_id field
  def self.get_friend_by_friend_id(user_id)
    sql = "SELECT DATE_FORMAT(f.updated_at, '%m/%d/%Y %H:%i:%S') as date_registered,
      u.*,DATE_FORMAT(f.created_at, '%m/%d/%Y %H:%i:%S') as date_invited, f.pending FROM users as u
      INNER JOIN friendships as f ON u.id = f.friendable_id AND f.pending != 0
      WHERE f.friend_id = #{user_id}"
    return self.find_by_sql(sql)
  end

  #get_avatar user or manager/admin
  def get_avatar
    u = User.find_by_id(self.id)
    if u.role == 'user'
      return u.avatar.url unless u.avatar.nil?
    else
      info = Info.find_by_email(self.email)
      return info.info_avatar.image.url unless info.nil?
    end
    return nil
  end

  def check_suspend(location)
    check = CustomersLocations.find_by_user_id_and_location_id(self.id, location.id)
    if check.nil?
      return 0
    else
      if check.is_deleted == 0
        return 0
      end
      if check.is_deleted == 1
        return 1
      end
    end
    return 0
  end

  def checkin_at(location, award_points = true)
    checkins.create(location_id: location.id, award_points: award_points)
  end

  def remove_token_code
    user_json = self.as_json
    user_json.delete("token")
    user_json.delete("authentication_token")
    user_json.delete("updated_at")
    user_json.delete("created_at")
    user_json.delete("id")
    user_json.delete("email")
    user_json.delete("username")
    user_json
  end

  def create_custome_user(user_params)
    self.create_braimtree_custome(user_params)
    self.email = user_params["email"]
    self.username = user_params["username"]
    self.password = user_params["new_password"]
    self.password_confirmation = user_params["confirm_password"]
    self.role = OWNER_ROLE
    self.skip_confirmation!
    self.save!(:validate=>false)
    self
  end

  def create_braimtree_custome(user_params)
    customer_info = {
      :first_name => self.first_name,
      :last_name => self.last_name,
      :email => email,
      :phone => self.phone
    }

    credit_card_info = {
      :number => user_params["credit_card_number"],
      :cardholder_name => user_params["credit_card_holder_name"],
      :cvv => user_params["credit_card_cvv"],
      :expiration_date => user_params["credit_card_expiration_date"],
      :billing_address => {
        :street_address => self.address,
        :locality => self.city,
        :country_code_alpha2 => self.billing_country_code,
        :region => self.state,
        :postal_code => self.zip
      }
    }

    @customer = BraintreeRails::Customer.new(customer_info)
    if @customer.save
      self.customer_id = @customer.id
      @credit_card = @customer.credit_cards.build(credit_card_info)
      @credit_card.save
    end
    self
  end

  def get_braintree_token
    if self.customer_id.nil?
      result = Braintree::Customer.create(
        :first_name => self.first_name,
        :last_name => self.last_name,
        :company => "Byte",
        :email => self.email
      )
      if result.success?
        self.update_attribute('customer_id', result.customer.id)
      else
        return {status: 'failed', errors: result.errors}
      end
    end
    {status: 'success', token: self.customer_id}
  end

  def has_cognos?(location_id)
    self.subscriptions.map{ |s| [s.plan_id, s.location_id] }.
      detect{ |a| a.first == BYTE_PLANS[:cognos] && a.last == location_id  }
  end

  def create_profile
    if self.owner?
      # Create profile for user that is not "user" role
      unless self.restaurants[0].blank?
        profile = self.build_profile
        profile.restaurant_name = self.restaurants[0].name
        profile.physical_address = self.restaurants[0].address
        profile.physical_country = self.restaurants[0].country
        profile.physical_city = self.restaurants[0].city
        profile.physical_zip = self.restaurants[0].zip
        profile.mailing_address = self.restaurants[0].address
        profile.mailing_country = self.restaurants[0].country
        profile.mailing_city = self.restaurants[0].city
        profile.mailing_zip = self.restaurants[0].zip

        profile.physical_state = self.restaurants[0].state
        profile.mailing_state = self.restaurants[0].state
        profile.save
      end
    end
  end

  private
    def add_userpoint(id, restaurant_id, point, type, status)
      #Create new userpoint record
      #GIVE : 1 receive - 2 shared
      UserPoints.create(
        user_id: id,
        point_type: type,
        location_id: restaurant_id,
        points: point,
        status: 2,
        give: status
      )
    end

    def build_error_msg(format, format_range)
      message = "^#{self.credit_card_type} card must start with #{format.join(', ')}"
      unless format_range.nil?
        message += " or in range "
        array_range = []
        format_range.each do |f|
          array_range << "#{f[:from]} - #{f[:to]}"
        end
        message += array_range.join(', ')
      end
      message
    end

  protected
    def confirmation_required?
      return !confirmed? if self.owner?
      return false
    end
end
