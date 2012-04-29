raise "To avoid rake task loading problems: run 'rake clobber' in vendor/plugins/rspec" if File.directory?(File.join(File.dirname(__FILE__), *%w[.. .. vendor plugins rspec pkg]))
raise "To avoid rake task loading problems: run 'rake clobber' in vendor/plugins/rspec-rails" if File.directory?(File.join(File.dirname(__FILE__), *%w[.. .. vendor plugins rspec-rails pkg]))

# In rails 1.2, plugins aren't available in the path until they're loaded.
# Check to see if the rspec plugin is installed first and require
# it if it is.  If not, use the gem version.
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../../vendor/plugins/rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)

begin
  require 'spec/rake/spectask'

  spec_prereq = File.exist?(File.join(RAILS_ROOT, 'config', 'database.yml')) ? "db:test:prepare" : :noop
  task :noop do
  end

  task :default => :spec
  task :stats => "spec:statsetup"

  desc "Run all specs in rspec directory (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:spec => spec_prereq) do |t|
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/rspec/spec.opts\""]
    t.spec_files = FileList['rspec/**/*_spec.rb']
  end

  namespace :spec do
    desc "Run all specs in rspec directory with RCov (excluding plugin specs)"
    Spec::Rake::SpecTask.new(:rcov) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/rspec/spec.opts\""]
      t.spec_files = FileList['rspec/**/*_spec.rb']
      t.rcov = true
      t.rcov_opts = lambda do
        IO.readlines("#{RAILS_ROOT}/rspec/rcov.opts").map {|l| l.chomp.split " "}.flatten
      end
    end
  
    desc "Print Specdoc for all rspecs (excluding plugin specs)"
    Spec::Rake::SpecTask.new(:doc) do |t|
      t.spec_opts = ["--format", "specdoc", "--dry-run"]
      t.spec_files = FileList['rspec/**/*_spec.rb']
    end

    desc "Print Specdoc for all plugin specs"
    Spec::Rake::SpecTask.new(:plugin_doc) do |t|
      t.spec_opts = ["--format", "specdoc", "--dry-run"]
      t.spec_files = FileList['vendor/plugins/**/spec/**/*_spec.rb'].exclude('vendor/plugins/rspec/*')
    end

    [:models, :controllers, :views, :helpers, :lib].each do |sub|
      desc "Run the specs under rspec/#{sub}"
      Spec::Rake::SpecTask.new(sub => spec_prereq) do |t|
        t.spec_opts = ['--options', "\"#{RAILS_ROOT}/rspec/spec.opts\""]
        t.spec_files = FileList["rspec/#{sub}/**/*_spec.rb"]
      end
    end
  
    desc "Run the specs under vendor/plugins (except RSpec's own)"
    Spec::Rake::SpecTask.new(:plugins => spec_prereq) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/rspec/spec.opts\""]
      t.spec_files = FileList['vendor/plugins/**/spec/**/*_spec.rb'].exclude('vendor/plugins/rspec/*').exclude("vendor/plugins/rspec-rails/*")
    end
  
    namespace :plugins do
      desc "Runs the examples for rspec_on_rails"
      Spec::Rake::SpecTask.new(:rspec_on_rails) do |t|
        t.spec_opts = ['--options', "\"#{RAILS_ROOT}/rspec/spec.opts\""]
        t.spec_files = FileList['vendor/plugins/rspec-rails/spec/**/*_spec.rb']
      end
    end

    # Setup specs for stats
    task :statsetup do
      require 'code_statistics'
      ::STATS_DIRECTORIES << %w(Model\ specs rspec/models) if File.exist?('rspec/models')
      ::STATS_DIRECTORIES << %w(View\ specs rspec/views) if File.exist?('rspec/views')
      ::STATS_DIRECTORIES << %w(Controller\ specs rspec/controllers) if File.exist?('rspec/controllers')
      ::STATS_DIRECTORIES << %w(Helper\ specs rspec/helpers) if File.exist?('rspec/helpers')
      ::STATS_DIRECTORIES << %w(Library\ specs rspec/lib) if File.exist?('rspec/lib')
      ::CodeStatistics::TEST_TYPES << "Model specs" if File.exist?('rspec/models')
      ::CodeStatistics::TEST_TYPES << "View specs" if File.exist?('rspec/views')
      ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exist?('rspec/controllers')
      ::CodeStatistics::TEST_TYPES << "Helper specs" if File.exist?('rspec/helpers')
      ::CodeStatistics::TEST_TYPES << "Library specs" if File.exist?('rspec/lib')
      ::STATS_DIRECTORIES.delete_if {|a| a[0] =~ /test/}
    end

    namespace :db do
      namespace :fixtures do
        desc "Load fixtures (from spec/fixtures) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
        task :load => :environment do
          require 'active_record/fixtures'
          ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
          (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'rspec', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
            Fixtures.create_fixtures('rspec/fixtures', File.basename(fixture_file, '.*'))
          end
        end
      end
    end

    namespace :server do
      daemonized_server_pid = File.expand_path("spec_server.pid", RAILS_ROOT + "/tmp")

      desc "start spec_server."
      task :start do
        if File.exist?(daemonized_server_pid)
          $stderr.puts "spec_server is already running."
        else
          $stderr.puts "Starting up spec server."
          system("ruby", "script/spec_server", "--daemon", "--pid", daemonized_server_pid)
        end
      end

      desc "stop spec_server."
      task :stop do
        unless File.exist?(daemonized_server_pid)
          $stderr.puts "No server running."
        else
          $stderr.puts "Shutting down spec_server."
          system("kill", "-s", "TERM", File.read(daemonized_server_pid).strip) && 
          File.delete(daemonized_server_pid)
        end
      end

      desc "reload spec_server."
      task :restart do
        unless File.exist?(daemonized_server_pid)
          $stderr.puts "No server running."
        else
          $stderr.puts "Reloading down spec_server."
          system("kill", "-s", "USR2", File.read(daemonized_server_pid).strip)
        end
      end
    end
  end
rescue LoadError
  # Don't go down in flames if rspec isn't around.
end
