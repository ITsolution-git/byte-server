class UserRecentSearch < ActiveRecord::Base
  attr_accessible :keyword, :search_type, :user_id, :description

  belongs_to :user

  def self.save_recent_search(user_id, type, keyword)
    recent_searches = UserRecentSearch.where('user_id = ? and search_type = ?', user_id, type).order("id")
    if recent_searches.length == 5
      user_searches = UserRecentSearch.where('keyword = ? and search_type = ? and user_id = ?',keyword, type, user_id).order("id")
      if user_searches.length <= 1
        if recent_searches.include? user_searches.first
          return true
        else
          UserRecentSearch.where(:id => recent_searches.first.id).destroy_all
          UserRecentSearch.create({
            :user_id => user_id,
            :search_type => type,
            :keyword => keyword
          })
        end
      else
        search_delete = []
        first_search = user_searches.first
        user_searches.each do |i|
          if i.id != first_search.id
            search_delete << i.id
          end
        end
        UserRecentSearch.where('id in (?)', search_delete).destroy_all
      end
    else
      user_searches = UserRecentSearch.where('keyword = ? and search_type = ? and user_id = ?',keyword, type, user_id).order("id")
      if user_searches.length <= 1
        if !recent_searches.include? user_searches.first
          UserRecentSearch.create({
            :user_id => user_id,
            :search_type => type,
            :keyword => keyword
          })
        end
      else
        search_delete = []
        first_search = user_searches.first
        user_searches.each do |i|
          if i.id != first_search.id
            search_delete << i.id
          end
        end
        UserRecentSearch.where('id in (?)', search_delete).destroy_all
      end
    end
  end

  def self.get_recent_searches(user_id, type)
    if type == "location" || type == "restaurant" || type == "item"
      return UserRecentSearch.where('user_id = ? and search_type = ?', user_id, type).select("id, keyword, search_type")
    else
      return UserRecentSearch.where('user_id = ?', user_id).select("id, keyword, search_type")
    end
  end
end