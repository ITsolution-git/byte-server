require 'rails_helper'

RSpec.configure do |c|
  c.include Features::ControllerMacros
end

describe PaymentTokensController do
  describe '#show' do
    login_user
    before { allow(controller).to receive(:current_user) { @user } }
    context 'token exists' do
      xit 'returns the customer id' do
        allow(@user).to receive(:get_braintree_token).and_return({status: 'success', token: 'abcd'})
        expect(@user).to receive(:get_braintree_token)
        get :show, access_token: @user.access_token
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['status']).to eq('ok')
      end
    end
  end
end
