class InvitedController < ApplicationController
  before_filter :authorise_request_as_json, :only => [:invite_email,:invite_sms,:friend_list,:get_total_message_friend_invite,:delete_friend,:get_list_friend_invitation]
  before_filter :authenticate_user_json, :only=>[:invite_sms,:invite_email,:delete_friend,:add_friend,:reply_friend_request, :invite_email_share,:invite_sms_share]
  before_filter :authorise_user_param, :only=>[:friend_list,:get_total_message_friend_invite,:get_list_friend_invitation,:friend_regis,:friend_regis_sharepoint,:change_status_message, :regis_sharepoint]
  
  # GET /invite-friend/:token
  def new
    @friendship = Friendship.find_by_token(params[:token])
    if @friendship.nil?
      redirect_to root_path
    else
      @user = User.find_by_id(@friendship.friend_id)
      @share = User.find_by_id(@friendship.friendable_id)
      @check_signup = false
      friendships = Friendship.where("friend_id = ?", @friendship.friend_id)
      friendships.each do |f|
        if f.pending == 1
          @check_signup = true
          break
        end
      end
      @user.username = ""
      @user.zip = ""
      if @user.phone
        @user.email = ""
      end
      if @user.email && @user.phone.nil?
        email = @user.email
        number = email.split('@').first
        if number.to_i != 0
          @user.email = ""
        end
      end
    end
  end

  # GET /invite-friend-share/:id/:token
  def new_sharepoint
    @friendship = Friendship.find_by_token(params[:token])
    @location = Location.find_by_id(params[:id])
    if @friendship.nil? || @location.nil?
      redirect_to root_path
    else
      @check_signup = false
      friendships = Friendship.where("friend_id =?", (@friendship.friend_id))
      friendships.each do |f|
        if f.pending == 1
          @check_signup = true
          break
        end
      end

      @share = User.find_by_id(@friendship.friendable_id)
      @user = User.find_by_id(@friendship.friend_id)
      if @user.phone
        @user.email = ""
      end
      if @user.email && @user.phone.nil?
        email = @user.email
        number = email.split('@').first
        if number.to_i != 0
          @user.email = ""
        end
      end
      unless @check_signup
        @user.username = ""
        @user.zip = ""
      end
    end
  end

  # GET /invite-social/:id/:username
  def new_social
    @currentuser = User.where("id=? AND username=?",params[:id],params[:username]).first
    if @currentuser.nil?
      render :status => 404, :json =>{:status=>:failed}
      #respond_to do |format|
      #  format.html { render action: "error" }
      #end
    else
      @c_id = @currentuser.id
      @user = User.new
    end
  end

  #Register user
  # def friend_regis_social
  #   @user = User.new(params[:user])
  #   @current_id = params[:current_id]
  #   if @user.save
  #     if @user.first_name="" && @user.last_name=""
  #       @user.update_attribute(:first_name,@user.username)
  #     end
  #     geo_obj = Geocoder.search(@user.zip).first
  #     unless geo_obj.nil?
  #       unless geo_obj.state.nil?
  #         @user.update_attribute(:state,geo_obj.state)
  #       end
  #       unless geo_obj.city.nil?
  #         @user.update_attribute(:city,geo_obj.city)
  #       end
  #     end

  #     @friendship = Friendship.new
  #     @friendship.friendable_id = @current_id
  #     @friendship.friend_id = @user.id
  #     @friendship.pending = 1
  #     if @friendship.save
  #       render :json => "You registration was successful. Please download the BYTE from the App Store/ Google Play to use your points."
  #     end
  #   else
  #     render :status => 503, :json => {:status =>:failed}
  #   end
  # end

  #Invite friend via SMS
  def invite_sms
    ActiveRecord::Base.transaction do
      phone = @parsed_json["phone"] if @parsed_json["phone"]
      check = User.find_by_phone(phone)
      email = "#{phone.gsub(/[^0-9a-z]/i,"")}@mymenu.com"
      check_friend  = check_friend_by_phone(phone, @user.id)
      check_friend2 = check_friend_by_phone2(phone, @user.id)

      unless check.nil?
            if check.role != 'user'
               @user_manager = User.find_by_phone_and_is_register(phone,1)
              unless @user_manager.nil?
                render :status => 403, :json => {:status => :failed,:is_friend => 2,:username => @user_manager.username}
                   
              else
                begin
                  @user_new = User.new
                  @user_new.username = phone.gsub(/[^0-9a-z]/i,"")
                  @user_new.email= email
                  @user_new.phone = phone
                  @user_new.is_register = 1
                  @user_new.zip = 70000
                  fname = @parsed_json["first_name"] if @parsed_json["first_name"]
                  lname = @parsed_json["last_name"] if @parsed_json["last_name"]
                
                  if (fname =="" && lname == "") || (fname.nil? && lname.nil?)
                    fname = phone.gsub(/[^0-9a-z]/i,"")
                  end
                  @user_new.first_name= fname
                  @user_new.last_name= lname
                  @user_new.password = "123456"
                  @user_new.role = USER_ROLE
                  @user_new.reset_authentication_token!
                  @user_new.save(:validate => false)

                  @friendship = Friendship.new
                  @friendship.friendable_id = @user.id
                  @friendship.friend_id = @user_new.id
                  @friendship.pending = 0
                  @friendship.save!
                  return render :status => 200, :json => {:status =>:success,:url => "http://#{request.host}:#{request.port}/invite-friend/#{@friendship.token}"}
                rescue
                  render :status => 500, :json => {:status=>:failed}
                end
              end
            else
              if check.is_register == 1 || check.is_register == 2
                render :status => 403, :json => {:status => :failed,:is_friend => 2,:username => check.username}
              else
                if check_friend || check_friend2
                  render :status => 403, :json => {:status => :failed,:is_friend => 1,:username => check.username}
                else
                  render :status => 403,:json => {:status => :failed , :is_friend => 0 ,:username => check.username}
                end
              end
            end
          
      else
        begin
          @user_new = User.new
          @user_new.username = phone.gsub(/[^0-9a-z]/i,"")
          @user_new.email= email
          @user_new.phone = phone
          @user_new.is_register = 1
          @user_new.zip = 70000

          fname = @parsed_json["first_name"] if @parsed_json["first_name"]
          lname = @parsed_json["last_name"] if @parsed_json["last_name"]
        
          if (fname =="" && lname == "") || (fname.nil? && lname.nil?)
            fname = phone.gsub(/[^0-9a-z]/i,"")
          end
          @user_new.first_name= fname
          @user_new.last_name= lname
          @user_new.password = "123456"
          @user_new.role = USER_ROLE
          @user_new.reset_authentication_token!
          @user_new.save(:validate => false)

          @friendship = Friendship.new
          @friendship.friendable_id = @user.id
          @friendship.friend_id = @user_new.id
          @friendship.pending = 0
          @friendship.save!
          return render :status => 200, :json => {:status =>:success,:url => "http://#{request.host}:#{request.port}/invite-friend/#{@friendship.token}"}
        rescue
          render :status => 500, :json => {:status=>:failed}
        end
      end
    end
  end

  # POST /invited/invite_email
  #Invite friend via Email
  def invite_email
    begin
      ActiveRecord::Base.transaction do
        email =  @parsed_json["email"]
        #message = @parsed_json["message"]
        check = User.find_by_email(email)
        first_name = @parsed_json["first_name"] if @parsed_json["first_name"]
        last_name = @parsed_json["last_name"] if @parsed_json["last_name"]
        check_friend1= check_friend_by_email(email,@user.id)
        check_friend2= check_friend_by_email2(email,@user.id)
        email1 = email.split("@").first
        unless check.nil?
          # diner can invite friend via email, if email was typed same as email of restaurant manager/owner -> can send link to invite
          # but when register, validate and show message to let they know that they need to use another email
          if check.role != 'user'
            @user_manager = User.where("email like :email_manager  AND (is_register = 1 or is_register = 2 )",{:email_manager => "%#{email1}_manager@mymenu.com%"}).first
            unless @user_manager.nil?
              puts "emai 1"
              render :status => 403, :json => {:status => :failed,:is_friend => 2,:username => @user_manager.username}
            else
              begin
                  @user_new = User.new
                  @user_new.username = Time.new.strftime("%Y%m%d%H%M%S%s")
                  @user_new.email= Time.new.strftime("%s")+ "_"+"#{email1}_manager@mymenu.com"
                  @user_new.password = "123456"
                  @user_new.is_register = 1
                  @user_new.zip = 70000
                  if (first_name == "" && last_name== "" ) || (first_name.nil? && last_name.nil?)
                    @user_new.first_name = email.split("@").first.gsub(/[^0-9a-z]/i,"")
                  else
                    @user_new.first_name = first_name
                    @user_new.last_name = last_name
                  end
                  @user_new.role = USER_ROLE
                  @user_new.reset_authentication_token!
                  @user_new.save(:validate => false)

                  @friendship = Friendship.new
                  @friendship.friendable_id = @user.id
                  @friendship.friend_id = @user_new.id
                  @friendship.pending = 0
                  @friendship.save!
                  link = "http://#{request.host}:#{request.port}/invite-friend/#{@friendship.token}"
                  if @user.first_name.nil?
                    UserMailer.custom_send_email_invite(@user.username,email, @user.username, link).deliver
                  else
                    UserMailer.custom_send_email_invite(@user.first_name + " " + @user.last_name,email, @user.username, link).deliver
                  end
                  
                  return render :status => 200, :json => {:status => :success}
              end
            end
          else
            if check.is_register == 1 || check.is_register == 2 
              render :status => 403, :json => {:status => :failed,:is_friend => 2,:username => check.username}
            else
              if check_friend1 || check_friend2
                render :status => 403, :json => {:status => :failed,:is_friend => 1,:username => check.username}
              else
                render :status => 403,:json => {:status => :failed , :is_friend => 0 ,:username => check.username}
              end
            end
          end
         
        else
          begin
              @user_new = User.new
              @user_new.username = Time.new.strftime("%Y%m%d%H%M%S%s")
              @user_new.email= @parsed_json["email"] if @parsed_json["email"]
              @user_new.password = "123456"
              @user_new.is_register = 1
              @user_new.zip = 70000
              if (first_name == "" && last_name== "" ) || (first_name.nil? && last_name.nil?)
                @user_new.first_name = email.split("@").first.gsub(/[^0-9a-z]/i,"")
              else
                @user_new.first_name = first_name
                @user_new.last_name = last_name
              end
              @user_new.role = USER_ROLE
              @user_new.reset_authentication_token!
              @user_new.save(:validate => false)

              @friendship = Friendship.new
              @friendship.friendable_id = @user.id
              @friendship.friend_id = @user_new.id
              @friendship.pending = 0
              @friendship.save!
          # rescue
          #   return render :status => 412, :json => {:status=>:failed, :error => "Invalid params"}
          end
          link = "http://#{request.host}:#{request.port}/invite-friend/#{@friendship.token}"
          if @user.first_name.nil? || (@user.first_name.nil? && @user.last_name.nil?)
            UserMailer.custom_send_email_invite(@user.username,email, @user.username, link).deliver
          else
             UserMailer.custom_send_email_invite(@user.first_name + " " + @user.last_name,email, @user.username, link).deliver
          end
          return render :status => 200, :json => {:status => :success}
        end
      end
    # rescue
    #   return render :status => 412, :json => {:status=>:failed,:error => "Can't send email."}
    end
  end

  #Friend list
  def friend_list
    friend1 = User.get_friend_by_friendable_id(@user.id)
    friend2 = User.get_friend_by_friend_id(@user.id)
    @friend = friend1.concat(friend2).sort { |x,y| x.id <=> y.id }
  end

  #Delete friend
  def delete_friend
    friend_id = @parsed_json["friend_id"]
    check = Friendship.where("friendable_id = ? AND friend_id =?",@user.id, friend_id).first
    check2 = Friendship.where("friendable_id = ? AND friend_id =?",friend_id, @user.id).first
    reciever = User.find_by_id(friend_id)
    notification = Notifications.find_by_from_user_and_to_user_and_alert_type(@user.id, reciever.email, FRIEND_REQUEST)
    if check.nil? && check2.nil?
      render :status=>403,:json=>{:error=>"Not exist friendship"}
    else
      unless check.nil? 
        check.destroy
        if check.pending == 0
          unless notification.nil?
            notification.destroy
          end
        end
        
        render :status => 200 , :json => {:status => :success}
      else
        unless check2.nil?
          check2.destroy
          render :status => 200 , :json => {:status => :success}
        else
          render :status => 403 , :json => {:error => :failed}
        end
      end
    end
  end

  # POST /invited/invite_email_share
  #invite_email_share
  def invite_email_share
    begin
      ActiveRecord::Base.transaction do
        @parsed_json["location_id"] ? location_id = @parsed_json["location_id"] : nil
        point = @parsed_json["point"] if @parsed_json["point"]
        first_name = @parsed_json["first_name"] if @parsed_json["first_name"]
        last_name = @parsed_json["last_name"] if @parsed_json["last_name"]
        
        location = Location.find_by_id(location_id)
        return render :status => 404, :json => {:status => :failed,:message => "Location not found"} if location.nil?
        
        owner_id = 0
        owner_id = location.owner_id
        #check exist user
        email = @parsed_json["email"]
        email1 = email.split("@").first
        check_friend1= check_friend_by_email3(email,@user.id)
        check_friend2= check_friend_by_email2(email,@user.id)
        if check_friend1 || check_friend2
          @user.sub_points(point)
          #Share points
          @user_share = User.find_by_email(email)
          #add user to contact group
          CustomersLocations.add_contact(Array([@user.id, @user_share.id]), location.id)
          save_user_notification(@user, location_id, point, @user_share, owner_id)
          return render :status => 200, :json => {:status => :success}
        else
          check = check_exist_email(email)
          if check !=0
            @user_share = User.find_by_email(email)
            if @user_share.role != 'user'
              @user_manager = User.where("email like :email_manager  AND (is_register = 1 or is_register =2)",{:email_manager => "%#{email1}_manager@mymenu.com%"}).first
              unless @user_manager.nil?
                  check_pending_user_share = Friendship.where("friendable_id=? and friend_id = ?" ,@user.id,@user_manager.id).first
                  unless check_pending_user_share.nil?
                    if check_pending_user_share.pending == 1 || @user_manager.is_add_friend == 1
                      @user.sub_points(point)
                      save_user_notification(@user, location_id, point, @user_manager, owner_id)
                      if @user.first_name.nil? || (@user.first_name.nil? && @user.last_name.nil?)
                        username = @user.username
                      else
                        username = @user.first_name + " " + @user.last_name
                      end
                      UserMailer.custom_send_email_regis(email,location.name,username,point).deliver
                      return render :status => 200, :json => {:status => :success}
                    else #check_pending_user_share.pending == 0
                      return render :status => 503, :json => {:status => :failed,:message => "This email has been invited to use BYTE, but hasn't signed up yet. You cannot share points to this email."}
                    end #
                  else
                    if @user_manager.is_register == 2
                      #Create new Friendship
                      @user.sub_points(point)
                      @friendship = Friendship.new
                      @friendship.friendable_id = @user.id
                      @friendship.friend_id = @user_manager.id
                      @friendship.pending = 0
                      @friendship.save!
                      save_user_notification(@user, location_id, point, @user_manager, owner_id)
                      @user_manager.skip_reconfirmation!
                      @user_manager.update_attribute(:is_register,1)
                      link = "http://#{request.host}:#{request.port}/invite-friend-share/#{location.id}/#{@friendship.token}"
                      if @user.first_name.nil? || (@user.first_name.nil? && @user.last_name.nil?)
                        username = @user.username
                      else
                        username = @user.first_name + " " + @user.last_name
                      end
                      UserMailer.custom_send_email_unregis(email, location.name, username, point, link).deliver
                      return render :status => 200, :json => {:status => :success}
                    elsif @user_manager.is_register == 0
                      @user.sub_points(point)
                      save_user_notification(@user, location_id, point, @user_manager, owner_id)
                      return render :status => 200, :json => {:status => :success}
                    else
                      return render :status => 503, :json => {:status => :failed,:message => "This email has been invited to use BYTE, but hasn't signed up yet. You cannot share points to this email."}
                    end
                  end
              else
                begin
                  @user_new = User.new
                  @user_new.username = Time.new.strftime("%Y%m%d%H%M%S%s")
                  @user_new.email= Time.new.strftime("%s")+ "_"+"#{email1}_manager@mymenu.com"
                  @user_new.password = "123456"
                  if (first_name =="" && last_name == "" ) || (first_name.nil? && last_name.nil?)
                    @user_new.first_name = email.split("@").first.gsub(/[^0-9a-z]/i,"")
                    #@user_new.last_name = email.split("@").first.gsub(/[^0-9a-z]/i,"")
                  else
                    @user_new.first_name = first_name
                    @user_new.last_name = last_name
                  end
                  @user_new.is_register = 1
                  @user_new.zip = 70000
                  @user_new.role = USER_ROLE
                  @user_new.reset_authentication_token!

                  @user_new.save(:validate => false)
                  @user.sub_points(point)

                  @friendship = Friendship.new
                  @friendship.friendable_id = @user.id
                  @friendship.friend_id = @user_new.id
                  @friendship.pending = 0
                  @friendship.save!
                # rescue
                #   return render :status => 412, :json => {:status=>:failed, :error => "Invalid params"}
                end
                  if @user.first_name.nil? || (@user.first_name.nil? && @user.last_name.nil?)
                    username = @user.username
                  else
                    username = @user.first_name + " " + @user.last_name
                  end
                save_user_notification(@user, location_id, point, @user_new, owner_id)
                link = "http://#{request.host}:#{request.port}/invite-friend-share/#{location.id}/#{@friendship.token}"
                UserMailer.custom_send_email_unregis(email, location.name, username, point, link).deliver
                return render :status => 200, :json => {:status => :success}
              end 
            else
              check_pending_user_share = Friendship.where("friendable_id=? and friend_id = ?" ,@user.id,@user_share.id).first
              unless check_pending_user_share.nil?
                if check_pending_user_share.pending == 1 || @user_share.is_add_friend == 1
                  @user.sub_points(point)
                  save_user_notification(@user, location_id, point, @user_share, owner_id)
                  if @user.first_name.nil? || (@user.first_name.nil? && @user.last_name.nil?)
                    username = @user.username
                  else
                    username = @user.first_name + " " + @user.last_name
                  end
                  UserMailer.custom_send_email_regis(email, location.name, username ,point).deliver
                  #add user to contact group when user share point
                  CustomersLocations.add_contact(Array([@user.id]), location.id)
                  return render :status => 200, :json => {:status => :success}
                else #check_pending_user_share.pending == 0
                  return render :status => 503, :json => {:status => :failed, :message => "This email has been invited to use BYTE, but hasn't signed up yet. You cannot share points to this email."}
                end #
              else
                if @user_share.is_register == 2
                  #Create new Friendship
                  @user.sub_points(point)
                  @friendship = Friendship.new
                  @friendship.friendable_id = @user.id
                  @friendship.friend_id = @user_share.id
                  @friendship.pending = 0
                  @friendship.save!
                  save_user_notification(@user, location_id, point, @user_share, owner_id)
                  @user_share.skip_reconfirmation!
                  @user_share.update_attribute(:is_register,1)
                  link = "http://#{request.host}:#{request.port}/invite-friend-share/#{location.id}/#{@friendship.token}"
                    if @user.first_name.nil? || (@user.first_name.nil? && @user.last_name.nil?)
                      username = @user.username
                    else
                      username = @user.first_name + " " + @user.last_name
                    end
                  CustomersLocations.add_contact(Array([@user.id]), location.id)
                  UserMailer.custom_send_email_unregis(email,location.name,username, point, link).deliver
                  return render :status => 200, :json => {:status => :success}
                elsif @user_share.is_register == 0
                  @user.sub_points(point)
                  save_user_notification(@user, location_id, point, @user_share, owner_id)
                  CustomersLocations.add_contact(Array([@user.id, @user_share.id]), location_id)
                  return render :status => 200, :json => {:status => :success}
                else
                  return render :status => 503, :json => {:status => :failed,:message => "This email has been invited to use BYTE, but hasn't signed up yet. You cannot share points to this email."}
                end
              end
            end #check user is manager or admin 
          else
            @user_new = User.new
            @user_new.username = Time.new.strftime("%Y%m%d%H%M%S%s")
            @user_new.email= @parsed_json["email"] if @parsed_json["email"]
            @user_new.password = "123456"
            if (first_name=="" && last_name =="" ) || (first_name.nil? && last_name.nil?)
              @user_new.first_name = email.split("@").first.gsub(/[^0-9a-z]/i,"")
            else
              @user_new.first_name = first_name
              @user_new.last_name = last_name
            end
            @user_new.is_register = 1
            @user_new.zip = 70000
            @user_new.role = USER_ROLE
            @user_new.reset_authentication_token!

            @user_new.save(:validate => false)
            @user.sub_points(point)

            @friendship = Friendship.new
            @friendship.friendable_id = @user.id
            @friendship.friend_id = @user_new.id
            @friendship.pending = 0
            @friendship.save!

            save_user_notification(@user, location_id, point, @user_new, owner_id)
            if @user.first_name.nil? || (@user.first_name.nil? && @user.last_name.nil?)
              username = @user.username
            else
              username = @user.first_name + " " + @user.last_name
            end
            CustomersLocations.add_contact(Array([@user.id]), location.id)
            link = "http://#{request.host}:#{request.port}/invite-friend-share/#{location.id}/#{@friendship.token}"
            UserMailer.custom_send_email_unregis(email,location.name,username, point, link).deliver
            return render :status => 200, :json => {:status => :success}
          end #end if check
        end
      end
    rescue
      return render :status => 500 , :json => {:error => :failed}
    end
  end

  # POST /invited/invite_sms_share
  #invite sms sharepoint
  def invite_sms_share
    ActiveRecord::Base.transaction do
      @parsed_json["location_id"] ? location_id = @parsed_json["location_id"] : nil
      point = @parsed_json["point"] if @parsed_json["point"]
      phone = @parsed_json["phone"] if @parsed_json["phone"]
      location = Location.find(location_id)
      owner_id = 0
      owner_id = location.owner_id unless location.nil?
      check_friend  = check_friend_by_phone(phone, @user.id)
      check_friend2 = check_friend_by_phone2(phone, @user.id)

      if check_friend || check_friend2  #have friend
        @user.sub_points(point)
        @user_share = User.find_by_phone(phone)
        save_user_notification(@user, location_id, point, @user_share, owner_id)
        return render :status => 200, :json => {:status => :success}
      else
        check_phone = check_exist_phone(phone)
        if check_phone!=0 #Exist phone
          @user_share = User.find_by_phone(phone)
          if @user_share.role != 'user' #if user is manager or admin
             phone1 = phone.gsub(/[^0-9a-z]/i,"")
             @user_manager = User.where("email like :email_manager  AND (is_register = 1 or is_register = 2)",{:email_manager => "%#{phone1}manageruser@mymenu.com%"}).first
             unless @user_manager.nil?
                check_pending_user_share = Friendship.where("friendable_id=? AND friend_id = ?" , @user.id, @user_manager.id).first
                unless check_pending_user_share.nil?
                    if check_pending_user_share.pending == 1 || @user_manager.is_add_friend == 1
                        @user.sub_points(point)
                        save_user_notification(@user, location_id, point, @user_manager, owner_id)
                        return render :status => 200, :json => {:status => :success}
                    else
                        return render :status => 503, :json => {:status => :failed,:message => "This phone number has been invited to use BYTE, but hasn't signed up yet. You cannot share points to this phone number."}
                    end #check_pending_user_share.pending == 0
                else
                      if @user_manager.is_register == 2
                        #Create new Friendship
                        @user.sub_points(point)
                        @friendship = Friendship.new
                        @friendship.friendable_id = @user.id
                        @friendship.friend_id = @user_manager.id
                        @friendship.pending = 0
                        @friendship.save!
                        save_user_notification(@user, location_id, point, @user_manager, owner_id)
                        @user_manager.skip_reconfirmation!
                        @user_manager.update_attribute(:is_register,1)
                        return render :status => 200, :json => {:url => "http://#{request.host}:#{request.port}/invite-friend-share/#{location.id}/#{@friendship.token}"}
                      elsif @user_manager.is_register == 0
                        @user.sub_points(point)
                        save_user_notification(@user, location_id, point, @user_manager, owner_id)
                        return render :status => 200, :json => {:status => :success}
                      else
                        return render :status => 503, :json => {:status => :failed,:message => "This phone number has been invited to use BYTE, but hasn't signed up yet. You cannot share points to this phone number."}
                      end
                end
             else
                begin
                  @user.sub_points(point)
                  @user_share = User.new
                  @user_share.email= Time.new.strftime("%s")+ "_"+"#{phone1}manageruser@mymenu.com"  
                  @user_share.username = phone.gsub(/[^0-9a-z]/i,"")
                  fname = @parsed_json["first_name"] if @parsed_json["first_name"]
                  lname = @parsed_json["last_name"] if @parsed_json["last_name"]

                  if (fname =="" && lname == "") || (fname.nil? && lname.nil?)
                   fname = phone.gsub(/[^0-9a-z]/i,"")
                   #lname = phone.gsub(/[^0-9a-z]/i,"")
                  end

                  @user_share.first_name = fname
                  @user_share.last_name = lname
                  @user_share.password = "123456"
                  @user_share.phone = phone
                  @user_share.zip = 70000
                  @user_share.is_register = 1
                  @user_share.role = USER_ROLE
                  @user_share.reset_authentication_token!
                  @user_share.save(:validate => false)


                  #Create new Friendship
                  @friendship = Friendship.new
                  @friendship.friendable_id = @user.id
                  @friendship.friend_id = @user_share.id
                  @friendship.pending = 0
                  @friendship.save!
                  save_user_notification(@user, location_id, point, @user_share, owner_id)
                  return render :status => 200, :json => {:url => "http://#{request.host}:#{request.port}/invite-friend-share/#{location.id}/#{@friendship.token}"}
                # rescue
                #   return render :status => 412, :json => {:status => :failed, :error => "Invalid params"}
                end
             end            
          else
              check_pending_user_share = Friendship.where("friendable_id=? AND friend_id = ?" , @user.id, @user_share.id).first
              unless check_pending_user_share.nil?
                if check_pending_user_share.pending == 1 || @user_share.is_add_friend == 1
                  @user.sub_points(point)
                  save_user_notification(@user, location_id, point, @user_share, owner_id)
                  return render :status => 200, :json => {:status => :success}
                else
                  return render :status => 503, :json => {:status => :failed,:message => "This phone number has been invited to use BYTE, but hasn't signed up yet. You cannot share points to this phone number."}
                end #check_pending_user_share.pending == 0
              else
                if @user_share.is_register == 2
                  #Create new Friendship
                  @user.sub_points(point)
                  @friendship = Friendship.new
                  @friendship.friendable_id = @user.id
                  @friendship.friend_id = @user_share.id
                  @friendship.pending = 0
                  @friendship.save!
                  save_user_notification(@user, location_id, point, @user_share, owner_id)
                  @user_share.skip_reconfirmation!
                  @user_share.update_attribute(:is_register,1)
                  return render :status => 200, :json => {:url => "http://#{request.host}:#{request.port}/invite-friend-share/#{location.id}/#{@friendship.token}"}
                elsif @user_share.is_register == 0
                  @user.sub_points(point)
                  save_user_notification(@user, location_id, point, @user_share, owner_id)
                  return render :status => 200, :json => {:status => :success}
                else
                  return render :status => 503, :json => {:status => :failed,:message => "This phone number has been invited to use BYTE, but hasn't signed up yet. You cannot share points to this phone number."}
                end
              end
          end 
        else
          begin
            @user.sub_points(point)
            @user_share = User.new
            @user_share.email= "#{phone.gsub(/[^0-9a-z]/i,"")}@mymenu.com"  if @parsed_json["phone"]
            @user_share.username = phone.gsub(/[^0-9a-z]/i,"")
            fname = @parsed_json["first_name"] if @parsed_json["first_name"]
            lname = @parsed_json["last_name"] if @parsed_json["last_name"]

            if (fname =="" && lname == "") || (fname.nil? && lname.nil?)
             fname = phone.gsub(/[^0-9a-z]/i,"")
             #lname = phone.gsub(/[^0-9a-z]/i,"")
            end

            @user_share.first_name = fname
            @user_share.last_name = lname
            @user_share.password = "123456"
            @user_share.phone = phone
            @user_share.zip = 70000
            @user_share.is_register = 1
            @user_share.role = USER_ROLE
            @user_share.reset_authentication_token!
            @user_share.save(:validate => false)


            #Create new Friendship
            @friendship = Friendship.new
            @friendship.friendable_id = @user.id
            @friendship.friend_id = @user_share.id
            @friendship.pending = 0
            @friendship.save!
            save_user_notification(@user, location_id, point, @user_share, owner_id)
            return render :status => 200, :json => {:url => "http://#{request.host}:#{request.port}/invite-friend-share/#{location.id}/#{@friendship.token}"}
          # rescue
          #   return render :status => 412, :json => {:status => :failed, :error => "Invalid params"}
          end
        end
      end
    end
  end

  # POST /friend_regis/:access_token
  def friend_regis
    # @user = User.find_all_by_authentication_token(params[:access_token]).first
    @friendship = Friendship.find(params[:friend_id])
    respond_to do |format|
      @user.skip_reconfirmation!
      if @user.update_attributes(params[:user])
        #Update city, state by zipcode
        update_geo_info(@user)
        #update friendship
        @user.update_attribute(:is_register, 0)
        @user.update_attribute(:created_at, @user.updated_at)
        @friendship.update_attribute(:pending, 1)
        UserMailer.custom_send_email(@user.email,SIGNUP_SUCCESS_SUBJECT,SIGNUP_SUCCESS_BODY).deliver
        #redirect to success page
        format.html { render action: :success}
      else
        @share = User.find_by_id(@friendship.friendable_id)
        format.html { render action: "new" }
      end
    end
  end

  # POST /friend_regis_sharepoint/:access_token
  # def friend_regis_sharepoint
  #   @friend_ship = Friendship.find(params[:friend_id])
  #   respond_to do |format|
  #     if @user.update_attributes(params[:user])
  #       update_geo_info(@user)
  #       #Update friendship
  #       @friend_ship.update_attribute(:pending, 1)

  #       sharer = User.find(@friend_ship.friendable_id)
  #       #LOOP to create notification......
  #       sp = SharePoint.where("friendships_id=?", @friend_ship.id)
  #       sp.each { |s|
  #         @notification = Notifications.new
  #         @notification.from_user = @friend_ship.friendable_id
  #         @notification.to_user = @user.email
  #         @notification.message = sharepoint_msg(sharer.username, s.points)
  #         @notification.msg_type = "group"
  #         @notification.location_id = s.location_id
  #         @notification.alert_type = SHARING_POINTS
  #         @notification.points = s.points
  #         @notification.msg_subject = POINTS_MESSAGE
  #         @notification.save
  #       }
  #       format.html { render action: "success" }
  #     else
  #       format.html { render action: "new_sharepoint" }
  #     end
  #   end
  # end

  def regis_sharepoint
    @friendship = Friendship.find_by_id(params[:friend_id])
    unless @friendship.nil?
      @notifications = Notifications.get_msg_between_users(@friendship.friendable_id, @user.email) \
          .msg_group.sharing_points.first
      @user.skip_reconfirmation!
      if @user.update_attributes(params[:user])
        #@user.reset_authentication_token!
        update_geo_info(@user)
        @user.update_attributes(:is_register => 0)
        @user.update_attribute(:created_at, @user.updated_at)
        @friendship.generate_token
        @friendship.update_attribute(:pending, 1)
        #LOOP to update notification
        unless @notifications.nil?
          @notifications.update_attribute(:to_user, @user.email) unless @notifications.nil?
        end
        UserMailer.custom_send_email(@user.email,SIGNUP_SUCCESS_SUBJECT,SIGNUP_SUCCESS_BODY).deliver
        CustomersLocations.add_contact(Array([@user.id]), params[:location_id])
          #redirect to succes page
        return render "success"
      end
      @share = User.find_by_id(@friendship.friendable_id)
      return render "new_sharepoint"
    else
      @user = User.new(params[:user])
      if @user.save
        UserMailer.custom_send_email(@user.email, SIGNUP_SUCCESS_SUBJECT, SIGNUP_SUCCESS_BODY).deliver
        CustomersLocations.add_contact(Array([@user.id]), params[:location_id])
        return render "success"
      end
      return render "new_sharepoint"
    end
  end

  def friend_expired
     friendship = Friendship.find_by_id(params[:friendship_id])
     check = Friendship.where('created_at > ? AND friend_id = ?', friendship.created_at, friendship.friend_id);
     unless check.empty?
        return render text: "true"
     else 
        user = User.find_by_id(friendship.friend_id)
        unless user.nil?
          if user.is_register == 2
            return render text: "true"
          else
            return render text: " "
          end
        end
     end
  end

    def check_manager
      email = params["email"] if params["email"]
      @user = User.find_by_email(email)
      
      unless @user.nil? 
         if @user.role != 'user'
         
            return render text: "true"
         end
      end
      return render text: "false"
      #return render text: "true"
    end
  def request_friend
    notification = Notifications.new
    notification.from_user = params[:from_user]
    notification.to_user =  params[:to_user]
    notification.message = invite_friend_msg(params[:username])
    notification.msg_type = "group"
    notification.alert_type = FRIEND_REQUEST
    notification.msg_subject = FRIEND_REQUEST
    notification.save
    friendship = Friendship.find_by_id(params[:friendship_id])
    friendship.generate_token
    friendship.save
    return render :json => {"adf" => params[:from_user], "adf" => params[:to_user]}

    # friendship = Friendship.find_by_id(params[:friend_id])
    # if friendship.nil?
    #   return render text: "true"
    # end
    # return render "request_friend"
  end

  def regis_social
    ActiveRecord::Base.transaction do
      @current_id = params[:cur_id]
      @user = User.new(params[:user])
      @user.role = USER_ROLE
      if (@user.first_name=="" || @user.first_name.nil? ) && (@user.last_name=="" ||@user.last_name.nil?)
        @user.first_name=@user.username
      end
      respond_to do |format|
        if @user.save
          update_geo_info(@user)
          @friendship = Friendship.create(
            :friendable_id => @current_id,
            :friend_id => @user.id,
            :pending => 1
          )
          UserMailer.custom_send_email(@user.email,SIGNUP_SUCCESS_SUBJECT,SIGNUP_SUCCESS_BODY).deliver
          #redirect to succes page
          format.html { render action: "success" }
        else
          @c_id = @current_id
          format.html { render action: "new_social" }
        end
      end #end response
    end
  end

  def add_friend
    begin
      ActiveRecord::Base.transaction do
        @parsed_json["username"] ? user_name = @parsed_json["username"] : user_name = ""
        reciever = User.where("username = ?", user_name).first
        if reciever.nil?
          return render :status => 412, :json => {:status => :failed, :message => "This friend is not exist."}
        else
          check_friend = check_friend_by_email(reciever.email, @user.id)
          check_friend1 = check_friend_by_email1(reciever.email, @user.id)
          if check_friend
            return  render :status => 200,:json => {:status => :failed, :message => "You have already requested to add this user as your friend."}
          elsif check_friend1
            friendship = Friendship.find_by_friend_id_and_friendable_id(@user.id, reciever.id)
            if friendship.pending == 2
              return  render :status => 200,:json => {:status => :failed, :message => "You have already requested to add this user as your friend."}
            else
              friendship.update_attributes(:pending => 2)
              notification = Notifications.find_by_from_user_and_to_user_and_alert_type(reciever.id, @user.email, FRIEND_REQUEST)
              notification.destroy unless notification.nil?
              return render :status => 200,:json => {:status => :success}
            end
          else
            
              friendship = Friendship.new
              friendship.friendable_id = @user.id
              friendship.friend_id = reciever.id
              friendship.generate_token
              friendship.pending = 0
              friendship.save!

              notification = Notifications.new
              notification.from_user = @user.id
              notification.to_user =  reciever.email
              #notification.location_id = location_id
              notification.message = invite_friend_msg(@user.username)
              notification.msg_type = "group"
              notification.alert_type = FRIEND_REQUEST
              notification.msg_subject = FRIEND_REQUEST
              notification.save!

              reciever.update_attribute(:is_add_friend, 1)
              return render :status => 200,:json => {:status => :success}
          end
        end
      end
    # rescue
    #  return render :status =>503,:json =>{:status => :failed}
    end
  end

  def reply_friend_request
    begin
      ActiveRecord::Base.transaction do
        username = @parsed_json["username"] if @parsed_json["username"]
        sender = User.where("username = ?" , username).first
        is_accept = @parsed_json["is_accept"].to_i if @parsed_json["is_accept"]
        friendship = Friendship.find_by_friendable_id_and_friend_id(sender.id, @user.id)
        notification = Notifications.where("from_user = ? and to_user = ? and alert_type = ?", sender.id, @user.email, FRIEND_REQUEST).first
        unless (friendship.nil? && notification.nil?)
          notification.destroy
          if is_accept ==0
            friendship.update_attributes!(:pending => 2)
            return render :status => 200, :json =>{:status => :success}
          else
            friendship.destroy
            @user.update_attribute(:is_add_friend, 0)
            return render :status => 200, :json =>{:status => :success}
          end
        else
          return render :status => 500, :json =>{:status => :failed,:error => "1"}
        end
      end
    rescue
      return render :status => 500, :json =>{:status => :failed}
    end
  end

  def change_status_message
    message_id = params["message_id"] if params["message_id"]
    puts "@@@@@@@@ message: #{message_id}"
    @notification = Notifications.find_by_id(message_id)
    #friendship = Friendship.find_by_friendable_id_and_friend_id(@notification.from_user, @user.id)
      unless @notification.nil?
        if @notification.update_attribute(:status,1)
          return render :status => 200, :json =>{:status => :success}
        end
        return render :status => 503, :json =>{:status => :failed}
      else
        return render :status => 503, :json =>{:status => :failed,:error => "1"}
      end   
  end

  def get_total_message_friend_invite
    @friend_messages = Notifications.get_total_unread_message_by_my_friend(@user.email)
  end

  def get_list_friend_invitation
    @list_invation = Notifications.get_list_invitation(@user.email)
  end

  def save_user_notification(user, location_id, point, user_shared, owner_id)
    location = Location.find_by_id(location_id)
    UserPoint.create(
     :user_id => user.id,
     :point_type => "Points Shared",
     :location_id => location_id,
     :points => point,
     :status => 1,
     :is_give => 0
    )
    UserPoint.create(
     :user_id => user_shared.id,
     :point_type => RECEIVED_POINT_TYPE,
     :location_id => location_id,
     :points => point,
     :status => 1,
     :is_give => 1
    )
    if user.first_name.nil? && user.last_name.nil?
      username = user.username
    else
      username = user.first_name + " " + user.last_name
    end
    Notifications.create(
      :from_user => user.id,
      :to_user => user_shared.email,
      :message => sharepoint_msg(username,location.name, point),
      :msg_type => "single",
      :location_id => location_id,
      :alert_type => SHARING_POINTS,
      :alert_logo => POINT_LOGO,
      :msg_subject => POINTS_MESSAGE,
      :points => point
    )
  end

  def regis_sharepoint_new
    respond_to do |format|
      @user = User.new(params[:user])
      if @user.save
        update_geo_info(@user)
       UserMailer.custom_send_email(@user.email,SIGNUP_SUCCESS_SUBJECT,SIGNUP_SUCCESS_BODY).deliver
        #redirect to succes page
        format.html { render action: "success" }
      else
        format.html { render action: "new_sharepoint" }
      end
    end
  end

  private
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
end
