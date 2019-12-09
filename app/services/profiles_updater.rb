class ProfilesUpdater
  class << self
    def call(object, params)
      profile_update object, params
    end

    private

    def profile_update(profile, params)
      profile.avatar.purge if params[:avatar]
      profile.update params if params.present?
    end
  end
end
