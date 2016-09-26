# module BraintreeRails
#   class CreditCard
#     include Model
#     define_attributes(
#       :create => [:billing_address, :cardholder_name, :customer_id, :expiration_date, :expiration_month, :expiration_year, :number, :cvv, :options, :token],
#       :update => [:card_type, :billing_address, :billing_address_attributes, :cardholder_name, :expiration_date, :expiration_month, :expiration_year, :options, :number, :cvv],
#       :readonly => [
#         :bin, :commercial, :country_of_issuance, :created_at, :debit, :durbin_regulated, :default,
#         :expired, :healthcare, :issuing_bank, :payroll, :prepaid, :unique_number_identifier, :updated_at
#       ],
#       :as_association => [:cardholder_name, :cvv, :expiration_date, :expiration_month, :expiration_year, :number]
#     )

#     has_many   :transactions,    :class => Transactions
#     has_many   :subscriptions,   :class => Subscriptions
#     belongs_to :customer,        :class => Customer,       :foreign_key => :customer_id
#     has_one    :billing_address, :class => BillingAddress
#     # accepts_nested_attributes_for :billing_address
#     validate :credit_card_format


#     alias_method :id, :token
#     alias_method :id=, :token=

#     around_persist :clear_encryped_attributes
#     before_update :normalize_expiration_date, :if => :expiry_date_changed?
    
#     def credit_card_format
#       # check format
#       return true if self.card_type.to_s.empty?
#       format = CARD_TYPE_NUMBER_FORMAT[self.card_type][:format]
#       format_range = CARD_TYPE_NUMBER_FORMAT[self.card_type][:format_range]
#       unless format.nil?
#         unless self.number.start_with?(*format)
#           return errors.add(:number, build_error_msg(format, format_range))
#         end
#       end

#       unless format_range.nil?
#         format_range.each do |index|
#           range = (index[:from]..index[:to]).to_a
#           unless self.number.start_with?(*range)
#             return errors.add(:number, build_error_msg(format, format_range))
#           end
#         end
#       end

#       # check length
#       unless CARD_TYPE_NUMBER_FORMAT[self.card_type][:length].nil?
#         if self.number.length != CARD_TYPE_NUMBER_FORMAT[self.card_type][:length]
#           return errors.add(:number, "^#{self.card_type} card must have
#               #{CARD_TYPE_NUMBER_FORMAT[self.card_type][:length]} digits")
#         end
#       else
#         unless self.number.length.between?(CARD_TYPE_NUMBER_FORMAT[self.card_type][:min_length],
#             CARD_TYPE_NUMBER_FORMAT[self.card_type][:max_length])
#           return errors.add(:number, "^#{self.card_type} card must have
#               #{CARD_TYPE_NUMBER_FORMAT[self.card_type][:min_length]}
#               - #{CARD_TYPE_NUMBER_FORMAT[self.card_type][:max_length]} digits")
#         end
#       end
#     end

#     def ensure_model(model)
#       if Braintree::Transaction::CreditCardDetails === model
#         assign_attributes(extract_values(model))
#         self.persisted = model.id.present?
#         model
#       else
#         super
#       end
#     end

#     def expired?
#       expired
#     end

#     def default?
#       default
#     end

#     def masked_number
#       "#{bin}******#{last_4}"
#     end

#     def add_errors(validation_errors)
#       billing_address.add_errors(validation_errors.except(:base)) if billing_address
#       super(validation_errors)
#     end

#     def attributes_for(action)
#       super.tap do |attributes|
#         if attributes[:billing_address] && action == :update
#           attributes[:billing_address].merge!(:options => {:update_existing => true})
#         end
#       end
#     end

#     def clear_encryped_attributes
#       yield if block_given?
#     ensure
#       return unless Configuration.mode == Configuration::Mode::JS
#       [:number=, :cvv=].each do |encrypted_attribute|
#         self.send(encrypted_attribute, nil)
#       end
#     end

#     def normalize_expiration_date
#       self.expiration_date = [self.expiration_month, self.expiration_year].join("/")
#       self.expiration_month = self.expiration_year = nil
#     end

#     def expiry_date_changed?
#       changed.include?(:expiration_month) || changed.include?(:expiration_year)
#     end
#   end
# end
