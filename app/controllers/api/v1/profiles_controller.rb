module Api
  module V1
    class ProfilesController < ApiController
      before_action :set_profile

      def show
        render json: @profile
      end

      def update
        authorize @profile
        ProfilesUpdater.call(@profile, profile_params)
        @profile.reload
        respond_with @profile, status: :ok do |format|
          format.json { render json: @profile.to_json, status: :ok }
        end
      end

      private

      def set_profile
        @profile = current_resource_owner.profile
      end

      def profile_params
        params.expect(profile: [:first_name, :last_name, { avatar: [:data, :filename, :type] }])
      end
    end
  end
end
