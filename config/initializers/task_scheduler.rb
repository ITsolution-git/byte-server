# -*- coding: utf-8 -*-

unless defined?(IRB)
  require 'rubygems'
  require 'rufus/scheduler'

  scheduler = Rufus::Scheduler.start_new

  scheduler.every '1m' do
    menus_approved = Menu.where('publish_start_date != ? AND repeat_time != ? AND repeat_time_to != ? AND publish_status = ?', "", "", "", 1)
    today = Time.now.utc.strftime("%Y-%m-%d %H:%M")
    today_time = Time.now.utc.strftime("%H:%M")
    dayname =Time.now.utc.wday
    menus_approved.each do |menu|
      repeat_on = menu.repeat_on.to_s
      start_date = menu.publish_start_date.strftime("%Y-%m-%d %H:%M")
      start_time = menu.repeat_time
      if start_date == today || (repeat_on.include?(dayname.to_s) && start_time == today_time)
        menu.publish_status = 2
        menu.published_date = today
        menu.save(:validate => false)
      end
    end
  end

  scheduler.every '30m', :timeout => '30m' do # Etc/GMT+0
    begin
      Order.run_order_cleaning()
    rescue
      puts "Time out!"
    end
  end

  scheduler.every '5m' do
    # UserMailer.send_notification().deliver
    Prize.check_unlock_prize
  end

  scheduler.every '1m' do
    Notifications.run_refunded_point()
  end

  scheduler.every '1m' do
    SharePrize.refund_prizes
  end

  # Friendship request reminders
  scheduler.every '1d' do
    Friendship.all_needing_reminders.each do |friendship_request|
      # Send a reminder-style notification (rather than the standard notification)
      friendship_request.send_push_notification_to_recipient(true)
    end
  end

  scheduler.every '3d' do
    ServerAvatar.destroy_all(['updated_at < ? AND server_id is ?', 3.days.ago, nil])
    LocationLogo.destroy_all(['updated_at < ? AND location_id is ?', 3.days.ago, nil])
    LocationImage.destroy_all(['updated_at < ? AND location_id is ?', 3.days.ago, nil])
    ItemKeyImage.destroy_all(['updated_at < ? AND item_key_id is ?', 3.days.ago, nil])
    ItemImage.destroy_all(['updated_at < ? AND item_id is ?', 3.days.ago, nil])
    InfoAvatar.destroy_all(['updated_at < ? AND info_id is ?', 3.days.ago, nil])
  end

  # scheduler.every '1m' do
    # Prize.send_unlock_prize_to_user
  # end

end

