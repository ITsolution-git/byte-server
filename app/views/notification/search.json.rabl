object @search_result
	 attributes :id,:from_user, :to_user, :about,:message,:msg_type ,:date,:restaurant
     node(:logo){|m| m.restaurant_logo}
	 node(:icon){|m| m.alert_logo}