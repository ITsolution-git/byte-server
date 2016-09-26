require 'rails_helper'

RSpec.configure do |c|
  c.include Features::ControllerMacros
end
xdescribe LocationMerchantsController do
  login_user
  describe '#create' do
    it 'creates a token for the braintree submerchant account' do
      location = create(:location_test)
      post :create, location_id: location.id, tax_id: '12345', account_number: '1123581321', routing_number: '071101307', birthday: '1981-11-19'
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to include(status: 'success')
    end
  end
end
