module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        skip_before_action :verify_authenticity_token
        respond_to :json

        def create
          build_resource(sign_up_params)
          resource.save
          if resource.persisted?
            resource.active_for_authentication? ? sign_up(resource_name, resource) : expire_data_after_sign_in!
            resource.create_profile
            render json: resource
          else
            clean_up_passwords resource
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
