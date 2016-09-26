class ItemOption < ActiveRecord::Base
  attr_accessible :name, :only_select_one, :is_deleted, :location_id

  has_many :items, :through => :item_item_options
  has_many :item_item_options, :dependent => :destroy
  has_many :item_option_addons
  has_many :view_item_option_addons, :class_name => "ItemOptionAddon", :conditions => {:item_option_addons => {:is_deleted => 0}}
  belongs_to :location


  validates :name ,:presence =>true , length:{maximum: 60, message:"^Menu Option Name can't be greater than 60 characters."}
  # validates :item_option_addons, :presence => true
  validates_associated :item_option_addons

	def has_item_contains_menu_published?
		has_item_contains_menu_published = false
		self.items.each do |item|
			if item.has_menu_published?
				has_item_contains_menu_published = true
				break
			end
		end
		return has_item_contains_menu_published
	end

	def ===(obj)
		if obj.instance_of?(self.class)
			item_option_attributes = ["name", "only_select_one"]
			item_option_attributes.each do |field|
				if self.send(field) != obj.send(field)
					return false
				end
			end

			if self.item_option_addons.count != obj.item_option_addons.length
				return false
			end

			arr = obj.item_option_addons.sort_by!{|m|m.id}

			self.item_option_addons.sort_by!{|m|m.id}.each_with_index do |opt, index|
				# print "\nOPT____" + opt.is_selected.to_s + "____" + opt.name.to_s + "____" + opt.price.to_s
				# print "\tARR____" + arr[index].is_selected.to_s + "____" + arr[index].name.to_s + "____" + arr[index].price.to_s
				if (opt.is_selected.to_s != arr[index].is_selected.to_s) or (opt.name.to_s != arr[index].name.to_s) or (opt.price.to_s != arr[index].price.to_s)
					return false
				end
			end
			return true
		end
		return false
	end
end