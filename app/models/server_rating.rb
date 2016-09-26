class ServerRating < ActiveRecord::Base
  attr_accessible :user_id, :rating, :server_id, :text

  belongs_to :user
  belongs_to :server

  def user_avatar
    u = User.where("id=?",self.user_id).first
    if (!u.nil? && u.avatar)
      return u.avatar.fullpath
    end
    return nil
  end

  def get_avg_rating
    rating =0
    s = ServerRating.where("rating IS NOT NULL AND server_id=?",self.server_id)
    if s.empty?
      return 0
    else
      s.collect {|c| rating=rating + c.rating}
      rating = rating.to_f/s.count
      return rating
    end
    return rating
  end
  def datetime
    self.updated_at.strftime("%d %b %Y")
  end
  def created
    self.created_at.strftime("%d %b %Y %H:%M:%S:%L")
  end
  def updated
    self.updated_at.strftime("%d %b %Y %H:%M:%S:%L")
  end
end
