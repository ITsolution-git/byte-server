require 'spec_helper'

describe ComboItem do

  let(:user_create) {create(:create_user)}

  before :each do
    mock_geocoding!
  end

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:item_id) }
    it { should allow_mass_assignment_of(:menu_id) }
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:combo_type) }
  end

  # Associations
  describe "Associations" do
    it { should have_many(:combo_item_categories).dependent(:destroy) }
    it { should have_many(:categories).through(:combo_item_categories) }
    it { should have_many(:combo_item_items).dependent(:destroy) }
    it { should have_many(:order_items)}
    it { should have_many(:items).through(:combo_item_items) }
    it { should belong_to(:menu) }
    it { should belong_to(:item) }
  end

  # Validations
  describe "Validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :menu_id }
  end

  describe "Methods" do

    before(:each) do
      user_create
      @pmi_combo_item = create(:pmi_combo_item)
      @pmi_gmi_combo_item = create(:pmi_gmi_combo_item)
      @comno_type_nil_combo_item = create(:comno_type_nil_combo_item)
      @gmi_pmi_combo_item = create(:gmi_pmi_combo_item)
      @gmi_combo_item = create(:gmi_combo_item)
      @name_nil_combo_item = create(:name_nil_combo_item)
      @name_test_combo_item = build(:name_test_combo_item)
    end

    context "#pmi?" do
      it "should be return true" do
        @pmi_combo_item.pmi?.should eq(true)
      end

      it "should not be return false" do
        @pmi_combo_item.pmi?.should_not eq(false)
      end

      it { @comno_type_nil_combo_item.pmi?.should (false) }
    end

    context "#cmi?" do
      it "should be return true with PMI,GMI" do
        @pmi_gmi_combo_item.cmi?.should eq(true)
      end

      it "should not be return false with PMI,GMI" do
        @pmi_gmi_combo_item.cmi?.should_not eq(false)
      end

      it { @comno_type_nil_combo_item.cmi?.should (false) }
    end

    context "#cmi?" do
      it "should be return true with GMI,PMI" do
        @pmi_gmi_combo_item.cmi?.should eq(true)
      end

      it "should not be return false with GMI,PMI" do
        @pmi_gmi_combo_item.cmi?.should_not eq(false)
      end
    end

    context "#gmi?" do
      it "should be return true with GMI" do
        @gmi_combo_item.gmi?.should eq(true)
      end

      it "should not be return false with GMI" do
        @gmi_combo_item.gmi?.should_not eq(false)
      end

      it { @comno_type_nil_combo_item.gmi?.should (false) }
    end

    context ".name_unique" do
      it "name should not unique" do
        @comno_type_nil_combo_item.save.should eq(true)
      end
    end

    context "==(obj)" do
      it "should be false" do
        @gmi_combo_item.==(@pmi_combo_item).should eq(false)
      end

      it "should be true" do
        @pmi_combo_item.==(@pmi_combo_item).should eq(true)
      end

      it "should be false" do
        @pmi_combo_item.==(Item.new).should eq(false)
      end
    end
  end
end
