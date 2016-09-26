class PasswordsController < Devise::PasswordsController

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    errors_ignore = [:credit_card_type, :credit_card_number, :credit_card_holder_name, :credit_card_expiration_date,
      :credit_card_cvv, :billing_zip, :billing_address, :email, :username, :zip, :first_name, :last_name, :address, :city, :state, :phone]
    resource.errors.each do |attr,msg|
      if errors_ignore.include?(attr)
        resource.errors.delete(attr)
      end
    end
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      resource.reset_password_token = resource.reset_password_sent_at = nil
      resource.reset_authentication_token! if resource.role == USER_ROLE && resource.is_register == 0
      if resource.role != USER_ROLE
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      else
        flash_message = :updated_not_active
      end
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      if resource.role != USER_ROLE
        respond_with resource, :location => after_sign_in_path_for(resource)
      else
        sign_out resource
        # redirect_to root_url
        redirect_to "http://mybyteapp.com"
      end
    else
      respond_with resource
    end
  end
end
