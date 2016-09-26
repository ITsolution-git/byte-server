require 'rails_helper'

RSpec.describe Order, :type => :model do
  xdescribe '#pay_order' do
    it 'creates a transaction with braintree' do
      order = create(:order)
      expect{order.pay_order(4.01, Braintree::Test::Nonce::Transactable)}.not_to raise_error
    end
  end
end
