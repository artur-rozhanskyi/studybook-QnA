class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def update
    if @user == current_user
      flash[:notice] = if @user.update user_params
                         'Password was successfully updated'
                       else
                         'Password was not updated'
                       end
      bypass_sign_in @user
    end
    redirect_to edit_user_profile_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
