class UserAccountsController < ApplicationController
  include UsersHelper
  before_filter :authenticate_user!, :except => [:move_location_to_new_user]

  def index
    # @user_accounts = User.where("role!=? and role !=?",USER_ROLE, ADMIN_ROLE).page(params[:page]).per(10)
    # @user_accounts.sort!{ |a,b| a.name.downcase <=> b.name.downcase }
    # respond_to do |format|
    #   format.html # index.html.erb
    # end
  end

  def delete
    @user_account = params[:user_account]
    str = @user_account.split('?').last
    @is_checked = false
    if str.nil?
      @is_checked = true
    else
      @user_account_array = str.split('=').last
      if @user_account_array == 'user_account'
        @is_checked = true
      end
    end
  end

  def action_delete
    @user_account = params[:user_account]
    user_array = []
    user_array_manager = []
    if !@user_account.blank?
      @user_account.each do |user_id|
        user_role = User.find_by_id(user_id)

        if user_role.owner?
          user_array << user_id
        elsif user_role.restaurant_manager?
          user_array_manager << user_id
        end

        user_delete = User.find_by_id(user_id)
        if !user_delete.nil? && !user_delete.admin?
          customer_id = user_delete.customer_id
          user_delete.destroy
          unless customer_id.nil?
            begin
              result = Braintree::Customer.delete("#{customer_id}")
              if result.success?
                puts 'customer successfully deleted'
              else
                fail 'this should never happen'
              end
            rescue Exception => e
              puts 'error'
            end
          end
        end

      end
    end

    # delete restaurant manager
    unless user_array_manager.empty?
      user_array_manager.each do |arr|
        rsr_manager = arr.to_s + ','
        location_delete_manager = Location.where('rsr_manager =?', rsr_manager)

        notifications = Notifications.where("from_user =?",arr)
        unless notifications.empty?
          notifications.each do |notification|
            unless notification.nil?
              notification.destroy
            end
          end
        end

        user_delete = User.find_by_id(arr)
        unless user_delete.nil?
          unless user_delete.email.nil?
            notification_email = Notifications.where('to_user =?',user_delete.email)
            unless notification_email.empty?
              notification_email.each do |no|
                unless no.nil?
                  no.destroy
                end
              end
            end
          end
        end

        user_points = UserPoint.where('user_id =?', arr)
        unless user_points.empty?
          user_points.each do |user_point|
            unless user_point.nil?
              user_point.destroy
            end
          end
        end

        unless location_delete_manager.empty?
          location_delete_manager.each do |l|
            owner_id = l.owner_id unless l.owner_id.nil?
            restaurant_owner_count = Location.where('owner_id =?', owner_id).count
            l.destroy
            if restaurant_owner_count == 1
              user_owner = User.find_by_id(owner_id)

              if !user_owner.nil? && !user_owner.admin?
                customer_id = user_owner.customer_id
                user_owner.destroy
                unless customer_id.nil?
                  begin
                    result = Braintree::Customer.delete("#{customer_id}")
                    if result.success?
                      puts 'customer successfully deleted'
                    else
                      fail 'this should never happen'
                    end
                  rescue Exception => e
                    puts 'error'
                  end
                end
              end
            end
          end
        end
      end
    end

    user_owner_delete = User.where("id IN (?)", user_array)
    unless user_owner_delete.empty?
      user_owner_delete.each do |user|
        unless user.nil?
          unless user.email.nil?
            notification_owner_email = Notifications.where('to_user =?',user.email)
            unless notification_owner_email.empty?
              notification_owner_email.each do |no|
                unless no.nil?
                  no.destroy
                end
              end
            end
          end
        end
      end
    end

    # delete restaurant
    manager_delete = []
    #~ notifications = Notifications.where('from_user IN (?)', user_array)
    #~ unless notifications.empty?
      #~ notifications.each do |notification|
        #~ unless notification.nil?
          #~ notification.destroy
        #~ end
      #~ end
    #~ end

    user_points = UserPoint.where('user_id IN (?)', user_array)
    unless user_points.empty?
      user_points.each do |user_point|
        unless user_point.nil?
          user_point.destroy
        end
      end
    end

    location_delete = Location.where('owner_id IN (?)', user_array)
    unless location_delete.empty?
      location_delete.each do |l|
        unless l.rsr_manager.nil?
          manager_arr = l.rsr_manager.split(',')
          manager = manager_arr[0].to_i
          if l.owner_id != manager
            rsr_manager = manager.to_s + ','
            location_manager = Location.where('rsr_manager=?', rsr_manager)
            unless location_manager.empty?
              location_manager.each do |local|
                local.destroy
              end
            end
            manager_delete << manager
          end
        end
        l.destroy
      end
    end

    # delete manager
    unless manager_delete.empty?
      manager_delete.each do |rsr|
        user_manager_delete = User.find_by_id(rsr)
        if !user_manager_delete.nil? && !user_manager_delete.admin?
          user_manager_delete.destroy
        end
      end
    end

    respond_to do |format|
      format.js
    end
  end

  # GET /user_accounts/1
  # GET /user_accounts/1.json
  def show
    # @user_account = User.find(params[:id])

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.json { render json: @user_account }
    # end
  end

  # GET /user_accounts/new
  # GET /user_accounts/new.json
  def new
    # @user_account = User.new

    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.json { render json: @user_account }
    # end
  end

  # GET /user_accounts/1/edit
  def edit
    # @user_account = User.find(params[:id])
  end

  # POST /user_accounts
  # POST /user_accounts.json
  def create
    # @user_account = User.new(params[:user_account])

    # respond_to do |format|
    #   if @user_account.save
    #     format.html { redirect_to @user_account, notice: 'User account was successfully created.' }
    #     format.json { render json: @user_account, status: :created, location: @user_account }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @user_account.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PUT /user_accounts/1
  # PUT /user_accounts/1.json
  def update
    # @user_account = UserAccount.find(params[:id])

    # respond_to do |format|
    #   if @user_account.update_attributes(params[:user_account])
    #     format.html { redirect_to @user_account, notice: 'User account was successfully updated.' }
    #     format.json { head :no_content }
    #   else
    #     format.html { render action: "edit" }
    #     format.json { render json: @user_account.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /user_accounts/1
  # DELETE /user_accounts/1.json
  def destroy
  end

  def reset_password
    @user_accounts = User.where('role!=? and role !=?', USER_ROLE, ADMIN_ROLE).page(params[:page]).per(10)
    @user = User.find_by_id(params[:format])
  end

  def action_reset
    user = User.find_by_id(params[:user_account])
    @confirmed = true
    respond_to do |format|
      if !user.nil?

        if user.confirmed? && user.owner?
          if User.send_reset_password_instructions({:email => user.email})
            format.js
          end
        else
          @confirmed = false
          format.js
        end
      end
    end
  end

  def search
    @user_accounts = User.where("role!=? and role !=?",USER_ROLE, ADMIN_ROLE).order('created_at DESC').page(params[:page]).per(10)
    # @user_accounts.sort!{ |b,a| a.created_at <=> b.created_at }
    @search_params = params[:search]

    unless @search_params.nil? ||@search_params == ""
      role = 'onwer'
      @user_accounts = User.search_user_account(@search_params,role).order('created_at DESC').page(params[:page]).per(10)
      # @user_accounts.sort!{ |b,a| a.created_at <=> b.created_at }
    end
  end

  def change_user_status
    unless params[:id].blank?
      id_status = params["id"].split("_")
      user = User.find(id_status[0])
      status = (id_status[1] == "Active" ? 0 : 1)
      user.update_attribute(:is_suspended, status)
      render :text=> user_status(user)
    else
      render :text=> false
    end
  end

  def change_user_password
    if !params["user"].blank? && !params["user"]["user_id"].blank?
      user = User.find(params["user"]["user_id"])
      user.password = params["user"]["new_password"]
      user.password_confirmation = params["user"]["new_password"]
      user.save(:validate=>false)
      render :text=> "Password successfully updated."
    else
      render :text=> "Please try again. Password does not match."
    end
  end

  def change_user_email
    if !params["user"].blank? && !params["user"]["user_id_email"].blank?
      @user = User.find(params["user"]["user_id_email"])
      @user.skip_reconfirmation!
      @user.email = params["user"]["user_new_email"]
      @user.email_confirmation = params["user"]["user_new_email_confirm"]
      respond_to do |format|
        format.js do
          @user.valid?
          if @user.errors[:email].blank?
            @user.save(validate: false)
            render 'user_accounts/change_user_email_success'
          else
            render 'user_accounts/change_user_email_error'
          end
        end
      end
    else
      render nothing: true
    end
  end

  def move_location_to_new_user
    unless params["location_id"].blank?
      session["move_location_id"] = params["location_id"]
      session[:app_service_id] = 4#current_user.app_service_id
      location = Location.find(params["location_id"])
      user_account = User.find(location.owner_id)
      render :partial=> "move_location_to_new_user", locals: {location: location, user_account: user_account}
    end
  end

  def account_setting
    user_account = User.find(params["id"])
    locations = Location.where("owner_id= ?",user_account.id)
    
    render :partial=> "account_setting", locals: {locations: locations, user_account: user_account}
  end

  def new_user_with_location
    user_id = params["user_move"]["user_id"]
    location_id = params["user_move"]["location_id"]

    user = User.find(user_id)
    user_json = user.remove_token_code

    user_new = User.new(user_json)
    user_new = user_new.create_custome_user(params["user_move"])

    location = Location.create_custome_location(location_id, user_new)

    profile = user_new.build_profile
    profile.create_custome_profile(location)

    user_new.send_confirmation_instructions
    render :text=> "true"
  end
end
