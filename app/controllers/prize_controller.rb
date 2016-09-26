class PrizeController < ApplicationController

  before_filter :authorise_request_as_json, :only => [:send_to_friend, :redeem_prize, :share_social, :total_prize, :send_to_email]
  before_filter :authenticate_user_json, :only => [:redeem_prize, :send_to_friend, :send_to_email]
  before_filter :authorise_user_param, :only => [:share_social, :total_prize]

  def send_to_friend
    begin
      ActiveRecord::Base.transaction do

        @parsed_json["prize_id"] ? prize_id = @parsed_json["prize_id"].to_i : nil
        @parsed_json["friend_id"] ? friend_id = @parsed_json["friend_id"].to_i : nil
        @parsed_json["share_prize_id"] ? share_prize_id = @parsed_json["share_prize_id"].to_i : nil
        prize = Prize.find_by_id(prize_id)
        if prize.nil?
          return render :status => 412, :json => {:status => :failed, :message => "Invalid params"}
        end
        location = nil
        location = Location.find_by_id(prize.status_prize.location_id) unless prize.status_prize.nil?
        friend = User.find_by_id(friend_id)
        if location.nil? || friend.nil? || share_prize_id.nil?
          return render :status => 412, :json => {:status => :failed, :message => "Invalid params"}
        end

        user_id = @user.id
        if @user.first_name.nil?
          username = @user.username
        else
          username = @user.first_name + " " +@user.last_name
        end
        
        redeem_value = prize.redeem_value
        #==============Begin Phuong code
         if share_prize_id == 0
          UserPoint.create({
            :user_id => user_id,
            :point_type => PRIZES_SHARED,
            :location_id => location.id,
            :points => redeem_value,
            :status => 1,
            :is_give => 0
          })
         end
         
         # add user to contact when user share share
        CustomersLocations.add_contact(Array([user_id, friend_id]),location.id)        
        
        share = SharePrize.find_by_id(share_prize_id)
        
        unless share.nil?
          share.update_attributes(:is_refunded => 2)
        end

        share_prize = SharePrize.new

        #==============End phuong code
        
        share_prize.prize_id = prize_id
        share_prize.from_user = user_id
        share_prize.to_user = friend_id
        share_prize.share_id = share_prize_id
        share_prize.status = 1
        share_prize.from_share = 'friend'
        share_prize.save

        noti = Notifications.new
        noti.from_user = user_id
        noti.to_user = friend.email
        noti.message = share_prizes_msg(username, prize.name, location.name)
        noti.msg_type = "single"
        noti.location_id = location.id
        noti.alert_type = PRIZE_ALERT_TYPE
        noti.alert_logo = POINT_LOGO
        noti.msg_subject= PRIZE_ALERT_TYPE
        noti.points = redeem_value
        noti.save!
        return render :status => 200, :json => {:status => :success}
      end
    rescue
      return render :status => 503, :json => {:status => :failed, :error => "Service Unavailable"}
    end
  end

  # POST /prize/redeem_prize
  # This is how users can exchange points for a prize
  # of their choosing.
  def redeem_prize
    begin
      ActiveRecord::Base.transaction do
        # Set the variables
        prize_id = @parsed_json["prize_id"] ?  @parsed_json["prize_id"].to_i : 0
        type         =  @parsed_json["type"]  if  @parsed_json["type"]
        from_user    =  @parsed_json["from_user"]   if  @parsed_json["from_user"]
        level        =  @parsed_json["level_number"]  if  @parsed_json["level_number"]
        timezone      =  @parsed_json["time_zone"]      if  @parsed_json["time_zone"]
        share_prize_id =  @parsed_json["share_prize_id"] if  @parsed_json["share_prize_id"]

        # Confirm the necessary values are available
        if prize_id == 0
          return render :json => {:status => :failed, :message => "Invalid params"}
        end
        if type.blank?
          return render :json => {:status => :failed, :message => "Type is not null"}
        end
        if from_user.blank?
          return render :json => {:status => :failed, :message => "From_user is not null"}
        end
        if share_prize_id.blank?
          return render :json => {:status => :failed, :message => "Share_prize_id is not null"}
        end
        if timezone.blank?
          return render :json => {:status => :failed, :message => "Timezone is not null"}
        end

        # Retrieve the records
        prize = Prize.find_by_id(prize_id)
        unless prize.nil?
          location = Location.find_by_id(prize.status_prize.location_id) unless prize.status_prize.nil?
        end
        if location.blank? 
          return render :status => 412, :json => {:status => :failed, :message => "Invalid params"}
        end
        
        #add user to contact group when user redeem prize
        CustomersLocations.add_contact(Array([@user.id]), location.id)
        
        # Retrieve the Prize record
        if from_user.to_i == 0
          prize = Prize.find_by_id(prize_id)
          unless prize.blank?
            sub_point_user(@user.id, location.id, prize.redeem_value)
          end
      	end
  
        # Create the PrizeRedeem record
        redeem_prize = PrizeRedeem.new(
          prize_id: prize_id,
          user_id: @user.id,
          from_user: from_user,
          level: level,
          redeem_value: prize.redeem_value,
          timezone: timezone,
          share_prize_id: share_prize_id,
          from_redeem: type,
          is_redeem: 1
        )
				if redeem_prize.save
          # Update the SharePrize record
          share_prize = SharePrize.find_by_id(share_prize_id)
					share_prize.update_attribute(:is_redeem, 1) if share_prize.present?
					
          # Return a nice little response using a bunch of ugly SQL
          sql = "
            SELECT DATE_FORMAT(CONVERT_TZ(pr.created_at,'+00:00', pr.timezone), '%m.%d.%Y / %I:%i%p') AS date_time_redeem
						FROM prize_redeems AS pr
            WHERE pr.id = #{redeem_prize.id}"
					time_redeem = Prize.find_by_sql(sql)
				  return  render json: {status: :success, date_time_redeem: time_redeem.first.date_time_redeem}
				end
			end
    rescue => e
      return render json: {status: :failed, error: e.message}
    end
  end

  def share_social
    begin
      ActiveRecord::Base.transaction do
        type        = params[:type] if params[:type]
        location_id = params[:location_id] if params[:location_id]
        date_time   = params[:date_time] if params[:date_time]
        point       = 0

        share_social = SocialShare.new
        share_social.location_id = location_id
        share_social.user_id     = @user.id
        share_social.socai_type  = type
        share_social.date_time   = date_time
        location = Location.find_by_id(location_id)
        return render :status => 404, :json => {:status => :failed, :error => "Resource not found"} if location.nil?
        if share_social.save
           user_share = SocialShare.where("location_id = ? and user_id = ? and socai_type =? and date_time = ?",location_id,@user.id,type,date_time)
           item = Item.find params[:item_id]
           share_social.update_attribute('item_id', item.id)
          if  user_share.count <= 3
            socail_point = SocialPoint.find_by_location_id(location_id)
            unless socail_point.nil?
              if type == 'facebook'
                point = socail_point.facebook_point.to_i
              elsif type == 'twitter'
                point  = socail_point.twitter_point.to_i
              elsif type == 'googleplus'
                point  = socail_point.google_plus_point.to_i
              elsif type == 'instagram'
                point  = socail_point.instragram_point.to_i
              end
            end
            if point.to_i > 0
              add_point_user(@user.id, location_id, point)
            end
          end

          #add user to contact group when user share menu item and restaurant on social
          CustomersLocations.add_contact(Array([@user.id]), location_id)
          return  render :json => {:status => :success}
        end
      end
    rescue
      return render :status => 500, :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end

  def add_point_user(user_id,location_id,point)
    UserPoint.create(
      {
        :user_id => user_id,
        :point_type => "Points from Restaurant",
        :location_id => location_id,
        :points => point,
        :status => 1,
        :is_give => 1
      })
  end

	def add_point_user(user_id,location_id,point)
		UserPoint.create({
      :user_id => user_id,
      :point_type => "Points from Restaurant",
      :location_id => location_id,
      :points => point,
      :status => 1,
      :is_give => 1
    })
	end

	def sub_point_user(user_id,location_id,point)
		UserPoint.create({
      :user_id => user_id,
      :point_type => "Redeem Prize",
      :location_id => location_id,
      :points => point,
      :status => 1,
      :is_give => 0
    })
	end

	def total_prize
	    @locations = Location.get_location_global(@user.id)
	    count = 0
	    user_id = @user.id
	    unless @locations.empty?
	      @locations.each  do |l| 
	        current_prizes = Prize.get_unlocked_prizes_by_location(l.id, l.total, user_id)
          prizes = current_prizes.concat(Prize.get_received_prizes(l.id, user_id))
	        prizes = Prize.reject_prizes_in_order(current_prizes, l.id, user_id)
          prizes = Prize.hide_redeemed_prizes_after_three_hours(prizes)
	        unless prizes.empty?
	          prizes.each do |prize|
	            if prize.date_time_redeem.nil?
	              count = count + 1
	            end
	          end
	        end
	      end 
	    end
	    return  render :status => 200, :json => {:status => :success , :total_prize => count}
	end

  def send_to_email
    begin
      ActiveRecord::Base.transaction do
        @parsed_json["prize_id"] ? prize_id = @parsed_json["prize_id"].to_i : nil
        @parsed_json["email"] ? email = @parsed_json["email"].to_s : nil 
        @parsed_json["share_prize_id"] ? share_prize_id = @parsed_json["share_prize_id"].to_i : nil

        prize = Prize.find_by_id(prize_id)
        if prize.nil?
          return render :status => 412, :json => {:status => :failed, :message => "Invalid params"}
        end
        location = prize.status_prize.location unless prize.status_prize.nil?
        if location.nil? || share_prize_id.nil?
          return render :status => 412, :json => {:status => :failed, :message => "Invalid params"}
        end
        user_id = @user.id
        if @user.first_name.nil?
          username = @user.username
        else
          username = @user.first_name + " " + @user.last_name
        end
        redeem_value = prize.redeem_value
        # minus point of user
        if share_prize_id == 0
          UserPoint.create({
            :user_id => user_id,
            :point_type => PRIZES_SHARED,
            :location_id => location.id,
            :points => prize.redeem_value,
            :status => 1,
            :is_give => 0
          })
        end

        #add user to contact group when user share prize
        CustomersLocations.add_contact(Array([@user.id]), location.id)
        share = SharePrize.find_by_id(share_prize_id)
        unless share.nil?
           share.update_attributes(:is_refunded => 2)
        end

        share_prize = SharePrize.new
        share_prize.prize_id = prize_id
        share_prize.from_user = @user.id
        share_prize.share_id = share_prize_id
        share_prize.from_share = 'friend'

        user = User.find_by_email(email)
        unless user.nil?
          share_prize.to_user = user.id
          if user.is_register == 1 || user.is_register == 2
            share_prize.status = 0
            share_prize.save
            
            @friendship = Friendship.new
            @friendship.friendable_id = @user.id
            @friendship.friend_id = user.id
            @friendship.pending = 0
            @friendship.save!

            link = "http://#{request.host}:#{request.port}/share_prize/#{location.id}/#{share_prize.token}/#{@friendship.token}"
            UserMailer.send_email_share_prize(email, @user.username, prize.name, location.name, link).deliver
          else
            share_prize.status = 1
            share_prize.save
            noti = Notifications.new
            noti.from_user = user_id
            noti.to_user = email
            noti.message = share_prizes_msg(username, prize.name, location.name)
            noti.msg_type = "single"
            noti.location_id = location.id
            noti.alert_type = PRIZE_ALERT_TYPE
            noti.alert_logo = POINT_LOGO
            noti.msg_subject= PRIZE_ALERT_TYPE
            noti.points = redeem_value
            noti.save
          end
          return render :status => 200 , :json => {:status => :success}
        else
          user_new = User.new
          user_new.username = ''
          user_new.email= email
          user_new.password = @user.generate_password(8)
          user_new.first_name = ''
          user_new.last_name = ''
          user_new.is_register = 1
          user_new.zip = ''
          user_new.role = USER_ROLE
          user_new.reset_authentication_token!
          user_new.save(:validate => false)

          # add invited user to friend list
          @friendship = Friendship.new
          @friendship.friendable_id = @user.id
          @friendship.friend_id = user_new.id
          @friendship.pending = 0
          @friendship.save!

          share_prize.status = 0
          share_prize.to_user = user_new.id
          share_prize.save!
          link = "http://#{request.host}:#{request.port}/share_prize/#{location.id}/#{share_prize.token}/#{@friendship.token}"
          UserMailer.send_email_share_prize(email, @user.username, prize.name, location.name, link).deliver
          return render :status => 200 , :json => {:status => :success}
        end
      end
    rescue
      return render :status => 500, :json => {:status => :failed, :error => "Internal Service Error"}
    end
  end
  
  def new
    @prize = SharePrize.find_by_token(params[:token])
    @location = Location.find_by_id(params[:id])
    @friendship = Friendship.find_by_token(params[:friendship_token])
    if @prize.nil? || @location.nil?
      redirect_to root_path
    else
      @user = User.find_by_id(@prize.to_user)
      @prize_token = @prize.token
      @is_receive = @prize.status
    end
  end

  def register
    ActiveRecord::Base.transaction do
      token = params[:prize_token]
      share_prize = SharePrize.find_by_token(token)
      @friendship = Friendship.find_by_id(params[:friend_id])
      @user = User.find_by_id(share_prize.to_user)
      location_id = params[:location_id]
      @location = Location.find(location_id)
      unless @friendship.nil?
        respond_to do |format|
          if !@user.nil?
            @user.update_attributes(params[:user])
            update_geo_info(@user)
            share_prize.status = 1
            # share_prize.generate_token
            share_prize.save

            @friendship.generate_token
            @friendship.update_attribute(:pending, 1)

            UserMailer.custom_send_email(@user.email,SIGNUP_SUCCESS_SUBJECT,SIGNUP_SUCCESS_BODY).deliver
            #add user to contact group when user share prize
            CustomersLocations.add_contact(Array([@user.id]), location_id)
            #redirect to succes page
            format.html { render action: "success" }
          else
            @prize_token = token
            format.html { render action: "new" }
          end
        end
      end
    end
  end

  def update_geo_info(user)
    if user.user?
      geo_obj = Geocoder.search(user.zip).first
      unless geo_obj.nil?
        info = {}
        info[:state] = geo_obj.state unless geo_obj.state.nil?
        info[:city] = geo_obj.city unless geo_obj.city.nil?
        user.update_attributes(info)
      end
    end
  end

  def addPrize
    prize_token = params["prize_token"] if params["prize_token"]
    prize = SharePrize.find_by_token(prize_token)
    unless prize.nil?
      prize.status = 1
      prize.save
    end
    return render text: "true"
  end

  def check_username
    username = params[:username]
    user = User.find_by_username(username)
    if user.nil?
      return render text: "true"
    else
      return render text: "false"
    end
  end

  def check_email
    email = params[:email]
    user_id = params[:user_id]
    user = User.find_by_email(email)
    if user.nil?
      return render text: "true"
    else
      if user.id.to_i == user_id.to_i
        return render text: "true"
      else
        return render text: "false"
      end
    end
  end
end
