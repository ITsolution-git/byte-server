require 'rails_helper'

RSpec.describe "admin/prices/edit", :type => :view do
  before(:each) do
    @price = assign(:admin_price, Price.create!(
      :plan_id => 1,
      :app_service_id => 1
    ))
  end

  it "renders the edit admin_price form" do
    render

    assert_select "form input", 3

    assert_select "form input" do
      assert_select "[name=?]", /.+/  # Not empty
    end
  end
end
