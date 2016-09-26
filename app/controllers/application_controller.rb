require "base64"
require 'fastimage'

class ApplicationController < ActionController::Base

  #############################
  ###  GENERAL CONFIG
  #############################
  protect_from_forgery
  layout :layout_by_resource


  #############################
  ###  FILTERS
  #############################
  before_filter :set_cache_buster
  before_bugsnag_notify :add_user_info_to_bugsnag


  def not_found
    respond_to do |format|
       format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
       format.json {render json: {:status => :not_found } }
    end
  end

  #############################
  ###  EXCEPTION RESCUING
  #############################
  rescue_from ActionController::RoutingError, ActionController::UnknownController,
    ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound,
    AbstractController::ActionNotFound, with: :not_found # To prevent Rails 3.2.8 deprecation warnings

  rescue_from CanCan::AccessDenied do |exception|
    if request.format == :json
      return render :status=>401,:json=>{:status => :failed, :error=>"Invalid Auth key"}
    end
    alert = exception.message
    if !current_user.nil?
      if current_user.user?
        alert = 'BYTE users do not have access to the Restaurant Portal. If you have BYTE Restaurant login please use that account to login'
        sign_out current_user
      end
      redirect_to root_url, :alert => alert
    else
      alert = 'You need to sign in or sign up before continuing.'
      sign_out current_user
      redirect_to root_url, :alert => alert
    end
  end


  #############################
  ###  METHODS
  #############################

  def not_found
    respond_to do |format|
       format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
    end
  end

  def exception_layout(e, errcode = 404)
    respond_to do |format|
       format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
    end
  end


  private
    #  # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      "http://mybyteapp.com/"
    end

    def set_cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "0"
    end

    def oauth_client_url(user_id)
      @auth_client_obj ||= OAuth2::Client.new(ENV["CLIENT_ID"], ENV["CLIENT_SECRET"], {:site => 'https://accounts.google.com',
                                                                                       :authorize_url => "/o/oauth2/auth", :token_url => "/o/oauth2/token"})

      # Find old access_token and refresh_token
      # If access_token was expired, It would use refresh_token to get new access_token
      user = User.find(user_id)
      session[:gg_user_id] = user_id
      if user.owner? || user.admin?
        if user.gg_access_token.nil? || user.time_request.nil?
          scope = ENV['API_SCOPE']
          scope = scope + ' ' + ENV['ADMIN_SDK_SCOPE'] if user.admin?
          return @auth_client_obj.auth_code.authorize_url(:scope => scope, :access_type => "offline",
            :redirect_uri => ENV['REDIRECT_URL'], :approval_prompt => 'force')
        end
      end
      false
    end

    def oauth_refresh_token(user_id)
      user = User.find(user_id)
      now = Time.now
      if user.owner? || user.admin?
        if !user.time_request.nil? && (now - user.time_request) > ENV['REFRESH_TIME']
          refresh_access_token_obj = OAuth2::AccessToken.new(@auth_client_obj, user.gg_access_token, {refresh_token: user.gg_refresh_token})
          new_token = refresh_access_token_obj.refresh!
          # update token to user
          user.gg_access_token = new_token.token
          user.gg_refresh_token = new_token.refresh_token
          user.time_request = Time.now
          user.save(:validate => false)
        end
      end
    end

    def oauth2callback
      user = User.find(session[:gg_user_id])
      begin
        access_token_obj = @auth_client_obj.auth_code.get_token(params[:code], { :redirect_uri => ENV['REDIRECT_URI'], :token_method => :post })
      rescue
        sign_out user
        return redirect_to new_user_session_path
      end

      uri = URI.parse("https://www.googleapis.com/oauth2/v2/userinfo")
      headers = {
        "Authorization" => "Bearer #{access_token_obj.token}"
      }
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      http.start

      response = http.request_get(uri.request_uri, headers)
      email = JSON.parse(response.body)['email']

      #puts "@ email", email

      session[:gg_user_id] = nil
      #puts "@ user", user.inspect
      if user.email == email

        # Save access toke to DB
        if user.owner? || user.admin?
          user.gg_access_token = access_token_obj.token
          user.gg_refresh_token = access_token_obj.refresh_token
          user.time_request = Time.now
          user.save(:validate => false)
        end
        redirect_to after_sign_in_path_for(user)
      else
        sign_out user
        redirect_to new_user_session_path, :alert => "You must use the email that registered on BYTE.
  Please log out current account: #{email} on Google and try again!"
      end
    end

    def save_to_admin_contact(user, *title_groups)
      admin_account = User.find_by_email(ENV['MYMENU_ADMIN_EMAIL'])
      save_contact_to(admin_account.id, user, *title_groups)
    end

    def save_contact_to(owner_id, user, *title_groups)
      begin
        # Refresh token if access token is expired
        unless oauth_client_url(owner_id)
          oauth_refresh_token(owner_id)
        end
        # Add Contact
        unless user.new_contact?(owner_id)
          # Update contact
          user_contact = UserContact.find_by_user_id_and_location_owner_id(user.id, owner_id)
          begin
            element = api_client(owner_id).update!(user.to_element(owner_id, *title_groups))
            if element
              user_contact = UserContact.find_by_user_id_and_location_owner_id(user.id, owner_id)
              user_contact.update_attribute(:etag, element.etag)
            end
            return element
          rescue
            user_contact.destroy
          end
        end

        user_contact = UserContact.find_or_create_by_user_id_and_location_owner_id(
        user_id: user.id,
        location_owner_id: owner_id
      )
        element = api_client(owner_id).create!(user.to_element(owner_id, *title_groups))
        if element
          user_contact.update_attributes(
            :etag => element.etag,
            :gg_contact_id => element.id.split('/').last
          )
          # user_contact.save
        end
        return element

      rescue => e
        logger.error("Can not save #{user.username}'s information to (ID: #{owner_id})'s contact. #{e.message}")
        return nil
      end
      return element
    rescue => e
      logger.error("Can not save #{user.username}'s information to (ID: #{owner_id})'s contact. #{e.message}")
      return nil
    end

    def save_contact(location, user, *title_groups)
      location_owner_ids = [location.id]
      unless location.rsr_manager.nil?
        user_ids = location.rsr_manager.split(',')
        location_owner_ids += user_ids
      end

      location_owner_ids.each do |owner_id|
        save_contact_to(owner_id, user, *title_groups)
      end
    end

    def add_all_contact_groups(location_owner_id, is_admin=false)
      # Create All Groups of Owner's contact
      begin
        if is_admin
          groups = [RESTAURANT_GROUP, DINER_GROUP]
        else
          groups = [RATE_GROUP, FAVORITE_GROUP, SHARE_MENU_ITEMS_GROUP, SHARE_RESTAURANT_POINTS_GROUP,
              ORDER_GROUP, PAY_GROUP, ACCEPT_POINTS_GROUP]
        end
        groups_created = []
        groups.each do |group_title|
          group = ContactGroup.find_by_title(group_title)
          if !group.nil? && group.new_group?(location_owner_id)
            el = group.to_element
            el.modifier_flag = :create
            groups_created << el
          end
        end

        els = api_client(location_owner_id).batch!(groups_created, {:api_type => :groups})

        # Save to db
        els.each do |el|
          g = ContactGroup.find_by_title(el.title)
          if g
            g.location_contact_groups.build(
              :gg_contact_group_id => el.id,
              :location_owner_id => location_owner_id
            )
            g.save
          end
        end

      rescue => e
        logger.error("Can not create groups for (ID: #{location_owner_id})'s contact. #{e.message}")
      end
    rescue => e
      logger.error("Can not create groups for (ID: #{location_owner_id})'s contact. #{e.message}")
    end

    def api_client(user_id)
      user = User.find(user_id)
      return GContacts::Client.new({access_token: user.gg_access_token})
    end

    # def delete_contact(location_owner_id, user)
    #   if !user.nil? && !user.new_contact?(location_owner_id)
    #     rs = api_client(location_owner_id).delete!(user.to_element)
    #     if rs
    #       user.gg_contact_id = user.etag = nil
    #       user.save(:validate => false)
    #     end
    #   end
    # end

    def current_user_ws
      return User.find_by_authentication_token(params[:access_token])
    end

    def authed_user
      @user
    end

    def current_ability # This modifies the CanCan defaults
      if request.format == :json
        @current_ability ||= Ability.new(current_user_ws)
      else
        @current_ability ||= Ability.new(current_user)
      end
    end

    def authorise_request_as_json
      if request.format.symbol != :json # This requires an 'Accept' header set to 'application/json'
        return render status: 406, json: {message: "The request must be json, but is #{request.format.symbol.inspect}"}
      end
    end

    def authenticate_user_json # TODO: This is a duplicate of authorise_user_param
      @parsed_json = ActiveSupport::JSON.decode(params.to_json)
      begin
        if @parsed_json["access_token"].blank?
          render :status=>401,:json=>{:status => :failed, :error=>"No access token passed"}
          return
        end
        @user = User.find_by_authentication_token(@parsed_json["access_token"])
        unless @user.nil?

        else
          unless @parsed_json["access_token"]=="imenuguestaccess"
            render :status=>401,:json=>{:status => :failed, :error=>"Invalid Auth key"}#{:message=>"Invalid Auth key"}
            return
          end
        end

      rescue
        render :status => 401, :json=>{:status => :failed, :error=>"Incorrect Json"}
        return
      end
    end

    def authorise_user_param
      if params[:access_token].blank?
        return render :status=>401,:json=>{:status => :failed, :message=>"No access token passed"}
      end

      if params[:access_token] == "imenuguestaccess" # TODO: Fix this security hole
        return
      end

      @user = User.find_by_authentication_token(params[:access_token])
      if @user.nil?
        return render :status=>401,:json=>{:status => :failed, :error=>"Invalid Auth key"}#{:message=>"Invalid access token"}
      end
    end

    def layout_by_resource
      if devise_controller?
        "imenu"
      else
        "imenu"
      end
    end

    def after_sign_in_path_for(resource_or_scope)
      # if resource_or_scope.is_a?(User)
      #   url = oauth_client_url(resource_or_scope.id)
      #   return url if url
      # end

      # if current_user.owner? || current_user.restaurant_manager?

      #   # Create All Groups of Owner's contact
      #   add_all_contact_groups(current_user.id)
      # end

      # if current_user.owner?
      #   # Add current user's information to Admin contact
      #   # begin
      #   #   save_to_admin_contact(current_user, RESTAURANT_GROUP)
      #   # rescue

      #   # end
      # end

      # if current_user.admin?

      #   # Create All Groups of Admin
      #   add_all_contact_groups(current_user.id, true)
      # end

      if current_user.role? CASHIER_ROLE
        return restaurant_orders_restaurant_order_index_path current_user.employer.slug
      end

      if resource_or_scope.sign_in_count == 1
        return edit_user_registration_path
      end

      return restaurants_path
    end

    def find_by_sql(model, sql, *binds)
      completed_sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, *binds])
      model.find_by_sql(completed_sql)
    end

    def check_exist_email(email)
      user = User.uniq.where('email =?',email).pluck(:id)
      if user.empty?
        return 0
      else
        return user.first
      end
    end

    def check_friend(email, user_id) # TODO: Eliminate this duplicate of 'check_friend_by_email'
      friend = Friendship.where( "friendable_id = ? ", user_id).select("friend_id")
      friend.each do |f|
        user = User.where("id = ? ", f.friend_id).first
        if user
          if (user.email == email)
            return true
          end
        end
      end
      return false
    end

    def check_friend_by_email(email,user_id)
      friend = Friendship.where( "friendable_id = ?",user_id).select("friend_id")
      friend.each do |f|
        user = User.where("id = ? ",f.friend_id).first
        if user
          if (user.email == email)
            return true
          end
        end
      end
      return false
    end

    def check_pending_friend(email,user_id)
      friend = Friendship.where( "friendable_id = ? and pending=0",user_id).select("friend_id")
      friend.each do |f|
        user = User.where("id = ? ",f.friend_id).first
        if user
          if (user.email == email)
            return true
          end
        end
      end
      return false
    end

    def check_friend_by_email1(email,user_id)
      friend = Friendship.where( "friend_id = ?",user_id).select("friendable_id")
      friend.each do |f|
        user = User.where("id = ? ",f.friendable_id).first
        if user
          if (user.email == email)
            return true
          end
        end
      end
      return false
    end

    def check_friend_by_email2(email,user_id)
      friend = Friendship.where( "friend_id = ? and pending != 0",user_id).select("friendable_id")
      friend.each do |f|
        user = User.where("id = ? ",f.friendable_id).first
        if user
          if (user.email == email)
            return true
          end
        end
      end
      return false
    end

    def check_friend_by_email3(email,user_id)
      friend = Friendship.where( "friendable_id = ? and pending != 0",user_id).select("friend_id")
      friend.each do |f|
        user = User.where("id = ? ",f.friend_id).first
        if user
          if (user.email == email)
            return true
          end
        end
      end
      return false
    end

    def check_friend_by_phone(phone,user_id)
      friend = Friendship.where( "friendable_id = ? and pending != 0",user_id).select("friend_id")
      friend.each do |f|
        user = User.where("id = ? ",f.friend_id).first
        if user
          if (user.phone == phone)
            return true
          end
        end
      end
      return false
    end

    def check_friend_by_phone2(phone,user_id)
      friend = Friendship.where( "friend_id = ? and pending != 0",user_id).select("friendable_id")
      friend.each do |f|
        user = User.where("id = ? ",f.friendable_id).first
        if user
          if (user.phone == phone)
            return true
          end
        end
      end
      return false
    end

    def check_exist_phone(phone)
      user = User.uniq.where('phone =?',phone).pluck(:id)
      if user.empty?
        return 0
      else
        return user.first
      end
    end

    def check_exist_accout_level_up(email,password)
      uri = URI.parse('https://api.thelevelup.com/v14/access_tokens')
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true
      req = Net::HTTP::Post.new(uri.path)
      req.add_field('Content-Type', 'application/json')
      req.body = { 'access_token' => {
                     'api_key' => '92eaf95b09cd3309be779690c41c24e595cb7555d576b17d337a8c0bd8996cc5',
                     'username' => "#{email}",
                     'password' => "#{password}"
                   }
                   }.to_json
      res = https.request(req)
      access_token = "#{res.body}"
      code  = "#{res.code}"
      @parsed_json = ActiveSupport::JSON.decode(access_token)
       if code.to_i == 200
         return "#{@parsed_json["access_token"]["token"]}"
       elsif code.to_i == 404
        return  "failed"
       else
         return "failed"
       end
    end

    def convert_rating_score(rating)
      score = ['A+','A','A-','B+','B','B-','C+','C','C-','D+','D','D-','F']
      return score[rating - 1]
    end

    def fix_special_character(c)
      return c.gsub("'","''")
    end

    def sharepoint_msg(sharer,restaurant_name,points)
      return "Congratulations, #{sharer} has shared #{points.to_i} points from #{restaurant_name} with you. Visit #{restaurant_name} to redeem your points.
       #whoshungry"
    end

    def refunded_point_msg(sharer, points,receiver)
      return "Hi #{sharer},You've shared #{points.to_i} points to #{receiver},but they didn't accept, so the points are refunded back to your account.
  Thanks."
    end

    def invite_friend_msg(sender_name)
      return "#{sender_name} would like to add you as a friend! Accept to view their profile and share yours as well!"
    end

    def share_prizes_msg(sharer, prize_name, location_name)
      return "Congratulations, #{sharer} has shared #{prize_name} from #{location_name} with you. Visit #{location_name} in MyPrizes to redeem your prize."
    end

    def get_location(address)
      position = Geocoder.search(address)
      if position.nil? || position.empty?
        return nil
      end
      return position.first
    end

    def reverse_string(keyword)
      return keyword if keyword.blank?
      str = ""
      keyword = keyword.mb_chars.downcase
      keyword = keyword.split(" ")
      keyword.reverse_each { |i| str += "#{i} " }
      return str
    end

    def compare_strings(str1, str2)
      str1 = str1.mb_chars.downcase
      str2 = str2.mb_chars.downcase
      encoded_str1 = Base64.encode64(str1)
      encoded_str2 = Base64.encode64(str2)
      if encoded_str1 == encoded_str2
        return true
      else
        return false
      end
    end

    def add_user_info_to_bugsnag(notif)
      notif.user = {
        email: current_user.email,
        name: current_user.name,
        id: current_user.id
      }

      # Add some app-specific data which will be displayed on a custom
      # "Diagnostics" tab on each error page on bugsnag.com
      # notif.add_tab(:diagnostics, {
      #   product: current_product.name
      # })
    end

    def check_suspended
      if current_user.is_suspended?
        flash[:error] = 'Cannot perfrom operation. Your account is suspended'
        @redirect_url = request.referer || root_url

        respond_to do |format|
          format.html { redirect_to @redirect_url }
          format.js { render 'shared/redirect_current_or_root' }
        end
      end
    end
end
