class ItemsController < ApplicationController
  before_filter :authorise_request_as_json
  before_filter :authorise_user_param, only: [:comments, :add_comment, :update_comment, :item_detail, :item_detail_v1]
  before_filter :authenticate_user_json, only: [:add_nexttime, :add_favourite]
  before_filter :load_item, only: [:comments, :add_comment, :add_nexttime, :update_comment, :add_favourite, :update_comment]

  def index
    render json: {message: "Incorrect access"}
  end

  def comments
    begin
      item_id = params[:id]
      menu_id = params[:menu_id]
      category_id = params[:category_id]
      @item = ItemComment.joins(:build_menu).where("build_menus.category_id=? AND build_menus.menu_id=? AND build_menus.item_id=?",category_id,menu_id,item_id).first
      sql = "SELECT ic.id as comment_id, bm.item_id, ic.text, ic.rating, ic.created_at, ic.updated_at,i.name as item_name,
                   u.id as user_id, u.avatar as user_avatar, u.username, IFNULL(ic.order_item_id, 0) as order_item_id
            FROM item_comments ic
            JOIN build_menus bm ON ic.build_menu_id = bm.id
            JOIN items i ON i.id = bm.item_id
            JOIN users u ON u.id = ic.user_id
            WHERE bm.menu_id =? AND bm.category_id = ? AND bm.item_id = ? AND bm.active = ? ORDER BY ic.updated_at DESC "
      limit = params[:limit]
      offset = params[:offset]
      if (!limit.nil? && !offset.nil?)
        sql << " LIMIT #{limit} OFFSET #{offset}"
      end
      @comments = find_by_sql(ItemComment,sql,menu_id,category_id, item_id, ACTIVE)
    rescue
      render :status => 500, :json => {:status => :failed}
    end
  end

  def add_nexttime
    begin
      user_id = @user ? @user.id : nil
      category_id = @parsed_json["category_id"] if @parsed_json["category_id"]
      menu_id = @parsed_json["menu_id"] if @parsed_json["menu_id"]
      is_nexttime = @parsed_json["nexttime"] if @parsed_json["nexttime"]
      @build_menu = BuildMenu.where('category_id = ? and menu_id = ? and item_id = ? and active = ?',category_id,menu_id,params[:id], ACTIVE)
      @nexttime = ItemNexttime.where('build_menu_id = ? and user_id = ?', @build_menu.first.id,user_id).first
      ItemNexttime.transaction do

        if !@nexttime.nil?
          @nexttime.update_attribute(:nexttime,is_nexttime)
          return render :status=>200, :json => {:status => :success}
        end

        nexttime = ItemNexttime.new
        nexttime.user_id = user_id
        nexttime.build_menu_id = @build_menu.first.id
        nexttime.nexttime = is_nexttime.to_i
        nexttime.save!
        return render :status=>200, :json => {:status => :success}
      end
    rescue
      return render :status => 500, :json => {:status => :failed}
    end
  end

  def update_comment
    begin
      # Pull the ItemComment record
      @item_comment = ItemComment.find(params[:id])

      if !@item_comment
        render status: 500, json: {status: :failed, error: 'Comment not found'}
      end

      # Update the ItemComment record
      update_hash = {}
      update_hash[:rating] = params[:rating] if params[:rating]
      update_hash[:text] = params[:comment] if params[:comment]
      @item_comment.update_attributes(update_hash)

      # Update the Item's average rating (Is this still in use?)
      all_item_comments = ItemComment.where(build_menu_id: @item_comment.build_menu_id)
      @item_comment.item.update_attribute(:rating, ItemComment.calculate_item_rating(all_item_comments).round(2))

      return render status: 200, json: {status: :success, review: comments.count, rating: @item_comment.rating}

    rescue => e
      render :status => 500, :json => {:status=> :failed, :error => e.message}
    end
  end

  #Add item comment/rating
  # TODO: Fix this hack job
  def add_comment
    begin
      if !@item
        return render status: 404, json: {status: :failed, error: "Item not found"}
      end

      # Set variables
      menu_id     = params[:menu_id].to_i if params[:menu_id]
      category_id = params[:category_id].to_i if params[:category_id]
      order_item_id = params[:order_item_id].to_i if (params[:order_item_id] && params[:order_item_id] != 0)
      rating      = params[:rating] if params[:rating]
      comment     = params[:comment] if  params[:comment]

      # Pull the BuildMenu and Item records
      @build_menu = BuildMenu.where(item_id: @item.id, menu_id: menu_id,
        category_id: category_id, active: true).first
      if !@build_menu
        return render status: 404, json: {status: :failed, error: "Build Menu not found"}
      end

      # check suspend status of user in a restaurant  TODO:
      customer_location = CustomersLocations.find_by_location_id_and_user_id(@item.location_id, @user.id)

      if customer_location.present? && customer_location.is_deleted == 1
        return render status: 403, json: {status: :failed, error: :Forbidden, is_suspended: 1}
      end

      # Confirm the user is checked in
      checkin = @user.current_checkin_at(@item.location)

      if !checkin
        return render status: 403, json: {status: :failed, error: 'The User must be checked in to this location to submit a comment.'}
      end

      # Confirm the user may submit another comment
      if ! checkin.another_comment_allowed?(@build_menu.id, rating)
        return render status: 403, json: {status: :failed, error: 'You’ve already submitted the maximum number of comments'}
      end

      # Create the ItemComment
      new_item_comment = ItemComment.new(
        user_id: @user.id,
        build_menu_id: @build_menu.id,
        rating: rating,
        text: comment,
        order_item_id: order_item_id
      )
      if !new_item_comment.save
        return render status: 200, json: {status: :success, error: 'Failed to save the new_item_comment.'}
      end


      # Add this User to the Location's contact list
      CustomersLocations.add_contact(Array([@user.id]), @item.location_id)

      # Update the Item's average rating value
      @item_comments = ItemComment.where(build_menu_id: @build_menu.id)
      updated_item_rating = ItemComment.calculate_item_rating(@item_comments).round(2)
      @item.update_attribute(:rating, updated_item_rating)

      return render status: 200, json: {status: :success, review: @item_comments.count, rating: updated_item_rating}
    rescue => e
      render status: 500, json: {status: :failed, error: e.message}
    end
  end

  def add_favourite
    begin
      category_id = @parsed_json["category_id"] if @parsed_json["category_id"]
      menu_id = @parsed_json["menu_id"] if @parsed_json["menu_id"]
      is_favourite = (@parsed_json["is_favourite"] == 1 || @parsed_json["is_favourite"] == '1' || @parsed_json["is_favourite"] == true || @parsed_json["is_favourite"] == 'true') ? true : false
      item_id = params[:id]
      build_menu = BuildMenu.where("category_id = ? and menu_id = ? and item_id = ? AND active = ?", category_id, menu_id, item_id, ACTIVE).first

      if build_menu.nil?
        return render :status => 404, :json => {:status => :failed, :error => "Resource not found"}
      end
      
      favourite = ItemFavourite.where(build_menu_id: build_menu.id, user_id: @user.id).first
      ItemFavourite.transaction do
        CustomersLocations.add_contact(Array([@user.id]), build_menu.item.location.id)
        if !favourite.nil?
          favourite.update_attributes!(:favourite => is_favourite)
          return render :status => 200, :json => {:status => :success}
        else
          new_favourite = ItemFavourite.new(
            user_id: @user.id,
            build_menu_id: build_menu.id,
            favourite: is_favourite
          )
          new_favourite.save!
          return render :status => 200, :json => {:status => :success}
        end
      end
    rescue
      render :status => 500, :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  def load_item
    @item = Item.find_by_id(params[:id])
  end

  def item_detail
    params[:location_id] ? location_id = params[:location_id].to_i : nil
    params[:category_id] ? category_id = params[:category_id] :nil
    params[:item_id] ? item_id = params[:item_id] :nil
    suspend = CustomersLocations.where("location_id =? and user_id = ?",location_id,@user.id).select("is_deleted").first
    if suspend.nil?
       suspend = CustomersLocations.new
       suspend.is_deleted = 0
    end
    @suspend = suspend
    @items = Item.get_items(@user.id, location_id, category_id, item_id)
  end

  def item_detail_v1
    begin
      params[:location_id] ? location_id = params[:location_id].to_i : nil
      params[:category_id] ? category_id = params[:category_id].to_i : nil
      params[:item_id] ? item_id = params[:item_id].to_i : nil
      @items = Item.get_items_v1(@user.id, location_id, category_id, item_id)
    rescue
      render :status => 500, :json => {:status => :failed, :error=>"Internal Service Error"}
    end
  end
end
