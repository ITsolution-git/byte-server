child @server_comments =>"comments" do
    attributes :id, :server_id, :rating
    attribute :text =>"comment"

    node(:username){|m| m.user.nil? ? "Guest" : m.user.username}
    attributes :user_avatar, :created, :updated
end

object @info
    attribute :get_avg_rating =>"rating"
    attribute :get_rating_count =>"ratings_count"
    attribute :get_comment_count =>"comments_count"