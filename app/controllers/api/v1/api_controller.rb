module Api
  module V1
    class ApiController < ActionController::API
      include Pundit
      include ActionController::Cookies
      # Devise code
      before_action :configure_permitted_parameters, if: :devise_controller?

      # Doorkeeper code
      before_action :doorkeeper_authorize!
      respond_to :json

      rescue_from Pundit::NotAuthorizedError do |exception|
        render json: { error: exception.message }, status: :unauthorized
      end

      protected

      # Devise methods
      # Authentication key(:username) and password field will be added automatically by devise.
      def configure_permitted_parameters
        added_attrs = [:email, :first_name, :last_name]
        devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
        devise_parameter_sanitizer.permit :account_update, keys: added_attrs
      end

      private

      # Doorkeeper methods
      def current_resource_owner
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      def pundit_user
        current_resource_owner
      end
    end
  end
end
