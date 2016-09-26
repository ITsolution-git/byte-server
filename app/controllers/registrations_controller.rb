class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_no_authentication, :only => [:new, :create, :setup_account]
  before_filter :go_to_dashboard_if_signed_in, :except => [:deactive_account, :reactive_account, :update, :new, :create, :setup_account, :create_cashier]
  before_filter :go_to_login_page_unless_signed_in, :only => [:deactive_account, :reactive_account]

  # GET /services
  def index
    @plans = BraintreeRails::Plan.all
    resource = build_resource({})
    respond_with resource
  end

  # GET /service/:id
  def service
    begin
      app_service = AppService.find_or_create_by_name(params[:id])
      session[:app_service_id] = app_service.id
      return redirect_to new_user_registration_url
    rescue
      return redirect_to index_user_registration_path
    end
  end

  # GET /register
  def new
    if session[:app_service_id].nil?
      return redirect_to index_user_registration_path
    end
    if params[:fromstep2] == 'true' || session[:new_user_id]
      self.resource = User.find(session[:new_user_id])
      @fromstep2 = params[:fromstep2]
    else
      resource = build_resource({})
      resource.app_service_id = session[:app_service_id]
      resource.restaurants.build.country = 'United States'
      resource.billing_country = 'United States'
      resource.billing_country_code = 'US'
    end

    return respond_with(resource)
  end

  def create_cashier
    resource = User.new
    resource.employer_id = params["user"]["employer_id"]
    resource.first_name = params["user"]["first_name"]
    resource.last_name = params["user"]["last_name"]
    resource.username = params["user"]["username"]
    resource.zip = params["user"]["zip"]
    resource.email = params["user"]["email"]
    resource.restaurant_type = "restaurant"
    resource.password = params["user"]["password"]
    resource.password_confirmation = params["user"]["password_confirmation"]
    resource.role = CASHIER_ROLE
    if resource.save
      flash[:notice] = 'You have created a new cashier!'
    else
      flash[:error] = resource.errors.full_messages
    end
    redirect_to :back
  end

  # POST /
  def create
    if session[:app_service_id].nil?
      return redirect_to index_user_registration_path
    end
    resource = build_resource

    if resource.agree == '1'
      if (params[:fromstep2] == "true" || session[:new_user_id])
        resource = User.find(session[:new_user_id])
        session[:temp_pwd] = params[:user][:password]

        if resource.update_attributes(params[:user])
          redirect_to user_steps_path
        else
          render :new
        end
      else
        if resource.save
          session[:new_user_id] = resource.id
          session[:temp_pwd] = params[:user][:password]
          redirect_to user_steps_path
        else
          render :new
        end
      end

    else
      clean_security_fields resource
      set_flash_message :alert, :agree_message
      return render :new
    end
  end

##
    # resource.skip_zip_validation = params[:user][:skip_zip_validation].to_i
    # if resource.agree == '1'
    #   if resource.restaurants.length == 0
    #     return render :new
    #   else
    #     if !session["move_location_id"].blank?
    #       location = Location.find(session["move_location_id"])
    #       resource.password = params["user"]["password"]
    #       resource.password_confirmation = params["user"]["password_confirmation"]
    #     else
    #       location = resource.restaurants[0]
    #       resource.password = "123456"
    #     end

    #     # Hack default value to pass validation
    #     resource.role = OWNER_ROLE

    #     if resource.autofill == '1'
    #       resource.billing_address = params[:user][:billing_address] = location.address
    #       resource.billing_city = params[:user][:billing_city] = location.city
    #       resource.billing_state = params[:user][:billing_state] = location.state
    #       resource.billing_zip = params[:user][:billing_zip] = location.zip
    #       resource.billing_country = params[:user][:billing_country] = location.country
    #       resource.billing_country_code = params[:user][:billing_country_code] = params[:restaurant_country_code]
    #     end

    #     flash[:alert] = nil

    #     # TODO: need validation and checking restaurant errors

    #     if resource.valid?
    #       begin
    #         @plan = AppService.find_plan(session[:app_service_id])
    #         params[:user][:has_byte] = true if @plan.id == BYTE_PLANS[:byte]
    #       rescue Exception => e
    #         @plan = nil
    #       end
    #       begin
    #         @setup_fee = BraintreeRails::AddOn.find(ADD_ON[:setup_fee])
    #       rescue Exception => e
    #         @setup_fee = nil
    #       end

    #       session[:user_params] = params[:user].to_json

    #       render 'confirmation'
    #     else
    #       clean_security_fields resource
    #       return render :new
    #     end

    #   end
    # else
    #   clean_security_fields resource
    #   set_flash_message :alert, :agree_message
    #   return render :new
    # end
  # end


  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource_params[:email] = resource_params[:email_confirmation] = current_user.email
    resource_params[:username] = current_user.username

    resource_params[:skip_zip_validation] = 1
    resource_params[:skip_username_validation] = 1
    resource_params[:skip_first_name_validation] = 1
    resource_params[:skip_last_name_validation] = 1

    # Assign data to pass validation
    resource_params[:credit_card_type] = VISA
    resource_params[:credit_card_number] = '4111111111111111'
    resource_params[:credit_card_holder_name] = 'test'
    resource_params[:credit_card_expiration_date] = '12/12'
    resource_params[:credit_card_cvv] = '123'
    resource_params[:billing_address] = 'Address'
    resource_params[:billing_zip] = '12345'

    if resource.update_with_password(resource_params)
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      else
        set_flash_message :notice, 'Your password was changed successfully.'
      end

      if resource.sign_in_count == 1
        # sign_out current_user
        sign_in resource_name, resource, :bypass => true
        respond_with resource, :location => restaurants_path
      else
        sign_out current_user
        respond_with resource, :location => after_sign_out_path_for(resource)
      end

      # sign_in resource_name, resource, :bypass => true
      # respond_with resource, :location => restaurants_path
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  # POST /register/setup
  def setup_account
    if session[:user_params].nil?
      return redirect_to root_path
    end

    user_params = ActiveSupport::JSON.decode(session[:user_params])
    resource = build_resource({})
    resource.username = user_params['username']
    resource.first_name = user_params['first_name']
    resource.last_name = user_params['last_name']
    resource.phone = user_params['phone']
    resource.email = resource.email_confirmation = user_params['email']
    resource.password_bak = (!session["move_location_id"].blank? ? user_params["password"] : resource.generate_password(8))
    resource.app_service_id = user_params['app_service_id']
    resource.credit_card_type = user_params['credit_card_type']
    resource.credit_card_number = user_params['credit_card_number']
    resource.credit_card_holder_name = user_params['credit_card_holder_name']
    resource.credit_card_expiration_date = user_params['credit_card_expiration_date']
    resource.credit_card_cvv = user_params['credit_card_cvv']
    resource.billing_address = user_params['billing_address']
    resource.billing_country = user_params['billing_country']
    resource.billing_country_code = user_params['billing_country_code']
    resource.billing_state = user_params['billing_state']
    resource.billing_city = user_params['billing_city']
    resource.billing_zip = user_params['billing_zip']
    resource.has_byte = user_params['has_byte']

    resource.restaurants[0] = Location.new

    if !session["move_location_id"].blank?
      resource.password = user_params["password"]
      resource.password_confirmation = user_params["password_confirmation"]
    end
    resource.restaurants[0].name = user_params['restaurants_attributes']['0']['name']
    resource.restaurants[0].chain_name = user_params['restaurants_attributes']['0']['chain_name']
    resource.restaurants[0].address = user_params['restaurants_attributes']['0']['address']
    resource.restaurants[0].country = user_params['restaurants_attributes']['0']['country']
    resource.restaurants[0].state = user_params['restaurants_attributes']['0']['state']
    resource.restaurants[0].city = user_params['restaurants_attributes']['0']['city']
    resource.restaurants[0].zip = user_params['restaurants_attributes']['0']['zip']

    resource.restaurants[0].primary_cuisine = user_params['restaurants_attributes']['0']['primary_cuisine']
    resource.restaurants[0].secondary_cuisine = user_params['restaurants_attributes']['0']['secondary_cuisine']

    resource.active_braintree = true
    resource.skip_zip_validation = 1

    customer_info = {
      :first_name => resource.first_name,
      :last_name => resource.last_name,
      :email => resource.email,
      :phone => resource.phone
    }

    credit_card_info = {
      :number => resource.credit_card_number,
      :cardholder_name => resource.credit_card_holder_name,
      :cvv => resource.credit_card_cvv,
      :expiration_date => resource.credit_card_expiration_date,
      :billing_address => {
        :street_address => resource.billing_address,
        :locality => resource.billing_city,
        :country_code_alpha2 => resource.billing_country_code,
        :region => resource.billing_state,
        :postal_code => resource.billing_zip
      }
    }

    session[:user_params] = nil
    @braintree_errors = false

    @customer = BraintreeRails::Customer.new(customer_info)
    if @customer.save
      resource.customer_id = @customer.id
      @credit_card = @customer.credit_cards.build(credit_card_info)
      unless @credit_card.save
        @braintree_errors = true
        BraintreeRails::Customer.delete(@customer.id)
        clean_security_fields resource
        return render :new
      end
    else
      @braintree_errors = true
      clean_security_fields resource
      return render :new
    end

    session[:app_service_id] = nil
    resource.role = OWNER_ROLE

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :setuped if is_navigational_format?
        # sign_up(resource_name, resource)
        return redirect_to new_user_session_path
        # respond_with resource, :location => restaurants_path
      else
        expire_session_data_after_sign_in!
        respond_to do |format|
          format.html
          format.js
        end
      end
    else
      set_flash_message :alert, :expired
      return redirect_to root_path
    end
  end


  # DELETE /deactive-account
  def deactive_account
    unless current_user.subscription_id.nil?
      result = Braintree::Subscription.cancel(current_user.subscription_id)
      if result
        current_user.update_attribute(:active_braintree, false)
        sign_out current_user
      end
    end
  end

  def reactive_account
    unless current_user.active_braintree
      plan = AppService.find_plan(current_user.app_service_id)
      customer = BraintreeRails::Customer.find(current_user.customer_id)
      credit_card = customer.credit_cards[0]
      subscription = plan.subscriptions.build(
        :payment_method_token => credit_card.token
      )
      if subscription.save
        current_user.subscription_id = subscription.id
        current_user.active_braintree = true
        current_user.save(:validate, false)
      end
    end
  end

  private
    def go_to_dashboard_if_signed_in
      if user_signed_in?
        redirect_to restaurants_path
      end
    end

    def go_to_login_page_unless_signed_in
      unless user_signed_in?
        redirect_to new_user_session_path
      end
    end

    def clean_security_fields(resource)
      resource.credit_card_number = resource.credit_card_holder_name = resource.credit_card_expiration_date = resource.credit_card_cvv = nil
      clean_up_passwords resource
    end
end
