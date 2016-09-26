require 'rails_helper'

describe BuildMenu, type: :geocode do

  let(:user_create) {create(:create_user)}

  before(:each) do
    mock_geocoding!
    user_create
    @build_menu = create(:build_menu, :active, :with_award_points)
    @build_menu_inactive = create(:build_menu, :inactive, :with_award_points)
    @test_active_build_menu = create(:build_menu, :active, :without_award_points)
    @test_build_menu = create(:build_menu, :inactive, :without_award_points)
  end

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:item_id) }
    it { should allow_mass_assignment_of(:menu_id) }
    it { should allow_mass_assignment_of(:category_id) }
    it { should allow_mass_assignment_of(:active) }
    it { should allow_mass_assignment_of(:category_sequence) }
    it { should allow_mass_assignment_of(:item_sequence) }
  end

  # Associations
  describe "Associations" do
    it { should have_many(:item_comments).dependent(:destroy) }
    it { should have_many(:item_favourites).dependent(:destroy) }
    it { should have_many(:item_nexttimes).dependent(:destroy) }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:order_item_combos).dependent(:destroy) }
    it { should belong_to(:menu) }
    it { should belong_to(:category) }
    it { should belong_to(:item) }
  end

  # Model Scope
  describe "Scope" do
    context "default_scope" do
      it "BuildMenu.new.active should be return true" do
        BuildMenu.new.active.should eq(true)
      end

      it "BuildMenu.create.active should be return true" do
        BuildMenu.create.active.should eq(true)
      end

      it "BuildMenu.all should be return active true" do
        expect(BuildMenu.all.map(&:active)).not_to include(false)
      end
    end

    context ".get_categories_by_menu" do
      it "should be return category_id" do
        BuildMenu.get_categories_by_menu(@build_menu.menu_id).first.category_id.should eq(@build_menu.category_id)
      end

      it "should be return category_sequence" do
        BuildMenu.get_categories_by_menu(@build_menu.menu_id).first.category_sequence.should eq(@build_menu.category_sequence)
      end
    end
  end

  # Methods
  describe "Methods" do
    context ".get_category_id_by_buid_menu_id" do
      it "should be Category" do
        @build_menu.get_category_id_by_buid_menu_id(@build_menu.id).should eq(@build_menu.category_id)
      end
    end

    context ".get_menu_id_by_buid_menu_id" do
      it "should be Menu" do
        @build_menu.get_menu_id_by_buid_menu_id(@build_menu.id).should eq(@build_menu.menu_id)
      end
    end

    context ".set_default_value" do
      it "Active should be true" do
        @build_menu.set_default_value.should eq(nil)
      end
    end

    context ".disable" do
      it "Active should false" do
        @build_menu.active.should_not eq(false)
      end

      it "Active should true" do
        @build_menu.disable
        @build_menu.active.should_not eq(true)
      end
    end

    context ".enable?" do
      it "Active should true" do
        @build_menu.enable?.should eq(true)
      end

      it "Active should not false" do
        @build_menu.enable?.should_not eq(false)
      end
    end

    context ".enable(item_sequence)" do
      it "item_sequence is false then should be nil" do
        @build_menu.enable(false).should eq(nil)
      end

      it "item_sequence should be true" do
        @build_menu.enable(true)
        @build_menu.item_sequence.should eq(1)
      end

      it "active should be true" do
        @build_menu.active.should eq(true)
      end
    end

    context ".find_by_items_id" do
      it "should be get items" do
        bm = BuildMenu.find_by_items_id([@build_menu.item_id])
        bm.first.item_id.should eq(@build_menu.item_id)
      end

      it "should be nil" do
        BuildMenu.find_by_items_id(nil).should eq([])
      end
    end

    context ".update_menu_status" do
      it "should be return nil" do
        @build_menu.update_menu_status.should eq(nil)
      end
    end

    context ".get_value_main_dish" do
      it "main dish should be return true" do
        @build_menu.get_value_main_dish([true]).should eq(true)
      end

      it "main dish should be return false" do
        @build_menu.get_value_main_dish([false]).should eq(false)
      end

      it "Two main dish should be return false" do
        @build_menu.get_value_main_dish([true, false]).should eq(false)
      end

      it "Two main dish should be return true" do
        @build_menu.get_value_main_dish([true, true]).should eq(true)
      end

      it "Two main dish should not be return false" do
        @build_menu.get_value_main_dish([false, false]).should_not eq(true)
      end
    end

    xcontext ".get_points" do
      it "should return item reward points" do
        @build_menu.get_point.should eq(20)
      end

      it "should return menu reward points" do
        @test_build_menu.get_point.should eq(30)
      end

      it "should return category points" do
        @build_menu_inactive.get_point.should eq(1234567999)
      end

      it "should not return nil" do
        @test_active_build_menu.get_point.should_not eq(nil)
      end

      it "should be return zero" do
        @test_active_build_menu.get_point.should eq(0)
      end
    end
  end

  # Callbacks
  describe "Callbacks" do
    context "update_combo" do
      it "should update menu as pending for inactive" do
        @build_menu_inactive.menu.publish_status.should eq(PENDING_STATUS)
      end
    end
  end
end
