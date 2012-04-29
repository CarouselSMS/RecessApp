namespace :db do
  desc 'Load an initial set of data'
  task :bootstrap => :environment do
    puts 'Creating tables...'
    Rake::Task["db:migrate"].invoke

    if SubscriptionPlan.count == 0
      puts 'Loading data...'
      plans = [
        { 'name' => 'Basic',          'amount' => 29.95, 'user_limit' => nil, 'trial_period' => 1, 'prepaid_message_count' => 250, 'ssl_allowed' => false },
        { 'name' => 'Basic with SSL', 'amount' => 34.95, 'user_limit' => nil, 'trial_period' => 1, 'prepaid_message_count' => 250, 'ssl_allowed' => true }
      ].collect do |plan|
        SubscriptionPlan.create!(plan)
      end
    end
   
    plans = SubscriptionPlan.all
    user = User.first || User.create!(:name => 'Test', :login => 'test', :password => 'test', :password_confirmation => 'test', :email => 'test@example.com', :mobile => "0123456789")
    a = Account.create!(:name => 'Test Account', :domain => 'test', :plan => plans.first, :user => user)
    a.update_attribute(:full_domain, "test.#{AppConfig['base_domain']}")
    
    puts 'Changing secret in environment.rb...'
    new_secret = ActiveSupport::SecureRandom.hex(64)
    config_file_name = File.join(RAILS_ROOT, 'config', 'environment.rb')
    config_file_data = File.read(config_file_name)
    File.open(config_file_name, 'w') do |file|
      file.write(config_file_data.sub('[YOUR_SECRET]', new_secret))
    end
    
    puts "All done!  You can now login to the test account at the localhost domain with the login test and password test.\n\n"
  end
end
