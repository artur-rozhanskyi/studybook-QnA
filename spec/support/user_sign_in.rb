module AcceptanceHelper
  def sign_in(user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  def fill_in_question(question)
    fill_in 'Title', with: question.title
    fill_in 'Body', with: question.body
    click_on 'Ask'
  end

  def edit_answer(body)
    within '.answer' do
      click_on 'Edit'
      fill_in 'Edit your answer', with: body
      click_on 'Save'
    end
  end

  def delete_answer
    within '.answers' do
      click_on 'Delete'
      page.driver.browser.switch_to.alert.accept
    end
  end
end
