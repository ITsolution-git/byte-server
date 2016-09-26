object @item
    attribute :get_rating => "rating"
    attribute :get_rating_count => "ratings_count"
    attribute :get_comment_count => "comments_count"

child @comments=>"comments" do
    attributes :comment_id, :item_id, :item_name, :text, :rating, :created, :updated, :user_id, :user_avatar, :order_item_id
    node(:username){|m| m.user.nil? ? "Guest" : m.user.username}
end