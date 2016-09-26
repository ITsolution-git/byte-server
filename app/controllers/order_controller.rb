class OrderController < ApplicationController
  before_filter :authenticate_user!, :only => [:my_orders, :view_order, :change_status, :refund, :resend_receipt, :restaurant_orders, :toggle_pos]
  before_filter :authorise_request_as_json, :except => [:my_orders, :view_order, :change_status, :refund, :resend_receipt, :restaurant_orders, :toggle_pos]
  before_filter :authorise_user_param, :only => [:order_global,:order_chain,:order_detail,:details,:get_order,:location_orders,:chain_orders,
    :global_orders,:get_server_comments, :get_order_v1, :details_v1]
  before_filter :authenticate_user_json, :only => [:new_order,:update_order,:get_receipt,:update_item,:add_server,:server_rating,
    :server_favourite,:edit_server_rating,
    #:pay_order, # apparently deprecated
    :get_amount_items,
    :new_order_v1, :update_item_v1, :update_order_v1, :get_amount_items_v1,
    #:pay_order_v1, # apparently deprecated
    :update_order_v2, :pay_order_v2]

  # POST /order/new_order
  def new_order
    begin
      ActiveRecord::Base.transaction do
        order_items = @parsed_json["order_items"] if @parsed_json["order_items"]
        location_id = @parsed_json["location_id"].to_i if @parsed_json["location_id"]
        tax = @parsed_json["tax"] if @parsed_json["tax"]
        fee = @parsed_json["fee"] if @parsed_json["fee"]
        location = Location.find_by_id(location_id)

        # Check if Diner has a current order at this restaurant.
        # If so, they selected an order_items => add them to current order.
        # If not, create an order and add order_items to one.
        if Order.is_current(@user.id, location)
          # Add order_items to current order
          current_order = Order.find_by_user_id_and_location_id_and_is_paid_and_is_cancel(@user.id, location.id, 0, 0)
          current_order.update_attributes!(:location_id => location.id, :tax => tax, :fee => fee)
          order_item = OrderItem.add_new_item(order_items, current_order)
          return render :json => 200,:json => {:status => :success, :order_id => current_order.id,\
            :order_item_id => order_item.id, :order_item_status => order_item.status}
        else
          # Create new new Order record
          new_order = Order.new(
            user_id: @user.id,
            tax: tax,
            fee: fee,
            location_id: location.id,
            receipt_day_id: Order.next_receipt_no(location),
            status: 0,
          )
          new_order.timezone = location.timezone if !location.nil?
          new_order.save!

          # Add a new OrderItem
          order_item = OrderItem.add_new_item(order_items, new_order)

          # Automatically check the user in at this location (to allow item grading)
          @user.checkin_at(location, false)

          return render :status => 200, :json => {:status => :success, :order_id => new_order.id,\
            :order_item_id => order_item.id, :order_item_status => order_item.status}
        end
      end
    # rescue
    #   return render :json => 500 , :json => {:status => :failed}
    end
  end

  def update_item
    order_items = @parsed_json["order_items"] if @parsed_json["order_items"]
    @parsed_json["order_id"] ? order_id = @parsed_json["order_id"].to_i : order_id = nil
    begin
      ActiveRecord::Base.transaction do
        if order_id.nil? || order_id == 0
          return render :status => 404, :json => {:status => :failed, :error => "Invalid Order"}
        end
        order = Order.find(order_id)
        unless order.nil?
          CustomersLocations.add_contact(Array([@user.id]), order.location_id)
        end
        unless order_items.empty?
          for i in order_items
            order_item = OrderItem.find(i['id'])
            # When users update their order items, we have three cases
            # First : They change quantity of current order (hasn't ordered yet) <=> i['order_item_status'] == 0 => update order item only
            # Second : They change quantity of current order (ordered) <=> i['order_item_status'] == 1 => add an item to order
            # Third : quantity of order item is zero => remove order item from current order
            if i['is_delete'] == 0 && i['status'] == 0
              order_item.update_attributes!(:quantity => i['quantity'], :price => i['price'],\
                :redemption_value => i['redemption_value'], :note => i['note'], :use_point => 0)
              OrderItemCombo.update_combo_items(order_item, i['order_item_combos'], UPDATE_ORDER_ITEM)
            elsif i['is_delete'] != 0 && i['status'] == 1
              OrderItem.add_new_item(i, order)
            else
              order_item.destroy
            end
          end
          return render :status => 200, :json => {:status => :success}
        end
        render :status => 404, :json => {:status => :failed, :error => "Invalid Item"}
      end
    rescue
      return render :status => 500, :json => {:status => :failed}
    end
  end

  def get_order
    params[:location_id] ? location_id = params[:location_id].to_i : location_id = nil
    if location_id == 0 || location_id == nil
      return render :status => 404, :json => {:status => :failed, :message => "Invalid Location ID"}
    end
    begin
      @order = Order.get_current_order(@user.id, location_id)
      unless @order.empty?
        @order_items = OrderItem.get_items_current_order(@order.first.id)
      end
      @server = Server.get_servers_current_order(@user.id, location_id.to_i)
    rescue
      return render :status => 500, :json => {:status => :failed}
    end
  end

  def details
    params[:id] ? order_id = params[:id].to_i : order_id = nil
    if order_id.nil? || order_id == 0
      return render :status => 404, :json => {:status => :failed, :error => "Invalid Order"}
    end
    begin
      @orders = Order.where(["id = ?", order_id]).select("*,id as receipt_no,IFNULL(total_tip, -1) as total_tip,IFNULL(orders.tip_percent, -1) as tip_percent ").first
      @orders.update_attribute(:read, 1)
      @order_items = OrderItem.get_items_order_detail(@orders.id)
      @server = Server.get_servers_order_detail(@user.id,@orders.id)
    rescue
      return render :status => 500, :json => {:status => :failed}
    end
  end

  def update_order
    @parsed_json["order_id"] ? order_id = @parsed_json["order_id"].to_i : order_id = nil
    @parsed_json["order_items"] ? order_items = @parsed_json["order_items"].to_a : order_items = []
    server_id = @parsed_json["server_id"] if @parsed_json["server_id"]
    total_tip = @parsed_json["total_tip"] if @parsed_json["total_tip"]
    tip_percent = @parsed_json["tip_percent"] if @parsed_json["tip_percent"]
    total_tax = @parsed_json["total_tax"] if @parsed_json["total_tax"]
    sub_price = @parsed_json["sub_price"] if @parsed_json["sub_price"]
    fee = @parsed_json["fee"] if @parsed_json["fee"]
    total_price = @parsed_json["total_price"] if @parsed_json["total_price"]
    status = @parsed_json["status"].to_i if @parsed_json["status"]
    code = -1
    total_redemption = 0
    begin
      ActiveRecord::Base.transaction do
        order = Order.find_by_id(order_id)
        if order.nil?
          return render :status => 404, :json => {:status => :failed, :error => "Resource not found"}
        end
        location = Location.get_location_name_and_email(order.location_id)

        #begin redemption points
        order_items.each do |oi|
          total_redemption = total_redemption + oi['use_point'].to_f
          unless oi['order_item_combos'].empty?
            oi['order_item_combos'].each do |ic|
              total_redemption = total_redemption  + ic['use_point'].to_f
            end
          end
        end
        # Diner use point to pay instead of using cash
        # Minus point of user immediately if they select to pay by point. when the day was over, if their order still isn't paid (pending/ordered )
        # Return points to them (cron job)
        # use_point of an item <=> a record is saved in table user_points
        # when day was over -> create a new record
        # many item were ordered by point in one day => update number of point in table user_points
        user_points = UserPoint.where("user_id = ? and location_id = ? and point_type = ? and is_give =? ",@user.id,order.location_id,REDEMPTION,0).order("id DESC").first
        unless user_points.nil?
          if order.created_at > user_points.created_at
            UserPoint.minus_points(@user.id,order.location_id,total_redemption) if total_redemption > 0
          else
             today = Time.now.in_time_zone("#{location.timezone}").strftime('%Y-%m-%d %H')
             user_point_date = user_points.created_at.in_time_zone("#{location.timezone}").strftime('%Y-%m-%d %H')
             if user_point_date.to_s != today.to_s
                UserPoint.minus_points(@user.id,order.location_id,total_redemption)
             else
                user_points.update_attributes(:points => total_redemption)
             end
          end
        else
          UserPoint.minus_points(@user.id,order.location_id,total_redemption) if total_redemption > 0
        end
        #end redemption point
        unless server_id.to_i == 0 # If diner chose a server
          order.update_attributes!(:server_id => server_id, :total_tip => total_tip, :status => status, :total_tax => total_tax,\
            :sub_price => sub_price, :total_price => total_price,:tip_percent => tip_percent, :fee => fee)
          #send mail order location
          OrderItem.update_items(order_items, order, 0)
          CustomersLocations.add_contact(Array([@user.id]), order.location_id) if order.status == 1 || order.is_paid == 1
          return render :json => 200,:json => {:status => :success, :order_id => order.id, :is_token => code}
        else
        # Diner don't choose server
          order.update_attributes!(:server_id => nil, :total_tip => total_tip, :status => status, \
            :total_tax => total_tax, :sub_price => sub_price, :total_price => total_price,:tip_percent => tip_percent, :fee=>fee)
          OrderItem.update_items(order_items, order, 0)
          CustomersLocations.add_contact(Array([@user.id]), order.location_id) if order.status == 1 || order.is_paid == 1
          return render :json => 200,:json => {:status => :success, :order_id => order.id, :is_token => code}
        end
      end
    # rescue
    #   return render :json => 500 , :json => {:status => :failed}
    end
  end

  def location_orders
    params[:location_id] ? location_id = params[:location_id].to_i : location_id = nil
    begin
      if location_id.nil? || location_id == 0
        return render :status => 404, :json => {:status => :failed, :error => "Invalid Location"}
      end
      @orders = Order.where("user_id = ? and location_id = ? and is_paid = ?", @user.id, location_id, 1)
        .order("paid_date DESC")
    rescue
      return render :json => 500 , :json => {:status => :failed}
    end
  end

  def chain_orders
    params[:chain_name] ? chain_name = params[:chain_name] : chain_name = ""
    begin
      @locations = Location.get_orders_chain(@user.id, fix_special_character(chain_name))
    rescue
      return render :json => 500 , :json => {:status => :failed}
    end
  end

  def global_orders
    begin
      @locations = Location.get_orders_global(@user.id)
    rescue
      return render :json => 500 , :json => {:status => :failed}
    end
  end

  # POST /order/pay_order
  # 2015-04-21 Reported as deprecated
  # def pay_order
  #   @parsed_json["order_id"] ? order_id = @parsed_json["order_id"].to_i : nil
  #   paid_date = Time.now.utc
  #   is_rate_all_items = true
  #   is_paid = 1

  #   begin
  #     order = Order.find_by_id(order_id)
  #     return render :status => 404, :json => {:status => :failed, :error => "Resource not found"} if order.nil?
  #     order_items = order.order_items
  #     @order_items = OrderItem.joins(:item).where("order_items.order_id = ?",order_id).select("order_items.id as order_item_id,items.id as id, items.name as item_name,items.price,order_items.quantity")

  #     unless @order_items.empty?
  #       @order_items.each do |item|
  #         @order_item_combos = OrderItemCombo.find_by_sql("SELECT ic.item_id as id ,i.name as item_name,ic.price ,ic.quantity
  #                                                          from items i
  #                                                          join order_item_combos ic on i.id = ic.item_id
  #                                                          where ic.order_item_id= #{item.order_item_id}")
  #       end

  #       #collect Menu Item to one Record
  #       @order_items.each do |i|
  #         i[:is_delete] = 0
  #       end

  #       for i in (0..@order_items.length - 1)
  #         tem =  @order_items[i]
  #         for j in (i+1..@order_items.length - 1)
  #           if tem[:id] ==  @order_items[j][:id]
  #             tem[:quantity] += @order_items[j][:quantity]
  #             tem[:price] =  @order_items[j][:price]
  #             @order_items[j][:price] = 0
  #             @order_items[j][:is_delete] = 1
  #           end
  #         end
  #       end
  #       @order_items.delete_if do |a|
  #         a[:is_delete] == 1
  #       end
  #     end

  #     return render :status => 404, :json => {:status => :failed, :error => "Invalid Order"} if order.nil?

  #     ActiveRecord::Base.transaction do
  #       order.update_attributes!(:paid_date => paid_date, :is_paid => is_paid)
  #       CustomersLocations.add_contact(Array([@user.id]), order.location_id)

  #       unless order_items.empty?
  #         order_items.each do |order_item|
  #           comment = ItemComment.find_by_order_item_id(order_item.id)
  #           if comment.present?
  #             UserPoint.create_for_submitting_a_grade(@user, order_item.item.location) # TODO: Points should be created automatically when an ItemComment is created
  #           else
  #             is_rate_all_items = false
  #           end
  #         end
  #       end #end order.update_attributes

  #       # save Notification and send an email to user
  #       from_user = Location.find_by_id(order.location_id)
  #       notification = Notifications.new
  #       notification.to_user = @user.email
  #       notification.msg_subject = GENERAL_MESSAGE
  #       notification.msg_type = 'single'
  #       notification.alert_type = ORDER_ALERT_TYPE
  #       notification.alert_logo = GENERAL_MESSAGE_LOGO
  #       notification.message = (is_rate_all_items ? PAY_ORDER_BODY_RATING_ALL : PAY_ORDER_BODY)
  #       notification.location_id = order.location_id
  #       notification.from_user = from_user.owner_id if (from_user.present? && from_user.owner_id.present?)
  #       notification.save!
  #       UserMailer.custom_send_email_pay_order(@user.email, is_rate_all_items, from_user, order, @order_items, @order_item_combos).deliver
  #       return render :status => 200,:json => {:status => :success}

  #     end # end transaction
  #   rescue
  #     return render :status => 500,:json => {:status => :failed}
  #   end
  # end

  def get_amount_items
    begin
      ActiveRecord::Base.transaction do
        location_id = @parsed_json["location_id"].to_i if @parsed_json["location_id"]
        location = Location.find_by_id(location_id)
        amount_of_items = 0
        if Order.is_current(@user.id, location)
          current_order = Order.find_by_user_id_and_location_id_and_is_paid_and_is_cancel(@user.id, location.id, 0, 0)
          items = current_order.order_items
          # puts "ITEM MAIN : #{items.inspect}"
          items.each do |i|
            amount_of_items += i.quantity
            combo_items = i.order_item_combos
            unless combo_items.empty?
                combo_items.each do |k|
                  amount_of_items += k.quantity
                end
            end
          end
        end
        return render :json => 200 , :json => {:status => :success, :amount => amount_of_items}
      end
    rescue
      return render :json => 500 , :json => {:status => :failed}
    end
  end
# Server management -----------------------------------------------------------------------
  def add_server
    begin
      server_id = @parsed_json["server_id"] if @parsed_json["server_id"]
      order_id = @parsed_json["order_id"] if @parsed_json["order_id"]
      @order = Order.where("id=?", order_id).first
      unless @order.nil?
        @order.update_attributes!(:server_id => server_id)

        return render :status => 200, :json =>{:status => :success}
      else
        render :status => 503, :json =>{:status => :failed, :error => "This order is not exist"}
      end
    rescue
      return render :status => 503, :json =>{:status => :failed}
    end
  end

  #Add new Server rating/comment
  def server_rating
    begin
      ServerRating.transaction do
        server_id = @parsed_json["server_id"] if @parsed_json["server_id"]
        rating = @parsed_json["rating"] if @parsed_json["rating"]
        comment = @parsed_json["comment"] if @parsed_json["comment"]

        server = Server.find_by_id(server_id)
        if server.nil?
          return render :status => 404, :json => {:status => :failed, :error => "Resource not found"}
        else
          # check suspend status of user in a restaurant
          customer_location = CustomersLocations.find_by_location_id_and_user_id(server.location_id, @user.id)
          if !customer_location.nil?
            return render :status => 403, :json => {
              :status => :failed,
              :error => :Forbidden,
              :is_suspended => customer_location.is_deleted
            } if customer_location.is_deleted == 1
          end

          @server_rating = ServerRating.new
          @server_rating.server_id = server_id
          @server_rating.user_id = @user.id
          @server_rating.rating = rating
          @server_rating.text = comment
          @server_rating.save!
          server.update_attributes!(:rating => @server_rating.get_avg_rating)
          return render :status => 200, :json =>{:status=>:success,:rating => @server_rating.get_avg_rating}
        end
      end #End transaction
    rescue
      return render :status => 500, :json =>{:status=>:failed, :error => "Internal Service Error"}
    end
  end

  #Edit server rating/comment
  def edit_server_rating
    begin
      ServerRating.transaction do
        server_rating_id = @parsed_json["server_rating_id"] if @parsed_json["server_rating_id"]
        rating = @parsed_json["rating"] if @parsed_json["rating"]
        comment = @parsed_json["comment"] if @parsed_json["comment"]
        @server_rating = ServerRating.where("id=? AND user_id=?", server_rating_id, @user.id).first
        if @server_rating.nil?
          return render :status => 404, :json => {:status=> :failed, :error =>"This comment is not your comment"}
        else
          # check suspend status of user in a restaurant
          location_id = @server_rating.server.location_id
          customer_location = CustomersLocations.find_by_location_id_and_user_id(location_id, @user.id)
          if !customer_location.nil?
            return render :status => 403, :json => {
              :status => :failed,
              :error => :Forbidden,
              :is_suspended => customer_location.is_deleted
            } if customer_location.is_deleted == 1
          end
          @server_rating.update_attributes!(:rating => rating.to_i, :text => comment)
          return render :status => 200, :json =>{:status=>:success, :rating=> @server_rating.get_avg_rating}
        end
      end
    rescue
      return render :status => 500, :json =>{:status=>:failed, :error => "Internal Service Error"}
    end
  end

  #Get list of server comments
  def get_server_comments
    begin
      params[:server_id] ? server_id = params[:server_id] : server_id = ""
      server = Server.where("id = ?", server_id).first
      if server.nil?
        return render :status => 404, :json=>{:status=>:failed,:error=>"Invalid Server"}
      else
        @info = Server.find_by_sql("SELECT s.id FROM servers s WHERE s.id=#{server_id}").first
        sql="SELECT sr.id, sr.server_id, sr.rating, sr.text,
            u.id as user_id, u.username, sr.created_at, sr.updated_at
            FROM server_ratings sr
            JOIN users u ON u.id = sr.user_id
            WHERE server_id=?
            ORDER BY sr.updated_at DESC"

        limit = params[:limit]
        offset = params[:offset]
        if (!limit.nil? && !offset.nil?)
          sql << " LIMIT #{limit} OFFSET #{offset}"
        end
        @server_comments = find_by_sql(ServerRating, sql, server_id)
      end #end server.nil?
    rescue
      render :status => 503, :json =>{:status=>:failed}
    end
  end

  #Add server favourite
  def server_favourite
    begin
      ServerFavourite.transaction do
        server_id = @parsed_json["server_id"] if @parsed_json["server_id"]
        is_favourite = @parsed_json["is_favourite"] if @parsed_json["is_favourite"]
        server = Server.find_by_id(server_id.to_i)
        unless server.blank?
          if is_favourite == 0 || is_favourite == 1
              check_favourite = ServerFavourite.where("server_id=? AND user_id=?", server_id, @user.id).first

              if check_favourite.nil?
                @server_fav = ServerFavourite.new
                @server_fav.server_id = server_id
                @server_fav.user_id = @user.id
                @server_fav.favourite = is_favourite
                @server_fav.save!
                return render :status => 200, :json =>{:status=>:success}
              else
                check_favourite.update_attributes!(:favourite => is_favourite)
                return render :status => 200, :json =>{:status=>:success}
              end #end check_favourite
          else
            return render :status => 412, :json =>{:status=> :failed, :error => "Invalid is_favourite"}
          end #end if is_favourite
        else
          return render :status => 412, :json =>{:status=> :failed, :error => "Invalid server_id"}
        end
      end #end transaction
    rescue
      return render :status => 503, :json =>{:status=>:failed}
    end
  end

   def test_mail
    @parsed_json = ActiveSupport::JSON.decode(request.body)
    UserMailer.test_send_email(@parsed_json["email"]).deliver
    return render :json =>{:a =>"asd"}
   end

  # Begin - New services for Order and Pay feature

  # POST /order/new_order_v1
  def new_order_v1
    begin
      @parsed_json["order_items"] ? order_items = @parsed_json["order_items"] : nil
      @parsed_json["location_id"] ? location_id = @parsed_json["location_id"].to_i : nil
      location = Location.find_by_id(location_id)
      tax = location.tax #look up tax of location manually
      if location.nil? || location_id.nil? || order_items.nil? || tax.nil?
        return render :status => 404, :json => {:status => :failed, :error => "Resource not found"}
      end
      ActiveRecord::Base.transaction do
        if Order.is_current(@user.id, location)
          current_order = Order.find_by_user_id_and_location_id_and_is_paid_and_is_cancel(@user.id, location.id, 0, 0)
          ordered_date = current_order.created_at
          if current_order.order_items.length > 0
            ordered_date = Time.now.utc
          end

          order_item = OrderItem.add_new_item_v1(order_items, current_order)

          # re-calculate sub_price of order
          sub_price = Order.calculate_sub_price(current_order)
          fee = location.service_fee_type=='fixed'? location.fee : sub_price / 100 * location.fee

          if !order_item.prize_id.nil? && order_item.is_prize_item == 1
            current_order.update_attributes!(
              :location_id => location.id,
              :tax => tax,
              :fee => fee,
              :created_at => ordered_date,
              :status => 1,
              :sub_price => sub_price
            )
          else
            current_order.update_attributes!(
              :location_id => location.id,
              :tax => tax,
              :fee => fee,
              :created_at => ordered_date,
              :sub_price => sub_price
            )
          end

          if current_order.in_order?
            current_order.update_attributes!(:status => 2)
          end

          total_price = Order.calculate_total_price(current_order)
          current_order.update_attribute('total_price', total_price)

          return render :status => 200,
                        :json => {
                          :status => :success,
                          :order_id => current_order.id,
                          :order_item_id => order_item.id,
                          :order_item_status => order_item.status
                        }
        else # this is a brand-new Order
          today_orders = Order.where('created_at > ?', Time.now.strftime("%Y-%m-%d")+" 00:00:00")

          new_order = Order.new
          new_order.user_id = @user.id
          new_order.tax = tax
          new_order.location_id = location.id
          new_order.timezone = location.timezone
          new_order.receipt_day_id = Order.next_receipt_no(location)
          new_order.ticket = today_orders.count+1
          order_item = OrderItem.add_new_item_v1(order_items, new_order)
          # if user added a prize item to cart, status of cart would be changed to ordered
          if !order_item.prize_id.nil? && order_item.is_prize_item == 1
            new_order.status = 1
          end
          sub_price = Order.calculate_sub_price(new_order)
          new_order.sub_price = sub_price
          new_order.total_tax = sub_price * tax
          new_order.total_tip = -2
          new_order.tip_percent = 0.16
          new_order.fee = location.service_fee_type=='fixed'? location.fee : sub_price / 100 * location.fee
          new_order.save!

          total_price = Order.calculate_total_price(new_order)
          new_order.update_attribute('total_price', total_price)
          # Automatically check the user in at this location (to allow item grading)
          @user.checkin_at(location, false)

          return render :status => 200,
                        :json => {
                          :status => :success,
                          :order_id => new_order.id,
                          :order_item_id => order_item.id,
                          :order_item_status => order_item.status
                        }
        end
      end
    rescue
      return render :status => 500, :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  def update_item_v1
    begin
      @parsed_json["order_items"] ? order_items = @parsed_json["order_items"].to_a : nil
      @parsed_json["order_id"] ? order_id = @parsed_json["order_id"].to_i : order_id = nil
      order = Order.find_by_id(order_id)
      ActiveRecord::Base.transaction do
        if order.nil? || order_items.nil?
          return render :status => 404, :json => {:status => :failed, :error => "Resource not found"}
        end
        order_items.each do |i|
          # 1 : Order is pending, diner can increase/decrease/delete item => update item
          # 2 : Order is ordered, diner can only increase quantity of item => That means they add an new item to order
          # 3 : decrease quantity of item in order to 0 => it means diner want to remove this item from his/her order
          order_item = OrderItem.find(i['id'])
          if i['quantity'].to_i != 0
            order_item.update_attributes!(
                :quantity => i['quantity'],
                :price => i['price'],
                :redemption_value => i['redemption_value'],
                :note => i['note'],
                :use_point => i['use_point'],
                :status => i['status']
              )
            OrderItemOption.update_item_options(order_item, i['order_item_options'].to_a)
          else
            order_item.destroy
          end
        end
        # re-calculate sub_price of order
        sub_price = Order.calculate_sub_price(order)
        order.update_attribute(:sub_price, sub_price)
      end
      return render :status => 200, :json => {:status => :success}
    rescue
      return render :status => 500, :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  def update_order_v1
    begin
      @parsed_json["order_id"] ? order_id = @parsed_json["order_id"].to_i : nil
      @parsed_json["order_items"] ? order_items = @parsed_json["order_items"].to_a : nil
      @parsed_json["server_id"] ? server_id = @parsed_json["server_id"].to_i : nil
      total_tip = @parsed_json["total_tip"] if @parsed_json["total_tip"]
      tip_percent = @parsed_json["tip_percent"] if @parsed_json["tip_percent"]
      total_tax = @parsed_json["total_tax"] if @parsed_json["total_tax"]
      fee = @parsed_json["fee"] if @parsed_json["fee"]
      sub_price = @parsed_json["sub_price"] if @parsed_json["sub_price"]
      total_price = @parsed_json["total_price"] if @parsed_json["total_price"]
      status = @parsed_json["status"].to_i if @parsed_json["status"]
      code = -1
      total_redemption = 0
      ActiveRecord::Base.transaction do
        order = Order.find_by_id(order_id)
        return render :status => 404, :json => {:status => :failed, :error => "Resource not found"} if order.nil?  || order_items.nil?
        @location = Location.get_location_name_and_email(order.location_id)

        # Diner use point to pay instead of using cash
        # Minus point of user immediately if they select to pay by point. when the day was over, if their order still isn't paid (pending/ordered )
        # Return points to them (cron job)
        # use_point of an item <=> a record is saved in table user_points
        # when day was over -> create a new record
        # many items were ordered by point in one day => update number of point in table user_points
        order_items.each do |oi|
          item = OrderItem.find(oi['id'].to_i)
          if item.prize_id.nil?
            if oi['is_deleted'].to_i == 0
              if item.use_point.to_i == 0
                total_redemption = total_redemption + oi['use_point'].to_i
              else
                if item.use_point.to_i != oi['use_point'].to_i
                  total_redemption = total_redemption + oi['use_point'].to_i
                end
              end
            end
          end
        end

        user_points = UserPoint.where("user_id = ? and location_id = ? and point_type = ? and is_give =? ",\
          @user.id, order.location_id, REDEMPTION, 0).order("id DESC").first
        unless user_points.nil?
          if order.created_at > user_points.created_at
            UserPoint.minus_points(@user.id, order.location_id, total_redemption) if total_redemption > 0
          else
             today = Time.now.in_time_zone("#{@location.timezone}").strftime('%Y-%m-%d')
             user_point_date = user_points.created_at.in_time_zone("#{@location.timezone}").strftime('%Y-%m-%d')
             if user_point_date.to_s != today.to_s
                UserPoint.minus_points(@user.id, order.location_id, total_redemption) if total_redemption > 0
             else
                user_points.update_attributes(:points => total_redemption) if total_redemption > 0
             end
          end
        else
          UserPoint.minus_points(@user.id, order.location_id, total_redemption) if total_redemption > 0
        end
        # end of redemption point
        selected_server = nil
        if server_id != 0
          selected_server = server_id unless Server.find_by_id(server_id).nil?
        end
        order.update_attributes!(
          :server_id => selected_server,
          :total_tip => total_tip,
          :status => status,
          :total_tax => total_tax,
          :fee => fee,
          :sub_price => sub_price,
          :total_price => total_price,
          :tip_percent => tip_percent
        )
        OrderItem.update_items_v1(order_items)
        return render :status => 200,
                      :json => {
                        :status => :success,
                        :order_id => order.id,
                        :is_token => code
                      }
      end
    rescue
      return render :json => 500 , :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  # 2015-04-21 Reported as deprecated
  # def pay_order_v1
  #   @parsed_json["order_id"] ? order_id = @parsed_json["order_id"].to_i : nil
  #   is_rate_all_items= true
  #   total_redemption_value = 0
  #   begin
  #     order = Order.find_by_id(order_id)
  #     return render :status => 404, :json => {:status => :failed, :error => "Resource not found"} if order.nil?

  #     @order_items = OrderItem.joins(:item).where("order_items.order_id = ?",order_id)\
  #       .select("order_items.id as order_item_id, items.id as id, items.name as item_name, items.price, order_items.quantity")

  #     #collect Menu Item to one Record
  #     @order_items.each do |item|
  #       @order_item_options = OrderItemOption.where("order_item_id = ?", item.order_item_id)
  #     end
  #     @order_items.each do |i|
  #       i[:is_delete] = 0
  #     end
  #     for i in (0..@order_items.length-1)
  #       tem =  @order_items[i]
  #       for j in (i+1..@order_items.length-1)
  #         if tem[:id] ==  @order_items[j][:id]
  #           tem[:quantity] += @order_items[j][:quantity]
  #           tem[:price] =  @order_items[j][:price]
  #           @order_items[j][:price] = 0
  #           @order_items[j][:is_delete] = 1
  #         end
  #       end
  #     end
  #     @order_items.delete_if do |a|
  #       a[:is_delete] == 1
  #     end

  #     ActiveRecord::Base.transaction do
  #       order.update_attributes!(:paid_date => Time.now.utc, :is_paid => 1)
  #       items = order.order_items
  #       # Add user to restaurant contact list
  #       CustomersLocations.add_contact(Array([@user.id]), order.location_id)

  #       # check if diner rate all items in order
  #       items.each do |item|
  #         total_redemption_value = total_redemption_value + item.use_point if !item.prize_id.nil? && item.is_prize_item == 1
  #         comment = ItemComment.find_by_order_item_id(item.id)
  #         if comment.nil?
  #           is_rate_all_items = false
  #         end
  #       end

  #       # minus user points used to pay the prize in order
  #       # UserPoint.minus_points(@user.id, order.location_id, total_redemption_value) if total_redemption_value > 0

  #     # save notification and send an email to user
  #       from_user = Location.find_by_id(order.location_id)
  #       notification = Notifications.new
  #       notification.to_user = @user.email
  #       notification.msg_subject = GENERAL_MESSAGE
  #       notification.msg_type = 'single'
  #       notification.alert_type = ORDER_ALERT_TYPE
  #       notification.alert_logo = GENERAL_MESSAGE_LOGO
  #       if is_rate_all_items
  #         notification.message = PAY_ORDER_BODY_RATING_ALL
  #       else
  #         notification.message = PAY_ORDER_BODY
  #       end
  #       notification.location_id = order.location_id
  #       notification.from_user = from_user.owner_id if !from_user.nil? && !from_user.owner_id.nil?
  #       notification.save!

  #       UserMailer.custom_send_email_pay_order_v1(@user.email, is_rate_all_items, from_user, order, @order_items, @order_item_options).deliver
  #       return render :status => 200,:json => {:status => :success}
  #     end
  #   # rescue
  #   #   return render :json => 500 , :json => {:status => :failed, :error => "Internal Service Error"}
  #   end
  # end
  def my_order_history
    begin
      params[:location_id] ? location_id = params[:location_id].to_i : nil
      location = Location.find_by_id(location_id)
      params[:order_id] ? order_id = params[:order_id].to_i : nil
      return render :status => 404, :json => {:status => :failed, :error => "Resource not found"} if location.nil?

      @order = Order.find(order_id)
      @order["service_fee"] = location.fee
      @order["service_fee_type"] = location.service_fee_type
      @order_items = OrderItem.get_items_of_current_order(@order.id)
      @server = Server.get_server_of_current_order(@order.user_id, location)
    rescue
      return render :status => 500, :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end
  def get_order_v1
    begin
      params[:location_id] ? location_id = params[:location_id].to_i : nil
      location = Location.find_by_id(location_id)
      return render :status => 404, :json => {:status => :failed, :error => "Resource not found"} if location.nil?

      @order = Order.get_current_order_of_diner(@user.id, location)
      unless @order.empty?
        @order_items = OrderItem.get_items_of_current_order(@order.first.id)
      end
      @server = Server.get_server_of_current_order(@user.id, location)
    rescue
      return render :status => 500, :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  def details_v1
    begin
      params[:id] ? order_id = params[:id].to_i : nil
      @order = Order.where(["id = ? and is_paid = 1", order_id])\
        .select("*, id as receipt_no,IFNULL(total_tip, -1) as total_tip,IFNULL(orders.tip_percent, -1) as tip_percent ").first
      if @order.nil?
        return render :status => 404, :json => {:status => :failed, :error => "Resource not found"}
      end
      @order.update_attribute(:read, 1) # diner has viewed their order in history
      @order_items = OrderItem.get_items(@order.id)
      @server = Server.get_servers(@user.id, @order.id)
    rescue
      return render :status => 500, :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  def get_amount_items_v1
    begin
      ActiveRecord::Base.transaction do
        @parsed_json["location_id"] ? location_id = @parsed_json["location_id"].to_i : nil
        location = Location.find_by_id(location_id)
        return render :status => 404, :json => {:status => :failed, :error => "Resource not found"} if location.nil?
        amount_of_items = 0
        if Order.is_current(@user.id, location)
          current_order = Order.find_by_user_id_and_location_id_and_is_paid_and_is_cancel(@user.id, location.id, 0, 0)
          items = current_order.order_items
          items.each do |i|
            amount_of_items += i.quantity
          end
        end
        return render :json => 200 , :json => {:status => :success, :amount => amount_of_items}
      end
    rescue
      return render :json => 500 , :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  def my_orders
    # @testitem = OrderItem.find 1544
    @active_myorders = ' class="active" '
    @user = current_user
    if  @user.role == 'admin'

       if params[:from] and params[:to]
        Time.zone = "America/Chicago"
        @orders = Order.joins(:user).where("users.is_register=0 AND orders.is_cancel=0 AND orders.created_at BETWEEN ? AND ?", Time.zone.parse("#{params[:from]} 00:00:00").in_time_zone('UTC'), Time.zone.parse("#{params[:to]} 23:59:59").in_time_zone('UTC'))

      elsif params[:keyword] and params[:keyword] != ''
        if params[:keyword].match(/^\d+[,.]\d+/)
          price = params[:keyword].split('.', 2).first
          @orders = Order.joins(:user).where("users.is_register=0 AND orders.is_cancel=0 AND orders.total_price >= ? AND orders.total_price < ?", price.to_i, price.to_i + 1)

        else
          keyword = params[:keyword].gsub(/[^a-zA-Z0-9\-\.\s]/,"")
          @orders = Order.joins(:user).where("users.is_register=0 AND orders.is_cancel=0 AND (users.username LIKE ? OR CAST(orders.total_price AS CHAR) LIKE ? OR users.phone LIKE ? OR orders.payment_type LIKE ? OR CAST(orders.ticket AS CHAR) LIKE ?) OR orders.phone LIKE ?", '%' + keyword + '%', keyword.split(',', 2).first + '%', '%' + keyword + '%', '%' + keyword + '%', '%' + keyword + '%', '%' + keyword + '%')
        end

      else
        @orders = Order.joins(:user).where("users.is_register=0 AND orders.is_cancel=0")

      end
      # @all_orders = Order.joins(:user).where("users.is_register=0 AND orders.is_cancel=0")
    else
      @location_ids = current_user.restaurants
      if params[:from] and params[:to]
        Time.zone = "America/Chicago"
        @orders = Order.joins(:user).where("location_id IN (?) AND users.is_register=0 AND orders.is_cancel=0 AND orders.created_at BETWEEN ? AND ?", @location_ids, Time.zone.parse("#{params[:from]} 00:00:00").in_time_zone('UTC'), Time.zone.parse("#{params[:to]} 23:59:59").in_time_zone('UTC'))

      elsif params[:keyword] and params[:keyword] != ''
        if params[:keyword].match(/^\d+[,.]\d+/)
          price = params[:keyword].split('.', 2).first
          @orders = Order.joins(:user).where("location_id IN (?) AND users.is_register=0 AND orders.is_cancel=0 AND orders.total_price >= ? AND orders.total_price < ?", @location_ids, price.to_i, price.to_i + 1)

        else
          keyword = params[:keyword].gsub(/[^a-zA-Z0-9\-\.\s]/,"")
          @orders = Order.joins(:user).where("location_id IN (?) AND users.is_register=0 AND orders.is_cancel=0 AND (users.username LIKE ? OR CAST(orders.total_price AS CHAR) LIKE ? OR users.phone LIKE ? OR orders.payment_type LIKE ? OR CAST(orders.ticket AS CHAR) LIKE ? OR orders.phone LIKE ?)", @location_ids, '%' + keyword + '%', keyword.split(',', 2).first + '%', '%' + keyword + '%', '%' + keyword + '%','%' + keyword + '%','%' + keyword + '%')
        end
      else
        @orders = Order.joins(:user).where("location_id IN (?) AND orders.is_cancel=0 AND users.is_register=0", @location_ids)
      end
      # @all_orders = Order.joins(:user).where("location_id IN (?) AND orders.is_cancel=0 AND users.is_register=0", @location_ids)


    end
    @total_price = @orders.sum :total_price
    @total_tip = @orders.sum :total_tip
    @total_tax = @orders.sum :total_tax
    @fee = @orders.sum :fee
    @total_orders = @orders.count
    @net_price = @total_price - @total_tip - @total_tax - @fee
    @orders =  @orders.order("id DESC")
    @csv_orders = @orders


    @orders = Kaminari.paginate_array(@orders).page(params[:page]).per(25)
    respond_to do |format|
      format.html
      format.csv { send_data export_csv(@csv_orders) }
    end
  end
  def export_csv(orders)
    CSV.generate do |csv|
      csv << ["Payment Status","Receipt #","Order Date/Time","Pickup Date/Time","Username","User Status","Phone Number","Order Status","Tip","Tax","Service Fee","SubTotal", "Total"]
      orders.each do |order|
        @tax = order.total_tax.to_f
        if order.total_tax.to_i ==0
            @tax = order.location.tax.to_f*order.sub_price.to_f
        end
        csv << [order.payment_type,order.ticket,order.created_at.in_time_zone(order.timezone).strftime("%Y/%m/%d %I:%M %p"),order.pickup_time.try(:strftime, "%Y/%m/%d %I:%M %p"),order.user.username,User.get_current_status(order.location_id, order.user_id),order.phone.present? ? order.phone : order.user.phone,order.get_current_order_status_text(),order.total_tip, @tax, order.fee, order.sub_price, order.total_price]
      end
    end
  end

  def restaurant_orders
    @active_restaurant_orders = ' class="active" '
    to = increment_date params[:to]
    @user = current_user
    @slug = params[:restaurant_id]
    @restaurant = Location.where("slug=?", @slug)
    @orders = nil
    unless @restaurant.nil?
      if  @user.role == 'admin' || @user.role == 'cashier'
        if params[:from] and to
            Time.zone = "America/Chicago"
            @orders = Order.joins(:user).joins(:location).where("is_paid=1 AND location_id=? AND orders.is_cancel=0 AND users.is_register=0 AND orders.created_at BETWEEN ? AND ?", @restaurant.first.id, Time.zone.parse("#{params[:from]} 00:00:00").in_time_zone('UTC'), Time.zone.parse("#{params[:to]} 23:59:59").in_time_zone('UTC'))
        elsif params[:keyword] and params[:keyword] != ''
          if params[:keyword].match(/^\d+[,.]\d+/)
            price = params[:keyword].split('.', 2).first
            @orders = Order.joins(:user).joins(:location).where("is_paid=1 AND location_id=? AND users.is_register=0 AND orders.is_cancel=0 AND orders.total_price >= ? AND orders.total_price < ?", @restaurant.first.id, price.to_i, price.to_i + 1)
          else
            keyword = params[:keyword].gsub(/[^a-zA-Z0-9\-\.\s]/,"")
            @orders = Order.joins(:user).joins(:location).where("is_paid=1 AND location_id=? AND orders.is_cancel=0 AND users.is_register=0 AND (users.username LIKE ? OR CAST(orders.total_price AS CHAR) LIKE ? OR users.phone LIKE ? OR orders.payment_type LIKE ? OR orders.phone LIKE ?)", @restaurant.first.id, '%' + keyword + '%', keyword.split(',', 2).first + '%', '%' + keyword + '%', '%' + keyword + '%', '%' + keyword + '%')
          end
        else
          @orders = Order.joins(:user).joins(:location).where("is_paid=1 AND location_id=? AND orders.is_cancel=0 AND users.is_register=0", @restaurant.first.id)
        end
      else
        if params[:from] and to
          Time.zone = "America/Chicago"
          @orders = Order.joins(:user).joins(:location).where("is_paid=1 AND location_id=? AND orders.is_cancel=0 AND users.is_register=0 AND orders.created_at BETWEEN ? AND ?  AND locations.owner_id=?", @restaurant.first.id, Time.zone.parse("#{params[:from]} 00:00:00").in_time_zone('UTC'), Time.zone.parse("#{params[:to]} 23:59:59").in_time_zone('UTC'), @user.id)
        elsif params[:keyword] and params[:keyword] != ''
          if params[:keyword].match(/^\d+[,.]\d+/)
            price = params[:keyword].split('.', 2).first
            @orders = Order.joins(:user).joins(:location).where("is_paid=1 AND location_id=? AND users.is_register=0 AND orders.is_cancel=0 AND orders.total_price >= ? AND orders.total_price < ? AND locations.owner_id=? ", @restaurant.first.id, price.to_i, price.to_i + 1, @user.id)
          else
            keyword = params[:keyword].gsub(/[^a-zA-Z0-9\-\.\s]/,"")
            @orders = Order.joins(:user).joins(:location).where("is_paid=1 AND location_id=? AND orders.is_cancel=0 AND users.is_register=0 AND (users.username LIKE ? OR CAST(orders.total_price AS CHAR) LIKE ? OR users.phone LIKE ? OR orders.payment_type LIKE ? OR orders.phone LIKE ?)  AND locations.owner_id=?", @restaurant.first.id, '%' + keyword + '%', keyword.split(',', 2).first + '%', '%' + keyword + '%','%' + keyword + '%', '%' + keyword + '%', @user.id)
          end
        else
          @orders = Order.joins(:user).joins(:location).where("is_paid = 1 AND location_id=? AND orders.is_cancel=0 AND users.is_register=0 AND locations.owner_id=?", @restaurant.first.id, @user.id)
        end
      end
      @total_price = @orders.sum :total_price
      @total_tip = @orders.sum :total_tip
      @total_tax = @orders.sum :total_tax
      @fee = @orders.sum :fee
      @total_orders = @orders.count
      @net_price = @total_price - @total_tip - @total_tax - @fee
      @total_count = @orders.count
      @orders =  @orders.order("id DESC")
      @csv_orders = @orders
      @orders = Kaminari.paginate_array(@orders).page(params[:page]).per(25)

    end
    respond_to do |format|
      format.json {render :json => {orders: @orders, total_count: @total_count}}
      format.html
      format.csv { send_data export_csv(@csv_orders) }
    end
  end

  def view_order
    params[:order_id] ? order_id = params[:order_id].to_i : order_id = nil
    @user = current_user
    @order_id = order_id
    begin
      @order = Order.find_by_id(@order_id)
      @order_items = OrderItem.get_items_current_order(@order.id)
      if @user.role != 'admin' && @user.role != CASHIER_ROLE && @order.location.owner_id != @user.id
        @order = nil
      end
    rescue
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def toggle_pos
    params[:order_id] ? order_id = params[:order_id].to_i : order_id = nil
    @user = current_user
    @order_id = order_id
    @accepted = false
    begin
      @order = Order.find_by_id(@order_id)
      if @user.role != 'admin' && @order.location.owner_id != @user.id
        @order = nil
      else
        if params[:accept]
          @order.update_attribute(:pos, !@order.pos)
          @accepted = true
        end
      end
    rescue
    end
    respond_to do |format|
      format.js
    end
  end

  def resend_receipt
    params[:order_id] ? order_id = params[:order_id].to_i : order_id = nil
    @user = current_user
    @order_id = order_id
    @accepted = false
    begin
      @order = Order.find_by_id(@order_id)
      @order_items = OrderItem.get_items_current_order(@order.id)
      if @user.role != 'admin'  && @user.role != CASHIER_ROLE && @order.location.owner_id != @user.id
        @order = nil
      end
    rescue

    end
    if params[:accept]
      UserMailer.send_email_receipt(@order.location, @order, @order_items).deliver
      @accepted = true
    end
    respond_to do |format|
      format.js
    end
  end

  def change_status
    params[:order_id] ? order_id = params[:order_id].to_i : order_id = nil
    @user = current_user
    @order_id = order_id
    @accepted = false
    begin
      @order = Order.find_by_id(@order_id)
      if @user.role != 'admin' && @user.role != CASHIER_ROLE  && @order.location.owner_id != @user.id
        @order = nil
      end

      if params[:accept]

        ActiveRecord::Base.transaction do
          @order.update_attribute(:status, @order.status + 1)
          @accepted = true
        end
      end

    rescue
    end
    respond_to do |format|
      format.js
    end
  end

  def update_order_v2
    begin
      @parsed_json["order_id"] ? order_id = @parsed_json["order_id"].to_i : nil
      @parsed_json["order_items"] ? order_items = @parsed_json["order_items"].to_a : nil
      @parsed_json["server_id"] ? server_id = @parsed_json["server_id"].to_i : nil
      total_tip = @parsed_json["total_tip"] if @parsed_json["total_tip"]
      tip_percent = @parsed_json["tip_percent"] if @parsed_json["tip_percent"]
      total_tax = @parsed_json["total_tax"] if @parsed_json["total_tax"]
      fee = @parsed_json["fee"] if @parsed_json["fee"]
      sub_price = @parsed_json["sub_price"] if @parsed_json["sub_price"]
      total_price = @parsed_json["total_price"] if @parsed_json["total_price"]
      status = @parsed_json["status"].to_i if @parsed_json["status"]
      phone = @parsed_json["phone"] if @parsed_json["phone"]
      pickup_time = @parsed_json["pickup_time"] if @parsed_json["pickup_time"]
      pickup_time_period = @parsed_json["pickup_time_period"] if @parsed_json["pickup_time_period"]

      user_added_credit_card = false

      total_redemption = 0
      ActiveRecord::Base.transaction do

        order = Order.find_by_id(order_id)
        return render :status => 404, :json => {:status => :failed, :error => "Resource not found"} if order.nil?  || order_items.nil?

        @location = Location.get_location_name_and_email(order.location_id)

        # Diner use point to pay instead of using cash
        # Minus point of user immediately if they select to pay by point. when the day was over, if their order still isn't paid (pending/ordered )
        # Return points to them (cron job)
        # use_point of an item <=> a record is saved in table user_points
        # when day was over -> create a new record
        # many items were ordered by point in one day => update number of point in table user_points
        order_items.each do |oi|
          item = OrderItem.find(oi['id'].to_i)
          if item.prize_id.nil?
            if oi['is_deleted'].to_i == 0
              if item.use_point.to_i == 0
                total_redemption = total_redemption + oi['use_point'].to_i
              else
                if item.use_point.to_i != oi['use_point'].to_i
                  total_redemption = total_redemption + oi['use_point'].to_i
                end
              end
            end
          end
        end

        user_points = UserPoint.where("user_id = ? and location_id = ? and point_type = ? and is_give =? ",\
          @user.id, order.location_id, REDEMPTION, 0).order("id DESC").first
        unless user_points.nil?
          if order.created_at > user_points.created_at
            UserPoint.minus_points(@user.id, order.location_id, total_redemption) if total_redemption > 0
          else
             today = Time.now.in_time_zone("#{@location.timezone}").strftime('%Y-%m-%d')
             user_point_date = user_points.created_at.in_time_zone("#{@location.timezone}").strftime('%Y-%m-%d')
             if user_point_date.to_s != today.to_s
                UserPoint.minus_points(@user.id, order.location_id, total_redemption) if total_redemption > 0
             else
                user_points.update_attributes(:points => total_redemption) if total_redemption > 0
             end
          end
        else
          UserPoint.minus_points(@user.id, order.location_id, total_redemption) if total_redemption > 0
        end
        # end of redemption point
        selected_server = nil
        if server_id != 0
          selected_server = server_id unless Server.find_by_id(server_id).nil?
        end

        pickup_time = update_pickup_time(pickup_time, pickup_time_period) if pickup_time.present? && pickup_time_period.present?
        order.update_attributes!(
          :server_id => selected_server,
          :total_tip => total_tip,
          :status => status,
          :total_tax => total_tax,
          :fee => fee,
          :sub_price => sub_price,
          :total_price => total_price,
          :tip_percent => tip_percent,
          :pickup_time => pickup_time,
          :phone => phone
        )
        OrderItem.update_items_v1(order_items)

        if order.is_ordered?
          #@user.update_attribute(:phone, phone)
        end
        return render :status => 200,
                      :json => {
                        :status => :success,
                        :order_id => order.id,
                        :user_added_credit_card => user_added_credit_card
                      }
      end
    # rescue
    #   return render :json => 500 , :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  def pay_order_v2
    @parsed_json["order_id"] ? order_id = @parsed_json["order_id"].to_i : nil
    payment_type = @parsed_json["payment_type"] if @parsed_json["payment_type"]
    is_rate_all_items= true
    total_redemption_value = 0
    begin
      order = Order.find_by_id(order_id)
      return render :status => 404, :json => {:status => :failed, :error => "Resource not found"} if order.nil?

      @order_items = OrderItem.joins(:item).where("order_items.order_id = ?",order_id)\
        .select("order_items.id as order_item_id, items.id as id, items.name as item_name, items.price, order_items.quantity, order_items.use_point").order("order_item_id desc")

      # @order_items.each do |i|
      #   i[:is_delete] = 0
      # end
      # for i in (0..@order_items.length-1)
      #   tem =  @order_items[i]
      #   for j in (i+1..@order_items.length-1)
      #     if tem[:id] ==  @order_items[j][:id]
      #       tem[:quantity] += @order_items[j][:quantity]
      #       tem[:price] =  @order_items[j][:price]
      #       @order_items[j][:price] = 0
      #       @order_items[j][:is_delete] = 1
      #     end
      #   end
      # end
      # @order_items.delete_if do |a|
      #   a[:is_delete] == 1
      # end

      ActiveRecord::Base.transaction do
        order.update_attributes!(:paid_date => Time.now.utc, :is_paid => 1, :payment_type => payment_type)
        items = order.order_items
        # Add user to restaurant contact list
        CustomersLocations.add_contact(Array([@user.id]), order.location_id)

        # check if diner rate all items in order
        items.each do |item|
          total_redemption_value = total_redemption_value + item.use_point if !item.prize_id.nil? && item.is_prize_item == 1
          comment = ItemComment.find_by_order_item_id(item.id)
          if comment.nil?
            is_rate_all_items = false
          end
        end

        # minus user points used to pay the prize in order
        # UserPoint.minus_points(@user.id, order.location_id, total_redemption_value) if total_redemption_value > 0

      # save notification and send an email to user
        from_user = Location.find_by_id(order.location_id)
        notification = Notifications.new
        notification.to_user = @user.email
        notification.msg_subject = GENERAL_MESSAGE
        notification.msg_type = 'single'
        notification.alert_type = ORDER_ALERT_TYPE
        notification.alert_logo = GENERAL_MESSAGE_LOGO
        if is_rate_all_items
          notification.message = PAY_ORDER_BODY_RATING_ALL
        else
          notification.message = PAY_ORDER_BODY
        end
        notification.location_id = order.location_id
        notification.from_user = from_user.owner_id if !from_user.nil? && !from_user.owner_id.nil?
        notification.save!

        #UserMailer.custom_send_email_pay_order_v2(@user.email, is_rate_all_items, from_user, order, @order_items).deliver
        UserMailer.custom_send_email_pay_order_v2(@user.email, order.location, order, @order_items).deliver
        return render :status => 200,:json => {:status => :success}
      end
    # rescue
    #   return render :json => 500 , :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  def new_credit_card_v1
    encrypted_cvv = @parsed_json["encrypted_cvv"] if @parsed_json["encrypted_cvv"]
    encrypted_expiration_month = @parsed_json["encrypted_expiration_month"] if  @parsed_json["encrypted_expiration_month"]
    encrypted_expiration_year  = @parsed_json["encrypted_expiration_year"] if @parsed_json["encrypted_expiration_year"]
    encrypted_number = @parsed_json["encrypted_number"] if @parsed_json["encrypted_number"]
    postal_code = @parsed_json["postal_code"] if @parsed_json["postal_code"]

    create_credit_card = TheLevelUp.create_credit_card(@user, encrypted_cvv, encrypted_expiration_month, encrypted_expiration_year, encrypted_number, postal_code)
    if create_credit_card[:code].to_i == 200
     render :status => 200, :json => {:status => :success}
    else
     render :status => :failed, :json => {:list_error => create_credit_card[:data]}
    end
  end

  def get_payment_token_v1
    begin
      params[:order_id] ? order_id = params[:order_id] : nil
      order = Order.find_by_id(order_id)
      return render :status => 4014, :json => {:status => :failed, :error => "Resource not found"} if order.nil?
      owner_id = order.location.owner_id
      user_levelup = UserLevelup.find_by_user_id(owner_id)
      levelup_order = TheLevelUp.create_order(user_levelup.access_token, order)
      if !levelup_order['uuid'].nil?
        order.update_attributes(:levelup_order_id => levelup_order['uuid'])
      end

      payment_token = TheLevelUp.get_payment_token(@user)
      if !payment_token.nil?
       render :status => 200, :json => {:status => :success,:payment_token_data => payment_token }
      else
        return render :status => 404, :json => {:status => :failed, :error => "Resource not found"}
      end
    rescue
      return render :json => 500 , :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end


  private

  def increment_date(date)
    if date.present?
      last_two = date.chars.last(2).join.to_i
      first_few = date.chars.first(date.length - 2).join
      first_few + ( last_two + 1).to_s
    else
      nil
    end
  end

  def update_pickup_time(pickup_time, pickup_time_period)
    begin
      Time.zone = @location.timezone
      return Time.zone.parse("#{pickup_time} #{pickup_time_period}").in_time_zone('UTC')
    rescue => ex
      nil
    end
  end
end
