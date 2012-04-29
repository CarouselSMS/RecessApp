ActiveRecord::Schema.define(:version => 1) do

  create_table :users, :force => true do |t|
    t.string  :login,          :null => false
    t.integer :profile_visits, :null => false, :default => 0
    t.string  :type,           :null => false, :default => 'User'

    t.timestamps
  end

  create_table :reports_as_sparkline_cache, :force => true do |t|
    t.string   :model_name,       :null => false
    t.string   :report_name,      :null => false
    t.string   :grouping,         :null => false
    t.string   :aggregation,      :null => false
    t.float    :value,            :null => false, :default => 0
    t.datetime :reporting_period, :null => false
    t.integer  :run_limit,        :null => false

    t.timestamps
  end
  add_index :reports_as_sparkline_cache, [
    :model_name,
    :report_name,
    :grouping,
    :aggregation,
    :run_limit
  ], :name => :name_model_grouping_agregation_run_limit
  add_index :reports_as_sparkline_cache, [
    :model_name,
    :report_name,
    :grouping,
    :aggregation,
    :reporting_period,
    :run_limit
  ], :unique => true, :name => :name_model_grouping_aggregation_period_run_limit

end
