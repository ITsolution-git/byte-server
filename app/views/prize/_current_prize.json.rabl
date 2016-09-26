object @prizes
  attributes :prize_id, :name, :level_number, :redeem_value, :date_time_redeem, :from_user, :email, :share_prize_id, :type, :status_prize_id
  unless :build_menu_id.nil?
    child :build_menu => "item" do
      node(:id){|bm| bm.item_id}
      attributes :category_id
      attribute :get_item_name => "name"
    end
  end

  child :category => "category" do
    attributes :id, :name, :redemption_value
    child :publish_items => "items" do
      attributes :id, :name
    end
  end