RSpec.describe 'UserAttachFiles', type: :feature do
  let(:file) { Tempfile.new('foo') }
  let(:user) { create(:user) }

  describe 'User attach file to question' do
    context 'with registered user' do
      let(:question) { create(:question, :with_file, user: user) }

      before do
        sign_in(user)
        visit new_question_path
        fill_in_question(build(:question)) do
          attach_file 'File', file.path
        end
      end

      after do
        file.unlink
      end

      it 'has file name' do
        expect(page).to have_link File.basename(file.path)
      end

      context 'when edit page' do # !!!!!!!!!!!!!
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
          end
            .to change(question.attachments, :count).by(-1)
        end
      end
    end
  end

  describe 'User attach file to answer', js: true do
    context 'with registered user' do
      let(:answer) { create(:answer, :with_file, question: create(:question), user: user) }

      before do
        sign_in(answer.user)
        visit question_path(answer.question)
        fill_in 'Your answer', with: answer.body
        attach_file 'File', file.path
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
            expect(page).to have_link File.basename(answer.attachments.first.file.identifier)
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
              fill_in 'Edit your answer', with: build(:answer).body
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
