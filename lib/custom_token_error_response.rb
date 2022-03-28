module CustomTokenErrorResponse
  def body
    {
      errors: {
        message: I18n.t('devise.failure.invalid', authentication_keys: User.authentication_keys.join('/'))
      }
    }
  end

  def status
    :unauthorized
  end
end
