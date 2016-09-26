require 'rails_helper'

RSpec.describe "admin/prices/index", :type => :view do
  before(:each) do
     @plan = create(:plan_300)
     @service = create(:basic_service)
     @prices = assign(:admin_prices, [
      Price.create!(
        :plan_id => @plan.id,
        :app_service_id => @service.id
      ),
      Price.create!(
        :plan_id => @plan.id,
        :app_service_id => @service.id
      )
    ])
  end

  it "renders a list of admin/prices" do
    render
    assert_select "tr>td", :text => "300".to_s, :count => 2
    assert_select "tr>td", :text => "BASIC".to_s, :count => 2
  end
end
