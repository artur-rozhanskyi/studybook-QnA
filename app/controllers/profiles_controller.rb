class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def show; end

  def edit; end

  def update
    if current_user == @profile.user && ProfilesUpdater.call(@profile, profile_params)
      flash[:notice] = 'Profile was successfully update.'
    end
    respond_with(@profile.user, :profile)
  end

  private

  def set_profile
    @profile = Profile.find_by(user_id: params[:user_id])
  end

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :avatar)
  end
end
