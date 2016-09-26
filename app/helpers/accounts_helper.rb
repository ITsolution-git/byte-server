module AccountsHelper
	def get_active(active_braintree)
	  active = 'Inactive'
	  if active_braintree
      active = 'Active'
	  end
	  return active
	end

  def get_date(user)
    return user.created_at.strftime("%d.%m.%Y")
  end

  def get_primary_contact(user)
    first_name = ''
    first_name = (user.first_name.to_s + ' ') unless user.first_name.nil?
    return first_name + ' ' + user.last_name.to_s
  end

  def get_app_service_id
    return current_user.app_service_id
  end

  def get_plans_braintree
     @plans = BraintreeRails::Plan.all
  end

  def get_account_number(number)
    return "%.06d" % number
  end
  
  # def get_start_year
  #   return Time.now.year
  # end

  # def get_end_year
  #   return Time.now.year + 200
  # end
  
  # def get_credit_card_number
  #   return @customer.credit_cards.first.number
  # end

  # def get_credit_card_date
  #   return  @customer.credit_cards.first.expiration_date.strftime("%m.%Y")
  # end

  def get_credit_card_type(credit_card)
    if credit_card.try(:card_type) == VISA
      return 1
    # elsif credit_card.card_type == MASTERCARD
    elsif credit_card.try(:card_type) == 'MasterCard'
      return 2
    elsif credit_card.try(:card_type) == AMERICAN_EXPRESS
      return 3
    elsif credit_card.try(:card_type) == DISCOVER
      return 4
    end
  end
  def setup_info(info, owner_id)
    Location.where(:owner_id => owner_id).each do |location|
      info.locations.build
    end
    return info
  end
end
