require 'test_helper'

class AccountExpandedsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get account_expandeds_edit_url
    assert_response :success
  end

end
