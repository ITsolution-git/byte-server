class UserStepsController < ApplicationController
  include Wicked::Wizard
  steps :restaurant_type, :location, :serves, :credit_card

  before_filter :get_resource

  def show
    case step
    when :location
      @resource.restaurants.build if @resource.restaurants.empty?
    when :serves
      @restaurant = @resource.restaurants.first
    end
    render_wizard
  end

  def update
    @resource.skip_zip_validation = 1
    case step
    when :location
      @resource.skip_credit_card_validation = 1
      @resource.update_attributes(params[:user])
    when :serves
      @resource.restaurants.first.skip_primary_cuisine_validation = 0
      @resource.update_attributes(params[:user])
    when :credit_card
      # Hack default value to pass validation
      @resource.active_braintree = true
      @resource.role = OWNER_ROLE
      @resource.skip_credit_card_validation = 0
      location = @resource.restaurants.first
      if params[:user][:autofill] == '1'
        @resource.billing_address = params[:user][:billing_address] = location.address
        @resource.billing_city = params[:user][:billing_city] = location.city
        @resource.billing_state = params[:user][:billing_state] = location.state
        @resource.billing_zip = params[:user][:billing_zip] = location.zip
        @resource.billing_country = params[:user][:billing_country] = location.country
        @resource.billing_country_code = params[:user][:billing_country_code] = params[:restaurant_country_code]
      else
        @resource.billing_address = params[:user][:billing_address]
        @resource.billing_city = params[:user][:billing_city]
        @resource.billing_state = params[:user][:billing_state]
        @resource.billing_zip = params[:user][:billing_zip]
        @resource.billing_country = params[:user][:billing_country]
        @resource.billing_country_code = params[:user][:billing_country_code] = params[:restaurant_country_code]
      end

      flash[:alert] = nil

      create_customer

      if (@braintree_errors)
        render 'user_steps/credit_card'
        return
      end

      if @resource.update_attributes(params[:user])
        session[:new_user_id] = nil
        @resource.password_bak = session[:temp_pwd]
        session[:temp_pwd] = nil
        @resource.create_profile
        @resource.send_confirmation_instructions
        # begin
        #   @plan = AppService.find_plan(session[:app_service_id])
        #   params[:user][:has_byte] = true if @plan.id == BYTE_PLANS[:byte]
        # rescue Exception => e
        #   @plan = nil
        # end
        # begin
        #   @setup_fee = BraintreeRails::AddOn.find(ADD_ON[:setup_fee])
        # rescue Exception => e
        #   @setup_fee = nil
        # end
      end
    else
      @resource.skip_zip_validation = 1
      @resource.skip_credit_card_validation = 1
      @resource.update_attributes(params[:user])

    end

    render_wizard @resource
  end

   # GET /confirmation
  def confirmation

  end

  private

  def get_resource
    @resource = User.find(session[:new_user_id]) if session[:new_user_id]
  end

  def create_customer
    customer_info = {
      :first_name => @resource.first_name,
      :last_name => @resource.last_name,
      :email => @resource.email,
      :phone => @resource.phone
    }

    credit_card_info = {
      :number => params[:user]['credit_card_number'],
      :cardholder_name => params[:user]['credit_card_holder_name'],
      :cvv => params[:user]['credit_card_cvv'],
      :expiration_date => params[:user]['credit_card_expiration_date'],
      :billing_address => {
        :street_address => @resource.billing_address,
        :locality => @resource.billing_city,
        :country_code_alpha2 => @resource.billing_country_code,
        :region => @resource.billing_state,
        :postal_code => @resource.billing_zip
      }
    }

    @customer = BraintreeRails::Customer.new(customer_info)
    if @customer.save
      @credit_card = @customer.credit_cards.build(credit_card_info)
      begin
        unless @credit_card.save
          BraintreeRails::Customer.delete(@customer.id)
          @braintree_errors = @credit_card.errors.full_messages
        end
      rescue
        BraintreeRails::Customer.delete(@customer.id)
        @braintree_errors = ["Credit Card Verification Failed, Please Enter Correct Information"]
      end
      @resource.customer_id = @customer.id
    else
      @braintree_errors = @customer.errors.full_messages
    end
  end

  def clean_security_fields(resource)
    resource.credit_card_number = resource.credit_card_holder_name = resource.credit_card_expiration_date = resource.credit_card_cvv = nil
    clean_up_passwords resource
  end

  def finish_wizard_path
    #user_path(current_user)
    '/user_steps/confirmation'
  end
end
