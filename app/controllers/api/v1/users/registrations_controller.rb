module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        # before_action :configure_sign_up_params, only: [:create]
        # before_action :configure_account_update_params, only: [:update]
        # skip_before_action :doorkeeper_authorize!

        skip_before_action :verify_authenticity_token
        respond_to :json

        def create
          build_resource(sign_up_params)
          resource.save
          if resource.persisted?
            resource.active_for_authentication? ? sign_up(resource_name, resource) : expire_data_after_sign_in!
            render json: resource
          else
            clean_up_passwords resource
            set_minimum_password_length
            respond_with resource
          end
        end

        protected

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end
      end
    end
  end
end
