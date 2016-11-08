class NotificationController < ApplicationController
  require 'net/smtp'
  include NotificationHelper

  # before_filter :authenticate_user!, :except => [:get_global_message, :get_restaurant_message, :get_message, :get_detail_message, :get_unread_by_chain, :delete_message_by_restaurant, :delete_message]
  load_and_authorize_resource class: 'Notifications'
  before_filter :authorise_request_as_json, only: [:get_global_message,
                                                   :get_restaurant_message, :get_message, :get_detail_message, :get_unread_by_chain]
  before_filter :authenticate_user_json, only: [:delete_message_by_restaurant, :delete_message]
  before_filter :authorise_user_param, only: [:get_unread_by_chain, :get_message, :get_detail_message, :get_global_message, :get_restaurant_message]
  skip_before_filter :verify_authenticity_token, :set_cache_buster
  #skip_before_filter :authenticate_user!, only: [:usercommunications]
  respond_to :json

   # rescue_from ActiveRecord::RecordNotFound, :with => :routing_error
   # def routing_error
   #   redirect_to communications_notification_index_path, :alert => "This rating message has been edited by the app user. Please refresh the page"
   #    # respond_to do |format|
   #    #   format.html {redirect_to communications_notification_index_path, :alert => "This rating message has been edited by the app user. Please refresh the page"}
   #    #   format.js
   #    # end
   # end

  def index
  end

  # GET /notification/sendmessage
  # For sending a message to a specific user (the form submits a POST to the 'add' method)
  def sendmessage
    @notification = Notifications.new
    @current_user = User.find(params[:current_user_id])
    @restaurant = Location.find_by_id(params[:restaurant])
    @prizes = StatusPrize.get_location_prizes(@restaurant.id)
  end

  # POST /notifications/add
  # Add rating messages to notification table
  def add
    return redirect_to restaurants_path if !params[:notifications][:location_id]

    points = params[:points].to_i

    # Create the Notification
    @notification = Notifications.new(params[:notifications])
    @notification.from_user        = current_user.id
    @notification.msg_type         = "group"
    @notification.status           =  0
    @notification.alert_logo       = "/assets/rating-alert.png"
    @notification.msg_subject      = RATING_MESSAGE
    if params[:notifications][:alert_type] == 'Restaurant Rating'
      @notification.alert_type = 'Restaurant Rating Reward'
    else
      @notification.alert_type = RATING_ALERT_TYPE
    end
    @notification.to_user          = params[:to_user]
    @notification.points           = points
    @notification.message          = params[:message]
    if @notification.save
      @receiving_users = User.where('email = ?', @notification.to_user)
      @restaurant = Location.find(@notification.location_id)

      # Add points if applicable
      push_notification_already_sent = false
      if @receiving_users.present? && points > 0
        # Note: Creating a UserPoint will automatically send a notification to the user
        add_point_user(@receiving_users.first.id, @notification.location_id, points)
        push_notification_already_sent = true
      end

      # Send a push notification if applicable
      unless push_notification_already_sent
        message = "You have received a message from #{@restaurant.name}"
        PushNotification.dispatch_message_to_resource_subscribers('msg_from_restaurant', message, @receiving_users.first)
      end

      redirect_to communications_restaurant_notification_index_path(@restaurant)
    end

  end #end of add

  # GET /notification/groupmessage
  # Send an email notification to a group of users (optionally with points or a prize attached)
  # TODO: Eliminate 'params' references in the groupmessage view
  def groupmessage
    @restaurant_id = params[:restaurant]
    @restaurant = Location.find_by_id(params[:restaurant])
    return redirect_to restaurants_path if !@restaurant

    @notification = Notifications.new
    user_email_array = []
    user_arr = []
    user_ids_string = params[:user_contact]
    unless user_ids_string.nil?
      user_ids_array = user_ids_string.split(',')
      unless user_ids_array.empty?
        user_email_array = User.where("id IN (?)", user_ids_array).pluck(:email)
      end
    end
    @user_email = user_email_array

    #add customer contact user
    @group = Group.where("location_id = ?", @restaurant_id)
    @customer = GroupUser.get_all_list_customers(@restaurant_id, current_user.id)
    customer_contact = []
    unless @customer.empty?
      @customer.each do |cus|
        customer_location = CustomersLocations.find_by_user_id(cus.id)
        if !customer_location.nil?
          unless customer_location.is_deleted.nil?
            if  customer_location.is_deleted == 2
              customer_contact << cus
            end
          end
        end
      end
      @customer = @customer - customer_contact
      @customer = @customer.sort { |x,y| y.created_at <=> x.created_at}
    end
    #end contact user

    # Get an array of this Location's Prizes (OLD CODES BEFORE REWARD 3.0)
    # @prizes = []
    # status_prize_ids = StatusPrize.where(location_id: @restaurant.id).pluck(:id)
    # unless status_prize_ids.empty?
    #   @prizes = Prize.joins(:status_prize).
    #     where('status_prize_id IN (?)', status_prize_ids).where(is_delete: false).
    #     order('status_prizes.name')
    # end

    # NEW CODE FOR REWARD 3.0
    @prizes = @restaurant.rewards
  end #end of groupmessage

  # POST /notification/addgroup  (Receives posts from the groupmessage action)
  def addgroup # TODO: Refactor this method
    return redirect_to restaurants_path if !params[:notifications][:location_id]

    # Set required variables
    location_id = params[:notifications][:location_id]
    alert_type = params[:notifications][:alert_type]
    points = (params[:points].present? ? params[:points].to_i : nil) # TODO: Why isn't this in the [:notifications] array?
    prize_id = (params[:notifications][:point_prize].present? ? params[:notifications][:point_prize].to_i : nil)

    # Determine if the email addresses are valid
    # NOTE: Emails should only be delimited by commas, not both commas and semicolons. (Semicolon syntax is in JS files as well)
    email_array = params[:user_emails].to_s.split(';')
    email_string = email_array.join(',')
    email_array = email_string.split(',').map(&:strip)
    email_array.uniq!
    valid_email_array = []
    invalid_email_array = []
    valid_username_array = []
    invalid_username_array = []
    email_array.each do |email|
      if is_a_valid_email?(email) #check if has a form or an email
        valid_email_array << email
      else
        valid_username_array << email
      end
    end
    group_users = User.search_by_emails_except(valid_email_array, current_user.id)
    valid_email_list = group_users.collect { |e| e.email  } #Emails that actually has registered users
    invalid_email_array = valid_email_array - valid_email_list
    group_users2 = User.search_by_usernames_except(valid_username_array, current_user.id)
    valid_username_list = group_users2.collect { |e| e.username } #Usernames that actually has registered users
    invalid_username_array = valid_username_array - valid_username_list

    group_users = group_users | group_users2


    # Set supplemental variables and possibly refine group_users
    case alert_type
    when DIRECT_ALERT_TYPE

      # Set additional variables
      message_type = "single"
      alert_logo= "/assets/direct-message.png"
      subject = DIRECT_MESSAGE

    when GENERAL_ALERT_TYPE

      # Set additional variables
      message_type = "single"
      alert_logo= "/assets/general-message.png"
      subject = GENERAL_MESSAGE

      # Redefine the 'group_users' variable
      group_users = GroupUser.get_all_list_customers(location_id, current_user.id)
      customer_contact_array = []
      group_users.each do |customer|
        customer_location = CustomersLocations.find_by_user_id(customer.id)
        if customer_location.present? && customer_location.is_deleted == 2
          #remove customer is delete
          customer_contact_array << customer
        end
      end
      group_users = group_users - customer_contact_array

    when RATING_ALERT_TYPE

      # Set additional variables
      message_type = "group"
      alert_logo = "/assets/rating-alert.png"
      subject = RATING_MESSAGE

      # Reduce the group_users to only those who have rated
      users_rated = GroupUser.get_user_rated(location_id, current_user)
      reduced_group_users = []
      unless group_users.empty? && users_rated.empty?
        group_users.each do |user|
          if users_rated.include?(user)
            reduced_group_users << user
          end
        end
      end
      group_users = reduced_group_users

      #add point to point user
      if points.present?
        group_users.each do |user|
          add_point_user(user.id, location_id, points) # Will send push notification
        end
      end

    when POINTS_ALERT_TYPE

      # Set additional variables
      message_type = "group"
      alert_logo = "/assets/reward-alert.png"
      subject = POINTS_MESSAGE

      #add point to point user
      if points.present?
        group_users.each do |user|
          add_point_user(user.id, location_id, points) # Will send push notification
        end
      end

    end # end of case statement

    # If there are no users
    if group_users.empty?
      flash[:warning] = "There are no users to send to!"
      return redirect_to groupmessage_notification_index_path(restaurant: params[:notifications][:location_id], alert: params[:alert])
    end

    #add point prize to prize
    if prize_id.present?
      group_users.each do |user|
        add_prize_user(prize_id, current_user.id, user.id, location_id) # Will send push notification
      end
    end

    # Send notification (and possibly push notification) to each user in the group
    @restaurant = Location.find(location_id)
    group_email_array = []
    group_users.each do |user|
      if user.kind_of?(User)
        group_email_array << user.email
      else
        group_email_array << user.fetch(:email)
      end
    end
    group_email_string = group_email_array.join(", ")

    group_users.each do |user|

      notification = Notifications.new(params[:notifications])
      notification.from_user       = current_user.id
      notification.msg_type        = message_type
      notification.to_user         = user.email
      notification.alert_type      = alert_type
      notification.msg_subject     = subject
      notification.points          = points.to_i
      notification.alert_logo      = alert_logo
      notification.msg_subject     = subject
      notification.group_emails    = group_email_string
      notification.point_prize     = prize_id
      notification.save
      notification.update_attribute(:reply, notification.id)

      # Send a push notification
      # NOTE: Point and prize push notifications will be sent automatically by model callbacks.
      if [DIRECT_ALERT_TYPE, GENERAL_ALERT_TYPE].include?(alert_type)
        message = "You have received a message from #{@restaurant.name}"
        PushNotification.dispatch_message_to_resource_subscribers('msg_from_restaurant', message, user)
      end
    end

    # Redirect as appropriate
    unless invalid_email_array.empty? && invalid_username_array.empty?
      flash[:warning] = "Message has been sent. However, the following email addresses or usernames are invalid and will not receive the message:"
      (invalid_email_array + invalid_username_array).each do |email|
        flash[:warning] << "<li style='margin-left:12px'>#{email} </li>"
      end
      redirect_to communications_restaurant_notification_index_path(@restaurant)
    else
      unless alert_type == RATING_ALERT_TYPE
        redirect_to communications_restaurant_notification_index_path(@restaurant), :notice => 'Message has been sent'
      else
        if params[:myorders]
          redirect_to restaurant_orders_restaurant_order_index_path(@restaurant), :notice => 'Message has been sent'
        else
          redirect_to communications_restaurant_notification_index_path(@restaurant), :notice => 'Message has been sent to diners who have rated the restaurant menu items'
        end
      end
    end
  end

  def send_to_restaurant_itself(notification,location)
      manager_ids = []
      from = User.find(notification.from_user)
      to = User.find_by_email(notification.to_user)
      manager_ids = location.rsr_manager.strip.split(",").map{|x| x.strip()}
      return  location.id == notification.location_id && (from.email == to.email || location.owner_id == to.id || manager_ids.include?(to.id))
  end

  def deletenotification
    id = params[:id]
    location_id = params[:resturant]
    current_restaurant_id = params[:current_restaurant_id]
    location = Location.find(location_id)
    notification = Notifications.find(id)
    from_user = User.find(notification.from_user)
    related_notifications = Notifications.where('from_user = ? AND msg_type = ?
                             AND alert_type = ? AND location_id = ?
                             AND msg_subject = ? AND created_at = ? AND group_emails = ?',
                             notification.from_user,notification.msg_type,
                             notification.alert_type, notification.location_id,
                             notification.msg_subject,notification.created_at,notification.group_emails )
    related_notifications.each do |noti|
      from_user_in_related = User.find(noti.from_user)
      if current_user.id == location.owner_id && params[:is_mycommunication] == "true"
          noti.update_attribute(:is_delete_by_admin, true)
      else
        if noti.sent?(current_user, location) && (current_restaurant_id.to_i == noti.location_id)
            noti.update_attribute(:is_delete_from_user, true)
        end
        if noti.received?(current_user, location) && ((current_restaurant_id.to_i != noti.location_id) || from_user_in_related.user?) || send_to_restaurant_itself(noti,location)
            noti.update_attribute(:is_delete_to_user, true)
        end
      end
    end
    if current_user.id == location.owner_id && params[:is_mycommunication] == "true" || current_user.admin? && params[:is_mycommunication] == "true"
       notification.update_attribute(:is_delete_by_admin, true)
    else
      if notification.sent?(current_user, location) && (current_restaurant_id.to_i == notification.location_id)
        notification.update_attribute(:is_delete_from_user, true)
      end
      if notification.received?(current_user, location) && ((current_restaurant_id.to_i != notification.location_id) || from_user.user?) || send_to_restaurant_itself(notification,location)
        notification.update_attribute(:is_delete_to_user, true)
      end
    end


    if params[:is_mycommunication] == "true"
      return redirect_to communications_notification_index_path(),
          :notice => 'The message is deleted successfully'
    end
    return redirect_to communications_restaurant_notification_index_path(location),
        :notice => 'The message is deleted successfully'

  end #end of deletenotification

  def search
    if request.post?
        parsed_json = ActiveSupport::JSON.decode(request.body)
        search  = parsed_json['search']
        user_id = parsed_json['user_id']
    end
    if request.get?
        search  = params[:search]
        user_id = params[:user_id]
    end

    @search_result = Notifications.search_notification(search,user_id)
    if @search_result.blank?
      render :text => "No Notifications"
    end
  end

  # GET /notification/communications
  # POST /notification/communications
  # GET /restaurants/:restaurant_id/notification/communications
  # POST /restaurants/:restaurant_id/notification/communications
  def communications
    @check = false
    @is_mycommunication = false
    location_ids = []
    @search_params = ''
    user = {}

    if current_user.admin?
      user['id'] = current_user.id
      user['email'] = current_user.email
      user['restaurants'] = Location.all
    else
      if current_user.has_parent?
        parent = current_user.parent_user
        user['id'] = parent.id
        user['email'] = parent.email
        if current_user.restaurant_admin?
          user['restaurants'] = Location.where_by_rsr_admin(current_user.id)
        elsif current_user.restaurant_manager?
          user['restaurants'] = Location.where_by_rsr_manager(current_user.id)
        end
      else
        user['id'] = current_user.id
        user['restaurants'] = current_user.restaurants
        unless current_user.unlimit?
          if current_user.app_service.limit > 0
            user['restaurants'] = user['restaurants'][0...current_user.app_service.limit]
          else
            user['restaurants'] = user['restaurants'][0..current_user.app_service.limit]
          end
        end
        user['email'] = current_user.email
      end
    end

    # communications
    if params[:restaurant_id]
      @restaurant = Location.find(params[:restaurant_id])
      unless @restaurant.nil?
        owner_id = @restaurant.owner_id
        if current_user.id.to_i == owner_id.to_i || current_user.admin?
          @check = true
        end
      end

      unless @restaurant.nil?
        @current_restaurant = @restaurant.id
      end
      authorize! :read, @restaurant
      location_ids << @restaurant.id
    else # mycommunications
      @is_mycommunication = true
      if !current_user.admin?
        user['restaurants'].each do |location|
          location_ids << location.id
        end
        if location_ids.length == 1 && current_user.restaurant_manager?
          @current_restaurant = location_ids.first
        end
      else #if user is admin
        user['restaurants'].each do |location|
          location_ids << location.id
        end

      end
    end

    # Search communications
    if params[:search]
      @search_params = params[:search]
      @notifications = Notifications.search_user_notifications(current_user, location_ids, user['email'], user['id'],
        @search_params,@is_mycommunication).page(params[:page]).per(10)
    else
      @notifications = Notifications.get_user_notifications(current_user, location_ids,
        user['email'], user['id'], @is_mycommunication).page(params[:page]).per(10)
    end

    if @check == false && !current_user.admin? && !@is_mycommunication
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/restaurant", :layout => false }
      end
    end

  end

  def usercommunications
    @restaurant_current = Location.find(params[:restaurant_id])
    @notification = Notifications.find(params[:id])
  end

  def usercommunicationsrating
    @restaurant_current = Location.find(params[:restaurant_id])
    @notification = Notifications.find(params[:id])
  end

  #Get global message
  def get_global_message
    location_id = params[:location_id].present? ? params[:location_id] : 0;
    @restaurant = Location.get_global_message(@user.email, location_id.to_i)
  end

  #Get message of restaurant
  def get_restaurant_message
    chain_name = fix_special_character(params[:chain_name])
    if chain_name
      @restaurant = Location.get_message_by_chain(chain_name, @user.email)
    else
      render :status => 412, :json => {:status=> :failed, :error => "chain_name is required"}
    end
  end
  #Get messages
  def get_message
    #Get parameters
    location_id = params[:location_id]
    if location_id == "" || location_id.nil?
      render :status => 404, :json => {:status=>:failed, :error => "location_id is required"}
    else
      @restaurant = Notifications.get_message_location(location_id.to_i,@user.email)
    end
  end

  #Get detail message
  def get_detail_message
    message = Notifications.find_by_id(params[:message_id])
    unless message.nil?
      ActiveRecord::Base.transaction do
        unless message.update_attributes(:received=> 1, :status=>1,:is_openms=>1)
                render :status => 503, :json=> {:status=>:failed}
        end
      end#end transaction
      @detail_message = Notifications.get_detail_message(message.id)
    end
    #end
  end

  #List unread message by chain
  def get_unread_by_chain
    chain_name = fix_special_character(params[:chain_name])
    if chain_name=='' || chain_name.nil?
      render :status=>412, :json=>{:status=>:failed, :error=>"Chain name is require"}
      return
    else
      @messages = Notifications.get_unread_message_by_chain(chain_name, @user.email)
    end
  end

  #Delete notification by restaurant
  def delete_message_by_restaurant
    root_id = @parsed_json["message_id"] if @parsed_json["message_id"]
    check = Notifications.where("id=?", root_id.to_i).first
    if check.nil?
      render :status=>412, :json=>{:status=>:failed, :error=>"Not exist this message"}
    else
      sql ="notifications.alert_type != 'Publish Menu Notification' AND notifications.id=? OR notifications.reply=?"
      notifications = Notifications.where(sql, root_id.to_i,root_id.to_i)
      for i in notifications
        i.update_attributes(:is_show=>0, :is_show_detail=>0)
      end
      render :status=>200, :json=>{:status=>:success}
    end
  end

  #Delete a notification
  def delete_message
    message_id = @parsed_json["message_id"] if @parsed_json["message_id"]
    notification = Notifications.where("id=?", message_id.to_i).first
    count = Notifications.where("reply = ?", notification.id).count
    if notification.nil?
      render :status=>412, :json=>{:status=>:failed, :error=>"Not exist this message"}
    else
      if ((notification.reply == 0 || notification.reply == notification.id) && count == 0)
        notification.update_attributes(:is_show => 0, :is_show_detail => 0)
      else
        notification.update_attribute(:is_show_detail, 0)
        notification.reply == 0 ? root_message_id = notification.id : root_message_id=notification.reply
        msg = Notifications.where("id=? OR reply=?", root_message_id, root_message_id).order("id")
        check = 0
        for i in msg
          if i.is_show_detail == 1
            check = 1
            break
          end
        end
        if check == 0
          msg.first.update_attribute(:is_show, 0)
        end
      end
      render :status=>200, :json=>{:status=>:success}
    end
  end

  def contact_all_message
    #add customer contact user
   @restaurant_id = params[:restaurant]
    @group = Group.where("location_id=?",@restaurant_id)
    @customer = GroupUser.get_all_list_customers(@restaurant_id,current_user.id)
    customer_contact = []
    unless @customer.empty?
      @customer.each do |cus|
        customer_location = CustomersLocations.find_by_user_id(cus.id)
        if !customer_location.nil?
          unless customer_location.is_deleted.nil?
            if  customer_location.is_deleted == 2
                customer_contact << cus
            end
          end
        end
      end
      @customer = @customer - customer_contact
      @customer =@customer.sort { |x,y| y.created_at <=> x.created_at}
      respond_to do |format|
        format.js
      end
    end
    #end contact user
  end

  def contact_group_message
    @restaurant_id = params[:restaurant]
    @group_id = params[:group_id]

    @group = Group.where("location_id=?",@restaurant_id)
    @customer = GroupUser.get_all_list_customers(@restaurant_id,current_user.id)
    customer_contact = []
    unless @customer.empty?
      @customer.each do |cus|
        customer_location = CustomersLocations.find_by_user_id(cus.id)
        if !customer_location.nil?
          unless customer_location.is_deleted.nil?
            if  customer_location.is_deleted == 2
                customer_contact << cus
            end
          end
        end
      end
    end
    @customer = @customer - customer_contact

    if !@group_id.nil?
      customer_arr_id = []
      user_arr_id = []
      unless @customer.empty?
        @customer.each do |cus|
          customer_arr_id << cus.id
        end
      end
      user_group = GroupUser.where("group_id=?", @group_id)
      unless user_group.empty?
        user_group.each do |user|
          user_arr_id << user.user_id
        end
      end
      user_group_arr = []
      unless user_arr_id.empty?
        user_arr_id.each do |id|
          if customer_arr_id.include?(id)
            user_group_arr << id
          end
        end
      end
    end
    @customer = User.where("id IN (?)",user_group_arr)
    @customer =@customer.sort { |x,y| y.created_at <=> x.created_at}

    respond_to do |format|
      format.js
    end
  end

  def search_contact_message
    @search_params = params[:search_params]
    @restaurant_id = params[:restaurant]

    @group = Group.where("location_id=?",@restaurant_id)
    @customer = GroupUser.get_all_list_customers(@restaurant_id,current_user.id)
    customer_contact = []
    unless @customer.empty?
      @customer.each do |cus|
        customer_location = CustomersLocations.find_by_user_id(cus.id)
        if !customer_location.nil?
          unless customer_location.is_deleted.nil?
            if  customer_location.is_deleted == 2
                customer_contact << cus
            end
          end
        end
      end
    end
    @customer = @customer - customer_contact

    arr_customer = []
    unless @customer.empty?
      @customer.each do |cu|
        arr_customer << cu.id
      end
    end
    if !@search_params.nil?
      customer_search_arr = User.search_customer_contact_message(@search_params)
      customer_search_arr = customer_search_arr.uniq
      customer_search = []
      unless customer_search_arr.empty?
        customer_search_arr.each do |id|
          if arr_customer.include?(id)
            customer_search << id
          end
        end
      end
      @customer = User.where("id IN (?)", customer_search)
      @customer = @customer.sort { |x,y| y.created_at <=> x.created_at}
    end
    respond_to do |format|
      format.js
    end
  end

  def send_customer_contact_message
    user_contact = params[:user_contact]
    user_username_arr = []
    unless user_contact.nil?
      user_arr = user_contact.split(',')
      unless user_arr.empty?
        user = User.where("id IN (?)", user_arr)
        unless user.empty?
          user.each do |u|
            user_username_arr << u.username
          end
        end
      end
    end
    @user_username = user_username_arr
    respond_to do |format|
      format.js
    end
  end

  def cronweeklyreport
    @restaurants = Location.where(weekly_progress_report: 1)

    @restaurants.each do |restaurant|
        @menu_items = restaurant.items
        @prizes = Prize.where(status_prize_id: restaurant.status_prizes.pluck(:id))


        @checkins = restaurant.checkins.includes(:user)
        @socials = restaurant.social_shares
        @item_ids = params[:item_id].present? ? [params[:item_id]] : restaurant.items.pluck(:id)
        @prize_ids = params[:prize_id].present? ? [params[:prize_id]] : @prizes.pluck(:id)
        @comments = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids})

        @new_ids = @checkins.select('min(id)').group(:user_id)
        @new_customers = @checkins.where(id: @new_ids)
        @returning_customers = @checkins.where("id NOT IN (?)", @new_ids.pluck(:id))

        period = 1
        @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_comments.created_at', range: period.weeks.ago..(period-1).weeks.ago).count
        @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_favourites.created_at', range: period.weeks.ago..(period-1).weeks.ago).count
        @order_count = OrderItem.where(item_id: @item_ids).group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
        @social_count = @socials.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
        @new_customer_count = @new_customers.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
        @returning_customer_count = @returning_customers.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
        @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
        @feedback_rating = @comments.group_by_day('item_comments.created_at', range: period.weeks.ago..(period-1).weeks.ago).group(:rating).count

        @feedback_rating_sum = 0
        @feedback_rating_count = 0
        @feedback_rating.each do |(date, rating), count|
          @feedback_rating_sum += rating * count
          @feedback_rating_count += count
        end

        @feedback_rating_str="A+"
        if @feedback_rating_count > 0
          @feedback_rating = (@feedback_rating_sum / @feedback_rating_count).floor
          case @feedback_rating
          when 1.0
            @feedback_rating_str = "A+"
          when 2.0
            @feedback_rating_str = "A"
          when 3.0
            @feedback_rating_str = "A-"
          when 4.0
            @feedback_rating_str = "B+"
          when 5.0
            @feedback_rating_str = "B"
          when 6.0
            @feedback_rating_str = "B-"
          when 7.0
            @feedback_rating_str = "C+"
          when 8.0
            @feedback_rating_str = "C"
          when 9.0
            @feedback_rating_str = "C-"
          when 10.0
            @feedback_rating_str = "D+"
          when 11.0
            @feedback_rating_str = "D"
          when 12.0
            @feedback_rating_str = "D-"
          when 13.0
            @feedback_rating_str = "F"
          else
            @feedback_rating_str = " "
          end
        end

        @week = {
          :feedback_count => @feedback_count.map { |k, v| v }.sum,
          :favourite_count => @favourite_count.map { |k, v| v }.sum,
          :order_count => @order_count.map { |k, v| v }.sum,
          :social_count => @social_count.map { |k, v| v }.sum,
          :new_customer_count => @new_customer_count.map { |k, v| v }.sum,
          :returning_customer_count => @returning_customer_count.map { |k, v| v }.sum,
          :redeemed_prize_count => @redeemed_prize_count.map { |k, v| v }.sum,
          :feedback_rating => @feedback_rating_str
        }

        @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_week('item_comments.created_at', range: period.years.ago..(period-1).years.ago).count
        @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_week('item_favourites.created_at', range: period.years.ago..(period-1).years.ago).count
        @order_count = OrderItem.where(item_id: @item_ids).group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
        @social_count = @socials.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
        @new_customer_count = @new_customers.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
        @returning_customer_count = @returning_customers.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
        @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count

        @year = {
          :feedback_count => @feedback_count.map { |k, v| v }.sum,
          :favourite_count => @favourite_count.map { |k, v| v }.sum,
          :order_count => @order_count.map { |k, v| v }.sum,
          :social_count => @social_count.map { |k, v| v }.sum,
          :new_customer_count => @new_customer_count.map { |k, v| v }.sum,
          :returning_customer_count => @returning_customer_count.map { |k, v| v }.sum,
          :redeemed_prize_count => @redeemed_prize_count.map { |k, v| v }.sum
        }

    UserMailer.send_email_weekly_report(restaurant.weekly_progress_email, restaurant, @week, @year).deliver
    end
    render status: 200, json: { status: :success }
  end

  def sendweeklyprogress
    @weekly_report_email = params[:weekly_progress_email]
    @weekly_report_cb = params[:weekly_progress_report]
    @restaurant = Location.find_by_id(params[:location_id])
    @restaurant.update_attributes({
        :weekly_progress_report => 1,
        :weekly_progress_email => @weekly_report_email
    });

    @menu_items = @restaurant.items
    @prizes = Prize.where(status_prize_id: @restaurant.status_prizes.pluck(:id))


    @checkins = @restaurant.checkins.includes(:user)
    @socials = @restaurant.social_shares
    @item_ids = params[:item_id].present? ? [params[:item_id]] : @restaurant.items.pluck(:id)
    @prize_ids = params[:prize_id].present? ? [params[:prize_id]] : @prizes.pluck(:id)
    @comments = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids})

    @new_ids = @checkins.select('min(id)').group(:user_id)
    @new_customers = @checkins.where(id: @new_ids)
    @returning_customers = @checkins.where("id NOT IN (?)", @new_ids.pluck(:id))

    period = 1
    @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_comments.created_at', range: period.weeks.ago..(period-1).weeks.ago).count
    @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_favourites.created_at', range: period.weeks.ago..(period-1).weeks.ago).count
    @order_count = OrderItem.where(item_id: @item_ids).group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
    @social_count = @socials.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
    @new_customer_count = @new_customers.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
    @returning_customer_count = @returning_customers.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
    @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
    @feedback_rating = @comments.group_by_day('item_comments.created_at', range: period.weeks.ago..(period-1).weeks.ago).group(:rating).count

    @feedback_rating_sum = 0
    @feedback_rating_count = 0
    @feedback_rating.each do |(date, rating), count|
      @feedback_rating_sum += rating * count
      @feedback_rating_count += count
    end

    @feedback_rating_str="A+"
    if @feedback_rating_count > 0
      @feedback_rating = (@feedback_rating_sum / @feedback_rating_count).floor
      case @feedback_rating
      when 1.0
        @feedback_rating_str = "A+"
      when 2.0
        @feedback_rating_str = "A"
      when 3.0
        @feedback_rating_str = "A-"
      when 4.0
        @feedback_rating_str = "B+"
      when 5.0
        @feedback_rating_str = "B"
      when 6.0
        @feedback_rating_str = "B-"
      when 7.0
        @feedback_rating_str = "C+"
      when 8.0
        @feedback_rating_str = "C"
      when 9.0
        @feedback_rating_str = "C-"
      when 10.0
        @feedback_rating_str = "D+"
      when 11.0
        @feedback_rating_str = "D"
      when 12.0
        @feedback_rating_str = "D-"
      when 13.0
        @feedback_rating_str = "F"
      else
        @feedback_rating_str = " "
      end
    end

    @week = {
      :feedback_count => @feedback_count.map { |k, v| v }.sum,
      :favourite_count => @favourite_count.map { |k, v| v }.sum,
      :order_count => @order_count.map { |k, v| v }.sum,
      :social_count => @social_count.map { |k, v| v }.sum,
      :new_customer_count => @new_customer_count.map { |k, v| v }.sum,
      :returning_customer_count => @returning_customer_count.map { |k, v| v }.sum,
      :redeemed_prize_count => @redeemed_prize_count.map { |k, v| v }.sum,
      :feedback_rating => @feedback_rating_str
    }

    @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_week('item_comments.created_at', range: period.years.ago..(period-1).years.ago).count
    @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_week('item_favourites.created_at', range: period.years.ago..(period-1).years.ago).count
    @order_count = OrderItem.where(item_id: @item_ids).group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
    @social_count = @socials.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
    @new_customer_count = @new_customers.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
    @returning_customer_count = @returning_customers.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
    @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count

    @year = {
      :feedback_count => @feedback_count.map { |k, v| v }.sum,
      :favourite_count => @favourite_count.map { |k, v| v }.sum,
      :order_count => @order_count.map { |k, v| v }.sum,
      :social_count => @social_count.map { |k, v| v }.sum,
      :new_customer_count => @new_customer_count.map { |k, v| v }.sum,
      :returning_customer_count => @returning_customer_count.map { |k, v| v }.sum,
      :redeemed_prize_count => @redeemed_prize_count.map { |k, v| v }.sum
    }

    UserMailer.send_email_weekly_report(@weekly_report_email, @restaurant, @week, @year).deliver

    render status: 200, json: { status: :success, feedback: @feedback_rating_str}
  end

  def send_weekly_prize_report
    reward = Reward.find params[:reward_id]
    UserMailer.send_email_weekly_prize_report(reward).deliver

    redirect_to edit_restaurant_reward_path(reward.location, reward), notice: "Weekly prize report has been sent"
  end


  private

    def add_point_user(user_id, location_id, points)
      UserPoint.create({
        :user_id =>  user_id,
        :point_type => POINT_FROM_RESTAURANT,
        :location_id => location_id,
        :points => points,
        :status => 1,
        :is_give => 1
      })
      CustomersLocations.add_contact(Array([user_id]), location_id)
    end

    def add_prize_user(prize_id, sending_user_id, receiving_user_id, location_id)
      # Old Codes Before 3.0
      # TODO: This should probably be a UserPrize.
      # SharePrize.create({
      #   :prize_id => prize_id,
      #   :from_user => sending_user_id,
      #   :to_user  => receiving_user_id,
      #   :location_id => location_id,
      #   :status      => 1,
      #   :from_share  => 'restaurants'
      # })

      # Reward 3.0
      UserReward.create(
        reward_id: prize_id,
        sender_id: sending_user_id,
        receiver_id: receiving_user_id,
        location_id: location_id
      )
      CustomersLocations.add_contact(Array([receiving_user_id]), location_id)
    end

end
