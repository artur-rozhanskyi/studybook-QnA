module AcceptanceHelper
  def fill_in_question(question)
    fill_in 'Title', with: question.title
    fill_in 'Body', with: question.body
    yield if block_given?
    click_on 'Ask'
  end

  def edit_subject(body, subject)
    within ".#{subject}", match: :first do
      click_on 'Edit'
      fill_in "#{subject}[body]", with: body
      click_on 'Save'
    end
  end

  def delete_subject(subject)
    within ".#{subject}", match: :first do
      click_on 'Delete'
      page.driver.browser.switch_to.alert.accept
    end
  end

  def fill_in_comment(body)
    click_on 'Add comment'
    fill_in 'comment[body]', with: body
    click_on 'Comment'
  end
end
