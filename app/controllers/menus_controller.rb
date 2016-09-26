class MenusController < ApplicationController
  require 'net/smtp'
  require 'fileutils'
  before_filter :authenticate_user!
  before_filter :check_suspended, only: [:publish]
  skip_before_filter :set_cache_buster
  load_and_authorize_resource

  def index
    @restaurant = Location.find(params[:restaurant_id])
    @restaurant_menus = @restaurant.menus.all.sort_by!{ |m| m.id }

    #get restaurant copy menus and shared menus
    @restaurant_copying_menus = @restaurant.copy_shared_menu_statuses
    restaurant_menu_ids = @restaurant.menus.map(&:id)
    @shared_menus = Location.in_chain(@restaurant.chain_name).map { |r| r.menus.shared(restaurant_menu_ids.present? ? restaurant_menu_ids : '') }.flatten

    #check restaurant in current user
    @check = false
    unless @restaurant.nil?
      owner_id = @restaurant.owner_id
      if current_user.id == owner_id || current_user.admin?
        @check = true
      end
    end
    #end

    authorize! :read, @restaurant
    @server = @restaurant.servers.new
    @server_avatar = @server.build_server_avatar
    @menu = @restaurant.menus.new
    @category = Category.new
    @item = Item.new
    @itemKey  = ItemKey.new
    @combo_item = ComboItem.new
    @item_option = ItemOption.new
    @item_key_image = @itemKey.build_item_key_image
    @menus_array = @restaurant.menus.all.sort_by!{ |m| m.name.downcase }.uniq{|el| el.name}
    @item_option_array = @restaurant.item_options.where("is_deleted = 0").sort_by!{ |m| m.name.downcase }.uniq{|el| el.name}
    @cat_array = Category.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }.uniq{|el| el.name}
    @key_array = ItemKey.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }.uniq{|el| el.name}
    @item_array = Item.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }.uniq{|el| [el.name, el.price]}
    @server_array =Server.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
      AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
      .sort_by!{ |m| m.name.downcase }
    #@item.item_photos.build
    @menu_build =  BuildMenu.new
    @tutorialVideos = TutorialVideo.find(:all)

    if @check == false
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/restaurant", :layout => false }
      end
    end
  end

  def create
    @restaurant = Location.find(params[:restaurant_id])
    @check = false

    unless @restaurant.nil?
      owner_id = @restaurant.owner_id
      @check = true if current_user.id == owner_id || current_user.admin?
    end

    if @check == true
      authorize! :read, @restaurant
      @menu = @restaurant.menus.new(params[:menu])

      unless @menu.publish_email.is_a?(Array)
        @menu.publish_email = params[:menu][:publish_email].split(',').map(&:strip)
      end

      @menu.rating_grade = nil if current_user.basic?
      @new_menu = Menu.new
      @item = Item.new
      @menu_build =  BuildMenu.new
      @item.item_images.build

      respond_to do |format|
        if @menu.save
          @menus_array = @restaurant.menus.all.sort_by!{ |m| m.name.downcase }
          format.html { redirect_to restaurant_menus_path(@restaurant), :notice => "Menu created"}
          format.js
        else
          format.js
        end
      end

    end
  end

  def edit
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    @menu = Menu.find(params[:id])
    @menus_array = @restaurant.menus.all.sort_by!{ |m| m.name.downcase }

    respond_to do |format|
      format.js
    end
    
  end

  def update

    @menu = Menu.where(id: params[:id]).first
    @restaurant = Location.where(name: params[:restaurant_id]).first || @menu.location
    authorize! :read, @restaurant

    @menu_old = @menu.dup
    @menu_old.menu_servers = @menu.menu_servers
    @menu_build = BuildMenu.new

    @item = Item.new

    params[:menu][:publish_email] = params[:menu][:publish_email].split(',').map(&:strip)

    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
        AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
        .sort_by!{ |m| m.name.downcase }

    @item.item_images.build

    if !@menu.published? && @menu.update_attributes(params[:menu])
        @menus_array = @restaurant.menus.all.sort_by!{ |m| m.name.downcase }
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    @menu = Menu.find(params[:id])
    @menu_build = BuildMenu.new
    respond_to do |format|
      if !@menu.published?
        @menu.destroy
        @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
          AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
          .sort_by!{ |m| m.name.downcase }
        @menus_array =@restaurant.menus.all.sort_by!{ |m| m.name.downcase }
      end
      format.html { redirect_to restaurant_menus_path(@restaurant) }
      format.js
    end
  end

  def remove_menu_from_build_menu
    @restaurant= Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    menu_builds =  BuildMenu.where(:menu_id => params[:id])
    respond_to do |format|
      menu_builds.each do |m|
        m.update_attributes(:active => false)
      end
      @menu = Menu.find(params[:id])
      format.js
    end
  end

  def remove_category_from_build_menu
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    menu_builds = BuildMenu.where(:menu_id => params[:id], :category_id => params[:category_id])
    respond_to do |format|
      menu_builds.each do |m|
        m.update_attributes(:active => false)
      end
      @category = Category.find(params[:category_id])
      @menu = Menu.find(params[:id])
      format.js
    end
  end

  def remove_item_from_build_menu
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    @item = Item.find(params[:item_id])
    menu_builds = BuildMenu.where(:menu_id => params[:id], :category_id => params[:category_id], :item_id => params[:item_id])
    respond_to do |format|
      menu_builds.each do |m|
        m.update_attributes(:active => false)
      end
      @menu = Menu.find(params[:id])
      @category = Category.find(params[:category_id])
      format.js
    end
  end

  def check_items_quantity
    @category_id = params[:category_id]
    build_menu = BuildMenu.where('menu_id = ? AND category_id = ?',
                                  params[:id], @category_id)
    @count = build_menu.count { |b| !b.item.is_main_dish }
    @value = params[:value].to_i
    respond_to do |f|
      f.js
    end
  end

  def display_combo_on_build_menu
    @combo_item = ComboItem.find(params[:combo_id])
    if @combo_item.gmi?
      @categories = @combo_item.combo_item_categories
    end

    if @combo_item.pmi?
      @items = @combo_item.combo_item_items
    end

    if @combo_item.cmi?
      @categories = @combo_item.combo_item_categories
      @items = @combo_item.combo_item_items
    end

    respond_to do |f|
      f.js
    end
    # if combo_item.pmi?
    #   combo_item_items = combo_item.
    # end
  end

  def add_combo_item
    @restaurant = Location.find(params[:combo_item][:location_id])
     @check = false
    unless @restaurant.nil?
      owner_id = @restaurant.owner_id
      if current_user.id.to_i == owner_id.to_i || current_user.admin?
        @check = true
      end
    end
    if @check == true
      authorize! :read, @restaurant
      @item_id_check = params[:combo_item][:item_id]
      @check_name = params[:combo_item][:name]
      @combo_item = ComboItem.new(
        name: params[:combo_item][:name],
        menu_id: params[:combo_item][:menu_id],
        item_id: params[:combo_item][:item_id]
      )

      if params[:items] && params[:categories]  && (!params[:qty].nil? && params[:qty].uniq != [""])\
         && (!params[:sequence].nil? && params[:sequence].uniq != [""])
        if params[:combo_item][:check_combo_type] == 'pmi'
          @combo_item.combo_type = PMI_GMI
        elsif params[:combo_item][:check_combo_type] == 'gmi'
          @combo_item.combo_type = GMI_PMI
        end
        # create PMI
        if params[:items]
          params[:items].each do |item_id|
            # Need ensure build_menu created
            @combo_item.combo_item_items.build(item_id: item_id)
          end
          @combo_item.save
        end

        # create GMI
        if params[:categories]
          params[:categories].each_with_index do |id, index|
            qty = params[:qty][index].to_i
            sequence = params[:sequence][index].to_i
            if qty > 0
              @combo_item.combo_item_categories.build(
                category_id: id,
                quantity: qty,
                sequence: sequence
              )

              @combo_item.save
            end
          end
        end
      else
        # create PMI
        if params[:items]
          @combo_item.combo_type = PMI
          params[:items].each do |item_id|
            # Need ensure build_menu created
            @combo_item.combo_item_items.build(item_id: item_id)
          end
          @combo_item.save
        end

        # create GMI
        if params[:categories]
          @combo_item.combo_type = GMI
          params[:categories].each_with_index do |id, index|
            qty = params[:qty][index].to_i
            sequence = params[:sequence][index].to_i
            if qty > 0
              @combo_item.combo_item_categories.build(
                category_id: id,
                quantity: qty,
                sequence: sequence
              )

              @combo_item.save
            end
          end
        end
      end

      @combo_item.valid?

      @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
          AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)
          .sort_by!{ |m| m.name.downcase }
      respond_to do |f|
        f.js
      end
    end
  end

  def cancel_combo_item
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    @combo_item = ComboItem.new
    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
        AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)
        .sort_by!{ |m| m.name.downcase }
  end

  def display_categories
    @menu = Menu.find(params[:id])
    @categories = @menu.get_categories_built.sort_by!{ |m| m.name.downcase }
    respond_to do |f|
      f.js
    end
  end

  def display_categories_extend
    @menu = Menu.find(params[:id])
    @categories = @menu.get_categories_built.sort_by!{ |m| m.name.downcase }
    respond_to do |f|
      f.js
    end
  end

  def display_main_dish_extend
    @menu = Menu.find(params[:id])
    respond_to do |f|
        @items = @menu.get_items_built.sort_by!{ |m| m.name.downcase }
        f.js {render :action => 'display_items_extend'}
    end
  end

  def display_main_dish
    @menu = Menu.find(params[:id])
    respond_to do |f|
      if params[:pmi]
        @items = @menu.get_items_built.sort_by!{ |m| m.name.downcase }
        f.js {render :action => 'display_items'}
      else
        @items = @menu.get_main_dish.sort_by! {|m| m.name.downcase}
        f.js {render :action => 'display_main_dish'}
      end
    end
  end

  def add_category
    @restaurant = Location.find(params[:restaurant_id])
    @check = false
    unless @restaurant.nil?
      owner_id = @restaurant.owner_id
      if current_user.id.to_i == owner_id.to_i || current_user.admin?
        @check = true
      end
    end
    if @check == true
      authorize! :read, @restaurant
      @category = Category.new(params[:category])
      @menu_build =  BuildMenu.new
      respond_to do |format|
        if @category.save
          @cat_array = Category.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
          format.html{ redirect_to restaurant_menus_path(@restaurant), :notice=> "Category created" }
          format.js
        else
          format.js
        end
      end
    end
  end

  def check_main_dish
    @combo_items = ComboItem.where('item_id = ?', params[:item_id])
    if @combo_items.empty?
      build_menu = BuildMenu.where('item_id = ?', params[:item_id])

      unless build_menu.nil?
        build_menu.each do |b|
          combo_item_categories = ComboItemCategory.where('category_id =?', b.category_id)

          unless combo_item_categories.empty?
            @check = true
          end
        end
      end
    end
    if @combo_items.empty?
      @combo_item_items = ComboItemItem.where('item_id = ?', params[:item_id])
    end

    respond_to do |f|
      f.js
    end
  end

  def add_item
    ap params
    @restaurant = Location.find(params[:restaurant_id])
    @check = false
    unless @restaurant.nil?
      owner_id = @restaurant.owner_id
      if current_user.id.to_i == owner_id.to_i || current_user.admin?
        @check = true
      end
    end
    if @check == true
      authorize! :read, @restaurant
      @item = @restaurant.items.new(params[:item])
      @menu = Menu.new
      @menu_build =  BuildMenu.new
      @item_image = ItemImage.where('item_token = ?', @item.token).last
      if @item_image
        @item.item_images[0] = @item_image
      end
      respond_to do |format|
        if @item.save
          ItemImage.destroy_all(['item_token = ? AND id != ?', @item.token, @item_image.id]) if @item_image
          @item_array = Item.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
          format.html { redirect_to restaurant_menus_path(@restaurant), :notice => "Item created"}
        end
        format.js
      end
    end
  end

  def edit_item
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    @item = Item.find(params[:item])
    respond_to do |format|
      format.js
    end

  end

  def publish
    @menu = Menu.find(params[:id])
    @restaurant = @menu.location
    @publish_email = @menu.publish_email
    @menu.publish_status = PUBLISH_STATUS
    utc_now = Time.now.utc
    @menu.published_date = utc_now.strftime("%Y-%m-%d %H:%M")
    unless @menu.publish_email.is_a?(Array)
      @menu.update_attribute(:publish_email, @menu.publish_email.split(',').map(&:strip))
    end
    published_date_tz = utc_now.strftime('%Y-%m-%d %I:%M %p')
    published_date_tz = utc_now.in_time_zone(params[:tz]).strftime('%Y-%m-%d %I:%M %p') if params[:tz]
    user = {}

    if !current_user.admin? && current_user.has_parent?
      parent = current_user.parent_user
      user['id'] = parent.id
      user['email'] = parent.email
    else
      user['id'] = current_user.id
      user['email'] = current_user.email
    end
    if @menu.save(:validate => false)
      default_notification = {
        :message       => "#{@menu.name} was published",
        :from_user     => user['id'],
        :msg_type      => "single",
        :to_user       => user['email'],
        :location_id   => @menu.location_id,
        :alert_type    => "Publish Menu Notification"
      }
      @notification = Notifications.new(default_notification)

      if @publish_email.is_a?(String)
        unless @publish_email.empty?
          Thread.new do
            UserMailer.publish_menu_email(@publish_email, @menu, published_date_tz).deliver
          end
        end
      else
        @publish_email.each do |email|
          Thread.new do
            UserMailer.publish_menu_email(email, @menu, published_date_tz).deliver
          end
        end
      end
      Thread.new do
        UserMailer.publish_menu_email(user['email'], @menu, published_date_tz).deliver
      end
      @notification.save
    end
    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
      AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
      .sort_by!{ |m| m.name.downcase }
    @server_array = Server.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
    @menus_array = @restaurant.menus.all.sort_by!{ |m| m.name.downcase }
    @cat_array = Category.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
    @item_array = Item.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }.uniq {|i| i.name}
    @item_option_array = @restaurant.item_options.where("is_deleted = 0").sort_by!{ |m| m.name.downcase }.uniq {|m| m.name}
    build_menu = BuildMenu.where('menu_id = ? and active = ?', @menu.id, 1)

    build_menu.each do |bm|
      item = Item.find_by_id(bm.item_id)
      item_comments = ItemComment.where("build_menu_id = ?", bm.id)
      item.update_attributes(:rating => ItemComment.calculate_item_rating(item_comments).round(2))
    end
  end

  def unpublish
    @menu = Menu.find(params[:id])
    @restaurant = @menu.location
    # logo_of_location= @restaurant.location_logo.image.to_s if !@restaurant.location_logo.nil?
    @publish_email = @menu.publish_email
    @menu.publish_status = APPROVE_STATUS
    utc_now = Time.now.utc
    @menu.published_date = utc_now.strftime("%Y-%m-%d %H:%M")
    unless @menu.publish_email.is_a?(Array)
      @menu.update_attribute(:publish_email, @menu.publish_email.split(',').map(&:strip))
    end
    published_date_tz = utc_now.strftime('%Y-%m-%d %I:%M %p')
    published_date_tz = utc_now.in_time_zone(params[:tz]).strftime('%Y-%m-%d %I:%M %p') if params[:tz]
    user = {}

    if !current_user.admin? && current_user.has_parent?
      parent = current_user.parent_user
      user['id'] = parent.id
      user['email'] = parent.email
    else
      user['id'] = current_user.id
      user['email'] = current_user.email
    end
    if @menu.save(:validate => false)
      # remove category_id from prizes linked to this category
        sql = "SELECT p.* FROM prizes p
              INNER JOIN status_prizes sp ON sp.id = p.status_prize_id
              INNER JOIN build_menus bm on bm.id = p.build_menu_id and bm.active = 1
              INNER JOIN menus m on bm.menu_id = m.id
              INNER JOIN items i on i.id = bm.item_id
              WHERE (sp.location_id = #{@menu.location_id} and m.id = #{@menu.id})"
        prizes = Prize.find_by_sql(sql)
        prize_ids = []
        prizes.each do |p|
          if @menu.publish_status != 2
            p.update_attributes(:build_menu_id => nil)
            prize_ids << p.id
          end
        end
        # remove item from order what linked to above prizes
        Prize.delete_orders_belong_to_prize(@menu.location_id, prize_ids)

      default_notification = {
        :message       => "#{@menu.name} is unpublished",
        :from_user     => user['id'],
        :msg_type      => "single",
        :to_user       => user['email'],
        :location_id   => @menu.location_id,
        :alert_type    => "Unpublish Menu Notification"
      }
      @notification = Notifications.new(default_notification)
      if @publish_email.is_a?(String)
        unless @publish_email.empty?
          Thread.new do
            UserMailer.unpublish_menu_email(@publish_email, @menu, published_date_tz).deliver
          end
        end
      else
        @publish_email.each do |email|
          Thread.new do
            UserMailer.unpublish_menu_email(email, @menu, published_date_tz).deliver
          end
        end
      end
      Thread.new do
        UserMailer.unpublish_menu_email(user['email'], @menu, published_date_tz).deliver
      end
      @notification.save
    end
    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
      AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
      .sort_by!{ |m| m.name.downcase }
    @server_array = Server.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
    @menus_array = @restaurant.menus.all.sort_by!{ |m| m.name.downcase }
    @cat_array = Category.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }.uniq { |m| m.name }
    @item_array = Item.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }.uniq {|i| i.name}
    @item_option_array = @restaurant.item_options.where("is_deleted = 0").sort_by!{ |m| m.name.downcase }.uniq { |m| m.name }
    build_menu = BuildMenu.where('menu_id = ? and active = ?', @menu.id, 1)

    build_menu.each do |bm|
      item = Item.find_by_id(bm.item_id)
      item_comments = ItemComment.where("build_menu_id = ?", bm.id)
      item.update_attributes(:rating => ItemComment.calculate_item_rating(item_comments).round(2))
    end

  end

  def mymenus
    location_ids = []
    if params[:id]
      location_ids  = params[:id]
    else
       @restaurants = current_user.restaurants
       @restaurants.each do |restaurant|
         location_ids << restaurant.id
       end
    end
    @menu = Menu.where('publish_start_date != ? AND location_id IN (?)', "", location_ids)
  end

  def menudetails
    @menu = Menu.find(params[:id])
  end

  def upload_item_key_image
    if params[:item_key_image][:crop_x].to_i == 0 && params[:item_key_image][:crop_y].to_i == 0 \
        && params[:item_key_image][:crop_w].to_i == 0 && params[:item_key_image][:crop_h].to_i == 0
      @item_key_image = ItemKeyImage.where('item_key_token = ? AND item_key_id is ?', params[:item_key_image][:item_key_token], nil).first
    else
      @item_key_image_old = ItemKeyImage.where('item_key_token = ?', params[:item_key_image][:item_key_token]).last
      if @item_key_image_old.nil?
        @item_key_image = @item_key_image_old
      else
        @item_key_image = @item_key_image_old.dup
        @item_key_image.image = @item_key_image_old.image
        @item_key_image.item_key_id = nil
      end
    end

    # @item_key_image = ItemKeyImage.find_by_item_key_token(params[:item_key_image][:item_key_token])
    if @item_key_image.nil?
      @item_key_image = ItemKeyImage.new
    end
    if params[:item_key_image][:image]
      array_item_key_image = params[:item_key_image][:image].original_filename.split('.').last
      params[:item_key_image][:image].original_filename = "#{DateTime.now.strftime("%Y_%m_%d_%H_%M_%S")}" + "." + array_item_key_image.to_s
    end
    @item_key_image.image = params[:item_key_image][:image]
    @item_key_image.item_key_token = params[:item_key_image][:item_key_token]
    @item_key_image.crop_x = params[:item_key_image][:crop_x]
    @item_key_image.crop_y = params[:item_key_image][:crop_y]
    @item_key_image.crop_w = params[:item_key_image][:crop_w]
    @item_key_image.crop_h = params[:item_key_image][:crop_h]
    @item_key_image.rate = params[:item_key_image][:rate]
    respond_to do |format|
      @item_key_image.save
      format.js
    end
  end

  def add_item_key
    @menu_build =  BuildMenu.new
    @itemKey = ItemKey.new(params[:item_key])
    @restaurant = Location.find(params[:restaurant_id])
    @check = false
    if @restaurant
      owner_id = @restaurant.owner_id
      if current_user.id.to_i == owner_id.to_i || current_user.admin?
        @check = true
      end
    end
    if @check == true
      authorize! :read, @restaurant
      @item = Item.new
      # @item_key_image = ItemKeyImage.where('item_key_token = ?', @itemKey.token).last
      # if @item_key_image
      #   @itemKey.item_key_image = @item_key_image
      # end

      @item_array = Item.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
      respond_to do |format|
        if @itemKey.save
          # @item_image = ItemImage.new
          # ItemKeyImage.destroy_all(['item_key_token = ? AND id != ?', @itemKey.token, @item_key_image.id]) if @item_key_image
          @key_array = ItemKey.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
          format.html { redirect_to restaurant_menus_path(@restaurant), :notice=> "Menu Item Key created"}
          format.js
        else
          format.js
        end
      end
    end
  end

  def update_build_menu_items
    @restaurant = Location.find(params[:location_id])
    @item_ids = []
    unless params[:menu_id].empty?
      @current_menu = Menu.find(params[:menu_id])
      unless params[:category_id].empty?
        build_menu = BuildMenu.where(menu_id: params[:menu_id], category_id: Category.get_name_ids(params[:category_id], @restaurant.id) )
        unless build_menu.empty?
          @item_ids = build_menu.map(&:item_id)
        end
      end
    end
  end

  def build_menu
    item_ids = params[:items].nil? ? [] : params[:items]

    # @item_ids = item_ids
    menu_id = params[:build_menu][:menu_id]
    category_id = params[:build_menu][:category_id]
    @is_new = BuildMenu.where(menu_id: menu_id, category_id: category_id).empty?
    respond_to do |format|
      # if @item_ids.empty?
      #   return format.js
      # end
      if @is_new && item_ids.empty?
        @menu = BuildMenu.new(params[:build_menu])

        unless @menu.valid?
          return format.js
        end
      else
        begin
          current_menu = Menu.find(menu_id)
        rescue
          @menu_id = true
          return format.js
        end
        if !current_menu.published?
          item_ids_cond = ''
          if !item_ids.empty?
            item_ids_cond = item_ids.map(&:to_i)
          end
          # BuildMenu.destroy_all(['menu_id = ? AND category_id = ? AND item_id NOT IN (?)',
          #     menu_id, category_id, item_ids.map(&:to_i)])

          # Disable other menus instead of removing
          b_menus = BuildMenu.where('menu_id = ? AND category_id = ? AND item_id NOT IN (?)',
              menu_id, category_id, item_ids_cond)
          b_menus.each do |m|
            m.update_attribute(:active, false)
          end
          @build_menus = []
          if @is_new
            #next_category_sequence = BuildMenu.maximum("category_sequence")
            next_category_sequence = BuildMenu.where('menu_id = ?', menu_id).maximum("category_sequence")
            next_category_sequence = next_category_sequence.to_i + 1
            next_item_sequence = 1
          else
            next_category_sequence = BuildMenu.where('menu_id = ?', menu_id).maximum("category_sequence")
            next_item_sequence = BuildMenu.where(menu_id: menu_id, category_id: category_id).maximum("item_sequence")
            next_item_sequence = next_item_sequence.to_i + 1
          end
          item_ids.each do |item_id|
            @menu = BuildMenu.unscoped.find_by_menu_id_and_category_id_and_item_id(menu_id, category_id, item_id)
            # Create new menu
            if @menu.nil?

              @menu = BuildMenu.new(menu_id: menu_id, category_id: category_id, item_id: item_id,
                  category_sequence: next_category_sequence, item_sequence: next_item_sequence)

              unless @menu.save
                return format.js
              end
              b = BuildMenu.unscoped.where('item_id =?', item_id)
              build_menu_id_list = []
              build_menu_id_delete = []
              build_menu_id_delete << @menu.id
              b.each do |build|
                build_menu_id_list << build.id
              end
              build_menu_id_list -= build_menu_id_delete
              build_menu_id_list.each do |m|

                i = ItemComment.where('build_menu_id =?', m)
                i.each do |a|
                  obj_comment = a.dup
                  obj_comment.created_at = a.created_at
                  obj_comment.updated_at = a.updated_at
                  obj_comment.build_menu_id = @menu.id
                  obj_comment.save
                end

                item_fav = ItemFavourite.where('build_menu_id =?', m)
                item_fav.each do |fav|
                  obj_favorite = fav.dup
                  obj_favorite.created_at = fav.created_at
                  obj_favorite.updated_at = fav.updated_at
                  obj_favorite.build_menu_id = @menu.id
                  obj_favorite.save
                end
              end


              # Increase item sequence
              next_item_sequence += 1
            else
              # Enable menu

              unless @menu.enable?
                @menu.enable(next_item_sequence)

                # Increase item sequence
                next_item_sequence += 1
              end
            end
          end

          #code new feature tuantran
          # item_ids_list = item_ids.map(&:to_i)
          # # build_menu_array = []
          # item_ids_list.each do |item|
          #   b = BuildMenu.unscoped.where('item_id =?',item)
          #   b.each do |m|
          #     i = ItemComment.where('build_menu_id =?', m.id)
          #     i.each do |a|
          #       obj_comment = a.dup
          #       obj_comment.created_at = a.created_at
          #       obj_comment.updated_at = a.updated_at
          #       obj_comment.build_menu_id = @menu.id
          #       obj_comment.save
          #     end
          #   end

          # end

          # #unless @menu.nil?
          #   #ItemComment.destroy_all(build_menu_id: @menu.id)
          #   b.each do |m|
          #     i = ItemComment.where('build_menu_id =?',m.id)
          #     if m.item_id == @menu.item_id
          #       i.each do |a|
          #        obj_comment = a.dup
          #        obj_comment.created_at = a.created_at
          #        obj_comment.updated_at = a.updated_at
          #        obj_comment.build_menu_id = @menu.id
          #        obj_comment.save
          #       end
          #     end
          #   end
            # build_menu_delete = []
            # build_menu_delete << @menu.id

            # build_menu_array  = build_menu_array - build_menu_delete


        #     build_menu.item_comments.each do |item_comment|
        #   obj_comment = item_comment.dup
        #   obj_comment.created_at = item_comment.created_at
        #   obj_comment.updated_at = item_comment.updated_at
        #   obj_comment.build_menu_id = obj.id
        #   obj_comment.save
        # end

          #end
          #end


          @restaurant =Location.find(params[:location_id])
          @cat_array = Category.where('location_id = ?', @restaurant.id).sort_by! {|m| m.name.downcase}
          @item_array = Item.where('location_id = ?', @restaurant.id).sort_by! {|m| m.name.downcase}
          @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
            AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
            .sort_by!{ |m| m.name.downcase }
          return format.js
        end
      end
    end
  end

  def order_build_menu
    categoriesOrder = params[:categoriesChanged]
    itemsOrder = params[:itemsChanged]
    menu = nil

    # Change categories sequence
    unless categoriesOrder.nil?
      categoriesOrder.each do |key, value|
        value.each do |index, info|
          if menu.nil?
            menu = Menu.find(info['menu_id'])
            if menu.published?
              break
            end
          end

          build_menu = BuildMenu.where(:menu_id => info['menu_id'], :category_id => info['category_id'])
          build_menu.update_all(:category_sequence => index.to_i + 1)
          Category.find(info['category_id']).update_attribute('sequence', index.to_i + 1)
        end
      end
    end

    # Change items sequence
    unless itemsOrder.nil?
      itemsOrder.each do |key, value|
        value.each do |index, info|
          if menu.nil?
            menu = Menu.find(info['menu_id'])
            if menu.published?
              break
            end
          end

          build_menu = BuildMenu.find_by_menu_id_and_category_id_and_item_id(info['menu_id'],
              info['category_id'], info['item_id'])
          build_menu.update_attribute(:item_sequence, index.to_i + 1) unless build_menu.nil?
        end
      end
    end

    respond_to do |format|
      return format.js
    end
  end

  def copy
    menu = Menu.find(params[:id])
    authorize! :read, menu
    @restaurant = Location.find(menu.location_id)

    @menu_clone = menu.dup
    @menu_clone.name = menu.generate_copy_name
    if @menu_clone.save
      build_menus = BuildMenu.where(menu_id: menu.id)
      build_menus.each do |build_menu|
        obj = build_menu.dup
        obj.menu_id = @menu_clone.id
        obj.save
        build_menu.item_comments.each do |item_comment|
          obj_comment = item_comment.dup
          obj_comment.created_at = item_comment.created_at
          obj_comment.updated_at = item_comment.updated_at
          obj_comment.build_menu_id = obj.id
          obj_comment.save
        end
        build_menu.item_favourites.each do |item_favourite|
          obj_favourite = item_favourite.dup
          obj_favourite.created_at = item_favourite.created_at
          obj_favourite.updated_at = item_favourite.updated_at
          obj_favourite.build_menu_id = obj.id
          obj_favourite.save
        end
      end
      @menus_array = @restaurant.menus.all.sort_by!{ |m| m.name.downcase }
      @menu_build =  BuildMenu.new
      @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
        AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
        .sort_by!{ |m| m.name.downcase }
    end

    respond_to do |format|
      return format.js
    end
  end

  def upload_server_avatar
    if params[:server_avatar][:crop_x] == 0 && params[:server_avatar][:crop_y] == 0 \
        && params[:server_avatar][:crop_w] == 0 && params[:server_avatar][:crop_h] == 0
      @server_avatar = ServerAvatar.where('server_token = ? AND server_id is ?', params[:server_avatar][:server_token], nil).first
    else
      @server_avatar_old = ServerAvatar.where('server_token = ?', params[:server_avatar][:server_token]).last
      if @server_avatar_old.nil?
        @server_avatar = @server_avatar_old
      else
        @server_avatar = @server_avatar_old.dup
        @server_avatar.image = @server_avatar_old.image
        @server_avatar.server_id = nil
      end
    end
    if @server_avatar.nil?
      @server_avatar = ServerAvatar.new
    end
    if params[:server_avatar][:image]
      array_server_image = params[:server_avatar][:image].original_filename.split('.').last
      params[:server_avatar][:image].original_filename = "#{DateTime.now.strftime("%Y_%m_%d_%H_%M_%S")}" + "." + array_server_image.to_s
    end
    @server_avatar.image = params[:server_avatar][:image]
    @server_avatar.server_token = params[:server_avatar][:server_token]
    @server_avatar.crop_x = params[:server_avatar][:crop_x]
    @server_avatar.crop_y = params[:server_avatar][:crop_y]
    @server_avatar.crop_w = params[:server_avatar][:crop_w]
    @server_avatar.crop_h = params[:server_avatar][:crop_h]
    @server_avatar.rate = params[:server_avatar][:rate]
    respond_to do |format|
      @server_avatar.save
      format.js
    end
  end

  def add_server
    @restaurant = Location.find(params[:restaurant_id])
    @check = false
    unless @restaurant.nil?
      owner_id = @restaurant.owner_id
      if current_user.id.to_i == owner_id.to_i || current_user.admin?
        @check = true
      end
    end
    if @check
      authorize! :read, @restaurant
      @menu = @restaurant.menus.new
      @server = Server.new(params[:server])
      # @server_avatar = ServerAvatar.where('server_token = ?', @server.token).last
      # if @server_avatar
      #   @server.server_avatar = @server_avatar
      # end

      respond_to do |format|
        if @server.save
          # ServerAvatar.destroy_all(['server_token = ? AND id != ?', @server.token, @server_avatar.id]) if @server_avatar
          @server_array = Server.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
          @menus_array = @restaurant.menus.all.sort_by!{ |m| m.name.downcase }
        end
        format.js
        format.html{ redirect_to restaurant_menus_path(@restaurant),:notice=>"Server created"}
      end
    end
  end

  def cancel_server
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    @server = Server.new
    @server_avatar = ServerAvatar.new
    @server_array = Server.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
  end

  def cancel_profile
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    @menu = Menu.new
    @menus_array = Menu.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
  end

  def cancel_category
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    @category = Category.new
    @cat_array = Category.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
  end

  def cancel_itemkey
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    @itemKey = ItemKey.new
    @item_key_image = ItemKeyImage.new
    @key_array = ItemKey.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
  end
  def cancel_item_option
    @restaurant = Location.find(params[:restaurant_id])
    authorize! :read, @restaurant
    @item_option = ItemOption.new
    @item_option_array = @restaurant.item_options.where("is_deleted = 0").sort_by!{ |m| m.name.downcase }
  end

  def cancel_item
     @restaurant = Location.find(params[:restaurant_id])
     authorize! :read, @restaurant
     @item = Item.new
     @item_image = ItemImage.new
     @item_array = Item.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }
  end

  def build_preview
    @device = 'iPhone'
    if params[:device]
      @device = params[:device]
    end
    @restaurant = Location.find(params[:loc_id])
    @menu =Menu.find(params[:menu_id])
    @categories = []
    build_menu = BuildMenu.get_categories_by_menu(@menu.id)
    build_menu.each do |menu_built|
      @categories << Category.find(menu_built.category_id)
    end
    @category = @categories.first
    @items = []
    build_menu = BuildMenu.where(menu_id: @menu.id, category_id: @category.id)
    build_menu.each do |menu_built|
      @items << Item.find(menu_built.item_id)
    end
    @item = @items.first

    respond_to do |format|
      format.js
    end
  end

  def switch_device
    @device = 'iPhone'
    if params[:device]
      @device = params[:device]
    end
    @menu = Menu.find(params[:menu_id])
    @restaurant = Location.find(params[:loc_id])
    @categories = []
    build_menu = BuildMenu.get_categories_by_menu(@menu.id)
    build_menu.each do |menu_built|
      @categories << Category.find(menu_built.category_id)
    end
    @category = @categories.first
    @items = []
    build_menu = BuildMenu.where(menu_id: @menu.id, category_id: @category.id)
    build_menu.each do |menu_built|
      @items << Item.find(menu_built.item_id)
    end
    @item = @items.first

    respond_to do |format|
      format.js
    end
  end

  def change_item_preview
    @item = Item.find(params[:item_id])
    @device = params[:device]
    @menu = Menu.find(params[:menu_id])
    @category = Category.find(params[:category_id])
    respond_to do |format|
      format.js
    end
  end

  def preview
    @device = params[:device]
    @menu =Menu.find(params[:menu_id])
    @category = Category.find(params[:category_id])
    @items = []
    build_menu = BuildMenu.where(menu_id: @menu.id, category_id: @category.id)
    build_menu.each do |menu_built|
      @items << Item.find(menu_built.item_id)
    end
    @item = params[:item_id] ? Item.find(params[:item_id]) : @items.first
    respond_to do |format|
      format.js
    end
  end

  #TODO: Refactor, move to a separate controller.
  def upload_image
    if params[:item_image][:crop_x].to_i == 0 && params[:item_image][:crop_y].to_i == 0 \
        && params[:item_image][:crop_w].to_i == 0 && params[:item_image][:crop_h].to_i == 0
      @item_image = ItemImage.where('item_token = ? AND item_id is ?', params[:item_image][:item_token], nil).first
    else
      @item_image_old = ItemImage.where('item_token = ?', params[:item_image][:item_token]).last
      if @item_image_old.nil?
        @item_image = @item_image_old
      else
        @item_image = @item_image_old.dup
        @item_image.image = @item_image_old.image
        @item_image.item_id = nil
      end
    end

    if @item_image.nil?
      @item_image = ItemImage.new
    end
    # item = Item.find_by_token(params[:item_image][:item_token])


    # @item_image.item_id = item.id
    if params[:item_image][:image]
      array_item_image = params[:item_image][:image].original_filename.split('.').last

      params[:item_image][:image].original_filename = "#{DateTime.now.strftime("%Y_%m_%d_%H_%M_%S")}" + "." + array_item_image.to_s
    end
    @item_image.image = params[:item_image][:image]
    @item_image.item_token = params[:item_image][:item_token]
    @item_image.crop_x = params[:item_image][:crop_x]
    @item_image.crop_y = params[:item_image][:crop_y]
    @item_image.crop_w = params[:item_image][:crop_w]
    @item_image.crop_h = params[:item_image][:crop_h]
    @item_image.rate = params[:item_image][:rate]
    if @item_image.save
      respond_to do |format|
        format.js { render :upload_image_success }
      end
    else
      respond_to do |format|
        format.js { render :upload_image_error }
      end
    end
  end

  def approve_menu
    menu_id = params[:menu_id]
    @menu = Menu.find(menu_id)
    @restaurant = Location.find(params[:loc_id])
    @menu.update_attribute(:publish_status, APPROVE_STATUS)
    unless @menu.publish_email.is_a?(Array)
      @menu.update_attribute(:publish_email, @menu.publish_email.split(',').map(&:strip))
    end
    respond_to do |format|
      format.js
    end
  end

  def add_publish_date
    @menu = Menu.find(params[:menu_id])
  end

  def menu_calendar_date
    publish_start_date = params[:date][:year].to_s + "-" + params[:date][:month].to_s + "-" +
                           params[:date][:day].to_s + " " + params[:date][:hour].to_s + ":" +
                           params[:date][:minute].to_s
    @menu = Menu.find(params[:menu_id])
    repeat_on = params[:repeat_on]
    weekdays = []
    user = {}
    repeats = " "

    # Format time
    repeat_time = params[:date][:hour].to_s + ":" + params[:date][:minute].to_s
    repeat_time_to = repeat_time

    # Convert to local timezone to send notification
    published_date_tz = publish_start_date.to_time.in_time_zone(params[:tz]).strftime('%Y-%m-%d %I:%M %p')
    repeat_time_tz = Time.now.utc.change(:hour => params[:date][:hour].to_s, :min => params[:date][:minute].to_s)\
        .in_time_zone(params[:tz]).strftime('%I:%M %p')

    repeat_time_to_tz = repeat_time_tz

    msg = "#{@menu.name} will be published at #{published_date_tz}"
    unless repeat_on.blank?
      repeat_on.each do |x|
        repeats = "#{x},#{repeats}"
        weekdays << WEEKDAY[x.to_i]
      end
      msg += " && from #{repeat_time_tz} to #{repeat_time_to_tz} on #{weekdays.join(', ')}"
    end

    # Send email && notification if menu updated success
    unless @menu.publish_email.is_a?(Array)
      @menu.update_attribute(:publish_email, @menu.publish_email.split(',').map(&:strip))
    end
    if @menu.update_attributes(:publish_start_date => publish_start_date, :repeat_on => repeats.strip(),
        :repeat_time => repeat_time, :repeat_time_to => repeat_time_to)
      if !current_user.admin? && current_user.has_parent?
        parent = current_user.parent_user
        user['id'] = parent.id
        user['email'] = parent.email
      else
        user['id'] = current_user.id
        user['email'] = current_user.email
      end
      default_notification = {
        :message       => msg,
        :from_user     => user['id'],
        :msg_type      => "single",
        :to_user       => user['email'],
        :location_id   => @menu.location_id,
        :alert_type    => "Publish Menu Notification"
      }
      @notification = Notifications.new(default_notification)

      if @menu.publish_email.is_a?(String)
        unless @menu.publish_email.empty?
          Notifications.create(default_notification.merge(to_user: @menu.publish_email))
          Thread.new do
            UserMailer.publish_calendar(@menu.publish_email, msg).deliver
          end
        end
      else
        @menu.publish_email.each do |email|
          Notifications.create(default_notification.merge(to_user: email))
          Thread.new do
            UserMailer.publish_calendar(email, msg).deliver
          end
        end
      end
      Thread.new do
        UserMailer.publish_calendar(user['email'], msg).deliver
      end
      @notification.save
    end
  end

  def rotate_server
    server_avatar_id = params[:logo].to_i
    @server_avatar = ServerAvatar.find_by_id(server_avatar_id)
    unless @server_avatar.nil?
      @server_avatar.rotate
    end
    respond_to do |format|
      format.js#html { redirect_to restaurants_path ,:notice=> 'Restaurant was deleted successfully.'}
    end
  end

  def rotate_item_key
    item_key_image_id = params[:logo].to_i
    @item_key_image = ItemKeyImage.find_by_id(item_key_image_id)
    unless @item_key_image.nil?
      @item_key_image.rotate
    end
    respond_to do |format|
      format.js#html { redirect_to restaurants_path ,:notice=> 'Restaurant was deleted successfully.'}
    end
  end

  def rotate_item
    item_image_id = params[:logo].to_i
    @item_image = ItemImage.find_by_id(item_image_id)
    unless @item_image.nil?
      @item_image.rotate
    end
    respond_to do |format|
      format.js#html { redirect_to restaurants_path ,:notice=> 'Restaurant was deleted successfully.'}
    end
  end

  def add_https_to_url(url)
    (!url.blank? && url.to_s.split("https:").size == 1) ? "https:#{url}" : url
  end

  def add_item_option
    ActiveRecord::Base.transaction do
      @restaurant = Location.find(params[:restaurant_id])
      ioption = params[:item_option]

      @check = false
      unless @restaurant.nil?
        owner_id = @restaurant.owner_id
        if current_user.id.to_i == owner_id.to_i || current_user.admin?
          @check = true
        end
      end

      if @check == true
        unless ItemOption.find_by_name_and_location_id_and_is_deleted(ioption["name"], @restaurant.id, 0).nil?
          @cust_errors = "This name has already been taken."

          @item_option_array = @restaurant.item_options.where("is_deleted = ?", 0).sort_by!{ |m| m.name.downcase }
          @item = Item.new
          @item_image = ItemImage.new
          @item_array = Item.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }

          respond_to do |format|
            format.html{ redirect_to restaurant_menus_path(@restaurant), :notice=> ""}
            format.js
          end
        else
          @item_option = ItemOption.new
          @item_option.name = ioption["name"]
          @item_option.location_id = @restaurant.id
          @item_option.only_select_one = ioption["select_one"].nil? ? 0 : 1
          @item_option.save
          @item_option_array = @restaurant.item_options.where("is_deleted = ?", 0).sort_by!{ |m| m.name.downcase }

          @item = Item.new
          @item_image = ItemImage.new
          @item_array = Item.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }

          respond_to do |format|
            if @item_option.save
              ioption['group'].each_with_index do |i, index|
                unless i['add_on'].nil? and i['price'].nil?
                  ItemOptionAddon.create(
                    :name => i['add_on'],
                    :price => i['price'],
                    :item_option_id => @item_option.id,
                    :is_selected => i['selected'] == 'on' ? 1 : 0
                  )
                end
              end
              format.html{ redirect_to restaurant_menus_path(@restaurant), :notice=> "Menu Option created"}
              format.js
            else
              format.js
            end
          end
        end #end unless ItemOption
      end #end check
    end
  end
  def batch_delete
    params[:items_to_delete].each do |menu_id|
      Menu.find(menu_id).destroy
    end
    render json: {}, status: :ok
  end
end
