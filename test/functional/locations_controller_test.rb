require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

  context "logged in" do
    setup { login_as :place1_admin }
    
    context "index" do
      setup { get :index }
      should_respond_with :success
      should_assign_to(:locations) { accounts(:place1).locations.all(:order => "name") }
    end
    
    context "new" do
      setup { get :new }
      should_respond_with :success
      should_assign_to(:location)
    end
    
    context "create" do
      setup { Location.delete_all }

      context "success" do
        setup { post :create, :location => { :name => "Location", :internal_id => "Internal ID" } }
        should_redirect_to("index") { locations_url }
        should_change "Location.count", :by => 1
        should_set_the_flash_to /was added/
        should "add database record" do
          account = accounts(:place1)
          account.reload
          
          location = account.locations.last
          assert_equal "Location",     location.name
          assert_equal "Internal ID",  location.internal_id
        end
      end
      
      context "failure" do
        setup { post :create, :location => { :internal_id => "Internal ID" } }
        should_render_template :new
      end
    end

    context "edit" do
      context "existing" do
        setup { get :edit, :id => (@location = accounts(:place1).locations.first).id }
        should_render_template :edit
        should_assign_to(:location) { @location }
      end
      
      context "missing" do
        setup { get :edit, :id => 0 }
        should_redirect_to("index") { locations_url }
      end
    end

    context "update" do
      context "existing" do
        setup { post :update, :id => (@location = accounts(:place1).locations.first).id, :location => { :name => "New name", :internal_id => "New ID" } }
        should_redirect_to("index") { locations_url }
        should_set_the_flash_to /updated/
        should "update record" do
          @location.reload
          assert_equal "New name", @location.name
          assert_equal "New ID", @location.internal_id
        end
      end
      
      context "missing" do
        setup { post :update, :id => 0, :location => { } }
        should_redirect_to("index") { locations_url }
      end
    end
    
    context "destroy" do
      context "existing" do
        setup { post :destroy, :id => (@location = accounts(:place1).locations.first).id }
        should_redirect_to("index") { locations_url }
        should_change "Location.count", :by => -1
        should "remove the record" do
          assert !Location.exists?(@location.id)
        end
      end
      
      context "missing" do
        setup { post :destroy, :id => 0 }
        should_redirect_to("index") { locations_url }
      end
    end
    
  end

end
