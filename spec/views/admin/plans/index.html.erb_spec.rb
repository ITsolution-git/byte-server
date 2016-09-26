require 'spec_helper'

RSpec.describe "admin/plans/index", :type => :view do
  before(:each) do
     @plans = assign(:admin_plans, [
      Plan.create!(
        :name => "Plan Name"
      ),
      Plan.create!(
        :name => "Plan Name"
      )
    ])
  end

  it "renders a list of admin/plans" do
    render
    assert_select "tr>td", :text => "Plan Name".to_s, :count => 2
  end
end
