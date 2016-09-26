FactoryGirl.define do
  factory :pmi_combo_item, class: ComboItem do |b|
    b.name "pmi"
    b.combo_type 'PMI'
    b.association :item, :factory => :test_item
    b.association :menu, :factory => :test_menu
  end
  
  factory :pmi_gmi_combo_item, class: ComboItem do |b|
    b.name "pmi gmi"
    b.combo_type 'PMI,GMI'
    b.association :item, :factory => :test_item
    b.association :menu, :factory => :test_menu
  end
  
  factory :gmi_pmi_combo_item, class: ComboItem do |b|
    b.name "gmi pmi"
    b.combo_type 'GMI,PMI'
    b.association :item, :factory => :test_item
    b.association :menu, :factory => :test_menu
  end
 
  factory :gmi_combo_item, class: ComboItem do |b|
    b.name "gmi"
    b.combo_type 'GMI'
    b.association :item, :factory => :test_item
    b.association :menu, :factory => :test_menu
  end
 
  factory :comno_type_nil_combo_item, class: ComboItem do |b|
    b.name "test"
    b.combo_type ''
    b.association :item, :factory => :test_item
    b.association :menu, :factory => :test_menu
  end
 
  factory :name_nil_combo_item, class: ComboItem do |b|
    b.name "test1"
    b.combo_type ''
    b.association :item, :factory => :test_item
    b.association :menu, :factory => :test_menu
  end 
 
  factory :name_test_combo_item, class: ComboItem do |b|
    b.name "test"
    b.combo_type ''
    b.association :item, :factory => :test_item
    b.association :menu, :factory => :test_menu
  end
end
