child @suspend => "user_status" do
   node (:status) {|m| m.is_deleted}
end
node(:items) do |i|
  partial('items/items', :object => @items)
end