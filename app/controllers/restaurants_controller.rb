require 'net/http'

class RestaurantsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :set_cache_buster
  load_and_authorize_resource :class => "Location"

  # GET /locations
  # GET /locations.json
  def index
    @restaurants = []
    if current_user.admin?
      params[:search] ? @search_params = params[:search] : ""
      unless @search_params.nil? || @search_params.blank?
        str = String.new(@search_params)
        app_service_id = 0

        unless /^\w+$/ === str
          str = str.gsub!(/\W/, "")
        end

        unless str.length == 0
          plan_id = ""
          packages = []
          BraintreeRails::Plan.all.each do|i|
            packages << [i.id, i.name]
          end
          packages.each do|j|
            if j[1].downcase.match(/#{str}/)
              plan_id = j[0]
              break
            end
          end
          app_service = AppService.find_by_name(plan_id)
          unless app_service.nil?
            app_service_id = app_service.id
          end
        end

        @restaurants = Location.joins("LEFT JOIN users ON users.id = locations.owner_id")
          .where("locations.name LIKE '%#{fix_special_character(@search_params)}%' OR users.email LIKE '%#{fix_special_character(@search_params)}%' OR users.app_service_id = #{app_service_id}")
          .order('locations.id DESC').page(params[:page]).per(10)
      else
        @restaurants = Location.order('id DESC').page(params[:page]).per(10)
      end
      # @restaurants = Location.order('id DESC').page(params[:page]).per(10)
    elsif current_user.owner?
      @restaurants = current_user.restaurants.order('id DESC').page(params[:page]).per(10)
    elsif current_user.restaurant_admin?
      @restaurants = Location.where_by_rsr_admin(current_user.id).order('id DESC').page(params[:page]).per(10)
    elsif current_user.restaurant_manager?
      @restaurants = Location.where_by_rsr_manager(current_user.id).order('id DESC').page(params[:page]).per(10)
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    @restaurant = Location.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    if current_user.limit_available?
      @restaurant = Location.new
      #add hour operation
      @group_hour = []
      #end
      @location_logo = @restaurant.build_logo
      @location_images = []
      5.times { @location_images << @restaurant.images.build }
      @page = Page.find_by_name("New Restaurant How it works")

      # 5.times {@restaurant.location_images.build}
      respond_to do |format|
        format.html # new.html.erb
      end
    else
      redirect_to restaurants_path, :notice => 'Restaurant limitted'
    end
  end

  # GET /locations/1/edit
  def edit
    @restaurant = Location.find(params[:id])
    #add code hour operation
    @group_hour = []

    unless @restaurant.nil?
      @hour_operation = HourOperation.where("location_id=?",@restaurant.id).order('group_hour ASC')
      unless @hour_operation.empty?
        @hour_operation.each do |h|
          @group_hour << h.group_hour
        end
        @group_hour = @group_hour.uniq
      end

    @hash = Gmaps4rails.build_markers(@restaurant) do |rest, marker|
      marker.lat rest.lat
      marker.lng rest.long
      marker.infowindow "Click for new location!!"
      marker.json({title: rest.id})
    end

    end

    #end

    @check = false
    unless @restaurant.nil?
      owner_id = @restaurant.owner_id
      if current_user.id.to_i == owner_id.to_i || current_user.admin?
        @check = true
      end
    end

    @location_logo = @restaurant.logo
    @location_logo ||= @restaurant.build_logo
    @location_images
    5.times do |index|
      img = @restaurant.location_image_photos.where(index: index).first
      img = @restaurant.location_image_photos.create(index: index) if img.nil?
      img.build_photo if img.photo.nil?

    end

    if @check == false
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/restaurant", :layout => false }
      end
    end

  end

  def upload_image
    if params[:location_image][:crop_x].to_i == 0 && params[:location_image][:crop_y].to_i == 0 \
        && params[:location_image][:crop_w].to_i == 0 && params[:location_image][:crop_h].to_i == 0
      @location_image = LocationImage.where('location_token = ? AND `index` = ? AND location_id is ?',
                                            params[:location_image][:location_token], params[:location_image][:index], nil).order("id").first
    else
      @location_image_old = LocationImage.where('location_token = ? AND `index` = ?',
                                                params[:location_image][:location_token], params[:location_image][:index]).order("id").last
      if @location_image_old.nil?
        @location_image = @location_image_old
      else
        @location_image = @location_image_old.dup
        #@location_image.image = @location_image_old.image
        @location_image.location_id = nil
      end
    end

    if @location_image.nil?
      @location_image = LocationImage.new
    end
    if !params[:location_image][:image].nil?
      array_image = params[:location_image][:image].original_filename.split('.').last
      params[:location_image][:image].original_filename = "#{DateTime.now.strftime("%Y_%m_%d_%H_%M_%S")}" + "." + array_image.to_s
    end
    @location_image.image = params[:location_image][:image]
    @location_image.location_token = params[:location_image][:location_token]
    @location_image.index = params[:location_image][:index]
    @location_image.crop_x = params[:location_image][:crop_x]
    @location_image.crop_y = params[:location_image][:crop_y]
    @location_image.crop_w = params[:location_image][:crop_w]
    @location_image.crop_h = params[:location_image][:crop_h]
    @location_image.rate = params[:location_image][:rate]
    respond_to do |format|
      @location_image.save(:validate=>false)
      format.js
    end
  end

  def upload_logo
    if params[:location_logo][:crop_x].to_i == 0 && params[:location_logo][:crop_y].to_i == 0 \
        && params[:location_logo][:crop_w].to_i == 0 && params[:location_logo][:crop_h].to_i == 0
      @location_logo = LocationLogo.where('location_token = ? AND location_id is ?', params[:location_logo][:location_token], nil).order("id").first
    else
      @location_logo_old = LocationLogo.where('location_token = ?', params[:location_logo][:location_token]).order("id").last
      if @location_logo_old.nil?
        @location_logo = @location_logo_old
      else
        @location_logo = @location_logo_old.dup
        #@location_logo.image = @location_logo_old.image
        @location_logo.location_id = nil
      end
    end

    if @location_logo.nil?
      @location_logo = LocationLogo.new
    end
    if !params[:location_logo][:image].nil?
      array_logo = params[:location_logo][:image].original_filename.split('.').last
      params[:location_logo][:image].original_filename = "#{DateTime.now.strftime("%Y_%m_%d_%H_%M_%S")}" + "." + array_logo.to_s
    end
    @location_logo.image = params[:location_logo][:image]
    @location_logo.location_token = params[:location_logo][:location_token]
    @location_logo.crop_x = params[:location_logo][:crop_x]
    @location_logo.crop_y = params[:location_logo][:crop_y]
    @location_logo.crop_w = params[:location_logo][:crop_w]
    @location_logo.crop_h = params[:location_logo][:crop_h]
    @location_logo.rate = params[:location_logo][:rate]
    respond_to do |format|
      @location_logo.save(:validate=>false)
      format.js
    end
  end

  # POST /locations
  # POST /locations.json
  def create

    if current_user.limit_available?
      @restaurant = Location.new(params[:restaurant])

      1.times do
        @location_dates = @restaurant.location_dates.build
      end

      @restaurant.owner_id = @restaurant.last_updated_by = current_user.id
      # @restaurant.created_by = current_user.id
      # if current_user.has_parent?
      #   @restaurant.owner_id = current_user.parent_user_id
      # else
      #   @restaurant.owner_id = current_user.id
      # end
      @location_logo = LocationLogo.find_by_location_token(@restaurant.token)
      if not @location_logo.nil?
        @restaurant.location_logo = @location_logo
      end
      @location_images = LocationImage.where('location_token = ?', @restaurant.token)
      if not @location_images.empty?
        @restaurant.location_images = @location_images
      end

      respond_to do |format|
        if @restaurant.save
          #create hour operation
          location_id = @restaurant.id
          days = params[:restaurant][:days]
          time_open = params[:restaurant][:time_open]
          time_close = params[:restaurant][:time_close]
          unless days.nil?
            unless days.empty?
              group_count = days.count
              days.each_with_index do |day, index|
                if index + 1 <= group_count
                  group_hour = day[0]
                  group_day = day[1]
                  unless group_day.empty?
                    group_day.each do |g|
                      if g.to_s == GROUP_DAY_EVERY
                        # group_day.delete("9")
                        group_day = group_day + GROUP_DAY_EVERY_REPLACE
                      end
                    end
                  end
                  unless group_day.empty?
                    group_day.each do |g|
                      if g.to_s == GROUP_DAY_WEEKENDS
                        # group_day.delete("10")
                        group_day = group_day + GROUP_DAY_WEEKENDS_REPLACE
                      end
                    end
                  end


                  unless group_hour.nil? && group_day.empty?
                    group_day.each do |day|
                      if (day.to_i > 1) && (day.to_i <9)
                        unless time_open[index] == "" || time_close[index] == ""
                          HourOperation.create({
                            :day =>  day,
                            :time_open => time_open[index],
                            :time_close => time_close[index],
                            :location_id => location_id,
                            :group_hour => group_hour
                          })
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          #end
          format.html {redirect_to restaurants_path, :notice=> 'Restaurant was created successfully.' }
          format.js { flash[:notice] = 'Restaurant was created successfully.' }
        else
          @location_logo = @restaurant.logo
          @location_logo ||= @restaurant.build_logo
          location_images_temporary = @restaurant.images
          @location_images = []
          5.times do |index|
            img = location_images_temporary.where(idx: index).first
            img ||= @restaurant.images.build(idx: index)
          end
          format.html { render action: "new" }
          format.js
        end
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update
    @restaurant = Location.find(params[:id])
    @check = false
    unless @restaurant.nil?
      owner_id = @restaurant.owner_id
      if current_user.id.to_i == owner_id.to_i || current_user.admin?
        @check = true
      end
    end
    if @check == false
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/restaurant", :layout => false }
      end
    else
      #add hour operation

      days = params[:restaurant][:days]
      time_open = params[:restaurant][:time_open]
      time_close = params[:restaurant][:time_close]
      if days.nil?
        hour_operation = HourOperation.where("location_id=? ", @restaurant.id)
        unless hour_operation.empty?
          hour_operation.destroy_all
        end
      else
        unless days.empty?
          hour_operation = HourOperation.where("location_id=? ", @restaurant.id)
          unless hour_operation.empty?
            hour_operation.destroy_all
          end
          group_count = days.count
          days.each_with_index do |day, index|
            if index + 1 <= group_count
              group_hour = day[0]
              group_day = day[1]
              unless group_day.empty?
                group_day.each do |g|
                  if g.to_s == GROUP_DAY_EVERY
                    # group_day.delete("9")
                    group_day = group_day + GROUP_DAY_EVERY_REPLACE
                  end
                end
              end
              unless group_day.empty?
                group_day.each do |g|
                  if g.to_s == GROUP_DAY_WEEKENDS
                    # group_day.delete("10")
                    group_day = group_day + GROUP_DAY_WEEKENDS_REPLACE
                  end
                end
              end
              # end
              #unless group_hour.nil?



                unless group_day.empty? && group_hour.nil?
                  group_day.each do |day|
                    if (day.to_i > 1) && (day.to_i <9)
                      unless time_open[index] == "" || time_close[index] == ""
                        HourOperation.create({
                          :day =>  day,
                          :time_open => time_open[index],
                          :time_close => time_close[index],
                          :location_id => @restaurant.id,
                          :group_hour => group_hour
                        })
                      end
                    end
                  end
                end
              #end
            end
          end
        end
      end
      #end hour operation.
      #@location_logo = LocationLogo.where('location_token = ?', @restaurant.token).last
      #@restaurant.location_logo = @location_logo unless @location_logo.nil?
      @restaurant.last_updated_by = current_user.id
      location_image_ids = []
      5.times do |index|
        location_image = LocationImage.where('location_token = ? AND `index` = ?', @restaurant.token, index).order("updated_at").last
        if not location_image.nil?
          #@restaurant.location_images << location_image
          location_image_ids << location_image.id
        end
      end
      access_token = @restaurant.token

      respond_to do |format|
        if @restaurant.update_attributes(params[:restaurant])

          local_logo = LocationLogo.where('location_token = ?', @restaurant.token)
          last_lo_logo = local_logo.last

          if !local_logo.blank?
            local_logo.each do |lo_logo|
              if last_lo_logo.id != lo_logo.id
                lo_logo.destroy
              end
            end
          end

          @location_logo = LocationLogo.where('location_token = ?', access_token).last
          unless @location_logo.blank?
            @location_logo.location_id = @restaurant.id
            @location_logo.save!(:validate=>false)
          end

          5.times do |index|
            local_image = LocationImage.where('location_token = ? AND `index` = ?', @restaurant.token, index).order("updated_at")
            last_local_image = local_image.last

            if !local_image.blank?
              local_image.each do |local_img|
                if last_local_image.id != local_img.id
                  local_img.destroy
                end
              end
            end

            location_image = LocationImage.where('location_token = ? AND `index` = ?', access_token, index).order("updated_at").last
            unless location_image.blank?
              location_image.location_id = @restaurant.id
              location_image.save!(:validate=>false)
            end
          end
          #LocationLogo.destroy_all(['location_token = ? AND id != ?', @restaurant.token, @location_logo.id]) unless @location_logo.nil?
          #LocationImage.destroy_all(['location_token = ? AND id NOT IN (?)', @restaurant.token, location_image_ids]) unless location_image_ids.empty?
          format.html { redirect_to restaurants_path, :notice=> 'Restaurant was updated successfully.' }
          format.js { flash[:notice] = 'Restaurant was updated successfully.' }
        else
          @location_logo = @restaurant.location_logo
          @location_logo = LocationLogo.new if @location_logo.nil?
          location_images_temporary = @restaurant.location_images
          @location_images = []
          5.times do |index|
            loc_img = LocationImage.new
            location_images_temporary.each_with_index do |location_image, i|
              if location_image.index == index
                loc_img = location_image
                location_images_temporary.delete_at(i)
              end
            end
            @location_images << loc_img
          end
          format.html { render action: "edit" }
          format.js
        end
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @restaurant = Location.find(params[:id])
    # add new function
    if current_user.admin?
      if !@restaurant.nil? && !@restaurant.owner_id.nil?
        restaurant_count = Location.where(:owner_id => @restaurant.owner_id).count

        if restaurant_count == 1
          owner = User.find_by_id(@restaurant.owner_id)

          if !owner.nil? && !owner.admin?
            customer_id = owner.customer_id
            owner.destroy
            if !customer_id.nil?
              begin
                result = Braintree::Customer.delete("#{customer_id}")
                if result.success?
                  puts "customer successfully deleted"
                else
                  raise "this should never happen"
                end
              rescue Exception => e
                puts "error"
              end
            end
            # result = Braintree::Customer.delete("#{owner.customer_id}") unless result.nil?
            # unless result.nil?
            #   if result.success?
            #     puts "customer successfully deleted"
            #   else
            #     raise "this should never happen"
            #   end
            # end
          end
        end
      end
    end

    if !@restaurant.nil? && !@restaurant.rsr_manager.nil?
      arr_manager = @restaurant.rsr_manager.split(',')
      rsr_manager = arr_manager[0].to_i
      user_delete = User.find_by_id(rsr_manager)

      if !user_delete.nil? && rsr_manager != current_user.id.to_i && rsr_manager != @restaurant.owner_id.to_i
        user_delete.destroy
      end
    end

    unless @restaurant.nil?
      menus = @restaurant.menus
      unless menus.empty?
        menus.each do |m|
          build_menu = BuildMenu.unscoped.where("menu_id=? AND active=?", m.id,0)

          unless build_menu.empty?
            build_menu.each do |b|
              b.destroy
            end
          end
        end
      end
    end
    # end
    @restaurant.destroy

    respond_to do |format|
      format.js { flash[:notice] = 'Restaurant was deleted successfully.' }
      format.json { head :no_content }
      format.html { redirect_to :back }
    end
  end


  # Get /restaurants/:id/step3
  # not in used can be removed
  #  def step3
  #    @restaurant = Location.find(params[:id])
  #  end

  # def analytics

  #   @restaurant = Location.find(:all,:conditions=>['owner_id=?',current_user.id])
  #   @redeem= UserPoints.find_by_sql("SELECT sum(points) as totalpoints,location_id from user_points  where (strftime('%Y-%m-%d',created_at) ='"+Time.now.strftime('%Y-%m-%d')+"' and point_type= 'points Redeemed')  group by location_id")

  # end

  # def resetredeem

  # end

  # def resetpassword
  #   location_id= params[:location_id]
  #   old_password= params[:old_password]
  #   new_password= params[:new_password]
  #   location=Location.find(:first,:conditions=>['id=? and redemption_password=?',location_id,old_password])

  #   if location.blank?
  #    # render :text=>"Old Password not Correct"
  #     redirect_to :action => "resetredeem" ,:value=>"Old Password not Correct",:id=>location_id
  #   else
  #     Location.where('id=? and redemption_password=?',location_id,old_password).update_all(:redemption_password=>new_password)
  #     redirect_to :action => 'index',:controller =>"restaurants" ,:value=>"Code edited successfully"
  #   end


  # end

  def dashboard
    @restaurant = Location.find params[:id]
    @menu_items = @restaurant.items
    @prizes = Prize.where(status_prize_id: @restaurant.status_prizes.pluck(:id))

    respond_to do |format|
      format.html { }
      format.json {
        period = params[:period_id].present? ? params[:period_id].to_i : 1
        @checkins = @restaurant.checkins.includes(:user)
        @socials = @restaurant.social_shares
        @item_ids = params[:item_id].present? ? [params[:item_id]] : @restaurant.items.pluck(:id)
        @prize_ids = params[:prize_id].present? ? [params[:prize_id]] : @prizes.pluck(:id)
        @comments = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids})

        @new_ids = @checkins.select('min(id)').group(:user_id)
        @new_customers = @checkins.where(id: @new_ids)
        @returning_customers = @checkins.where("id NOT IN (?)", @new_ids.pluck(:id))

        case params[:filter]
        when 'year'
          #@checkin_count = @checkins.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
          @checkin_count = @checkins.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
          @zipcode_count = @checkins.joins(:user).group_by_week('checkins.created_at', range: period.years.ago..(period-1).years.ago).count('users.zip', distinct: true)
          # @feedback_count = @comments.group_by_week('item_comments.created_at', range: period.years.ago..(period-1).years.ago).count
          @feedback_count = @comments.group_by_week('item_comments.created_at', range: period.years.ago..(period-1).years.ago).count
          @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_week('item_favourites.created_at', range: period.years.ago..(period-1).years.ago).count
          @order_count = OrderItem.where(item_id: @item_ids).group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
          @social_count = @socials.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
          @new_customer_count = @new_customers.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
          @returning_customer_count = @returning_customers.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
          @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count

          @feedback_rating = @comments.group_by_week('item_comments.created_at', range: period.years.ago..(period-1).years.ago).group(:rating).count
          # @redeem_count = PrizeRedeem.where(prize_id: Prize.where(status_prize_id: @restaurant.status_prizes.pluck(:id)))


          #@social_count = SocialShare.where(item_id: @item_ids).group_by_week('created_at', range: period.years.ago..(period-1).years.ago).count
          # @redeems = PrizeRedeem.where(id: @item.prizes.plurk(:id))
          # @redeem_count = @redeems.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
        when 'month'
          @checkin_count = @checkins.group_by_day(:created_at, range: period.months.ago..(period-1).months.ago).count
          @zipcode_count = @checkins.joins(:user).group_by_day('checkins.created_at', range: period.months.ago..(period-1).months.ago).count('users.zip', distinct: true)
          @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_comments.created_at', range: period.months.ago..(period-1).months.ago).count
          @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_favourites.created_at', range: period.months.ago..(period-1).months.ago).count
          @order_count = OrderItem.where(item_id: @item_ids).group_by_day(:created_at, range: period.months.ago..(period-1).months.ago).count
          @social_count = @socials.group_by_day(:created_at, range: period.months.ago..(period-1).months.ago).count
          @new_customer_count = @new_customers.group_by_day(:created_at, range: period.months.ago..(period-1).months.ago).count
          @returning_customer_count = @returning_customers.group_by_day(:created_at, range: period.months.ago..(period-1).months.ago).count
          @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_day(:created_at, range: period.months.ago..(period-1).months.ago).count
          @feedback_rating = @comments.group_by_day('item_comments.created_at', range: period.months.ago..(period-1).months.ago).group(:rating).count

        when 'week'
          @checkin_count = @checkins.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
          @zipcode_count = @checkins.joins(:user).group_by_day('checkins.created_at', range: period.weeks.ago..(period-1).weeks.ago).count('users.zip', distinct: true)
          @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_comments.created_at', range: period.weeks.ago..(period-1).weeks.ago).count
          @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_favourites.created_at', range: period.weeks.ago..(period-1).weeks.ago).count
          @order_count = OrderItem.where(item_id: @item_ids).group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
          @social_count = @socials.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
          @new_customer_count = @new_customers.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
          @returning_customer_count = @returning_customers.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
          @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
          @feedback_rating = @comments.group_by_day('item_comments.created_at', range: period.weeks.ago..(period-1).weeks.ago).group(:rating).count

        when 'day'
          @checkin_count = @checkins.group_by_hour(:created_at, range: period.days.ago..(period-1).days.ago).count
          @zipcode_count = @checkins.joins(:user).group_by_hour('checkins.created_at', range: period.days.ago..(period-1).days.ago).count('users.zip', distinct: true)
          @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_hour('item_comments.created_at', range: period.days.ago..(period-1).days.ago).count
          @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_hour('item_favourites.created_at', range: period.days.ago..(period-1).days.ago).count
          @order_count = OrderItem.where(item_id: @item_ids).group_by_hour(:created_at, range: period.days.ago..(period-1).days.ago).count
          @social_count = @socials.group_by_hour(:created_at, range: period.days.ago..(period-1).days.ago).count
          @new_customer_count = @new_customers.group_by_hour(:created_at, range: period.days.ago..(period-1).days.ago).count
          @returning_customer_count = @returning_customers.group_by_hour(:created_at, range: period.days.ago..(period-1).days.ago).count
          @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_hour(:created_at, range: period.days.ago..(period-1).days.ago).count
          @feedback_rating = @comments.group_by_hour('item_comments.created_at', range: period.days.ago..(period-1).days.ago).group(:rating).count

        end
        @checkin_count = @checkin_count.map { |k, v| [k.to_i * 1000, v] }
        @zipcode_count = @zipcode_count.map { |k, v| [k.to_i * 1000, v] }
        @feedback_count = @feedback_count.map { |k, v| [k.to_i * 1000, v] }
        @favourite_count = @favourite_count.map { |k, v| [k.to_i * 1000, v] }
        @order_count = @order_count.map { |k, v| [k.to_i * 1000, v] }
        @social_count = @social_count.map { |k, v| [k.to_i * 1000, v] }
        @new_customer_count = @new_customer_count.map { |k, v| [k.to_i * 1000, v] }
        @returning_customer_count = @returning_customer_count.map { |k, v| [k.to_i * 1000, v] }
        @redeemed_prize_count = @redeemed_prize_count.map { |k, v| [k.to_i * 1000, v] }

        @feedback_rating_count = {}
        @feedback_rating.each do |(date, rating), count|
          date_i = date.to_i * 1000
          @feedback_rating_count[date_i] ||= {}
          @feedback_rating_count[date_i][rating] = count
        end

        #@feedback_count_item = @feedback_count_item.map { |k, v| [k.to_i * 1000, v] } if params[:item_id].present?
        # @redeem_count = @redeem_count.map { |k, v| [k.to_i * 1000, v] }

        @results = {
          checkins: @checkin_count,
          zipcodes: @zipcode_count,
          feedbacks: @feedback_count,
          favourites: @favourite_count,
          orders: @order_count,
          socials: @social_count,
          new_customers: @new_customer_count,
          returning_customers: @returning_customer_count,
          redeemed_prizes: @redeemed_prize_count,
          feedback_ratings: @feedback_rating_count

          #feedbacks_item: @feedback_count_item if params[:item_id].present?
        }

        # @results[:feedbacks_item] = @feedback_count_item if params[:item_id].present?
        render json: @results
      }
    end
  end

  def mydashboard
    #@resturant=Location.find(:all)
    first_restaurant = current_user.restaurants.first
    redirect_to dashboard_restaurant_path(first_restaurant)
  end

  def calendar
    location_id = params[:id]
    @resturant = Location.find(location_id)

    @check = false
    unless @resturant.nil?
      owner_id = @resturant.owner_id
      if current_user.id.to_i == owner_id.to_i || current_user.admin?
        @check = true
      end
    end

    if @check == false
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/restaurant", :layout => false }
      end
    end

  end

  def rotate_logo

    location_logo_id = params[:logo].to_i
    @location_logo = LocationLogo.find_by_id(location_logo_id)
    unless @location_logo.nil?
      @location_logo.rotate
    end
    respond_to do |format|
      format.js#html { redirect_to restaurants_path ,:notice=> 'Restaurant was deleted successfully.'}
    end
  end

  def rotate_image
    location_image_id = params[:image].to_i
    @location_image = LocationImage.find_by_id(location_image_id)
    unless @location_image.nil?
      @location_image.rotate
    end
    respond_to do |format|
      format.js#html { redirect_to restaurants_path ,:notice=> 'Restaurant was deleted successfully.'}
    end
  end

  def delete_hour_operation

    group_hour = params[:group_hour]
    location_id = params[:location_id]
    unless group_hour.nil? && location_id.nil?
       hour_operation = HourOperation.where("group_hour=? AND location_id=?", group_hour, location_id)
       unless hour_operation.empty?
        hour_operation.destroy_all
       end
    end
    respond_to do |format|
      format.js
    end
  end

  def add_https_to_url(url)
    (!url.blank? && url.to_s.split("https:").size == 1) ? "https:#{url}" : url
  end

  def delete_logo
    @restaurant = Location.find(params[:id])

    @check = false
    unless @restaurant.nil?
      owner_id = @restaurant.owner_id
      if current_user.id.to_i == owner_id.to_i || current_user.admin?
        @check = true
      end
    end

    if @check == true && @restaurant.location_logo.nil? == false
      @restaurant.location_logo.destroy;
      flash[:notice] = "Restaurant logo removed"
    end

    redirect_to edit_restaurant_path(params[:id]);
  end

  def manage_photos
    @restaurant = Location.where(id: params[:id]).first
  end

  def create_photos
    @restaurant = Location.where(id: params[:id]).first
    photo_params = params[:photos]
    photo_params.each do |index, photo|
      @restaurant.photos.create(
        public_id: photo[:public_id],
        format: photo[:format],
        version: photo[:version],
        width: photo[:width],
        height: photo[:height],
        resource_type: photo[:resource_type],
        name: photo[:name]
      )
    end
    @photos = @restaurant.photos

    url_params = params[:urls]
    url_params.each do |url|
      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri.to_s)
      res = Net::HTTP.start(uri.host, uri.port) {|http|
        http.request(req)
      }
    end
    respond_to do |format|
      format.js
    end
  end

  def delete_photo
    @restaurant = Location.where(id: params[:id]).first
    @photo = Photo.where(id: params[:photo_id]).first
    @photo.destroy if @photo
    @restaurant.reload
    @photos = @restaurant.photos
    respond_to do |format|
      format.js
    end
  end

  def crop_logoURL
      @photo = Photo.find_by_id(params[:photo_id])
      @restaurant = Location.find_by_id(params[:rest_id])
      crop_x = params[:crop_x].to_f
      logo_url = nil
      if(crop_x < 0)
        border_width = -1 * crop_x * @photo.width / 180
        logo_url = Cloudinary::Utils.cloudinary_url(@photo.path("png"), {transformation: [
          {border: { width: border_width.round, color: 'white' } },
          {width: 180, height: 180, radius: "max", crop: 'fit'}]})
      else
        border_ratio = 1 - crop_x / 90
        logo_url = Cloudinary::Utils.cloudinary_url(@photo.path("png"), {transformation: [
          {width: (border_ratio.round(2) if border_ratio != 1), height: (border_ratio.round(2) if border_ratio != 1), crop: ("crop" if border_ratio != 1)},
          {width: 180, height: 180, radius: "max", crop: 'fit'}]})
      end
      render :json => {:logo_url => logo_url}.to_json
  end

  def update_latLng
    @restaurant = Location.find_by_id(params[:id])
    @restaurant.update_attributes(:lat => params[:lat], :long => params[:lng])
    respond_to do |format|
      format.html { render action: "edit"}
      format.js
    end
  end

  def add_fundraiser
    @restaurant = Location.find_by_id(params[:id]);
    @fundraiser = Fundraiser.find_by_id(params[:fundraiser_id])
    if(@restaurant.fundraisers.include?(@fundraiser)) 
      render :json => {:message => "Existing Fundraiser", :success=>0}.to_json
    else 
      @restaurant.fundraisers<<@fundraiser
      if @restaurant.save
        render :json => {:message => "Fundraiser added", :success=>1, :name=>@fundraiser.name, :id=>@fundraiser.id}.to_json
      else
        render :json => {:message => "Add Failed", :success=>0}.to_json
      end
    end
  end
  def delete_fundraiser
    @restaurant = Location.find_by_id(params[:id]);
    @fundraiser = Fundraiser.find_by_id(params[:fundraiser_id])
    
    @restaurant.fundraisers.delete @fundraiser
    if @restaurant.save
      render :json => {:message => "Fundraiser removed", :success=>1}.to_json
    else
      render :json => {:message => "Remove Failed", :success=>0}.to_json
    end
  end

  def profile_menu_csv
    @items = []
    @restaurant = Location.find(params[:id])

    @restaurant.menus.each do |menu|
      menu.items.each do |item|
        @items << item
      end
    end

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"profile-menus.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end
end
