RSpec.describe SearchService, :sphinx do
  describe '#call' do
    let(:users) { create_list(:user, 5) }
    let!(:questions) { create_list(:question, 5, user: users[rand(0...4)], body: 'body') }
    let!(:answers) do
      create_list(:answer, 5, user: users[rand(0...4)], question: questions[rand(0...4)], body: 'body')
    end
    let!(:comments) do
      create_list(:comment, 5, user: users[rand(0...4)], commentable: questions[rand(0...4)], body: 'body')
    end

    context 'when all scope' do
      let(:search_params) { { 'text' => 'body', 'search_in' => 'all' } }

      it 'finds all questions with text' do
        expect(described_class.call(search_params)['question'].count).to eq questions.count
      end

      it 'finds all answers with text' do
        expect(described_class.call(search_params)['answer'].count).to eq answers.count
      end

      it 'finds all comments with text' do
        expect(described_class.call(search_params)['comment'].count).to eq comments.count
      end
    end

    context 'when question scope' do
      let(:search_params) { { 'text' => 'body', 'search_in' => 'question' } }

      it 'finds all questions that contains text' do
        expect(described_class.call(search_params)['question'].count).to eq questions.count
      end

      it 'does not find answers' do
        expect(described_class.call(search_params)['answer']).to be_nil
      end

      it 'does not find comments' do
        expect(described_class.call(search_params)['comment']).to be_nil
      end
    end

    context 'when answer scope' do
      let(:search_params) { { 'text' => 'body', 'search_in' => 'answer' } }

      it 'finds all answers that contains text' do
        expect(described_class.call(search_params)['answer'].count).to eq answers.count
      end

      it 'does not find answers' do
        expect(described_class.call(search_params)['question']).to be_nil
      end

      it 'does not find comments' do
        expect(described_class.call(search_params)['comment']).to be_nil
      end
    end

    context 'when comment scope' do
      let(:search_params) { { 'text' => 'body', 'search_in' => 'comment' } }

      it 'finds all comments that contains text' do
        expect(described_class.call(search_params)['comment'].count).to eq comments.count
      end

      it 'does not find answers' do
        expect(described_class.call(search_params)['answer']).to be_nil
      end

      it 'does not find comments' do
        expect(described_class.call(search_params)['question']).to be_nil
      end
    end
  end
end
