class PointsController < ApplicationController
  #before_filter :authenticate_user!, :except => [:mypoint, :my_global_point, :point_detail,:reply_message,:point_share_friend]
  skip_before_filter :verify_authenticity_token
  before_filter :authorise_request_as_json, :only => [:reply_message,:point_share_friend, :point_share_friend, :reply_message, ]
  before_filter :authorise_user_param, :only => [:mypoint, :my_global_point, :point_detail]
  before_filter :authenticate_user_json, :only => [:reply_message, :point_share_friend]
  skip_before_filter :set_cache_buster
  # before_filter :authenticate_user!
  load_and_authorize_resource :class => "UserPoint"

  #  WEB SERVICE POINT ------------------------------------------------------------------------

  # GET /points/mypoint
  def mypoint
    begin
      if params[:chain_name]
        #Get dinner status
        sql = "
          SELECT
            l.id,
            sum( CASE WHEN u.is_give = 1 THEN u.points ELSE u.points*(-1) END) as total
          FROM locations l
          JOIN user_points u ON l.id = u.location_id AND u.status=1
          WHERE u.user_id = #{@user.id} "

        location_id = params[:location_id]?params[:location_id]:0
        location_id = location_id.to_i
        if location_id > 0
            sql << "AND l.id = '#{location_id}'"
        end

        chain_name = fix_special_character(params[:chain_name])
        if chain_name.to_s != "null"
          sql << "AND l.chain_name='#{chain_name}'"
        end
        @global = Location.find_by_sql(sql)

        #points by chain name
        @locations = Location.my_point_by_chain(chain_name, @user.id, location_id)
        #@current_prize = Location.get_list_my_prize_by_chain(chain_name,@user.id)
      else
        render :status => 412 , :json => {:status=> :failed, :error => "chain_name is required"}
      end
    rescue Exception => e # I hate having to do this
      return render status: 500, json: {status: :failed, error: e.message}
    end
  end

  def my_global_point
    @locations = Location.my_global_point(@user.id)
  end

  def point_detail
    if location_id = params[:location_id]
      #Get dinner status
      sql="SELECT u.location_id as id,sum( CASE WHEN u.is_give = 1 THEN u.points ELSE u.points*(-1) END) as total
      FROM user_points u
      WHERE u.location_id =#{location_id}  AND u.user_id=#{@user.id} AND u.status=1"
      @locations = Location.find_by_sql(sql).first

      #List of point
      @point = UserPoint.select("user_points.*, DATE_FORMAT(updated_at, '%m/%d/%Y %H:%i:%S') as most_recent")\
      .where("user_points.user_id = '#{@user.id}' and user_points.status = 1
      and user_points.points > 0  and user_points.location_id = #{location_id.to_i}")\
      .order("most_recent DESC")
    else
      render :status => 412 , :json => {:status=>:failed, :error => "location_id is required"}
    end
  end

  #Share point with friend
  def point_share_friend
    begin
      ActiveRecord::Base.transaction do
        point = @parsed_json["point"] if @parsed_json["point"]
        location_id = @parsed_json["location_id"] if @parsed_json["location_id"]
        location = Location.find(location_id)
        @to_user = User.where("id=?",@parsed_json["to_user"]).first
        if @to_user.nil?
          return render :status=>412,:json=>{:status=>:failed, :error=>"to_user param invalid"}
        else
          check = Friendship.where("friendable_id = ? AND friend_id =?",@user.id, @to_user.id).first
          check2 = Friendship.where("friendable_id = ? AND friend_id =?",@to_user.id, @user.id).first
          if check.nil? && check2.nil?
            return render :status => 404, :json => {:status => :failed, :error=>"Resource not found"}
          else
            @user.sub_points(point)
            #Share points
            UserPoint.create({
              :user_id => @user.id,
              :point_type => "Points Shared",
              :location_id => location_id,
              :points => point,
              :status => 1,
              :is_give => 0
            })
            UserPoint.create(
              :user_id => @to_user.id,
              :point_type => RECEIVED_POINT_TYPE,
              :location_id => location_id,
              :points => point,
              :status => 1,
              :is_give => 1
            )
            notification = Notifications.new
            notification.from_user = @user.id
            notification.to_user = @to_user.email
            if @user.first_name.nil? || (@user.first_name.nil? && @user.last_name.nil?)
              username = @user.username
            else
              username = @user.first_name + " " + @user.last_name
            end
            notification.message = sharepoint_msg(username,location.name ,point)
            notification.msg_type = "single"
            notification.location_id = location_id
            notification.alert_type = SHARING_POINTS
            notification.alert_logo = POINT_LOGO
            notification.msg_subject = POINTS_MESSAGE
            notification.points = point
            notification.save!
            CustomersLocations.add_contact(Array([@user.id, @to_user.id]), location_id)
            return render :status => 200, :json => {:status => :success}
          end
        end
      end #end transaction
    # rescue
    #   return render :status =>500, :json=> {:status=>:failed, :error => "Internal Service Error"}
    end
  end

  #Confirm received point
  def reply_message # TODO: Refactor this method
    from_user    = User.find_by_id(@parsed_json["from_user"])
    msg_id       = @parsed_json["msg_id"] if @parsed_json["msg_id"]
    location_id  = @parsed_json["location_id"] if @parsed_json["location_id"]
    message      = @parsed_json["message"] if @parsed_json["message"]
    alert_type   = @parsed_json["alert_type"] if @parsed_json["alert_type"]

    if alert_type.blank?
      return render :status => 412, :json=>{:status=>:failed, :error=>"alert_type param is required"}
    end
    if msg_id.blank?
      return render :status => 412,:json=>{:status=>:failed, :error=>"msg_id param is required"}
    end
    if from_user.blank?
      return render :status => 412,:json=>{:status=>:failed, :error=>"from_user param is required"}
    end

    ActiveRecord::Base.transaction do
      if [POINTS_ALERT_TYPE, RATING_ALERT_TYPE, SHARING_POINTS, RESTAURANT_RATING_ALERT_TYPE].include?(alert_type)
        msg_point = Notifications.find_by_id(msg_id)
        to_user = User.find_by_id(msg_point.from_user) if msg_point.present?
        points = msg_point.nil? ? 0 : msg_point.points
        @notification             = Notifications.new
        @notification.from_user   = @user.id
        @notification.to_user     = to_user.email
        @notification.message     = message
        @notification.msg_type    = "group"
        @notification.location_id = location_id

        case alert_type
        when POINTS_ALERT_TYPE
          @notification.alert_type = POINTS_ALERT_TYPE
          @notification.alert_logo  = POINT_LOGO
          @notification.msg_subject = POINTS_MESSAGE
        when RATING_ALERT_TYPE
          @notification.alert_type = RATING_ALERT_TYPE
          @notification.alert_logo  = RATING_LOGO
          @notification.msg_subject = RATING_MESSAGE
        when SHARING_POINTS
          @notification.alert_type = SHARING_POINTS
          @notification.alert_logo  = POINT_LOGO
          @notification.msg_subject = SHARING_POINTS
        when RESTAURANT_RATING_ALERT_TYPE
          @notification.alert_type = RESTAURANT_RATING_ALERT_TYPE
          @notification.alert_logo  = RATING_LOGO
          @notification.msg_subject = RESTAURANT_RATING_MESSAGE
        end
        @notification.points      = points
        @notification.reply       = msg_id

        if @notification.save
          return render :status => 200, :json=> {:status=>:success}
        end
        return render :status => 503, :json=> {:status=>:failed}
      end
      return render  :status => 503, :json=> {:status=>:failed,:error=>"Alert Type Invalid"}
    end
  end

  # WEB SERVER ------------------------------------------------------------------

  def get_data_for_report(params)
    @is_my_rewards_page = false
    @is_my_rewards_search_page = false
    item_comments = []
    reward_rating_notifications = []
    location_ids = []
    restaurants = []
    user = {}

    if !current_user.admin?
      if current_user.restaurant_admin?
        user['restaurants'] = Location.where_by_rsr_admin(current_user.id)
      elsif current_user.restaurant_manager?
        user['restaurants'] = Location.where_by_rsr_manager(current_user.id)
      elsif current_user.owner?
        user['restaurants'] = current_user.restaurants
        unless current_user.unlimit?
          user['restaurants'] = user['restaurants'][0...current_user.app_service.limit]
        end
      end
    else
      user['restaurants'] = Location.all
    end

    # if params[:search]
    #   search_params = params[:search]
    #   d = DateTime.parse(search_params) rescue nil
    #   date_converted = search_params
    #   date_converted = DateTime.parse(search_params).strftime("%Y-%m-%d") if d
    # end

    # Reward
    if !params[:restaurant_id].nil? && params[:restaurant_id] != "" && params[:after_hide].nil?
      restaurant = Location.find(params[:restaurant_id])
      authorize! :read, restaurant
      restaurants << restaurant
    else # My Reward
      @is_my_rewards_page = true
      @is_my_rewards_search_page = true
      restaurants = user['restaurants']
    end
    # # Get all notifications
    # restaurants.each do |r|
    #   location_ids << r.id

    #   # Get all item comments
    #   build_menus = r.build_menus
    #   if !build_menus.nil?
    #     build_menus.each do |build_menu|
    #       item_comments.concat(build_menu.item_comments)
    #     end
    #   end
    #   item_comments.uniq
    # end
    #
    @item_comments_array = []
    # Get all notifications
    restaurants.each do |restaurant|
      location_ids << restaurant.id
      # Get all item comments
      build_menus = restaurant.build_menus
      if !build_menus.nil?
        build_menus.each do |build_menu|
          @item_comments_array.concat(build_menu.item_comments)
        end
      end
    end
    @item_command_id_lst = Notifications.where(alert_type: RATING_ALERT_TYPE).pluck(:item_comment_id)
    @item_comments_array.each do |item_comment|
      if @item_command_id_lst.include?(item_comment.id)
        item_comments << item_comment
      end
    end

    item_comments.uniq

    reward_rating_notifications = Notifications.get_rating_notifications(current_user, location_ids)
    unless reward_rating_notifications.empty?
      item_comments = item_comments.concat(reward_rating_notifications)
    end
    item_comments = item_comments.sort { |x,y| y.created_at <=> x.created_at}
    return item_comments
  end


  def reward_export_csv
    @item_comments = get_data_for_report(params)
    reward_csv = CSV.generate do |csv|
      # header row
      csv << ["UserID", "Reward Type", "Description", "Point", "Date" , "Time"]
      # data row
      @item_comments.each do |item|
        if !item.has_attribute? 'from_user'
          user_obj = User.find(item.user_id)
          build_menu_comment_obj = BuildMenu.find(item.build_menu_id)
          item_obj = Item.find(build_menu_comment_obj.item_id)
          rating_points = item_obj.points_awarded_for_comment
          description = ''
          if !item_obj.nil?
            description = item_obj.name
          end
          csv << [user_obj.username, 'Rating', description ,
            rating_points.to_i, item.created_at.strftime("%Y-%m-%d "),
          item.created_at.strftime(" %l:%M %p")]
        else
          item_name= ''
          if !item.item_id.nil?
            item_obj = Item.find(item.item_id)
            item_name = item_obj.name unless item_obj.nil?
          end
          user_obj = User.find_by_email(item.to_user)
          csv << [user_obj.username, item.alert_type, item_name ,
            item.points.to_i,item.created_at.strftime("%Y-%m-%d "),
          item.created_at.strftime(" %l:%M %p")]
        end
      end
    end

    send_data(reward_csv, :type => 'test/csv', :filename => 'MyReward_Record_'+DateTime.now.strftime("%Y_%m_%d")+'.csv')

  end

  def reward_export_pdf
    @item_comments = get_data_for_report(params)
    require 'prawn'

    Prawn::Document.generate('MyReward_Record_'+DateTime.now.strftime("%Y_%m_%d")+'.pdf') do |pdf|
      cells =[]
      cells << [Prawn::Table::Cell::Text.make( pdf, "UserID",
        :background_color => "#FFFF33", :width => 60),
        Prawn::Table::Cell::Text.make( pdf, "Reward Type", :background_color => "#FFFF33", :width => 100),
        Prawn::Table::Cell::Text.make( pdf, "Description", :background_color => "#FFFF33", :width => 100),
        Prawn::Table::Cell::Text.make( pdf, "Point", :background_color => "#FFFF33",:width => 60),
        Prawn::Table::Cell::Text.make( pdf, "Date", :background_color => "#FFFF33"),
      Prawn::Table::Cell::Text.make( pdf, "Time", :background_color => "#FFFF33")]

      i=1
      @item_comments.each do |item|
        if !item.has_attribute? 'from_user'
          user_obj = User.find(item.user_id)
          build_menu_comment_obj = BuildMenu.find(item.build_menu_id)
          item_obj = Item.find(build_menu_comment_obj.item_id)
          rating_points = item_obj.points_awarded_for_comment
          description = ''
          if !item_obj.nil?
            description = item_obj.name
          end

          cells << [Prawn::Table::Cell::Text.new( pdf, [i,0],:content => user_obj.username.to_s),
            'Rating', description ,
            rating_points.to_i,
            item.created_at.strftime("%Y-%m-%d "),
          item.created_at.strftime("%l:%M %p")]
        else
          item_name= ''
          if !item.item_id.nil?
            item_obj = Item.find(item.item_id)
            item_name = item_obj.name unless item_obj.nil?
          end

          user_obj = User.find_by_email(item.to_user)

          cells << [Prawn::Table::Cell::Text.new( pdf, [i,0], :content => user_obj.username.to_s),
            item.alert_type,
            item_name ,item.points.to_i,
            item.created_at.strftime("%Y-%m-%d "),
          item.created_at.strftime("%l:%M %p")]
        end
        i=i+1
      end

      table_data = cells
      pdf.table(table_data,:width => 500)
    end

    send_file('MyReward_Record_'+DateTime.now.strftime("%Y_%m_%d")+'.pdf')

  end


  def reward_export_xls
    @item_comments = get_data_for_report(params)

    require 'axlsx'
    p = Axlsx::Package.new
    wb = p.workbook
    wb.styles do |s|
      wb.add_worksheet(:name => "Item Comments") do |sheet|
        head = s.add_style :bg_color => "00", :fg_color => "FF"
        sheet.add_row ["UserID", "Reward Type", "Description", "Point", "Date" , "Time"]
        sheet.row_style 0, head

        @item_comments.each do |item|
          if !item.has_attribute? 'from_user'
            user_obj = User.find(item.user_id)
            build_menu_comment_obj = BuildMenu.find(item.build_menu_id)
            item_obj = Item.find(build_menu_comment_obj.item_id)
            rating_points = item_obj.points_awarded_for_comment
            description = ''
            if !item_obj.nil?
              description = item_obj.name
            end

            sheet.add_row [user_obj.username, 'Rating', description,
              rating_points.to_i, item.created_at.strftime("%Y-%m-%d "),
            item.created_at.strftime("%l:%M %p") ]
          else
            item_name= ''
            if !item.item_id.nil?
              item_obj = Item.find(item.item_id)
              item_name = item_obj.name unless item_obj.nil?
            end

            user_obj = User.find_by_email(item.to_user)

            sheet.add_row [user_obj.username, item.alert_type, item_name ,
              item.points,item.created_at.strftime("%Y-%m-%d "),
            item.created_at.strftime("%l:%M %p") ]
          end
        end
      end
    end

    p.use_autowidth = true
    p.serialize('MyReward_Record_'+DateTime.now.strftime("%Y_%m_%d")+'.xlsx')

    send_file('MyReward_Record_'+DateTime.now.strftime("%Y_%m_%d")+'.xlsx')
  end

  # GET
  #Action for showing Rewards of a resturant
  def rewards # TODO: Refactor this method!
    @check = false
    @restaurant = Location.new
    @is_my_rewards_page = false
    @is_my_rewards_search_page = false
    @item_comments = []
    @reward_rating_notifications = []
    @total_rating_points = 0
    @total_reward_points = 0
    @total_points = 0
    date_converted = ""
    @search_text = ""
    location_ids = []
    restaurants = []
    user = {}

    if !current_user.admin?
      if current_user.restaurant_admin?
        user['restaurants'] = Location.where_by_rsr_admin(current_user.id)
      elsif current_user.restaurant_manager?
        user['restaurants'] = Location.where_by_rsr_manager(current_user.id)
      elsif current_user.owner?
        user['restaurants'] = current_user.restaurants
        unless current_user.unlimit?
          user['restaurants'] = user['restaurants'][0...current_user.app_service.limit]
        end
      end
    else
      user['restaurants'] = Location.all
    end

    if params[:search]
      @search_text = params[:search]
      d = DateTime.parse(@search_text) rescue nil
      date_converted = @search_text
      date_converted = DateTime.parse(@search_text).strftime("%Y-%m-%d") if d
    end

    # Reward
    if !params[:restaurant_id].blank? && params[:after_hide].nil?
      @restaurant = Location.find(params[:restaurant_id])

      unless @restaurant.nil?
        owner_id = @restaurant.owner_id
        if current_user.id.to_i == owner_id.to_i || current_user.admin?
          @check = true
        end
      end

      authorize! :read, @restaurant
      restaurants << @restaurant
    else # My Reward
      @is_my_rewards_page = true
      @is_my_rewards_search_page = true
      restaurants = user['restaurants']
    end

    @item_comments = []
    # Get all notifications
    restaurants.each do |restaurant|
      location_ids << restaurant.id

      # Get all item comments
      build_menus = restaurant.build_menus
      unless build_menus.blank?
        build_menus.each do |build_menu|
          @item_comments.concat(build_menu.item_comments)
        end
      end
    end

    # Get all user checkins
    @user_checkins = Checkin.where(location_id: @restaurant.id)

    # Get all prize_redeems (Rething relationships and refactor in future)
    @prize_redeems = []
    @restaurant.status_prizes.each do |sp|
      sp.prizes.each do |prize|
        prize.prize_redeems.each do |p_redeem|
          @prize_redeems << p_redeem
        end
      end
    end

    @user_rewards = @restaurant.user_rewards.where(is_reedemed: true)

    @reward_rating_notifications = Notifications.get_rating_notifications(current_user, location_ids)

    # calculate points
    unless @item_comments.blank?
      @item_comments.each do |item_comment|
        @total_rating_points += item_comment.points_awarded_for_comment
      end
    end

    # Search
    result = []
    hide_status = 'hide_status'
    if current_user.owner? && @is_my_rewards_page
      hide_status = 'is_hide_reward_by_admin'
    end
    if @item_comments.present? && params[:search]
      @item_comments.each do |item_comment|
        @item_comments.select {|ic| ic.send(hide_status) == 0 \
          and !(User.where('id = ? AND username LIKE ?',ic.user_id, '%' + @search_text + '%').empty?) \
          || !(Item.joins(:build_menus).where("build_menus.id = ? AND (items.name LIKE ?)", \
          ic.build_menu_id, '%' + @search_text + '%').empty?) \
          || !(ItemComment.where('id = ? AND (DATE_FORMAT(created_at,"%Y-%m-%d") = ?
          OR DATE_FORMAT(created_at,"%Y") = ? OR DATE_FORMAT(created_at,"%m") = ? OR DATE_FORMAT( created_at,"%d") = ?)', \
          ic.id, date_converted, @search_text, @search_text, @search_text).empty?) }.each do |ic|
            result << ic
            @item_comments.delete(ic)
        end
      end
    end

    @item_comments.reject! {|item_comment| item_comment.send(hide_status) == 1 }
    unless @reward_rating_notifications.empty?
      @reward_rating_notifications.each do |reward_rating|
        if !reward_rating.points.nil?
          @total_reward_points += reward_rating.points
        end
      end
      @reward_rating_notifications.reject! {|notification| notification.send(hide_status) == 1 }
      if params[:search]
        checknumber= is_number?(@search_text)

        unless is_number?(@search_text)

          @reward_rating_notifications.reject! {|reward_rating| User.where('email = ? AND username LIKE ?', \
          reward_rating.to_user, '%' + @search_text + '%').empty? && Item.where('id = ? AND name LIKE ?', \
          reward_rating.item_id, '%' + @search_text + '%').empty? && Notifications.where('id = ? AND (DATE_FORMAT(created_at,"%Y-%m-%d") = ?
          OR DATE_FORMAT(created_at,"%Y") = ? OR DATE_FORMAT(created_at,"%m") = ? OR DATE_FORMAT(created_at,"%d") = ?)', \
          reward_rating.id, date_converted, @search_text, @search_text, @search_text).empty?}

        else

          @reward_rating_notifications.reject! {|reward_rating| User.where('email = ? AND username LIKE ?', \
          reward_rating.to_user, '%' + @search_text + '%').empty? && Item.where('id = ? AND name LIKE ?', \
          reward_rating.item_id, '%' + @search_text + '%').empty? && Notifications.where('id = ? AND points = ?', \
          reward_rating.id, @search_text).empty? && Notifications.where('id = ? AND (DATE_FORMAT(created_at,"%Y-%m-%d") = ?
          OR DATE_FORMAT(created_at,"%Y") = ? OR DATE_FORMAT(created_at,"%m") = ? OR DATE_FORMAT(created_at,"%d") = ?)', \
          reward_rating.id, date_converted, @search_text, @search_text, @search_text).empty?}
        end
      end
    end
    @total_rating_points += @total_reward_points
    @total_points = @total_rating_points

    # TODO: Refactor this - we're adding Notifications into a group of ItemComments.  Poor form.
    if params[:search]
      @item_comments = result.concat(@reward_rating_notifications).sort { |x,y| y.created_at <=> x.created_at }
    else
      @item_comments = @item_comments.concat(@reward_rating_notifications).sort { |x,y| y.created_at <=> x.created_at }
    end
    count = (params[:page]).to_i - 1
    if @item_comments.length / 10 == count && @item_comments.length % 10 == 0
      params[:page] = count.to_s
    end

    # Add all the info into one points_ledger_info array.
    @points_ledger_info = []
    @item_comments.each do |i|
      if i.present?
        @points_ledger_info << i
      end
    end

    @user_checkins.each do |i|
      if i.present?
        @points_ledger_info << i
      end
    end

    @prize_redeems.each do |i|
      if i.present?
        @points_ledger_info << i
      end
    end

    @user_rewards.each do |i|
      if i.present?
        @points_ledger_info << i
      end
    end

    @points_ledger_info.sort_by! {|obj| obj.updated_at}.reverse!
    @points_ledger_info = Kaminari.paginate_array(@points_ledger_info).page(params[:page]).per(10)

    if @check == false && !current_user.admin? && !@is_my_rewards_page
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/restaurant", :layout => false }
      end
    end
  end

  def is_number?(str)
    true if Float(str) rescue false
  end

  #action  when hide an item in reward

  def hide_reward_point
    @is_my_rewards_page = params[:is_my_rewards_page]
    @is_my_rewards_page = @is_my_rewards_page == 'true' ? true:false
    @is_my_rewards_search_page=false
    @item_comments = []
    date_converted= ""
    @search_text= ""
    @reward_rating_notifications = []

    if params[:search]
      search_params = params[:search]
      d = DateTime.parse(search_params) rescue nil
      if d
        date_converted = DateTime.parse(search_params).strftime("%Y-%m-%d ")
      else
        date_converted = search_params
      end
    end

    unless params[:item_comment_id].nil?
      @item_comment = ItemComment.find(params[:item_comment_id])
    end
    unless params[:notification_id].nil?
      @rating_reward_notification = Notifications.find(params[:notification_id])
    end
    column = 'hide_status'
    if current_user.owner? && @is_my_rewards_page
      column = 'is_hide_reward_by_admin'
    end

    if !@item_comment.nil? && @item_comment.update_column(column.to_sym, 1) \
    || !@rating_reward_notification.nil? && @rating_reward_notification.update_attributes(column.to_sym => 1)

      params_advance = {}
      if params[:search]
        params_advance[:search] = params[:search]
      end
      if params[:page]
        params_advance[:page] = params[:page]
      end
      if !@is_my_rewards_page
        @restaurant = Location.find(params[:restaurant_id])
        return redirect_to rewards_restaurant_points_path(@restaurant, params_advance)
      else
        params_advance[:after_hide] = true
        return redirect_to rewards_restaurant_points_path(current_user, params_advance)
      end
    end
  end

  def show_all_reward
    restaurants = []
    @item_comments = []
    @reward_rating_notifications = []
    location_ids = []
    user ={}
    if !current_user.admin?
      if current_user.has_parent?
        parent = current_user.parent_user
        user['restaurants'] = parent.restaurants
      else
        user['restaurants'] = current_user.restaurants
      end
    end

    if params[:restaurant_id]
      @restaurant = Location.find(params[:restaurant_id])
      restaurants << @restaurant
      location_ids << @restaurant.id
    else
      @is_my_rewards_page = true
      if !current_user.admin?
        restaurants = user['restaurants']
      end
      # restaurants = current_user.restaurants
      # location_ids = restaurants.map{|restaurant| restaurant.id}
    end

    restaurants.each do |restaurant|
      location_ids << restaurant.id
      build_menus = restaurant.build_menus
      unless build_menus.nil?
        build_menus.each do |build_menu|
          @item_comments.concat(build_menu.item_comments)
        end
        @item_comments.uniq
      end
    end

    @item_comments.each do |item_comment|
      if @is_my_rewards_page && current_user.owner?
        item_comment.update_column(:is_hide_reward_by_admin, 0)
      else
        item_comment.update_column(:hide_status, 0)
      end
    end
    # @reward_rating_notifications = Notifications.where('location_id IN (?) AND alert_type = ? AND hide_status = ?',
    #     location_ids, RATING_ALERT_TYPE, 1)

    @reward_rating_notifications = Notifications.get_rating_notifications(current_user, location_ids).hide_notification(@is_my_rewards_page)
    # puts "@ reward_rating_notifications", @reward_rating_notifications

    # @reward_rating_notifications = Notifications.where('location_id IN (?) AND alert_type = ?',
    #       location_ids, RATING_ALERT_TYPE)

    unless @reward_rating_notifications.empty?
      if @is_my_rewards_page && current_user.owner?
        @reward_rating_notifications.update_all(:is_hide_reward_by_admin => 0)
      else
        @reward_rating_notifications.update_all(:hide_status => 0)
      end
    end

    if params[:restaurant_id]
      redirect_to rewards_restaurant_points_path(@restaurant)
    else
      redirect_to rewards_points_path()
    end
  end

  # GET /points/socical?restaurant_id=:location_name
  def socical
    # Confirm the required parameter is given
    if params[:restaurant_id].blank?
      return redirect_to restaurants_path, warning: "The 'socical' page requires a restaurant_id parameter."
    end
    @restaurant = Location.find_by_id(params[:restaurant_id])
    authorize! :read, @restaurant

    # Get the SocialPoint record
    @social_point = SocialPoint.find_by_location_id(@restaurant.id)
    if !@social_point
      @social_point = SocialPoint.new(location_id: @restaurant.id)
    end
  end

  # POST /points/socical_point
  def socical_point
    location_id = params[:social_point][:location_id]
    @restaurant = Location.find(location_id)

    unless location_id.nil?
      @social_point = SocialPoint.find_by_location_id(location_id)
      if @social_point.present?
        @social_point.update_attributes(params[:social_point])
      else
        @social_point = SocialPoint.new
        @social_point.facebook_point = params[:social_point][:facebook_point].to_i
        @social_point.google_plus_point = params[:social_point][:google_plus_point].to_i
        @social_point.ibecon_point = params[:social_point][:ibecon_point].to_i
        @social_point.instragram_point = params[:social_point][:instragram_point].to_i
        @social_point.twitter_point = params[:social_point][:twitter_point].to_i
        @social_point.location_id = params[:social_point][:location_id].to_i

        @social_point.save
      end
    end
    respond_to do |format|
      #@social_point = SocialPoint.find_by_location_id(location_id)
      format.js
    end
  end

  def prize

    @restaurant = Location.find_by_slug(params[:format])
    @status_prize_id = params[:status_prize_id].to_i

    @status_name = nil
    unless @status_prize_id == 0
      status_prize = StatusPrize.find_by_id(@status_prize_id)
      unless status_prize.nil?
        @status_name = status_prize.name
      end
    end
    status = []
    unless  @restaurant.nil?
      status = StatusPrize.where("location_id=?", @restaurant.id).order("id")
    end
    unless @restaurant.nil?
      @status_prize = StatusPrize.where("location_id=?",@restaurant.id)
      if @status_prize.empty?
        StatusPrize.create(
        name: 'Bronze',
        location_id: @restaurant.id,
        )
        StatusPrize.create(
        name: 'Silver',
        location_id: @restaurant.id,
        )
        StatusPrize.create(
        name: 'Gold',
        location_id: @restaurant.id,
        )
        StatusPrize.create(
        name: 'Platinum',
        location_id: @restaurant.id,
        )
      end
      @status_prize = StatusPrize.where("location_id=?",@restaurant.id).order('id ASC')
    end
    @prize = Prize.new
    @status_prize_id = StatusPrize.find_by_id(@status_prize_id)
    if !@restaurant.nil? && !status.empty?
      if @status_prize_id != 0 && !@status_prize_id.nil?
        @prize = Prize.where("status_prize_id=? AND is_delete=?", @status_prize_id, 0).order('level ASC')
      else
        @prize = Prize.where("status_prize_id=? AND is_delete=?", status[0].id, 0).order('level ASC')
      end
      if @prize.nil?
        @prize = Prize.new
      end
    end
    unless @restaurant.nil?
      @status_prize_arr = StatusPrize.where("location_id=?",@restaurant.id).order('id ASC')
    end
  end

  def action_status_prize
    @restaurant = Location.find_by_slug(params[:format])
    @status_prize_id = params[:status_prize_id].to_i
  end

  def status_prize

    @restaurant = Location.find_by_slug(params[:format])
    @status_prize_id = params[:status_prize_id].to_i
    # status = []
    # unless  @restaurant.nil?
    #   status = StatusPrize.where("location_id=?", @restaurant.id).order("id")
    # end
    # unless @restaurant.nil?
    #   @status_prize = StatusPrize.where("location_id=?",@restaurant.id)
    #   if @status_prize.empty?
    #     StatusPrize.create(
    #     name: 'Bronze',
    #     location_id: @restaurant.id,
    #     )
    #     StatusPrize.create(
    #     name: 'Sivler',
    #     location_id: @restaurant.id,
    #     )
    #     StatusPrize.create(
    #     name: 'Gold',
    #     location_id: @restaurant.id,
    #     )
    #     StatusPrize.create(
    #     name: 'Platinum',
    #     location_id: @restaurant.id,
    #     )
    #   end
    #   @status_prize = StatusPrize.where("location_id=?",@restaurant.id)
    # end

    # @prize = Prize.new
    # if !@restaurant.nil? && !status.empty?
    #   @prize = Prize.where("status_prize_id=? AND is_delete=?", @status_prize_id, 0).order('level ASC')
    #   if @prize.nil?
    #     @prize = Prize.new
    #   end
    # end

  end

  def save_prize(name_array, redeem_value_array, status_prize_id, status_name,location_id, build_menu_ids, category_ids)
    count_name = name_array.count
    count_redeem = redeem_value_array.count
    @restaurant = Location.find_by_id(location_id)
    status = StatusPrize.find_by_id(status_prize_id)

    unless status.nil?
      status.update_attribute(:name, status_name)
    end
    if count_name == count_redeem
      unless name_array.empty?
        name_array.each_with_index do |name, index|
          category_id = nil
          build_menu_id = nil
          if build_menu_ids[index] != nil && build_menu_ids[index] != ""
            build_menu_id = build_menu_ids[index]
          else
            category_id = category_ids[index]
          end
          @prize = Prize.new
          @prize.name = name
          # @prize.token = params[:prize][:token]
          @prize.level = index + 1
          @prize.redeem_value = redeem_value_array[index]
          @prize.status_prize_id = status_prize_id
          @prize.role = 'owner'
          @prize.is_delete = 0
          @prize.build_menu_id = build_menu_id
          @prize.category_id = category_id
          @prize.save
        end
      end
    end
  end

  def insert_prize
    location_id = params[:prize][:location_id]
    status_name = params[:prize][:status_name]
    @status_prize_id = params[:prize][:status_prize_id]

    @restaurant = Location.find_by_id(location_id) unless location_id.nil?
    unless params[:prize][:name].nil?
      name_array = params[:prize][:name]
      redeem_value_array = params[:prize][:redeem_value]
      build_menu_ids = params[:prize][:build_menu_id]
      category_ids = params[:prize][:category_id]
      save_prize(name_array, redeem_value_array, @status_prize_id, status_name, location_id, build_menu_ids, category_ids)
    end
    respond_to do |format|
      format.js
    end
  end

  def insert
    @params = params
    respond_to do |format|
      format.js
    end
  end
  def prize_level

    @params = params
    respond_to do |format|
      format.js
    end
  end

  def update_prize_level
    arr = params[:prize][:build_menu_id]
    item = nil
    arr.each_with_index do |value, index|
      item = value
    end
    @status_prize_id = params[:status_prize_id]
    status_name = params[:status_name]
    role = 'owner'
    location_id = params[:location_id]
    level_arr_params = []
    name_arr_params = []
    redeem_value_arr_params = []
    build_menu_ids = []
    category_ids = []
    @restaurant = Location.find_by_id(location_id)
    status = StatusPrize.find_by_id(@status_prize_id)
    unless status.nil?
      status.update_attribute(:name, status_name)
    end
    unless params[:prize].nil?
      params[:prize][:level].each do |level|
        level_arr_params << level.to_i
      end
      params[:prize][:name].each do |name|
        name_arr_params << name
      end
      params[:prize][:redeem_value].each do |redeem_value|
        redeem_value_arr_params << redeem_value
      end
      params[:prize][:build_menu_id].each do |build_menu_id|
        build_menu_ids << build_menu_id
      end
      params[:prize][:category_id].each do |category_id|
        category_ids << category_id
      end

      if level_arr_params.count == 1 \
        && name_arr_params.count == 1 && name_arr_params.include?("") \
        && redeem_value_arr_params.count == 1 && redeem_value_arr_params.include?("")\
        && category_ids.count == 1 && category_ids.include?("")\
        && build_menu_ids.count == 1 && build_menu_ids.include?("")
        prize_lst = Prize.where('status_prize_id = ? and is_delete = ?', @status_prize_id, 0)
        prize_lst.each do |prize|
          prize.update_attribute(:is_delete, 1)
          # delete item in order linked to prize
          Prize.delete_orders_belong_to_prize(location_id, prize.id)
        end
      else
        prize_arr = Prize.where('status_prize_id = ? and is_delete = ?',@status_prize_id, 0).order('level ASC')
        count = prize_arr.count
        count_name_prize = name_arr_params.length
        level_arr = []
        prize_arr.each do |prize|
          level_arr << prize.level.to_i
        end
        if level_arr == level_arr_params && count == count_name_prize
          name_arr_params.each_with_index do |name, index|
            level = index + 1
            prize = Prize.where("level = ? AND is_delete = ? AND status_prize_id = ?", level, 0, @status_prize_id)
            prize.each do |p|
              is_changed_item = false
              current_prize_item = nil
              current_prize_category = nil
              category_id = nil
              build_menu_id = nil
              current_prize_item = BuildMenu.find(p.build_menu_id).item.redemption_value if !p.build_menu_id.nil?
              current_prize_category = Category.find(p.category_id).redemption_value if !p.category_id.nil?
              old_redemption_value = p.redeem_value

              # restaurant owner changed redemption value of prize
              if redeem_value_arr_params[index] != old_redemption_value
                # restaurant owner select an item an link it to prize
                if build_menu_ids[index] != nil && !build_menu_ids[index].blank?
                  if BuildMenu.find(build_menu_ids[index]).item.redemption_value.to_i == redeem_value_arr_params[index].to_i
                    logger.info "111"
                    is_changed_item = true
                    build_menu_id = build_menu_ids[index]
                  end
                else # restaurant owner select a category an link it to prize
                  if category_ids[index] != nil && !category_ids[index].blank?
                    if Category.find(category_ids[index]).redemption_value.to_i == redeem_value_arr_params[index].to_i
                      is_changed_item = true
                      category_id = category_ids[index]
                    end
                  end
                end
              else # restaurant owner hasn't changed redemption value of prize yet
                if build_menu_ids[index] != nil && !build_menu_ids[index].blank?
                  if BuildMenu.find(build_menu_ids[index]).item.redemption_value.to_i == redeem_value_arr_params[index].to_i
                    is_changed_item = true
                    build_menu_id = build_menu_ids[index]
                  end
                else # restaurant owner select a category an link it to prize
                  if category_ids[index] != nil && !category_ids[index].blank?
                    if Category.find(category_ids[index]).redemption_value.to_i == redeem_value_arr_params[index].to_i
                      is_changed_item = true
                      category_id = category_ids[index]
                    end
                  end
                end
              end

              p.update_attributes(
                :name => name,
                :level =>level_arr[index],
                :redeem_value => redeem_value_arr_params[index],
                :status_prize_id => @status_prize_id,
                :role => role,
                :build_menu_id => build_menu_id,
                :category_id => category_id
              )
              # delete item in order linked to prize
              if is_changed_item || (p.build_menu_id.nil? && p.category_id.nil?)
                Prize.delete_orders_belong_to_prize(location_id, p.id)
              end
            end
          end
        else
          level_arr_params.each_with_index do |level, index|
            if level == 0
              prize = Prize.new
              category_id = nil
              build_menu_id = nil
              if build_menu_ids[index] != nil && build_menu_ids[index] != ""
                build_menu_id = build_menu_ids[index]
              else
                category_id = category_ids[index]
              end
              prize.name = name_arr_params[index]
              prize.level = index + 1000
              prize.redeem_value = redeem_value_arr_params[index]
              prize.status_prize_id = @status_prize_id
              prize.role = 'owner'
              prize.is_delete = 0
              prize.build_menu_id = build_menu_id
              prize.category_id = category_id
              prize.save
            else
              level_prize = Prize.where("level=? AND is_delete =? AND status_prize_id=?",level, 0, @status_prize_id)
              level_prize.each do |p|
                category_id = nil
                build_menu_id = nil
                old_redemption_value = p.redeem_value
              # restaurant owner changed redemption value of prize
              if redeem_value_arr_params[index] != old_redemption_value
                # restaurant owner select an item an link it to prize
                if build_menu_ids[index] != nil && !build_menu_ids[index].blank?
                  if BuildMenu.find(build_menu_ids[index]).item.redemption_value.to_i == redeem_value_arr_params[index].to_i
                    logger.info "111"
                    is_changed_item = true
                    build_menu_id = build_menu_ids[index]
                  end
                else # restaurant owner select a category an link it to prize
                  if category_ids[index] != nil && !category_ids[index].blank?
                    if Category.find(category_ids[index]).redemption_value.to_i == redeem_value_arr_params[index].to_i
                      is_changed_item = true
                      category_id = category_ids[index]
                    end
                  end
                end
              else # restaurant owner hasn't changed redemption value of prize yet
                if build_menu_ids[index] != nil && !build_menu_ids[index].blank?
                  if BuildMenu.find(build_menu_ids[index]).item.redemption_value.to_i == redeem_value_arr_params[index].to_i
                    is_changed_item = true
                    build_menu_id = build_menu_ids[index]
                  end
                else # restaurant owner select a category an link it to prize
                  if category_ids[index] != nil && !category_ids[index].blank?
                    if Category.find(category_ids[index]).redemption_value.to_i == redeem_value_arr_params[index].to_i
                      is_changed_item = true
                      category_id = category_ids[index]
                    end
                  end
                end
              end
                p.update_attributes(
                  :name => name_arr_params[index],
                  :redeem_value => redeem_value_arr_params[index],
                  :build_menu_id => build_menu_id,
                  :category_id => category_id
                )
                # delete item in order linked to prize
                if is_changed_item || (p.build_menu_id.nil? && p.category_id.nil?)
                  Prize.delete_orders_belong_to_prize(location_id, p.id)
                end
              end
            end
          end
          level_delete = level_arr - level_arr_params
          level_delete.each do |delete|
            prize_delete = Prize.where("level=? AND is_delete =? AND status_prize_id=?",delete, 0, @status_prize_id)
            prize_delete.each do |prize|
              prize.update_attribute(:is_delete, 1)
              # delete item in order linked to prize
              Prize.delete_orders_belong_to_prize(location_id, prize.id)
            end
          end

          level_change = []
          prize_change = Prize.where('status_prize_id =? and is_delete= ? ',@status_prize_id,0).order('level ASC')
          prize_change.each do |prize|
            level_change << prize.level.to_i
          end

          level_change.each_with_index do |change, index|
            level = index + 1
            prize_change = Prize.where("level=? AND is_delete =? AND status_prize_id=?",change, 0, @status_prize_id)
            prize_change.each do |prize|
              prize.update_attribute(:level, level)
            end
          end
        end
      end
    else
      prizes = Prize.where("status_prize_id=? AND is_delete=?",@status_prize_id, 0)
      prizes.each do |p|
        p.update_attribute(:is_delete, 1)
        # delete item in order linked to prize
        Prize.delete_orders_belong_to_prize(location_id, p.id)
      end
    end
    respond_to do |format|
      format.js#html { redirect_to prize_points_path(@restaurant), notice: 'The Level Prize is saved successfully' }
    end
  end

  def delete_prize_level
    @level = params[:level]
    @status_prize_id = params[:status_prize_id]
    respond_to do |format|
      format.js
    end
  end

  def action_delete_prize_level

    level = params[:level]
    @status_prize_id = params[:status_prize_id]
    level_prize = Prize.find_by_status_prize_id_and_is_delete_and_level(@status_prize_id, 0,level)
    unless level_prize.nil?
      if !level_prize.level.nil?
        level_prize.update_attribute(:is_delete, 1)
        level_update = Prize.where("status_prize_id=? AND is_delete=? AND level > ?",@status_prize_id, 0, level_prize.level).order('level ASC')
        unless level_update.empty?
          level_update.each do |l|
            count = l.level.to_i - 1

            l.update_attribute(:level, count.to_i)
          end
        end
      end
    end
    @prize = Prize.where("status_prize_id=? AND is_delete=?",@status_prize_id, 0)
    status_prize =StatusPrize.find_by_id(@status_prize_id)
    unless status_prize.nil?
      @restaurant = Location.find_by_id(status_prize.location_id)
    end


    respond_to do |format|
      format.js#html { redirect_to prize_points_path(@restaurant), notice: 'The Level Prize is deleted successfully.' }
    end
  end

  def get_item_and_categories
    redemption_value = params[:redeem_value]
    location_id = params[:location_id]
    item_sql = "SELECT distinct b.id as build_menu_id, i.name FROM items i
      JOIN build_menus b on i.id = b.item_id AND b.active = 1
      JOIN menus m on m.id = b.menu_id AND m.publish_status = 2
      WHERE i.location_id = #{location_id} AND i.redemption_value = #{redemption_value}
      ORDER BY i.name"
    items = Item.find_by_sql(item_sql)

    category_sql = "SELECT distinct c.id as category_id, c.name FROM categories c
      JOIN build_menus b on c.id = b.category_id AND b.active = 1
      JOIN menus m on m.id = b.menu_id AND m.publish_status = 2
      WHERE c.location_id = #{location_id} AND c.redemption_value = #{redemption_value}
      ORDER By c.name"
    categories = Category.find_by_sql(category_sql)

    results = items.uniq | categories.uniq
    render :json => {
      :results => results
    }
  end
end
