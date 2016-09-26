child @items => "items" do
    attributes :id , :name, :category_id, :category_name, :menu_id
    node(:rating){|r| r.avg_rating}

    child :item_photos => "item_images" do
        node :image do
            |v| v.photo.fullpath if v.photo
        end
    end
    #child :item_keys => "item_keys" do
    #        attributes :id, :name, :description,:image
    #end
    #attribute :type
end

child @servers => "servers" do
    attributes :id, :avatar, :name, :rating
end
