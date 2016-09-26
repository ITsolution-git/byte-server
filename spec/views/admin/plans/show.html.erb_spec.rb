require 'spec_helper'

RSpec.describe "admin/plans/show", :type => :view do
  before(:each) do
    @plan = assign(:admin_plan, Plan.create!(
      :name => "Plan Name:"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Plan Name:/)
  end
end
