class ItemKeyController < ApplicationController
  load_and_authorize_resource
  def edit
    @itemKey = ItemKey.find(params[:id])
    @server_avatar = @item_key.image
    @server_avatar ||= @item_key.build_image
    @restaurant = Location.find(@itemKey.location_id)
    @key_array = ItemKey.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id]).sort_by!{ |m| m.name.downcase }
    respond_to do |format|
      format.js
    end
  end

  def update
    @menu_build = BuildMenu.new
    @itemKey = ItemKey.find(params[:id])
    @itemKey_old = @itemKey.dup
    @itemKey_old.item_key_image = @itemKey.item_key_image
    @item = Item.new
    respond_to do |format|
      if @itemKey.update_attributes(params[:item_key])
        @restaurant = Location.find(@itemKey.location_id)
        @item_array = Item.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id])
        @key_array = ItemKey.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id]).sort_by!{ |m| m.name.downcase }
      end
      format.js
    end
  end

  def destroy
    @itemKey = ItemKey.find(params[:id])
    @restaurant = Location.find(@itemKey.location_id)
    @item_keys = @restaurant.item_keys.where(name: @itemKey.name)
    @item_keys.destroy_all
    @item = Item.new
    @item_array = Item.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id])
    @key_array = ItemKey.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id]).sort_by!{ |m| m.name.downcase }

    respond_to do |format|
      format.js
    end
  end

  def batch_delete
    # intercept "set global" alternative of shared form
    if params['make_global'] == "true"
      params[:items_to_delete].each do |item_key_id|
        ItemKey.find(item_key_id).update_attribute(:is_global,true)
      end
    else
      params[:items_to_delete].each do |item_key_id|
        ItemKey.find(item_key_id).destroy
      end if params[:items_to_delete]
    end

    render json: {}, status: :ok
  end
end
