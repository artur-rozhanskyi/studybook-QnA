class QuestionPresenter < BasePresenter
  def current_user_owner?(current_user)
    current_user == user
  end
end
