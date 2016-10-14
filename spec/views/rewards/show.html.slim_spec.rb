require 'rails_helper'

RSpec.describe "rewards/show", :type => :view do
  before(:each) do
    @reward = assign(:reward, Reward.create!(
      :name => "Name",
      :photo => "Photo",
      :share_link => "Share Link",
      :timezone => "Timezone",
      :default_timezone => false,
      :description => "MyText",
      :quantity => 1,
      :stats => 2,
      :location => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Photo/)
    expect(rendered).to match(/Share Link/)
    expect(rendered).to match(/Timezone/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
  end
end
