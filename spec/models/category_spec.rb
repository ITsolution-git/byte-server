require 'rails_helper'

describe Category do

  before do
    mock_geocoding!
  end

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:location_id) }
    xit { should allow_mass_assignment_of(:category_points) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:order) }


    # Associations
    describe "Associations" do
      it { should have_many(:items).through(:build_menus) }
      it { should have_many(:build_menus).dependent(:destroy) }
      it { should have_many(:menus).through(:build_menus) }
      it { should have_many(:combo_item_categories).dependent(:destroy) }
      it { should have_many(:combo_items).through(:combo_item_categories) }
      it { should belong_to(:location) }
    end

    # Validations
    describe "Validations" do
      let(:category_points_max_length) { build(:category_with_points_max_length) }
      it { should validate_presence_of :name }
      xit { should validate_numericality_of(:category_points).only_integer.allow_nil}
      it "Length of name should be maximum 30 with message '^Category Name can't be greater than 30 characters.'" do
        should ensure_length_of(:name).
          is_at_most(30).
          with_message("^Category Name can't be greater than 30 characters.")
      end

      xit "category_points length should be maximum 10" do
        category_points_max_length.save.should eq(false)
      end
    end

    describe "Method" do
      before(:each) do
        create(:create_user)
        @menu = create(:test_menu)
        @category1 = create(:category_test1)
        @category2 = create(:category_test2)
        @item = build(:test_item)
      end

      context ".item_by_build_menu" do
        it "Should get Items" do
          @item.save(:validate=>false)
          create_build_menu(@item.id, @menu.id, @category2.id)
          items = @category2.item_by_build_menu(@menu.id, @category2.id)
          items.first.name.should eq("test")
        end
      end

      context "#has_menu_published?" do
        it "should be false" do
          @category2.has_menu_published?.should eq(false)
        end
      end

      context "==(obj)" do
        it "should be false" do
          @category2.==(@category1).should eq(false)
        end

        it "should be true" do
          @category1.==(@category1).should eq(true)
        end

        it "should be false" do
          @category1.==(Item.new).should eq(false)
        end
      end
    end
  end
end
