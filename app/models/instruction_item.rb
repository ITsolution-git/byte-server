class InstructionItem < ActiveRecord::Base
  attr_accessible :instruction_category_id, :item_name, :times, :youtube_id

  belongs_to :instruction_category
end
