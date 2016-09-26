class MenuItemsController < ApplicationController
  load_and_authorize_resource :class => "Item"

  def edit
    @item = Item.find(params[:id])
    @restaurant = Location.find(@item.location_id)
    @item_array = Item.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id]).sort_by!{ |m| m.name.downcase }

    img_count = 1 - @item.item_photos.count   #later change it to number of images you want to have per item for now 1
    img_count.times do |i|
      @item.item_photos.build
    end
    respond_to do |format|
      format.js
    end
  end

  def update
    @item = Item.find(params[:id])
    @item_old = @item.dup
    @item_old.item_images[0] = @item.item_images[0]
    @item_old.item_item_keys = @item.item_item_keys

    @restaurant = Location.find(@item.location_id)
    @item_image = ItemImage.where('item_token = ?', @item.token).last
    @item.item_images[0] = @item_image unless @item_image.nil?

    @is_changed = false
    @option_old = (@item.item_item_options.map {|x| x.item_option.id}).join('|').strip

    # create local item keys from any selected global item keys

    if params[:global_item_keys]
      global_item_key_ids = params[:global_item_keys][:select]

      if global_item_key_ids
        global_item_key_ids.each do |item_key_id|
          global_item_key = ItemKey.find( item_key_id )

          # check if replica already exists

          local_item_key = @restaurant.item_keys.find_by_name_and_description( global_item_key.name, global_item_key.description )

          unless local_item_key
            local_item_key = @restaurant.item_keys.create!( { :description => global_item_key.description, :name => global_item_key.name, :image_id => global_item_key.image_id } )
          end

          # check if menu_item is already associated with this menu_item_key

          unless @item.item_keys.find_by_name_and_description( local_item_key.name, local_item_key.description )
            @item.item_keys << local_item_key
          end
        end
      end
    end

    respond_to do |format|
      allow_updated = true
      combo_item = ComboItem.find_by_item_id(@item.id)

      if combo_item.nil?
        combo_item_item = ComboItemItem.find_by_item_id(@item.id)
        unless combo_item_item.nil?
          allow_updated = false if @item.is_main_dish
        end
      else
        allow_updated = false if !@item.is_main_dish
      end

      @item.backup_attributes
      
      if allow_updated && @item.update_attributes(params[:item])
        # remove category_id from prizes linked to this category
        sql = "SELECT p.* FROM prizes p
              INNER JOIN status_prizes sp ON sp.id = p.status_prize_id
              INNER JOIN build_menus bm on bm.id = p.build_menu_id and bm.active = 1
              INNER JOIN items i on i.id = bm.item_id
              WHERE (sp.location_id = #{@item.location_id} and i.id = #{@item.id})"
        prizes = Prize.find_by_sql(sql)
        prize_ids = []
        prizes.each do |p|
          if p.redeem_value != @item.redemption_value
            p.update_attributes(:build_menu_id => nil)
            prize_ids << p.id
          end
        end
        # remove item from order what linked to above prizes
        Prize.delete_orders_belong_to_prize(@item.location_id, prize_ids)

        @option_new= (@item.item_item_options.map {|x| x.item_option.id}).join('|').strip

        if @option_old != @option_new
          @is_changed = true
        end

        ItemImage.destroy_all(['item_token = ? AND id != ?', @item.token, @item_image.id]) unless @item_image.nil?
        @item_image.update_attributes(:item_id => @item.id) unless @item_image.nil?
        @item_image = @item.item_images[0]
        @menu_build = BuildMenu.new
        @item_array = Item.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id]).sort_by!{ |m| m.name.downcase }
        @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
          AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
          .sort_by!{ |m| m.name.downcase }
      end

      @item_option_array = ItemOption.where("is_deleted = 0 AND location_id = ?", @restaurant.id).sort_by!{ |m| m.name.downcase }
      format.js
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @restaurant = Location.find(@item.location_id)
    @items = @restaurant.items.where(name: @item.name)
    @items.destroy_all
    @menu = @restaurant.menus.new
    @menu_build = BuildMenu.new
    @item_array = Item.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id]).sort_by!{ |m| m.name.downcase }
    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
        AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
        .sort_by!{ |m| m.name.downcase }
  end

  def batch_delete
    params[:items_to_delete].each do |item_id|
      Item.find(item_id).destroy
    end
    render json: {}, status: :ok
  end
end
