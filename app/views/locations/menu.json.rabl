child @categories => "categories" do
  attributes :id,:name,:number_item,:menu_id, :is_favourite, :is_nexttime 
end
child @prizes => "prizes" do
  node(:current_prizes) do |p|
    partial('prize/current_prize', :object => p.current_prizes(@location.id, p.total, p.user_id))
  end
end
