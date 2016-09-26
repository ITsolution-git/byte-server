class ItemTag
  def initialize(location_id)
    @location = Location.find location_id
  end

  def find_by_tag(name, type)
    records = eval("#{type}_records").select do |object|
      # if the type is trending we just want to return all ten
      if type == 'trending'
        true
      else
        object.name.upcase == name && has_menu_published?(object)
      end
    end
    get_items records
  end

  def tag_kinds
    [category_tags, trending_tags, menu_item_tags, item_key_tags]
  end


  def category_tags
    tags = filter_and_map category_records
    {name: 'Menu Categories', tag_type: 'category', sequence: '1', tags: tags.uniq}
  end


  # Finds the tags that are trending based on a function found on the item
  def trending_tags
    {name: 'Trending', tag_type: 'trending', sequence: '2', tags: ['TOP 10 MENU ITEMS']}
  end

  # Gets the grades that are at least B+. The grades are a numerical scale
  # F  D  C- C  C+ B- B  B+ A- A  A+
  # 1  2  3  4  5  6  7  8  9  10 11

  def top_grade_tags
    tags = filter_and_map top_grade_records
    {name: 'Top Grade', tag_type: 'top_grade', sequence: '3', tags: tags.uniq}
  end


  def menu_item_tags
    tags = filter_and_map menu_item_records
    {name: 'Menu Item', tag_type: 'menu_item', sequence: '4', tags: tags.uniq}
  end


  def item_key_tags
    tags = filter_and_map item_key_records
    {name: 'Item Keys', tag_type: 'item_key', sequence: '5', tags: tags.uniq}
  end

  private
  def filter_and_map(records)
    map_name(filter_collection(records))
  end
  def map_name(records)
    records.map{|record| record.name.upcase}.to_a
  end

  def filter_collection(records)
    records.select do |record|
      has_menu_published? record
    end
  end

  def has_menu_published?(record)
    items = get_items([record])
    items.reduce(false) do |accumulator, item|
      accumulator || item.has_menu_published?
    end
  end

  def get_items(records)
    if records.any?{|record| record.is_a?(Item)}
      records
    else
      records.reduce(Set.new) do |accumulator, record|
        relevant_items = record.items.select do |item|
          @location.items.include? item
        end
        accumulator.merge relevant_items
      end
    end
  end

  def category_records
    BuildMenu
      .includes(:menu, :location, :category)
      .where(locations: {id: @location.id}, menus: {publish_status: 2})
      .order(:category_sequence)
      .map{|build_menu| build_menu.category}
  end

  def trending_records
    items = @location.items.map do |item|
      {trending_points: item.trending_points, record: item}
    end
    items.sort_by{|item| item[:trending_points]}.map{|item| item[:record]}.last(10)
  end

  def top_grade_records
    @location.items.where('rating > ?', 7)
  end

  def menu_item_records
    @location.items.reduce(Set.new) do |accumulator, item|
      if item.item_type.present?
        accumulator.add item.item_type
      else
        accumulator
      end
    end
  end

  def item_key_records
    @location.items.reduce(Set.new) do |accumulator, item|
      accumulator.merge item.item_keys
    end
  end
end

