module Admin
  class Package < ActiveRecord::Base
    self.table_name = 'packages'

    attr_accessible :package_id, :enabled

    scope :enabled, -> { where(enabled: true) }
  end
end
