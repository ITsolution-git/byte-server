require 'rails_helper'

RSpec.configure do |c|
  c.include Features::ControllerMacros
end

xdescribe PaymentsController do
  describe '#create' do
    it 'calls pay_order on the order model and returns success' do
      login
      order = create(:order)
      allow(Order).to receive(:find).
        with(order.id.to_s).
        and_return(order)
      allow(order).to receive(:pay_order).and_return({status: :success})
      expect(order).to receive(:pay_order)
      post :create, payment_token: 'JFLKSANFKL', amount: '5.00', id: order.id, access_token: @user.access_token
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq('success')
    end
  end
end
