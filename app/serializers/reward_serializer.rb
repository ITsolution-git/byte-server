class RewardSerializer < ActiveModel::Serializer
  attributes :id, :name, :photo, :share_link, :available_from, :expired_until, :timezone, :default_timezone, :description, :quantity, :stats
  has_one :location
end
