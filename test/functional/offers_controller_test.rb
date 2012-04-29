require 'test_helper'

class OffersControllerTest < ActionController::TestCase

  context "logged in" do
    setup do
      login_as :place1_admin
      @account = accounts(:place1)
    end
    
    context "index" do
      setup { get :index }
      should_render_template :index
      should_assign_to(:offers) { @account.offers.all(:order => "created_at DESC") }
    end
    
    context "new" do
      setup { get :new }
      should_render_template :new
    end
    
    context "edit" do
      setup do
        @offer = @account.offers.first
        get :edit, :id => @offer.id
      end
      should_render_template :edit
      should_assign_to(:offer) { @offer}
    end
    
    context "create" do
      setup do
        @account.offers.delete_all
        get :create, :offer => { :name => "a", :text => "b", :details => "c" }
      end
      should_redirect_to("offers list") { offers_url }
      should "add offer" do
        @account.reload
        offer = @account.offers.first
        assert_equal "a", offer.name
        assert_equal "b", offer.text
        assert_equal "c", offer.details
      end
    end
    
    context "failed create" do
      setup { get :create, :offer => { :name => "" } }
      should_render_template :new
    end
    
    context "update" do
      setup do
        @offer = @account.offers.first
        get :update, :id => @offer.id, :offer => { :name => "a", :text => "b", :details => "c" }
      end
      should_redirect_to("offers list") { offers_url }
      should_set_the_flash_to "Offer was updated"
      should "update offer" do
        @offer.reload
        assert_equal "a", @offer.name
        assert_equal "b", @offer.text
        assert_equal "c", @offer.details
      end
    end
    
    context "failed update" do
      setup { get :update, :id => @account.offers.first, :offer => { :name => "" } }
      should_render_template :edit
    end
    
    context "destroy" do
      setup do
        @offer = @account.offers.first
        get :destroy, :id => @offer.id
      end
      should_redirect_to("offers list") { offers_url }
      should_set_the_flash_to "Offer was deleted"
      should_change "Offer.count", :by => -1
    end
  end
end
