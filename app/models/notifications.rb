class Notifications < ActiveRecord::Base
  # This class would probably be better named as "EmailNotification".

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :from_user, :to_user, :message, :msg_type, :location_id, :alert_logo,
                  :alert_type, :item_id, :points, :status, :msg_subject, :reply, :received,
                  :menu_rating, :product_comment, :hide_status, :hide_notification, :group_emails,
                  :is_show, :is_show_detail, :item_comment_id, :is_openms, :is_delete_to_user,
                  :is_delete_from_user, :is_delete_by_admin, :is_hide_reward_by_admin, 
                  :point_prize


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :location
  belongs_to :sender, class_name: 'User', foreign_key: 'from_user'


  #############################
  ###  SCOPES
  #############################
  %w(rsr_admin rsr_manager).each do |field|
    scope "where_by_#{field}", ->(user_id) {
      joins(:location).where("locations.#{field} LIKE ?
      OR locations.#{field} LIKE ? OR locations.#{field} LIKE ?",
                             "#{user_id},%", "%,#{user_id},%", "%,#{user_id},")
    }
  end
  scope :not_sharing_points, -> { where('alert_type != ?', SHARING_POINTS) }
  scope :not_friend_request, -> { where('alert_type != ?', FRIEND_REQUEST) }
  scope :rating_alert, -> { where('alert_type = ?', RATING_ALERT_TYPE) }
  scope :sharing_points, -> { where('alert_type = ?', SHARING_POINTS) }
  scope :msg_group, -> { where('msg_type = ?', 'group') }
  scope :get_msg_between_users, -> (from, to) { where('from_user = ? AND to_user = ?', from, to) }
  scope :group_notifications, -> {
    group('from_user, alert_type, message, msg_type, points, item_id, status,
      notifications.created_at')
  }
  scope :all_notification_by_user, ->(email, user_id) { where('to_user = ? OR from_user = ?', email, user_id) }
  # scope :hide_notification, -> {where('hide_status = ?', 1)}
  # scope :search_with_params, ->(params, date_converted) {where('alert_type LIKE ? OR created_at LIKE ?
  #           OR strftime("%Y", created_at) = ? OR strftime("%m", created_at) = ? OR strftime("%d", created_at) = ?',
  #           "%#{params}%", "%#{date_converted}", params, params, params)}
  # scope :group_points_notifications, -> {group('from_user, alert_type, message, msg_type, points, item_id, status, created_at')}


  #############################
  ###  METHODS
  #############################
  def self.hide_notification(is_my_rewards_page)
    if is_my_rewards_page
      return Notifications.where('is_hide_reward_by_admin = ?', 1)
    else
      return Notifications.where('hide_status = ?', 1)
    end
  end

  def self.get_notifications_by_location(location_ids)
    manager_ids = []
    manager_emails = []
    all_emails = []
    locations = []
    inactive_locations = [0]
    unless location_ids.empty?
      locations = Location.where('id IN (?)', location_ids)
      manager_ids = locations.pluck(:rsr_manager).map { |x| x.strip.to_i }
      users = User.where('id IN (?)', manager_ids)
      users.each do |user|
        manager_emails << user.email
        all_emails << user.email
      end
    end
    admin = User.find(1) # TODO: What the heck is this?  Get rid of it!
    owner = User.find(locations[0].owner_id)

    all_emails << owner.email
    manager_ids << owner.id
    inactive_location = Location.unscoped.where('owner_id = ? AND active = ?', owner.id, false)
    unless inactive_location.empty?
      inactive_location.each do |location|
        inactive_locations << location.id
      end
    end
    manager_ids << admin.id

    Notifications.where("location_id NOT IN (?) AND (to_user IN (?) AND location_id IN (?) OR (location_id IN (?)
      AND from_user IN (?)) OR (to_user = ? AND location_id IN (?)) OR (to_user = ? AND location_id IN (?) ))",
                        inactive_locations, manager_emails, location_ids, location_ids, manager_ids, owner.email, location_ids, admin.email, location_ids)
  end

  def self.get_notifications_undeleted(user, location_ids, is_mycommunication)
    rsr_manager_ids = []
    all_ids = []
    rsr_manager_emails = []
    all_emails = []

    owner_ids = []
    owner_emails = []

    unless location_ids.empty?
      locations = Location.find(location_ids)
      locations.each do |l|
        unless l.rsr_manager.nil?
          rsr_manager_ids += l.rsr_manager.strip.split(',').map { |x| x.strip }
          all_ids += l.rsr_manager.strip.split(',').map { |x| x.strip }
          # add
          owner_ids << l.owner_id
          owner = User.find(l.owner_id)
          unless owner.nil?
            owner_emails << owner.email
          end
          # end
          manager = User.find_by_id(l.rsr_manager)
          unless manager.nil?
            rsr_manager_emails << manager.email
            all_emails.push << manager.email
          end
        end
      end
    end
    if user.nil?
      return where('is_delete_to_user != ? AND is_delete_from_user != ?', 1, 1)
    end
    if user.restaurant_manager?
      owner_manager_ids = []
      owner_manager_ids << user.id
      owner_manager_ids << user.parent_user.id
      owner_manager_emails = []
      owner_manager_emails << user.email
      owner_manager_emails << user.parent_user.email

      return where('(to_user NOT IN (?) AND is_delete_from_user = ?)
          OR (from_user NOT IN (?) AND is_delete_to_user = ?)
          OR (from_user IN (?) AND to_user IN (?)
          AND is_delete_to_user = ? AND is_delete_from_user = ?)',
                   owner_manager_emails, 0, owner_manager_ids, 0, owner_manager_ids, owner_manager_emails, 0, 0)
    elsif user.owner?
      owner_managers_ids = []
      owner_managers_ids += rsr_manager_ids
      owner_managers_ids << user.id
      owner_managers_emails = []
      owner_managers_emails += rsr_manager_emails
      owner_managers_emails << user.email
      if is_mycommunication
        return where('location_id IN (?) AND is_delete_by_admin = ?', location_ids, 0)
      else
        return where('(to_user NOT IN (?) AND is_delete_from_user = ?)
          OR (from_user NOT IN (?) AND is_delete_to_user = ?)
          OR ( from_user IN (?) AND  to_user IN (?)
          AND is_delete_to_user = ? AND is_delete_from_user = ?)',
                     owner_managers_emails, 0, owner_managers_ids, 0, owner_managers_ids, owner_managers_emails, 0, 0)
      end
    elsif user.admin? # if user is admin
      admin_manager_ids = []
      admin_manager_ids += rsr_manager_ids
      admin_manager_ids += owner_ids
      admin_manager_ids << user.id

      admin_manager_emails = []
      admin_manager_emails += rsr_manager_emails
      admin_manager_emails += owner_emails
      admin_manager_emails << user.email
      if is_mycommunication
        return where('location_id IN (?) AND is_delete_by_admin = ?', location_ids, 0)
      else
        return where('(to_user NOT IN (?) AND is_delete_from_user = ?)
          OR (from_user NOT IN (?) AND is_delete_to_user = ?)
          OR ( from_user IN (?) AND  to_user IN (?)
          AND is_delete_to_user = ? AND is_delete_from_user = ?)',
                     admin_manager_emails, 0, admin_manager_ids, 0, admin_manager_ids, admin_manager_emails, 0, 0)
      end
    end
  end

  def sent?(current_user, location)
    sub_user_ids = []
    user_id = sender.id
    user_amdin = User.find(user_id)
    if location != 0
      current_location = Location.find(location)
      location_owner = current_location.owner_id
      array_manager = current_location.rsr_manager.split(',')
      location_manager = array_manager[0].to_i
    end
    # unless user_amdin.nil?
    #   user_role = user_amdin.admin?
    # end
    if current_user.restaurant_manager?
      return current_user.id === user_id || user_id === current_user.parent_user.id || user_amdin.admin?
    elsif current_user.owner?
      sub_users = current_user.sub_users
      unless sub_users.empty?
        sub_users.each do |user|
          sub_user_ids.push(user.id)
        end
      end
      return current_user.id === user_id || sub_user_ids.include?(user_id) || user_amdin.admin?
    end
    if current_user.admin? && location != 0
      return current_user.id === user_id || user_id == location_owner || user_id == location_manager
    end
  end

  def received?(current_user, location)
    sub_user_emails = []
    user_admin = User.find_by_email(to_user)
    if location != 0
      current_location = Location.find(location)
      location_owner = current_location.owner_id
      array_manager = current_location.rsr_manager.split(',')
      location_manager = array_manager[0].to_i
    end
    if current_user.restaurant_manager?
      return current_user.email === to_user || to_user === current_user.parent_user.email || user_admin.admin?
    elsif current_user.owner?
      sub_users = current_user.sub_users
      unless sub_users.empty?
        sub_users.each do |user|
          sub_user_emails.push(user.email)
        end
      end
      return current_user.email === to_user || sub_user_emails.include?(to_user) || user_admin.admin?
    end
    if current_user.admin? && location != 0
      return current_user.id === user_admin.id || user_admin.id == location_owner ||  user_admin.id == location_manager
    end
  end

  def date
    created_at.strftime('%d %b %Y')
  end

  def get_avatar_message
    u = User.where("id = ?", self.user_id).first
    if (self.alert_type == DIRECT_ALERT_TYPE ||
      self.alert_type == RATING_ALERT_TYPE ||
      self.alert_type == POINTS_ALERT_TYPE ||
      self.alert_type == GENERAL_ALERT_TYPE) && u.role == 'owner'
      location = Location.find_by_id(self.location_id)
      user = User.find_by_id(location.owner_id)
      unless user.nil?
        if user.avatar.present? && user.avatar.path.present?
           return user.avatar.url({format: :primary})
        else
           return nil
        end
      end
    else
      unless u.nil?
        if u.role == 'user'
          return u.avatar.url unless u.avatar.nil?
        else
          return nil
        end
      end
      return nil
    end
  end

  def self.search_with_params(params, user = nil, location_ids, is_mycommunication)
    d = DateTime.parse(params) rescue nil
    date_converted = params
    date_converted = DateTime.parse(params).strftime('%Y-%m-%d') if d

    conditions = ''
    user_ids = User.where('username LIKE ?', "%#{params}%").map { |x| x.id }
    unless user_ids.empty?
      conditions += "OR from_user IN (#{user_ids.join(',')})"
    end
    get_notifications_undeleted(user, location_ids, is_mycommunication).where('alert_type LIKE ? OR notifications.created_at LIKE ?
        OR DATE_FORMAT(notifications.created_at,"%Y") = ?
        OR DATE_FORMAT(notifications.created_at,"%m") = ?
        OR DATE_FORMAT(notifications.created_at,"%d") = ?' \
        + conditions, "%#{params}%", "%#{date_converted}%", params, params, params)
  end

  def self.search_notification(search, user_id)
    where('alert_type LIKE :search or message LIKE :search and to_user LIKE :user_id',
          search: "%#{search}%", user_id: "%#{user_id}%")
  end

  def self.get_rating_notifications(user, location_ids)
    result = rating_alert
    unless location_ids.empty?
      result = result.get_notifications_by_location(location_ids)
    end

    unless user.admin?
      if user.restaurant_admin?
        result = result.where_by_rsr_admin(user.id)
      elsif user.restaurant_manager?
        result = result.where_by_rsr_manager(user.id)
      end
    end

    # remove rating reward notification from owner or managers
    unless result.empty?
      result.each do |notification|
        unless notification.location_id == 0
          current_location = Location.find(notification.location_id)
        else
          role = 'admin'
          user_amdin = User.find_by_role(role)
          id = user_amdin.id
          current_location = Location.find_by_owner_id(id)
        end

        manager_ids = []
        unless current_location.nil?
          owner = User.find(current_location.owner_id)
          owner_id = owner.id

          managers = owner.sub_users
          unless managers.empty?
            managers.each do |manager|
              manager_ids.push(manager.id)
            end
          end
        end
        result.reject! { |noti| noti.from_user == owner_id || manager_ids.include?(noti.from_user) }
      end
    end
    result
  end

  def self.search_user_notifications(user, location_ids, _real_email, _real_user_id, params, is_mycommunication)
    unless location_ids.empty?
      result = get_notifications_by_location(location_ids)
    end
    if user.admin?
      result = result.not_sharing_points.not_friend_request.search_with_params(params, user, location_ids, is_mycommunication)
    else
      result = result.not_sharing_points.not_friend_request.search_with_params(params, user, location_ids, is_mycommunication)
      if user.restaurant_admin?
        result = result.where_by_rsr_admin(user.id)
      elsif user.restaurant_manager?
        # result = result.where_by_rsr_manager(user.id)
      end
    end
    result.group_notifications.order('notifications.created_at DESC')
  end

  def self.get_user_notifications(user, location_ids, _real_email, _real_user_id, is_mycommunication)
    result = []
    if user.admin?
      result = not_sharing_points.not_friend_request
      result = result.get_notifications_by_location(location_ids) if location_ids.present?
    else
      result = not_sharing_points.not_friend_request.get_notifications_by_location(location_ids)
      result = result.where_by_rsr_admin(user.id) if user.restaurant_admin?
    end
    if result.present?
      result.get_notifications_undeleted(user, location_ids, is_mycommunication)
        .group_notifications.order('notifications.created_at DESC')
    else
     result
    end
  end

  def self.refunded_point_msg(sharer, points, receiver)
    "Hi #{sharer}, You've shared #{points.to_i} points to #{receiver}, but they didn't accept, so the points are refunded back to your account. Thanks."
  end

  def self.get_list_notification
    sql = "select n.id,n.from_user,n.to_user,n.location_id,n.points,n.status,n.created_at,n.updated_at,l.timezone
         from notifications n
         join locations l on l.id = n.location_id
         where n.received = 0 and n.status = 0 and n.is_openms = 0 and n.points > 0 and n.alert_type = 'Sharing Points'"
    find_by_sql(sql)
  end
  
  def self.run_refunded_point
    refunded_points = get_list_notification
    unless refunded_points.empty?
      refunded_points.each do |refunded_point|
        @from_user = User.find(refunded_point.from_user)
        @to_user = User.find_by_email(refunded_point.to_user)
        if @to_user.is_register != 0
          unless refunded_point.timezone.nil?
            notification_date = (refunded_point.created_at + 10.minutes).in_time_zone("#{refunded_point.timezone}")
            time_now = DateTime.now.in_time_zone("#{refunded_point.timezone}")
            date_compare = (Time.parse(time_now.to_s) - Time.parse(notification_date.to_s)) / (3600 * 24)
            if date_compare > 0
              # refunded_point.update_attribute(:is_openms,1)
              @from_user = User.find(refunded_point.from_user)
              @to_user = User.find_by_email(refunded_point.to_user)
              @from_user.add_points_user(refunded_point.points)
              # Add new userpoint
              UserPoint.create(
                user_id: @from_user.id,
                point_type: 'Points Refunded',
                location_id: refunded_point.location_id,
                points: refunded_point.points,
                status: 1,
                is_give: 1
              )

              # Received points
              #Remove UserPoint
              user_points = UserPoint.where("user_id = ? and location_id = ? and point_type = ? and is_give =? ",@to_user.id,refunded_point.location_id,RECEIVED_POINT_TYPE,1).first
              unless user_points.nil?
                user_points.destroy
              end
              @notification = Notifications.new
              @notification.from_user = User.find_by_role('admin').id
              @notification.to_user = @from_user.email
              if @to_user.last_name.nil?
                @notification.message = "Hi #{@from_user.username}, You've shared #{refunded_point.points.to_i} points to #{@to_user.email}, but they didn't accept, so the points are refunded back to your account. Thanks."
              else
                receive = @to_user.first_name + ' ' + @to_user.last_name
                @notification.message = "Hi #{@from_user.username}, You've shared #{refunded_point.points.to_i} points to #{receive}, but they didn't accept, so the points are refunded back to your account. Thanks."
              end
              @notification.msg_type = "group"
              @notification.location_id = refunded_point.location_id
              @notification.alert_type = SHARING_POINTS
              @notification.alert_logo = POINT_LOGO
              @notification.msg_subject = POINTS_MESSAGE
              @notification.received = 1
              @notification.points = refunded_point.points
              @notification.save
              @check_registers = Friendship.where('friend_id = ?', @to_user.id)

              unless @check_registers.empty?
                @check_registers.each do |check_register|
                  if check_register.pending == 0 && @to_user.is_register != 0
                    # check_register.destroy
                    @to_user.skip_reconfirmation!
                    @to_user.update_attribute(:is_register, 2)
                    puts 'Pass qua day'
                  end
                end
              end
              refunded_point.destroy
            end # end date_compare
          end
        end
      end # end refunded_point for each
    end # end refunded_points empty
  end

  # Get message by location
  def self.get_message_location(location_id, email)
    sql = "SELECT n.id,n.alert_logo, n.alert_type, n.msg_subject, n.message,n.status, n.location_id,
             DATE_FORMAT(n.updated_at, '%m.%d.%Y') as update_day,
             DATE_FORMAT(n.updated_at, '%H.%i.%S') as update_time,
             DATE_FORMAT(n.created_at, '%m.%d.%Y') as create_day,
             DATE_FORMAT(n.created_at, '%H.%i.%S') as create_time
         FROM notifications n
         WHERE n.alert_type != 'Publish Menu Notification'
         AND n.location_id = #{location_id} AND n.to_user='#{email}' AND n.is_show=1
         ORDER BY  status, create_day desc, create_time desc"
    find_by_sql(sql)
  end

  # Get detail message
  def self.get_detail_message(message_id)
    sql = "SELECT n.id as msg_id,n.location_id, n.alert_type, n.alert_logo, n.msg_type, n.msg_subject,n.message,
                 u.id as user_id,u.username, n.from_user, u.avatar,
                 DATE_FORMAT(n.updated_at, '%m-%d-%Y %H:%i:%S') as update_time,
                 DATE_FORMAT(n.created_at, '%m-%d-%Y %H:%i:%S') as create_time, n.points, n.received, n.reply
          FROM notifications n
          JOIN users u ON u.id = n.from_user
          WHERE n.alert_type != 'Publish Menu Notification' AND n.is_show_detail=1
          AND (n.id=#{message_id} OR n.reply=#{message_id})
          ORDER BY n.id ASC"
    find_by_sql(sql)
  end

  # Get unread message by chain
  def self.get_unread_message_by_chain(chain_name, email)
    sql = "SELECT l.id as location_id, n.id, n.message, n.msg_type, n.msg_subject, n.alert_logo, n.alert_type,
          DATE_FORMAT(n.updated_at, '%m.%d.%Y') as update_day,
          DATE_FORMAT(n.updated_at, '%H.%i.%S') as update_time
        FROM notifications n
        JOIN locations l ON l.id = n.location_id
        WHERE n.alert_type !='Publish Menu Notification'
        AND n.status=0 AND n.is_show=1
        AND l.chain_name='#{chain_name}' AND n.to_user='#{email}'
        ORDER BY update_day DESC, update_time DESC"
    find_by_sql(sql)
  end

  def self.get_total_unread_message_by_my_friend(email)
    sql1 = "SELECT 'Friend Requests' as name, COUNT(*) as total
          FROM notifications n
          WHERE to_user = '#{email}' AND alert_type !='Publish Menu Notification'
          AND alert_type ='Friend Requests'"
    friend = find_by_sql(sql1)
    sql2 = "SELECT 'Restaurants' as name, COUNT(*) as total
          FROM notifications n
          JOIN locations l on l.id = n.location_id
          WHERE to_user = '#{email}' AND alert_type !='Publish Menu Notification' AND alert_type !='Friend Requests'
          AND n.status = 0 AND n.is_show=1"
    restaurant = find_by_sql(sql2)
    friend.concat(restaurant)
  end
  def self.get_list_invitation(email)
    sql = "select  p.id as msg_id, u.id as user_id, u.username,u.first_name,u.last_name,p.message,p.location_id,u.avatar,p.status as unread, DATE_FORMAT(p.updated_at, '%m.%d.%Y') as request_day,
          DATE_FORMAT(p.updated_at, '%H.%i.%S') as request_time, p.alert_type
          from notifications p
          join users u on   u.id =  p.from_user
          where  p.to_user =  '#{email}' and  p.alert_type = 'Friend Requests'"
    find_by_sql(sql)
  end
  
end
