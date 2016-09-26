namespace :item_keys do
  desc "Made users anonymous"
  task :fix_removal => :environment do
    puts 'Task started'
    Menu.all.each do |menu|
      location = menu.location
      next if location.nil?

      location.item_keys.each do |item_key|
        item_key.items = [] if item_key.items.detect { |item| !item.menus.map(&:location_id).include? location.id }.present?
      end
    end
    puts 'Task finished'
  end
end
