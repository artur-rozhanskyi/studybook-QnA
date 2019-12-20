class UserPresenter < BasePresenter
  def name
    first_name || email
  end
end
