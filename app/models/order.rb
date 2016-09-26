class Order < ActiveRecord::Base
  attr_accessible :id, :order_date, :is_paid, :is_cancel, :tip, :user_id, :price, :tax, :fee, :location_id, :receipt_no, :server_id, :paid_date, :status, :ticket,
                  :total_tip, :total_tax, :sub_price, :total_price, :read, :timezone, :qrcode_levelup,:tip_percent, :created_at, :payment_type,
                  :pickup_time, :phone
  attr_accessor :braintree_info
  belongs_to :user
  has_many :order_items ,:dependent=>:destroy
  belongs_to :server
  belongs_to :location
  after_update :status_push_notification, if: :status_changed?

  scope :today, -> (location) { where('location_id = ? AND created_at >= ?', location.id, Time.now.beginning_of_day.in_time_zone("#{location.timezone}")) }

  def status_push_notification
    user = self.user
    if  self.is_paid == 1
      hash = {location_id: self.location_id, order_id: self.id}
      if self.status == 1
        message = "We have started to prepare your meal. Please call the store (#{self.location.phone}) if you have any questions."
        PushNotification.dispatch_message_to_resource_subscribers('order_submitted', message, user, hash)
      elsif self.status == 2
        message = 'Your order is now ready to be picked up!'
        PushNotification.dispatch_message_to_resource_subscribers('order_completed', message, user, hash)
      end
    end
  end

  def store_no
    @locations =  Location.find_by_sql("select id from locations where chain_name in (select chain_name from locations where id = #{self.location_id})")
    count = 0
    for i in @locations
      count = count + 1
      if i['id'] == self.location_id
        break
      end
    end
    return count
  end
  def price
    @items = Item.find_by_sql("select sum(i.price) as price from items i join order_items oi on i.id = oi.item_id
                              join orders io on o.id = oi.order_id where o.id = #{self.id}")
    return @items.first.price
  end

  def get_order_date
    return self.created_at.strftime("%m-%d-%Y %H:%M:%S") if !self.created_at.nil?
  end
  def get_paid_date
    return self.paid_date.strftime("%m-%d-%Y %H:%M:%S") if self.is_paid == 1
  end

  def self.get_current_order(user_id, location_id)
    timezone = Location.find(location_id.to_i).timezone
    current_oders = []
    orders = self.joins(:location)\
                 .where("user_id = ? and location_id = ? and is_paid = ? and is_cancel = ?", user_id,location_id.to_i, 0, 0)\
                 .select("distinct orders.id, IFNULL(server_id,0) as server_id, orders.id as receipt_no, IFNULL(total_tip, -1) as total_tip,
                  locations.id as loca_id, locations.tax as current_tax, orders.fee, orders.created_at, is_paid, location_id, status, orders.tax,IFNULL(tip_percent, -1) as tip_percent")
    orders.each do |order|
      if order.created_at.in_time_zone("#{timezone}").strftime('%Y-%m-%d') == Time.now.in_time_zone("#{timezone}").strftime('%Y-%m-%d')
         current_oders << order
      end
    end
    return current_oders.uniq
  end

  def self.is_current(user_id, location)
    count = 0
    orders = Order.where("is_paid = ? and is_cancel = ? and location_id = ? and user_id = ?", 0, 0, location.id, user_id)
    orders.each do |order|
      if order.created_at.in_time_zone("#{location.timezone}").strftime('%Y-%m-%d')\
         == Time.now.in_time_zone("#{location.timezone}").strftime('%Y-%m-%d')
         count = count + 1
      end
    end
    if count == 0
      return false
    else
      return true
    end
  end

  def self.run_order_cleaning()
    pending_orders = self.where('is_paid = ? and status = ?', 0, 0)
    pending_orders.each do |order_pending|
      unless order_pending.timezone.nil?
       today = Time.now.in_time_zone("#{order_pending.timezone}").strftime('%Y-%m-%d')
        order_date = order_pending.created_at.in_time_zone("#{order_pending.timezone}").strftime('%Y-%m-%d')
        if order_date.to_s != today.to_s
          refuned_points(order_pending.user_id, order_pending.location_id)
          order_pending.destroy
        end
      end
    end

    ordered_orders = self.where('is_paid = ? and status = ? and is_cancel = ? ', 0, 1, 0)
    ordered_orders.each do |order_ordered|
      unless order_ordered.timezone.nil?
        today = Time.now.in_time_zone("#{order_ordered.timezone}").strftime('%Y-%m-%d')
        order_date = order_ordered.created_at.in_time_zone("#{order_ordered.timezone}").strftime('%Y-%m-%d')
        if order_date.to_s != today.to_s
          order_items = order_ordered.order_items
          order_items.each do |oi|
            if oi.status == 0
              oi.destroy
            else
              if !oi.prize_id.nil? && !oi.share_prize_id.nil?
                oi.update_attributes(:prize_id => nil, :share_prize_id => nil, :is_prize_item => 0)
              end
            end
          end
          order_ordered.update_attribute(:is_cancel, 1)
          refuned_points(order_ordered.user_id,order_ordered.location_id)
        end
      end
    end
  end
  def self.refuned_points(user_id,location_id)
    user_points = UserPoint.where("user_id = ? and location_id = ? and point_type = ? and is_give =?", user_id, location_id, REDEMPTION, 0)\
                           .order("id DESC").first
    unless user_points.nil?
      if user_points.points.to_i > 0
        UserPoint.create({
          :user_id =>  user_id,
          :point_type => POINTS_REFUNDED,
          :location_id => location_id,
          :points => user_points.points,
          :status => 1,
          :is_give => 1
        })
      end
    end
  end

  # Begin - Implement the new version for order feature
  def self.get_current_order_of_diner(user_id, location)
    timezone = location.timezone
    current_oders = []
    orders = self.joins(:location)\
                 .where("user_id = ? and location_id = ? and is_paid = ? and is_cancel = ?", user_id, location.id, 0, 0)\
                 .select("distinct orders.id, IFNULL(server_id, 0) as server_id, orders.receipt_day_id as receipt_no, IFNULL(total_tip, -1) as total_tip, locations.id as location_id,
                    locations.tax as current_tax, locations.fee as service_fee, locations.service_fee_type, orders.created_at, orders.fee, is_paid, location_id, status, orders.tax, orders.ticket, IFNULL(tip_percent, -1) as tip_percent")
    orders.each do |order|
      if order.created_at.in_time_zone("#{timezone}").strftime('%Y-%m-%d') == Time.now.in_time_zone("#{timezone}").strftime('%Y-%m-%d')
         current_oders << order
      end
    end
    return current_oders.uniq
  end

  def in_order?
    is_in_order = false
    if self.status == 0
      return false
    elsif self.status == 2
      return true
    else
      order_items = self.order_items
      order_items.each do |i|
        if i.status == 0
          is_in_order = true
          break
        end
      end
      return is_in_order
    end
  end
  # End - Implement the new version for order feature
  def get_current_order_status_text()
    if self.status == 0
      return 'New'
    elsif self.status == 1
      return 'Ordered'
    elsif self.status == 2
      if self.is_paid == 1
        return 'Completed'
      end
      return 'In-Ordered'
    elsif self.status == 3
      return 'Refunded'
    end
  end
  def get_current_order_status()
    if self.status == 0
      return '<span class="order-status label-new">New</span>'
    elsif self.status == 1
      return '<span class="order-status label-ordered">Ordered</span>'
    elsif self.status == 2
      if self.is_paid == 1
        return '<span class="order-status label-completed">Completed</span>'
      end
      return '<span class="order-status label-inorder">In-Ordered</span>'
    elsif self.status == 3
      return '<span class="order-status label-new">Refunded</span>'
    end
  end

  def is_ordered?
    is_ordered = true

    order_items = self.order_items
    order_items.each do |i|
      if i.status == 0
        is_ordered = false
        break
      end
    end
    return is_ordered
  end

  def self.calculate_sub_price(order)
    sub_price = 0
    items = order.order_items
    items.each do |i|
      sub_price = sub_price + (i.price * i.quantity.to_i - i.use_point.to_i)
      options = i.order_item_options
      options.each do |j|
        j.price ||= 0.00
        #sub_price = sub_price.to_f + j.price * (i.quantity - j.quantity)
        sub_price = sub_price.to_f + j.price * i.quantity
      end
    end
    return sub_price
  end

  def self.calculate_total_price(order)
    total_price = 0
    tax = order.tax
    current_tax = nil
    if !order.location.nil?
      current_tax = order.location.tax
    end
    if !current_tax.nil?
      if order.status = 0
        if tax != current_tax
          tax = current_tax
        end
      end
    end

    total_tax = tax * order.sub_price.to_f

    if !order.tip_percent.nil? && order.tip_percent.to_f > 0 && order.total_tip.to_f == -2

      total_tip = order.tip_percent.to_f * order.sub_price.to_f
      total_price = order.sub_price.to_f + total_tip + total_tax + order.fee
    else
      if order.total_tip.to_f > 0 && order.tip_percent.to_f == -2
        total_price = order.sub_price.to_f + order.total_tip.to_f + total_tax + order.fee
      end
    end
    return total_price
  end

  def self.next_receipt_no(location)
    Order.today(location).last.try(:receipt_day_id).to_i + 1
  end

  def pay_order(amount, token)
    result = Braintree::Transaction.sale(
      amount: self.total_price.round(2).to_s,
      merchant_account_id: self.location.customer_id,
      payment_method_nonce: token,
      service_fee_amount: (self.total_price * 0.029 + 0.30).round(2).to_s,
      options: {
        submit_for_settlement: true
      }
    )
    if result.class == Braintree::SuccessfulResult
      self.update_attribute('payment_type', 'Credit Card')
      self.update_attribute('is_paid', 1)
      self.update_attribute('order_id', result.transaction.id)
      self.update_attribute('status', 0)
      self.update_attribute('paid_date', DateTime.now)
      #sending email to the user
      is_rate_all_items = true
      items = self.order_items
      items.each do |item|
          comment = ItemComment.find_by_order_item_id(item.id)
          if comment.nil?
            is_rate_all_items = false
          end
        end
      @order_items = OrderItem.joins(:item).where("order_items.order_id = ?",self.id)\
      .select("order_items.id as order_item_id, items.id as id, items.name as item_name, items.price, order_items.quantity, order_items.use_point").order("order_item_id desc")
      UserMailer.custom_send_email_pay_order_v2(self.user.email, Location.find_by_id(self.location_id), self, @order_items).deliver
      {status: 'success'}
    else
      {status: 'failed', errors: result.errors}
    end
  end
  def refund
    unless self.order_id.nil?
      transaction = Braintree::Transaction.find self.order_id
      if transaction.status == 'settled' || transaction.status == 'settling'
        result = Braintree::Transaction.refund(self.order_id)
      else
        result = Braintree::Transaction.void(self.order_id)
      end
      if result.success?
        self.update_attribute('status', 3)
        self.update_attribute('is_refunded', true)
        {status: 'success'}
      else
        {status: 'failed', errors: result.errors}
      end
    end
  end


end
