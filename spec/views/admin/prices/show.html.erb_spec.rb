require 'rails_helper'

RSpec.describe "admin/prices/show", :type => :view do
  before(:each) do
    @plan = create(:plan_300)
    @service = create(:basic_service)
    @price = assign(:price, Price.create!(
      :plan_id => @plan.id,
      :app_service_id => @service.id
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/300/)
    expect(rendered).to match(/BASIC/)
  end
end
