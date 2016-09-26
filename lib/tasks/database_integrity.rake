namespace :database_integrity do
  desc 'Fix integrity issues with wrong email type for menu'
  task :fix_menus_emails => :environment do
    progress_bar = ProgressBar.create(title: 'Menus:', total: Menu.count)
    puts 'Checking menus publish emails and fixing (emptying) bad ones'
    Menu.all.each do |menu|
      begin
        puts menu.publish_email
      rescue ActiveRecord::SerializationTypeMismatch
        puts "Fixing menu with name: #{menu.name}"
        menu.update_attribute(:publish_email, [])
      end
      menu.update_attribute(:publish_email, []) if menu.publish_email.empty?
    end
    progress_bar.increment
    puts 'Fixing finished successfully'
  end
end
