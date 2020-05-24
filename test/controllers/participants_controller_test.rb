require 'test_helper'

class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  test "should get entry" do
    get participants_entry_url
    assert_response :success
  end

  test "should get participation" do
    get participants_participation_url
    assert_response :success
  end

end
