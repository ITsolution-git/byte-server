class UserAccountAppsController < ApplicationController
   before_filter :authenticate_user!
  # GET /user_account_apps
  # GET /user_account_apps.json
  def index
    @user_accounts_app = User.where("role=? and is_register=?",USER_ROLE, 0).page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_account_apps }
    end
  end

  def search
    @user_accounts_app = User.where("role=? and is_register=?",USER_ROLE, 0).order('created_at DESC').page(params[:page]).per(10)
    # @user_accounts_app.sort!{ |b,a| a.created_at <=> b.created_at }
    @search_params = params[:search]

    unless @search_params.nil? ||@search_params == ""
      role = 'user'
      @user_accounts_app = User.search_user_account(@search_params, role).order('created_at DESC').page(params[:page]).per(10)
      # @user_accounts_app.sort!{ |b,a| a.created_at <=> b.created_at }
    end

    # Used in search.csv.erb for printing all users
    @user_accounts_app_all = User.where("role=? and is_register=?",USER_ROLE, 0).order('created_at DESC')

    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"app-users.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def delete
    @user_accounts_app = params[:user_account]
    str = @user_accounts_app.split('?').last
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
    @user_accounts_app = params[:user_account]
    if !@user_accounts_app.nil?
      @user_accounts_app.each do |user_id|
        user_delete = User.find_by_id(user_id)

        notifications = Notifications.where('from_user =?',user_id)
        unless notifications.blank?
          notifications.each do |notification|
            unless notification.blank?
              notification.destroy
            end
          end
        end

        user_points = UserPoint.where('user_id =?',user_id)
        unless user_points.empty?
          user_points.each do |user_point|
            unless user_point.nil?
              user_point.destroy
            end
          end
        end
        
        if !user_delete.blank? && !user_delete.admin?
          user_delete.destroy 
        end
      end  
    end
    respond_to do |format|
      format.js
    end
  end

  def reset_password
    @user_accounts_app = User.where("role=? and is_register=?",USER_ROLE, 0).page(params[:page]).per(10)
    @user = User.find_by_id(params[:format])
  end

  def action_reset
    user = User.find_by_id(params[:user_account])
    respond_to do |format|
      if !user.nil?
        if User.send_reset_password_instructions({:email => user.email})
          format.js
        end
      end
    end
  end

  # GET /user_account_apps/1
  # GET /user_account_apps/1.json
  def show
    @user_account_app = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_account_app }
    end
  end

  # GET /user_account_apps/new
  # GET /user_account_apps/new.json
  def new
    @user_account_app = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_account_app }
    end
  end

  # GET /user_account_apps/1/edit
  def edit
    @user_account_app = User.find(params[:id])
  end

  # POST /user_account_apps
  # POST /user_account_apps.json
  def create
    @user_account_app = User.new(params[:user_account_app])

    respond_to do |format|
      if @user_account_app.save
        format.html { redirect_to @user_account_app, notice: 'User account app was successfully created.' }
        format.json { render json: @user_account_app, status: :created, location: @user_account_app }
      else
        format.html { render action: "new" }
        format.json { render json: @user_account_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_account_apps/1
  # PUT /user_account_apps/1.json
  def update
    @user_account_app = User.find(params[:id])

    respond_to do |format|
      if @user_account_app.update_attributes(params[:user_account_app])
        format.html { redirect_to @user_account_app, notice: 'User account app was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_account_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_account_apps/1
  # DELETE /user_account_apps/1.json
  def destroy
    @user_account_app = User.find(params[:id])
    @user_account_app.destroy

    respond_to do |format|
      format.html { redirect_to user_account_apps_url }
      format.json { head :no_content }
    end
  end

  def suspend_customer
    @customer_id = params[:customer_id]
    respond_to do |format|
      format.js
    end
  end

  def un_suspend_customer
    @customer_id = params[:customer_id]
    respond_to do |format|
      format.js
    end
  end

  def action_suspend_customer
    @customer_id = params[:customer_id]
    user = User.find_by_id(@customer_id)
    unless user.nil?
      user.update_attribute(:is_suspended, 1)
    end
    respond_to do |format|
      format.js
    end
  end

  def action_un_suspend_customer
    @customer_id = params[:customer_id]
    user = User.find_by_id(@customer_id)
    unless user.nil?
      user.update_attribute(:is_suspended, 0)
    end
    respond_to do |format|
      format.js
    end
  end
end
