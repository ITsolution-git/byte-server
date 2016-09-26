class Prize < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :status_prize_id, :build_menu_id, :category_id,
    :name, :redeem_value, :level, :role, :is_delete

  attr_accessor :array_prize, :level_delete, :status_name,
                :location_id, :location_logo, :location_cuisine,
                :location_name, :location_lat, :location_long, :byte_prize_type


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :build_menu
  belongs_to :category
  belongs_to :status_prize
  has_many :share_prizes, dependent: :destroy
  has_many :prize_redeems, dependent: :destroy
  has_many :user_prizes, dependent: :destroy
  has_one :item, through: :build_menu


  #############################
  ###  VALIDATIONS
  #############################
  validates :status_prize_id, presence: true, numericality: { only_integer: true } # Required
  validates :build_menu_id, allow_nil: true, numericality: { only_integer: true }
  validates :category_id, allow_nil: true, numericality: { only_integer: true }
  validates :level, presence: true, numericality: { only_integer: true } # Required
  validates :redeem_value, presence: true, numericality: {greater_than: 0} # Required


  #############################
  ###  INSTANCE METHODS
  #############################

  def current_prizes(location_id, points, user_id)
    current_prizes = Prize.get_unlocked_prizes_by_location(location_id, points, user_id)
    current_prizes.delete_if do |i|
      i.type != "owner" || !i.date_time_redeem.nil?
    end
    prizes = Prize.reject_prizes_in_order(current_prizes, location_id, user_id)

    # only show prizes were linked to item or category
    received_prizes = Prize.get_received_prizes(location_id, user_id)
    received_prizes = received_prizes.reject{|p| p.build_menu == nil && p.category == nil}

    if prizes.empty? || prizes.nil?
      received_prizes = Prize.reject_prizes_in_order(received_prizes, location_id, user_id)
      return received_prizes
    end

    first_prize = prizes.first
    is_linked_to_item = false
    if !first_prize.category.nil? || !first_prize.build_menu.nil?
      is_linked_to_item = true
    end

    results = []
    if is_linked_to_item
      results << first_prize
    end

    results = results | received_prizes
    results = Prize.reject_prizes_in_order(results, location_id, user_id)
    # Remove redeemed prizes
    results = results.reject{|p| p.date_time_redeem != nil}
    return results
  end

  def prize_status_name
    return User.get_current_status(location_id, user_id)
  end


  #############################
  ###  CLASS METHODS
  #############################

  def self.get_redeemed_prizes_from_friend_or_restaurant(location_id, user_id)
    sql = "SELECT
              stp.id as status_prize_id,
              pr.share_prize_id as share_prize_id,
              pr.from_redeem as type,
              p.id as prize_id,
              p.name,
              p.level AS level_number,
              p.redeem_value,
              pr.from_user AS from_user,
              u.email as email,
              DATE_FORMAT(CONVERT_TZ(pr.created_at, '+00:00', pr.timezone),
                      '%m/%d/%Y %H:%i:%S') as date_time_redeem,
              DATE_FORMAT(NOW(), '%m/%d/%Y %H:%i:%S') as date_time_current,
              DATE_FORMAT(CONVERT_TZ(NOW(), @@session .time_zone, '+00:00'),
                      '%m/%d/%Y %H:%i:%S') as date_currents,
              DATE_FORMAT(pr.created_at, '%m/%d/%Y %H:%i:%S') as date_redeem,
              p.build_menu_id,
              p.category_id
          FROM
              prizes p
                  JOIN
              status_prizes stp ON stp.id = p.status_prize_id
                  JOIN
              prize_redeems pr ON p.id = pr.prize_id
                  LEFT JOIN
              users u ON u.id = pr.from_user
          WHERE
              p.is_delete = 0 and stp.location_id = #{location_id} and pr.user_id = #{user_id}"
    return Prize.find_by_sql(sql).uniq
  end

  def self.get_redeemed_prizes(location_id, user_id)
    redeem_sql = "SELECT
                      p.id, p.level, sp.id as status_prize_id
                  FROM
                      prizes p
                          JOIN
                      prize_redeems pr ON p.id = pr.prize_id
                          JOIN
                      status_prizes sp ON sp.id = p.status_prize_id
                          JOIN
                      locations l ON l.id = sp.location_id
                  WHERE
                      pr.user_id = ? AND pr.share_prize_id = 0 AND pr.from_user = 0 AND l.id = ? AND p.is_delete = 0 AND p.status_prize_id IS NOT NULL
                  ORDER BY p.status_prize_id"
    redeem_sql_completed = ActiveRecord::Base.send(:sanitize_sql_array, [redeem_sql, user_id, location_id])
    redeemed_prizes = Prize.find_by_sql(redeem_sql_completed)
    return redeemed_prizes.uniq
  end

  def self.get_shared_prizes(location_id, user_id)
    share_sql = "SELECT
                    p.id, p.level, sp.id as status_prize_id
                FROM
                    prizes p
                        JOIN
                    share_prizes shp ON p.id = shp.prize_id
                        JOIN
                    status_prizes sp ON sp.id = p.status_prize_id
                        JOIN
                    locations l ON l.id = sp.location_id
                WHERE
                    shp.from_user = ? AND shp.share_id = 0 AND l.id = ? AND p.is_delete = 0 AND p.status_prize_id IS NOT NULL
                ORDER BY p.status_prize_id"
    shared_sql_completed = ActiveRecord::Base.send(:sanitize_sql_array, [share_sql, user_id, location_id])
    shared_prizes = Prize.find_by_sql(shared_sql_completed)
    return shared_prizes
  end

  def self.get_ordered_prizes(location_id, user_id)
    order_sql = "SELECT
                    p.id, p.level, sp.id as status_prize_id
                FROM
                    order_items oi
                        JOIN
                    orders o ON o.id = oi.order_id AND o.is_paid = 1
                        JOIN
                    prizes p ON p.id = oi.prize_id AND p.is_delete = 0
                        JOIN
                    status_prizes sp ON p.status_prize_id = sp.id
                WHERE
                    o.user_id = ? AND sp.location_id = ? AND oi.share_prize_id = 0
                    AND p.is_delete = 0 AND p.status_prize_id IS NOT NULL
                ORDER BY p.status_prize_id"
    order_sql_completed = ActiveRecord::Base.send(:sanitize_sql_array, [order_sql, user_id, location_id])
    ordered_prizes = Prize.find_by_sql(order_sql_completed)
    return ordered_prizes
  end

  def self.get_unlocked_prizes(location_id, points, prize_ids, status_prize_id)
    unlocked_prizes = []
    total_redemption = 0
    status_prize_id = status_prize_id
    if status_prize_id.nil?
      status_prize_id = StatusPrize.where('location_id = ?', location_id).order('id').first.id
    end
    sql = "SELECT
              stp.id as status_prize_id,
              0 as share_prize_id,
              p.role as type,
              p.id as prize_id,
              p.name,
              p.level as level_number,
              p.redeem_value,
              0 as from_user,
              null as email,
              DATE_FORMAT(NOW(), '%m/%d/%Y %H:%i:%S') as date_time_current,
              DATE_FORMAT(CONVERT_TZ(NOW(), @@session .time_zone, '+00:00'), '%m/%d/%Y %H:%i:%S') as date_currents,
              null as date_redeem,
              null as date_time_redeem,
              p.build_menu_id,
              p.category_id
          FROM
              prizes p
          JOIN
              status_prizes stp ON p.status_prize_id = stp.id
          WHERE
              stp.location_id = ? AND p.is_delete = 0 AND stp.id = ?"
    # In case diner hasn't redeemed, shared or paid any prize, then prize_ids is equal nil
    # Else, prize_ids is an array
    if prize_ids.nil?
      sql = sql + " ORDER BY p.level ASC"
      completed_sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, location_id, status_prize_id])
    else
      sql = sql + " " + "AND p.id in (?)" + " ORDER BY p.level ASC"
      completed_sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, location_id, status_prize_id, prize_ids])
    end

    prizes = Prize.find_by_sql(completed_sql)
    return prizes
  end

  def self.get_used_prizes(location_id, user_id, used_prize_ids)
    sql = "SELECT
              stp.id as status_prize_id,
              pr.share_prize_id as share_prize_id,
              pr.from_redeem as type,
              p.id as prize_id,
              p.name,
              p.level AS level_number,
              p.redeem_value,
              pr.from_user AS from_user,
              u.email as email,
              DATE_FORMAT(CONVERT_TZ(pr.created_at, '+00:00', pr.timezone),
                      '%m/%d/%Y %H:%i:%S') as date_time_redeem,
              DATE_FORMAT(NOW(), '%m/%d/%Y %H:%i:%S') as date_time_current,
              DATE_FORMAT(CONVERT_TZ(NOW(), @@session .time_zone, '+00:00'),
                      '%m/%d/%Y %H:%i:%S') as date_currents,
              DATE_FORMAT(pr.created_at, '%m/%d/%Y %H:%i:%S') as date_redeem,
              p.build_menu_id,
              p.category_id
          FROM
              prizes p
                  JOIN
              status_prizes stp ON stp.id = p.status_prize_id
                  JOIN
              prize_redeems pr ON p.id = pr.prize_id
                  LEFT JOIN
              users u ON u.id = pr.from_user
          WHERE
              p.is_delete = 0 and stp.location_id = ? and pr.user_id = ? and p.id in (?)"
    completed_sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, location_id, user_id, used_prize_ids])
    prizes = Prize.find_by_sql(completed_sql)
    return prizes
  end

  def self.get_received_prizes(location_id, user_id)
    # find prizes what diners received from their friends or restaurant owner
    received_sql = "SELECT
                        stp.id as status_prize_id,
                        sp.id as share_prize_id,
                        sp.from_share as type,
                        p.id as prize_id,
                        p.name,
                        p.level AS level_number,
                        p.redeem_value,
                        sp.from_user AS from_user,
                        u.email as email,
                        null as date_time_redeem,
                        DATE_FORMAT(NOW(), '%m/%d/%Y %H:%i:%S') as date_time_current,
                        DATE_FORMAT(CONVERT_TZ(NOW(), @@session .time_zone, '+00:00'), '%m/%d/%Y %H:%i:%S') as date_currents,
                        null as date_redeem,
                        p.build_menu_id,
                        p.category_id
                    FROM
                        prizes p
                            JOIN
                        status_prizes stp ON stp.id = p.status_prize_id
                            JOIN
                        share_prizes sp ON p.id = sp.prize_id
                            JOIN
                        users u ON u.id = sp.from_user
                    WHERE
                        p.is_delete = 0 AND stp.location_id = ? AND sp.to_user = ? AND is_redeem = 0 AND (sp.is_refunded = 0 OR sp.is_refunded = 1)"
    completed_received_sql = ActiveRecord::Base.send(:sanitize_sql_array, [received_sql, location_id, user_id])
    received_prizes = Prize.find_by_sql(completed_received_sql)
    return received_prizes
  end

  def self.hide_redeemed_prizes_after_three_hours(prizes)
    list_prizes = []
    prizes.each do |prize|
      if prize[:date_redeem].nil?
         list_prizes << prize
      else
        date_current = Time.strptime(prize[:date_currents], '%m/%d/%Y %H:%M:%S').to_s
        date_redeem = Time.strptime(prize[:date_redeem], '%m/%d/%Y %H:%M:%S').to_s
        date_time = (Time.parse(date_current) - Time.parse(date_redeem))/3600
        if date_time <= 3
          list_prizes << prize
        else
          # If there is a SharePrize with the given Prize id, mark it as limited
          share_prize = SharePrize.find_by_prize_id(prize.id)
          share_prize.update_attributes(is_limited: 1) unless share_prize.blank?
        end
      end
    end
    return list_prizes
  end

  def self.get_unlocked_prizes_by_location(location_id, points, user_id)
    results = []
    total_redemption = 0
    restauratn_prizes = Prize.joins(:status_prize).where('status_prizes.location_id = ?', location_id).select("prizes.id")
    unless restauratn_prizes.empty?
      redeemed_prizes = get_redeemed_prizes(location_id, user_id)
      shared_prizes = get_shared_prizes(location_id, user_id)
      ordered_prizes = get_ordered_prizes(location_id, user_id)

      used_prizes = redeemed_prizes | shared_prizes | ordered_prizes
      max_used_prize = used_prizes.sort_by{|p| [p.status_prize_id, p.level]}.last

      # In case diners haven't yet ordered/shared/redeemed any prize, base on total point of them to determine current prizes
      if max_used_prize.nil? || used_prizes.empty?
        # get unlocked prizes base on total point of diner
        prizes = get_unlocked_prizes(location_id, points, nil, nil)
        unlocked_prizes = []
        prizes.each do |i|
          total_redemption = total_redemption + i.redeem_value
          if total_redemption <= points
            unlocked_prizes << i
          end
        end
        results = unlocked_prizes
      else # diners have used prizes by sharing or ordering or redeeming
        redeemed_prize_ids = []
        shared_prize_ids = []
        ordered_prize_ids = []
        redeemed_prizes.each do |redeemed_prize|
          redeemed_prize_ids << redeemed_prize.id
        end
        shared_prizes.each do |shared_prize|
          shared_prize_ids << shared_prize.id
        end
        ordered_prizes.each do |ordered_prize|
          ordered_prize_ids << ordered_prize.id
        end
        used_prize_ids = redeemed_prize_ids | shared_prize_ids | ordered_prize_ids

        prizes_by_status = Prize.where('status_prize_id = ?', max_used_prize.status_prize_id).select('id')
        # reject prizes were used to get unlocked prizes
        prizes_by_status = prizes_by_status.reject{|p| used_prize_ids.include?(p.id)}
        unlocked_prizes = get_unlocked_prizes(location_id, points, prizes_by_status, max_used_prize.status_prize_id)

        all_redeemed_prizes = get_used_prizes(location_id, user_id, redeemed_prize_ids)
        prizes = unlocked_prizes | all_redeemed_prizes
        is_redeemed_all_prizes = true
        prizes.each do |i|
          if i.date_time_redeem != "null" && i.date_time_redeem.nil?
            is_redeemed_all_prizes = false
            break
          end
        end
        # if diner redeemed all prizes at current status, go to next status and get all prizes will be unlocked
        if is_redeemed_all_prizes == true
          new_unlocked_prizes = []
          if (max_used_prize.status_prize_id + 1) <= StatusPrize.where('location_id = ?', location_id).maximum('id')
            new_prizes = get_unlocked_prizes(location_id, points, nil, max_used_prize.status_prize_id + 1)
            new_prizes.each do |i|
              total_redemption = total_redemption + i.redeem_value
              if total_redemption <= points
                new_unlocked_prizes << i
              end
            end
          end
          results = prizes | new_unlocked_prizes
        else
          list_prizes_unlocked = []
          prizes.each do |i|
            total_redemption = total_redemption + i.redeem_value
            if total_redemption <= points
              list_prizes_unlocked << i
            end
          end
          results = list_prizes_unlocked
        end
      end
    end
    return results
  end

  def self.save_user_prize(location, user, prize)
    user_prizes_from_location = UserPrize.where(user_id: user.id, prize_id: prize.id, location_id: location.id)
    if user_prizes_from_location.empty?
      UserMailer.send_mail_unlock_prize(location.name, user.email, prize.name).deliver
      UserPrize.create({
        :location_id => location.id,
        :is_sent_notification => 1,
        :prize_id => prize.id,
        :user_id => user.id,
      })
      message = "Congratulations you've unlocked #{prize.name} prize. Please go to MyPrize to Redeem your prize! Can't wait to see you at #{location.name}."
      noti = Notifications.new
      noti.from_user = location.owner_id
      noti.to_user = user.email
      noti.message = message
      noti.msg_type = "single"
      noti.location_id = location.id
      noti.alert_type = PRIZE_ALERT_TYPE
      noti.alert_logo = POINT_LOGO
      noti.msg_subject= PRIZE_ALERT_TYPE
      noti.points = prize.redeem_value
      noti.save!
    end
  end

  # 2015-04-23 Dan@Cabforward.com: A grep analysis indicates this method is no longer in use
  # def self.check_unlock_prize

  #   sql = "SELECT location.*
  #         FROM locations AS location
  #         JOIN status_prizes sp ON location.id = sp.location_id
  #         JOIN prizes p ON p.status_prize_id = sp.id
  #         WHERE location.active = 1"
  #   locations = Location.find_by_sql(sql)
  #   locations = locations.uniq{|x| x.id}
  #   users = User.where('is_register = ? and role = ?', 0, USER_ROLE)

  #   users.each do |u|
  #     locations.each do |l|
  #       # get total points of user at a restaurant
  #       sql = "
  #         SELECT
  #           l.id,
  #           IFNULL(SUM(CASE WHEN u.is_give = 1 THEN u.points ELSE u.points * (- 1) END), 0) AS total
  #         FROM locations AS l
  #         JOIN user_points AS u ON l.id = u.location_id
  #         WHERE
  #           u.user_id = ?
  #           AND u.location_id = ?"
  #       completed_sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, u.id, l.id])
  #       user_point = Location.find_by_sql(completed_sql).first.total
  #       user_prizes = UserPrize.where(user_id: u.id, location_id: l.id)
  #       location_status = l.status_prizes.order(:id)
  #       unless location_status.empty?
  #         # if user hasn't had any prize
  #         if user_prizes.empty?
  #           first_status = location_status.first
  #           first_status_prizes = first_status.prizes.where('status_prize_id is not null and is_delete = 0')
  #           unlock_prizes = []
  #           total_redeem_value = 0
  #           first_status_prizes.each do |i|
  #             total_redeem_value = total_redeem_value + i.redeem_value
  #             if total_redeem_value <= user_point
  #               unlock_prizes << i
  #             end
  #           end
  #           unlock_prizes.each do |i|
  #             save_user_prize(l, u, i)
  #           end
  #         else
  #           last_status_prize = user_prizes.last.status_prize
  #           current_user_prizes_ids = UserPrize.where(user_id: u.id, location_id: l.id, prize_id: prize.id).pluck(:prize_id)



  #           # compare with user point and list out prize they can unlock
  #           current_status_prizes = last_status_prize.prizes.where('id not in (?) and is_delete = 0 and status_prize_id is not null', current_user_prizes_ids)

  #           # Build a list of items that the User can redeem
  #           total_redeem_value = 0
  #           unlockable_prize_ids = []
  #           current_status_prizes.each do |i|
  #             total_redeem_value = total_redeem_value + i.redeem_value
  #             if total_redeem_value <= user_point
  #               unlockable_prize_ids << i
  #             end
  #           end


  #           unlockable_prize_ids.each do |i|
  #             save_user_prize(l, u, i)
  #           end
  #         end
  #       else
  #         next
  #       end
  #     end
  #   end
  # end

  def self.reject_prizes_in_order(current_prizes, location_id, user_id)
    prizes = current_prizes
    prize_order_sql = "SELECT prize_id, share_prize_id FROM order_items oi
            JOIN orders o on o.id = oi.order_id
            JOIN locations l on l.id = o.location_id
            WHERE o.location_id = #{location_id} AND oi.prize_id IS NOT NULL
              AND oi.share_prize_id IS NOT NULL AND oi.is_prize_item = 1
              AND o.user_id = #{user_id}"
    prizes_in_order = OrderItem.find_by_sql(prize_order_sql)
    prizes_in_order.each do |po|
      prizes.delete_if do |j|
        j.share_prize_id == po.share_prize_id && j.prize_id == po.prize_id
      end
    end
    return prizes
  end

  # BEGIN WEB SERVER functions----------------------------------------------------------

  def self.delete_orders_belong_to_prize(location_id, prize_ids)
    orders = Order.where('location_id = ? and is_paid != 1 and is_cancel != 1', location_id)
    orders.each do |o|
      o.order_items.where('prize_id in (?)', prize_ids).destroy_all
    end
  end

  # END WEB SERVER functions------------------------------------------------------------
end
