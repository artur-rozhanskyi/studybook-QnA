RSpec.describe 'UserAttachFiles', type: :feature do
  describe 'User attach file to question' do
    context 'with registered user' do
      let(:user) { create(:user) }
      let(:file) { Tempfile.new('foo') }
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

      context 'with edit page' do
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
end
