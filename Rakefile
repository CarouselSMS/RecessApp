# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  require 'metric_fu'
  
  MetricFu::Configuration.run do |config|
    config.metrics  = [:churn, :stats, :flog, :flay, :reek, :roodi ]
    config.graphs   = [:flog, :flay, :reek, :roodi ]
    config.flay     = { :dirs_to_flay => ['app', 'lib']  } 
    config.flog     = { :dirs_to_flog => ['app', 'lib']  }
    config.reek     = { :dirs_to_reek => ['app', 'lib']  }
    config.roodi    = { :dirs_to_roodi => ['app', 'lib'] }
    config.churn    = { :start_date => "1 year ago", :minimum_churn_count => 10 }
  end
rescue Exception => e
  # Don't explode if we have no metric_fu installed
end