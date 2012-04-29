ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  map.with_options(:conditions => {:subdomain => AppConfig['admin_subdomain']}) do |subdom|
    subdom.root :controller => 'subscription_admin/subscriptions', :action => 'index'
    subdom.with_options(:namespace => 'subscription_admin/', :name_prefix => 'admin_', :path_prefix => nil) do |admin|
      admin.resources :subscriptions, :member => { :charge => :post }
      admin.resources :accounts, :member => { :login_with_user => :get }
      admin.resources :subscription_plans, :as => 'plans'
      admin.resources :subscription_discounts, :as => 'discounts'
      admin.resources :affiliates, :member => { :monthly_stats => :get, :accounts => :get }, :collection => {:payouts => :any}
    end
  end
  
  # All public pages
  map.with_options(:conditions => {:subdomain => /^(www)?$/}, :controller => 'front') do |front|
    front.root
    front.connect   '/benefits-for-owners',           :action => "business_owners"
    front.connect   '/direct-sms-for-marketers',      :action => "marketers"
    front.connect   '/freedom-for-guests',            :action => "guests"
    front.connect   '/demo',                          :action => "demo"
    front.connect   '/help',                          :action => "help"
    front.feedback  '/free-limited-release-licenses', :action => "feedback_form"
    front.terms     '/terms',                         :action => "terms"
    front.connect   '/contact-us',                    :action => "contact_us"
    front.connect   '/thanks-for-contacting-us',      :action => "thanks_contact"
    front.connect   '/thanks-for-signing-up',         :action => "thanks_signup"
    front.connect   '/thanks-for-your-feedback',      :action => "thanks_feedback"
    front.connect   '/features-and-benefits',         :action => "features"
    front.pricing   '/pricing-and-signup',            :action => "pricing"    
    front.connect   '/about-us',                      :action => "about"
    front.connect   '/take-a-tour',                   :action => "tour"
    front.connect   '/integration',                   :action => "integration"
    front.partner   '/partner/:slug',                 :action => "remember_customer"
  end
  
  # Accessible from subdomains
  map.connect         '/demomodal',                 :controller => 'front', :action => "demomodal"
  map.connect         '/sorry-to-see-you-go',       :controller => 'front', :action => "exitmodal"
  map.connect         '/webapp',                    :controller => 'front'       
  
  map.resources       :messages, :collection => { :send_test_conf => :post, :send_test_page => :post, :send_test_offer => :post }
  map.resources       :offers
  map.resources       :locations, :has_many => :logs
  map.resources       :guests, :collection => { :clear => :delete, :waiting_list => :get, :paged_list => :get, :arrived_list => :get, :noshow_list => :get, :all => :get, :clear_waitlist => :post, :webapp_popup => :get }, :member => { :arrive => :post, :page => :post, :noshow => :post, :waiting => :post }

  map.resources       :demo_guests, :collection => { :clear => :delete, :waiting_list => :get, :paged_list => :get, :arrived_list => :get, :noshow_list => :get, :all => :get, :clear_waitlist => :post, :webapp_popup => :get }, :member => { :arrive => :post, :page => :post, :noshow => :post, :waiting => :post }
  
  map.subscribers     '/subscribers',               :controller => "subscribers"
  map.connect         '/subscribers/send_message',  :controller => "subscribers", :action => "send_message"
  map.connect         '/subscribers/message_log',   :controller => "subscribers", :action => "message_log"
  
  map.statistics      '/statistics',                :controller => "statistics"
  
  map.dashboard       '/', :controller => "accounts", :action => "dashboard"
  map.root            :controller => "accounts", :action => "dashboard"

  # See how all your routes lay out with "rake routes"
  map.plans           '/account-signup',                    :controller => 'accounts', :action => 'new', :plan => AppConfig['locals_plan_name'], :discount => nil
  map.connect         '/account-signup/d/:discount',        :controller => 'accounts', :action => 'new', :plan => AppConfig['locals_plan_name']
  map.thanks          '/account-signup/thanks',             :controller => 'accounts', :action => 'thanks'
  map.create          '/account-signup/create/:discount',   :controller => 'accounts', :action => 'create', :discount => nil
  map.resource        :account, :collection => { :dashboard => :get, :thanks => :get, :plans => :get, :billing => :any, :paypal => :any, :plan => :any, :cancel => :any, :canceled => :get, :store_signup_data => :post }
  map.new_account     '/account-signup/:plan/:discount',    :controller => 'accounts', :action => 'new', :plan => nil, :discount => nil, :local => false
  map.new_acc         '/signup',                            :controller => 'accounts', :action => 'new', :plan => AppConfig['locals_plan_name'], :discount => nil, :local => true

  map.resources       :users
  map.resource        :session, :member => { :create_as_admin => :get }
  map.forgot_password '/account/forgot', :controller => 'sessions', :action => 'forgot'
  map.reset_password  '/account/reset/:token', :controller => 'sessions', :action => 'reset'

  map.connect '/api/:action',         :controller => 'api', :format => "json"
  map.webapp_demo '/webapp_demo', :controller => 'demo_guests', :action => 'webapp_popup'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
