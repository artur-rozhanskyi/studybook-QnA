RSpec.describe 'UserSearch', type: :feature, sphinx: true, js: true do
  let(:user) { create(:user) }

  describe 'User visit search page' do
    it 'haves search form' do
      Capybara.using_session 'user' do
        sign_in(user)
        visit search_path
        expect(page).to have_button 'Search'
      end

      Capybara.using_session 'guest' do
        visit search_path
        expect(page).to have_button 'Search'
      end
    end
  end

  describe 'User search' do
    let!(:questions) { create_list(:question, 5, user: user, body: 'body') }
    let!(:answers)  { create_list(:answer, 5, user: user, question: questions[rand(0...4)], body: 'body') }
    let!(:comments) { create_list(:comment, 5, user: user, commentable: questions[rand(0...4)], body: 'body') }
    let(:query) { 'body' }

    context 'when simple search' do
      it 'finds all' do
        Capybara.using_session 'user' do
          sign_in(user)
          visit search_path
          search_query('simple_form', query)
          expect(page).to have_selector('.question', count: questions.count)
          expect(page).to have_selector('.answer', count: answers.count)
          expect(page).to have_selector('.comment', count: comments.count)
          questions.each { |question| expect(page).to have_content(question.title) }
        end

        Capybara.using_session 'guest' do
          visit search_path
          search_query('simple_form', query)
          expect(page).to have_selector('.question', count: questions.count)
          expect(page).to have_selector('.answer', count: answers.count)
          expect(page).to have_selector('.comment', count: comments.count)
          questions.each { |question| expect(page).to have_content(question.title) }
        end
      end
    end

    context 'when advanced search' do
      context 'when "question" scope' do
        it 'finds questions' do
          Capybara.using_session 'user' do
            sign_in(user)
            visit search_path
            search_query('question_form', query) { click_on 'Advanced search' }
            expect(page).to have_selector('.question', count: questions.count)
            expect(page).not_to have_selector('.answer')
            expect(page).not_to have_selector('.comment')
            questions.each { |question| expect(page).to have_content(question.title) }
          end

          Capybara.using_session 'guest' do
            visit search_path
            search_query('question_form', query) { click_on 'Advanced search' }
            expect(page).to have_selector('.question', count: questions.count)
            expect(page).not_to have_selector('.answer')
            expect(page).not_to have_selector('.comment')
            questions.each { |question| expect(page).to have_content(question.title) }
          end
        end
      end

      context 'when "answer" scope' do
        it 'finds answers' do
          Capybara.using_session 'user' do
            sign_in(user)
            visit search_path
            search_query('answer_form', query) { click_on 'Advanced search' }
            expect(page).to have_selector('.answer', count: answers.count)
            expect(page).not_to have_selector('.question')
            expect(page).not_to have_selector('.comment')
            answers.each { |answer| expect(page).to have_content(answer.body) }
          end

          Capybara.using_session 'guest' do
            visit search_path
            search_query('answer_form', query) { click_on 'Advanced search' }
            expect(page).to have_selector('.answer', count: answers.count)
            expect(page).not_to have_selector('.question')
            expect(page).not_to have_selector('.comment')
            answers.each { |answer| expect(page).to have_content(answer.body) }
          end
        end
      end

      context 'when "comment" scope' do
        it 'finds comments' do
          Capybara.using_session 'user' do
            sign_in(user)
            visit search_path
            search_query('comment_form', query) { click_on 'Advanced search' }
            expect(page).to have_selector('.comment', count: comments.count)
            expect(page).not_to have_selector('.question')
            expect(page).not_to have_selector('.answer')
            comments.each { |comment| expect(page).to have_content(comment.body) }
          end

          Capybara.using_session 'guest' do
            visit search_path
            search_query('comment_form', query) { click_on 'Advanced search' }
            expect(page).to have_selector('.comment', count: comments.count)
            expect(page).not_to have_selector('.question')
            expect(page).not_to have_selector('.answer')
            comments.each { |comment| expect(page).to have_content(comment.body) }
          end
        end
      end

      context 'when "user" scope' do
        it 'finds users' do
          Capybara.using_session 'user' do
            sign_in(user)
            visit search_path
            search_query('user_form', user.email) { click_on 'Advanced search' }
            expect(page).to have_content(user_full_name(user))
            expect(page).not_to have_selector('.questions')
            expect(page).not_to have_selector('.answers')
            expect(page).not_to have_selector('.comments')
          end

          Capybara.using_session 'guest' do
            visit search_path
            search_query('user_form', user.email) { click_on 'Advanced search' }
            expect(page).to have_content(user_full_name(user))
            expect(page).not_to have_selector('.questions')
            expect(page).not_to have_selector('.answers')
            expect(page).not_to have_selector('.comments')
          end
        end
      end
    end
  end

  def user_full_name(user)
    "#{user.first_name} #{user.last_name}"
  end
end
