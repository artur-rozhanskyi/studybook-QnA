Doorkeeper.configure do
  orm :active_record

  resource_owner_from_credentials do
    user = User.find_for_database_authentication(email: params[:email])
    if user&.valid_for_authentication? { user.valid_password?(params[:password]) } && user&.active_for_authentication?
      request.env['warden'].set_user(user, scope: :user, store: false)
      user
    end
  end
  grant_flows %w(password)
  access_token_expires_in 5.days

  skip_client_authentication_for_password_grant true
  skip_authorization { true }
end

Rails.application.config.to_prepare do
  Doorkeeper::OAuth::ErrorResponse.prepend CustomTokenErrorResponse
end

Rails.application.config.to_prepare do
  Doorkeeper::OAuth::ErrorResponse.prepend CustomTokenErrorResponse
end
