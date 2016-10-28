module RewardsHelper
  def unredeemed(value)
    value.eql?(0) ? "Unlimited" : value
  end
end
