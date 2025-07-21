RSpec.describe 'UserAttachFiles' do
  let(:file) { Tempfile.new('foo') }
  let(:user) { create(:user) }

  describe 'User attach file to question' do
    context 'with registered user' do
      let(:question) { create(:question, :with_file, user: user) }

      before do
        sign_in(user)
        visit new_question_path
        ask_question(build(:question)) do
          attach_file nil, file.path
        end
      end

      after do
        file.unlink
      end

      it 'has file name' do
        expect(page).to have_link File.basename(file.path)
      end

      context 'when edit page' do
        before do
          visit question_path(question)
          click_on 'Edit'
        end

        it 'has file name in edit question' do
          expect(page).to have_link File.basename(question.attachments.first.file.identifier)
        end

        it 'has delete checkbox' do
          expect(page).to have_field 'Remove file'
        end

        it 'has remove file' do
          expect do
            check 'Remove file'
            click_on 'Ask'
            find('h1')
          end
            .to change(question.attachments, :count).by(-1)
        end
      end
    end
  end

  describe 'User attach file to answer', :js do
    context 'with registered user' do
      let(:question) { create(:question, :with_file, user: user) }

      before do
        sign_in(user)
        visit question_path(question)
        within '.new_answer' do
          fill_in 'Your answer', with: attributes_for(:answer)[:body]
          attach_file 'answer[attachments_attributes][0][file]_', file.path
        end
        click_on 'Answer'
      end

      after do
        file.unlink
      end

      it 'has file name' do
        within '.answers' do
          expect(page).to have_link File.basename(file.path)
        end
      end

      context 'with edit form' do
        before do
          within '.answer', match: :first do
            click_on 'Edit'
          end
        end

        it 'has file name in edit question' do
          within '.answer .files', match: :first do
            expect(page).to have_link File.basename(file.path)
          end
        end

        it 'has delete checkbox' do
          within '.answer .files', match: :first do
            expect(page).to have_field 'Remove file'
          end
        end

        it 'has remove file' do
          within '.answer', match: :first do
            expect do
              check 'Remove file'
              click_on 'Save'
              find('p')
            end
              .to change(Attachment, :count).by(-1)
          end
        end
      end
    end
  end
end
