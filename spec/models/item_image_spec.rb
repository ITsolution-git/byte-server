require 'rails_helper'

describe ItemImage do

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:image) }
    it { should allow_mass_assignment_of(:item_id) }
    it { should allow_mass_assignment_of(:item_token) }
    it { should allow_mass_assignment_of(:crop_x) }
    it { should allow_mass_assignment_of(:crop_y) }
    it { should allow_mass_assignment_of(:crop_w) }
    it { should allow_mass_assignment_of(:crop_h) }
    it { should allow_mass_assignment_of(:rate) }
  end

  # Associations
  describe "Associations" do
    it { should belong_to(:item) }
  end

  describe ".cropping" do
    before(:each) do
      @item_image_true = build(:item_image_true)
      @item_image_false = build(:item_image_false)
      @item_image_crop_x_true = build(:item_image_crop_x_true)
      @item_image_crop_y_true = build(:item_image_crop_y_true)
      @item_image_crop_w_true = build(:item_image_crop_w_true)
      @item_image_crop_h_true = build(:item_image_crop_h_true)
    end

    context "return" do
      it { @item_image_true.cropping?.should eq(true) }
      it { @item_image_false.cropping?.should eq(false) }
      it { @item_image_crop_x_true.cropping?.should eq(false) }
      it { @item_image_crop_y_true.cropping?.should eq(false) }
      it { @item_image_crop_w_true.cropping?.should eq(false) }
      it { @item_image_crop_h_true.cropping?.should eq(false) }
    end
  end

end
