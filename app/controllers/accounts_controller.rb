require 'RMagick'
include Magick

class AccountsController < ApplicationController
  before_filter :authenticate_user!
  def create
    @restaurant = Location.find(params[:restaurant_id])
    @account = User.where(:email=>params[:account][:email]).first_or_initialize(params[:account])
    respond_to do |format|
      if @account.save
         @restaurant.users << @account unless @restaurant.users.include?(@account)
        format.html { redirect_to restaurant_accounts_path(@restaurant), notice: 'User successfully added' }
        format.js
      else
        format.html { render action: "index" }
        format.js
      end
    end
  end

  def update
    @restaurant=Location.find(params[:restaurant_id])
    @update_account = User.find(params[:id])
    @account = User.new
    if params[:account][:password].blank?
      params[:account].delete("password")
      params[:account].delete("password_confirmation")
    end
    respond_to do |format|
      if @update_account.update_attributes(params[:account])
        format.html { redirect_to restaurant_accounts_path(@restaurant), notice: 'User successfully updated' }
        format.js
      else
        format.html { redirect_to restaurant_accounts_path(@restaurant,:id=>@account.id), notice: 'User successfully updated' }
        format.js
      end
    end
  end

  def destroy
    @restaurant=Location.find(params[:restaurant_id])
    @delete_account = User.find(params[:id])
    @account = User.new
    respond_to do |format|
      if @restaurant.user_ids.include?(@delete_account.id)
        @restaurant.users.delete(@delete_account)
        format.html { redirect_to restaurant_accounts_path(@restaurant),notice: "User removed successfully" }
        format.js
      else
        format.html{ redirect_to restaurant_accounts_path(@restaurant),notice: "An Error Occurred!"}
        format.js
      end
    end

  end

  def new
    @restaurant = Location.find(params[:restaurant_id])
    @account = User.new
  end

  def index
    if !current_user.restaurant_manager? && !current_user.role?(CASHIER_ROLE)
      @customer = BraintreeRails::Customer.find(current_user.customer_id) unless current_user.nil?
    end

    @location_form = Location.new
    @user = current_user
    @search_results = Braintree::Transaction.search do |search|
      search.customer_id.is "#{current_user.customer_id}"
    end
    @dates = []
    @search_results.each do |s|
      @dates << s.created_at.strftime("%m/%Y")
    end
    @dates = @dates.uniq
    # @info = Info.new
    @user_avatar = UserAvatar.where('user_id=?',current_user.id).order('id ASC').last
    @subscriptions = SubscriptionFetcher.new(current_user.subscriptions.map(&:subscription_id), no_stats: true).subscriptions
    packages = PackageFetcher.new(no_stats: true)
    @packages = packages.list_enabled.reject {|p| current_user.restaurants.count == current_user.subscriptions.where(plan_id: p[:id]).count }
  end

  def export_pdf
    @customer = BraintreeRails::Customer.find(current_user.customer_id)
    month = params[:month].split('_')
    @search_results = Braintree::Transaction.search do |search|
      search.customer_id.is "#{current_user.customer_id}"
    end
    @result = []
    #check search result
    unless @search_results.nil?
      @search_results.each do |search|
        month.each do |m|
          if (m == search.created_at.strftime("%m/%Y"))
            @result << search
          end
        end
      end
      @result = @result.uniq
      require 'prawn'
      Prawn::Document.generate('Transaction_Record_' + DateTime.now.strftime("%Y_%m_%d")+'.pdf') do |pdf|
        cells =[]
        cells << [Prawn::Table::Cell::Text.make( pdf, "ID",
                                                 :background_color => "#FFFF33", :width => 60),
                  Prawn::Table::Cell::Text.make( pdf, "Transaction Date", :background_color => "#FFFF33", :width => 80),
                  Prawn::Table::Cell::Text.make( pdf, "Type", :background_color => "#FFFF33", :width => 40),
                  Prawn::Table::Cell::Text.make( pdf, "Status", :background_color => "#FFFF33",:width => 120),
                  Prawn::Table::Cell::Text.make( pdf, "Payment Information", :background_color => "#FFFF33"),
                  Prawn::Table::Cell::Text.make( pdf, "Amount", :background_color => "#FFFF33")]
        i = 1
        @result.each do |s|
          cells << [Prawn::Table::Cell::Text.new( pdf, [i,0], :content => s.id),
                    s.created_at.strftime("%Y-%m-%d "),
                    s.type, s.status,
                    s.credit_card_details.bin + "******" \
                    + s.credit_card_details.last_4,
                    s.amount]
          i = i+1
        end
        table_data = cells
        pdf.table(table_data,:width => 500)
      end
      send_file('Transaction_Record_'+DateTime.now.strftime("%Y_%m_%d")+'.pdf')
    end
  end

  def build_error_msg(format, format_range)
    message = "^#{self.credit_card_type} card must start with #{format.join(', ')}"
    unless format_range.nil?
      message += " or in range "
      array_range = []
      format_range.each do |f|
        array_range << "#{f[:from]} - #{f[:to]}"
      end
      message += array_range.join(', ')
    end
    message
  end

  def change_password
    @user_data = UserBilling.new
    @user = User.where("token = ?", params[:token])
    @result = false
    if @user.length > 0
      @user_id = @user[0].id
      @result=true
    end
  end

  def update_password
    @user = User.find(params[:user_id])
    if @user.present? and params[:billing_password].present? and params[:billing_password]==params[:billing_cpassword]
      @user_billing = UserBilling.find(@user.user_billing.id)
      @user_billing.update_attribute(:billing_password, params[:billing_password])
      redirect_to accounts_path, :notice => 'Billing login information is updated successfully.'
    else
      redirect_to change_password_accounts_path + "?token="+@user.token, :notice => 'Password does not match or empty.'
    end
  end

  def reset_password
    @user_data = UserBilling.where("billing_email = ? AND user_id=?", params[:email], params[:user_id])
    if @user_data.present?
      @user = User.find(@user_data[0].user_id)
      @resource = root_url + change_password_accounts_path + "?token=" + @user.token
      UserMailer.send_billing_reset_password_email(params[:email], @resource).deliver
      render :text=> "success"
    else
      render :text=> "fail"
    end
  end

  def create_login_billing
    @user_billing = UserBilling.new
  end

  def new_login_billing
    @user_billing = UserBilling.new
    @user_data = UserBilling.where("billing_email = ? AND billing_password = ? AND user_id=?", params[:billing_email], params[:billing_password], current_user.id)
    
    @user_billing = UserBilling.new
    @result=false
    if params[:billing_password] == params[:billing_cpassword]
      @user_billing["billing_email"] = params[:billing_email]
      @user_billing["billing_password"] = params[:billing_password]
      @user_billing["user_id"] = current_user.id
      if @user_billing.save
        @result = true

        @customer = BraintreeRails::Customer.find(current_user.customer_id)
        @search_results = Braintree::Transaction.search do |search|
          search.customer_id.is "#{current_user.customer_id}"
        end
        @dates = []
        @search_results.each do |s|
          @dates << s.created_at.strftime("%m/%Y")
        end
        @dates = @dates.uniq
      end
    end
    respond_to do |format|
       format.js
    end
  end

  def login_billing
    @user_billing = UserBilling.new
  end

  def check_login_billing

    @user_billing = UserBilling.new
    @user_data = UserBilling.where("billing_email = ? AND billing_password = ? AND user_id=?", params[:billing_email], params[:billing_password], current_user.id)
    @result = false
    if @user_data.present?
      @result = true
      @customer = BraintreeRails::Customer.find(current_user.customer_id)
      @search_results = Braintree::Transaction.search do |search|
        search.customer_id.is "#{current_user.customer_id}"
      end
      @dates = []
      @search_results.each do |s|
        @dates << s.created_at.strftime("%m/%Y")
      end
      @dates = @dates.uniq
    end

    respond_to do |format|
       format.js
    end
  end

  def edit_billing
    @customer = BraintreeRails::Customer.find(current_user.customer_id)
    @search_results = Braintree::Transaction.search do |search|
      search.customer_id.is "#{current_user.customer_id}"
    end
    @dates = []
    @search_results.each do |s|
      @dates << s.created_at.strftime("%m/%Y")
    end
    @dates = @dates.uniq
  end

  def edit
  end

  def update_billing
    @customer_token = BraintreeRails::Customer.find(current_user.customer_id)
    if params[:customer][:credit_cards][:number] != ""
      @result = Braintree::CreditCard.update(
        "#{@customer_token.credit_cards[0].token}",
        #:card_type => "Mastercard",
        :cardholder_name => "#{params[:customer][:credit_cards][:cardholder_name]}",
        :number => "#{params[:customer][:credit_cards][:number]}",
        :expiration_month => "#{params[:customer][:credit_cards][:expiration_month]}",
        :expiration_year => "#{params[:customer][:credit_cards][:expiration_year]}",
        :cvv =>"#{params[:customer][:credit_cards][:cvv]}",
        :billing_address => {
          :locality => "#{params[:customer][:credit_cards][:billing_address][:locality]}",
          :extended_address => "#{params[:customer][:credit_cards][:billing_address][:extended_address]}",
          :region => "#{params[:customer][:credit_cards][:billing_address][:region]}",
          :country_name => "#{params[:customer][:credit_cards][:billing_address][:country_name]}",
          :postal_code => "#{params[:customer][:credit_cards][:billing_address][:postal_code]}",
        }
      )
    else
       @result = Braintree::CreditCard.update(
        "#{@customer_token.credit_cards[0].token}",
        :cardholder_name => "#{params[:customer][:credit_cards][:cardholder_name]}",
        :expiration_month => "#{params[:customer][:credit_cards][:expiration_month]}",
        :expiration_year => "#{params[:customer][:credit_cards][:expiration_year]}",
        :cvv =>"#{params[:customer][:credit_cards][:cvv]}",
        :billing_address => {
          :locality => "#{params[:customer][:credit_cards][:billing_address][:locality]}",
          :extended_address => "#{params[:customer][:credit_cards][:billing_address][:extended_address]}",
          :region => "#{params[:customer][:credit_cards][:billing_address][:region]}",
          :country_name => "#{params[:customer][:credit_cards][:billing_address][:country_name]}",
          :postal_code => "#{params[:customer][:credit_cards][:billing_address][:postal_code]}",
        }
      )
    end
    @search_results = Braintree::Transaction.search do |search|
      search.customer_id.is "#{current_user.customer_id}"
    end
    @dates = []
    @search_results.each do |s|
      @dates << s.created_at.strftime("%m/%Y")
    end
    @dates = @dates.uniq
    @customer = BraintreeRails::Customer.find(current_user.customer_id)
     respond_to do |format|
        format.js
     end
  end

  def update_address
    # params[:user][:email_profile] = current_user.email_profile
    # Assign data to pass validation
    if  params[:user][:username] == current_user.username
      params[:user][:skip_username_validation] = 1
    end
    params[:user][:email] = params[:user][:email_confirmation] = current_user.email
    params[:user][:credit_card_type] = VISA
    params[:user][:credit_card_number] = '4111111111111111'
    params[:user][:credit_card_holder_name] = 'test'
    params[:user][:credit_card_expiration_date] = '12/12'
    params[:user][:credit_card_cvv] = '123'
    params[:user][:billing_address] = 'Address'
    params[:user][:billing_zip] = '12345'
    params[:user][:skip_zip_validation] = 1
    # params[:user][:skip_username_validation] = 1

    # full_name = params[:user][:full_name]
    # params[:user][:first_name] = full_name.split(" ")[0..-2].join(" ")
    # params[:user][:last_name] = full_name.split(" ").last
    @user_old = current_user.dup
    @user_old.profile = current_user.profile.dup
    respond_to do |format|
      if current_user.update_attributes(params[:user])
        format.js
      else
        format.js
      end
    end
  end

  def canel_address

  end

  def canel_billing
    @customer = BraintreeRails::Customer.find(current_user.customer_id)
    @search_results = Braintree::Transaction.search do |search|
      search.customer_id.is "#{current_user.customer_id}"
    end
    @dates = []
    @search_results.each do |s|
      @dates << s.created_at.strftime("%m/%Y")
    end
    @dates = @dates.uniq
  end

  def edit_package
    @locations = []
  end

  def canel_package
  end

  def update_package
    @locations = []
    user = params[:user]
    agree = user[:agree]
    @check = false
    @old_app_service_id = current_user.app_service_id
    old_subscription_id = current_user.subscription_id
    @new_app_service_id = user[:app_service_id]
    @locations_count = Location.unscoped.where('owner_id=?', current_user.id).count


    package =''
    if @old_app_service_id.to_i == 2
      package = 'Deluxe'
    elsif @old_app_service_id.to_i == 3
      package = 'Premium'
    end

    respond_to do |format|
        if agree == "1"

          if @new_app_service_id.to_i > @old_app_service_id.to_i && @new_app_service_id.to_i != 2\
           || @new_app_service_id.to_i == 2 && @locations_count.to_i == 1 \
           || @new_app_service_id.to_i == 1 && @locations_count.to_i == 1
            @check = true

            #delete email manager
            if @new_app_service_id.to_i == 1
              location = Location.find_by_owner_id(current_user.id)

              rsr_manager = current_user.id.to_s + ','
              user_manager = User.find_by_id(location.rsr_manager.split(",").first)
              if !user_manager.nil?
                unless user_manager.id == current_user.id
                  user_manager.destroy
                end
              end
              UserMailer.send_delete_manager_info(current_user, package, location.name).deliver

              location.update_attribute(:rsr_manager, rsr_manager) if !location.nil?
            end
            # end delete manager

            if @new_app_service_id.to_i > @old_app_service_id.to_i && @old_app_service_id == 1
              # location = Location.find_by_owner_id(current_user.id)
              # manager = current_user.create_manager_account_with_location(location.id)
              # UserMailer.send_manager_info(manager, current_user.email_profile, location).deliver
            # elsif @new_app_service_id < @old_app_service_id && @new_app_service_id == 1
            #   location.rsr_manager
            end

            if current_user.update_attribute(:app_service_id, user[:app_service_id])
              locations = Location.unscoped.where('owner_id=?', current_user.id)

              locations.update_all(:active => true)
              current_user.user_update_package(old_subscription_id, @new_app_service_id)
              format.js
              # if @new_app_service_id == "2"
              #   format.js {render :js => "window.location.href='"+ accounts_path+"'", notice: 'BYTE Package is updated successfully.'}
              # else
              #   format.js
              # end
            else
                format.js
            end
          else
            @check = true
            format.js
          end
        else
          current_user.app_service_id = @new_app_service_id
          format.js
        end
    end
  end

  def activate_service
    respond_to do |format|
      if current_user.update_attribute(:active_braintree, 1)
        if UserMailer.send_email_activate(current_user.email).deliver
           format.js {render :js => "window.location.href='"+ accounts_url+"'"}
          #format.js
        else
           format.js {render :js => "window.location.href='"+ accounts_url+"'"}
          #format.js
        end
      else
         format.js {render :js => "window.location.href='"+ accounts_url+"'"}
        #format.js
      end
    end
  end

  def cancel_service
    respond_to do |format|
      if current_user.update_attribute(:active_braintree, 0)
        if UserMailer.send_email_cancel_service(current_user.email).deliver
          #format.js
          format.js {render :js => "window.location.href='"+ accounts_url+"'"}
        else
           format.js {render :js => "window.location.href='"+ accounts_url+"'"}
          #format.js
        end
      else
         format.js {render :js => "window.location.href='"+ accounts_url+"'"}
        #format.js
      end
    end
  end

  def create_roles
    #if !current_user.limit_available?
      @info = Info.new(params[:info])
      @info_avatar_delete = InfoAvatar.where('info_token = ?', @info.token).last
      @info.info_avatar = @info_avatar_delete
      @location_ids = params[:locations]
      respond_to do |format|
        if @location_ids.nil? || @location_ids.blank? || @location_ids.empty?
          @info = Info.new
          format.js
        else
          if @info.save
            # Validate locations
            InfoAvatar.destroy_all(['info_token = ? AND id != ?', @info.token, @info_avatar_delete.id]) if not @info_avatar.nil?
            locations = Location.where('id IN (?)', params[:locations])
            locations.update_all(info_id: @info.id)
            format.js
          else
            format.js
          end
        end
      end
    #else
     # redirect_to accounts_path, :notice => 'Accounts limitted'
    #end
  end

  def delete_user_manager
    @info = Info.find(params[:id])
    @info_avatar = @info.build_info_avatar
    locations_array = Location.where('info_id IN (?)', params[:id])
    info_avatar = InfoAvatar.where(info_token: @info.token)
    respond_to do |format|
      if locations_array.update_all(info_id: 0) && @info.destroy
        if !info_avatar.empty?
          info_avatar.each do |i|
            i.destroy
          end
        end
        format.js
      else
        format.js
      end
    end
  end

  def edit_roles
    @info = Info.find(params[:format])
    @info_avatar = InfoAvatar.where('info_token = ? and info_id=?', @info.token,@info.id).last
    if !@info_avatar.nil?
      @info.info_avatar = @info_avatar
    else
      @info_avatar = @info.build_info_avatar
    end
  end

  def cancel_roles
    @info = Info.new
    @info_avatar = InfoAvatar.new
  end

  def update_roles
    info_array = []
    info_array_new = []
    location_ids_old = []
    location_id = []
    @info = Info.find(params[:info][:id])

    location_id = Location.where("info_id=?", params[:info][:id]).order('id DESC')
    location_id.each do |l|
      location_ids_old << l.id
    end
    info_array << @info.name
    info_array << @info.email
    info_array << @info.phone
    info_array << location_ids_old
    info_array << @info.info_avatar
    @info_old = info_array.dup

    location_new = []
    location_params = params[:locations]
    if !location_params.nil?
      location_params.each do |l|
        location_new << l.to_i
      end
    end
    info_array_new << params[:info][:name]
    info_array_new << params[:info][:email]
    info_array_new << params[:info][:phone]
    info_array_new << location_new
    @info_new  = info_array_new.dup

    @info_avatar = InfoAvatar.where('info_token = ?', @info.token).last
    @info.info_avatar = @info_avatar if not @info_avatar.nil?
    old_location_ids = @info.locations.map(&:id)
    @info_id = params[:info][:id]
    respond_to do |format|
      if location_params.nil?
         # Remove old locations assigned
        locations = Location.where('id IN (?)', old_location_ids)
        locations.update_all(:info_id => nil)
        InfoAvatar.delete_all("info_id=#{@info_id}")
        @info.destroy
        @info_avatar = InfoAvatar.new
        format.js
      else
        if @info.update_attributes(params[:info])
          info_array_new << @info.info_avatar
          @info_new  = info_array_new.dup
          location_ids = params[:locations]
          # Remove old locations assigned
          locations = Location.where('id IN (?)', old_location_ids)
          locations.update_all(:info_id => nil)
          # Update new locations assigned
          locations_update = Location.where('id IN (?)', location_ids)
          locations_update.update_all(:info_id => @info_id)
          @info_avatar = InfoAvatar.new
          format.js
        end
      end
    end
  end

  def set_user_avatar
    @user = User.where(id: params[:user][:id]).first
    @user.update_attribute(:avatar_id, params[:user][:avatar_id])
    respond_to do |format|
      format.js
    end
  end

  def upload_info_avatar
    if params[:user_avatar][:crop_x].to_i == 0 && params[:user_avatar][:crop_y].to_i == 0 \
        && params[:user_avatar][:crop_w].to_i == 0 and params[:user_avatar][:crop_h].to_i == 0
      @user_avatar = UserAvatar.where('user_token = ? AND user_id = ?', params[:user_avatar][:user_token], current_user.id).first
    else
      @user_avatar_old = UserAvatar.where('user_token = ?', params[:user_avatar][:user_token]).last
      if @user_avatar_old.nil?
        @user_avatar = @user_avatar_old
      else
        @user_avatar = @user_avatar_old.dup
        @user_avatar.image = @user_avatar_old.image
        @user_avatar.user_id = current_user.id
      end
    end
    if @user_avatar.nil?
      @user_avatar = UserAvatar.new
    end
    if !params[:user_avatar][:image].nil?
      array_logo = params[:user_avatar][:image].original_filename.split('.').last
      params[:user_avatar][:image].original_filename = "#{DateTime.now.strftime("%Y_%m_%d_%H_%M_%S")}" + "." + array_logo.to_s
    end
    @user_avatar.user_id = current_user.id
    @user_avatar.image = params[:user_avatar][:image]
    @user_avatar.user_token = params[:user_avatar][:user_token]
    @user_avatar.crop_x = params[:user_avatar][:crop_x]
    @user_avatar.crop_y = params[:user_avatar][:crop_y]
    @user_avatar.crop_w = params[:user_avatar][:crop_w]
    @user_avatar.crop_h = params[:user_avatar][:crop_h]
    @user_avatar.rate = params[:user_avatar][:rate]
    respond_to do |format|
      @user_avatar.save
      @user_avatar_delete = UserAvatar.where('user_id=?',current_user.id).order('id DESC').last
      count = UserAvatar.where('user_id=?',current_user.id).order('id DESC').count
      if count > 1 && !@user_avatar_delete.nil?
        @user_avatar_delete.destroy
      end
      format.js
    end
  end

  def view_restaurant
    @new_app_service_id = params[:new_app_service_id]
    @locations = Location.unscoped.where("owner_id=?",current_user.id)
    respond_to do |format|
      format.js
    end
  end

  def update_restaurant_acitve
    location_ids = []
    old_subscription_id = current_user.subscription_id
    old_app_service_id = current_user.app_service_id
    @new_app_service_id = params[:new_app_service_id].to_i



    package =''
    if old_app_service_id == 2
      package = 'Deluxe'
    elsif old_app_service_id == 3
      package = 'Premium'
    end

    old_location_ids = Location.unscoped.where("owner_id=?",current_user.id).map(&:id)
    unless params[:locations_array].nil?
      params[:locations_array].each do |c|
        location_ids << c.to_i
      end
    end

    respond_to do |format|
      if !location_ids.nil?

        if @new_app_service_id == 1
          location = Location.find_by_id(location_ids[0])
          rsr_manager = current_user.id.to_s + ','
          user_manager = User.find_by_id(location.rsr_manager.split(",").first)
          if !user_manager.nil?
            unless user_manager.id == current_user.id
              user_manager.destroy
            end
          end
          # UserMailer.send_delete_manager_info(current_user, package, location.name).deliver

          location.update_attribute(:rsr_manager, rsr_manager) if !location.nil?
        end

        if current_user.update_attribute(:app_service_id, params[:new_app_service_id])
          locations = Location.unscoped.where('id IN (?)', old_location_ids - location_ids)
          locations.update_all(:active => false)
          locations_new = Location.unscoped.where('id IN (?)', location_ids)
          locations_new.update_all(:active => true)
          current_user.user_update_package(old_subscription_id, @new_app_service_id)
          format.js {render :js => "window.location.href='"+ accounts_url+"'", notice: 'BYTE Package is updated successfully.'}
          # format.html { redirect_to accounts_path}
          # format.js
        else
          format.html { redirect_to accounts_url}
          # format.js
        end
      else
        format.html { redirect_to accounts_url}
        # format.js
      end
    end
  end

  def rotate_info
    info_image_id = params[:logo].to_i
    @user_avatar = UserAvatar.find_by_id(info_image_id)
    unless @user_avatar.nil?
      @user_avatar.rotate
    end
    respond_to do |format|
      format.js#html { redirect_to restaurants_path ,:notice=> 'Restaurant was deleted successfully.'}
    end
  end
end
