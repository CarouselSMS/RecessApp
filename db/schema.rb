# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100109142219) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_domain"
    t.datetime "deleted_at"
    t.string   "venue_name"
    t.string   "venue_address"
    t.string   "venue_type"
    t.string   "venue_type_other"
    t.string   "conf_message"
    t.boolean  "conf_prepend_venue",      :default => true
    t.string   "page_message"
    t.boolean  "page_prepend_venue",      :default => true
    t.integer  "offer_id"
    t.integer  "session_message_count"
    t.integer  "session_email_count"
    t.integer  "marketing_message_count", :default => 0,     :null => false
    t.boolean  "on_hold",                 :default => false
    t.integer  "admin_message_count",     :default => 0,     :null => false
    t.integer  "subscribers_count",       :default => 0,     :null => false
    t.boolean  "page_append_sub",         :default => false
    t.boolean  "locally_registered",      :default => false
  end

  add_index "accounts", ["full_domain"], :name => "index_accounts_on_full_domain"

  create_table "admin_messages", :force => true do |t|
    t.integer  "account_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_messages", ["account_id"], :name => "index_admin_messages_on_account_id"
  add_index "admin_messages", ["created_at"], :name => "index_admin_messages_on_created_at"

  create_table "affiliates", :force => true do |t|
    t.string   "first_name",                                                      :null => false
    t.string   "last_name",                                                       :null => false
    t.string   "email",                                                           :null => false
    t.string   "slug",                                                            :null => false
    t.float    "percent",                                                         :null => false
    t.integer  "references_count",                               :default => 0,   :null => false
    t.integer  "accounts_count",                                 :default => 0,   :null => false
    t.decimal  "revenue",          :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "payout",           :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "affiliates", ["slug"], :name => "index_affiliates_on_slug", :unique => true

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "changes"
    t.integer  "version",        :default => 0
    t.datetime "created_at"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "demo_guests", :force => true do |t|
    t.integer  "user_session_id"
    t.string   "phone"
    t.string   "note"
    t.integer  "wait_hours"
    t.integer  "wait_minutes"
    t.string   "aasm_state"
    t.datetime "deleted_at"
    t.integer  "party_size"
    t.integer  "page_count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", :force => true do |t|
    t.string   "name",             :null => false
    t.string   "email",            :null => false
    t.string   "company"
    t.string   "position"
    t.string   "industry"
    t.boolean  "using_ps"
    t.string   "using_ps_details"
    t.boolean  "using_ws"
    t.string   "using_ws_details"
    t.text     "how_working"
    t.string   "how_found"
    t.text     "additional_info"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guests", :force => true do |t|
    t.integer  "waitlist_id"
    t.string   "phone"
    t.string   "note"
    t.integer  "wait_hours"
    t.integer  "wait_minutes"
    t.string   "aasm_state"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "party_size"
    t.integer  "page_count",   :default => 0
  end

  add_index "guests", ["waitlist_id"], :name => "index_guests_on_waitlist_id"

  create_table "iphones", :force => true do |t|
    t.string   "udid",                          :null => false
    t.integer  "sent",       :default => 0,     :null => false
    t.boolean  "blocked",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "iphones", ["udid"], :name => "index_iphones_on_udid", :unique => true

  create_table "locations", :force => true do |t|
    t.integer  "account_id",  :null => false
    t.string   "name",        :null => false
    t.string   "internal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["account_id"], :name => "index_locations_on_account_id"

  create_table "marketing_messages", :force => true do |t|
    t.integer  "account_id",                :null => false
    t.integer  "kind",                      :null => false
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recipients", :default => 1, :null => false
    t.integer  "parts",      :default => 1, :null => false
    t.integer  "total",      :default => 1, :null => false
  end

  add_index "marketing_messages", ["account_id"], :name => "index_marketing_messages_on_account_id"
  add_index "marketing_messages", ["created_at"], :name => "index_marketing_messages_on_created_at"

  create_table "offers", :force => true do |t|
    t.integer  "account_id", :null => false
    t.string   "name",       :null => false
    t.string   "text",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "details"
  end

  create_table "password_resets", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.string   "remote_ip"
    t.string   "token"
    t.datetime "created_at"
  end

  create_table "phones", :force => true do |t|
    t.string   "number",          :null => false
    t.integer  "last_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "optout_before"
  end

  add_index "phones", ["number"], :name => "index_phones_on_number", :unique => true

  create_table "references", :force => true do |t|
    t.integer  "affiliate_id"
    t.integer  "account_id"
    t.string   "cookie_token"
    t.float    "payment_percent",                                   :default => 0.0, :null => false
    t.decimal  "payment_amount",      :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "subscription_amount", :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "registered_at"
  end

  add_index "references", ["cookie_token"], :name => "index_references_on_cookie_token", :unique => true

  create_table "reports_as_sparkline_cache", :force => true do |t|
    t.string   "model_name",                        :null => false
    t.string   "report_name",                       :null => false
    t.string   "grouping",                          :null => false
    t.string   "aggregation",                       :null => false
    t.float    "value",            :default => 0.0, :null => false
    t.datetime "reporting_period",                  :null => false
    t.integer  "run_limit",                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports_as_sparkline_cache", ["model_name", "report_name", "grouping", "aggregation", "reporting_period", "run_limit"], :name => "name_model_grouping_aggregation_period_run_limit", :unique => true
  add_index "reports_as_sparkline_cache", ["model_name", "report_name", "grouping", "aggregation", "run_limit"], :name => "name_model_grouping_agregation_run_limit"

  create_table "session_emails", :force => true do |t|
    t.integer  "account_id",  :null => false
    t.integer  "kind",        :null => false
    t.string   "email",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
  end

  add_index "session_emails", ["account_id"], :name => "index_session_emails_on_account_id"
  add_index "session_emails", ["location_id"], :name => "index_session_emails_on_location_id"

  create_table "session_messages", :force => true do |t|
    t.integer  "account_id",                        :null => false
    t.integer  "phone_id",                          :null => false
    t.integer  "kind",                              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.integer  "dlr_message_id"
    t.integer  "dlr_status",     :default => 0
    t.boolean  "dlr_final",      :default => false
  end

  add_index "session_messages", ["account_id"], :name => "index_session_messages_on_account_id"
  add_index "session_messages", ["created_at"], :name => "index_session_messages_on_created_at"
  add_index "session_messages", ["dlr_message_id"], :name => "index_session_messages_on_mt_id"
  add_index "session_messages", ["location_id"], :name => "index_session_messages_on_location_id"

  create_table "subscribers", :force => true do |t|
    t.integer  "account_id",      :null => false
    t.integer  "phone_id",        :null => false
    t.datetime "next_renewal_at", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscribers", ["account_id", "phone_id"], :name => "index_subscribers_on_account_id_and_phone_id", :unique => true
  add_index "subscribers", ["next_renewal_at"], :name => "index_subscribers_on_next_renewal_at"

  create_table "subscription_discounts", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.decimal  "amount",                 :precision => 6, :scale => 2, :default => 0.0
    t.boolean  "percent"
    t.date     "start_on"
    t.date     "end_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "apply_to_setup",                                       :default => true
    t.boolean  "apply_to_recurring",                                   :default => true
    t.integer  "trial_period_extension",                               :default => 0
  end

  create_table "subscription_payments", :force => true do |t|
    t.integer  "account_id"
    t.integer  "subscription_id"
    t.decimal  "amount",             :precision => 10, :scale => 2, :default => 0.0
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "setup"
    t.boolean  "misc"
    t.integer  "prepaid_messages"
    t.integer  "session_messages"
    t.integer  "admin_messages"
    t.integer  "marketing_messages"
  end

  add_index "subscription_payments", ["account_id"], :name => "index_subscription_payments_on_account_id"
  add_index "subscription_payments", ["subscription_id"], :name => "index_subscription_payments_on_subscription_id"

  create_table "subscription_plans", :force => true do |t|
    t.string   "name"
    t.decimal  "amount",                :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_limit"
    t.integer  "renewal_period",                                       :default => 1
    t.decimal  "setup_amount",          :precision => 10, :scale => 2
    t.integer  "trial_period",                                         :default => 15
    t.integer  "prepaid_message_count",                                :default => 250,   :null => false
    t.boolean  "ssl_allowed",                                          :default => false
  end

  create_table "subscriptions", :force => true do |t|
    t.decimal  "amount",                   :precision => 10, :scale => 2
    t.datetime "next_renewal_at"
    t.string   "card_number"
    t.string   "card_expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                                   :default => "trial"
    t.integer  "subscription_plan_id"
    t.integer  "account_id"
    t.integer  "user_limit"
    t.integer  "renewal_period",                                          :default => 1
    t.string   "billing_id"
    t.integer  "subscription_discount_id"
    t.integer  "prepaid_message_count",                                   :default => 250,     :null => false
    t.boolean  "ssl_allowed",                                             :default => false
  end

  add_index "subscriptions", ["account_id"], :name => "index_subscriptions_on_account_id"

  create_table "user_sessions", :force => true do |t|
    t.string   "session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "name"
    t.string   "remember_token"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "account_id"
    t.boolean  "admin",                                   :default => false
    t.string   "mobile",                                                     :null => false
    t.integer  "location_id"
    t.string   "admin_login_token"
  end

  add_index "users", ["account_id"], :name => "index_users_on_account_id"

  create_table "waitlists", :force => true do |t|
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
