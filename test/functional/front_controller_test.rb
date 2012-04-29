require 'test_helper'

class FrontControllerTest < ActionController::TestCase

  context 'remember_customer action' do
    setup do
      @affiliate = affiliates(:valid_affiliate1)
      get :remember_customer, :slug => @affiliate.slug
    end

    should_redirect_to("pricing") { pricing_url }

    should 'create reference and give customer a reference cookie' do
      reference = assigns(:reference)
      assert_equal reference.affiliate_id, @affiliate.id
      assert_equal cookies[AppConfig['reference_cookie_name']], reference.cookie_token
    end
  end


  context 'on second page view' do
    should 'not rewrite existent cookie' do
      affiliate = affiliates(:valid_affiliate1)
      get :remember_customer, :slug => affiliate.slug
      cookie1 = cookies[AppConfig['reference_cookie_name']]

      another_affiliate = affiliates(:valid_affiliate2)
      get :remember_customer, :slug => another_affiliate.slug
      cookie2 = cookies[AppConfig['reference_cookie_name']]

      # we still have old cookies
      assert_equal cookie1, cookie2
    end
  end

end
