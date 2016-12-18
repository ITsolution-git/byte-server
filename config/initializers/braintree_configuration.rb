Braintree::Configuration.environment = (Rails.env.production? ? :production : :sandbox)
Braintree::Configuration.merchant_id = Figaro.env.braintree_merchant_id
Braintree::Configuration.public_key  = Figaro.env.braintree_public_key
Braintree::Configuration.private_key = Figaro.env.braintree_private_key
