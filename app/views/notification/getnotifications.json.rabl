
object @notification
    attributes :id,:from_user, :to_user, :about,:message,:msg_type ,:date,:restaurant,:alert_type,:points,:rating_status
     node(:logo){|m| m.location.logo.fullpath if m.location.logo}
	 node(:icon){|m| m.alert_logo}


