require 'rails_helper'

RSpec.describe "rewards/index", :type => :view do
  before(:each) do
    assign(:rewards, [
      Reward.create!(
        :name => "Name",
        :photo => "Photo",
        :share_link => "Share Link",
        :timezone => "Timezone",
        :default_timezone => false,
        :description => "MyText",
        :quantity => 1,
        :stats => 2,
        :location => nil
      ),
      Reward.create!(
        :name => "Name",
        :photo => "Photo",
        :share_link => "Share Link",
        :timezone => "Timezone",
        :default_timezone => false,
        :description => "MyText",
        :quantity => 1,
        :stats => 2,
        :location => nil
      )
    ])
  end

  it "renders a list of rewards" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Photo".to_s, :count => 2
    assert_select "tr>td", :text => "Share Link".to_s, :count => 2
    assert_select "tr>td", :text => "Timezone".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
