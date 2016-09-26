class LocationMerchantsController < ApplicationController
  def new

  end
  def create
    location = Location.find(params[:location_id])
    user = location.owner
    user.update_attribute('address', params[:owner_address])
    user.update_attribute('city', params[:owner_city])
    user.update_attribute('state', params[:owner_state])
    user.update_attribute('zip', params[:owner_zip])
    user.reload
    Rails.logger.warn "***HERE #{location.name}"
    if params[:customer_id]
      location.update_attribute 'customer_id', params[:customer_id]
    else
      result = Braintree::MerchantAccount.create(
        :individual => {
          :first_name => location.name.gsub(/[^0-9A-Za-z ]/, '').downcase.tr(" ", "_"),
          :last_name => State.where('name = ? OR state_code = ?', location.owner.state, location.owner.state.upcase).first.state_code,
          :email => location.owner.email,
          :date_of_birth => params[:birthday],
          :address => {
            :street_address => location.owner.address,
            :locality => location.owner.city,
            :region => State.where('name = ? OR state_code = ?', location.owner.state, location.owner.state.upcase).first.state_code,
            :postal_code => location.owner.zip
          }
        },
        :business => {
          #:legal_name => location.name,
          #:dba_name => location.name,
          #:tax_id => params[:tax_id],
          :address => {
            :street_address => location.address,
            :locality => location.city,
            :region => State.where(name: location.state).first.state_code,
            :postal_code => location.zip,
          }
        },
        :funding => {
          :destination => Braintree::MerchantAccount::FundingDestination::Bank,
          :account_number => params[:account_number],
          :routing_number => params[:routing_number]
        },
        :tos_accepted => true,
        :master_merchant_account_id => Figaro.env.braintree_master_merchant_account_id
      )
      Rails.logger.warn "***HERE #{result.inspect}"
      if result.class == Braintree::ErrorResult
        render json: {status: 'failed', error: result.errors}
        return
      else
        location.update_attribute 'customer_id', result.merchant_account.id
      end
    end
    respond_to do |format|
      format.html {redirect_to url_for(:controller => :accounts, :action => :index)}
      format.json {render json: {status: 'success'}, status: :ok}
    end
  end
end
