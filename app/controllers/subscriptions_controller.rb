class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  def create
    flash[:error] = []
    location_ids = params[:locations_ids].map(&:to_i) if params[:locations_ids].present?
    unless location_ids.present?
      flash[:error] = 'No locations were chosen'
      return render 'shared/redirect_current_or_root'
    end

    if current_user.subscriptions.detect { |s| location_ids.include?(s.location_id) && params[:plan_id] == s.plan_id }
      flash[:error] = 'Subscription already exists for some of the locations'
      return render 'create'
    end

    location_ids.each do |id|
      location = Location.find(id)
      if params[:plan_id] == BYTE_PLANS[:order_and_pay]  && !location.try(:customer_id).present?
        flash[:error] << "In order to enable Order and Pay for location: #{location.name}, please create a Sub Merchant Braintree Account under the Advance App Settings tab"
        next
      end
      subscription = current_user.subscriptions.new(plan_id: params[:plan_id], plan_name: params[:plan_name], location_id: id)
      creator = SubscriptionCreator.new(plan_id: params[:plan_id], member_id: current_user.customer_id).subscription
      if creator.instance_of?(Braintree::ErrorResult)
        flash[:error] = 'Transaction was not able to process. Please update your billing to continue'
      else
        unless subscription.valid? && creator.present?
          flash[:error] = 'Errors during some subscription creation'
        else
          subscription.subscription_id = creator.subscription.id
          subscription.save!
        end
      end
    end
    flash[:success] = 'Subscription is successfully taken' unless flash[:error].present?
  end

  def destroy
    subscription = Subscription.where(subscription_id: params[:id]).first
    if subscription.present? && cancel_subscription(params[:id]).success?
      subscription.destroy
      flash[:success] = 'You have successfully removed the subscription'
    else
      flash[:error] = 'Error during subscription cancellation'
    end

    render 'shared/redirect_current_or_root'
  end

  def byte_package
    subscription = byte_subscription
    if subscription.present? && subscription.status != 'Canceled'
      if cancel_subscription(subscription.id).success?
        current_user.update_attribute(:is_suspended, true)
        current_user.update_attribute(:has_byte, false)
        flash[:success] = 'You have successfully removed BYTE subscription'
      else
        flash[:error] = 'Error during BYTE subscription cancellation'
      end
    else
      if SubscriptionCreator.new(plan_id: BYTE_PLANS[:byte],
                                 member_id: current_user.customer_id).subscription.present?
        current_user.update_attribute(:is_suspended, false)
        current_user.update_attribute(:has_byte, true)
        flash[:success] = 'You have successfully subscribed to BYTE subscription'
      else
        flash[:error] = 'Error during BYTE subscription procedure'
      end
    end
    render 'shared/redirect_current_or_root'
  end

  private

  def byte_subscription
    res =
      begin
        sub = Braintree::Subscription.search { |search| search.plan_id.is BYTE_PLANS[:byte] }
        sub.detect { |s| s.status != 'Canceled' && s.transactions.first.customer_details.id == current_user.customer_id }
      rescue Braintree::AuthenticationError,
         Braintree::AuthorizationError,
         Braintree::ConfigurationError,
         Braintree::DownForMaintenanceError,
         Braintree::ForgedQueryString,
         Braintree::InvalidSignature,
         Braintree::NotFoundError,
         Braintree::ServerError,
         Braintree::SSLCertificateError,
         Braintree::UnexpectedError,
         Braintree::UpgradeRequiredError,
         Braintree::ValidationsFailed,
         Braintree::ServerError,
         Braintree::SSLCertificateError,
         Braintree::UnexpectedError
      end
  end

  def cancel_subscription(id)
    begin
      Braintree::Subscription.cancel id
    rescue Braintree::AuthenticationError,
       Braintree::AuthorizationError,
       Braintree::ConfigurationError,
       Braintree::DownForMaintenanceError,
       Braintree::ForgedQueryString,
       Braintree::InvalidSignature,
       Braintree::NotFoundError,
       Braintree::ServerError,
       Braintree::SSLCertificateError,
       Braintree::UnexpectedError,
       Braintree::UpgradeRequiredError,
       Braintree::ValidationsFailed,
       Braintree::ServerError,
       Braintree::SSLCertificateError,
       Braintree::UnexpectedError
    end
  end
end
