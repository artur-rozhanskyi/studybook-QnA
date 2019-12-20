RSpec.describe DailyMailer, type: :mailer do
  describe 'digest' do
    let(:user) { create(:user) }
    let!(:questions) { create_list(:question, 2) }
    let(:mail) { described_class.digest(user) }
    let(:user_name) { UserPresenter.new(user).name }

    it 'renders the headers' do
      expect(mail.subject).to eq('Daily digest')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['qna@qna.com'])
    end

    it_behaves_like 'user greeting'

    it 'renders question titles' do
      questions.each do |question|
        expect(mail.body.encoded).to match(question.title)
      end
    end
  end
end
