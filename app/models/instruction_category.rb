class InstructionCategory < ActiveRecord::Base
  attr_accessible :icon, :name
  has_many :instruction_items
end
