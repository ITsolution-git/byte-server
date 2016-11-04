class UserMailer < ActionMailer::Base
  helper :mail
  default from: "support@mybyteapp.com"
  $support_mail = "support@mybyteapp.com"

  def publish_calendar(email, msg)
    subject = "BYTE Publish Notification Alert"
    mail(to: email, subject: subject, body: msg)
  end

  def send_manager_info(user, email, location)
    @user = user
    subject = "[BYTE] #{location.name} - Manager Account."
    mail(to: email, subject: subject)
  end

  def invition_email(user,link)
    @user = user
    @link = link
    mail(to: @user.email, subject: 'Invitation letter')
  end

  def invition_email_new(email,link, sharer, points)
    @link = link
    @points = points
    @sharer = sharer
    mail(to: email, subject: 'Invitation letter')
  end

  def publish_menu_email(address, menu, published_date_tz)
    subject = "BYTE Publish Notification Alert"
    @menu = menu
    @published_date_tz = published_date_tz
    mail(to: address, subject: subject)
  end

  def unpublish_menu_email(address, menu, published_date_tz)
    subject = "BYTE Unpublish Notification Alert"
    @menu = menu
    @published_date_tz = published_date_tz
    mail(to: address, subject: subject)
  end

  def feedback_v1(username, email, subject, comment)
    @user = username
    @email = email
    @subject = subject
    @comment = comment
    mail(to: $support_mail, subject: 'BYTE Feedback')
  end

  def feedback(username, email, rating, comment)
    @user = username
    @comment = comment
    @email = email
    @rating = rating
    mail(to: $support_mail, subject: 'BYTE Feedback')
  end

  def rating(username, emails, rating, comment)
    #@user = username
    unless emails.nil?
      @comment = comment
      @rating = rating
      emails = emails.kind_of?(Array) ? emails : [emails]
      emails.each do |email|
        mail(to: email, subject: 'BYTE Rating')
      end
    end
  end

  def custom_send_email(email, subject, body)
    mail(to: email, subject: subject, body: body)
  end

  def custom_send_email_unregis(email, restaurant_name, sharer, points, link)
    @restaurant_name = restaurant_name
    @sharer = sharer
    @points = points
    @link = link
    mail(to: email, subject: 'Point Message')
  end

  def custom_send_email_regis(email, restaurant_name, sharer, points)
    @restaurant_name = restaurant_name
    @sharer = sharer
    @points = points
    mail(to: email, subject: 'Point Message')
  end

  def custom_send_email_invite(name, email, inviter, link)
    @inviter = inviter
    @link = link
    @name = name
    subject = "#{inviter} wants you to join BYTE!"
    mail(to: email, from: "support@mybyteapp.com", subject: subject)
  end

  def custom_send_email_pay_order(email,is_send_email_raing_all,location,order,order_items,order_item_combos)
    subject = "BYTE Order Confirmation"
    @order_items = order_items
    @location = location
    @order = order
    @order_item_combos = order_item_combos
    @is_send_email_raing_all = {}
    @is_send_email_raing_all['is_send_email_raing_all'] = is_send_email_raing_all
    mail(to: email, content_type: 'text/html', subject: subject)
  end

  def send_billing_reset_password_email(email, resource)
    subject = "Reset password of billing area"
    @email = email
    @resource = resource
    mail(to: email, content_type: 'text/html', subject: subject)
  end

  def send_email_activate(email)
    subject = "Activate service success!"
    mail(to: email, subject: subject)
  end

  def send_email_cancel_service(email)
    subject = "Cancel service service success!"
    mail(to: email, subject: subject)
  end
  # def custom_send_email_rating_all_pay_order(email)
  #  subject = "Pay order to BYTE!"
  #  body = "You’ve paid your order and got points for rating items. Please go to MyOrder to view your receipt."
  #  mail(to:email, subject:subject,body: body)
  # end

  def send_email_order(location, order_id, order_items, sub_total, total_tax, total_tip, total_price, tip_percent)
    @order_items = order_items
    @location = location
    @order ={}
    @order['order_id'] = order_id
    @order['sub_total'] = sub_total
    @order['total_tax'] = total_tax
    @order['total_tip'] = total_tip
    @order['total_price'] = total_price
    @order['tip_percent'] = tip_percent
    subject = "BYTE Order - #{order_id} "
    mail(to:location.email,content_type: "text/html", subject: subject)
  end

  def send_email_receipt(location, order, order_items)
    @order_items = order_items
    @location = location
    @order = order

    subject = "BYTE Order Receipt"
    mail(to:@order.user.email,content_type: "text/html", subject: subject)
  end

  def send_email_refund(location, order, order_items)
    @order_items = order_items
    @location = location
    @order = order
    @user = @order.user

    subject = "BYTE Issue Refund"
    mail(to:@order.user.email,content_type: "text/html", subject: subject)
  end

  def send_email_order_v1(location, order_id, order_items, sub_total, total_tax, total_tip, total_price, tip_percent)
    @order_items = order_items
    @location = location
    @order ={}
    @order['order_id'] = order_id
    @order['sub_total'] = sub_total
    @order['total_tax'] = total_tax
    @order['total_tip'] = total_tip
    @order['total_price'] = total_price
    @order['tip_percent'] = tip_percent
    subject = "BYTE Order - #{order_id}"
    mail(to: location.email, content_type: "text/html", subject: subject)
  end

  def custom_send_email_pay_order_v1(email, is_send_email_raing_all, location, order, order_items, order_item_options)
    subject = "BYTE Order Confirmation"
    @order_items = order_items
    @location = location
    @order = order
    @order_item_options = order_item_options
    @is_send_email_raing_all = {}
    @is_send_email_raing_all['is_send_email_raing_all'] = is_send_email_raing_all
    mail(to: email, content_type: "text/html", subject: subject)
  end

  def custom_send_email_pay_order_v2(email, location, order, order_items)
    subject = "BYTE Order Confirmation"
    @order_items = order_items
    @location = location
    @order = order
    mail(to: email, content_type: "text/html", subject: subject)
  end

  def send_delete_manager_info(current_user, package, location_name)
    subject = "Delete Account Manager!"
    @user = current_user
    @package = package
    @location_name = location_name
    mail(to: 'mike.little@mymenu.us', subject: subject)
  end

  def send_email_share_prize(email, sharer, prize, restaurant_name, link)
    @sharer = sharer
    @prize = prize
    @restaurant_name = restaurant_name
    @link = link
    mail(to: email, subject: 'Prize Message')
  end

  def send_notification()
    mail(to: "dev.magrabbit@gmail.com", subject: "Run Unlock Prize feature", body: "running")
  end

  def send_mail_unlock_prize(restaurant_name, user_mail, prize_name)
    subject = "CONGRATULATIONS! You have unlocked a prize"
    body = "Congratulations you've unlocked #{prize_name} prize. Please go to MyPrize to Redeem your prize! Can't wait to see you at #{restaurant_name}."
    mail(to: user_mail, subject: subject, body: body)
  end

  def send_email_weekly_report(email, restaurant, week, year)
    @restaurant = restaurant
    @week = week
    @year = year
    mail(to: email, content_type: "text/html", subject: "Weekly Progress Report")
  end

  def send_email_weekly_prize_report(reward)
    @restaurant = reward.location
    emails = reward.weekly_reward_email.split(",")
    @reward = reward
    @unlocked_prizes = @reward.user_rewards.where(is_redeemed: false).count
    @total_redemeed = @reward.stats
    @total_redemeed_past_week = @reward.get_total_redemeed_past_week
    mail(to: emails, content_type: "text/html", subject: "Weekly Prize Report")
  end
end
