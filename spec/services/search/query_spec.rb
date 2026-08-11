RSpec.describe Search::Query do
  describe '#call' do
    let(:user) { create(:user) }

    context 'when OpenSearch returns hits' do
      let!(:question) { create(:question, user: user, body: 'body') }
      let(:search_client) { instance_double(Search::Client, enabled?: true, search: [question.id]) }

      before do
        allow(Search).to receive(:client).and_return(search_client)
      end

      it 'hydrates records from OpenSearch ids' do
        results = described_class.new(text: 'body', search_in: 'question').call

        expect(results['question']).to contain_exactly(question)
      end
    end

    context 'when OpenSearch returns no hits' do
      let(:search_client) { instance_double(Search::Client, enabled?: true, search: []) }

      before do
        allow(Search).to receive(:client).and_return(search_client)
      end

      it 'does not fall back to the database scope' do
        results = described_class.new(text: 'body', search_in: 'question').call

        expect(results).to eq({})
      end
    end

    context 'when OpenSearch raises an error' do
      let!(:question) { create(:question, user: user, body: 'body') }
      let(:search_client) do
        instance_double(Search::Client, enabled?: true).tap do |client|
          allow(client).to receive(:search).and_raise(StandardError, 'boom')
        end
      end

      before do
        allow(Search).to receive(:client).and_return(search_client)
      end

      it 'falls back to the database scope' do
        results = described_class.new(text: 'body', search_in: 'question').call

        expect(results['question']).to contain_exactly(question)
      end
    end
  end
end
