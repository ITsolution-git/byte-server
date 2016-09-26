class CategoryController < ApplicationController

  before_filter :authenticate_user!, :only=>[:batch_delete]
  before_filter :authorise_request_as_json, :only=>[:category,:categories,:category_items, :category_items_v1]
  before_filter :authorise_user_param, :only=>[:category,:categories,:category_items, :category_items_v1]

  load_and_authorize_resource
  def edit
    @category = Category.find(params[:id])
    @restaurant = Location.find(@category.location_id)
    @cat_array = Category.where('location_id = ?',@restaurant.id).sort_by!{ |m| m.name.downcase }
    respond_to do |format|
      format.js
    end
  end

  def update
    @category = Category.find(params[:id])
    @category_old = @category.dup
    @restaurant = Location.find(@category.location_id)
    @category.update_attributes(params[:category])

    # remove category_id from prizes linked to this category
    sql = "SELECT p.* FROM prizes p INNER JOIN status_prizes s ON s.id = p.status_prize_id
          WHERE (s.location_id = #{@category.location_id} and p.category_id = #{@category.id})"
    prizes = Prize.find_by_sql(sql)
    prize_ids = []
    prizes.each do |p|
      if p.redeem_value != @category.redemption_value
        p.update_attributes(:category_id => nil)
        prize_ids << p.id
      end
    end
    # remove item from order what linked to above prizes
    Prize.delete_orders_belong_to_prize(@category.location_id, prize_ids)

    @menu_build =  BuildMenu.new
    @cat_array = Category.where('location_id = ?',@restaurant.id).sort_by!{ |m| m.name.downcase }
    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
        AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
        .sort_by!{ |m| m.name.downcase }
    respond_to do |format|
      format.js
    end
  end

  def category
    @category = Category.find(params[:category_id])
    if !@category
      render :status => 403 , :json => {:error => "Not found category"}
    end
  end

  def categories
    @categories = Category.all
    if !@categories
      render :status => 403 , :json => {:error => "Not found category"}
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @restaurant = Location.find(@category.location_id)
    @menus_category = @category.menus
    @category.destroy

    @cat_array = Category.where('location_id = ?',@restaurant.id).sort_by!{ |m| m.name.downcase }
    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
        AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)\
        .sort_by!{ |m| m.name.downcase }
    @menu_build =  BuildMenu.new
    respond_to do |format|
      format.js
    end

  end
  def category_items
    user_id = @user ? @user.id : nil
    location_id = params[:location_id]
    category_id = params[:category_id]
    @items = Item.get_items_category(user_id, location_id, category_id)
  end

  def category_items_v1
    location_id = params[:location_id]
    category_id = params[:category_id]
    @items = Item.get_items_category(@user.id, location_id, category_id)
  end

  def batch_delete
    params[:items_to_delete].each do |category_id|
      Category.find(category_id).destroy
    end
    render json: {}, status: :ok
  end
end
