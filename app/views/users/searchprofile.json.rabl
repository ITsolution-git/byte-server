collection @profile
attributes :id,:name,:location_rating,:item_price,:item_rating,:radius,:item_type,:menu_type,:server_rating,:isdefault
node (:keyword) {|m| m.text}
node (:point_offered) {|m| m.item_reward}