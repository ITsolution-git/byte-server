namespace :data do
  desc "Made users anonymous"
  task :anonymous, [:email_postfix, :pass] => :environment do |t, args|
    # TODO: redefining some custom validations, remove after User model is refactored
    class User
      def get_skip_zip_validation?; true; end
      def get_skip_first_name_validation?; true; end
      def get_skip_last_name_validation?; true; end
      def use_credit_card?; false; end
      def send_devise_notification(notification, opts={}); end
    end

    args.with_defaults(email_postfix: '@mailinator.com', pass: 'password')
    progress_bar = ProgressBar.create(title: 'Users', total: User.count)
    puts "Users will be updated with email => 'user_[user.id]#{args.email_postfix}' and password => '#{args.pass}'"
    User.all.each do |user|
      user.skip_reconfirmation!
      user.email = user.email_confirmation = "user_#{user.id}#{args.email_postfix}"
      user.password = user.password_confirmation =  args.pass
      user.save

      progress_bar.increment
      puts "Process finished with errors:#{user.errors.full_messages.to_sentence} | User id = #{user.id}" unless user.valid?
    end

    puts 'Task finished'
  end
end
