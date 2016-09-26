class GroupUser < ActiveRecord::Base
  attr_accessible :group_id, :user_id
  belongs_to :group

  def self.get_all_list_customers(location_id_arr, current_user)
    sql1 = "SELECT distinct(user_id) as id FROM
    item_comments where build_menu_id IN(SELECT id
    FROM build_menus WHERE item_id IN (SELECT id from items where location_id IN (#{location_id_arr})))"
    user_comments = self.find_by_sql(sql1)
  
    sql2 = "SELECT distinct(user_id) as id FROM item_favourites
    where favourite = 1 AND build_menu_id IN(SELECT id FROM build_menus WHERE item_id IN
    (SELECT id from items where location_id IN (#{location_id_arr})))"
    user_favorites = self.find_by_sql(sql2)

    sql3= "SELECT distinct(user_id) as id FROM location_comments WHERE location_id IN (#{location_id_arr})"
    user_comment_locations = self.find_by_sql(sql3)

    sql4= "SELECT distinct(user_id) as id  FROM location_favourites WHERE location_id IN (#{location_id_arr})"
    user_fav_locations = self.find_by_sql(sql4)

    sql5="SELECT distinct(user_id) as id  FROM orders WHERE location_id IN (#{location_id_arr})"
    user_orders = self.find_by_sql(sql5)

    sql6= "SELECT distinct(user_id) as id FROM social_shares WHERE location_id IN (#{location_id_arr})"
    user_shares = self.find_by_sql(sql6)

    sql7 = "SELECT distinct(s.from_user) as id FROM
    share_prizes s where s.prize_id IN(SELECT p.id
    FROM prizes p
    JOIN status_prizes sp
    ON  sp.id = p.status_prize_id WHERE sp.location_id IN (#{location_id_arr}))"
    user_shares_prize = self.find_by_sql(sql7)

    sql8 = "SELECT distinct(s.to_user) as id FROM
    share_prizes s where s.prize_id IN(SELECT p.id
    FROM prizes p
    JOIN status_prizes sp
    ON  sp.id = p.status_prize_id WHERE sp.location_id IN (#{location_id_arr})
    AND  s.status = 1)"
    user_receive_prize = self.find_by_sql(sql8)

    sql9 = "SELECT distinct(u.id) as id FROM users u
    join notifications n on u.email =n.to_user
    where n.location_id IN (#{location_id_arr}) AND (n.alert_type = 'Rating Reward'
    or n.alert_type = 'Points Message' or n.alert_type ='Sharing Points')
    AND n.points > 0"
    user_receive_point = self.find_by_sql(sql9)
    
    sql10= "SELECT distinct(user_id) as id FROM checkins WHERE location_id IN (#{location_id_arr})"
    user_checkins = self.find_by_sql(sql10)

    sql11 = "SELECT distinct(u.id) as id FROM users u 
    join notifications n on u.id =n.from_user 
    where n.location_id IN (#{location_id_arr}) AND (n.alert_type = 'Rating Reward'
    or n.alert_type = 'Points Message' or n.alert_type ='Sharing Points')
    AND n.points > 0"
    user_share_point = self.find_by_sql(sql11)

    user_common = user_comments.concat(user_favorites)
    user_common = user_common.concat(user_comment_locations)
    user_common = user_common.concat(user_fav_locations)
    user_common = user_common.concat(user_orders)
    user_common = user_common.concat(user_shares)
    user_common = user_common.concat(user_shares_prize)
    user_common = user_common.concat(user_receive_prize)
    user_common = user_common.concat(user_receive_point)
    user_common = user_common.concat(user_checkins)
    user_common = user_common.concat(user_share_point)
    user_common = user_common.uniq
    user_arr = User.where("id IN (?) AND contact_delete=0", user_common)
    #user_arr = User.where("id IN (?) AND contact_delete = 0 and is_register = 0", user_common)
    return user_arr
  end

  def self.get_user_rated(location_id_arr, user)
    get_all_list_customers(location_id_arr, user)
    #~ sql1 = "SELECT distinct(user_id) as id FROM
    #~ item_comments where build_menu_id IN(SELECT id
    #~ FROM build_menus WHERE item_id IN
    #~ (SELECT id from items where location_id IN (#{location_id_arr})))"
    #~ user_comments_rated = self.find_by_sql(sql1)
    #~ user_arr = User.where("id IN (?) AND contact_delete=0", user_comments_rated)
    #~ # user_emails = []
    #~ # unless user_arr.empty?
    #~ #   user_arr.each do |user|
    #~ #     user_emails << user.email
    #~ #   end
    #~ # end
    #~ return user_arr
  end

  def self.get_user_favorite_items(item_id)
    sql = "SELECT distinct(user_id) as id FROM item_favourites
     where favourite = 1 AND build_menu_id IN(SELECT id FROM build_menus WHERE item_id = #{item_id})"
    user_favorites = self.find_by_sql(sql)
    user_arr = User.where("id IN (?)", user_favorites)
    return user_arr
  end

  def self.get_delete_share_prize(location_id)
    sql = "SELECT distinct(s.from_user) as id FROM
                    share_prizes s where s.prize_id IN(SELECT p.id
                    FROM prizes p
                    JOIN status_prizes sp
                    ON  sp.id = p.status_prize_id
                    WHERE sp.location_id IN (#{location_id}))"
    user_prize = self.find_by_sql(sql)
    user = User.where("id IN (?)", user_prize)
    return user
  end

  def self.get_delete_receive_prize(location_id)
    sql = "SELECT distinct(s.to_user) as id FROM
                    share_prizes s where s.prize_id IN(SELECT p.id
                    FROM prizes p
                    JOIN status_prizes sp
                    ON  sp.id = p.status_prize_id WHERE sp.location_id IN (#{location_id}) AND s.status =1)"
    user_prize_receive = self.find_by_sql(sql)
    user = User.where("id IN (?)", user_prize_receive)
    return user
  end
  def self.get_delete_item_favorite(location_id)
    sql = "SELECT distinct(user_id) as id FROM item_favourites
    where favourite = 1 AND build_menu_id IN(SELECT id FROM build_menus WHERE item_id IN
    (SELECT id from items where location_id IN (#{location_id})))"
    user_favorite = self.find_by_sql(sql)
    user = User.where("id IN (?)", user_favorite)
    return user
  end

  def self.get_delete_notification(location_id)
    sql="SELECT distinct(u.id) as id FROM users u
    join notifications n on u.email =n.to_user
    where n.location_id IN (#{location_id}) AND (n.alert_type = 'Rating Reward'
    or n.alert_type = 'Points Message' or n.alert_type ='Sharing Points')
    AND n.status = 1 AND n.received = 1 AND n.is_openms = 1 and n.points > 0"
    user_notification = self.find_by_sql(sql)
    user = User.where("id IN (?)", user_notification)
    return user
  end
end
