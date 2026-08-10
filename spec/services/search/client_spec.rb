RSpec.describe Search::Client do
  describe '#search' do
    let(:raw_client) do
      instance_double(
        OpenSearch::Client,
        search: {
          'hits' => {
            'hits' => [{ '_id' => '7' }, { '_id' => '9' }]
          }
        }
      )
    end
    let(:configuration) do
      instance_double(Search::Configuration, enabled?: true, client_options: {})
    end
    let(:client) { described_class.new(configuration: configuration, raw_client: raw_client) }

    it 'returns hit ids from OpenSearch' do
      ids = client.search(Search::Indexes::QuestionIndex, 'body')

      expect(ids).to eq([7, 9])
    end
  end

  describe '#upsert' do
    let(:raw_client) { instance_double(OpenSearch::Client) }
    let(:configuration) do
      instance_double(Search::Configuration, enabled?: true, client_options: {})
    end
    let(:client) { described_class.new(configuration: configuration, raw_client: raw_client) }

    it 'indexes the document through the official client' do
      expect(raw_client).to receive(:index).with(
        index: Search::Indexes::QuestionIndex.index_name,
        id: 1,
        body: { title: 'Hello' },
        refresh: false
      )

      client.index_document(Search::Indexes::QuestionIndex, 1, { title: 'Hello' })
    end
  end

  describe '#delete' do
    let(:raw_client) { instance_double(OpenSearch::Client) }
    let(:configuration) do
      instance_double(Search::Configuration, enabled?: true, client_options: {})
    end
    let(:client) { described_class.new(configuration: configuration, raw_client: raw_client) }

    it 'deletes through the official client and ignores missing docs' do
      expect(raw_client).to receive(:delete).with(
        index: Search::Indexes::QuestionIndex.index_name,
        id: 1,
        ignore: 404
      )

      client.delete(Search::Indexes::QuestionIndex, 1)
    end
  end
end
