module Api
  module V1
    module Users
      class PasswordsController < Devise::PasswordsController
        respond_to :json

        def create
          params[:user][:data] = { host: request.origin }
          super
        end

        private

        def resource_params
          params.expect(user: [:email, :password, :password_confirmation, :reset_password_token, { data: [[:host]] }])
        end
      end
    end
  end
end
