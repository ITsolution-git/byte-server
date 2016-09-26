class LocationGrader
  GRADES = %w(A+ A A- B+ B B- C+ C C- D+ D D- F).freeze
  WEIGHTS = [2.5, 1.75, 1.25, 1, 0.8, 0.65].freeze
  def initialize(location)
    @scores = location_item_comments location
  end

  def grade
    divisor = find_divisor
    apply_divisor divisor, sum_averages
  end

  def to_alphabetic
    return '' if grade.round < 1 || grade.round > 13

    GRADES[grade.round-1]
  end

  private

  def sum_averages
    @scores.reduce(0) do |accumulator, (age, values)|
      average = sum_by_age(values) / values.count
      weighted_average = apply_weight(age, average)
      accumulator += weighted_average
    end
  end

  def sum_by_age(values)
    values.reduce(0) do |accumulator, value|
      accumulator += value
    end
  end

  def months_back(date)
    date2 = Time.now
    (date2.year * 12 + date2.month) - (date.year * 12 + date.month)
  end

  def location_item_comments(location)
    @_location_item_comments ||= location.grades
      .map { |comment| { months_back(comment.updated_at) => comment.rating } } # make hash of month to rating
      .group_by{ |e| e.keys.first } # group hash keys by first key
      .map{|key, array| [key, array.map{|hash| hash.values.first}] }.to_h
  end

  def find_divisor
    divisor = @scores.keys.reduce(0) do |accumulator, age|
      accumulator += find_weight age
    end
    divisor.zero? ? 1 : divisor
  end

  def find_weight age
    if age <= 5
      WEIGHTS[age]
    else
      WEIGHTS[5]
    end
  end

  def apply_divisor(divisor, value)
    value / divisor
  end

  def apply_weight(age, value)
    value * find_weight(age)
  end

end
