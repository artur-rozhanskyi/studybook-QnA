module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def facebook
      authenticate_with('Facebook', 'devise.facebook_data')
    end

    def google_oauth2
      authenticate_with('Google', 'devise.google_data')
    end

    def failure
      redirect_to root_path
    end

    private

    def authenticate_with(kind, data)
      @user = User.find_for_oauth(request.env['omniauth.auth'])
      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
      else
        session[data] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
    end
  end
end
