require 'cgi'
class LocationsController < ApplicationController
  before_filter :authorise_request_as_json, :only=>[:favourite_global,:favourite_items,:favourite_item_detail, :special_message_search, :show]
  before_filter :authorise_user_param, :except=>[
    :add_comment, :update_comment,
    :add_favourite,:favourite_item_detail,:normal_search,:advance_search, :share_via_social, :search_restaurant_item, :normal_search_v1, :search_restaurant_item_v1, :update_braintree_customer_id]
  before_filter :authenticate_user_json, :only=>[
    :add_comment,:update_comment,
    :add_favourite,:normal_search,:advance_search, :share_via_social, :search_restaurant_item, :show, :search_restaurant_item_v1]
  before_filter :validate_lat_long, :only=>[:advance_search, :normal_search, :normal_search_v1]
  before_filter :validate_radius, :only=>[:advance_search]
  #load_and_authorize_resource
  respond_to :json

  def index
    params[:keyword] ? keyword = params[:keyword] : ''
    params[:latitude] ? latitude = params[:latitude] : 0
    params[:longitude] ? longitude = params[:longitude] : 0
    params[:radius] ? radius_in_miles = params[:radius] : 0
    params[:type] ? type = params[:type] : "default"

    google_places = GooglePlaces::Client.new(GG_PLACES_API_KEY.to_s)
    place_types = ['restaurant','food']

    if type.downcase == "location"
      name = "restaurant in " + keyword.strip
      @locations = google_places.spots_by_query(name, types: place_types)
    else
      # Prepare variables
      radius_in_meters = (radius_in_miles.present? ? (radius_in_miles.to_i * 1609) : nil)

      parameters = {types: place_types, rankby: :distance}
      parameters[:radius] = radius_in_meters if radius_in_meters
      parameters[:name] = keyword if (keyword.present? && type.downcase != "default")

      @locations = google_places.spots(latitude, longitude, parameters)
    end
  end

  def normal_search
    begin
      # Return the nearby locations
      radius = (@parsed_json['radius'].present? ? @parsed_json['radius'] : DEFAULT_SEARCH_RADIUS_IN_MILES)
      @nearby_locations = Location.near([@lat, @lng], radius) # 'near' is a Geocode gem method
    rescue Exception => e
      return render :status => 500, :json => {:status => :failed, errors: e.message}
    end
  end

  def normal_search_v1
    begin
      # Define the parameters
      radius_in_miles = (params['radius'].present? ? params['radius'].to_i : nil)
      restaurant_name = (params['keyword'].present? ? params['keyword'].to_s.mb_chars.downcase.strip : nil)
      @locations = Location.all_nearby_including_unregistered(@lat, @lng, radius_in_miles, restaurant_name)
    rescue Exception => e
      return render :status => 500, :json => {:status => :failed, errors: e.message}
    end
  end

  def advance_search
    begin
      arr_no_condition = []
      arr_have_condition = []
      location_id_array = []
      arr_locations = []
      @locations = []

      restaurant_rating_min = @parsed_json["restaurant_rating_min"] if @parsed_json["restaurant_rating_min"]
      restaurant_rating_max = @parsed_json["restaurant_rating_max"] if @parsed_json["restaurant_rating_max"]
      item_price_min = @parsed_json["item_price_min"] if @parsed_json["item_price_min"]
      item_price_max = @parsed_json["item_price_max"] if @parsed_json["item_price_max"]
      point_offered_min = @parsed_json["point_offered_min"] if @parsed_json["point_offered_min"]
      point_offered_max = @parsed_json["point_offered_max"] if @parsed_json["point_offered_max"]
      item_rating_min = @parsed_json["item_rating_min"] if @parsed_json["item_rating_min"]
      item_rating_max = @parsed_json["item_rating_max"] if @parsed_json["item_rating_max"]
      radius = @parsed_json["radius"] if @parsed_json["radius"]
      item_type = @parsed_json["item_type"] if @parsed_json["item_type"]
      item_type = item_type.join(",")
      menu_type = @parsed_json["menu_type"] if @parsed_json["menu_type"]
      menu_type = menu_type.join(",")
      keyword = @parsed_json["keyword"] if @parsed_json["keyword"]
      keyword = keyword.downcase
      server_rating_min = @parsed_json["server_rating_min"] if @parsed_json["server_rating_min"]
      server_rating_max = @parsed_json["server_rating_max"] if @parsed_json["server_rating_max"]
      keyword = keyword.strip
      keyword = keyword.tr("^,A-Za-z0-9", ' ')

      # build a statement to query restaurants form database which satisfid conditions user chose without type anything on textbox
      sql = Location.build_statement(menu_type, item_rating_max, item_rating_min, point_offered_max, point_offered_min, item_price_max,\
        item_price_min, item_type, server_rating_max, server_rating_min, restaurant_rating_max, restaurant_rating_min)

      # find restaurants by criteria user typed with keyword is blank
      if keyword.blank?
        locations_one = find_by_sql(Location, sql)
        locations_one.each do |l|
          location_id_array << l['id']
        end
        @locations = Location.near_coordinates_with_ids(@lat, @lng, radius, location_id_array)
      else
        # find restaurants by criteria user typed with keyword is not blank
        conditions = Location.split_conditions(keyword)
        arr_have_condition = conditions['conditions']
        arr_no_condition = conditions['no_conditions']

        location_first = Location.find_by_keyword_advance_search(arr_have_condition, arr_no_condition)
        location_first.each do |i|
          arr_locations << i['id']
        end
        if sql.match(/where/)
          sql = sql + " and l.id in (?)"
        else
          sql = sql + " where l.id in (?)"
        end
        locations = find_by_sql(Location,sql,arr_locations.uniq)
        locations.each do |j|
          location_id_array << j['id']
        end
        @locations = Location.near_coordinates(@lat, @lng, radius, location_id_array)
      end
    rescue
      return render :status => 500, :json => {:status=>:failed}
    end
  end

  def run_default_search
    begin
      @profile = SearchProfile.find_by_id(params[:search_profile_id].to_i)
      lat = params[:latitude].to_f if params[:latitude]
      long = params[:longitude].to_f if params[:longitude]
      if @profile.nil?
        return render :status => 404, :json => {:status => :failed, :error => "Invalid search profile"}
      end
      restaurant_rating_min = @profile.location_rating.split(",").first.to_f
      restaurant_rating_max = @profile.location_rating.split(",").last.to_f
      item_price_min = @profile.item_price.split(",").first.to_f
      item_price_max = @profile.item_price.split(",").last.to_f
      point_offered_min = @profile.item_reward.split(",").first.to_i
      point_offered_max = @profile.item_reward.split(",").last.to_i
      item_rating_min = @profile.item_rating.split(",").first.to_f
      item_rating_max = @profile.item_rating.split(",").last.to_f
      radius = @profile.radius.to_i
      item_type = @profile.item_type
      menu_type = @profile.menu_type
      keyword = @profile.text
      keyword = keyword.downcase
      keyword = keyword.tr("^,A-Za-z0-9", ' ')
      server_rating_min = @profile.server_rating.split(",").first.to_f if !@profile.server_rating.nil?
      server_rating_max = @profile.server_rating.split(",").last.to_f if !@profile.server_rating.nil?
      arr_no_condition = []
      arr_have_condition = []
      arr_locations = []
      @locations = []
      location_id_array =[]

      # build a statement to query restaurants form database which satisfid conditions user chose without type anything on textbox
      sql = Location.build_statement(menu_type, item_rating_max, item_rating_min, point_offered_max, point_offered_min, item_price_max,\
      item_price_min, item_type, server_rating_max, server_rating_min, restaurant_rating_max, restaurant_rating_min)

      # find restaurants by criteria user typed with keyword is blank
      if keyword.blank?
        locations_one = find_by_sql(Location, sql)
        locations_one.each do |i|
          location_id_array << i['id']
        end
        @locations = Location.near_coordinates(lat, long, radius, location_id_array)
      else
        # find restaurants by criteria user typed with keyword is not blank
        conditions = Location.split_conditions(keyword)
        arr_have_condition = conditions['conditions']
        arr_no_condition = conditions['no_conditions']

        location_first = Location.find_by_keyword_advance_search(arr_have_condition, arr_no_condition)
        location_first.each do |j|
          arr_locations << j['id']
        end
        if sql.match(/where/)
          sql = sql + " and l.id in (?)"
        else
          sql = sql + " where l.id in (?)"
        end
        locations = find_by_sql(Location,sql, arr_locations)
        locations.each do |k|
          location_id_array << k['id']
        end
        @locations = Location.near_coordinates(lat, long, radius, location_id_array)
      end
    rescue
      return render :status => 500, :json => {:status=>:failed}
    end
  end

  def show
    begin
      ActiveRecord::Base.transaction do
        user_id = @user ? @user.id : nil
        params[:id] ? location_id = params[:id].to_i : nil
        if location_id.blank?
          return render :status => 412, :json => {:status=>:failed, :error=>"Invalid Location ID"}
        end
        location = Location.find_by_id(location_id)

        if location.blank?
          return render :status => 412, :json => {:status=>:failed, :error=>"Invalid Location ID"}
        end
        location.google_url = CGI::escape(location.google_url) if !location.try(:google_url).blank?
        location.twiter_url = CGI::escape(location.twiter_url) if !location.try(:twiter_url).blank?
        location.facebook_url = CGI::escape(location.facebook_url) if !location.try(:facebook_url).blank?
        location.instagram_username = CGI::escape(location.instagram_username) if !location.try(:instagram_username).blank?
        location.com_url = CGI::escape(location.com_url) if !location.try(:com_url).blank?
        @location = location
        check_visited = LocationVisited.where("location_id = ? AND user_id = ?", @location.try(:id), user_id).first
        if check_visited.blank?
          location_visited = LocationVisited.new
          location_visited.location_id = @location.try(:id)
          location_visited.user_id = user_id
          location_visited.visited = 1
          location_visited.save!
        else
          check_visited.update_attributes!(:visited => check_visited.visited + 1)
        end
        sql ="SELECT l.id, SUM( CASE WHEN u.is_give = 1 THEN u.points ELSE u.points*(-1) END) as total
            FROM locations l JOIN user_points u ON l.id = u.location_id
            WHERE u.user_id =#{user_id} AND u.location_id =#{location_id}"
        @point = Location.find_by_sql(sql).first
        @favourite=LocationFavourite.find_by_location_id_and_user_id(@location, @user.id)
        @hour_of_operation = HourOperation.get_hour_operation_v1(@location.id)
        suspend = CustomersLocations.where("location_id =? and user_id = ?", location_id, @user.id).select("is_deleted").first
        if suspend.blank?
           suspend = CustomersLocations.new
           suspend.is_deleted = 0
        end
        @suspend = suspend
        location_packages = @location.subscriptions.map(&:subscription_id)
        @packages = SubscriptionFetcher.new(location_packages, no_stats: true).subscriptions
      end
    rescue => e
      render :status => 500, :json => {:status=>:failed, :error => e.message}
    end
  end

  def menu_type
    @menu_type = MenuType.joins(:menus).where('publish_status = ?', 2).uniq.order("name")
  end
  def item_type
    @item_type = ItemType.all
  end

  def search
    @locations = Location.search_location(params[:search])
  end

  def menu
    user_id = @user ? @user.id : nil
    params[:id] ? location_id = params[:id] : nil
    @location = Location.find_by_id(location_id)
    return :status => 404, :json => {:status => :failed, :error => "Resource not found"} if @location.nil?
    begin
      @categories = Location.get_categories(user_id, location_id)
      sql = "SELECT locations.id as location_id, #{user_id} as user_id,
              IFNULL(SUM(CASE WHEN user_points.is_give = 1 THEN user_points.points ELSE user_points.points*(-1) END),0) as total
             FROM `locations` INNER JOIN `user_points` ON `user_points`.`location_id` = `locations`.`id`
             WHERE `locations`.`active` = 1 AND (locations.id = #{location_id} AND user_points.user_id = #{user_id}
              AND user_points.status = 1)"
      @prizes = Prize.find_by_sql(sql)
    rescue
      render :status => 500, :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  def comments
    limit = params[:limit]
    offset = params[:offset]
    location_id = params[:id]
    begin
      location = Location.find(params[:id])
      if location.nil?
        return render :status =>404, :json => {:status=>:failed, :error=>"Invalid Location ID"}
      end
      if (!limit.nil? && !offset.nil?)
        @comments = location.location_comments.limit(limit).offset(offset).order("updated_at DESC")
      else
        @comments = location.location_comments.order("updated_at DESC")
      end
    rescue
      render :status => 500, :json => {:status => :failed}
    end
  end

  def update_comment
    begin
      location = Location.find(params[:id].to_i)

      # check suspend status of user in a restaurant
      customer_location = CustomersLocations.find_by_location_id_and_user_id(location.id, @user.id)
      if !customer_location.nil?
        return render :status => 403, :json => {
          :status => :failed,
          :error => :Forbidden,
          :is_suspended => customer_location.is_deleted
        } if customer_location.is_deleted == 1
      else
        new_contact = CustomersLocations.new
        new_contact.location_id = location.id
        new_contact.user_id = @user.id
        new_contact.is_deleted = 0
        new_contact.save
      end

      ActiveRecord::Base.transaction do
        comment_id = @parsed_json["comment_id"] if @parsed_json["comment_id"]
        comment = location.location_comments.find(comment_id)
        comment.rating      =  @parsed_json["rating"] if @parsed_json["rating"]
        comment.text        =  @parsed_json["comment"] if @parsed_json["comment"]
        comment.save(validate: false)
        CustomersLocations.add_contact(Array([@user.id]), location.id)

        location.update_attributes!(:rating => location.current_rating)
        render :status => 200, :json => {:status => :success,:rating => location.current_rating}
      end
    rescue
      render :status => 500, :json => {:status=> :failed, :error => "Internal Server Error"}
    end
  end

  def add_comment
    begin
      # Set variables
      location_id = params[:id].to_i
      rating = @parsed_json["rating"] if @parsed_json["rating"]
      comment = @parsed_json["comment"] if @parsed_json["comment"]

      # Retrieve records
      location = Location.find_by_id(location_id)
      if location.nil?
        return render :status => 404, :json => {:status => :failed, :error => "Resource not found"}
      end
      menu = location.menus.where(publish_status: 2).first

      # check suspend status of user in a restaurant
      customer_location = CustomersLocations.find_by_location_id_and_user_id(location_id, @user.id)
      if customer_location.present?
        return render status: 403, json: {
          status: :failed, error: :Forbidden, is_suspended: customer_location.is_deleted
        } if customer_location.is_deleted == 1
      else
        CustomersLocations.add_contact([@user.id], location.id)
      end

      # Create the LocationComment and, if applicable, the Notification
      ActiveRecord::Base.transaction do
        # Create a LocationComment
        location_comment = location.location_comments.new(
          user_id: @user.id,
          location_id: location_id,
          rating: rating,
          text: comment
        )
        location_comment.save(validate: false)

        # Update the Location's averate rating
        location.update_attributes!(rating: location.current_rating)

        # If applicable, send a Notification
        if !menu.nil? && !menu.rating_grade.nil? && rating.present?
          if rating > menu.rating_grade
            params = {
              from_user: @user.id,
              to_user: location.owner.email,
              msg_type: 'single',
              msg_subject: RATING_MESSAGE,
              message: "Points added for rating restaurant #{location.name}",
              alert_type: 'Restaurant Rating',
              alert_logo: RATING_LOGO,
              location_id: location_id,
              product_comment: comment,
              location_comment_id: location_comment.id
            }
            Notifications.create(params)
          end
        end
        return render status: 200, json: {status: :success, rating: location.current_rating}
      end
    rescue => e
      return render status: 500, json: {status: :failed, error: e.message}
    end
  end

  def add_favourite
    begin
      user_id = @user ? @user.id : nil
      location_id = params[:id].to_i
      is_favourite = (@parsed_json["is_favourite"] == 1 || @parsed_json["is_favourite"] == '1' || @parsed_json["is_favourite"] == true || @parsed_json["is_favourite"] == 'true') ? true : false
      @location = Location.find(location_id.to_i)
      @favourite=LocationFavourite.find(:first,:conditions =>['location_id =? and user_id=?',location_id,user_id])
      ActiveRecord::Base.transaction do
        CustomersLocations.add_contact(Array([user_id]), location_id)

        if !@favourite.nil?
          is_updated = @favourite.update_attribute(:favourite, is_favourite)
          if is_updated
            return render :status => 200, :json => {:status => :success}
          else
            return render :status => 503, :json => {:status => :failed}
          end
        else
          favourite = @location.location_favourites.new
          favourite.user_id     =  user_id.to_i
          favourite.location_id =  location_id.to_i
          favourite.favourite   =  @parsed_json["is_favourite"] if @parsed_json["is_favourite"]
          is_saved = favourite.save
          if is_saved
            return render :status => 200, :json => {:status => :success}
          else
            return render :status => 503, :json => {:status => :failed}
          end
        end

      end
    rescue => e
      render :status => 500, :json => {:status=> :failed, :error => e.message}
    end
  end

  def search_restaurant_item
    begin
      current_user = User.find_all_by_authentication_token(@parsed_json["access_token"]).first
      @parsed_json["location_id"] ? location_id = @parsed_json["location_id"].to_i : nil
      if location_id.nil? || location_id == 0
        render :status => 404, :json=>{:status=> :failed, :error=>"Invalid location"}
        return
      end
      keyword = @parsed_json["keyword"]
      keyword = keyword.gsub(/%/,"\\%")
      @items = Item.search_items(current_user.id, location_id.to_i, fix_special_character(keyword))
    rescue => e
      return render :status => 500, :json=>{:status=> :failed, :error => e.message}
    end
  end

  def search_restaurant_item_v1
    begin
      current_user = User.find_all_by_authentication_token(@parsed_json["access_token"]).first
      @parsed_json["location_id"] ? location_id = @parsed_json["location_id"].to_i : nil
      if location_id.nil? || location_id == 0
        return render :status => 404, :json=>{:status=> :failed, :error=>"Invalid location"}
      end
      keyword = @parsed_json["keyword"]
      keyword = keyword.gsub(/%/,"\\%")
      @items = Item.search_items(current_user.id, location_id.to_i, fix_special_character(keyword))
    rescue => e
      return render :status => 500, :json=>{:status=> :failed, :error => e.message}
    end
  end

  #Get favourite global
  def favourite_global
    @fav = Location.favourite_global(@user.id).uniq{|location| location.id}
  end

  #Get favourite by chain
  def favourite_restaurant
    chain_name = params[:chain_name] if params[:chain_name]

    if chain_name=='' || chain_name.nil?
      render :status => 412, :json=>{:status=>:failed, :error => "Chain name is required"}
      return
    else
      chain_name = fix_special_character(params[:chain_name])
      @fav = Location.favourite_by_chain(chain_name, @user.id).uniq{|l| l.id}
    end
    
  end

  #Get list item favourite
  def favourite_items
    current_location = params[:location_id] if params[:location_id]
    if current_location=='' || current_location.nil?
      render :status => 412, :json=>{:status=>:failed, :error => "location is required"}
      return
    else
      @items = Item.items_favourite(@user.id, current_location).uniq{|i| i.id}
      @servers = Server.servers_favourite(@user.id, current_location)
    end
  end

  def share_via_social
    # add user to sharing restaurant group
    begin
      @parsed_json["location_id"] ? location_id = @parsed_json["location_id"].to_i : nil
      if location_id.nil? || location_id == 0
        return render :status => 404, :json => {:status => :failed, :error => "Invalid Location ID"}
      end
      return render :status => 200, :json => {:status => :success}
    rescue
      return render :status => 500, :json => {:status => :failed}
    end
  end

  def special_message_search
    begin
      params[:latitude] ? lat = params[:latitude].to_f : nil
      params[:longitude] ? lng = params[:longitude].to_f : nil
      params[:radius] ? radius = params[:radius].to_i : nil
      if lat.nil? || lng.nil? || radius.nil?
        return render :status => 412, :json => {:status => :failed, :error => "Incorrect params"}
      end
      locations = Location.get_restaurants_by_special_message(radius, lat, lng)
      return render :status => 200, :json => locations
    rescue
      return render :status => 503,:json=>{:status => :failed, :error => "Service Unavailable"}
    end
  end

  def update_braintree_customer_id
    @location = Location.find(params[:id])
    if @location.update_attributes(customer_id: params[:customer_id])
      flash.now[:success] = 'Braintree ID successfully updated'
    else
      flash.now[:error] = @location.errors.full_messages.to_sentence
    end
  end



  private

    def validate_lat_long
      if (params["latitude"] && params["longitude"])
        @lng = params["longitude"]
        @lat = params["latitude"]
      else
        render :status => 412, :json => {:status => :failed, :error => "Mising latitude and/or longitude parameter"}
      end
    end

    def validate_radius
      if (@parsed_json["radius"].to_f <= 0)
        render :status => 400,:json => {:status => :failed, :error => "Radius must be more than 0 mile"}
      end
    end
end
