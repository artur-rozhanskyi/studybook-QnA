Devise.setup do |config|
  config.mailer_sender = 'no-reply@qna.com'

  require 'devise/orm/active_record'

  config.case_insensitive_keys = [:email]

  config.strip_whitespace_keys = [:email]

  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 11

  config.reconfirmable = true

  config.expire_all_remember_me_on_sign_out = true

  config.password_length = 6..128

  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours

  config.sign_out_via = :delete

  config.omniauth :facebook,
                  ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
                  scope: 'email',
                  info_fields: 'email,first_name,last_name'

  config.omniauth :google_oauth2,
                  ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
                  scope: 'email, profile',
                  info_fields: 'email,first_name,last_name'
end
