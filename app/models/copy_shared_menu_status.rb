class CopySharedMenuStatus < ActiveRecord::Base
  belongs_to :location
  attr_accessible :job_id, :menu_name
end
