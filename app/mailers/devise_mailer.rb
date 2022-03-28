class DeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def reset_password_instructions(record, token, opts = {})
    opts[:template_name] = record.pending_reconfirmation? ? '' : 'api/v1/devise/mailer/reset_password_instructions'
    super
  end
end
