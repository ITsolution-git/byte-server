require 'spec_helper'

RSpec.describe "admin/plans/new", :type => :view do
  before(:each) do
    @plan = assign(:plan, Plan.new(
      :name => "MyString"
    ))
  end

  it "renders new admin_plan form" do
    render

    assert_select "form[action=?][method=?]", admin_plans_path, "post" do
      assert_select "input#plan_name[name=?]", "plan[name]"
    end
  end
end
