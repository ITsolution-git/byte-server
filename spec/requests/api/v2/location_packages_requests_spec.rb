require 'rails_helper'

xdescribe Api::V2::LocationPackagesController, type: :request do
  describe ".test" do
    context 'when the user does not exist' do
      before do
        get 'api/v2/location_packages/1'
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( {status: 'failed', error: 'No access token passed'}.to_json )
      end
    end

    context 'when the user exists' do
      let(:current_user) { create :create_user }
      let(:location_without_packages) { create :location_test}
      let(:location_with_packages) { create :location_test }
      let(:subscription) { create :subscription, location: location_with_packages , subscription_id: '123'}

      it 'should response with empty packages list' do
        get "api/v2/location_packages/#{location_without_packages.id}",
          access_token: current_user.authentication_token
        expect( response.body ).to eq( [].to_json )
      end

      it 'should response with packages list' do
        subs = double(id: subscription.subscription_id,
                      billing_period_end_date: '2015-08-18')

        allow(Braintree::Subscription).to receive(:find).and_return(subs)
        get "api/v2/location_packages/#{location_with_packages.id}",
          access_token: current_user.authentication_token

        expect( response.body ).to eq( [{ id: '123', due: '2015-08-18' }].to_json )
      end
    end
  end
end
