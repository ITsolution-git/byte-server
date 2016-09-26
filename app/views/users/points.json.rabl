object @user
node(:points) { |m| @user.points.to_i }  #to return 0 if nil
child @user=>:history do
    child :item_comments=> "items" do
        attributes :item_id, :text, :rating, :date
        node(:item_name){|m| m.item.name}
        node(:location_name){|m| m.item.location.name}
    end
end
