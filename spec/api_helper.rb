﻿module ApiHelper
  include Rack::Test::Methods
  include FactoryBot::Syntax::Methods
  include Rails.application.routes.url_helpers

  def sign_in_as_a_valid_user(user)
    @access_token ||= create(:access_token, resource_owner_id: user.id)
    header 'Authorization', "Bearer #{@access_token.token}"
  end

  def app
    Rails.application
  end

  def default_url_options
    { host: 'test.com' }
  end
end
