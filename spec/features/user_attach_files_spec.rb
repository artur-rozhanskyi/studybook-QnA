RSpec.describe 'UserAttachFiles', type: :feature do
  describe 'User attach file to question' do
    context 'with registered user' do
      let(:user) { create(:user) }
      let(:file) { Tempfile.new('foo') }

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
    end
  end
end
