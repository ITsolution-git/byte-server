class UsersController < ApplicationController

  #before_filter :authorise_request_as_json, :only=>[:login, :logout,:register,:settings,:update_settings,:points,:avatar,:forgot_password]
  before_filter :authorise_request_as_json, :except => [:batch_delete, :set_avatar]
  before_filter :authenticate_user_json, :only=> [:logout,:update_settings,:addsearchprofile,:deletesearchprofile,:editsearchprofile, :mymenu_feedback, :set_default,:mymenu_feedback_v1]
  before_filter :authorise_user_param, :only=>[:settings, :points,:avatar,:searchprofile,:getsearchprofile,:searchfriend, :recent_searches]
  before_filter :authenticate_user!, :only=>[:batch_delete]
  respond_to :json

  def login
    # Determine the parameters
    if request.post?
      parameters = ActiveSupport::JSON.decode(request.body).to_h.with_indifferent_access
    else # get
      parameters = params.to_h.with_indifferent_access
    end

    # Make the parameters more accessible
    email = parameters[:email]
    password = parameters[:password]
    username = parameters[:username]
    devise_token = parameters[:devise_token]
    # Validate the incoming parameters
    # TODO: Revamp this logic
    if email.nil? && username.nil?
      if password.nil?
        render :status => 412, :json => {:status => :failed, :error => "Please provide password and username"}
        return
      else
        render :status => 412, :json => {:status => :failed, :error => "Please provide email or username"}
        return
      end
    elsif email.present?
      @user = User.find_by_email(email.downcase)
      if @user.nil?
        return invalid_login_attempt
      end
    elsif username.present?
      @user = User.find_by_username(username)
      if @user.nil?
        render :status => 412, :json => {:status => :failed, :error => "Incorrect username or password."}
        return
      end
    else
      @user = User.where("username = ? AND email = ?", username, email).first
      if @user.nil?
        render :status => 412, :json => {:status => :failed, :error => "Incorrect username and password."}
        return
      end
    end

    # Authenticate the user
    if @user.valid_password?(password)
      @user.device_token = devise_token
      @user.ensure_authentication_token!
      set_curret_user_device_by_parse_id(@user, parameters[:push_id])
      PushNotificationSubscription.subscribe(@user, @user)
      @search_profile = SearchProfile.where('user_id = ? and isdefault = ?', @user.id, 1)
    else
      return invalid_login_attempt
    end

  end

  def logout
    begin
      if @user.nil?
        render :status=>412, :json=>{:message=>"Incorrect token."}
      else
        @user.reset_authentication_token!
        render :status=>200, :json=>{:status=>:success}
      end
    rescue
      return render :status => 503 ,:json => {:status => :failed}
    end
  end

  def test_register
    email ="thienhoangnhan2222@gmail.com"
    first_name="thien"
    last_name ="hoang"
    if register_level_up(email,first_name,last_name)
      return  render :json => {:status => :success}
    else
      return  render :json => {:status => :failed}
    end
  end

  # POST /users/register
  # User account creation
  # NOTE: It is unclear if this method is still in use - see register_v1.
  def register
    begin
      ActiveRecord::Base.transaction do
        @user = User.new(params[:user])
        @user.role = USER_ROLE

        # Attempt to geocode the User's location
        if geo_obj = Geocoder.search(@user.zip).first
          @user.state = geo_obj.state if geo_obj.state
          @user.city = geo_obj.city if geo_obj.city
        end

        begin
          user_record_saved = @user.save
        rescue
          return render :status => 412, :json=> {:status=>:failed, :errors=> @user.errors.inspect }.to_json
        end

        if user_record_saved
          # Automatically log the user in
          @user = sign_in(:user,@user)
          @user.ensure_authentication_token!
          set_curret_user_device_by_parse_id(@user, params[:push_id])
          begin
            UserMailer.custom_send_email(@user.email,SIGNUP_SUCCESS_SUBJECT,SIGNUP_SUCCESS_BODY).deliver
          rescue

          end
          #register account level up
          return render :status=>200, :json=> {:status=>:success,:id=>@user.id, :access_token => @user.access_token,
                                               :city => @user.city ||= '',:state => @user.state ||= '',:points => @user.points,"dinner_status"=>@user.dinner_status}.to_json
        else
          return render :status => 412,:json => {:status =>:failed,:errors => @user.errors.messages}.to_json
        end
      end
    rescue => e
      return render :status => 500,:json => {:status => e.message}
    end
  end

  def save_access_token_levelup
    access_token = check_exist_accout_level_up(@parsed_json['email'], @parsed_json['password'])
    unless access_token == "failed"
      @user.update_attributes(:access_token_levelup => access_token)
      return render :status => 200, :json => {:status => :success}
    else
      return render :status => 404, :json => {:status => :failed,:message => "The email or password is not correct."}
    end
  end

  def update_settings
    begin
      User.transaction do
        is_change_password = false
        @user.first_name= @parsed_json["first_name"] if @parsed_json["first_name"]
        @user.last_name= @parsed_json["last_name"] if @parsed_json["last_name"]
        @user.address = @parsed_json["address"] if @parsed_json["address"]
        @user.zip = @parsed_json["zip"] if @parsed_json["zip"]
        @user.phone = @parsed_json["phone"] if @parsed_json["phone"]
        if @parsed_json["username"]
          if @user.username.to_s.strip == @parsed_json["username"].to_s.strip
            @user.skip_username_validation = 1
          else
            @user.username = @parsed_json["username"]
          end
        else
          @user.skip_username_validation = 1
        end
        @user.skip_first_name_validation = 1
        @user.skip_last_name_validation = 1
        if !@parsed_json["password"].nil?
          @user.password = @parsed_json["password"]
          is_change_password = true
        end
        geo_obj = Geocoder.search(@parsed_json["zip"]).first
        if !geo_obj.nil?
          @user.state = geo_obj.state if geo_obj.state
          @user.city = geo_obj.city if geo_obj.city
        end
        # Assign data to pass validation
        @user.credit_card_type = VISA
        @user.credit_card_number = '4111111111111111'
        @user.credit_card_holder_name = 'test'
        @user.credit_card_expiration_date = '12/12'
        @user.credit_card_cvv = '123'
        @user.billing_address = 'Address'
        @user.billing_zip = '12345'
        @user.email_confirmation = @user.email
        if @user.save
          if is_change_password
            @user.reset_authentication_token!
          end
          return render :status => 200, :json => {:status => :success, "state" => @user.state ||= '',"city" => @user.city ||= '', :access_token => @user.authentication_token}.to_json
        else
          return render :status => 412, :json => {:status => :failed, :errors => @user.errors.messages}.to_json
        end
      end
    rescue
      return render :status => 503,:json => {:status =>:failed, :errors => "Service Unavailable"}
    end
  end

  def avatar
    @user = User.find_by_authentication_token(params[:access_token])
    photo_hash = upload_user_avatar(@user, params[:avatar])
    if photo_hash.present?
      create_or_update_avatar(@user, photo_hash)
    end
  end

  def set_avatar
    if params[:user][:avatar].present?
      photo_hash = upload_user_avatar(current_user, params[:user][:avatar])
      if photo_hash.present?
        if create_or_update_avatar(current_user, photo_hash)
          flash[:success] = 'Avatar was updated'
        else
          flash[:error] = 'Error during avatar update'
        end
      end
    end

    redirect_to accounts_url
  end

  def register_social
    begin
      ActiveRecord::Base.transaction do
        # Build a new User record
        @user = User.new
        @user.email = params['email']
        @user.username = params['username']
        @user.password = params['password']
        @user.address = params['address']
        @user.zip = params['zip']
        @user.first_name = params['first_name']
        @user.last_name = params['last_name']
        @user.social_image_url = params['imageURL']
        @user.role = USER_ROLE
        @user.skip_first_name_validation = 1
        @user.skip_last_name_validation = 1

        # Attempt to geocode the user's zip
        if geo_obj = Geocoder.search(params['zip']).first
          @user.state = geo_obj.state if geo_obj.state
          @user.city = geo_obj.city if geo_obj.city
        end

        # Finalize the new User record
        if @user.save
          name = params['email']
          @user.apply_omniauth(params['provider'], params['uid'], name)
          @user = sign_in(:user, @user)
          @search_profile = SearchProfile.where('user_id = ? and isdefault = ?', @user.id, 1) # Used in the view
          set_curret_user_device_by_parse_id(@user, params['push_id'])
          @user.ensure_authentication_token!
          begin
            UserMailer.custom_send_email(@user.email,SIGNUP_SUCCESS_SUBJECT,SIGNUP_SUCCESS_BODY).deliver
          rescue

          end
        else
          render :status => 412, :json => {:status => :failed, :errors => @user.errors.messages}.to_json
        end
      end
    rescue => e
      return render :status => 500, :json => {:status => e.message}
    end
  end

  # Social logins endpoint
  def check_token # effectively login_social
    begin
      ActiveRecord::Base.transaction do
        @parsed_json = params

        uid = @parsed_json["uid"] if @parsed_json["uid"]
        provider = @parsed_json["provider"] if @parsed_json["provider"]
        email = @parsed_json["email"] if @parsed_json["email"]
        name = (@parsed_json["name"] ? @parsed_json["name"] : '')
        username = @parsed_json["username"] if @parsed_json["username"]
        push_id = @parsed_json['push_id']

        # Confirm the required inputs are given
        if uid == "" || uid.nil?
          render :status => 412, :json => {:status =>:failed, :error => "Invalid params"}
          return
        end
        if provider == "" || provider.nil?
          render :status => 412, :json => {:status => :failed, :error => "Invalid params"}
          return
        end

        # Look up the User (Can be found by email or username. Variable is left check_email however.)
        check_email = User.find_by_email(email)

        if (check_email.nil?)
          check_email = User.find_by_username(username)
        end

        unless check_email.nil?
          if !check_email.user? # if the User isn't an ordinary user (is a manager, admin, etc)
            return render :status => 400, :json => {:status => :failed, :error => "Incorrect email or password."}
          end
        end

        # Perform the authentication
        auth = Service.find_by_provider_and_uid(provider, uid)
        if auth && auth.user.present?
          @user = sign_in(:user, auth.user)
          PushNotificationSubscription.subscribe(@user, @user)
          set_curret_user_device_by_parse_id(@user, push_id)
          return @user.ensure_authentication_token!
        else
          if provider == "twitter" && auth.nil?
            return render :status => 400, :json => {:status => :failed, :exist => 1}
          else
            unless check_email.nil?
              check_email.services.create(:provider => provider, :uid => uid, :uname => name)
              @user = sign_in(:user,check_email)
              set_curret_user_device_by_parse_id(@user, push_id)
              PushNotificationSubscription.subscribe(@user, @user)
              return @user.ensure_authentication_token!
              @user.ensure_authentication_token!
            else
              return render :status=>400, :json => {:status => :failed}
            end
          end
        end
      end
    rescue => e
      return render :status => 500, :json => {:status => :failed, error: e.message}
    end
  end

  def forgot_password
    @parsed_json = ActiveSupport::JSON.decode(request.body)
    begin
      user = User.find_by_email(@parsed_json['email'].to_s)
      if !user.nil? && user.is_register == 0
        begin
          User.send_reset_password_instructions({:email => user.email})
          return render :status => 200, :json => {:status => :success}
        rescue
          return render :status => 200, :json => {:status => :success}
        end
      else
        return render :status => 412, :json => {:status => :failed, :error => "The email you entered could not be found. Please try again."}
      end
      # rescue
      #   render :status => 500 ,:json => {:status => :failed}
    end
  end

  def user_point
    location_id = params[:location_id]
    if location_id.blank? || location_id.to_i == 0
      render :json => {:error => "Invalid params"}
      return
    end
    @user_points = UserPoints.find_by_sql(" select sum(p.points) as total_points FROM locations l
                                            left join user_points p on p.location_id=l.id
                                            WHERE p.user_id=1 and p.location_id = #{location_id.to_i}")
    render :json => @user_points
  end
  def addsearchprofile
    begin
      name_search = @parsed_json["name"] if @parsed_json["name"]
      SearchProfile.transaction do
        check = SearchProfile.where("user_id = ?", @user.id)
        for i in check
          if i.name == name_search
            return render :status => 404 , :json => {:status=>:failed, :error => "MySearch Profile Name is already existing"}
          end
        end
        @profile = SearchProfile.new
        if @parsed_json["restaurant_rating_min"] && @parsed_json["restaurant_rating_max"]
          @profile.location_rating = "#{@parsed_json["restaurant_rating_min"]},#{@parsed_json["restaurant_rating_max"]}"
        end
        if @parsed_json["item_price_min"] && @parsed_json["item_price_max"]
          @profile.item_price = "#{@parsed_json["item_price_min"]},#{@parsed_json["item_price_max"]}"
        end
        if @parsed_json["point_offered_min"] && @parsed_json["point_offered_max"]
          @profile.item_reward = "#{@parsed_json["point_offered_min"]},#{@parsed_json["point_offered_max"]}"
        end
        if  @parsed_json["item_rating_min"] && @parsed_json["item_rating_max"]
          @profile.item_rating =  "#{@parsed_json["item_rating_min"]},#{@parsed_json["item_rating_max"]}"
        end
        if @parsed_json["server_rating_min"] && @parsed_json["server_rating_max"]
          @profile.server_rating = "#{@parsed_json["server_rating_min"]},#{@parsed_json["server_rating_max"]}"
        end
        @profile.radius = @parsed_json["radius"] if @parsed_json["radius"]
        item_type =@parsed_json["item_type"] if @parsed_json["item_type"]
        @profile.item_type = item_type.map(&:inspect).join(', ').gsub(/\s+/, "")

        menu_type = @parsed_json["menu_type"] if @parsed_json["menu_type"]
        @profile.menu_type = menu_type.map(&:inspect).join(', ').gsub(/\s+/, "")

        text =@parsed_json["keyword"] if @parsed_json["keyword"]
        @profile.text = text #.gsub(/\s+/, "")

        if @parsed_json["isdefault"] == 1
          current_search_profiles = SearchProfile.where("user_id = ? and isdefault = ?", @user.id, 1)
          current_search_profiles.update_all(:isdefault => 0) unless current_search_profiles.empty?
        end
        @profile.isdefault = @parsed_json["isdefault"]
        @profile.name = name_search
        @profile.user_id = @user.id
        @profile.save!
        render :status => 200, :json => {:status => :success}
      end
    rescue
      render :status=> 500, :json=> {:status=>:failed}
    end
  end
  def deletesearchprofile
    begin
      @parsed_json["search_profile_id"] ? profile_id = @parsed_json["search_profile_id"].to_i : nil
      if profile_id == 0 || profile_id.nil?
        return render :status => 412, :json => {:error => "Invalid params"}
      end
      SearchProfile.transaction do
        @profile = SearchProfile.find_by_id(profile_id)
        @profile.destroy if @profile
        render :status => 200, :json => {:status => :success}
      end
    rescue
      render :status => 500, :json => {:status => :failed}
    end
  end
  def editsearchprofile
    begin
      @parsed_json["search_profile_id"] ? profile_id = @parsed_json["search_profile_id"].to_i : nil
      @profile = SearchProfile.find_by_id(profile_id)
      if @profile.nil?
        return render :status => 404, :json => {:status => :failed, :error => "Invalid Search Profile"}
      end
      search_profiles = SearchProfile.where("user_id = ? and id not in (?)", @user.id, profile_id)
      search_profiles.each do |i|
        if i.name == @parsed_json["name"]
          return render :status => 404, :json => {:status => :failed, :error => "MySearch Profile Name is already existing"}
        end
      end
      if @profile
        if @parsed_json["restaurant_rating_min"] && @parsed_json["restaurant_rating_max"]
          @profile.location_rating = "#{@parsed_json["restaurant_rating_min"]},#{@parsed_json["restaurant_rating_max"]}"
        end
        if @parsed_json["item_price_min"] && @parsed_json["item_price_max"]
          @profile.item_price = "#{@parsed_json["item_price_min"]},#{@parsed_json["item_price_max"]}"
        end
        if @parsed_json["point_offered_min"] && @parsed_json["point_offered_max"]
          @profile.item_reward = "#{@parsed_json["point_offered_min"]},#{@parsed_json["point_offered_max"]}"
        end
        if  @parsed_json["item_rating_min"] && @parsed_json["item_rating_max"]
          @profile.item_rating =  "#{@parsed_json["item_rating_min"]},#{@parsed_json["item_rating_max"]}"
        end
        if @parsed_json["server_rating_min"] && @parsed_json["server_rating_max"]
          @profile.server_rating = "#{@parsed_json["server_rating_min"]},#{@parsed_json["server_rating_max"]}"
        end
        @profile.radius = @parsed_json["radius"] if @parsed_json["radius"]
        item_type =@parsed_json["item_type"] if @parsed_json["item_type"]
        @profile.item_type = item_type.map(&:inspect).join(', ').gsub(/\s+/, "")

        menu_type = @parsed_json["menu_type"] if @parsed_json["menu_type"]
        @profile.menu_type = menu_type.map(&:inspect).join(', ').gsub(/\s+/, "")

        @profile.text = @parsed_json["keyword"] if @parsed_json["keyword"]
        @profile.name = @parsed_json["name"] if @parsed_json["name"]
        @profile.save!
        return render :status => 200, :json => {:status => :success}
      end
    rescue
      return render :status => 500, :json => {:status => :failed}
    end
  end
  def searchprofile
    @profile = SearchProfile.where("user_id = '?'",@user.id)
    if !@profile
      render :status => 404, :json => {:error => "Resource not found"}
    end
  end
  def searchfriend
    params["name"] ? name = params["name"] : ""
    limit = params["limit"]
    offset = params["offset"]
    @friend = User.search_friend(name,@user,limit,offset)
  end


  def getsearchprofile
    profile_id = params[:search_profile_id]
    @profile = SearchProfile.where("id = ?",profile_id).first
    if !@profile
      render :status => 404, :json => {:error => "Resource not found"}
    end
  end

  def set_default
    id = @parsed_json["search_profile_id"].to_i if @parsed_json["search_profile_id"]
    @profile = SearchProfile.find_by_id(id)
    if @profile.nil?
      return render :status =>404, :json => {:status => :failed, :error=>"Invalid search profile"}
    end
    if @profile.isdefault == 1
      return render :status => 400, :json => {:status => :failed, :messages => "This profile was default"}
    end
    SearchProfile.transaction do
      begin
        @profile.update_attributes(:isdefault => 1)
        SearchProfile.where('id <> ? and user_id = ?',id, @user.id).update_all(:isdefault => 0)
        return render :status => 200, :json => {:status => :success}
      rescue
        return render :status => 503, :json => {:status => :failed}
      end
    end
  end

  def mymenu_feedback
    rating = @parsed_json["rating"] if @parsed_json["rating"]
    comment = @parsed_json["comment"] if @parsed_json["comment"]
    ActiveRecord::Base.transaction do
      begin
        UserMailer.feedback(@user.username, @user.email, convert_rating_score(rating.to_i), comment).deliver
        return render :status => 200, :json => {:status => :success}
      rescue
        return render :status => 503 ,:json => {:status => :failed, :error => "Service Unavailable"}
      end
    end
  end

  def mymenu_feedback_v1
    subjects = ["", "Compliment", "Complaint", "Suggestion", "Question/Concern"]
    @parsed_json["subject"] ? subject = @parsed_json["subject"].to_i : 0
    comment = @parsed_json["comment"] if @parsed_json["comment"]
    @feedback = Feedback.new
    @feedback.user_id = @user.id
    @feedback.subject = subjects[subject]
    @feedback.comment = comment
    ActiveRecord::Base.transaction do
      begin
        @feedback.save!
        UserMailer.feedback_v1(@user.username, @user.email, subjects[subject], comment).deliver
        return render :status => 200, :json => {:status => :success}
      rescue
        return render :status => 503 ,:json => {:status => :failed, :error => "Service Unavailable"}
      end
    end
  end

  def recent_searches
    params[:type] ? type = params[:type].to_s.strip : ""
    @search = UserRecentSearch.get_recent_searches(@user.id, type)
  end

  # GET or PUT /users/checkin
  # TODO: This should be split into separate methods: "GET users/1/checkins" and "POST /users/1/checkins"
  def checkin
    # Set the User variable
    user = User.find_by_authentication_token(params[:access_token])
    return invalid_user if !user

    # Handle the request based on the type (GET or PUT)
    if params[:locationID].blank? && request.method == "GET"
      checkins = Checkin.recent_checkin_locations_for(user)
      return render json: {
        :success => true,
        :authentication_token => user.authentication_token,
        :checkins => checkins,
      }, status: 201

    elsif request.method == "PUT"
      location = Location.find_by_id(params[:locationID])
      return invalid_location if location.blank?

      # Do not allow repeat checkins
      if user.is_checked_in_at?(location)
        return render status: 500, json: { success: false, message: "You're already checked in there!" }
      end

      # Check the User in at this Location
      checkin = user.checkin_at(location)

      # Add this user to this Location's contact list
      CustomersLocations.add_contact([user.id], location.id)

      return render json: {
        :success => true,
        :authentication_token => user.authentication_token,
        :numberOfCheckin => user.checkins.location_checkin(location.try(:id)).count,
        :points => checkin.points,
        :location_logo => location.try(:logo).try(:fullpath),
        :last_checkin_date => location.try(:checkins).try(:last).try(:updated_at)
      }, status: 201

    else
      return invalid_user
    end
  end

  def invalid_push_id
    render status: 412, json: { status: :failed, error: "A valid push_id parameter is required." }
  end

  def invalid_login_attempt
    warden.custom_failure!
    render :status => 412, :json => { :status => :failed, :error => "Invalid email or password." },  :success => false
  end

  def invalid_user
    render json: {
      success: false,
      message: "Not authorize to access the resource"
    }, status: 401
  end

  def invalid_location
    render json: {
      success: false,
      message: "Invalid location"
    }, status: 422
  end

  # POST /users/register_v1
  # User account creation. (Deprecated the 'register' method.)
  def register_v1
    begin
      ActiveRecord::Base.transaction do
        # Set variables
        @user = User.new(params[:user])
        @user.role = USER_ROLE

        # Attempt to geocode the User's location
        geo_obj = Geocoder.search(@user.zip).first
        if !geo_obj.nil?
          @user.state = geo_obj.state if geo_obj.state
          @user.city = geo_obj.city if geo_obj.city
        end

        # Save the new user record
        begin
          rs = @user.save
        rescue
          return render :status => 412, :json=> {:status=>:failed, :errors=> @user.errors.inspect }.to_json
        end

        # Automatically sign in
        if rs
          @user = sign_in(:user, @user)
          set_curret_user_device_by_parse_id(@user, params[:push_id])
          @user.ensure_authentication_token!
          begin
            UserMailer.custom_send_email(@user.email,SIGNUP_SUCCESS_SUBJECT,SIGNUP_SUCCESS_BODY).deliver
          rescue
            logger.info "Could not send mail to user"
          end

          return render :status => 200, :json => {
            :status => :success,
            :id => @user.id,
            :access_token => @user.access_token,
            :city => @user.city ||= '',
            :state => @user.state ||= '',
            :points => @user.points,
            :dinner_status => @user.dinner_status
          }
        else
          return render :status => 412,:json => {:status =>:failed,:errors => @user.errors.messages}.to_json
        end
      end
    # rescue
    #   return render :status => 500,:json => {:status =>:failed}
    end
  end

  def batch_delete
    params[:items_to_delete].each do |user_id|
      User.find(user_id).destroy
    end
    render json: {}, status: :ok
  end


  private

    def set_curret_user_device_by_parse_id(user, parse_installation_id)
      # Identify the Device and change its settings as necessary.

      # Check if we already have this installation ID in our database
      @device = Device.find_by_parse_installation_id(parse_installation_id)
      if @device.present?
        # If applicable, update the Device settings
        @device.set_owner_as(user) if !@device.owner_is?(user) # Updates Parse channel subscriptions

        return true

      elsif Device.parse_installation_exists_with_object_id?(parse_installation_id)
        # We don't yet have a record for this Device, so we need to create one.

        # First, make sure the user doesn't have an existing Device record
        user.device.destroy if user.device.present?

        # Note: Creating a Device automatically sets it as the user's current device.
        @device = user.create_device(parse_installation_id: parse_installation_id) if parse_installation_id.present?
        return false if !@device

        return true

      else # the parse_installation_id value is unknown to Parse
        return false
      end

    end

    def upload_user_avatar(current_user, image)
      begin
        Cloudinary::Uploader.upload(image,
                                    folder: "users/#{current_user.id}",
                                    public_id: "user_#{current_user.id}_avatar",
                                    overwrite: true)
      rescue => e
      end
    end
    
    def create_or_update_avatar(object, photo_hash)
      photo_attributes = {
        public_id: photo_hash["public_id"],
        format: photo_hash["format"],
        version: photo_hash["version"],
        width: photo_hash["width"],
        height: photo_hash["height"],
        resource_type: photo_hash["resource_type"]
      }
      if object.avatar.present?
        object.avatar.update_attributes(photo_attributes)
      else
        object.create_avatar(photo_attributes)
      end
    end
end
