require 'rails_helper'

RSpec.describe "admin/prices/new", :type => :view do
  before(:each) do
    @plan = create(:plan_300)
    @service = create(:basic_service)
    @price = assign(:price, Price.new(
      :plan_id => @plan.id,
      :app_service_id => @service.id
    ))
  end

  it "renders new admin_price form" do
    render

    assert_select "form input", 2

    assert_select "form input" do
      assert_select "[name=?]", /.+/  # Not empty
    end
  end
end
