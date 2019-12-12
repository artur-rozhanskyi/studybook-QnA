module Api
  module V1
    class UsersController < ApiController
      def index
        users = User.where.not(id: current_resource_owner.id)
        respond_with users
      end

      def me
        respond_with current_resource_owner
      end
    end
  end
end
