module AttributeStripper

  def self.before_validation(model)
    model.attributes.each_value { |v| v.strip! if v.respond_to? :strip! }
    true
  end

end