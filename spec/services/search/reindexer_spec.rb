RSpec.describe Search::Reindexer do
  describe '#call' do
    let!(:questions) { create_list(:question, 2, body: 'body') }
    let(:indices_client) { instance_double(OpenSearch::API::Indices::IndicesClient) }
    let(:raw_client) do
      instance_double(
        OpenSearch::Client,
        indices: indices_client,
        count: { 'count' => questions.count }
      )
    end
    let(:search_client) do
      instance_double(
        Search::Client,
        enabled?: true,
        raw_client: raw_client
      )
    end
    let(:index_definition) { Search::Indexes::QuestionIndex }

    before do
      allow(indices_client).to receive(:exists_alias).with(name: index_definition.alias_name).and_return(true)
      allow(indices_client).to receive(:get_alias).with(name: index_definition.alias_name).and_return(
        {
          index_definition.versioned_index_name(1) => {
            'aliases' => { index_definition.alias_name => {} }
          }
        }
      )

      allow(search_client).to receive(:create_index)
      allow(search_client).to receive(:bulk).and_return('errors' => false, 'items' => [])
      allow(search_client).to receive(:switch_alias)
      allow(search_client).to receive(:delete_index)
    end

    it 'creates a new versioned index' do
      expect(search_client).to receive(:create_index).with(index_definition, index_definition.versioned_index_name(2))

      described_class.new(index_definition, client: search_client, batch_size: 1).call
    end

    it 'bulk indexes documents into the new versioned index' do
      expect(search_client).to receive(:bulk).with(
        body: array_including(
          {
            index: {
              _index: index_definition.versioned_index_name(2),
              _id: questions.first.id
            }
          }
        )
      )

      described_class.new(index_definition, client: search_client, batch_size: 1).call
    end

    it 'switches the alias atomically' do
      expect(search_client).to receive(:switch_alias).with(
        index_definition,
        index_definition.versioned_index_name(2),
        old_index_name: index_definition.versioned_index_name(1)
      )

      described_class.new(index_definition, client: search_client, batch_size: 1).call
    end

    it 'removes the old index after a successful alias switch' do
      expect(search_client).to receive(:delete_index).with(index_definition.versioned_index_name(1))

      described_class.new(index_definition, client: search_client, batch_size: 1).call
    end
  end
end
