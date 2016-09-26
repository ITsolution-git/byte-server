FactoryGirl.define do
  factory :combo_item_category1, class: ComboItemCategory do |c|
    c.quantity 1
    c.association :category, :factory => :category_test1
    c.association :combo_item, :factory => :pmi_combo_item
  end
  
  factory :combo_item_category2, class: ComboItemCategory do |c|
    c.quantity 1
    c.association :category, :factory => :category_test2
    c.association :combo_item, :factory => :gmi_combo_item
  end
end
