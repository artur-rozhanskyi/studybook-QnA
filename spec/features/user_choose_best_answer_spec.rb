RSpec.describe 'UserChooseBestAnswer', :js do
  describe 'User choose best answer' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let(:question) { create(:question, user: user) }
    let(:answers) { create_list(:answer, 5, question: question) }

    before do
      answers
      visit question_path(question)
    end

    it "has 'Best' button" do
      Capybara.using_session 'user' do
        sign_in(user)
        visit question_path(question)
        expect(page).to have_button 'Best'
      end

      Capybara.using_session 'another_user' do
        sign_in(another_user)
        visit question_path(question)
        expect(page).to have_no_button 'Best'
      end

      Capybara.using_session 'guest' do
        visit question_path(question)
        expect(page).to have_no_button 'Best'
      end
    end

    it 'marks answer as best' do
      Capybara.using_session 'user' do
        sign_in(user)
        visit question_path(question)
        click_on('Best', match: :first)
        within '.answer', match: :first do
          expect(page).to have_css('.best_answer_mark')
        end
      end

      Capybara.using_session 'another_user' do
        sign_in(another_user)
        visit question_path(question)
        within '.answer', match: :first do
          expect(page).to have_css('.best_answer_mark')
        end
      end

      Capybara.using_session 'guest' do
        visit question_path(question)
        within '.answer', match: :first do
          expect(page).to have_css('.best_answer_mark')
        end
      end
    end
  end
end
