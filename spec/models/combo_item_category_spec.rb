require 'rails_helper'

describe ComboItemCategory do

  let(:user_create) {create(:create_user)}

  before :each do
    mock_geocoding!
  end

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:category_id) }
    it { should allow_mass_assignment_of(:combo_item_id) }
    it { should allow_mass_assignment_of(:quantity) }
    it { should allow_mass_assignment_of(:sequence) }
  end

  # Associations
  describe "Associations" do
    it { should belong_to(:category) }
    it { should belong_to(:combo_item)}
  end

  # Methods
  describe "Methods" do
    before(:each) do
      user_create
      @combo_item_category1 = create(:combo_item_category1)
      @combo_item_category2 = create(:combo_item_category2)
    end

    context "scrop get_quantity" do
      it "should be return combo_item_category object" do
        ComboItemCategory.get_quantity(@combo_item_category1.category_id, @combo_item_category1.combo_item_id).should eq([@combo_item_category1])
      end

      it "Without category_id should be return nil" do
        ComboItemCategory.get_quantity(nil, @combo_item_category1.combo_item_id).should eq([])
      end

      it "Without combo_item_id should be return nil" do
        ComboItemCategory.get_quantity(@combo_item_category1.category_id, nil).should eq([])
      end

      it "With wrong combo_item_id should be return nil" do
        ComboItemCategory.get_quantity(@combo_item_category1.category_id, @combo_item_category2.combo_item_id).should eq([])
      end

      it "With wrong category_id should be return nil" do
        ComboItemCategory.get_quantity(@combo_item_category2.category_id, @combo_item_category1.combo_item_id).should eq([])
      end
    end

    context "==(obj)" do
      it "should be false" do
        @combo_item_category2.==(@combo_item_category1).should eq(false)
      end

      it "should be true" do
        @combo_item_category1.==(@combo_item_category1).should eq(true)
      end

      it "should be false" do
        @combo_item_category2.==(Item.new).should eq(false)
      end
    end
  end
end
