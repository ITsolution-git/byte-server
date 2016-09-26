require 'spec_helper'

RSpec.describe "admin/plans/edit", :type => :view do
  before(:each) do
    @plan = assign(:plan, Plan.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit admin_plan form" do
    render

    assert_select "form[action=?][method=?]", admin_plan_path(@plan), "post" do

      assert_select "input#plan_name[name=?]", "plan[name]"
    end
  end
end
