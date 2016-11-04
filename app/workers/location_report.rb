class LocationReport
  include Sidekiq::Worker
  sidekiq_options retry: false


  def perform(location_id)
    restaurant = Location.find(location_id)
    @menu_items = restaurant.items
    @prizes = Prize.where(status_prize_id: restaurant.status_prizes.pluck(:id))
    @checkins = restaurant.checkins.includes(:user)
    @socials = restaurant.social_shares
    @item_ids = restaurant.items.pluck(:id)
    @prize_ids = @prizes.pluck(:id)
    @comments = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids})

    @new_ids = @checkins.select('min(id)').group(:user_id)
    @new_customers = @checkins.where(id: @new_ids)
    @returning_customers = @checkins.where("id NOT IN (?)", @new_ids.pluck(:id))

    period = 1
    @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_comments.created_at', range: period.weeks.ago..(period-1).weeks.ago).count
    @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_favourites.created_at', range: period.weeks.ago..(period-1).weeks.ago).count
    @order_count = OrderItem.where(item_id: @item_ids).group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
    @social_count = @socials.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
    @new_customer_count = @new_customers.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
    @returning_customer_count = @returning_customers.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
    @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
    @feedback_rating = @comments.group_by_day('item_comments.created_at', range: period.weeks.ago..(period-1).weeks.ago).group(:rating).count

    @feedback_rating_sum = 0
    @feedback_rating_count = 0
    @feedback_rating.each do |(date, rating), count|
      @feedback_rating_sum += rating * count
      @feedback_rating_count += count
    end

    @feedback_rating_str="A+"
    if @feedback_rating_count > 0
      @feedback_rating = (@feedback_rating_sum / @feedback_rating_count).floor
      case @feedback_rating
      when 1.0
        @feedback_rating_str = "A+"
      when 2.0
        @feedback_rating_str = "A"
      when 3.0
        @feedback_rating_str = "A-"
      when 4.0
        @feedback_rating_str = "B+"
      when 5.0
        @feedback_rating_str = "B"
      when 6.0
        @feedback_rating_str = "B-"
      when 7.0
        @feedback_rating_str = "C+"
      when 8.0
        @feedback_rating_str = "C"
      when 9.0
        @feedback_rating_str = "C-"
      when 10.0
        @feedback_rating_str = "D+"
      when 11.0
        @feedback_rating_str = "D"
      when 12.0
        @feedback_rating_str = "D-"
      when 13.0
        @feedback_rating_str = "F"
      else
        @feedback_rating_str = " "
      end
    end

    @week = {
      :feedback_count => @feedback_count.map { |k, v| v }.sum,
      :favourite_count => @favourite_count.map { |k, v| v }.sum,
      :order_count => @order_count.map { |k, v| v }.sum,
      :social_count => @social_count.map { |k, v| v }.sum,
      :new_customer_count => @new_customer_count.map { |k, v| v }.sum,
      :returning_customer_count => @returning_customer_count.map { |k, v| v }.sum,
      :redeemed_prize_count => @redeemed_prize_count.map { |k, v| v }.sum,
      :feedback_rating => @feedback_rating_str
    }

    @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_week('item_comments.created_at', range: period.years.ago..(period-1).years.ago).count
    @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_week('item_favourites.created_at', range: period.years.ago..(period-1).years.ago).count
    @order_count = OrderItem.where(item_id: @item_ids).group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
    @social_count = @socials.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
    @new_customer_count = @new_customers.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
    @returning_customer_count = @returning_customers.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
    @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count

    @year = {
      :feedback_count => @feedback_count.map { |k, v| v }.sum,
      :favourite_count => @favourite_count.map { |k, v| v }.sum,
      :order_count => @order_count.map { |k, v| v }.sum,
      :social_count => @social_count.map { |k, v| v }.sum,
      :new_customer_count => @new_customer_count.map { |k, v| v }.sum,
      :returning_customer_count => @returning_customer_count.map { |k, v| v }.sum,
      :redeemed_prize_count => @redeemed_prize_count.map { |k, v| v }.sum
    }

    UserMailer.send_email_weekly_report(restaurant.weekly_progress_email, restaurant, @week, @year).deliver
  end
end
