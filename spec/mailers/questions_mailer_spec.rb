RSpec.describe QuestionsMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer) { create(:answer, question: question) }
  let(:email) { Capybara::Node::Simple.new(new_mail.body.to_s) }

  describe '.author_new_answer' do
    let(:author_mail) { described_class.author_new_answer(question) }

    it 'renders the headers' do
      expect(author_mail.subject).to eq('New answer')
      expect(author_mail.to).to eq([user.email])
      expect(author_mail.from).to eq(['qna@qna.com'])
    end

    it_behaves_like 'user greeting' do
      let(:mail) { author_mail }
    end

    it 'renders question link' do
      expect(author_mail.body.encoded).to match(question_url(question))
    end
  end

  describe '.subscribed_user' do
    let(:another_user) { create(:user) }
    let(:subscribed_mail) { described_class.subscribed_user(another_user, question) }

    before { another_user.subscribed_questions << question }

    it 'renders the headers' do
      expect(subscribed_mail.subject).to eq('New answer')
      expect(subscribed_mail.to).to eq([another_user.email])
      expect(subscribed_mail.from).to eq(['qna@qna.com'])
    end

    it_behaves_like 'user greeting' do
      let(:mail) { subscribed_mail }
      let(:user) { another_user }
    end

    it 'renders question link' do
      expect(subscribed_mail.body.encoded).to match(question_url(question))
    end
  end
end
