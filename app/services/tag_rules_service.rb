class TagRulesService
  def initialize(tags, search_with)
    @types = tags.group_by{|tag| tag[:type]}.values
    @search_with = search_with
  end

  def find_tags
    combine_different_types.to_a
  end

  private
  def combine_different_types
    @types.reduce(Set.new) do |accumulator, tags|
      result = combine_same_types tags
      conditional_intersect(accumulator, result)
    end
  end

  def conditional_intersect(accumulator, result)
    if accumulator.empty?
      result
    else
      accumulator & result
    end
  end

  def combine_same_types(tags)
    tags.reduce(Set.new) do |accumulator, tag|
      results = @search_with.find_by_tag(tag[:name], tag[:type])
      accumulator | results
    end
  end
end
