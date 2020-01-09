class UserPresenter < BasePresenter
  def name
    first_name || email
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
