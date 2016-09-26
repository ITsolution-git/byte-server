class LocationTrendingService
  def initialize(locations, date, amount_of_trending)
    @locations = locations
    @location_list = @locations.map{|v| v.id}
    @date = date
    @amount_of_trending = amount_of_trending
  end

  def find_trending
    trending_hash = find_ordered_hash
    @locations.each{|location| trending_hash[location.id] = location if trending_hash.has_key?(location.id)}
    trending_hash.values
  end

  private

  def find_ordered_hash
    result = calculate_parts
    result.delete nil
    Hash[result.sort_by{|k, v| -v}.first(@amount_of_trending)]
  end

  def calculate_parts
    a_grades = grades_count(0, 4)
    b_grades = grades_count(4, 7)
    favorites = favorites_count
    shares = share_count
    merge_results(a_grades, b_grades, favorites, shares)
  end

  def share_count
    SocialShare
      .includes(:location)
      .where(location_id: @location_list )
      .where('social_shares.updated_at > ?', @date)
      .group('location_id')
      .count
  end

  def favorites_count
    ItemFavourite
      .includes(build_menu: [{item: [:location]}])
      .where(locations: {id: @location_list})
      .where("item_favourites.updated_at > ?", @date)
      .group('items.location_id')
      .count
  end

  def grades_count(high_grade, low_grade)
    ItemComment
      .includes(build_menu: [{item: [:location]}])
      .where(locations: {id: @location_list})
      .where("item_comments.updated_at > ? AND item_comments.rating < ? AND item_comments.rating > ?", @date, low_grade, high_grade)
      .group('items.location_id')
      .count
  end

  def merge_results(hash_one, hash_two, hash_three, hash_four)
    result = merge_by_addition hash_one, hash_two
    result = merge_by_addition result, hash_three
    merge_by_addition result, hash_four
  end

  def merge_by_addition(hash_one, hash_two)
    hash_one.merge(hash_two){|key, old_value, new_value| old_value + new_value}
  end

end
