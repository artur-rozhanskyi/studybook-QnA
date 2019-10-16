module AcceptanceHelper
  def sign_in(user)
    # binding.pry
    visit new_user_session_path
    # save_and_open_page
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  def fill_in_question(question)
    fill_in 'Title', with: question.title
    fill_in 'Body', with: question.body
    click_on 'Ask'
  end
end
